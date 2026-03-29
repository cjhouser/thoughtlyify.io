variable "engineering_subscription_id" {
  type      = string
  sensitive = true
}

variable "admin_password_nva_a" {
  description = "admin password for the simulated NVA"
  type        = string
  sensitive   = true
}
