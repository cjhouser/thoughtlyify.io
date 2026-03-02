variable "cloudflare_api_token" {
  sensitive   = true
  type        = string
  description = "Used for DNS-01 challenge"
}

variable "email" {
  sensitive   = true
  type        = string
  description = "Used for DNS-01 challenge"
}
