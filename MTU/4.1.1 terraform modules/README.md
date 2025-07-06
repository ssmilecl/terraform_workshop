# Terraform Modules Functionality and Practice

## Overview

This example demonstrates the core concepts and best practices of Terraform modules, including:

- **Root Module vs Child Module** definitions and relationships
- **Module references in State files**
- **Input parameter definitions in child modules**
- **Using Variables, Data Sources, and Locals**
- **Resource attribute references between modules**
- **Output passing between modules**

## Architecture Description

```
Root Module (orchestrator)
├── VPC Module (child module)
│   ├── VPC
│   ├── Internet Gateway
│   ├── Public Subnets (2 subnets)
│   ├── Route Table & Associations
│   └── Security Group
└── EC2 Module (child module)
    ├── Launch Template
    ├── EC2 Instances (2 instances)
    ├── Application Load Balancer
    ├── Target Group
    └── Target Group Attachments
```

## Module Structure

### Root Module
- **Definition**: Contains the main configuration files where `terraform` commands are executed
- **Responsibilities**: Orchestrates and calls child modules, defines global variables and outputs
- **Files**: `main.tf`, `variables.tf`, `outputs.tf`, `terraform.tfvars`

### Child Modules
- **VPC Module**: Responsible for networking infrastructure
- **EC2 Module**: Responsible for compute resources and load balancing

## Key Concept Demonstrations

### 1. Module Invocation and Variable Passing

```hcl
# Root Module calling child module
module "vpc" {
  source = "./modules/vpc"
  
  # Variable passing
  environment        = var.environment
  project_name       = var.project_name
  vpc_cidr           = var.vpc_cidr
  public_subnets     = var.public_subnets
  availability_zones = var.availability_zones
  
  # Computed values
  project_prefix     = local.project_prefix
  random_suffix      = random_string.suffix.result
  common_tags        = local.common_tags
}
```

### 2. Resource Attribute References Between Modules

```hcl
# EC2 Module using VPC Module outputs
module "ec2" {
  source = "./modules/ec2"
  
  # Variables from root
  environment   = var.environment
  project_name  = var.project_name
  instance_type = var.instance_type
  key_pair_name = var.key_pair_name
  
  # Computed values
  project_prefix = local.project_prefix
  random_suffix  = random_string.suffix.result
  common_tags    = local.common_tags
  
  # Inter-module attribute references (VPC → EC2)
  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  web_security_group_id = module.vpc.web_security_group_id
  
  depends_on = [module.vpc]
}
```

### 3. Data Sources Usage

```hcl
# Dynamically fetch AMI information
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}
```

### 4. Locals Usage

```hcl
# Computed values and random suffix
locals {
  project_prefix = "${var.project_name}-${var.environment}"
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    Owner       = "terraform-workshop"
    ManagedBy   = "terraform-modules"
  }
}
```

### 5. Module Output Passing

```hcl
# Child module output
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

# Root module outputs
output "vpc_info" {
  description = "VPC information"
  value = {
    vpc_id      = module.vpc.vpc_id
    vpc_cidr    = module.vpc.vpc_cidr
    public_subnet_ids = module.vpc.public_subnet_ids
  }
}

output "web_application_url" {
  description = "Web application URL"
  value       = "http://${module.ec2.load_balancer_dns}"
}
```

## Practical Steps

### Step 1: Initialize Terraform
```bash
cd "MTU/4.1.1 terraform modules"
terraform init
```

**Expected Output**:
```
Initializing modules...
- vpc in modules/vpc
- ec2 in modules/ec2

Initializing the backend...
Initializing provider plugins...
- Reusing previous version of hashicorp/aws from the dependency lock file
- Reusing previous version of hashicorp/random from the dependency lock file

Terraform has been successfully initialized!
```

### Step 2: View Execution Plan
```bash
terraform plan
```

**Expected Output Summary**:
```
Plan: 15 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + ec2_info = {
      + instance_ids = (known after apply)
      + instance_public_ips = (known after apply)
      + load_balancer_dns = (known after apply)
    }
  + vpc_info = {
      + vpc_id = (known after apply)
      + vpc_cidr = (known after apply)
      + public_subnet_ids = (known after apply)
    }
  + web_application_url = (known after apply)
```

### Step 3: Apply Configuration
```bash
terraform apply -auto-approve
```

**Expected Output Summary**:
```
Apply complete! Resources: 15 added, 0 changed, 0 destroyed.

Outputs:
ec2_info = {
  "instance_ids" = [
    "i-079189727b1d682e4",
    "i-0c1b827e0a5351e7a",
  ]
  "instance_public_ips" = [
    "54.80.58.54",
    "44.220.168.75",
  ]
  "load_balancer_dns" = "demo-webapp-jpa9va-web-alb-269451601.us-east-1.elb.amazonaws.com"
}
vpc_info = {
  "vpc_id" = "vpc-0c9bf7104315cfa84"
  "vpc_cidr" = "10.0.0.0/16"
  "public_subnet_ids" = [
    "subnet-0b676fd1d881216fc",
    "subnet-0af1e0f0cda8dc263",
  ]
}
web_application_url = "http://demo-webapp-jpa9va-web-alb-269451601.us-east-1.elb.amazonaws.com"
```

### Step 4: Verify Module References in State

```bash
# View module structure in state
terraform state list
```

