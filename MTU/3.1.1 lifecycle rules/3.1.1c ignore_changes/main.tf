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

# Example: ignore_changes
# This EC2 instance will ignore changes to specific attributes
# Useful when external systems modify resource attributes
resource "aws_instance" "app_server" {
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = {
    Name = "${var.environment}-app-server"
    Type = "ignore_changes_example"
    # These tags might be modified by external systems
    LastModified = "2024-01-01"
    AutoScaling  = "enabled"
    Environment  = var.environment
  }

  # Lifecycle rule: ignore_changes
  # Ignore changes to specific attributes
  lifecycle {
    ignore_changes = [
      tags["LastModified"],
      tags["AutoScaling"],
      # You can also ignore all tags: tags
    ]
  }
}

# For comparison: EC2 instance without ignore_changes
resource "aws_instance" "normal_server" {
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = {
    Name         = "${var.environment}-normal-server"
    Type         = "normal_example"
    LastModified = "2024-01-01"
    AutoScaling  = "enabled"
    Environment  = var.environment
  }

  # No lifecycle rule - all changes will be detected
} 
