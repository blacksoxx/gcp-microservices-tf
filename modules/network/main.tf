resource "google_compute_network" "prod_vpc" {
  project                 = var.project_id
  name                    = var.vpc_name
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

resource "google_compute_subnetwork" "gke_subnet" {
  project       = var.project_id
  name          = "gke-subnet"
  ip_cidr_range = var.gke_subnet_cidr
  region        = var.region
  network       = google_compute_network.prod_vpc.id

  secondary_ip_range {
    range_name    = "gke-pods-range"
    ip_cidr_range = var.gke_pods_cidr
  }

  secondary_ip_range {
    range_name    = "gke-services-range"
    ip_cidr_range = var.gke_services_cidr
  }

  private_ip_google_access = true
}

resource "google_compute_subnetwork" "serverless_subnet" {
  project                  = var.project_id
  name                     = "serverless-subnet"
  ip_cidr_range            = var.serverless_subnet_cidr
  region                   = var.region
  network                  = google_compute_network.prod_vpc.id
  private_ip_google_access = true
}

resource "google_compute_global_address" "private_service_access" {
  project       = var.project_id
  name          = "prod-vpc-psa-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.prod_vpc.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.prod_vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_service_access.name]
}

resource "google_compute_router" "nat_router" {
  project = var.project_id
  name    = "prod-nat-router"
  region  = var.region
  network = google_compute_network.prod_vpc.id
}

resource "google_compute_router_nat" "nat" {
  project                            = var.project_id
  name                               = "prod-cloud-nat"
  router                             = google_compute_router.nat_router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

resource "google_vpc_access_connector" "serverless_connector" {
  project       = var.project_id
  name          = "serverless-vpc-connector"
  region        = var.region
  min_instances = 2
  max_instances = var.serverless_connector_max_instances

  subnet {
    name       = google_compute_subnetwork.serverless_subnet.name
    project_id = var.project_id
  }

  depends_on = [google_compute_subnetwork.serverless_subnet]
}
