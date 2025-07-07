output "workspace_arn" {
  description = "ARN of the Prometheus workspace"
  value       = module.prometheus.workspace_arn
}

output "workspace_id" {
  description = "ID of the Prometheus workspace"
  value       = module.prometheus.workspace_id
}

output "workspace_endpoint" {
  description = "Endpoint of the Prometheus workspace"
  value       = module.prometheus.workspace_prometheus_endpoint
}

output "alertmanager_endpoint" {
  description = "Endpoint of the alertmanager"
  value       = module.prometheus.workspace_alertmanager_endpoint
}