# Outputs for ignore_changes example

output "app_server_id" {
  description = "ID of the app server (with ignore_changes)"
  value       = aws_instance.app_server.id
}

output "app_server_public_ip" {
  description = "Public IP of the app server"
  value       = aws_instance.app_server.public_ip
}

output "normal_server_id" {
  description = "ID of the normal server (without ignore_changes)"
  value       = aws_instance.normal_server.id
}

output "normal_server_public_ip" {
  description = "Public IP of the normal server"
  value       = aws_instance.normal_server.public_ip
} 
