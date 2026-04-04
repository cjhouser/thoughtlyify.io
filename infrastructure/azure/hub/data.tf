data "azurerm_resource_group" "platform" {
  name = "platform"
}

data "azurerm_virtual_network" "hub_a" {
  name                = "hub-a"
  resource_group_name = data.azurerm_resource_group.platform.name
}

data "azurerm_subnet" "bastion_hub_a" {
  name                 = "bastion-hub-a"
  resource_group_name  = data.azurerm_resource_group.platform.name
  virtual_network_name = data.azurerm_virtual_network.hub_a.name
}

data "azurerm_network_interface" "bastion_a" {
  name                = "bastion-a"
  resource_group_name = data.azurerm_resource_group.platform.name
}

data "azurerm_network_interface" "nva_private_hub_a" {
  name                = "nva-private-hub-a"
  resource_group_name = data.azurerm_resource_group.platform.name
}

data "azurerm_network_interface" "nva_public_hub_a" {
  name                = "nva-public-hub-a"
  resource_group_name = data.azurerm_resource_group.platform.name
}
