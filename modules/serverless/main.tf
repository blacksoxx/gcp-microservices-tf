resource "google_service_account" "scheduler_invoker" {
  project      = var.project_id
  account_id   = "scheduler-run-invoker"
  display_name = "Cloud Scheduler Cloud Run Invoker"
}

resource "google_cloud_run_v2_service" "frontend" {
  project  = var.project_id
  name     = var.cloud_run_service
  location = var.region
  deletion_protection = false

  template {
    containers {
      image = var.frontend_image

      ports {
        container_port = 8080
      }
    }

    vpc_access {
      connector = var.vpc_connector_id
      egress    = "ALL_TRAFFIC"
    }
  }

  ingress = "INGRESS_TRAFFIC_ALL"
}

resource "google_cloud_run_v2_service_iam_member" "scheduler_invoker" {
  project  = var.project_id
  location = var.region
  name     = google_cloud_run_v2_service.frontend.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.scheduler_invoker.email}"
}

resource "google_cloud_scheduler_job" "frontend_warmup" {
  project   = var.project_id
  region    = var.region
  name      = var.scheduler_job_name
  schedule  = "*/5 * * * *"
  time_zone = "Etc/UTC"

  http_target {
    uri         = google_cloud_run_v2_service.frontend.uri
    http_method = "GET"

    oidc_token {
      service_account_email = google_service_account.scheduler_invoker.email
      audience              = google_cloud_run_v2_service.frontend.uri
    }
  }

  depends_on = [google_cloud_run_v2_service_iam_member.scheduler_invoker]
}
