output "platform_a_api_server_hostname" {
  description = "API server for platform-a cluster"
  value       = azurerm_kubernetes_cluster.platform_a.private_fqdn
}

output "platform_a_api_server_ip" {
  description = "Private link IP address for platform-a API server"
  value       = data.azurerm_private_endpoint_connection.platform_a.private_service_connection[0].private_ip_address
}
