# Basic Static Website with CloudFront CDN

This module creates:
- S3 bucket for static content
- ACM certificate for your subdomain
- CloudFront distribution
- Sample static HTML page

## Prerequisites
- AWS CLI configured with your credentials
- Terraform installed
  - If you don't have Terraform installed, follow the instructions [here](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- Assigned subdomain from instructor (e.g., student1.workshop.com)

## Usage

1. Update `terraform.tfvars` with your assigned subdomain:

```hcl
student_subdomain = "student1.workshop.com" # Replace with your assigned subdomain
content_version = "student1-v1" # Customize this
```

2. Initialize and apply Terraform:

```bash
terraform init
terraform apply
```

3. After apply, provide to your instructor:
- Certificate validation records (from outputs)
- CloudFront domain name (from outputs)

4. Wait for instructor to:
- Add certificate validation records
- Add CloudFront CNAME record

5. Once DNS propagates, your site will be available at your subdomain URL

## Customization
- Edit the HTML content in `main.tf` to customize your page
- Update `content_version` in `terraform.tfvars` to track changes

## Key Terraform Concepts

### Providers
```hcl
provider "aws" {
  region = "us-west-2"
}
```
- Providers are plugins that Terraform uses to interact with cloud platforms
- They expose resources and data sources
- Each provider has its own configuration (like region for AWS)

### Resources
```hcl
resource "aws_s3_bucket" "static_site" {
  bucket = replace(var.student_subdomain, ".", "-")
}
```
- Resources are infrastructure objects you want to manage
- Format: `resource "provider_type" "local_name" { ... }`
- Each resource type has its own configuration arguments
- Resources often have dependencies on other resources

### Data Sources
```hcl
data "aws_iam_policy_document" "static_site" {
  statement {
    // ... policy configuration ...
  }
}
```
- Data sources fetch information from your provider
- They allow you to query existing resources or generate configurations
- Format: `data "provider_type" "local_name" { ... }`
- Used for reading (unlike resources which are for creating/updating)

### Variables
```hcl
variable "student_subdomain" {
  description = "Subdomain assigned to student"
  type        = string
}
```
- Variables make your configuration reusable
- They can have types, descriptions, and default values
- Can be set via:
  - terraform.tfvars file
  - -var command line flag
  - Environment variables (TF_VAR_name)

### Outputs
```hcl
output "website_url" {
  value = "https://${var.student_subdomain}"
}
```
- Outputs expose specific values from your infrastructure
- Useful for showing important information after apply
- Can be referenced by other Terraform configurations

### Dependencies
- Terraform automatically handles dependencies between resources
- Explicit dependencies: using `depends_on`
- Implicit dependencies: using reference expressions (e.g., `${aws_s3_bucket.static_site.id}`)

### State
- Terraform tracks infrastructure in a state file
- Default: local file named `terraform.tfstate`
- Maps real-world resources to your configuration
- Contains sensitive information - handle with care!

### Common Commands
```bash
terraform init          # Initialize working directory
terraform plan         # Show execution plan
terraform apply        # Apply changes
terraform destroy      # Destroy infrastructure
terraform fmt         # Format configuration files
terraform validate    # Validate configuration files
terraform show        # Show current state
terraform output      # Show output values
```

### Best Practices
1. Always run `terraform plan` before `apply`
2. Use meaningful names for resources
3. Use variables for reusable values
4. Format your code with `terraform fmt`
5. Validate your configuration with `terraform validate`
6. Use version control for your Terraform code
7. Keep sensitive data out of version control

### Next Steps
- Learn about remote state storage
- Explore Terraform modules
- Understand workspace management
- Study CI/CD integration