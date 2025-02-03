# Using Terraform Modules

This section demonstrates how to use public Terraform modules to simplify infrastructure code and follow best practices.

## What are Terraform Modules?

Terraform modules are reusable, encapsulated units of Terraform configuration that package infrastructure resources in a maintainable way. They help:

1. **Reduce Code Duplication**
   - Reuse common infrastructure patterns
   - Maintain consistency across projects
   - Reduce errors through tested configurations

2. **Simplify Complex Infrastructure**
   - Abstract away implementation details
   - Provide clear interfaces through variables
   - Handle dependencies automatically

3. **Enforce Best Practices**
   - Use community-tested configurations
   - Implement security controls consistently
   - Follow infrastructure patterns

## Module Sources

Modules can come from various sources:
- Public Registry (registry.terraform.io)
- Private Registry
- Git Repositories
- Local Paths
- HTTP URLs

## Key Concepts

1. **Module Structure**
   ```
   module "name" {
     source  = "source_location"
     version = "version_number"
     
     # Module inputs
     input1 = value1
     input2 = value2
   }
   ```

2. **Version Constraints**
   - Always specify versions for stability
   - Use semantic versioning
   - Example: `version = "~> 3.0.0"`

3. **Module Composition**
   - Modules can use other modules
   - Create hierarchical infrastructure
   - Share outputs between modules

## Used Modules

This example uses two popular modules:

1. **terraform-aws-modules/cloudfront/aws**
   - Creates CloudFront distributions
   - Handles origin access controls
   - Manages cache behaviors

2. **terraform-aws-modules/s3-bucket/aws**
   - Creates S3 buckets
   - Configures bucket properties
   - Manages access controls

## Prerequisites

- Completed steps from 01_basic (existing ACM certificate)
- Terraform 0.13 or later
- AWS credentials configured

## Usage

1. Initialize Terraform with modules:
``` bash
terraform init
```

2. Review the plan:
``` bash
terraform plan
```

3. Apply the configuration:
``` bash
terraform apply
```

## Best Practices for Using Modules

1. **Version Management**
   - Always specify module versions
   - Use version constraints
   - Test version upgrades

2. **Input Variables**
   - Document all required inputs
   - Provide meaningful defaults
   - Validate input values

3. **Module Size**
   - Keep modules focused
   - Follow single responsibility principle
   - Break large modules into smaller ones

4. **Documentation**
   - Read module documentation
   - Understand input/output variables
   - Check examples and requirements

5. **Testing**
   - Test modules in isolation
   - Verify module upgrades
   - Use terraform plan to validate changes

## Key Differences from Basic Setup

1. **Code Organization**
   - More structured approach
   - Clear separation of concerns
   - Reusable components

2. **Maintenance**
   - Updates handled by module maintainers
   - Security patches included
   - Best practices built-in

3. **Flexibility**
   - Easy to customize through variables
   - Consistent interface
   - Documented options

## Common Issues and Solutions

1. **Module Version Conflicts**
   ```bash
   # Force module update
   terraform init -upgrade
   ```

2. **Provider Version Requirements**
   - Check module documentation
   - Update provider versions
   - Use provider locks

3. **Module Dependencies**
   - Use depends_on when needed
   - Check module outputs
   - Verify resource ordering

This approach:
1. Reuses the existing ACM certificate
2. Uses community modules for CloudFront and S3
3. Simplifies the configuration while maintaining functionality
4. Demonstrates module usage best practices

Would you like me to explain any part in more detail?

2. Then, if needed, destroy the basic setup (01_basic):
```bash
cd ../01_basic
terraform destroy
```

## Important: Destruction Order

When destroying resources across workshop steps, the correct order is crucial:

1. First, destroy the module resources (03_terraform_modules):
   ```bash
   Destroy CloudFront and S3 modules
   terraform destroy
   ```

⚠️ **Warning**: Destroying the basic setup (01_basic) first will cause issues with the certificate data source in the modules setup. Always destroy the modules first!

### Why This Order Matters
- The modules setup references the ACM certificate created in the basic setup
- If you destroy the basic setup first, the certificate data source in modules becomes invalid
- This can lead to state inconsistencies and failed destroy operations
