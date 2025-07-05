# Terraform Lifecycle: `create_before_destroy` Demo

This example demonstrates the **`create_before_destroy`** lifecycle rule, which ensures new resources are created before old ones are destroyed, preventing downtime.

## What Gets Created

- ✅ **Security Group** - Web server security group (with lifecycle rule)
- ✅ **EC2 Instance** - Depends on the security group

## How `create_before_destroy` Works

Without this rule, Terraform would:
1. ❌ **Destroy old security group first**
2. ❌ **EC2 instance loses security group** (downtime!)
3. ❌ **Create new security group**
4. ❌ **Update EC2 instance**

With `create_before_destroy`, Terraform:
1. ✅ **Creates new security group first**
2. ✅ **Updates EC2 instance to use new security group**
3. ✅ **Destroys old security group** (no downtime!)

## Prerequisites

1. **AWS Account** with EC2 and VPC permissions
2. **Terraform** installed (>= 1.0)
3. **AWS CLI** configured: `aws configure`

## Demo Steps

### 1. Initial Setup
```bash
terraform init
terraform plan
terraform apply
```

**Expected:** 2 resources created (1 security group, 1 EC2 instance)

### 2. Trigger a Security Group Replacement
Edit `main.tf` and change the security group description:

```hcl
resource "aws_security_group" "web" {
  name_prefix = "${var.environment}-web-sg"
  description = "Security group for web servers - UPDATED"  # <-- Change this
  # ... rest of configuration
}
```

### 3. Plan the Change
```bash
terraform plan
```

**Expected Output:**
```
# aws_security_group.web must be replaced
-/+ resource "aws_security_group" "web" {
    ~ description = "Security group for web servers" -> "Security group for web servers - UPDATED"
    # ... other attributes
}

# aws_instance.web_server will be updated in-place
~ resource "aws_instance" "web_server" {
    ~ vpc_security_group_ids = [
        - "sg-oldsgid",
        + "sg-newsgid",
    ]
}

Plan: 1 to add, 1 to change, 1 to destroy.
```

**Key Points:**
- The `+/-` symbol means replacement
- EC2 instance will be updated (not replaced)
- Due to `create_before_destroy`, new SG created first

### 4. Apply the Change
```bash
terraform apply
```

**Expected Behavior:**
1. ✅ **New security group created** (sg-newsgid)
2. ✅ **EC2 instance updated** to use new security group
3. ✅ **Old security group destroyed** (sg-oldsgid)
4. ✅ **No downtime** - EC2 instance always has a security group

### 5. Verify No Downtime
```bash
terraform plan
```

**Expected:** `Plan: 0 to add, 0 to change, 0 to destroy.`

## Test Without create_before_destroy

To see the difference, comment out the lifecycle rule:

```hcl
# lifecycle {
#   create_before_destroy = true
# }
```

Then trigger another replacement and notice the plan shows potential downtime.

## Key Learning Points

### **When to Use create_before_destroy**
- ✅ **Security Groups** - Referenced by other resources
- ✅ **Load Balancers** - Cannot have downtime
- ✅ **DNS Records** - Need continuous availability
- ✅ **Launch Templates** - Used by Auto Scaling Groups

### **When NOT to Use**
- ❌ **Resources with unique constraints** (e.g., unique names)
- ❌ **Resources that cannot exist simultaneously**

## Common Use Cases

1. **Security Groups in Production** - Always need connectivity
2. **Load Balancers** - Zero downtime deployments
3. **DNS Records** - Continuous name resolution
4. **Launch Configurations** - Auto Scaling Groups need them

## Cleanup

```bash
terraform destroy
```

**Expected:** All resources destroyed cleanly.

## File Structure

```
.
├── main.tf            # Security group with lifecycle rule
├── variables.tf       # Variable declarations
├── outputs.tf         # Output declarations
├── terraform.tfvars   # Variable values
└── README.md          # This demo guide
``` 