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
    Name                     = "north_south_a"
    "kubernetes.io/role/elb" = 1
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
    Name                     = "north_south_b"
    "kubernetes.io/role/elb" = 1
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
    Name                     = "north_south_c"
    "kubernetes.io/role/elb" = 1
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
  ip_address_type = "dualstack"
  load_balancer_type = "network"
  name            = "platform"
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
    port = 10254
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
  referenced_security_group_id = aws_eks_cluster.platform.vpc_config[0].cluster_security_group_id
  from_port                    = aws_lb_target_group.platform.port
  ip_protocol                  = "tcp"
  to_port                      = aws_lb_target_group.platform.port
}

resource "aws_vpc_security_group_egress_rule" "platform_health_check" {
  security_group_id            = aws_security_group.public.id
  description                  = "Health check from lb to cluster"
  referenced_security_group_id = aws_eks_cluster.platform.vpc_config[0].cluster_security_group_id
  from_port                    = aws_lb_target_group.platform.health_check[0].port
  ip_protocol                  = "tcp"
  to_port                      = aws_lb_target_group.platform.health_check[0].port
}

resource "aws_vpc_security_group_ingress_rule" "platform_traffic" {
  security_group_id            = aws_eks_cluster.platform.vpc_config[0].cluster_security_group_id
  description                  = "Traffic from lb to cluster"
  referenced_security_group_id = aws_security_group.public.id
  from_port                    = aws_lb_target_group.platform.port
  ip_protocol                  = "tcp"
  to_port                      = aws_lb_target_group.platform.port
}

resource "aws_vpc_security_group_ingress_rule" "platform_health_check" {
  security_group_id            = aws_eks_cluster.platform.vpc_config[0].cluster_security_group_id
  description                  = "Health check from lb to cluster"
  referenced_security_group_id = aws_security_group.public.id
  from_port                    = aws_lb_target_group.platform.health_check[0].port
  ip_protocol                  = "tcp"
  to_port                      = aws_lb_target_group.platform.health_check[0].port
}