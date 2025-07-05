# Outputs for create_before_destroy example

output "security_group_id" {
  description = "ID of the web security group"
  value       = aws_security_group.web.id
}

output "security_group_name" {
  description = "Name of the web security group"
  value       = aws_security_group.web.name
}

output "ec2_instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.web_server.id
}

output "ec2_instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.web_server.public_ip
} 
