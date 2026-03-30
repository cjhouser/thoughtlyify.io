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
  private_hub_network_a     = cidrsubnet(local.hub_network_a, 3, 0)
  nva_private_hub_network_a = cidrhost(local.private_hub_network_a, 4)

  public_hub_network_a     = cidrsubnet(local.hub_network_a, 3, 7)
  nva_public_hub_network_a = cidrhost(local.public_hub_network_a, 4)

  bastion_hub_network_a         = cidrsubnet(local.hub_network_a, 3, 1)
  bastion_bastion_hub_network_a = cidrhost(local.bastion_hub_network_a, 4)

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

resource "azurerm_subnet" "public_hub_a" {
  name                 = "public-hub-a"
  resource_group_name  = azurerm_resource_group.platform.name
  virtual_network_name = azurerm_virtual_network.hub_a.name
  address_prefixes = [
    local.public_hub_network_a
  ]
}

resource "azurerm_subnet_nat_gateway_association" "egress_a_egress_hub_a" {
  subnet_id      = azurerm_subnet.public_hub_a.id
  nat_gateway_id = azurerm_nat_gateway.egress_a.id
}

resource "azurerm_subnet" "private_hub_a" {
  name                 = "private-hub-a"
  resource_group_name  = azurerm_resource_group.platform.name
  virtual_network_name = azurerm_virtual_network.hub_a.name
  address_prefixes = [
    local.private_hub_network_a
  ]
}


resource "azurerm_subnet" "bastion_hub_a" {
  name                 = "bastion-hub-a"
  resource_group_name  = azurerm_resource_group.platform.name
  virtual_network_name = azurerm_virtual_network.hub_a.name
  address_prefixes = [
    local.bastion_hub_network_a
  ]
}

resource "azurerm_subnet_network_security_group_association" "bastion_hub_a" {
  subnet_id                 = azurerm_subnet.bastion_hub_a.id
  network_security_group_id = azurerm_network_security_group.bastion_a.id
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

resource "azurerm_subnet_route_table_association" "spoke_nodes_platform_a" {
  subnet_id      = azurerm_subnet.nodes_platform_a.id
  route_table_id = azurerm_route_table.spoke.id
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


###############
### routing ###
###############
resource "azurerm_route_table" "nva_private_hub_a" {
  name                = "nva-private-hub-a"
  location            = azurerm_resource_group.platform.location
  resource_group_name = azurerm_resource_group.platform.name
}

resource "azurerm_route" "nva-private-hub-a" {
  name                   = "nva-private-hub-a"
  resource_group_name    = azurerm_resource_group.platform.name
  route_table_name       = azurerm_route_table.nva_private_hub_a.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = azurerm_network_interface.nva_private_hub_a.private_ip_address
}


###############################
### network security groups ###
###############################
resource "azurerm_network_security_group" "bastion_a" {
  name                = "bastion-a"
  location            = azurerm_resource_group.platform.location
  resource_group_name = azurerm_resource_group.platform.name

  security_rule {
    name                       = "ssh_from_admin_a"
    priority                   = 500
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = local.admin_a_ip
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "ssh_from_admin_b"
    priority                   = 501
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = local.admin_b_ip
    destination_address_prefix = "*"
  }
}
