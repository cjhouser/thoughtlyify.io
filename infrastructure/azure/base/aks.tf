resource "azurerm_user_assigned_identity" "platform" {
  location            = azurerm_resource_group.platform.location
  name                = "platform"
  resource_group_name = azurerm_resource_group.platform.name
}

resource "azurerm_role_assignment" "network_contributor_platform" {
  role_definition_name = "Network Contributor"
  description          = "Creates a private link in the node subnet."
  principal_id         = azurerm_user_assigned_identity.platform.principal_id
  scope                = azurerm_subnet.nodes_platform_a.id
}

resource "azurerm_role_assignment" "managed_identity_operator_platform" {
  role_definition_name = "Managed Identity Operator"
  description          = "The cluster using user-assigned managed identity must be granted 'Managed Identity Operator' role to assign kubelet identity"
  principal_id         = azurerm_user_assigned_identity.platform.principal_id
  scope                = azurerm_user_assigned_identity.platform_kubelet.id
}

resource "azurerm_user_assigned_identity" "platform_kubelet" {
  location            = azurerm_resource_group.platform.location
  name                = "platform-kubelet"
  resource_group_name = azurerm_resource_group.platform.name
}

resource "azurerm_kubernetes_cluster" "platform_a" {
  name                    = "platform-a"
  location                = azurerm_resource_group.platform.location
  resource_group_name     = azurerm_resource_group.platform.name
  dns_prefix              = "platform-a"
  private_cluster_enabled = true

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.platform.id
    ]
  }

  default_node_pool {
    fips_enabled                = false
    gpu_driver                  = "None"
    name                        = "system"
    os_disk_size_gb             = 110 # NVMe is 55gb*vcpu https://learn.microsoft.com/en-us/azure/virtual-machines/ephemeral-os-disks#size-requirements
    os_sku                      = "AzureLinux3"
    temporary_name_for_rotation = "rotation"
    vm_size                     = "Standard_D2pds_v6"
    vnet_subnet_id              = azurerm_subnet.nodes_platform_a.id
    max_pods                    = 110
    node_count                  = 1
    os_disk_type                = "Ephemeral"
    host_encryption_enabled     = true
    type                        = "VirtualMachineScaleSets"
    zones                       = ["1", "2", "3"]
    #kubelet_disk_type           = "Temporary" # preview feature. enable it when it reaches GA

    kubelet_config {
      allowed_unsafe_sysctls    = []
      container_log_max_line    = 2
      container_log_max_size_mb = 10
    }

    upgrade_settings {
      # Consider VM size quotas and available IP addresses when setting max surge
      max_surge                = "10%"
      drain_timeout_in_minutes = 5
    }
  }

  kubelet_identity {
    client_id                 = azurerm_user_assigned_identity.platform_kubelet.client_id
    object_id                 = azurerm_user_assigned_identity.platform_kubelet.principal_id
    user_assigned_identity_id = azurerm_user_assigned_identity.platform_kubelet.id
  }

  network_profile {
    dns_service_ip      = "172.24.0.4"
    load_balancer_sku   = "standard"
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    outbound_type       = "userDefinedRouting"
    pod_cidrs = [
      "172.16.0.0/18",
    ]
    service_cidrs = [
      "172.24.0.0/18",
    ]
    ip_versions = [
      "IPv4"
    ]
  }

  storage_profile {
    blob_driver_enabled         = false
    disk_driver_enabled         = true
    file_driver_enabled         = false
    snapshot_controller_enabled = true
  }

  depends_on = [
    azurerm_role_assignment.managed_identity_operator_platform,
    azurerm_role_assignment.network_contributor_platform,
    azurerm_route.nva_private_hub_a,
  ]
}
