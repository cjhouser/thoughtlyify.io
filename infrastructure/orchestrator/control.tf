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
  role_arn                      = aws_iam_role.eks_cluster_role.arn
  version                       = "1.33"

  access_config {
    authentication_mode = "API"
  }
  # Ensure that IAM Role permissions are created before and deleted
  # after EKS Cluster handling. Otherwise, EKS will not be able to
  # properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.amazon_eks_cluster_policy
  ]
  kubernetes_network_config {
    ip_family = "ipv6"
  }
  upgrade_policy {
    support_type = "STANDARD"
  }
  vpc_config {
    public_access_cidrs = [
      "::/0",
      "0.0.0.0/0"
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
