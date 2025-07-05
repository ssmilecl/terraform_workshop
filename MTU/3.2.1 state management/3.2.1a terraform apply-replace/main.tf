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

# Example: Terraform Taint
# This EC2 instance will be used to demonstrate taint functionality
# Taint forces a resource to be destroyed and recreated on next apply
resource "aws_instance" "demo_server" {
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = {
    Name        = "${var.environment}-taint-server"
    Type        = "taint_demo"
    Environment = var.environment
  }

  user_data = <<-EOF
              #!/bin/bash
              echo "Instance created at: $(date)" > /tmp/creation_time.txt
              echo "Instance ID: $(curl -s http://169.254.169.254/latest/meta-data/instance-id)" >> /tmp/creation_time.txt
              EOF
}
