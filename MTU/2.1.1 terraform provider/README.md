# Simple VPC Terraform Example

This example demonstrates Terraform **providers** and **resources** by creating a basic VPC with an Internet Gateway.

## What Gets Created

- ✅ **VPC** (Virtual Private Cloud) - 10.0.0.0/16
- ✅ **Internet Gateway** - Attached to the VPC

## Prerequisites

1. **AWS Account** with appropriate permissions
2. **Terraform** installed (>= 1.0)
3. **AWS CLI** configured with credentials:
   ```bash
   aws configure
   ```

## Step-by-Step Guide

### 1. Initialize Terraform
```bash
terraform init
```

**Expected Output:**
```
Initializing the backend...
Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 5.0"...
- Installing hashicorp/aws v5.x.x...
- Installed hashicorp/aws v5.x.x

Terraform has been successfully initialized!
```

### 2. Plan the Infrastructure
```bash
terraform plan
```

**Expected Output:**
```
Terraform will perform the following actions:

  # aws_internet_gateway.main will be created
  + resource "aws_internet_gateway" "main" {
      + arn      = (known after apply)
      + id       = (known after apply)
      + owner_id = (known after apply)
      + tags     = {
          + "Environment" = "dev"
          + "ManagedBy"   = "terraform"
          + "Name"        = "dev-igw"
          + "Project"     = "simple-vpc-example"
        }
      + vpc_id   = (known after apply)
    }

  # aws_vpc.main will be created
  + resource "aws_vpc" "main" {
      + arn                = (known after apply)
      + cidr_block         = "10.0.0.0/16"
      + enable_dns_hostnames = true
      + enable_dns_support   = true
      + id                 = (known after apply)
      + tags               = {
          + "Environment" = "dev"
          + "ManagedBy"   = "terraform"
          + "Name"        = "dev-vpc"
          + "Project"     = "simple-vpc-example"
        }
    }

Plan: 2 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + internet_gateway_id = (known after apply)
  + vpc_cidr_block      = "10.0.0.0/16"
  + vpc_id              = (known after apply)
```

### 3. Apply the Configuration
```bash
terraform apply
```

Type `yes` when prompted.

**Expected Output:**
```
aws_vpc.main: Creating...
aws_vpc.main: Creation complete after 2s [id=vpc-xxxxxxxxx]
aws_internet_gateway.main: Creating...
aws_internet_gateway.main: Creation complete after 1s [id=igw-xxxxxxxxx]

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

Outputs:
internet_gateway_id = "igw-xxxxxxxxx"
vpc_cidr_block = "10.0.0.0/16"
vpc_id = "vpc-xxxxxxxxx"
```

### 4. Verify No Changes Needed
```bash
terraform plan
```

**Expected Output (Verification):**
```
aws_internet_gateway.main: Refreshing state... [id=igw-xxxxxxxxx]
aws_vpc.main: Refreshing state... [id=vpc-xxxxxxxxx]

No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and found no differences, so no changes are needed.
```
**✅ Key Verification:** `Plan: 0 to add, 0 to change, 0 to destroy.`

### 5. View Current State
```bash
terraform show
```

### 6. View Outputs
```bash
terraform output
```

**Expected Output:**
```
internet_gateway_id = "igw-xxxxxxxxx"
vpc_cidr_block = "10.0.0.0/16"
vpc_id = "vpc-xxxxxxxxx"
```

### 7. Destroy the Infrastructure
```bash
terraform destroy
```

Type `yes` when prompted.

**Expected Output (Verification):**
```
aws_internet_gateway.main: Destroying... [id=igw-xxxxxxxxx]
aws_internet_gateway.main: Destruction complete after 1s
aws_vpc.main: Destroying... [id=vpc-xxxxxxxxx]
aws_vpc.main: Destruction complete after 1s

Destroy complete! Resources: 2 destroyed.
```
**✅ Key Verification:** `Destroy complete! Resources: 2 destroyed.`

## File Structure

```
.
├── main.tf            # Provider configuration and resources
├── variables.tf       # Variable declarations
├── outputs.tf         # Output declarations
├── terraform.tfvars   # Variable values
└── README.md          # This guide
```

## Key Learning Points

### **Provider vs Resource**
- **Provider** (`provider "aws"`): Plugin that communicates with AWS API
- **Resource** (`resource "aws_vpc"`): Actual infrastructure component

### **Resource Dependencies**
- Internet Gateway automatically depends on VPC (`vpc_id = aws_vpc.main.id`)
- Terraform creates VPC first, then Internet Gateway

### **Variables and Outputs**
- **Variables**: Parameterize configurations (`var.vpc_cidr`)
- **Outputs**: Export values for use elsewhere

## Troubleshooting

### Common Issues:
1. **AWS credentials not configured**: Run `aws configure`
2. **Region mismatch**: Check your AWS CLI region vs `terraform.tfvars`
3. **Insufficient permissions**: Ensure your AWS user has VPC creation permissions

### Useful Commands:
```bash
terraform fmt       # Format code
terraform validate  # Validate configuration
terraform state list  # List resources in state
```
