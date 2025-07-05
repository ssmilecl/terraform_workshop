# Terraform Lifecycle: `ignore_changes` Demo

This example demonstrates the **`ignore_changes`** lifecycle rule, which tells Terraform to ignore changes to specific resource attributes, useful when external systems modify resources.

## What Gets Created

- ✅ **EC2 Instance (app_server)** - With `ignore_changes` for specific tags
- ✅ **EC2 Instance (normal_server)** - Without `ignore_changes` (for comparison)

## How `ignore_changes` Works

When external systems modify resources:
- ✅ **Without ignore_changes**: Terraform detects drift and wants to "fix" it
- ✅ **With ignore_changes**: Terraform ignores specified attributes and leaves them alone

## Prerequisites

1. **AWS Account** with EC2 permissions
2. **Terraform** installed (>= 1.0)
3. **AWS CLI** configured: `aws configure`

## Demo Steps

### 1. Initial Setup
```bash
terraform init
terraform plan
terraform apply
```

**Expected:** 2 resources created (2 EC2 instances)

### 2. Simulate External Tag Changes
Simulate external systems modifying EC2 instance tags by manually updating them in AWS Console:

1. **Go to EC2 Console** → **Instances**
2. **Find both instances:**
   - `demo-app-server` (with ignore_changes)
   - `demo-normal-server` (without ignore_changes)
3. **Modify tags on BOTH instances:**
   - Change `LastModified` to current date: `2024-12-20`
   - Change `AutoScaling` to `disabled`
   - Add new tag: `ExternallyManaged = true`

### 3. Plan After External Changes
```bash
terraform plan
```

**Expected Output:**
```
aws_instance.normal_server: Refreshing state... [id=i-xxxxxxxxx]
aws_instance.app_server: Refreshing state... [id=i-xxxxxxxxx]

Terraform will perform the following actions:

  # aws_instance.normal_server will be updated in-place
  ~ resource "aws_instance" "normal_server" {
      ~ tags = {
          ~ "AutoScaling"     = "disabled" -> "enabled"
          ~ "LastModified"    = "2024-12-20" -> "2024-01-01"
          - "ExternallyManaged" = "true" -> null
          # (other tags unchanged)
        }
    }

Plan: 0 to add, 1 to change, 0 to destroy.
```

**Key Points:**
- ✅ **app_server**: NO changes detected (ignores specified tags)
- ✅ **normal_server**: Changes detected (wants to "fix" the drift)

### 4. Apply to See the Difference
```bash
terraform apply
```

**Expected Behavior:**
- ✅ **app_server**: Tags remain as modified by external system
- ✅ **normal_server**: Tags reverted to Terraform configuration

### 5. Try Changing Ignored Attributes in Terraform
Edit `main.tf` and change the ignored tags in the app_server:

```hcl
resource "aws_instance" "app_server" {
  # ... other configuration
  
  tags = {
    Name = "${var.environment}-app-server"
    Type = "ignore_changes_example"
    LastModified = "2024-12-31"      # <-- Change this
    AutoScaling  = "disabled"        # <-- Change this
    Environment  = var.environment
  }
  
  # ... lifecycle configuration
}
```

### 6. Plan After Terraform Changes
```bash
terraform plan
```

**Expected Output:**
```
No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration 
and found no differences, so no changes are needed.
```

**Key Point:** ✅ **Changes to ignored attributes are not detected**

### 7. Change Non-Ignored Attribute
Now change a non-ignored tag in the app_server:

```hcl
tags = {
  Name = "${var.environment}-app-server-UPDATED"  # <-- Change this
  Type = "ignore_changes_example"
  LastModified = "2024-12-31"
  AutoScaling  = "disabled"
  Environment  = var.environment
}
```

### 8. Plan One More Time
```bash
terraform plan
```

**Expected Output:**
```
# aws_instance.app_server will be updated in-place
~ resource "aws_instance" "app_server" {
    ~ tags = {
        ~ "Name" = "demo-app-server" -> "demo-app-server-UPDATED"
        # (ignored tags unchanged)
    }
}

Plan: 0 to add, 1 to change, 0 to destroy.
```

