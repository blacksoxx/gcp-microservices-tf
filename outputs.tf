output "gke_cluster_endpoint" {
  description = "Regional GKE control plane endpoint"
  value       = module.gke.cluster_endpoint
}

data "kubernetes_service_v1" "boutique_frontend_external" {
  count = var.deploy_boutique_manifests ? 1 : 0

  metadata {
    name      = "frontend-external"
    namespace = var.boutique_namespace
  }

  depends_on = [terraform_data.boutique_manifests]
}

output "cloud_run_url" {
  description = "Cloud Run frontend URL (null when deploy_cloud_run_frontend is false)"
  value       = var.deploy_cloud_run_frontend ? module.serverless[0].cloud_run_url : null
}

output "boutique_frontend_external_ip" {
  description = "GKE frontend-external service IP (null until allocated)"
  value = var.deploy_boutique_manifests ? try(
    data.kubernetes_service_v1.boutique_frontend_external[0].status[0].load_balancer[0].ingress[0].ip,
    null
  ) : null
}

output "boutique_frontend_url" {
  description = "GKE frontend URL (null until a load balancer IP is allocated)"
  value = var.deploy_boutique_manifests ? try(
    "http://${data.kubernetes_service_v1.boutique_frontend_external[0].status[0].load_balancer[0].ingress[0].ip}",
    null
  ) : null
}

output "database_private_ip" {
  description = "Cloud SQL private IP address"
  value       = module.database.cloud_sql_private_ip
}
