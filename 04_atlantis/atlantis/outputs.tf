output "atlantis_url" {
  description = "URL of Atlantis"
  value       = module.atlantis.url
}

output "webhook_url" {
  description = "Webhook URL for GitHub"
  value       = "${module.atlantis.url}/events"
}

output "ecs_task_role" {
  description = "Role ARN for Atlantis ECS task"
  value       = module.atlantis.service.task_role_arn
} 
