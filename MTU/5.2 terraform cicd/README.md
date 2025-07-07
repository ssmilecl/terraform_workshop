# Terraform CI/CD Multi-Environment Pipeline

## Overview

This example demonstrates a **production-ready Terraform CI/CD pipeline** with multi-environment deployment using **folder-based environment separation**. The pipeline automatically deploys to development, runs automated tests with **Terratest**, and promotes to production only after **manual approval**.

## Pipeline Architecture

### Environment Flow
```
┌─────────────────────────────────────────────────────────────┐
│              CI/CD Pipeline with Approval                  │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. Code Push   →   2. Deploy Dev   →   3. Run Tests        │
│      (main)           (automatic)        (Terratest)        │
│                         ⬇                   ⬇             │
│                         ✅                   ✅             │
│                                                             │
│  6. Complete    ←   5. Deploy Prod   ←   4. 🛑 APPROVAL      │
│                       (automatic)         (manual)          │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Folder Structure

```
MTU/5.2 terraform cicd/
├── environments/
│   ├── dev/                    # Development environment
│   │   ├── main.tf            # Infrastructure resources
│   │   ├── variables.tf       # Environment variables
│   │   ├── outputs.tf         # Infrastructure outputs
│   │   └── terraform.tfvars   # Dev configuration
│   └── prod/                   # Production environment
│       ├── main.tf            # Infrastructure resources (prod features)
│       ├── variables.tf       # Environment variables
│       ├── outputs.tf         # Infrastructure outputs
│       └── terraform.tfvars   # Prod configuration
├── tests/                      # Automated testing
│   ├── terraform_test.go      # Infrastructure tests
│   └── go.mod                 # Go dependencies
├── .github/workflows/          # CI/CD pipeline
│   └── terraform-cicd.yml     # GitHub Actions workflow
└── README.md
```

## Key Features

### 🎯 **Generic Infrastructure Pipeline**

This pipeline works with **any Terraform infrastructure**, not just specific resources:

- **Flexible Resource Support**: S3 buckets, EC2 instances, VPCs, databases, etc.
- **Generic Output Handling**: Automatically captures all Terraform outputs
- **Universal Testing**: Terratest validates any infrastructure type
- **Environment Agnostic**: Works with any environment configuration

### 🛡️ **Production Approval Workflow**

- **Development**: Deploys automatically on push to main
- **Testing**: Runs automatically after dev deployment
- **Production**: **Requires manual approval** before deployment

### 📊 **Comprehensive Monitoring**

- **Real-time Summaries**: Infrastructure outputs displayed in GitHub
- **Test Results**: Terratest results with detailed feedback
- **Deployment Status**: Clear success/failure reporting
- **Cleanup on Failure**: Automatic resource cleanup

## Pipeline Components

### 1. **Development Deployment**
- **Trigger**: Push to main branch
- **Environment**: `development` (GitHub environment)
- **Resources**: Any infrastructure defined in `environments/dev/`
- **State**: `dev/terraform.tfstate` (remote S3 backend)

### 2. **Infrastructure Testing**
- **Framework**: Terratest with Go
- **Validation**: Resource existence, configuration, outputs
- **Timeout**: 15 minutes with proper error handling
- **Requirement**: Dev deployment must succeed

### 3. **Production Deployment**
- **Trigger**: Tests pass + **manual approval**
- **Environment**: `production` (GitHub environment with approval)
- **Resources**: Any infrastructure defined in `environments/prod/`
- **State**: `prod/terraform.tfstate` (remote S3 backend)

### 4. **Cleanup & Monitoring**
- **Failure Cleanup**: Automatic destruction of failed resources
- **Deployment Summaries**: JSON outputs displayed in GitHub UI
- **Status Tracking**: Real-time pipeline status updates

## Environment Examples

The current setup uses S3 buckets as examples, but the pipeline supports any infrastructure:

### Development Environment
```hcl
# Example: Simple S3 bucket
resource "aws_s3_bucket" "dev_bucket" {
  bucket = "${var.project_name}-${var.environment}-bucket"
  
  tags = {
    Environment = "dev"
    Purpose     = "Development"
  }
}
```

### Production Environment
```hcl
# Example: S3 bucket with production features
resource "aws_s3_bucket" "prod_bucket" {
  bucket = "${var.project_name}-${var.environment}-bucket"
  
  tags = {
    Environment = "prod"
    Purpose     = "Production"
    Criticality = "High"
  }
}

