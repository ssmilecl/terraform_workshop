# Terraform State Management & Locking Demo

## Overview

This simple demo shows the difference between **local state** and **remote state** using just a single S3 bucket resource. The focus is on understanding state management and collaboration concepts.

**🎯 Key Feature**: Automatic bucket naming with random suffix prevents conflicts when multiple students use the same code!

**🔗 Integration**: The backend created here is also used by experiment **5.2 terraform cicd** - complete this experiment first!

## What You'll Learn

1. **Local State**: State stored locally with local-only locking
2. **Remote State**: State stored in S3 with distributed locking via DynamoDB
3. **Why Remote State**: Enables team collaboration and prevents conflicts
4. **Shared Backend**: How multiple Terraform projects can share the same remote backend

## Demo Setup

```
terraform-state-demo/
├── backend-setup/          # Creates S3 bucket & DynamoDB table
│   ├── main.tf
│   ├── variables.tf
│   ├── terraform.tfvars
│   └── outputs.tf
├── main.tf                 # Simple S3 bucket resource
├── backend.tf              # Remote state configuration
├── variables.tf
├── terraform.tfvars
└── outputs.tf
```

## Part 1: Local State

### Step 1: Test Local State
```bash
# Navigate to the demo directory
cd "MTU/5.1 terraform remote state"

# Disable remote state by renaming backend.tf
mv backend.tf backend.tf.disabled

# Initialize with local state
terraform init
```

**Result**: You'll see `terraform.tfstate` file created locally.

### Step 2: Apply Configuration
```bash
terraform apply -auto-approve
```

**Result**: 
- S3 bucket created
- State stored in local `terraform.tfstate` file
- Local lock file `.terraform.tfstate.lock.info` created during operations

### Step 3: Test Local Locking (Same Machine)
```bash
# Terminal 1: Start a long-running apply
terraform apply -auto-approve &

# Terminal 2: Try to run plan immediately (same machine)
terraform plan
```

**Result**: Terminal 2 will show lock error - local locking works on same machine!

### Step 4: View Local State
```bash
# Check local state file
cat terraform.tfstate | jq '.resources[0].instances[0].attributes.bucket'

# List files - you'll see terraform.tfstate
ls -la terraform.tfstate*
```

## Part 2: Remote State

### Step 5: Create Backend Infrastructure
```bash
# Navigate to backend setup
cd backend-setup

# Create S3 bucket and DynamoDB table for remote state
terraform init
terraform apply -auto-approve

# 🔑 IMPORTANT: Note the bucket name with random suffix for later use
terraform output state_bucket_name
# Example output: terraform-state-demo-bucket-a1b2c3d4

# Save this bucket name - you'll need it for 5.2 experiment too!
export STATE_BUCKET_NAME=$(terraform output -raw state_bucket_name)
echo "Backend bucket created: $STATE_BUCKET_NAME"
```

**Result**: 
- S3 bucket: `terraform-state-demo-bucket-<random>` (unique suffix prevents conflicts)
- DynamoDB table: `terraform-state-demo-locks`
- **This backend will be shared with experiment 5.2!**

### Step 6: Enable Remote State
```bash
# Go back to main directory
cd ../

# Re-enable remote state
mv backend.tf.disabled backend.tf

# 🔑 IMPORTANT: Update backend.tf with the actual bucket name
# Get the bucket name from backend-setup
cd backend-setup
BUCKET_NAME=$(terraform output -raw state_bucket_name)
cd ../

# Update backend.tf with the actual bucket name
# Replace "terraform-state-demo-bucket-<random>" with the actual bucket name
sed -i "s/terraform-state-demo-bucket-<random>/$BUCKET_NAME/g" backend.tf

# OR manually edit backend.tf and replace the bucket name

# Initialize with remote state
terraform init
```

**Result**: Terraform will ask to migrate state from local to remote.

### Step 7: Test Remote State
```bash
# Run terraform plan
terraform plan
```

**Result**: Terraform now uses S3 for state storage and DynamoDB for locking.

### Step 8: Verify Remote State
```bash
# Check S3 bucket for state file (use your actual bucket name)
aws s3 ls s3://$STATE_BUCKET_NAME/

# Check DynamoDB for lock table
aws dynamodb describe-table --table-name terraform-state-demo-locks --query 'Table.TableStatus'

# No local state file anymore
ls -la terraform.tfstate*
```

## Setting Up Shared Backend for Experiment 5.2

Once you've completed the remote state setup above, you can use the same backend for experiment **5.2 terraform cicd**:

### Step 9: Configure 5.2 Backend
```bash
# Get the backend bucket name
cd backend-setup
BUCKET_NAME=$(terraform output -raw state_bucket_name)
cd ../

# Navigate to 5.2 experiment
cd "../5.2 terraform cicd"

# Update both dev and prod environments with the same bucket
sed -i "s/terraform-state-demo-bucket-<random>/$BUCKET_NAME/g" environments/dev/main.tf
sed -i "s/terraform-state-demo-bucket-<random>/$BUCKET_NAME/g" environments/prod/main.tf

# OR manually edit:
# - environments/dev/main.tf
# - environments/prod/main.tf
# Replace "terraform-state-demo-bucket-<random>" with your actual bucket name

echo "✅ Backend configured for both experiments!"
echo "🔗 Now you can run experiment 5.2 with shared remote state"
```

### Benefits of Shared Backend

| Feature | Separate Backends | Shared Backend |
|---------|-------------------|----------------|
| **Resource Efficiency** | Multiple S3 buckets | Single S3 bucket |
| **State Organization** | Scattered state files | Centralized state storage |
| **Cost** | Higher (multiple buckets) | Lower (single bucket) |
| **Management** | Complex (multiple configs) | Simple (one config) |
| **Learning** | ❌ Confusing | ✅ Real-world pattern |

**Real-world Use Case**: In production, teams typically use one shared state backend for all their Terraform projects, with different state keys for different environments/projects.

## Key Differences

| Feature | Local State | Remote State |
|---------|-------------|--------------|
| **Storage** | Local file | S3 bucket |
| **Locking Scope** | ❌ Same machine only | ✅ Across all users/machines |
| **Collaboration** | ❌ Can't share state | ✅ Shared state |
| **Backup** | ❌ Manual | ✅ Automatic versioning |
| **Encryption** | ❌ Plain text | ✅ Encrypted |
| **Locking Mechanism** | Local `.lock.info` file | DynamoDB distributed lock |

## The Real Problem with Local State

### **Single User Scenario** (Local state works fine)
```bash
# On your machine - works perfectly
terraform apply  # ✅ Creates local lock, applies changes
terraform plan   # ✅ Works fine
```

### **Multi-User Scenario** (Local state fails)
```bash
# User A's machine
terraform apply  # ✅ Creates infrastructure

# User B's machine (different local state)
terraform apply  # ❌ Creates conflicting infrastructure!
                 # No awareness of User A's changes
```

### **Remote State Solution**
```bash
# User A's machine
terraform apply  # ✅ Creates DynamoDB lock, applies changes

# User B's machine (same remote state)
terraform apply  # ⏳ Waits for User A's lock to release
                 # ✅ Sees User A's changes, applies correctly
```

## Practical Test Commands

### Test State Storage:
```bash
# Local state - check file
cat terraform.tfstate | head -10

# Remote state - check S3 (use your actual bucket name)
aws s3 ls s3://$STATE_BUCKET_NAME/terraform-state-demo/
```

### Test Locking:
```bash
# Local locking (same machine only)
terraform apply -auto-approve &
terraform plan  # Will show lock error

# Remote locking (across machines)
# User A: terraform apply
# User B: terraform plan  # Will wait for User A
```

### View Lock Status:
```bash
# Check DynamoDB for active locks
aws dynamodb scan --table-name terraform-state-demo-locks
```

## Common Issues & Solutions

### 1. Lock Stuck
```bash
# If lock gets stuck, force unlock
terraform force-unlock <LOCK_ID>
```

### 2. State Not Found
```bash
# If state file is missing
terraform import aws_s3_bucket.demo_bucket <bucket-name>
```

### 3. Permission Denied
```bash
# Check AWS credentials
aws sts get-caller-identity
```

## Cleanup

### Step 1: Destroy Resources
```bash
# In main directory
terraform destroy -auto-approve
```

### Step 2: Destroy Backend
```bash
# In backend-setup directory
cd backend-setup
terraform destroy -auto-approve
```

### Step 3: Clean Local Files
```bash
# Remove local state files
rm -f terraform.tfstate*
rm -rf .terraform/
```

## Key Takeaways

1. **Both local and remote state have locking** - the difference is scope
2. **Local locking**: Only prevents conflicts on the same machine
3. **Remote locking**: Prevents conflicts across all team members and machines
4. **Remote state enables collaboration**: Multiple users can work safely together
5. **Remote state provides additional benefits**: Backup, encryption, audit trail

## Real-World Usage

```hcl
# Production backend configuration
terraform {
  backend "s3" {
    bucket         = "company-terraform-state"
    key            = "production/infrastructure.tfstate"
    region         = "us-east-1"
    dynamodb_table = "company-terraform-locks"
    encrypt        = true
  }
}
```

The main benefit of remote state is **enabling safe team collaboration** - not just locking! 