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
