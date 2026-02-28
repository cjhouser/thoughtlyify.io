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
  ipv4_prefix = "10.0.0.0/20"
}

data "azurerm_location" "centralus" {
  location = "centralus"
}

resource "azurerm_resource_group" "platform" {
  name     = "platform"
  location = data.azurerm_location.centralus.location
}

resource "azurerm_virtual_network" "platform" {
  name                = "platform"
  location            = azurerm_resource_group.platform.location
  resource_group_name = azurerm_resource_group.platform.name
  address_space = [
    local.ipv4_prefix
  ]
}

resource "azurerm_subnet" "nodes" {
  name                 = "nodes"
  resource_group_name  = azurerm_resource_group.platform.name
  virtual_network_name = azurerm_virtual_network.platform.name
  address_prefixes = [
    cidrsubnet(local.ipv4_prefix, 3, 6)
  ]
}

resource "azurerm_user_assigned_identity" "platform" {
  location            = azurerm_resource_group.platform.location
  name                = "platform"
  resource_group_name = azurerm_resource_group.platform.name
}

resource "azurerm_kubernetes_cluster" "platform" {
  name                = "platform"
  location            = azurerm_resource_group.platform.location
  resource_group_name = azurerm_resource_group.platform.name
  dns_prefix          = "platform" # use dns_prefix to allow external access to k8s api

  api_server_access_profile {
    authorized_ip_ranges = [
      "73.93.82.208/32"
    ]
  }

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.platform.id
    ]
  }

  default_node_pool {
    name                        = "system"
    os_disk_size_gb             = 110 # NVMe is 55gb*vcpu https://learn.microsoft.com/en-us/azure/virtual-machines/ephemeral-os-disks#size-requirements
    temporary_name_for_rotation = "rotation"
    vm_size                     = "Standard_D2pds_v6"
    vnet_subnet_id              = azurerm_subnet.nodes.id
    node_count                  = 1
    #os_disk_type               = "Ephemeral" https://github.com/Azure/AKS/issues/5568
    #host_encrpytion_enabled = true # enable when Ephemeral os_disk_type is enabled

    kubelet_config {
      container_log_max_line    = 2
      container_log_max_size_mb = 10
    }
  }

  network_profile {
    dns_service_ip      = "172.20.0.4" # first four addresses are reserved
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    service_cidrs = [
      "172.20.0.0/16", # match AWS EKS default IPv4 Service prefix
    ]
    ip_versions = [
      "IPv4"
    ]
  }
}
