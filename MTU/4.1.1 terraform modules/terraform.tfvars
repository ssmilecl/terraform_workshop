# Terraform Variables for Modules Demo
# Customize these values for your environment

# Basic Configuration
environment  = "demo"
project_name = "webapp"
owner        = "terraform-workshop"
aws_region   = "us-east-1"

# Networking Configuration
vpc_cidr           = "10.0.0.0/16"
public_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]
availability_zones = ["us-east-1a", "us-east-1b"]

# Compute Configuration
instance_type = "t3.micro"
key_pair_name = "" # Leave empty if you don't have a key pair

# Note: If you have an AWS key pair, you can specify it like:
# key_pair_name = "my-key-pair" 
