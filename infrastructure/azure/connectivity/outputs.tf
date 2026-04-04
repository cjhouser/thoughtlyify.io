output "bastion_public_ip" {
  description = "public IP address of the bastion host"
  value       = azurerm_linux_virtual_machine.bastion_a.public_ip_address
}
