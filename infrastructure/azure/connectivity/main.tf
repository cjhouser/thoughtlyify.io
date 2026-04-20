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

resource "azurerm_resource_group" "platform" {
  name     = "platform"
  location = data.azurerm_location.centralus.location
}

#############
### hub_a ###
#############
resource "azurerm_virtual_network" "hub_a" {
  name                = "hub-a"
  location            = azurerm_resource_group.platform.location
  resource_group_name = azurerm_resource_group.platform.name
  address_space = [
    local.hub_a
  ]
}

resource "azurerm_subnet" "public_hub_a" {
  name                            = "public-hub-a"
  default_outbound_access_enabled = false
  resource_group_name             = azurerm_resource_group.platform.name
  virtual_network_name            = azurerm_virtual_network.hub_a.name
  address_prefixes = [
    local.untrusted_hub_a
  ]
}

resource "azurerm_subnet" "private_hub_a" {
  name                            = "private-hub-a"
  default_outbound_access_enabled = false
  resource_group_name             = azurerm_resource_group.platform.name
  virtual_network_name            = azurerm_virtual_network.hub_a.name
  address_prefixes = [
    local.trusted_hub_a
  ]
}

resource "azurerm_subnet" "bastion_hub_a" {
  name                            = "bastion-hub-a"
  default_outbound_access_enabled = false
  resource_group_name             = azurerm_resource_group.platform.name
  virtual_network_name            = azurerm_virtual_network.hub_a.name
  address_prefixes = [
    local.bastion_hub_a
  ]
}


##################
### platform_a ###
##################
resource "azurerm_virtual_network" "platform_a" {
  name                = "platform-a"
  location            = azurerm_resource_group.platform.location
  resource_group_name = azurerm_resource_group.platform.name
  address_space = [
    local.platform_a
  ]
}

resource "azurerm_subnet" "nodes_platform_a" {
  name                            = "nodes-platform-a"
  default_outbound_access_enabled = false
  resource_group_name             = azurerm_resource_group.platform.name
  virtual_network_name            = azurerm_virtual_network.platform_a.name
  address_prefixes = [
    local.nodes_platform_a
  ]
}

resource "azurerm_subnet_route_table_association" "nodes_platform_a" {
  subnet_id      = azurerm_subnet.nodes_platform_a.id
  route_table_id = azurerm_route_table.nva_private_hub_a.id
}


###############
### peering ###
###############
resource "azurerm_virtual_network_peering" "hub_a_to_platform_a" {
  name                      = "hub-a-to-platform-a"
  resource_group_name       = azurerm_resource_group.platform.name
  virtual_network_name      = azurerm_virtual_network.hub_a.name
  remote_virtual_network_id = azurerm_virtual_network.platform_a.id
  allow_forwarded_traffic   = true
}

resource "azurerm_virtual_network_peering" "platform_a_to_hub_a" {
  name                      = "platform-a-to-hub-a"
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

resource "azurerm_route" "nva_private_hub_a" {
  name                   = "nva-private-hub-a"
  resource_group_name    = azurerm_resource_group.platform.name
  route_table_name       = azurerm_route_table.nva_private_hub_a.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = azurerm_network_interface.nva_private_hub_a.private_ip_address
}


##########################
### network interfaces ###
##########################
resource "azurerm_network_interface" "bastion_a" {
  name                = "bastion-a"
  location            = azurerm_resource_group.platform.location
  resource_group_name = azurerm_resource_group.platform.name

  ip_configuration {
    name                          = "bastion-a"
    subnet_id                     = azurerm_subnet.bastion_hub_a.id
    private_ip_address_allocation = "Static"
    private_ip_address            = local.bastion_bastion_hub_a
    primary                       = true
    public_ip_address_id          = azurerm_public_ip.bastion_a.id
  }
}

resource "azurerm_network_interface" "nva_private_hub_a" {
  name                = "nva-private-hub-a"
  location            = azurerm_resource_group.platform.location
  resource_group_name = azurerm_resource_group.platform.name

  ip_configuration {
    name                          = "nva-private-hub-a"
    subnet_id                     = azurerm_subnet.private_hub_a.id
    private_ip_address_allocation = "Static"
    private_ip_address            = local.nva_private_hub_a
    primary                       = true
  }
}

resource "azurerm_network_interface" "nva_public_hub_a" {
  name                  = "nva-public-hub-a"
  location              = azurerm_resource_group.platform.location
  resource_group_name   = azurerm_resource_group.platform.name
  ip_forwarding_enabled = true

  ip_configuration {
    name                          = "nva-public-hub-a"
    subnet_id                     = azurerm_subnet.public_hub_a.id
    private_ip_address_allocation = "Static"
    private_ip_address            = local.nva_public_hub_a
    primary                       = true
    public_ip_address_id          = azurerm_public_ip.firewall_a.id
  }
}


###########################
### public IP addresses ###
###########################
resource "azurerm_public_ip" "bastion_a" {
  name                    = "bastion-a"
  location                = azurerm_resource_group.platform.location
  resource_group_name     = azurerm_resource_group.platform.name
  allocation_method       = "Static"
  sku                     = "Standard"
  idle_timeout_in_minutes = 4
  zones                   = ["1"]
}

resource "azurerm_public_ip" "firewall_a" {
  name                    = "firewall-a"
  location                = azurerm_resource_group.platform.location
  resource_group_name     = azurerm_resource_group.platform.name
  allocation_method       = "Static"
  sku                     = "Standard"
  idle_timeout_in_minutes = 4
  zones                   = ["1"]
}
