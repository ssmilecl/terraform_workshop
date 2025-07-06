# EC2 Module Outputs - Child Module Outputs
# These outputs are consumed by the root module

output "instance_ids" {
  description = "List of EC2 instance IDs"
  value       = aws_instance.web[*].id
}

output "instance_public_ips" {
  description = "List of public IP addresses of EC2 instances"
  value       = aws_instance.web[*].public_ip
}

output "instance_private_ips" {
  description = "List of private IP addresses of EC2 instances"
  value       = aws_instance.web[*].private_ip
}

output "load_balancer_dns" {
  description = "DNS name of the load balancer"
  value       = aws_lb.web.dns_name
}

output "load_balancer_zone_id" {
  description = "Zone ID of the load balancer"
  value       = aws_lb.web.zone_id
}

output "load_balancer_arn" {
  description = "ARN of the load balancer"
  value       = aws_lb.web.arn
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.web.arn
}

output "launch_template_id" {
  description = "ID of the launch template"
  value       = aws_launch_template.web.id
}

# Information outputs for demonstration
output "ami_used" {
  description = "AMI ID used for instances"
  value       = data.aws_ami.amazon_linux.id
}

output "ami_name" {
  description = "Name of the AMI used"
  value       = data.aws_ami.amazon_linux.name
}

output "instance_count" {
  description = "Number of instances created"
  value       = length(aws_instance.web)
}

output "availability_zones_used" {
  description = "Availability zones where instances are deployed"
  value       = [for instance in aws_instance.web : instance.availability_zone]
} 
