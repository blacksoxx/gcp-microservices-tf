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

variable "frontend_image" {
  description = "Container image used by the Cloud Run frontend service"
  type        = string
  default     = "gcr.io/google-samples/microservices-demo/frontend:v0.10.1"
}

variable "allow_public_frontend" {
  description = "Whether to allow unauthenticated access to the Cloud Run frontend"
  type        = bool
  default     = true
}

variable "deploy_cloud_run_frontend" {
  description = "Whether to deploy the Cloud Run frontend module"
  type        = bool
  default     = false
}

variable "deploy_boutique_manifests" {
  description = "Whether Terraform should deploy the Online Boutique Kubernetes manifests to GKE"
  type        = bool
  default     = false
}

variable "boutique_namespace" {
  description = "Kubernetes namespace used for Online Boutique manifests"
  type        = string
  default     = "boutique"
}

variable "boutique_manifest_url" {
  description = "URL to the Online Boutique Kubernetes manifest file"
  type        = string
  default     = "https://raw.githubusercontent.com/GoogleCloudPlatform/microservices-demo/main/release/kubernetes-manifests.yaml"
}
