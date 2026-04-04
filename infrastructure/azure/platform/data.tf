data "azurerm_resource_group" "platform" {
  name = "platform"
}

data "azurerm_private_endpoint_connection" "platform_a" {
  name                = "kube-apiserver"
  resource_group_name = azurerm_kubernetes_cluster.platform_a.node_resource_group
}

data "azurerm_virtual_network" "platform_a" {
  name                = "platform-a"
  resource_group_name = data.azurerm_resource_group.platform.name
}

data "azurerm_subnet" "nodes_platform_a" {
  name                 = "nodes-platform-a"
  virtual_network_name = data.azurerm_virtual_network.platform_a.name
  resource_group_name  = data.azurerm_resource_group.platform.name
}