**Key Point:** ✅ **Changes to non-ignored attributes are detected**

## Advanced Demo: Different ignore_changes Patterns

### Ignore All Tags
```hcl
lifecycle {
  ignore_changes = [tags]
}
```

### Ignore Multiple Attributes
```hcl
lifecycle {
  ignore_changes = [
    tags["LastModified"],
    tags["AutoScaling"],
    user_data,
    security_groups
  ]
}
```

### Ignore Entire Resource (rare)
```hcl
lifecycle {
  ignore_changes = all
}
```

## Key Learning Points

### **When to Use ignore_changes**
- ✅ **Database Minor Upgrades** - RDS automatically applies minor version updates
- ✅ **Monitoring Systems** - Add monitoring-related tags
- ✅ **CI/CD Pipelines** - Update deployment timestamps
- ✅ **Auto Scaling Groups** - Modify instance tags automatically
- ✅ **Security Tools** - Add compliance tags

### **What Can Be Ignored**
- ✅ **Engine Versions** - Database minor version upgrades (most common)
- ✅ **Tags** - Modified by external systems
- ✅ **User Data** - When updated by configuration management
- ✅ **Security Groups** - When managed by other systems
- ✅ **Disk Sizes** - When modified by monitoring

### **When NOT to Use**
- ❌ **Critical Configuration** - Security settings, networking
- ❌ **State that Matters** - Database connections, load balancer targets
- ❌ **Overuse** - Don't ignore everything, defeats the purpose

## Common Use Cases

### **1. Database Minor Version Upgrades (Most Common)**
```hcl
resource "aws_db_instance" "main" {
  engine_version = "8.0.35"  # MySQL version
  # ... other config
  
  lifecycle {
    ignore_changes = [
      engine_version,  # AWS may auto-upgrade to 8.0.36, 8.0.37, etc.
    ]
  }
}
```

### **2. Monitoring and Compliance**
```hcl
lifecycle {
  ignore_changes = [
    tags["MonitoringAgent"],
    tags["ComplianceStatus"],
    tags["LastPatched"]
  ]
}
```

### **3. CI/CD Deployment Info**
```hcl
lifecycle {
  ignore_changes = [
    tags["DeployedBy"],
    tags["DeploymentTime"],
    tags["GitCommit"]
  ]
}
```

### **4. Auto Scaling Tags**
```hcl
lifecycle {
  ignore_changes = [
    tags["LastScaled"],
    tags["AutoScalingGroup"],
    tags["LaunchTime"]
  ]
}
```

## Best Practices

### **Be Specific**
```hcl
# Good - specific attributes
ignore_changes = [tags["LastModified"]]

# Avoid - too broad
ignore_changes = [tags]
```

### **Document Why**
```hcl
lifecycle {
  # Ignore changes made by our monitoring system
  ignore_changes = [tags["MonitoringAgent"]]
}
```

### **Combine with Other Rules**
```hcl
lifecycle {
  create_before_destroy = true
  ignore_changes       = [tags["ExternallyManaged"]]
}
```

## Troubleshooting

### **Common Issues:**
1. **Terraform keeps trying to change ignored attributes**
   - Check attribute syntax: `tags["key"]` not `tags.key`
   
2. **Changes still detected**
   - Verify the attribute path is correct
   - Check for typos in attribute names

3. **Too many ignored changes**
   - Be more specific about what to ignore
   - Consider if the resource should be managed elsewhere

## Real-World Example

This pattern is commonly used when:
- **RDS Database** - AWS automatically applies minor version upgrades (8.0.35 → 8.0.36)
- **Monitoring agents** - Update tags with health status
- **CI/CD pipelines** - Add deployment information
- **Auto Scaling Groups** - Automatically add/modify tags on instances

The key is to let external systems manage specific attributes while Terraform manages the core resource configuration.

## Cleanup

```bash
terraform destroy
```

## File Structure

```
.
├── main.tf            # EC2 instances with ignore_changes
├── variables.tf       # Variable declarations
├── outputs.tf         # Output declarations
├── terraform.tfvars   # Variable values
└── README.md          # This demo guide
``` 