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

###############
### bastion ###
###############
resource "azurerm_subnet_network_security_group_association" "bastion_hub_a" {
  subnet_id                 = data.azurerm_subnet.bastion_hub_a.id
  network_security_group_id = azurerm_network_security_group.bastion_a.id
}

resource "azurerm_network_security_group" "bastion_a" {
  name                = "bastion-a"
  location            = data.azurerm_resource_group.platform.location
  resource_group_name = data.azurerm_resource_group.platform.name

  security_rule {
    name                       = "no-inbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  dynamic "security_rule" {
    for_each = var.bastion_whitelist
    content {
      name                       = "ssh-${security_rule.key}"
      priority                   = 500 + security_rule.key
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = security_rule.value
      destination_address_prefix = "*"
    }
  }
}

resource "azurerm_network_interface_security_group_association" "bastion_bastion_hub_a" {
  network_interface_id      = data.azurerm_network_interface.bastion_a.id
  network_security_group_id = azurerm_network_security_group.bastion_a.id
}

resource "azurerm_linux_virtual_machine" "bastion_a" {
  name                            = "bastion-a"
  resource_group_name             = data.azurerm_resource_group.platform.name
  location                        = data.azurerm_resource_group.platform.location
  admin_username                  = "oper"
  disable_password_authentication = true
  encryption_at_host_enabled      = true
  size                            = "Standard_B2pts_v2"

  network_interface_ids = [
    data.azurerm_network_interface.bastion_a.id,
  ]

  admin_ssh_key {
    username   = "oper"
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


################
### firewall ###
################
resource "azurerm_network_security_group" "firewall_untrusted_a" {
  name                = "firewall-untrusted-a"
  location            = data.azurerm_resource_group.platform.location
  resource_group_name = data.azurerm_resource_group.platform.name

  security_rule {
    name                       = "https-from-internet"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "0.0.0.0/0"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "no-inbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "firewall_untrusted_a" {
  network_security_group_id = azurerm_network_security_group.firewall_untrusted_a.id
  subnet_id                 = data.azurerm_subnet.nva_public_hub_a.id
}

resource "azurerm_network_interface_security_group_association" "firewall_untrusted_a" {
  network_security_group_id = azurerm_network_security_group.firewall_untrusted_a.id
  network_interface_id      = data.azurerm_network_interface.nva_public_hub_a.id
}

resource "azurerm_linux_virtual_machine" "firewall_a" {
  name                            = "firewall-a"
  resource_group_name             = data.azurerm_resource_group.platform.name
  location                        = data.azurerm_resource_group.platform.location
  size                            = "Standard_B2pls_v2"
  encryption_at_host_enabled      = true
  admin_username                  = "oper"
  admin_password                  = var.firewall_admin_password
  disable_password_authentication = false

  network_interface_ids = [
    data.azurerm_network_interface.nva_private_hub_a.id,
    #data.azurerm_network_interface.nva_public_hub_a.id,
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
