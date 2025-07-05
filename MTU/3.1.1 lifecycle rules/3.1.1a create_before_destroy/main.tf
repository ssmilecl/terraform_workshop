# Terraform Provider Configuration
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Example: create_before_destroy
# This security group will be recreated before the old one is destroyed
# Useful for resources that cannot have downtime
resource "aws_security_group" "web" {
  name_prefix = "${var.environment}-web-sg"
  description = "Security group for web servers"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-web-sg"
    Type = "create_before_destroy_example"
  }

  # Lifecycle rule: create_before_destroy
  # When this resource needs to be replaced, create the new one first
  lifecycle {
    create_before_destroy = true
  }
}

# Dependent resource to show the benefit of create_before_destroy
# This EC2 instance depends on the security group
resource "aws_instance" "web_server" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.web.id]

  tags = {
    Name = "${var.environment}-web-server"
    Type = "dependent_resource"
  }
}
