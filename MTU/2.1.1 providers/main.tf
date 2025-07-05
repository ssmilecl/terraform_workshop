# Terraform Provider Configuration
# This block specifies which provider(s) Terraform should use
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Provider Block
# This configures the AWS provider with the region
provider "aws" {
  region = var.aws_region

  # Optional: Add default tags that will be applied to all resources
  default_tags {
    tags = {
      Environment = var.environment
      Project     = "simple-vpc-example"
      ManagedBy   = "terraform"
    }
  }
}

# VPC Resource
# This is the main resource that creates a Virtual Private Cloud
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.environment}-vpc"
  }
}

# Internet Gateway (optional - shows resource dependency)
# Allows communication between VPC and the internet
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.environment}-igw"
  }
}


