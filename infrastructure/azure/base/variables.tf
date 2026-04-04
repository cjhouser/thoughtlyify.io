variable "engineering_subscription_id" {
  type      = string
  sensitive = true
}

variable "firewall_admin_password" {
  description = "OS administrative user's password on firewall VMs"
  type        = string
  sensitive   = true
}

variable "firewall_admin_username" {
  description = "OS administrative user's username on firewall VMs"
  type        = string
  sensitive   = true
}
