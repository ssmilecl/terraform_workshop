# AWS Managed Service for Prometheus

This module creates an AWS Managed Service for Prometheus instance using Terraform.

## Features

- Creates and configures an AWS Managed Service for Prometheus workspace
- Configures alerting rules and recording rules
- Sets up appropriate IAM permissions

## Usage

```bash
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

## Requirements

- AWS CLI configured with appropriate permissions
- Terraform >= 1.0.0
- Backend S3 bucket configured for state storage