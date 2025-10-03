data "aws_security_group" "eks_platform" {
  id = aws_eks_cluster.platform.vpc_config[0].cluster_security_group_id
}

resource "aws_vpc" "platform" {
  assign_generated_ipv6_cidr_block = true
  enable_dns_hostnames             = true
  enable_dns_support               = true
  cidr_block                       = "10.0.0.0/20"
  tags = {
    Name = "platform"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.platform.id

  tags = {
    Name = "igw"
  }
}

resource "aws_egress_only_internet_gateway" "eigw" {
  vpc_id = aws_vpc.platform.id

  tags = {
    Name = "eigw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.platform.id

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.igw.id
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.platform.id

  route {
    ipv6_cidr_block        = "::/0"
    egress_only_gateway_id = aws_egress_only_internet_gateway.eigw.id
  }
}

resource "aws_subnet" "north_south_a" {
  assign_ipv6_address_on_creation                = true
  availability_zone                              = "us-west-2a"
  cidr_block                                     = cidrsubnet(aws_vpc.platform.cidr_block, 3, 2)
  enable_dns64                                   = true
  enable_resource_name_dns_aaaa_record_on_launch = true
  ipv6_cidr_block                                = cidrsubnet(aws_vpc.platform.ipv6_cidr_block, 8, 2)
  map_public_ip_on_launch                        = true
  vpc_id                                         = aws_vpc.platform.id
  tags = {
    Name = "north_south_a"
  }
}

resource "aws_subnet" "north_south_b" {
  assign_ipv6_address_on_creation                = true
  availability_zone                              = "us-west-2b"
  cidr_block                                     = cidrsubnet(aws_vpc.platform.cidr_block, 3, 3)
  enable_dns64                                   = true
  enable_resource_name_dns_aaaa_record_on_launch = true
  ipv6_cidr_block                                = cidrsubnet(aws_vpc.platform.ipv6_cidr_block, 8, 3)
  map_public_ip_on_launch                        = true
  vpc_id                                         = aws_vpc.platform.id
  tags = {
    Name = "north_south_b"
  }
}

resource "aws_subnet" "north_south_c" {
  assign_ipv6_address_on_creation                = true
  availability_zone                              = "us-west-2c"
  cidr_block                                     = cidrsubnet(aws_vpc.platform.cidr_block, 3, 4)
  enable_dns64                                   = true
  enable_resource_name_dns_aaaa_record_on_launch = true
  ipv6_cidr_block                                = cidrsubnet(aws_vpc.platform.ipv6_cidr_block, 8, 4)
  map_public_ip_on_launch                        = true
  vpc_id                                         = aws_vpc.platform.id
  tags = {
    Name = "north_south_c"
  }
}

resource "aws_route_table_association" "north_south_a" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.north_south_a.id
}

resource "aws_route_table_association" "north_south_b" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.north_south_b.id
}

resource "aws_route_table_association" "north_south_c" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.north_south_c.id
}

resource "aws_lb" "platform" {
  ip_address_type    = "dualstack"
  load_balancer_type = "network"
  name               = "platform"
  security_groups = [
    aws_security_group.public.id
  ]
  subnets = [
    aws_subnet.north_south_a.id,
    aws_subnet.north_south_b.id,
    aws_subnet.north_south_c.id,
  ]
}

resource "aws_lb_target_group" "platform" {
  name            = "platform"
  port            = 443
  protocol        = "TCP"
  vpc_id          = aws_vpc.platform.id
  target_type     = "ip"
  ip_address_type = "ipv6"
  health_check {
    enabled  = true
    protocol = "HTTP"
    path     = "/healthz"
    port     = 10254
  }
}

resource "aws_lb_listener" "platform" {
  load_balancer_arn = aws_lb.platform.arn
  port              = 443
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.platform.arn
  }
}

resource "aws_security_group" "public" {
  name   = "public"
  vpc_id = aws_vpc.platform.id
}

resource "aws_vpc_security_group_ingress_rule" "http_ipv6" {
  security_group_id = aws_security_group.public.id
  description       = "Allow all inbound traffic on the load balancer listener port"
  cidr_ipv6         = "::/0"
  from_port         = aws_lb_listener.platform.port
  ip_protocol       = "tcp"
  to_port           = aws_lb_listener.platform.port
}

resource "aws_vpc_security_group_egress_rule" "platform_traffic" {
  security_group_id            = aws_security_group.public.id
  description                  = "Traffic from lb to cluster"
  referenced_security_group_id = data.aws_security_group.eks_platform.id
  from_port                    = aws_lb_target_group.platform.port
  ip_protocol                  = "tcp"
  to_port                      = aws_lb_target_group.platform.port
}

