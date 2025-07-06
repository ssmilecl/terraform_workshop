# VPC Module - Child Module
# This module creates the networking foundation for the web application

# Data source to get available availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Create VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.common_tags, {
    Name = "${var.project_prefix}-vpc-${var.random_suffix}"
    Type = "VPC"
  })
}

# Create Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id # Resource attribute reference

  tags = merge(var.common_tags, {
    Name = "${var.project_prefix}-igw-${var.random_suffix}"
    Type = "Internet Gateway"
  })
}

# Create public subnets
resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id                  = aws_vpc.main.id # Resource attribute reference
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(var.common_tags, {
    Name = "${var.project_prefix}-public-subnet-${count.index + 1}-${var.random_suffix}"
    Type = "Public Subnet"
    AZ   = var.availability_zones[count.index]
  })
}

# Create route table for public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id # Resource attribute reference

  # Route to Internet Gateway
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id # Resource attribute reference
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_prefix}-public-rt-${var.random_suffix}"
    Type = "Public Route Table"
  })
}

# Associate route table with public subnets
resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id # Resource attribute reference
  route_table_id = aws_route_table.public.id         # Resource attribute reference
}

# Security group for web servers
resource "aws_security_group" "web" {
  name_prefix = "${var.project_prefix}-web-sg-${var.random_suffix}"
  vpc_id      = aws_vpc.main.id # Resource attribute reference

  # HTTP access
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS access
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH access (if needed)
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr] # Only from within VPC
  }

  # All outbound traffic
  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_prefix}-web-sg-${var.random_suffix}"
    Type = "Security Group"
  })

  lifecycle {
    create_before_destroy = true
  }
} 
