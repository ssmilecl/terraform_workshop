variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "project" {
  description = "Project name for tagging"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
}

variable "workspace_name" {
  description = "Name of the Prometheus workspace"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "create_workspace" {
  description = "Whether to create the Prometheus workspace"
  type        = bool
  default     = true
}

variable "rule_group_namespaces" {
  description = "A map of rule group namespaces to create"
  type        = any
  default     = {}
}

variable "alertmanager_configuration" {
  description = "Alertmanager configuration"
  type        = any
  default     = null
}