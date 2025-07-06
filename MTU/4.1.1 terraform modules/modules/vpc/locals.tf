# VPC Module Local Values
# Locals are computed values that can be used throughout the module

locals {
  # Computed naming patterns
  vpc_name = "${var.project_prefix}-vpc-${var.random_suffix}"

  # Computed CIDR information
  vpc_cidr_parts = split("/", var.vpc_cidr)
  vpc_network    = local.vpc_cidr_parts[0]
  vpc_prefix     = local.vpc_cidr_parts[1]

  # Subnet configuration
  subnet_count = length(var.public_subnets)

  # Module-specific tags
  module_tags = {
    Module      = "vpc"
    ModuleType  = "networking"
    SubnetCount = local.subnet_count
    VPCPrefix   = local.vpc_prefix
  }

  # Combined tags (merge common tags with module-specific tags)
  all_tags = merge(var.common_tags, local.module_tags)

  # Availability zone mapping
  az_subnet_map = {
    for idx, subnet in var.public_subnets :
    var.availability_zones[idx] => subnet
  }

  # Security group rules as objects for better organization
  web_ingress_rules = [
    {
      description = "HTTP"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "HTTPS"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "SSH from VPC"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [var.vpc_cidr]
    }
  ]
} 
