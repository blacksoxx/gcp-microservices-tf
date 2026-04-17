output "gke_cluster_endpoint" {
  description = "Regional GKE control plane endpoint"
  value       = module.gke.cluster_endpoint
}

output "cloud_run_url" {
  description = "Cloud Run frontend URL"
  value       = module.serverless.cloud_run_url
}

output "database_private_ip" {
  description = "Cloud SQL private IP address"
  value       = module.database.cloud_sql_private_ip
}
