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
  admin_a_ip = "73.93.82.208/32"
  admin_b_ip = "24.23.136.148/32"
}

data "azurerm_location" "centralus" {
  location = "centralus"
}

data "azurerm_private_endpoint_connection" "platform_a" {
  name                = "kube-apiserver"
  resource_group_name = azurerm_kubernetes_cluster.platform_a.node_resource_group
}

resource "azurerm_resource_group" "platform" {
  name     = "platform"
  location = data.azurerm_location.centralus.location
}
