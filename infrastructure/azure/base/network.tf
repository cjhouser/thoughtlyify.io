locals {
  # [C]lass [N]etwork [S]ubnet [H]ost
  # CCCCCCCC.CCCCCCCC.NNNNNSSS.HHHHHHHH
  # 11000000.10101000.00000000.00000000
  #
  # 5 bits NET  =  32 vnets. 16 pairs for regional redundancy
  # 3 bits SUB  =   8 subnets per vnet
  # 8 bits HOST = 251 usable host addresses per subnet
  #
  # Region A: 192.168.0.0/21   - 192.168.120.0/21 = cidrsubnet("192.168.0.0/16", 5, 0-15)
  # Region B: 192.168.128.0/21 - 192.168.248.0/21 = cidrsubnet("192.168.0.0/16", 5, 16-31)
  network_class = "192.168.0.0/16"

  # vnet naming: {vnet}_network_{region}
  hub_network_a      = cidrsubnet(local.network_class, 5, 0)
  platform_network_a = cidrsubnet(local.network_class, 5, 15)

  # subnet naming: {subnet}_{vnet}_network_{region}
  egress_hub_network_a  = cidrsubnet(local.hub_network_a, 3, 0)
  bastion_hub_network_a = cidrsubnet(local.hub_network_a, 3, 1)

  nodes_platform_network_a = cidrsubnet(local.platform_network_a, 3, 0)
}


#############
### hub_a ###
#############
resource "azurerm_virtual_network" "hub_a" {
  name                = "hub_a"
  location            = azurerm_resource_group.platform.location
  resource_group_name = azurerm_resource_group.platform.name
  address_space = [
    local.hub_network_a
  ]
}

resource "azurerm_subnet" "egress_hub_a" {
  name                 = "egress_hub_a"
  resource_group_name  = azurerm_resource_group.platform.name
  virtual_network_name = azurerm_virtual_network.hub_a.name
  address_prefixes = [
    local.egress_hub_network_a
  ]
}


##################
### platform_a ###
##################
resource "azurerm_virtual_network" "platform_a" {
  name                = "platform_a"
  location            = azurerm_resource_group.platform.location
  resource_group_name = azurerm_resource_group.platform.name
  address_space = [
    local.platform_network_a
  ]
}

resource "azurerm_subnet" "nodes_platform_a" {
  name                            = "nodes_platform_a"
  default_outbound_access_enabled = false
  resource_group_name             = azurerm_resource_group.platform.name
  virtual_network_name            = azurerm_virtual_network.platform_a.name
  address_prefixes = [
    local.nodes_platform_network_a
  ]
}


###############
### peering ###
###############
resource "azurerm_virtual_network_peering" "hub_a_to_platform_a" {
  name                      = "hub_a_to_platform_a"
  resource_group_name       = azurerm_resource_group.platform.name
  virtual_network_name      = azurerm_virtual_network.hub_a.name
  remote_virtual_network_id = azurerm_virtual_network.platform_a.id
  allow_forwarded_traffic   = true
}

resource "azurerm_virtual_network_peering" "platform_a_to_hub_a" {
  name                      = "platform_a_to_hub_a"
  resource_group_name       = azurerm_resource_group.platform.name
  virtual_network_name      = azurerm_virtual_network.platform_a.name
  remote_virtual_network_id = azurerm_virtual_network.hub_a.id
  allow_forwarded_traffic   = true
}


