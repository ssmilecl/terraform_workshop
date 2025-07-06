# Root Module Outputs - Terraform Modules Demo
# These outputs expose important information from child modules

# Random suffix generated at root level
output "random_suffix" {
  description = "Random suffix used for unique resource naming"
  value       = random_string.suffix.result
}

# VPC Module Outputs - passed through from child module
output "vpc_info" {
  description = "VPC information from the VPC module"
  value = {
    vpc_id                = module.vpc.vpc_id
    vpc_cidr              = module.vpc.vpc_cidr
    public_subnet_ids     = module.vpc.public_subnet_ids
    web_security_group_id = module.vpc.web_security_group_id
    internet_gateway_id   = module.vpc.internet_gateway_id
  }
}

# EC2 Module Outputs - passed through from child module
output "ec2_info" {
  description = "EC2 instance information from the EC2 module"
  value = {
    instance_ids          = module.ec2.instance_ids
    instance_public_ips   = module.ec2.instance_public_ips
    load_balancer_dns     = module.ec2.load_balancer_dns
    load_balancer_zone_id = module.ec2.load_balancer_zone_id
  }
}

# Combined outputs for easy access
output "web_application_url" {
  description = "URL to access the web application"
  value       = "http://${module.ec2.load_balancer_dns}"
}

output "ssh_connection_commands" {
  description = "SSH commands to connect to instances (if key pair is provided)"
  value = var.key_pair_name != "" ? [
    for ip in module.ec2.instance_public_ips :
    "ssh -i ~/.ssh/${var.key_pair_name}.pem ec2-user@${ip}"
  ] : ["No key pair provided - SSH not available"]
}

# Module communication demonstration
output "module_communication_example" {
  description = "Example of how data flows between modules"
  value = {
    step_1 = "Root module generates random suffix: ${random_string.suffix.result}"
    step_2 = "Root passes variables to VPC module"
    step_3 = "VPC module creates networking: ${module.vpc.vpc_id}"
    step_4 = "VPC outputs flow to EC2 module inputs"
    step_5 = "EC2 module creates instances in VPC subnets"
    step_6 = "EC2 outputs flow back to root: ${module.ec2.load_balancer_dns}"
  }
}

# Resource count summary
output "resource_summary" {
  description = "Summary of resources created by each module"
  value = {
    vpc_module_creates = [
      "1 VPC (${module.vpc.vpc_id})",
      "2 Public Subnets",
      "1 Internet Gateway",
      "1 Route Table",
      "1 Security Group"
    ]
    ec2_module_creates = [
      "2 EC2 Instances",
      "1 Application Load Balancer",
      "1 Target Group",
      "1 Launch Template"
    ]
    total_resources = "~8 AWS resources across 2 modules"
  }
} 
