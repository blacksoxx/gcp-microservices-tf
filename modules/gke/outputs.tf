output "cluster_endpoint" {
  description = "GKE cluster endpoint"
  value       = google_container_cluster.primary.endpoint
}

output "cluster_ca_certificate" {
  description = "GKE cluster CA certificate"
  value       = google_container_cluster.primary.master_auth[0].cluster_ca_certificate
}

output "stateful_disk_name" {
  description = "Persistent disk name for stateful workloads"
  value       = google_compute_disk.stateful_disk.name
}
