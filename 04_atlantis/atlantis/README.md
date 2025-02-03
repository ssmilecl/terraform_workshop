# Setting Up Atlantis

This guide will help you set up Atlantis for automated Terraform plan and apply through pull requests.

## Prerequisites

1. Fork the Workshop Repository
   ```bash
   # Visit https://github.com/[original-repo]
   # Click "Fork" button
   # Clone your forked repository
   git clone https://github.com/[your-username]/terraform_workshop.git
   ```

2. Create GitHub Personal Access Token
   - Go to GitHub Settings → Developer settings → Personal access tokens
   - Click "Generate new token"
   - Select scopes:
     - repo (all)
     - admin:repo_hook
   - Copy and save the token

3. AWS Requirements
   - VPC with public subnets
   - Route53 hosted zone
   - ACM certificate for your Atlantis domain

## Installation Steps

1. Configure Variables
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

2. Deploy Atlantis
   ```bash
   terraform init
   terraform apply
   ```

3. Configure GitHub Repository
   - Go to your forked repo settings
   - Click "Webhooks"
   - Add webhook:
     - Payload URL: https://[your-atlantis-domain]/events
     - Content type: application/json
     - Secret: [your-webhook-secret]
     - Events: Pull request, Push

4. Test the Setup
   ```bash
   # Create a new branch
   git checkout -b test-atlantis

   # Make a change to any .tf file
   
   # Commit and push
   git add .
   git commit -m "test: atlantis setup"
   git push origin test-atlantis

   # Create a pull request on GitHub
   ```

## Using Atlantis

1. Creating Pull Requests
   - Atlantis automatically runs `terraform plan`
   - Results posted as PR comments

2. Common Commands
   - `atlantis plan` - Run plan manually
   - `atlantis apply` - Apply changes
   - `atlantis help` - Show all commands

3. Best Practices
   - Always review plans before applying
   - Use branch protection rules
   - Require PR reviews

## Security Considerations

1. Access Control
   - Use GitHub organization restrictions
   - Implement branch protection
   - Control who can run apply

2. Secrets Management
   - Use AWS Secrets Manager
   - Rotate GitHub tokens regularly
   - Protect webhook secrets

## Troubleshooting

1. Common Issues
   - Webhook failures
   - Plan/Apply errors
   - Permission issues

2. Logs
   - Check ECS task logs
   - Monitor ALB access logs
   - Review GitHub webhook delivery logs

## Cleanup

To destroy the Atlantis infrastructure:

## Module Features

This implementation uses the official `terraform-aws-modules/atlantis/aws` module which provides:

1. **Fargate Deployment**
   - Serverless container deployment
   - Auto-scaling capabilities
   - No EC2 instance management

2. **Persistent Storage**
   - EFS integration for state persistence
   - Survives container restarts
   - Shared storage across tasks

3. **Security**
   - Secrets management with AWS Secrets Manager
   - Private subnets for ECS tasks
   - ALB with HTTPS only

4. **High Availability**
   - Multi-AZ deployment
   - Load balanced
   - Auto-recovery

## Architecture

The module creates:
- Application Load Balancer (ALB)
- ECS Fargate Service
- EFS File System
- Security Groups
- IAM Roles
- Secrets Manager Secrets
- Route53 Records