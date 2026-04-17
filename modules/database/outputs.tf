output "cloud_sql_private_ip" {
  description = "Private IP of Cloud SQL instance"
  value       = google_sql_database_instance.postgres.private_ip_address
}

output "redis_private_ip" {
  description = "Private IP address of Redis instance"
  value       = google_redis_instance.cache.host
}
