terraform {
  required_version = "~> 1.10.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}

  use_cli         = true
  subscription_id = var.engineering_subscription_id
}

locals {
  # |CLASS            |NET |SUB |HOST
  # 11000000.10101000.00000000.00000000
  #
  # 5 bits NET  = 32 VNETs. 16 pairs for regional redundancy.
  # 4 bits SUB  = 16 subnets/vnet
  # 7 bits HOST = 128 hosts/subnet
  #
  # Region A: 192.168.0.0   - 192.168.127.255 = cidrsubnet(5,  0-15)
  # Region B: 192.168.128.0 - 192.168.255.255 = cidrsubnet(5, 16-31)
  network_class = "192.168.0.0/16"

  # non-k8s vnet provisioned from the lower range
  hub_vnet_a = cidrsubnet(local.network_class, 5, 0)
  hub_vnet_b = cidrsubnet(local.network_class, 5, 16)

  # k8s vnets are provisioned from the higher range
  platform_vnet_a = cidrsubnet(local.network_class, 5, 15)
  platform_vnet_b = cidrsubnet(local.network_class, 5, 31)
  prod_vnet_a     = cidrsubnet(local.network_class, 5, 14)
  prod_vnet_b     = cidrsubnet(local.network_class, 5, 30)
  nonprod_vnet_a  = cidrsubnet(local.network_class, 5, 13)
  nonprod_vnet_b  = cidrsubnet(local.network_class, 5, 29)
}

data "azurerm_location" "centralus" {
  location = "centralus"
}

resource "azurerm_resource_group" "platform" {
  name     = "platform"
  location = data.azurerm_location.centralus.location
}

resource "azurerm_virtual_network" "platform_a" {
  name                = "platform_a"
  location            = azurerm_resource_group.platform.location
  resource_group_name = azurerm_resource_group.platform.name
  address_space = [
    local.platform_vnet_a
  ]
}

resource "azurerm_subnet" "platform_a_nodes" {
  name                 = "platform_a_nodes"
  resource_group_name  = azurerm_resource_group.platform.name
  virtual_network_name = azurerm_virtual_network.platform_a.name
  address_prefixes = [
    cidrsubnet(local.platform_vnet_a, 4, 0)
  ]
}

resource "azurerm_user_assigned_identity" "platform" {
  location            = azurerm_resource_group.platform.location
  name                = "platform"
  resource_group_name = azurerm_resource_group.platform.name
}

resource "azurerm_user_assigned_identity" "platform_kubelet" {
  location            = azurerm_resource_group.platform.location
  name                = "platform_kubelet"
  resource_group_name = azurerm_resource_group.platform.name
}

resource "azurerm_role_assignment" "platform_kubelet_mio" {
  scope                = azurerm_user_assigned_identity.platform_kubelet.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = azurerm_user_assigned_identity.platform.principal_id
}

resource "azurerm_kubernetes_cluster" "platform_a" {
  name                = "platform_a"
  location            = azurerm_resource_group.platform.location
  resource_group_name = azurerm_resource_group.platform.name
  dns_prefix          = "platform-a" # use dns_prefix to allow external access to k8s api

  api_server_access_profile {
    authorized_ip_ranges = [
      "73.93.82.208/32",
      "24.23.136.148/32",
    ]
  }

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
    os_sku                      = "Ubuntu"
    temporary_name_for_rotation = "rotation"
    vm_size                     = "Standard_D2pds_v6"
    vnet_subnet_id              = azurerm_subnet.platform_a_nodes.id
    max_pods                    = 110
    node_count                  = 1
    os_disk_type                = "Ephemeral"
    host_encryption_enabled     = true
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
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
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
    azurerm_role_assignment.platform_kubelet_mio
  ]
}
