output "cloud_run_url" {
  description = "Cloud Run frontend URL"
  value       = google_cloud_run_v2_service.frontend.uri
}
