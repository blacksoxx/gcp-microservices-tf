variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "network_self_link" {
  description = "VPC self link used for private services"
  type        = string
}

variable "cloud_sql_instance_id" {
  description = "Cloud SQL instance ID"
  type        = string
}

variable "redis_instance_id" {
  description = "Redis instance ID"
  type        = string
}
