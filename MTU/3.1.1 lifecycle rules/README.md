# Terraform Lifecycle Rules - Complete Examples

This section contains **three independent examples** demonstrating Terraform's lifecycle rules. Each example is in its own subfolder to prevent interference between different lifecycle behaviors.

## 📁 **Example Structure**

```
3.1.1 lifecycle rules overview/
├── 3.1.1a create_before_destroy/  # Zero-downtime replacements
├── 3.1.1b prevent_destroy/        # Protect critical resources  
└── 3.1.1c ignore_changes/         # Handle external modifications
```

## 🎯 **What Each Example Demonstrates**

### **3.1.1a - `create_before_destroy`**
**Purpose:** Prevent downtime during resource replacements

**Resources:**
- Security Group (with lifecycle rule)
- EC2 Instance (dependent resource)

**Demo:** 
- Modify security group to trigger replacement
- See how new SG is created before old one is destroyed
- EC2 instance never loses connectivity

**Key Learning:** Zero-downtime deployments for critical resources

---

### **3.1.1b - `prevent_destroy`**
**Purpose:** Protect critical resources from accidental deletion

**Resources:**
- Critical S3 Bucket (protected)
- Regular S3 Bucket (not protected)
- S3 Bucket Versioning (protected)

**Demo:**
- Try to destroy individual resources
- Try to destroy entire stack
- See how Terraform refuses to destroy protected resources

**Key Learning:** Safety nets for production-critical resources

---

### **3.1.1c - `ignore_changes`**
**Purpose:** Handle external systems that modify resources

**Resources:**
- EC2 Instance (with ignore_changes)
- EC2 Instance (without ignore_changes)
- Auto Scaling Group (simulates external system)
- VPC and Subnet (supporting infrastructure)

**Demo:**
- Manually modify tags in AWS Console
- See how ignore_changes prevents drift detection
- Compare with normal resource behavior

**Key Learning:** Coexistence with external management systems

## 🚀 **How to Use These Examples**

### **Option 1: Run All Examples (Recommended)**
```bash
# Run each example independently
cd "3.1.1a create_before_destroy"
terraform init && terraform apply
# ... follow demo steps in README
terraform destroy

cd "../3.1.1b prevent_destroy"  
terraform init && terraform apply
# ... follow demo steps in README
# Note: destroy will fail due to prevent_destroy

cd "../3.1.1c ignore_changes"
terraform init && terraform apply
# ... follow demo steps in README
terraform destroy
```

### **Option 2: Focus on One Lifecycle Rule**
Pick the lifecycle rule you want to learn about and run just that example.

### **Option 3: Compare Behaviors**
Run examples side-by-side to see the differences in behavior.

## 📋 **Prerequisites (All Examples)**

1. **AWS Account** with appropriate permissions
2. **Terraform** installed (>= 1.0)
3. **AWS CLI** configured: `aws configure`
4. **Unique identifiers** - Change bucket suffixes, etc.

## 🔑 **Key Concepts Summary**

### **`create_before_destroy`**
```hcl
lifecycle {
  create_before_destroy = true
}
```
- ✅ **Use for:** Resources that cannot have downtime
- ✅ **Behavior:** New resource created before old one destroyed
- ✅ **Examples:** Security Groups, Load Balancers, DNS Records

### **`prevent_destroy`**
```hcl
lifecycle {
  prevent_destroy = true
}
```
- ✅ **Use for:** Critical resources that should never be accidentally deleted
- ✅ **Behavior:** `terraform destroy` fails if it would destroy the resource
- ✅ **Examples:** Production databases, important S3 buckets

### **`ignore_changes`**
```hcl
lifecycle {
  ignore_changes = [
    tags["LastModified"],
    tags["AutoScaling"]
  ]
}
```
- ✅ **Use for:** Attributes modified by external systems
- ✅ **Behavior:** Terraform ignores changes to specified attributes
- ✅ **Examples:** Auto-scaling tags, monitoring attributes

## 🎨 **Advanced Combinations**

You can combine lifecycle rules:
```hcl
lifecycle {
  create_before_destroy = true
  prevent_destroy      = true
  ignore_changes       = [tags["ExternallyManaged"]]
}
```

## 📚 **Learning Path**

1. **Start with `create_before_destroy`** - Most commonly used
2. **Move to `prevent_destroy`** - Important for production safety
3. **Finish with `ignore_changes`** - Handles complex real-world scenarios

## 🛠️ **Troubleshooting**

### **Common Issues:**
1. **Resources interfering with each other**
   - ✅ **Solution:** Use separate directories (already done!)

2. **prevent_destroy preventing cleanup**
   - ✅ **Solution:** Comment out lifecycle rule, apply, then destroy

3. **ignore_changes not working**
   - ✅ **Solution:** Check attribute syntax: `tags["key"]` not `tags.key`

## 💡 **Best Practices**

1. **Use `create_before_destroy`** for production resources with dependencies
2. **Use `prevent_destroy`** sparingly, only for truly critical resources
3. **Use `ignore_changes`** when external systems manage specific attributes
4. **Document** why each lifecycle rule is used
5. **Test** lifecycle behavior in non-production environments first

## 🔍 **What's Next?**

After mastering lifecycle rules, explore:
- **Terraform Modules** - Reusable infrastructure components
- **Remote State** - Collaborative Terraform workflows
- **Workspaces** - Managing multiple environments
- **Provisioners** - Bootstrap resources after creation

Each example includes detailed step-by-step instructions and expected outputs for hands-on learning! 