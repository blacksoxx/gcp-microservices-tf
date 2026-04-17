variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "vpc_connector_id" {
  description = "Serverless VPC Access connector ID"
  type        = string
}

variable "cloud_run_service" {
  description = "Cloud Run service name"
  type        = string
}

variable "scheduler_job_name" {
  description = "Cloud Scheduler job name"
  type        = string
}

variable "frontend_image" {
  description = "Container image for Online Boutique frontend"
  type        = string
  default     = "gcr.io/google-samples/microservices-demo/frontend:v0.10.2"
}
