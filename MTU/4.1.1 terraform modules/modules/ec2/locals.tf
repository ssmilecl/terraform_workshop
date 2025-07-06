# EC2 Module Local Values
# Locals are computed values that can be used throughout the module

locals {
  # Name prefixes for consistent naming
  name_prefix = "${var.project_prefix}-${var.random_suffix}"

  # Module-specific tags
  module_tags = {
    Module     = "ec2"
    ModuleType = "compute"
    AMI        = data.aws_ami.amazon_linux.id
    Region     = data.aws_region.current.name
  }

  # Combined tags (merge common tags with module-specific tags)
  all_tags = merge(var.common_tags, local.module_tags)

  # Minimal user data script
  user_data = <<-EOF
#!/bin/bash
yum install -y httpd
echo "<h1>Hello from Terraform!</h1><p>Status: HEALTHY</p>" > /var/www/html/index.html
systemctl enable httpd
systemctl start httpd
EOF
}
