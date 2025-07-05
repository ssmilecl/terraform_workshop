# Terraform Command: `terraform apply -replace` Demo

This example demonstrates the **`terraform apply -replace`** command, which is the modern way to force resource replacement in Terraform.

## What Gets Created

- ✅ **EC2 Instance** - Server with user data for replacement demonstration

## How `terraform apply -replace` Works

When you use apply -replace:
- ✅ **Immediately replaces specified resource** in one command
- ✅ **More direct than legacy taint workflow** 
- ✅ **Destroys and recreates resource** in single operation
- ✅ **Useful for corrupted resources** or forcing updates

## Prerequisites

1. **AWS Account** with EC2 permissions
2. **Terraform** installed (>= 0.15.2 for -replace support)
3. **AWS CLI** configured: `aws configure`
4. **AMI ID** - Update `ami_id` in `terraform.tfvars` for current Amazon Linux 2023

## Demo Steps

### 1. Initial Setup
```bash
terraform init
terraform plan
terraform apply
```

**Expected:** 1 resource created (EC2 instance)

### 2. Check Current State
```bash
terraform state list
```

**Expected Output:**
```
aws_instance.demo_server
```

### 3. View Resource Details (Before Replacement)
```bash
terraform show aws_instance.demo_server
```

**Note the launch time and instance ID** - these will change after replacement.

### 4. Preview Replacement
```bash
terraform plan -replace="aws_instance.demo_server"
```

**Expected Output:**
```
Terraform will perform the following actions:

  # aws_instance.demo_server will be replaced, as requested
-/+ resource "aws_instance" "demo_server" {
    ~ id                       = "i-0123456789abcdef0" -> (known after apply)
    ~ launch_time              = "2024-12-20T10:30:00.000Z" -> (known after apply)
    ~ public_ip                = "54.123.45.67" -> (known after apply)
    ~ private_ip               = "172.31.32.123" -> (known after apply)
      # ... other changing attributes
    }

Plan: 1 to add, 0 to change, 1 to destroy.
```

**Key Points:**
- ✅ **Resource marked for replacement** (`-/+` symbol)
- ✅ **New instance will be created** with different ID and IP
- ✅ **User data will re-execute** on the new instance

### 5. Execute Replacement
```bash
terraform apply -replace="aws_instance.demo_server"
```

**Expected Behavior:**
1. ✅ **Old EC2 instance destroyed**
2. ✅ **New EC2 instance created**
3. ✅ **New instance ID, launch time, and IP addresses**
4. ✅ **User data script executes on new instance**

### 6. Verify Recreation
```bash
terraform show aws_instance.demo_server
```

**Compare with step 3** - you should see:
- ✅ **Different instance ID**
- ✅ **Different launch time**
- ✅ **Different public/private IP addresses**
- ✅ **Same configuration and tags**

## Key Learning Points

### **When to Use terraform apply -replace**
- ✅ **Corrupted Resources** - When resources are in a bad state
- ✅ **Force Updates** - When normal apply doesn't trigger needed changes
- ✅ **Testing Recreations** - Verify that resource recreation works
- ✅ **User Data Changes** - EC2 instances with new user data
- ✅ **Configuration Drift** - When manual changes need to be reset

### **What Happens During Replace**
1. **Planning Phase** - Terraform plans replacement
2. **Destroy Phase** - Old resource destroyed
3. **Create Phase** - New resource created
4. **Dependencies** - Dependent resources may also be replaced

### **Replace vs Other Operations**
- **apply -replace** - Force replacement immediately (modern approach)
- **terraform taint** - Mark for replacement, apply later (legacy)
- **terraform destroy -target** - Destroy specific resource only
- **Manual changes** - Modify resource outside Terraform

## Common Use Cases

### **1. Corrupted EC2 Instance**
```bash
# Instance is corrupted or compromised
terraform apply -replace="aws_instance.web_server"
```

