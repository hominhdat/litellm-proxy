resource "vpc" "default" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "litellm-vpc"

}
  lifecycle {
    create_before_destroy = true
  }
}

# create 3 private subnets and 3 public subnets in vpc
resource "subnet" "private" {
  count = 3
  vpc_id = vpc.default.id
  cidr_block = cidrsubnet(vpc.default.cidr_block, 8, count.index + 1)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = false
  tags = {
    Name = "litellm-private-subnet-${count.index + 1}"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "subnet" "public" {
  count = 3
  vpc_id = vpc.default.id
  cidr_block = cidrsubnet(vpc.default.cidr_block, 8, count.index + 1)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "litellm-public-subnet-${count.index + 1}"
  }
  lifecycle {
    create_before_destroy = true
  }
}
data "aws_availability_zones" "available" {
  state = "available"
}
resource "aws_internet_gateway" "default" {
  vpc_id = vpc.default.id
  tags = {
    Name = "litellm-internet-gateway"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route_table" "public" {
  vpc_id = vpc.default.id
  tags = {
    Name = "litellm-public-route-table"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route" "public_internet_access" {
  route_table_id = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.default.id
}

resource "aws_route_table_association" "public" {
  count = length(subnet.public)
  subnet_id = subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = vpc.default.id
  tags = {
    Name = "litellm-private-route-table"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route_table_association" "private" {
  count = length(subnet.private)
  subnet_id = subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_nat_gateway" "default" {
  allocation_id = aws_eip.nat.id
  subnet_id = subnet.public[0].id
  tags = {
    Name = "litellm-nat-gateway"
  }
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_eip" "nat" {
  vpc = true
  tags = {
    Name = "litellm-nat-eip"
  }
  lifecycle {
    create_before_destroy = true
  }
}

# route all private subnets to the NAT gateway
resource "aws_route" "private_nat_gateway" {
  count = length(subnet.private)
  route_table_id = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.default.id
}

resource "aws_security_group" "default" {
  vpc_id = vpc.default.id
  name = "litellm-security-group"
  description = "Security group for litellm"
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "litellm-security-group"
  }
  lifecycle {
    create_before_destroy = true
  }
}