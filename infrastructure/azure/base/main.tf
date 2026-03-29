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

data "azurerm_location" "centralus" {
  location = "centralus"
}

resource "azurerm_resource_group" "platform" {
  name     = "platform"
  location = data.azurerm_location.centralus.location
}
# Provider does not support standardv2 nat gateway
resource "azurerm_nat_gateway" "egress_a" {
  name                = "egress_a"
  location            = azurerm_resource_group.platform.location
  resource_group_name = azurerm_resource_group.platform.name
  zones               = ["1"]
}

resource "azurerm_public_ip" "egress_a" {
  name                    = "egress_a"
  location                = azurerm_resource_group.platform.location
  resource_group_name     = azurerm_resource_group.platform.name
  allocation_method       = "Static"
  sku                     = "Standard"
  idle_timeout_in_minutes = 4
  zones                   = ["1"]
}

resource "azurerm_nat_gateway_public_ip_association" "egress_a_egress_a" {
  nat_gateway_id       = azurerm_nat_gateway.egress_a.id
  public_ip_address_id = azurerm_public_ip.egress_a.id
}

resource "azurerm_subnet_nat_gateway_association" "pubic_hub_a_egress_a" {
  subnet_id      = azurerm_subnet.public_hub_a.id
  nat_gateway_id = azurerm_nat_gateway.egress_a.id
}

