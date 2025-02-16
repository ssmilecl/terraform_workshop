# Creating Your AWS Route53 Hosted Zone

## What is this?
This terraform code will create your personal DNS hosted zone in AWS Route53. Think of it as reserving your own space on the internet where you can manage your domain names and direct traffic to your applications.

## What's a Hosted Zone?
A hosted zone is like an internet address book for your domain. It contains records that tell the internet how to route traffic to your applications (like websites, APIs, etc.).

## What are Nameservers?
Nameservers are like GPS for the internet. They tell the world where to find information about your domain. When someone tries to visit your domain, these nameservers provide directions to your actual application.

## Prerequisites
1. AWS account access
2. Terraform installed on your machine
3. Your assigned subdomain from the instructor (e.g., `johnsnow.aws.jrworkshop.au`)
4. Your AWS account ID

## Steps to Create Your Hosted Zone

1. Update `terraform.tfvars` with your information:
   
```
student_subdomain = "your-name.aws.jrworkshop.au"  # Use the subdomain assigned to you
```

2. Run the following commands:

```bash
terraform init
terraform plan
terraform apply
```

3. After successful creation, you'll see three outputs:
   - `hosted_zone_id`: Your zone's unique identifier
   - `hosted_zone_name`: Your domain name
   - `nameservers`: List of 4 nameservers (NS records)

## Important! Next Steps
**Send the following information to your instructor**:
1. Your subdomain name
2. The 4 nameserver values (NS records)

Example format:
```
Subdomain: johnsnow.aws.jrworkshop.au
Nameservers:
- ns-1234.awsdns-12.org
- ns-345.awsdns-43.com
- ns-678.awsdns-21.net
- ns-910.awsdns-50.co.uk
```

The instructor will use these nameservers to delegate your subdomain, allowing your hosted zone to be accessible on the internet.

## Why This Matters
This setup allows you to:
- Host your own websites and applications under your subdomain
- Manage DNS records for your applications
- Learn about DNS management in a real-world context

## Need Help?
Contact your instructor if you:
- Don't see the nameserver values after creation
- Get any errors during the process
- Have questions about DNS or hosted zones

