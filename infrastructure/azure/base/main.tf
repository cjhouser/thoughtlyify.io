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
