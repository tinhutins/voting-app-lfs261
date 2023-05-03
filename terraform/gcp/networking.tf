# VPC
resource "google_compute_network" "vpc" {
  name = "${var.project}-vpc"
  # default routing mode is regional,  here are informations : https://cloud.google.com/network-connectivity/docs/router/concepts/overview#dynamic-routing-mode
  # routing_mode            = "REGIONAL" 
  auto_create_subnetworks = "false"

  depends_on = [
    google_project_service.apis_needed,
  ]
}
# Subnet
resource "google_compute_subnetwork" "subnet" {
  name                     = "${var.project}-subnet"
  region                   = var.region
  network                  = google_compute_network.vpc.id
  private_ip_google_access = true

  #kubernetes nodes use this ip range
  ip_cidr_range = var.main_ip_cidr_block


  #pods use this ip range
  secondary_ip_range {
    range_name    = "gke-pod-range"
    ip_cidr_range = var.pods_ip_cidr_block
  }

  #services use this ip range
  secondary_ip_range {
    range_name    = "gke-service-range"
    ip_cidr_range = var.service_ip_cidr_block
  }
}

# create cloud router for vms with private IPs to access internet (for example kubernetes nodes will be able to pull docker images)
resource "google_compute_router" "router" {
  name    = "${var.project}-router"
  network = google_compute_network.vpc.id
  region  = var.region
}

# create nat and reference it to a cloud router
resource "google_compute_router_nat" "nat" {
  name                               = "${var.project}-my-router-nat"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }

  depends_on = [
    google_compute_router.router
  ]
}

# allocate static IP to the nat
resource "google_compute_address" "nat_address" {
  name         = "nat-address"
  address_type = "EXTERNAL"
  network_tier = "PREMIUM"

  depends_on = [
    google_project_service.apis_needed
  ]
}

# example firewall rule to allow SSH within VPC
resource "google_compute_firewall" "allow-ssh" {
  name    = "allow-ssh"
  network = google_compute_network.vpc.name
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow-ftp" {
  name    = "allow-ftp"
  network = google_compute_network.vpc.name
  allow {
    protocol = "tcp"
    ports    = ["21"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow-something" {
  name    = "allow-something"
  network = google_compute_network.vpc.name
  allow {
    protocol = "tcp"
    ports    = ["22222"]
  }

  source_ranges = ["0.0.0.0/0"]
}