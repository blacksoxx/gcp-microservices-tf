variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "cluster_name" {
  description = "Regional GKE cluster name"
  type        = string
}

variable "network_self_link" {
  description = "Self link of the VPC"
  type        = string
}

variable "subnetwork_self_link" {
  description = "Self link of the GKE subnet"
  type        = string
}

variable "pods_range_name" {
  description = "Secondary range name for pods"
  type        = string
}

variable "services_range_name" {
  description = "Secondary range name for services"
  type        = string
}

variable "disk_zone" {
  description = "Zone for stateful persistent disk"
  type        = string
}

variable "node_count" {
  description = "Initial node count per zone for the regional node pool"
  type        = number
  default     = 1
}

variable "node_machine_type" {
  description = "Machine type for GKE nodes"
  type        = string
  default     = "e2-standard-2"
}
