locals {
  # |CLASS            |NET |SUB |HOST
  # 11000000.10101000.00000000.00000000
  #
  # 5 bits NET  = 32 VNETs. 16 pairs for regional redundancy.
  # 4 bits SUB  = 16 subnets/vnet
  # 7 bits HOST = 128 hosts/subnet
  #
  # Region A: 192.168.0.0   - 192.168.127.255 = cidrsubnet(5,  0-15)
  # Region B: 192.168.128.0 - 192.168.255.255 = cidrsubnet(5, 16-31)
  network_class = "192.168.0.0/16"

  # non-k8s vnet provisioned from the lower range
  hub_vnet_a = cidrsubnet(local.network_class, 5, 0)
  hub_vnet_b = cidrsubnet(local.network_class, 5, 16)

  # k8s vnets are provisioned from the higher range
  platform_vnet_a = cidrsubnet(local.network_class, 5, 15)
  platform_vnet_b = cidrsubnet(local.network_class, 5, 31)
  prod_vnet_a     = cidrsubnet(local.network_class, 5, 14)
  prod_vnet_b     = cidrsubnet(local.network_class, 5, 30)
  nonprod_vnet_a  = cidrsubnet(local.network_class, 5, 13)
  nonprod_vnet_b  = cidrsubnet(local.network_class, 5, 29)
}
