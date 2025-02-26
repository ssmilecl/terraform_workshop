# Basic Static Website with CloudFront CDN

## Prerequisites
1. **Hosted Zone Setup**: You must have completed the hosted zone setup from:
   `terraform_workshop/01_basic/hosted_zone`
2. AWS CLI configured with your credentials
3. Terraform installed
4. Your assigned subdomain (e.g., johnsnow.aws.jrworkshop.au)

## What This Creates
- S3 bucket for static content
- ACM certificate for your subdomain (with automatic validation)
- CloudFront distribution
- Sample static HTML page

## Deployment Steps

1. Update `terraform.tfvars`:
```hcl
student_subdomain = "johnsnow.aws.jrworkshop.au"  # Your domain name
content_version   = "johnsnow-tf-basic-v1"       # Version tag for your content
account_id        = "xxxxxxxxxx"               # Change to your AWS account ID
hosted_zone_id    = "xxxxxxxxxxxxxx"      # Change to your hosted zone ID

```

2. Initial deployment:
```bash
terraform init
terraform plan
terraform apply
```

3. **Important**: The first `apply` will create resources but CloudFront won't be fully functional yet because:
   - ACM certificate needs to be validated
   - This validation happens automatically in your hosted zone
   - It can take 5-15 minutes for AWS to validate the certificate

4. Wait for certificate validation:
   - Check the AWS Console > Certificate Manager
   - Wait until your certificate status changes to "Issued"
   - Or use AWS CLI:
   ```bash
   aws acm list-certificates --query 'CertificateSummaryList[*].[DomainName,Status]'
   ```

5. Once certificate is validated, run another apply:
```bash
terraform apply
```

6. After successful second apply, your static website will be available at:
   `https://your-subdomain.aws.jrworkshop.au`

   Note: It may take 5-10 minutes for CloudFront to fully deploy

## Customizing Your Website
- Edit the HTML content in `main.tf` to customize your page
- Update `content_version` in `terraform.tfvars` to track changes
- Run `terraform apply` to deploy changes

## Troubleshooting
1. If CloudFront shows "Invalid certificate":
   - Wait for certificate validation to complete
   - Run `terraform apply` again
2. If website isn't accessible after deployment:
   - Allow 5-10 minutes for CloudFront propagation
   - Verify certificate is "Issued" in ACM
   - Check CloudFront distribution status is "Deployed"

## Need Help?
Contact your instructor if:
- Certificate validation takes longer than 30 minutes
- CloudFront remains unavailable after second apply
- You see any unexpected errors

## Cleanup
To remove all resources:
```bash
terraform destroy
```

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

## Understanding SSL/TLS Certificates

### What is an SSL/TLS Certificate?
An SSL/TLS certificate is a digital certificate that:
- Encrypts data between your website and its visitors
- Proves your website's identity to browsers
- Enables the padlock 🔒 icon and HTTPS in browsers

### How Browsers Trust Your Website
1. **Certificate Chain of Trust**:
   - Your certificate is issued by Amazon's Certificate Manager (ACM)
   - ACM's certificate is issued by a Root Certificate Authority (CA)
   - Browsers come pre-installed with trusted Root CA certificates
   - This creates a "chain of trust" from your site to the browser

2. **What Happens When a User Visits Your Site**:
   ```
   Browser ──── Requests ───→ Your Website
     ↓                            ↓
   Checks         Presents Certificate
   Certificate    (issued by ACM)
     ↓                            
   Verifies with
   Root CA
     ↓
   Shows 🔒 if Valid
   ```

3. **Why HTTPS Matters**:
   - Encrypts all data between browser and website
   - Prevents data tampering and eavesdropping
   - Builds user trust (green padlock)
   - Required for modern web features

### How AWS Certificate Manager (ACM) Works
1. **Certificate Request**:
   - When you run `terraform apply`, AWS creates a certificate for your domain
   - This certificate is free when used with AWS services like CloudFront

2. **Domain Validation Process**:
   - AWS needs to verify you control the domain
   - AWS creates a special DNS record (CNAME) in your hosted zone
   - Format: `_acme-challenge.your-domain.com`
   - This happens automatically because you own the hosted zone

3. **Validation Flow**:
   ```
   Your Hosted Zone ─── Contains ──→ Validation Records
         ↑                               ↓
   AWS Creates Records         AWS Checks Records
         ↑                               ↓
   Certificate Request ←── Validates ─── AWS ACM
   ```

4. **Certificate Renewal**:
   - ACM certificates are valid for 13 months
   - AWS automatically renews certificates
   - Renewal uses the same validation records

### Why Two Applies Are Needed
1. **First Apply**:
   - Creates the certificate
   - Sets up validation records
   - Starts validation process (takes 5-15 minutes)

2. **Second Apply**:
   - Uses the validated certificate
   - Completes CloudFront setup with HTTPS
   - Enables secure access to your website

### Certificate Requirements
- Must be in `us-east-1` region for CloudFront use
- Domain must match your assigned subdomain exactly
- Validation records must remain in your hosted zone