# Production-specific features
resource "aws_s3_bucket_versioning" "prod_bucket" {
  bucket = aws_s3_bucket.prod_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}
```

## Infrastructure Testing

### Generic Test Structure
```go
func TestTerraformCICDDev(t *testing.T) {
    // 1. Deploy any infrastructure
    terraform.InitAndApply(t, terraformOptions)
    
    // 2. Validate outputs exist
    outputs := terraform.OutputAll(t, terraformOptions)
    assert.NotEmpty(t, outputs)
    
    // 3. Test specific resources (customize per infrastructure)
    // Example for S3:
    bucketName := outputs["bucket_info"].(map[string]interface{})["bucket_name"].(string)
    aws.AssertS3BucketExists(t, "us-east-1", bucketName)
    
    // Example for EC2:
    // instanceId := outputs["instance_info"].(map[string]interface{})["instance_id"].(string)
    // aws.AssertEc2InstanceExists(t, "us-east-1", instanceId)
}
```

## Setup Instructions

### Prerequisites

1. **AWS Account** with appropriate permissions
2. **GitHub Repository** with Actions enabled
3. **Terraform** >= 1.6.0
4. **Go** >= 1.19 (for running tests locally)

### GitHub Environment Setup

#### Step 1: Create GitHub Environments

**📋 Detailed Steps to Create GitHub Environments:**

1. **Navigate to Your Repository**
   - Go to your GitHub repository
   - Click on the **Settings** tab (top navigation bar)

2. **Access Environments Section**
   - In the left sidebar, scroll down to **Code and automation**
   - Click on **Environments**

3. **Create Development Environment**
   - Click **New environment** button
   - Enter environment name: `development`
   - Click **Configure environment**
   - **Deployment protection rules**: Leave unchecked (automatic deployment)
   - **Environment secrets**: We'll add these next
   - Click **Save protection rules**

4. **Create Production Environment**
   - Click **New environment** button
   - Enter environment name: `production`
   - Click **Configure environment**
   
   **Configure Production Protection Rules:**
   - ✅ Check **Required reviewers**
   - Click **Add reviewers** and select:
     - Your GitHub username
     - Or a team (e.g., `@your-org/devops-team`)
   - Set **Prevent self-review** (recommended)
   - ✅ Check **Deployment branches and tags**
   - Select **Protected branches only** 
   - Click **Save protection rules**

5. **Verify Environment Creation**
   - You should now see both environments listed:
     - `development` (No protection rules)
     - `production` (Protection rules: Required reviewers)

#### Step 2: Configure Branch Protection (Required for Production)

**📋 Set Up Branch Protection Rules:**

1. **Navigate to Branches**
   - In your repository, go to **Settings** → **Branches**

2. **Add Branch Protection Rule**
   - Click **Add rule**
   - Branch name pattern: `main`
   - ✅ Check **Require a pull request before merging**
   - ✅ Check **Require status checks to pass before merging**
   - ✅ Check **Require branches to be up to date before merging**
   - Click **Create** or **Save changes**

#### Step 3: Configure Environment Secrets

**📋 Add AWS Credentials to Each Environment:**

1. **For Development Environment:**
   - Go to **Settings** → **Environments** → `development`
   - Scroll to **Environment secrets** section
   - Click **Add secret**
   - Name: `AWS_ACCESS_KEY_ID`
   - Value: Your AWS Access Key for development
   - Click **Add secret**
   - Repeat for `AWS_SECRET_ACCESS_KEY`

2. **For Production Environment:**
   - Go to **Settings** → **Environments** → `production`
   - Scroll to **Environment secrets** section
   - Click **Add secret**
   - Name: `AWS_ACCESS_KEY_ID`
   - Value: Your AWS Access Key for production
   - Click **Add secret**
   - Repeat for `AWS_SECRET_ACCESS_KEY`

**🔐 Security Best Practice:**
| Secret Name | Development Value | Production Value |
|-------------|------------------|------------------|
| `AWS_ACCESS_KEY_ID` | Your dev AWS Access Key | Your prod AWS Access Key |
| `AWS_SECRET_ACCESS_KEY` | Your dev AWS Secret Key | Your prod AWS Secret Key |

**💡 Tip:** Use different AWS accounts/keys for dev vs prod environments for better security.

#### Step 4: Test Environment Setup

**📋 Verify Your Environment Configuration:**

1. **Check Environment Status**
   - Go to **Settings** → **Environments**
   - Verify both environments are listed:
     ```
     ✅ development (No protection rules)
     ✅ production (Protection rules: Required reviewers)
     ```

2. **Test Environment Secrets**
   - Go to each environment
   - Click on the environment name
   - Verify secrets are listed (values hidden for security):
     ```
     🔐 AWS_ACCESS_KEY_ID
     🔐 AWS_SECRET_ACCESS_KEY
     ```

3. **Test Branch Protection**
   - Go to **Settings** → **Branches**
   - Verify `main` branch has protection rules:
     ```
     ✅ main (Protected branch)
     ```

#### Step 5: Troubleshooting Common Issues

**🔧 Common Setup Problems and Solutions:**

| Problem | Solution |
|---------|----------|
| **"Environment not found" error** | 1. Check environment name spelling (case-sensitive)<br>2. Ensure environment is created in correct repository<br>3. Verify workflow file references correct environment names |
| **"Environment protection rules failed"** | 1. Ensure branch protection is enabled for `main`<br>2. Check that reviewer has repository permissions<br>3. Verify reviewer is not the same as the person triggering deployment |
| **"Secrets not found" error** | 1. Check secret names match exactly (case-sensitive)<br>2. Ensure secrets are added to environment, not repository<br>3. Verify AWS credentials are valid and not expired |
| **"Permission denied" during deployment** | 1. Check AWS IAM permissions for the credentials<br>2. Verify credentials work with `aws sts get-caller-identity`<br>3. Ensure AWS region matches your configuration |
| **"Approval required but no reviewers"** | 1. Add reviewers to production environment<br>2. Ensure reviewers have repository access<br>3. Check that branch protection allows the workflow |

**🔍 Quick Environment Test:**

To test if your environments are working, create a simple test workflow:

```yaml
name: Test Environments
on:
  workflow_dispatch:

jobs:
  test-dev:
    runs-on: ubuntu-latest
    environment: development
    steps:
      - name: Test Development Environment
        run: echo "✅ Development environment works!"

  test-prod:
    runs-on: ubuntu-latest
    environment: production
    steps:
      - name: Test Production Environment
        run: echo "✅ Production environment works!"
```

**Expected Results:**
- Development job runs immediately
- Production job waits for manual approval
- Both jobs complete successfully after approval

### AWS IAM Permissions

Create an IAM user with permissions for your infrastructure:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:*",
        "ec2:*",
        "iam:*",
        "rds:*"
      ],
      "Resource": "*"
    }
  ]
}
```

### Backend Setup

Create the S3 bucket for remote state:

```bash
# Create state bucket
aws s3 mb s3://terraform-cicd-demo-state-bucket --region us-east-1
```

## Pipeline Workflow

### Step 1: Code Push
```bash
git add .
git commit -m "feat: update infrastructure"
git push origin main
```

### Step 2: Automatic Development Deployment
```
🏗️ Development Environment
✅ Terraform Format: PASSED
✅ Terraform Init: SUCCESS
✅ Terraform Validate: SUCCESS
✅ Terraform Plan: SUCCESS
✅ Terraform Apply: SUCCESS
📊 Outputs: Available in GitHub Summary
```

### Step 3: Automatic Testing
```
🧪 Infrastructure Tests
✅ Development Infrastructure: VALIDATED
✅ Terratest: PASSED
📋 All tests completed successfully
```

### Step 4: Production Approval
```
🛑 Production Deployment Approval Required
👤 Waiting for manual approval from: @reviewer
📋 Review terraform plan before approving
⏳ Deployment will proceed after approval
```

### Step 5: Production Deployment (After Approval)
```
🚀 Production Environment
✅ Manual Approval: RECEIVED
✅ Terraform Format: PASSED
✅ Terraform Init: SUCCESS
✅ Terraform Validate: SUCCESS
✅ Terraform Plan: SUCCESS
✅ Terraform Apply: SUCCESS
📊 Outputs: Available in GitHub Summary
```

## Customizing for Your Infrastructure

### 1. **Replace Example Resources**

Update `environments/dev/main.tf` and `environments/prod/main.tf`:

```hcl
# Instead of S3 buckets, use your infrastructure:
resource "aws_instance" "web_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-web"
    Environment = var.environment
  }
}

resource "aws_db_instance" "database" {
  engine      = "mysql"
  engine_version = "8.0"
  instance_class = var.db_instance_class
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-db"
    Environment = var.environment
  }
}
```

### 2. **Update Variables**

Modify `variables.tf` files:

```hcl
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"  # dev
  # default   = "t3.medium" # prod
}

variable "db_instance_class" {
  description = "Database instance class"
  type        = string
  default     = "db.t3.micro"  # dev
  # default   = "db.t3.small"  # prod
}
```

