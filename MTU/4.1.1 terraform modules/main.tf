# Root Module - Terraform Modules Demo
# This root module orchestrates child modules to create a complete web application infrastructure

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Random suffix for unique resource naming
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# Local values computed at root level
locals {
  project_prefix = "${var.environment}-${var.project_name}"
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform-modules"
    Suffix      = random_string.suffix.result
    Owner       = var.owner
  }
}

# VPC Module - Creates networking foundation
module "vpc" {
  source = "./modules/vpc"

  # Pass variables from root to child module
  environment    = var.environment
  project_name   = var.project_name
  vpc_cidr       = var.vpc_cidr
  public_subnets = var.public_subnets

  # Pass computed values
  project_prefix = local.project_prefix
  random_suffix  = random_string.suffix.result
  common_tags    = local.common_tags

  # Pass availability zones
  availability_zones = var.availability_zones
}

# EC2 Module - Creates compute resources
module "ec2" {
  source = "./modules/ec2"

  # Pass variables from root to child module
  environment   = var.environment
  project_name  = var.project_name
  instance_type = var.instance_type
  key_pair_name = var.key_pair_name

  # Pass computed values
  project_prefix = local.project_prefix
  random_suffix  = random_string.suffix.result
  common_tags    = local.common_tags

  # Pass outputs from VPC module to EC2 module (module communication)
  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  web_security_group_id = module.vpc.web_security_group_id

  # Dependencies - ensure VPC is created before EC2
  depends_on = [module.vpc]
}
