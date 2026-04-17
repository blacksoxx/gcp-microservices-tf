output "vpc_self_link" {
  description = "Self link of the production VPC"
  value       = google_compute_network.prod_vpc.self_link
}

output "gke_subnet_self_link" {
  description = "Self link of GKE subnet"
  value       = google_compute_subnetwork.gke_subnet.self_link
}

output "gke_pods_range_name" {
  description = "Secondary range name for GKE pods"
  value       = "gke-pods-range"
}

output "gke_services_range_name" {
  description = "Secondary range name for GKE services"
  value       = "gke-services-range"
}

output "serverless_vpc_connector_id" {
  description = "Fully qualified ID for the Serverless VPC Access connector"
  value       = google_vpc_access_connector.serverless_connector.id
}
