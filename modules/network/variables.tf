variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "vpc_name" {
  description = "VPC name"
  type        = string
  default     = "prod-vpc"
}

variable "gke_subnet_cidr" {
  description = "Primary CIDR for the GKE subnet"
  type        = string
  default     = "10.10.0.0/20"
}

variable "gke_pods_cidr" {
  description = "Secondary CIDR range for GKE pods"
  type        = string
  default     = "10.20.0.0/16"
}

variable "gke_services_cidr" {
  description = "Secondary CIDR range for GKE services"
  type        = string
  default     = "10.30.0.0/20"
}

variable "serverless_subnet_cidr" {
  description = "Primary CIDR for serverless connector subnet"
  type        = string
  default     = "10.40.0.0/24"
}

variable "vpc_connector_cidr" {
  description = "IP CIDR range for Serverless VPC Access connector"
  type        = string
  default     = "10.40.1.0/28"
}
