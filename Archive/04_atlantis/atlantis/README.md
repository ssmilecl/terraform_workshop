# Setting Up Atlantis for Terraform Workshop

This guide helps you set up Atlantis - a tool that automates Terraform workflows through GitHub pull requests. In this workshop, we'll deploy Atlantis in AWS ECS Fargate with persistent storage.

## What is Atlantis?
Atlantis automates your Terraform workflow by:
- Running `terraform plan` on pull requests
- Allowing `terraform apply` through PR comments
- Showing plan output directly in GitHub
- Locking workspaces to prevent concurrent modifications

## Architecture Overview

### Infrastructure Components
1. **ECS Fargate**
   - Serverless container platform
   - No EC2 instances to manage
   - Auto-scaling based on demand
   - Runs Atlantis container

2. **Networking (VPC Module Required)**
   - Uses VPC from `terraform_workshop/04_atlantis/vpc` module
   - Public subnets for ALB
   - Private subnets for Fargate tasks
   - NAT Gateway for outbound traffic
   - Security groups for access control

3. **Storage and State**
   - EFS (Elastic File System) for persistent storage
   - Mounted to Fargate tasks
   - Stores Terraform plans and repo clones
   - Survives container restarts

4. **Load Balancer**
   - Application Load Balancer (ALB)
   - HTTPS termination
   - Routes traffic to Fargate tasks
   - Health checks and auto-scaling

### How Atlantis Works
```
GitHub PR → Webhook → ALB → Atlantis Container
                             ↓
                      1. Clones Repo
                      2. Runs terraform plan
                      3. Posts results to PR
                      4. Waits for apply command
```

## Prerequisites

1. **VPC Setup Required**
   - Deploy the VPC module first: `terraform_workshop/04_atlantis/vpc`
   - Note the VPC ID and subnet IDs
   - VPC must have:
     - Public and private subnets
     - NAT Gateway
     - Correct subnet tagging (*public*, *private*)

2. **GitHub Setup**
   - Fork the workshop repository: `github.com/kewei5zhang/terraform_workshop`
   - You'll need admin access to your forked repository

3. **GitHub Personal Access Token**
   - Go to GitHub Settings → Developer settings → Personal access tokens
   - Click "Generate new token"
   - Select scopes:
     - repo (terraform_workshop)
     - Webhooks: readonly
     - Pull requests: read/write
   - Copy and save the token

4. **Store Required Secrets**
   Run these commands to store secrets in AWS Parameter Store:
   ```bash
   # Generate webhook secret
   WEBHOOK_SECRET=$(openssl rand -base64 24 | tr -dc 'a-zA-Z0-9' | head -c 20)
   echo "Generated webhook secret: $WEBHOOK_SECRET"

   # Store GitHub token
   aws ssm put-parameter \
     --name "/atlantis/github/token" \
     --value "your-github-token" \
     --type "SecureString"

   # Store webhook secret
   aws ssm put-parameter \
     --name "/atlantis/github/webhook-secret" \
     --value "$WEBHOOK_SECRET" \
     --type "SecureString"
   ```

5. **Update terraform.tfvars**
   ```hcl
   region              = "us-east-1"
   vpc_id              = "your-vpc-id"              # From VPC module
   certificate_arn     = "your-certificate-arn"
   github_user         = "your-github-username"
   github_organization = "github.com/your-username"
   route53_record_name = "atlantis"
   route53_zone_id     = "your-zone-id"
   ```

## Deployment Steps

1. **Initialize and Apply**
   ```bash
   terraform init
   terraform plan   # Review the changes
   terraform apply
   ```

2. **Configure GitHub Webhook**
   After successful deployment, you'll see these outputs:
   - `atlantis_url`: Your Atlantis server URL
   - `webhook_url`: URL for GitHub webhook

   Go to your forked repository:
   - Settings → Webhooks → Add webhook
   - Payload URL: Use the `webhook_url` output
   - Content type: `application/json`
   - Secret: Use the webhook secret from Parameter Store
   - Events: Select 'Pull request' and 'Push'

## Testing Your Setup

1. **Create a Test PR**
   ```bash
   git checkout -b test-atlantis
   # Make a small change to any .tf file
   git commit -am "test: atlantis setup"
   git push origin test-atlantis
   # Create PR on GitHub
   ```

2. **Watch Atlantis in Action**
   - Atlantis will automatically run `plan`
   - Review the plan in PR comments
   - Comment `atlantis apply` to apply changes

## Common Commands in PRs
- `atlantis plan` - Run/re-run plan
- `atlantis apply` - Apply the plan
- `atlantis help` - Show all commands

## Troubleshooting

1. **VPC Issues**
   - Verify VPC module is deployed
   - Check subnet tags for *public* and *private*
   - Ensure NAT Gateway is working

2. **Webhook Issues**
   - Verify webhook secret matches Parameter Store
   - Check webhook delivery logs in GitHub
   - Ensure Atlantis URL is accessible

3. **Plan/Apply Failures**
   - Check ECS task logs
   - Verify GitHub token permissions
   - Check Parameter Store access

## Cleanup
```bash
terraform destroy
```
Note: This will remove Atlantis and associated resources. Your GitHub fork and webhook will remain.

## Security Notes
- Atlantis has full AWS access - use in development only
- Rotate GitHub tokens regularly
- Use branch protection in production
- Monitor Atlantis access logs