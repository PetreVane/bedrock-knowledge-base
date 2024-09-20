

# Creates a VPC with the specified CIDR block and enable DNS hostnames.
resource "aws_vpc" "ecs_vpc" {
  cidr_block = var.cidr_block
  enable_dns_hostnames = true
}

# Creates public subnets within the VPC based on the provided CIDR blocks.
resource "aws_subnet" "ecs_public_subnets" {
  count = length(var.subnet_cidr_block)
  vpc_id = aws_vpc.ecs_vpc.id
  cidr_block = var.subnet_cidr_block[count.index]
  availability_zone = var.availability_zone[count.index]
  map_public_ip_on_launch = true
}

# Attaches an internet gateway to the VPC for external internet access.
resource "aws_internet_gateway" "ecs_internet_gateway" {
  vpc_id = aws_vpc.ecs_vpc.id
}

# Creates a route table for the VPC and set a default route to the internet gateway.
resource "aws_route_table" "ecs_route_table" {
  vpc_id = aws_vpc.ecs_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ecs_internet_gateway.id
  }
}

# Associates the public subnets with the route table for internet access.
resource "aws_route_table_association" "ecs_route_table_association" {
  count = length(var.subnet_cidr_block)
  subnet_id = aws_subnet.ecs_public_subnets[count.index].id
  route_table_id = aws_route_table.ecs_route_table.id
}

# Creates a security group for ECS instances to control inbound traffic.
resource "aws_security_group" "ecs_security_group" {
  name        = "ecs_security_group-${random_id.generator.hex}"
  description = "Security group for running containers"
  vpc_id      = aws_vpc.ecs_vpc.id
}

# Defines an ingress rule allowing inbound traffic on port 3000 within the security group
resource "aws_vpc_security_group_ingress_rule" "ecs_ingress_rule" {
  security_group_id = aws_security_group.ecs_security_group.id

  cidr_ipv4 = "0.0.0.0/0"
  from_port   = 3000
  ip_protocol = "tcp"
  to_port     = 3000
}

# Defines an egress rule allowing all outbound traffic from the security group.
resource "aws_vpc_security_group_egress_rule" "ecs_egress_rule" {
  security_group_id = aws_security_group.ecs_security_group.id
  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol       = "-1"
}