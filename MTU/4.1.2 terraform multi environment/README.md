# Terraform Multi-Environment Strategy: Folder-Based vs Workspaces

## Overview

This example demonstrates a **folder-based multi-environment approach** for Terraform deployments, showcasing how it overcomes the key limitations of terraform workspaces:

1. **Shared codebase limitations** - limits the ability to make progressive or incremental code changes
2. **Shared state limitations** - each environment may require different security profiles, making it necessary to store state files separately  
3. **Shared providers and modules limitations** - restricts the ability to upgrade versions progressively across environments

## Architecture: Why Folders Beat Workspaces

### The Problem with Terraform Workspaces

```
❌ WORKSPACE APPROACH LIMITATIONS:
├── main.tf (shared code)
├── variables.tf (shared variables)  
├── terraform.tfvars (shared config)
└── terraform.tfstate.d/
    ├── dev/
    ├── staging/
    └── prod/
    
Issues:
- Same module versions across ALL environments
- Complex conditional logic for environment differences  
- Shared provider constraints
- Difficult progressive rollouts
- Risk of accidental cross-environment changes
```

### The Solution: Independent Environment Folders

```
✅ FOLDER-BASED APPROACH BENEFITS:
environments/
├── dev/
│   ├── main.tf (latest module versions)
│   ├── variables.tf (dev-specific vars)
│   ├── terraform.tfvars (permissive settings)
│   └── terraform.tfstate (isolated state)
├── staging/
│   ├── main.tf (stable tested versions)
│   ├── variables.tf (production-like vars)
│   ├── terraform.tfvars (restrictive settings)
│   └── terraform.tfstate (isolated state)
└── prod/
    ├── main.tf (proven stable versions)
    ├── variables.tf (enterprise vars)
    ├── terraform.tfvars (maximum security)
    └── terraform.tfstate (isolated state)

Benefits:
✅ Different module versions per environment
✅ Environment-specific configurations
✅ Independent state files
✅ Progressive version rollouts
✅ No shared configuration conflicts
```

## Demonstrating the Three Key Benefits

### 1. Overcoming Shared Codebase Limitations

**Different Module Versions Across Environments:**

```hcl
# Development (environments/dev/main.tf)
module "main_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 4.0"  # ← Latest version for testing new features
  
  # Permissive dev settings
  versioning = { enabled = false }
  server_side_encryption_configuration = {}
  block_public_acls = false
}

# Staging (environments/staging/main.tf)  
module "main_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.15.0"  # ← Stable version tested in dev
  
  # Production-like settings
  versioning = { enabled = true }
  server_side_encryption_configuration = { /* AES256 */ }
  block_public_acls = true
}

# Production (environments/prod/main.tf)
module "main_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws" 
  version = "3.14.1"  # ← Well-proven stable version
  
  # Enterprise-grade settings
  versioning = { enabled = true }
  server_side_encryption_configuration = { /* AES256 + bucket_key */ }
  block_public_acls = true
  lifecycle_rule = [{ /* 365 day retention + multi-tier storage */ }]
}
```

### 2. Overcoming Shared State Limitations

**Independent State Files with Different Security Profiles:**

```bash
# Each environment has its own state file
environments/dev/terraform.tfstate      # Dev team access
environments/staging/terraform.tfstate  # QA team access  
environments/prod/terraform.tfstate     # Ops team access

# Different backend configurations possible
# Dev: Local state or simple S3
# Staging: S3 with versioning
# Prod: S3 + DynamoDB locking + encryption
```

**Environment-Specific Security Settings:**

```hcl
# Development - Permissive for testing
allow_public_access = true   # OK for dev testing
enable_logging = false       # Reduce costs
backup_retention_days = 7    # Short retention

# Production - Maximum security
allow_public_access = false  # Never in production
enable_logging = true        # Always audit
backup_retention_days = 365  # Compliance retention
```

### 3. Overcoming Shared Providers and Modules Limitations

**Progressive Version Rollouts:**

```
Version Progression Strategy:
Dev Environment    → Tests v4.11.0 (latest)
    ↓ (validation)
Staging Environment → Adopts v3.15.0 (stable) 
    ↓ (validation)
Prod Environment   → Adopts v3.14.1 (proven)

This enables:
✅ Testing new versions safely in dev
✅ Validating stability in staging  
✅ Conservative rollout to production
✅ Quick rollback if issues found
❌ Cannot do this with workspaces!
```

## Hands-On Experimental Steps

### Step 1: Verify All Environments Work

```bash
# Test Development Environment
cd environments/dev
terraform init && terraform validate && terraform plan 
# ✅ Should show: S3 module ~> 4.0, public access allowed, no encryption

# Test Staging Environment  
cd ../staging
terraform init && terraform validate && terraform plan 
# ✅ Should show: S3 module 3.15.0, encryption enabled, public access blocked

# Test Production Environment
cd ../prod
terraform init && terraform validate && terraform plan
# ✅ Should show: S3 module 3.14.1, maximum security, 365-day retention
```

### Step 2: Experiment with Progressive Version Changes

**Scenario: Testing a New Module Version**

```bash
# 1. Update dev to test newest version
cd environments/dev
# Edit main.tf: Change version = "~> 4.0" to version = "~> 4.1"
terraform init
terraform plan
# ✅ Shows only dev is affected, staging/prod unchanged

# 2. After validation, promote to staging
cd ../staging  
# Edit main.tf: Change version = "3.15.0" to version = "4.0.0"
terraform init
terraform plan
# ✅ Shows only staging is affected, dev/prod unchanged

# 3. Finally, promote to production (conservative approach)
cd ../prod
# Edit main.tf: Change version = "3.14.1" to version = "3.15.0"
terraform init  
terraform plan
# ✅ Shows only production is affected
```