### 3. **Customize Tests**

Update `tests/terraform_test.go`:

```go
func TestTerraformCICDDev(t *testing.T) {
    // Deploy infrastructure
    terraform.InitAndApply(t, terraformOptions)
    
    // Test EC2 instance
    instanceId := terraform.Output(t, terraformOptions, "instance_id")
    aws.AssertEc2InstanceExists(t, "us-east-1", instanceId)
    
    // Test database
    dbEndpoint := terraform.Output(t, terraformOptions, "db_endpoint")
    assert.NotEmpty(t, dbEndpoint)
    
    // Custom health checks
    testApplicationHealth(t, instanceId)
}
```

### 4. **Update Outputs**

Modify `outputs.tf` files:

```hcl
output "instance_info" {
  description = "EC2 instance information"
  value = {
    instance_id = aws_instance.web_server.id
    public_ip   = aws_instance.web_server.public_ip
    dns_name    = aws_instance.web_server.public_dns
  }
}

output "database_info" {
  description = "Database connection information"
  value = {
    endpoint = aws_db_instance.database.endpoint
    port     = aws_db_instance.database.port
  }
  sensitive = true
}
```

## Approval Workflow

### How Production Approval Works

1. **Automatic Trigger**: When tests pass, production job starts
2. **Approval Pause**: GitHub pauses and sends notification to reviewers
3. **Manual Review**: Reviewers can see terraform plan in GitHub UI
4. **Approval Decision**: Approve or reject the deployment
5. **Automatic Deployment**: If approved, terraform apply runs

### Approval Notifications

Reviewers receive notifications via:
- 📧 **Email**: GitHub sends approval request email
- 🔔 **GitHub UI**: Notification appears in GitHub interface
- 📱 **Mobile**: GitHub mobile app notifications (if configured)

### Approval Interface

In GitHub Actions:
```
🛑 Review pending
Environment: production
Reviewer: @your-username

[ Review deployment ]  [ View details ]

Terraform Plan:
+ aws_s3_bucket.prod_bucket
+ aws_s3_bucket_versioning.prod_bucket
+ aws_s3_bucket_server_side_encryption_configuration.prod_bucket

Plan: 3 to add, 0 to change, 0 to destroy.

[ ✅ Approve and deploy ]  [ ❌ Reject ]
```

## Monitoring and Troubleshooting

### Pipeline Status Indicators

```
✅ Development: SUCCESS
✅ Tests: PASSED  
🛑 Production: WAITING_FOR_APPROVAL
```

```
✅ Development: SUCCESS
✅ Tests: PASSED
✅ Production: SUCCESS (Approved by @reviewer)
```

### Common Approval Scenarios

#### Scenario 1: Standard Approval
```
🛑 Production deployment requires approval
👤 Waiting for: @team-lead
⏳ Auto-timeout: 30 days
```

#### Scenario 2: Rejected Deployment
```
❌ Production deployment rejected
👤 Rejected by: @team-lead
💬 Reason: "Please update security group rules"
```

#### Scenario 3: Auto-timeout
```
⏰ Production deployment timed out
📅 Waited: 30 days without approval
🔄 Re-run pipeline to try again
```

## Security Best Practices

### 1. **Environment Isolation**
- Separate AWS accounts for dev/prod (recommended)
- Different IAM roles with least privilege
- Separate state backends

### 2. **Approval Controls**
- Require multiple approvers for production
- Use teams instead of individual reviewers
- Set approval timeouts

### 3. **Secret Management**
- Use GitHub environment secrets
- Rotate AWS keys regularly
- Consider AWS OIDC instead of static keys

## Local Testing Guide

### Prerequisites for Local Testing

1. **Install Go** (>= 1.22)
   ```bash
   # macOS
   brew install go
   
   # Verify installation
   go version
   ```

2. **Configure AWS Credentials**
   ```bash
   # Option 1: AWS SSO
   aws sso login
   
   # Option 2: AWS Configure
   aws configure
   
   # Verify credentials
   aws sts get-caller-identity
   ```

### Running Tests Locally

#### **Step 1: Navigate to Tests Directory**
```bash
cd "MTU/5.2 terraform cicd/tests"
```

#### **Step 2: Install Dependencies**
```bash
# Download dependencies (uses go.mod/go.sum)
go mod download

# Verify dependencies
go list -m all
```

