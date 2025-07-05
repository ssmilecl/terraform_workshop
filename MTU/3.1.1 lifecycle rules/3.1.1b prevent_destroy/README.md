# Terraform Lifecycle: `prevent_destroy` Demo

This example demonstrates the **`prevent_destroy`** lifecycle rule, which prevents critical resources from being accidentally destroyed by `terraform destroy`.

## What Gets Created

- ✅ **Critical S3 Bucket** - Protected by `prevent_destroy`
- ✅ **S3 Bucket Versioning** - Also protected by `prevent_destroy`
- ✅ **Regular S3 Bucket** - Can be destroyed normally (for comparison)

## How `prevent_destroy` Works

This lifecycle rule acts as a safety net:
- ✅ **Prevents accidental destruction** of critical resources
- ✅ **Fails terraform destroy** if it would destroy protected resources
- ✅ **Forces intentional action** to remove protection before destroying

## Prerequisites

1. **AWS Account** with S3 permissions
2. **Terraform** installed (>= 1.0)
3. **AWS CLI** configured: `aws configure`
4. **Unique bucket suffix** - Change `bucket_suffix` in `terraform.tfvars`

## Demo Steps

### 1. Initial Setup
```bash
terraform init
terraform plan
terraform apply
```

**Expected:** 3 resources created (2 S3 buckets, 1 versioning configuration)

### 2. Try to Destroy the Critical Bucket
```bash
terraform destroy -target=aws_s3_bucket.critical_data
```

**Expected Output:**
```
Error: Instance cannot be destroyed

  on main.tf line 18, in resource "aws_s3_bucket" "critical_data":
  18: resource "aws_s3_bucket" "critical_data" {

Resource aws_s3_bucket.critical_data has lifecycle.prevent_destroy set, but
the plan calls for this resource to be destroyed.
```

**Key Point:** ✅ **Terraform refuses to destroy** the critical bucket

### 3. Try to Destroy the Regular Bucket (for comparison)
```bash
terraform destroy -target=aws_s3_bucket.regular_data
```

**Expected Output:**
```
aws_s3_bucket.regular_data: Refreshing state... [id=demo-regular-data-12345]

Terraform will perform the following actions:

  # aws_s3_bucket.regular_data will be destroyed
  - resource "aws_s3_bucket" "regular_data" {
      # ... attributes
    }

Plan: 0 to add, 0 to change, 1 to destroy.
```

**Key Point:** ✅ **Regular bucket can be destroyed** (no lifecycle rule)

Type `yes` to confirm, then recreate it with `terraform apply`.

### 4. Try Full Destroy
```bash
terraform destroy
```

**Expected Output:**
```
Error: Instance cannot be destroyed

  on main.tf line 18, in resource "aws_s3_bucket" "critical_data":
  18: resource "aws_s3_bucket" "critical_data" {

Resource aws_s3_bucket.critical_data has lifecycle.prevent_destroy set, but
the plan calls for this resource to be destroyed.
```

**Key Point:** ✅ **Even full destroy fails** due to protected resources

### 5. Remove Protection and Destroy
To actually destroy everything, comment out the lifecycle rules:

```hcl
resource "aws_s3_bucket" "critical_data" {
  # ... configuration

  # lifecycle {
  #   prevent_destroy = true
  # }
}

resource "aws_s3_bucket_versioning" "critical_data" {
  # ... configuration

  # lifecycle {
  #   prevent_destroy = true
  # }
}
```

Then apply the changes and destroy:
```bash
terraform apply  # Remove the lifecycle rules
terraform destroy # Now works
```

## Key Learning Points

### **When to Use prevent_destroy**
- ✅ **Production Databases** - Critical data that cannot be lost
- ✅ **S3 Buckets with Important Data** - Backups, logs, artifacts
- ✅ **DNS Zones** - Critical for domain resolution
- ✅ **KMS Keys** - Used for encryption across systems
- ✅ **State Buckets** - Terraform remote state storage

### **When NOT to Use**
- ❌ **Development Resources** - Should be easily recreatable
- ❌ **Temporary Resources** - Designed to be short-lived
- ❌ **Test Environments** - Need frequent cleanup

## Common Use Cases

1. **Production Databases** - RDS, DynamoDB tables with customer data
2. **Storage Buckets** - S3 buckets with backups, logs, or artifacts
3. **Identity Resources** - IAM roles, users that are hard to recreate
4. **Networking** - VPCs, subnets in production environments
5. **Certificates** - SSL/TLS certificates that take time to reissue

## Best Practices

### **Combine with Other Protections**
```hcl
resource "aws_s3_bucket" "critical" {
  # ... configuration
  
  lifecycle {
    prevent_destroy = true
    ignore_changes  = [tags["LastModified"]]
  }
}
```

### **Use Conditionally**
```hcl
lifecycle {
  prevent_destroy = var.environment == "production" ? true : false
}
```

### **Document Protected Resources**
Always document why a resource is protected and how to remove protection.

## File Structure

```
.
├── main.tf            # S3 buckets with prevent_destroy
├── variables.tf       # Variable declarations
├── outputs.tf         # Output declarations
├── terraform.tfvars   # Variable values
└── README.md          # This demo guide
``` 