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

data "azurerm_location" "platform" {
  location = "centralus"
}

resource "azurerm_resource_group" "platform" {
  name     = "platform"
  location = data.azurerm_location.platform.location
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

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.platform.id
    ]
  }

  default_node_pool {
    name           = "system"
    vm_size        = "Standard_B2pls_v2"
    vnet_subnet_id = azurerm_subnet.nodes.id
    node_count     = 1
  }

  network_profile {
    dns_service_ip      = "172.20.0.4" # first four addresses are reserved
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    service_cidrs = [
      "172.20.0.0/16", # match AWS EKS default IPv4 Service prefix
      "fc00::/108"     # AWS auto-assigns 
    ]
    ip_versions = ["IPv4", "IPv6"]
  }
}
