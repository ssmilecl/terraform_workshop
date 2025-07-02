# Simple VPC terraform.tfvars file
# This file contains example values for the variables defined in main.tf

aws_region  = "us-west-2"
environment = "dev"
vpc_cidr    = "10.0.0.0/16"

# You can also try these alternative configurations:
# 
# For production:
# aws_region = "us-east-1"
# environment = "prod"
# vpc_cidr = "10.1.0.0/16"
#
# For staging:
# aws_region = "us-west-1"
# environment = "staging"
# vpc_cidr = "10.2.0.0/16" 
