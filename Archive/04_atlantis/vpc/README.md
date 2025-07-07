# VPC Setup for Atlantis

This module creates the VPC infrastructure required for running Atlantis.

## Features

1. **Network Layout**
   - Multi-AZ VPC
   - Public and private subnets
   - NAT Gateway for private subnet internet access
   - VPC Endpoints for AWS services

2. **VPC Endpoints**
   - S3 (Gateway endpoint)
   - ECR API and Docker
   - ECS and ECS Telemetry
   - CloudWatch Logs

3. **Security**
   - Private subnets for Atlantis containers
   - Public subnets for ALB only
   - Controlled internet access via NAT

## Usage

1. Initialize the VPC module:
   ```bash
    terraform init 
    ```

2. Review the configuration:
   ```bash
    terraform plan 
    ```

3. Apply the configuration:
   ```bash
    terraform apply 
    ```

4. Note the outputs for use in Atlantis setup:
   - vpc_id
   - private_subnet_ids
   - public_subnet_ids

## Important Notes

1. **Subnet Layout**
   - Public subnets: ALB placement
   - Private subnets: Atlantis containers
   - NAT Gateway: Single NAT to reduce costs

2. **VPC Endpoints**
   - Reduces data transfer costs
   - Improves security
   - Required for private subnet operation

3. **Costs**
   - NAT Gateway has hourly costs
   - VPC Endpoints have hourly costs
   - Consider for production vs development

This VPC setup provides:
1. All necessary networking for Atlantis
2. Security best practices
3. Cost-effective NAT configuration
4. Required VPC endpoints
5. All outputs needed by the Atlantis module

The VPC needs to be created first, then its outputs can be used in the Atlantis configuration. Would you like me to explain any specific part in more detail?
