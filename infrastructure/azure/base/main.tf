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

  client_id       = "15b50407-9822-4201-a5cd-2829f80f0e98"
  tenant_id       = "dc5223e4-6d55-44db-889f-9e039c0b432c"
  subscription_id = "b41ee6ed-8dd3-422c-84da-405354f1b2cb"
}

data "azurerm_location" "westus2" {
  location = "westus2"
}

resource "azurerm_resource_group" "platform" {
  name     = "platform"
  location = data.azurerm_location.westus2.location
}

resource "azurerm_virtual_network" "platform" {
  name                = "platform"
  location            = azurerm_resource_group.platform.location
  resource_group_name = azurerm_resource_group.platform.name
  address_space = [
    local.ipv4_prefix,
    local.ipv6_prefix
  ]
}

resource "azurerm_subnet" "nodes" {
  name                 = "nodes"
  resource_group_name  = azurerm_resource_group.platform.name
  virtual_network_name = azurerm_virtual_network.platform.name
  address_prefixes = [
    cidrsubnet(local.ipv4_prefix, 3, 6),
    cidrsubnet(local.ipv6_prefix, 8, 6)
  ]
}

resource "azurerm_kubernetes_cluster" "platform" {
  name                = "platform"
  location            = azurerm_resource_group.platform.location
  resource_group_name = azurerm_resource_group.platform.name
  dns_prefix          = "platform" # use dns_prefix to allow external access to k8s api

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name                    = "platform-nodes"
    vm_size                 = "b2pls-v2"
    auto_scaling_enabled    = false
    host_encryption_enabled = false # revisit this later. skipping it to avoid azure key vault
    node_public_ip_enabled  = false
    gpu_driver              = "None"
    fips_enabled            = false
    os_disk_size_gb         = 30
    os_sku                  = "Ubuntu"
    pod_subnet_id           = azurerm_subnet.nodes.id
    node_labels = {
      "node-role.kubernetes.io/compute" = "compute"
    }
  }
}