### **2. Updated User Data**
```bash
# EC2 user data changed but instance not recreated
terraform apply -replace="aws_instance.app_server"
```

### **3. Reset Configuration**
```bash
# Manual changes made outside Terraform
terraform apply -replace="aws_security_group.app_sg"
```

### **4. Storage Issues**
```bash
# EBS volume has corruption issues
terraform apply -replace="aws_ebs_volume.app_data"  # This will recreate the volume!
```

### **5. Multiple Resource Reset**
```bash
# Replace multiple related resources
terraform apply -replace="aws_instance.web" -replace="aws_instance.app"
```

## Best Practices

### **Be Careful with Dependencies**
- ✅ **Check plan first** - Use `-replace` with `plan` to preview
- ✅ **Consider downtime** - Dependent resources will also be recreated
- ✅ **Backup data** - Especially for databases and storage

### **Use with State Lock**
- ✅ **In team environments** - Ensure no concurrent operations
- ✅ **Remote state** - Use proper state locking

### **Modern vs Legacy Approach**
```bash
# Modern approach (preferred)
terraform apply -replace="aws_instance.demo_server"

# Legacy approach (still works but not recommended)
terraform taint aws_instance.demo_server
terraform apply
```

## Production Scenarios

### **Scenario 1: Security Incident Response**
```bash
# Compromised instance needs immediate replacement
terraform apply -replace="aws_instance.web_server"
# Clean, fresh instance deployed immediately
```

### **Scenario 2: Failed Application Deployment**
```bash
# Application deployment corrupted the instance
terraform apply -replace="aws_instance.app_server"
# Reset to known good state
```

### **Scenario 3: Infrastructure Validation**
```bash
# Test disaster recovery procedures
terraform apply -replace="aws_instance.primary_db"
# Verify backup/restore procedures work
```

### **Scenario 4: Update Troubleshooting**
```bash
# User data changes not taking effect
terraform apply -replace="aws_instance.demo_server"
# Force fresh deployment with new user data
```

## Troubleshooting

### **Common Issues:**
1. **"Resource not found"**
   - Check resource address: `terraform state list`
   - Verify resource name is correct
   
2. **"Too many dependent resources"**
   - Review plan output carefully
   - Consider impact on dependent resources

3. **"State locked"**
   - Wait for other operations to complete
   - Check for crashed processes holding locks

4. **"Resource already being replaced"**
   - Wait for current operation to complete
   - Check terraform state for pending operations

### **Recovery:**
```bash
# If replace operation fails
terraform plan  # Check current state
terraform apply # Complete any pending operations

# If you need to cancel a plan file
rm replace.tfplan
terraform plan  # Create new plan
```

## Advantages of apply -replace

### **Over Legacy Taint:**
- ✅ **Single command** - No need for separate taint + apply
- ✅ **More explicit** - Clear intent to replace specific resource
- ✅ **Better in automation** - Easier to script and CI/CD
- ✅ **Safer** - No risk of forgetting to apply after taint

### **Production Benefits:**
- ✅ **Faster incident response** - One command to replace compromised resources
- ✅ **Clearer audit trail** - Explicit replacement actions in logs
- ✅ **Better team collaboration** - No "tainted" state confusion
- ✅ **Automation-friendly** - Easier to integrate with monitoring systems

## Cleanup

```bash
terraform destroy
```

**Expected Output:**
```
Destroy complete! Resources: 1 destroyed.
```

## File Structure

```
.
├── main.tf            # EC2 instance for replacement demonstration
├── variables.tf       # Variable declarations
├── outputs.tf         # Output declarations
├── terraform.tfvars   # Variable values
└── README.md          # This demo guide
```

## What's Next?

- **terraform state rm** - Remove resources from state without destroying
- **terraform import** - Import existing resources into state
- **terraform refresh** - Update state with real-world resources

---

**Key Takeaway**: `terraform apply -replace` is the modern, preferred way to force resource replacement. It's more direct, safer, and better suited for production environments than the legacy taint workflow. 