#### **Step 3: Deploy Infrastructure First**
```bash
# Deploy development environment
cd ../environments/dev
terraform init
terraform apply -auto-approve

# Note the bucket name: terraform-cicd-demo-dev-bucket
```

#### **Step 4: Run Terratest**
```bash
# Go back to tests directory
cd ../../tests

# Run development environment tests
go test -v -timeout 15m -run TestTerraformCICDDev

# Run specific test
go test -v -run TestTerraformCICDDev/DevBucketExists

# Run all tests (if you have both dev and prod deployed)
go test -v -timeout 15m ./...
```

#### **Step 5: Clean Up**
```bash
# Destroy development infrastructure
cd ../environments/dev
terraform destroy -auto-approve
```

### **Expected Test Output**

✅ **Successful Run:**
```
=== RUN   TestTerraformCICDDev
=== RUN   TestTerraformCICDDev/DevBucketExists
=== RUN   TestTerraformCICDDev/DevBucketTags
=== RUN   TestTerraformCICDDev/DevBucketNaming
--- PASS: TestTerraformCICDDev (2.34s)
    --- PASS: TestTerraformCICDDev/DevBucketExists (1.12s)
    --- PASS: TestTerraformCICDDev/DevBucketTags (0.89s)
    --- PASS: TestTerraformCICDDev/DevBucketNaming (0.01s)
PASS
```

❌ **Failed Run (if infrastructure not deployed):**
```
=== RUN   TestTerraformCICDDev/DevBucketExists
    Error: NotFound: Not Found
    status code: 404
--- FAIL: TestTerraformCICDDev/DevBucketExists
```

### **Local Testing Tips**

💡 **Best Practices:**
- Always deploy infrastructure before running tests
- Use unique bucket names to avoid conflicts
- Clean up resources after testing
- Test against development environment only

🔧 **Troubleshooting:**
```bash
# Check AWS credentials
aws sts get-caller-identity

# Check Go installation
go version

# Check if bucket exists
aws s3 ls | grep terraform-cicd-demo

# Force clean Go module cache
go clean -modcache
```

### **Local vs CI/CD Testing**

| Aspect | Local Testing | CI/CD Testing |
|--------|---------------|---------------|
| **Purpose** | Development & debugging | Quality gate |
| **Infrastructure** | You deploy manually | Pipeline deploys automatically |
| **Scope** | Single environment | Full dev → prod flow |
| **Cleanup** | Manual cleanup required | Automatic in pipeline |

## Success Metrics

### Performance Targets
- **Development Deployment**: < 5 minutes
- **Test Execution**: < 15 minutes  
- **Production Deployment**: < 5 minutes (after approval)
- **Approval Response Time**: < 4 hours (business hours)

### Quality Metrics
- **Test Coverage**: 100% of critical resources
- **Deployment Success Rate**: > 95%
- **Approval Rejection Rate**: < 10%
- **Pipeline Reliability**: > 99%

## Advanced Configuration

### Multiple Approval Strategies

#### Strategy 1: Team-Based Approval
```yaml
environment: 
  name: production
  required-reviewers: 
    - devops-team
    - security-team
  minimum-reviewers: 2
```

#### Strategy 2: Branch-Based Deployment
```yaml
environment:
  name: production
  deployment-branch-policy:
    protected-branches: true
    custom-branch-policies: false
```

#### Strategy 3: Time-Based Windows
```yaml
environment:
  name: production
  wait-timer: 5  # Wait 5 minutes before allowing approval
  deployment-timeout: 1440  # 24 hours to approve
```

## Troubleshooting Guide

### Issue 1: Approval Not Working
```
Error: Environment 'production' not found
```
**Solution**: Create production environment in GitHub Settings → Environments

### Issue 2: Tests Failing
```
Error: Terratest timeout after 15 minutes
```
**Solution**: Increase timeout in workflow or optimize infrastructure deployment

### Issue 3: State Lock Issues
```
Error: state lock not released
```
**Solution**: Use terraform force-unlock or check S3 backend configuration

## Conclusion

This pipeline provides enterprise-grade Terraform automation with:

✅ **Generic Infrastructure Support**: Works with any Terraform resources
✅ **Production Approval Workflow**: Manual approval required for production
✅ **Comprehensive Testing**: Automated validation with Terratest
✅ **Environment Isolation**: Separate dev/prod configurations and state
✅ **Failure Recovery**: Automatic cleanup and detailed error reporting
✅ **Scalable Architecture**: Easy to extend for additional environments

The approval workflow ensures production deployments are reviewed and authorized, making it suitable for enterprise environments where change control is critical. 