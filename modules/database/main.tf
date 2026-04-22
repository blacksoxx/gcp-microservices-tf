resource "google_sql_database_instance" "postgres" {
  project          = var.project_id
  name             = var.cloud_sql_instance_id
  database_version = "POSTGRES_15"
  region           = var.region
  settings {
    tier = "db-custom-2-7680"

    ip_configuration {
      ipv4_enabled    = false
      private_network = var.network_self_link
    }

    backup_configuration {
      enabled = true
    }
  }

  deletion_protection = false
}

resource "google_redis_instance" "cache" {
  project            = var.project_id
  name               = var.redis_instance_id
  tier               = "STANDARD_HA"
  memory_size_gb     = 1
  region             = var.region
  authorized_network = var.network_self_link
  connect_mode       = "PRIVATE_SERVICE_ACCESS"
  redis_version      = "REDIS_7_0"
}
