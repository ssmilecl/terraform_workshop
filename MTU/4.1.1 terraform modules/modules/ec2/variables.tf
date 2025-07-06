# EC2 Module Variables - Child Module Input Variables
# These variables are passed from the root module and VPC module outputs

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "project_prefix" {
  description = "Computed project prefix from root module"
  type        = string
}

variable "random_suffix" {
  description = "Random suffix for unique naming"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "key_pair_name" {
  description = "Name of the AWS key pair for EC2 instances"
  type        = string
}

# Variables from VPC module outputs
variable "vpc_id" {
  description = "ID of the VPC (from VPC module)"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs (from VPC module)"
  type        = list(string)
}

variable "web_security_group_id" {
  description = "ID of the web security group (from VPC module)"
  type        = string
} 