**Expected Output**:
```
random_string.suffix
module.ec2.data.aws_ami.amazon_linux
module.ec2.data.aws_availability_zones.available
module.ec2.data.aws_caller_identity.current
module.ec2.data.aws_region.current
module.ec2.aws_instance.web[0]
module.ec2.aws_instance.web[1]
module.ec2.aws_launch_template.web
module.ec2.aws_lb.web
module.ec2.aws_lb_listener.web
module.ec2.aws_lb_target_group.web
module.ec2.aws_lb_target_group_attachment.web[0]
module.ec2.aws_lb_target_group_attachment.web[1]
module.vpc.data.aws_availability_zones.available
module.vpc.aws_internet_gateway.main
module.vpc.aws_route_table.public
module.vpc.aws_route_table_association.public[0]
module.vpc.aws_route_table_association.public[1]
module.vpc.aws_security_group.web
module.vpc.aws_subnet.public[0]
module.vpc.aws_subnet.public[1]
module.vpc.aws_vpc.main
```

### Step 5: View Specific Module State

```bash
# View VPC module state
terraform state show module.vpc.aws_vpc.main

# View EC2 module state
terraform state show module.ec2.aws_instance.web[0]
```

### Step 6: Test Application Access

```bash
# Test web application
curl http://demo-webapp-jpa9va-web-alb-269451601.us-east-1.elb.amazonaws.com/

# Get load balancer DNS name
terraform output web_application_url
```

**Expected Response**:
```html
<h1>Hello from Terraform!</h1><p>Status: HEALTHY</p>
```

### Step 7: View Module Communication Flow

```bash
# View how modules communicate
terraform output module_communication_example
```

**Expected Output**:
```
{
  "step_1" = "Root module generates random suffix: jpa9va"
  "step_2" = "Root passes variables to VPC module"
  "step_3" = "VPC module creates networking: vpc-0c9bf7104315cfa84"
  "step_4" = "VPC outputs flow to EC2 module inputs"
  "step_5" = "EC2 module creates instances in VPC subnets"
  "step_6" = "EC2 outputs flow back to root: demo-webapp-jpa9va-web-alb-269451601.us-east-1.elb.amazonaws.com"
}
```

## Module Best Practices

### 1. Module Design Principles
- **Single Responsibility**: Each module focuses on one specific functionality
- **High Cohesion, Low Coupling**: Modules are internally cohesive with minimal inter-module dependencies
- **Reusability**: Support different environments through variables and outputs

### 2. Variable Design
```hcl
# Required variables
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "The vpc_cidr must be a valid CIDR block."
  }
}

# Optional variables
variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}
```

### 3. Output Design
```hcl
# Provide necessary resource references
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

# Provide computed values
output "load_balancer_dns" {
  description = "DNS name of the load balancer"
  value       = aws_lb.web.dns_name
}
```

### 4. Module Version Management
```hcl
# Using Git tags for version control
module "vpc" {
  source = "git::https://github.com/company/terraform-modules.git//vpc?ref=v1.0.0"
  
  # Configuration parameters
}

# Using Terraform Registry
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"
  
  # Configuration parameters
}
```

## Advanced Concepts

### 1. Module Composition Pattern
```hcl
# Application layer module calling infrastructure modules
module "app_infrastructure" {
  source = "./modules/app-infrastructure"
  
  # Network module
  vpc_module = module.vpc
  
  # Security module
  security_module = module.security
  
  # Application configuration
  application_config = var.application_config
}
```

### 2. Conditional Resource Creation
```hcl
# Create resources based on conditions
resource "aws_instance" "web" {
  count = var.create_instances ? var.instance_count : 0
  
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  
  tags = local.common_tags
}
```

### 3. Dynamic Block Usage
```hcl
# Dynamically create security group rules
resource "aws_security_group" "web" {
  name_prefix = "${var.project_name}-web-"
  vpc_id      = var.vpc_id
  
  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
}
```

### Instance Replacement

If you need to update user data or instance configuration:

```bash
# Force replacement of specific instances
terraform apply -replace="module.ec2.aws_instance.web[0]" -replace="module.ec2.aws_instance.web[1]"
```

## Resource Cleanup

```bash
# Destroy all resources
terraform destroy -auto-approve
```

**Expected Output**:
```
Destroy complete! Resources: 15 destroyed.
```

## Summary

This example comprehensively demonstrates the core concepts of Terraform modules:

1. **Module Architecture**: Root Module orchestrates Child Modules
2. **State Management**: Modules are referenced in State with `module.<name>` prefix
3. **Variable Passing**: Configuration passed through module parameters
4. **Resource References**: Use `module.<name>.<output>` to reference other module outputs
5. **Data Sources**: Dynamically fetch AWS resource information
6. **Local Values**: Compute and combine configuration values
7. **Module Outputs**: Expose necessary resource information for other modules

Through modular design, we achieve code reusability, maintainability, and scalability, which are the core advantages of Terraform infrastructure as code.

### Key Learnings

- **Simplified is Better**: Simple user data scripts are more reliable than complex ones
- **Health Checks**: Load balancer health checks verify application availability
- **Module Communication**: Inter-module references enable loose coupling
- **State Management**: Terraform state tracks module relationships automatically
- **Output Organization**: Well-structured outputs improve module usability 