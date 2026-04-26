locals {
  required_services = [
    "compute.googleapis.com",
    "container.googleapis.com",
    "artifactregistry.googleapis.com",
    "servicenetworking.googleapis.com",
    "vpcaccess.googleapis.com",
    "run.googleapis.com",
    "sqladmin.googleapis.com",
    "redis.googleapis.com",
    "cloudscheduler.googleapis.com",
    "iam.googleapis.com"
  ]
}

resource "google_project_service" "required" {
  for_each           = toset(local.required_services)
  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}

module "network" {
  source     = "./modules/network"
  project_id = var.project_id
  region     = var.region

  depends_on = [google_project_service.required]
}

module "gke" {
  source               = "./modules/gke"
  project_id           = var.project_id
  region               = var.region
  cluster_name         = var.cluster_name
  network_self_link    = module.network.vpc_self_link
  subnetwork_self_link = module.network.gke_subnet_self_link
  pods_range_name      = module.network.gke_pods_range_name
  services_range_name  = module.network.gke_services_range_name
  disk_zone            = var.disk_zone

  depends_on = [module.network]
}

resource "terraform_data" "boutique_manifests" {
  count = var.deploy_boutique_manifests ? 1 : 0

  triggers_replace = [
    var.project_id,
    var.region,
    var.cluster_name,
    var.boutique_namespace,
    var.boutique_manifest_url
  ]

  provisioner "local-exec" {
    command = <<-EOT
      set -e
      gcloud container clusters get-credentials ${var.cluster_name} --region ${var.region} --project ${var.project_id}
      kubectl get namespace ${var.boutique_namespace} >/dev/null 2>&1 || kubectl create namespace ${var.boutique_namespace}
      kubectl apply -n ${var.boutique_namespace} -f ${var.boutique_manifest_url}
    EOT
    interpreter = ["/bin/bash", "-c"]
  }

  depends_on = [module.gke]
}

resource "kubernetes_storage_class_v1" "stateful_sc" {
  metadata {
    name = "boutique-stateful-sc"
  }

  storage_provisioner    = "pd.csi.storage.gke.io"
  reclaim_policy         = "Retain"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = true

  parameters = {
    type = "pd-standard"
  }

  depends_on = [module.gke]
}

module "database" {
  source                = "./modules/database"
  project_id            = var.project_id
  region                = var.region
  network_self_link     = module.network.vpc_self_link
  cloud_sql_instance_id = "boutique-postgres"
  redis_instance_id     = "boutique-redis"

  depends_on = [module.network]
}

module "serverless" {
  count              = var.deploy_cloud_run_frontend ? 1 : 0
  source             = "./modules/serverless"
  project_id         = var.project_id
  region             = var.region
  vpc_connector_id   = module.network.serverless_vpc_connector_id
  cloud_run_service  = "boutique-frontend"
  scheduler_job_name = "frontend-warmup"
  frontend_image     = var.frontend_image
  allow_public_frontend = var.allow_public_frontend

  depends_on = [module.network]
}