resource "aws_vpc_security_group_egress_rule" "platform_health_check" {
  security_group_id            = aws_security_group.public.id
  description                  = "Health check from lb to cluster"
  referenced_security_group_id = data.aws_security_group.eks_platform.id
  from_port                    = aws_lb_target_group.platform.health_check[0].port
  ip_protocol                  = "tcp"
  to_port                      = aws_lb_target_group.platform.health_check[0].port
}

resource "aws_vpc_security_group_ingress_rule" "platform_traffic" {
  security_group_id            = data.aws_security_group.eks_platform.id
  description                  = "Traffic from lb to cluster"
  referenced_security_group_id = aws_security_group.public.id
  from_port                    = aws_lb_target_group.platform.port
  ip_protocol                  = "tcp"
  to_port                      = aws_lb_target_group.platform.port
}

resource "aws_vpc_security_group_ingress_rule" "platform_health_check" {
  security_group_id            = data.aws_security_group.eks_platform.id
  description                  = "Health check from lb to cluster"
  referenced_security_group_id = aws_security_group.public.id
  from_port                    = aws_lb_target_group.platform.health_check[0].port
  ip_protocol                  = "tcp"
  to_port                      = aws_lb_target_group.platform.health_check[0].port
}

resource "aws_vpc_endpoint" "s3" {
  private_dns_enabled = false
  route_table_ids = [
    aws_route_table.private.id
  ]
  service_name = "com.amazonaws.${data.aws_region.current.region}.s3"
  tags = {
    Name = "s3"
  }
  vpc_endpoint_type = "Gateway"
  vpc_id            = aws_vpc.platform.id
}

resource "aws_vpc_endpoint" "ecr_api" {
  ip_address_type     = "ipv4"
  private_dns_enabled = true
  security_group_ids = [
    aws_security_group.privatelink.id
  ]
  service_name = "com.amazonaws.${data.aws_region.current.region}.ecr.api"
  subnet_ids = [
    aws_subnet.control_a.id,
    aws_subnet.control_b.id,
  ]
  tags = {
    Name = "ecr.api"
  }
  vpc_endpoint_type = "Interface"
  vpc_id            = aws_vpc.platform.id
  dns_options {
    dns_record_ip_type                             = "ipv4"
    private_dns_only_for_inbound_resolver_endpoint = false
  }
}

resource "aws_vpc_endpoint" "ec2" {
  ip_address_type     = "ipv4"
  private_dns_enabled = true
  security_group_ids = [
    aws_security_group.privatelink.id
  ]
  service_name = "com.amazonaws.${data.aws_region.current.region}.ec2"
  subnet_ids = [
    aws_subnet.control_a.id,
    aws_subnet.control_b.id,
  ]
  vpc_endpoint_type = "Interface"
  vpc_id            = aws_vpc.platform.id
  dns_options {
    dns_record_ip_type                             = "ipv4"
    private_dns_only_for_inbound_resolver_endpoint = false
  }
  tags = {
    Name = "ec2"
  }
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  ip_address_type     = "ipv4"
  private_dns_enabled = true
  security_group_ids = [
    aws_security_group.privatelink.id
  ]
  service_name = "com.amazonaws.${data.aws_region.current.region}.ecr.dkr"
  subnet_ids = [
    aws_subnet.control_a.id,
    aws_subnet.control_b.id,
  ]
  tags = {
    Name = "ecr.dkr"
  }
  vpc_endpoint_type = "Interface"
  vpc_id            = aws_vpc.platform.id
  dns_options {
    dns_record_ip_type                             = "ipv4"
    private_dns_only_for_inbound_resolver_endpoint = false
  }
}

resource "aws_security_group" "privatelink" {
  vpc_id      = aws_vpc.platform.id
  description = "allow traffic from eks nodes to privatelink"
  name        = "privatelink"
}

resource "aws_vpc_security_group_ingress_rule" "eks_nodes_to_privatelink" {
  security_group_id            = aws_security_group.privatelink.id
  referenced_security_group_id = data.aws_security_group.eks_platform.id
  ip_protocol                  = -1
}

resource "aws_vpc_security_group_egress_rule" "privatelink_to_vpc_ipv4" {
  security_group_id = aws_security_group.privatelink.id
  cidr_ipv4         = aws_vpc.platform.cidr_block
  ip_protocol       = -1
}

resource "aws_vpc_security_group_egress_rule" "privatelink_to_vpc_ipv6" {
  security_group_id = aws_security_group.privatelink.id
  cidr_ipv6         = aws_vpc.platform.ipv6_cidr_block
  ip_protocol       = -1
}