### Step 3: Experiment with Configuration Changes

**Scenario: Adding New Security Features**

```bash
# 1. Test new security feature in dev first
cd environments/dev
# Add to main.tf:
#   lifecycle_rule = [{
#     id = "test_cleanup"
#     status = "Enabled"
#     expiration = { days = 1 }  # Very short for testing
#   }]

terraform plan
# ✅ Shows new lifecycle rule only in dev

# 2. If successful, add production-appropriate settings to staging
cd ../staging
# Add to main.tf:
#   lifecycle_rule = [{
#     id = "staging_cleanup" 
#     status = "Enabled"
#     expiration = { days = 60 }  # Medium retention
#   }]

terraform plan
# ✅ Shows different lifecycle rule in staging

# 3. Finally add to production with enterprise settings
cd ../prod
# Production already has comprehensive lifecycle rules
terraform plan
# ✅ Production unaffected by dev/staging changes
```

### Step 4: Experiment with Provider Constraints

**Scenario: Testing New Provider Features**

```bash
# 1. Update dev to use latest provider
cd environments/dev
# Edit main.tf terraform block:
# Change: version = "~> 5.0" to version = "~> 5.1"
terraform init
# ✅ Downloads new provider version only for dev

# 2. Staging can stay on stable version
cd ../staging
terraform init
# ✅ Still uses ~> 5.0 provider version

# 3. Production uses conservative version
cd ../prod  
terraform init
# ✅ Still uses ~> 5.0 provider version
```

### Step 5: Demonstrate State Isolation

**Scenario: Independent Environment Changes**

```bash
# 1. Deploy only development
cd environments/dev
terraform apply -auto-approve
# ✅ Creates dev bucket with permissive settings

# 2. Check other environments are unaffected
cd ../staging && terraform plan
# ✅ Shows no existing infrastructure, clean plan

cd ../prod && terraform plan  
# ✅ Shows no existing infrastructure, clean plan

# 3. Deploy staging with different settings
cd ../staging
terraform apply -auto-approve
# ✅ Creates staging bucket with production-like security

# 4. Verify dev is still running independently
cd ../dev && terraform show
# ✅ Shows dev bucket still exists with dev settings
```

## Real-World Usage Scenarios

### Scenario 1: Emergency Security Patch
```
1. Security vulnerability found in S3 module v4.0
2. Immediately patch production: v3.14.1 → v3.14.2 
3. Dev can continue testing v4.1 features
4. Staging validates v3.15.1 for next prod release
5. No shared configuration conflicts
```

### Scenario 2: Feature Development Workflow
```
1. Dev tests new lifecycle policies with latest module
2. After validation, staging adopts stable version + new policies
3. Production gets well-tested version after staging validation
4. Each environment progresses independently
```

### Scenario 3: Rollback Scenario
```
1. Issue found in staging after module upgrade
2. Rollback staging: v4.0.0 → v3.15.0
3. Dev continues testing fix with v4.0.1
4. Production unaffected by staging issues
5. Independent state management enables safe rollbacks
```

## Key Advantages Demonstrated

### ✅ No Shared Codebase Issues
- **Independent Evolution**: Each environment can adopt changes at its own pace
- **No Conditional Logic**: Clean, environment-specific configurations
- **Safe Experimentation**: Dev changes don't risk staging/prod

### ✅ No Shared State Issues  
- **Complete Isolation**: Each environment has its own state file
- **Independent Deployments**: Deploy/destroy environments independently
- **No Cross-Environment Pollution**: Changes isolated to specific environments

### ✅ No Shared Provider/Module Issues
- **Progressive Adoption**: Test latest versions in dev, promote gradually
- **Version Safety**: Production uses proven versions while dev experiments
- **Flexible Constraints**: Each environment can have different provider versions

## Testing Your Understanding

Try these exercises to validate your understanding:

1. **Version Progression**: Update dev to module v4.2, verify staging/prod unaffected
2. **Security Testing**: Add public access policy to dev, confirm staging/prod remain secure  
3. **Independent Deployment**: Deploy only staging, verify dev/prod are independent
4. **Configuration Drift**: Modify retention policies across environments, observe differences
5. **Provider Testing**: Update dev to latest AWS provider, keep staging/prod on stable versions

## Comparison Matrix

| Feature | Terraform Workspaces | Folder-Based Approach |
|---------|---------------------|----------------------|
| **Module Versions** | ❌ Same across all environments | ✅ Different per environment |
| **State Isolation** | ⚠️ Same backend, different files | ✅ Completely independent |
| **Configuration Flexibility** | ❌ Shared vars + conditionals | ✅ Environment-specific configs |
| **Progressive Rollouts** | ❌ Difficult/impossible | ✅ Natural progression |
| **Risk of Cross-Environment Changes** | ⚠️ High (shared code) | ✅ Low (isolated folders) |
| **Experimentation Safety** | ❌ Changes affect all environments | ✅ Isolated experimentation |
| **Emergency Patching** | ❌ Complex conditional logic | ✅ Direct environment updates |

## Conclusion

The folder-based approach **completely eliminates** the three core limitations of terraform workspaces and enables **true multi-environment management** with:

1. ✅ **Progressive version adoption** without shared codebase constraints
2. ✅ **Independent state management** with complete environment isolation  
3. ✅ **Flexible provider/module evolution** across environments

This approach provides the foundation for enterprise-grade infrastructure management with the safety, flexibility, and operational practices required for real-world deployments. 