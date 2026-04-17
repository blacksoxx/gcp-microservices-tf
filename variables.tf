variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "Primary GCP region"
  type        = string
  default     = "us-central1"
}

variable "cluster_name" {
  description = "Name of the GKE cluster"
  type        = string
  default     = "boutique-gke"
}

variable "disk_zone" {
  description = "Zone used for the stateful persistent disk"
  type        = string
  default     = "us-central1-b"
}
