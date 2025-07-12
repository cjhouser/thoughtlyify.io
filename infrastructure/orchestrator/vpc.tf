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
