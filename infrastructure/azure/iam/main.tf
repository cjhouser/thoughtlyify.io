terraform {
  required_version = "~> 1.10.0"
  required_providers {
    azuread = {
      source  = "opentofu/azuread"
      version = "~> 3.7.0"
    }
  }
}

provider "azuread" {
  use_cli = true
}


resource "azuread_group" "example" {
  display_name     = "MyGroup"
  security_enabled = true
}
