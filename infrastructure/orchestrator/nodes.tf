resource "aws_subnet" "nodes_a" {
  assign_ipv6_address_on_creation                = true
  availability_zone                              = "us-west-2a"
  cidr_block                                     = cidrsubnet(aws_vpc.platform.cidr_block, 3, 5)
  enable_dns64                                   = true
  enable_resource_name_dns_aaaa_record_on_launch = true
  ipv6_cidr_block                                = cidrsubnet(aws_vpc.platform.ipv6_cidr_block, 8, 5)
  vpc_id                                         = aws_vpc.platform.id
  tags = {
    Name                              = "nodes_a"
  }
}

resource "aws_subnet" "nodes_b" {
  assign_ipv6_address_on_creation                = true
  availability_zone                              = "us-west-2b"
  cidr_block                                     = cidrsubnet(aws_vpc.platform.cidr_block, 3, 6)
  enable_dns64                                   = true
  enable_resource_name_dns_aaaa_record_on_launch = true
  ipv6_cidr_block                                = cidrsubnet(aws_vpc.platform.ipv6_cidr_block, 8, 6)
  vpc_id                                         = aws_vpc.platform.id
  tags = {
    Name                              = "nodes_b"
  }
}

resource "aws_subnet" "nodes_c" {
  assign_ipv6_address_on_creation                = true
  availability_zone                              = "us-west-2c"
  cidr_block                                     = cidrsubnet(aws_vpc.platform.cidr_block, 3, 7)
  enable_dns64                                   = true
  enable_resource_name_dns_aaaa_record_on_launch = true
  ipv6_cidr_block                                = cidrsubnet(aws_vpc.platform.ipv6_cidr_block, 8, 7)
  vpc_id                                         = aws_vpc.platform.id
  tags = {
    Name                              = "nodes_c"
  }
}

resource "aws_route_table_association" "nodes_a" {
  route_table_id = aws_route_table.private.id
  subnet_id      = aws_subnet.nodes_a.id
}

resource "aws_route_table_association" "nodes_b" {
  route_table_id = aws_route_table.private.id
  subnet_id      = aws_subnet.nodes_b.id
}

resource "aws_route_table_association" "nodes_c" {
  route_table_id = aws_route_table.private.id
  subnet_id      = aws_subnet.nodes_c.id
}

resource "aws_eks_node_group" "nodes_0" {
  ami_type        = "AL2023_ARM_64_STANDARD"
  capacity_type   = "SPOT"
  cluster_name    = aws_eks_cluster.platform.name
  disk_size       = "20"
  node_group_name = "node_0"
  node_role_arn   = data.aws_iam_role.eks_node.arn
  release_version = "1.33.0-20250704"
  version         = "1.33"

  instance_types = [
    "t4g.medium"
  ]

  subnet_ids = [
    aws_subnet.nodes_a.id,
    aws_subnet.nodes_b.id,
    aws_subnet.nodes_c.id
  ]

  scaling_config {
    desired_size = 3
    max_size     = 4
    min_size     = 3
  }

  update_config {
    max_unavailable = 1
  }
}
