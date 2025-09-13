resource "aws_subnet" "control_a" {
  assign_ipv6_address_on_creation                = true
  availability_zone                              = "us-west-2a"
  cidr_block                                     = cidrsubnet(aws_vpc.platform.cidr_block, 3, 0)
  enable_resource_name_dns_aaaa_record_on_launch = true
  ipv6_cidr_block                                = cidrsubnet(aws_vpc.platform.ipv6_cidr_block, 8, 0)
  vpc_id                                         = aws_vpc.platform.id
  tags = {
    Name = "control-a"
  }
}

resource "aws_subnet" "control_b" {
  assign_ipv6_address_on_creation                = true
  availability_zone                              = "us-west-2b"
  cidr_block                                     = cidrsubnet(aws_vpc.platform.cidr_block, 3, 1)
  enable_resource_name_dns_aaaa_record_on_launch = true
  ipv6_cidr_block                                = cidrsubnet(aws_vpc.platform.ipv6_cidr_block, 8, 1)
  vpc_id                                         = aws_vpc.platform.id
  tags = {
    Name = "control-b"
  }
}

resource "aws_route_table_association" "control_a" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.control_a.id
}

resource "aws_route_table_association" "control_b" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.control_b.id
}

resource "aws_eks_cluster" "platform" {
  bootstrap_self_managed_addons = false
  name                          = "platform"
  role_arn                      = data.aws_iam_role.eks_cluster_role.arn
  version                       = "1.33"

  access_config {
    authentication_mode = "API"
  }
  kubernetes_network_config {
    ip_family = "ipv6"
  }
  upgrade_policy {
    support_type = "STANDARD"
  }
  vpc_config {
    endpoint_private_access = true
    public_access_cidrs = [
      "73.93.82.208/32"
    ]
    subnet_ids = [
      aws_subnet.control_a.id,
      aws_subnet.control_b.id
    ]
  }
  zonal_shift_config {
    enabled = false
  }
}

resource "aws_eks_access_entry" "chouser" {
  cluster_name  = aws_eks_cluster.platform.name
  principal_arn = data.aws_iam_user.chouser.arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "cluster_admins" {
  cluster_name  = aws_eks_cluster.platform.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = data.aws_iam_user.chouser.arn

  access_scope {
    type = "cluster"
  }

  depends_on = [
    aws_eks_access_entry.chouser
  ]
}

resource "aws_eks_addon" "cni" {
  addon_name    = "vpc-cni"
  addon_version = "v1.19.6-eksbuild.1"
  cluster_name  = aws_eks_cluster.platform.name
}

resource "aws_eks_addon" "proxy" {
  addon_name    = "kube-proxy"
  addon_version = "v1.33.0-eksbuild.2"
  cluster_name  = aws_eks_cluster.platform.name
}

resource "aws_eks_addon" "coredns" {
  addon_name    = "coredns"
  addon_version = "v1.12.1-eksbuild.2"
  cluster_name  = aws_eks_cluster.platform.name
  depends_on = [
    aws_eks_node_group.nodes_0
  ]
}
