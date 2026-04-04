###############
### bastion ###
###############
resource "azurerm_public_ip" "bastion_a" {
  name                    = "bastion-a"
  location                = azurerm_resource_group.platform.location
  resource_group_name     = azurerm_resource_group.platform.name
  allocation_method       = "Static"
  sku                     = "Standard"
  idle_timeout_in_minutes = 4
  zones                   = ["1"]
}

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

resource "azurerm_network_interface_security_group_association" "bastion_bastion_hub_a" {
  network_interface_id      = azurerm_network_interface.bastion_a.id
  network_security_group_id = azurerm_network_security_group.bastion_a.id
}

resource "azurerm_linux_virtual_machine" "bastion_a" {
  name                            = "bastion-a"
  resource_group_name             = azurerm_resource_group.platform.name
  location                        = azurerm_resource_group.platform.location
  admin_username                  = "bastion"
  disable_password_authentication = true
  encryption_at_host_enabled      = true
  size                            = "Standard_B2pts_v2"

  network_interface_ids = [
    azurerm_network_interface.bastion_a.id,
  ]

  admin_ssh_key {
    username   = "bastion"
    public_key = file("~/.ssh/bastion.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-arm64"
    version   = "latest"
  }
}


##############
### egress ###
##############
resource "azurerm_nat_gateway" "egress_a" {
  name                = "egress-a"
  location            = azurerm_resource_group.platform.location
  resource_group_name = azurerm_resource_group.platform.name
  zones               = ["1"]
}

resource "azurerm_public_ip" "egress_a" {
  name                    = "egress-a"
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

resource "azurerm_network_interface" "nva_private_hub_a" {
  name                = "nva-private-hub-a"
  location            = azurerm_resource_group.platform.location
  resource_group_name = azurerm_resource_group.platform.name

  ip_configuration {
    name                          = "nva-private-hub-a"
    subnet_id                     = azurerm_subnet.private_hub_a.id
    private_ip_address_allocation = "Static"
    private_ip_address            = local.nva_private_hub_a
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
  }
}

resource "azurerm_linux_virtual_machine" "firewall_a" {
  name                            = "firewall-a"
  resource_group_name             = azurerm_resource_group.platform.name
  location                        = azurerm_resource_group.platform.location
  size                            = "Standard_B2pls_v2"
  encryption_at_host_enabled      = true
  admin_username                  = var.firewall_admin_username
  admin_password                  = var.firewall_admin_password
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.nva_private_hub_a.id,
    #azurerm_network_interface.nva_public_hub_a.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "freebsd"
    offer     = "freebsd-15_0"
    sku       = "15_0-release-arm64-gen2-ufs"
    version   = "15.0.0"
  }
}
