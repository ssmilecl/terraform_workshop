# Outputs for terraform taint example

output "ec2_instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.demo_server.id
}

output "ec2_instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.demo_server.public_ip
}
