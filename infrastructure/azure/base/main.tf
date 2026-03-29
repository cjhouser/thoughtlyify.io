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
resource "azurerm_subnet_nat_gateway_association" "pubic_hub_a_egress_a" {
  subnet_id      = azurerm_subnet.public_hub_a.id
  nat_gateway_id = azurerm_nat_gateway.egress_a.id
}

