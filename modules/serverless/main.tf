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

      env {
        name  = "PRODUCT_CATALOG_SERVICE_ADDR"
        value = "productcatalogservice.boutique.svc.cluster.local:3550"
      }

      env {
        name  = "CURRENCY_SERVICE_ADDR"
        value = "currencyservice.boutique.svc.cluster.local:7000"
      }

      env {
        name  = "CART_SERVICE_ADDR"
        value = "cartservice.boutique.svc.cluster.local:7070"
      }

      env {
        name  = "RECOMMENDATION_SERVICE_ADDR"
        value = "recommendationservice.boutique.svc.cluster.local:8080"
      }

      env {
        name  = "SHIPPING_SERVICE_ADDR"
        value = "shippingservice.boutique.svc.cluster.local:50051"
      }

      env {
        name  = "CHECKOUT_SERVICE_ADDR"
        value = "checkoutservice.boutique.svc.cluster.local:5050"
      }

      env {
        name  = "AD_SERVICE_ADDR"
        value = "adservice.boutique.svc.cluster.local:9555"
      }

      env {
        name  = "SHOPPING_ASSISTANT_SERVICE_ADDR"
        value = "shoppingassistantservice.boutique.svc.cluster.local:80"
      }

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

resource "google_cloud_run_v2_service_iam_member" "public_invoker" {
  count    = var.allow_public_frontend ? 1 : 0
  project  = var.project_id
  location = var.region
  name     = google_cloud_run_v2_service.frontend.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "google_cloud_scheduler_job" "frontend_warmup" {
  project   = var.project_id
  region    = var.region
  name      = var.scheduler_job_name
  schedule  = "*/5 * * * *"
  time_zone = "Etc/UTC"

  http_target {
    uri         = "${google_cloud_run_v2_service.frontend.uri}/_healthz"
    http_method = "GET"

    oidc_token {
      service_account_email = google_service_account.scheduler_invoker.email
      audience              = google_cloud_run_v2_service.frontend.uri
    }
  }

  depends_on = [google_cloud_run_v2_service_iam_member.scheduler_invoker]
}
