resource "google_container_cluster" "cratis-test-cluster" {
  provider = google-beta
  name     = var.cluster_name

  #If you specify a zone (such as us-central1-a), the cluster will be a zonal cluster with a single cluster master. If you specify a region (such as us-west1), the cluster will be a regional cluster with multiple masters spread across zones in the region, and with default node locations in those zones as well

  # in a regional cluster, cluster master nodes are present in multiple zones in the region. For that reason, regional clusters should be preferred.

  location = var.zone

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  initial_node_count       = 1
  remove_default_node_pool = true

  release_channel {
    channel = var.cluster_release_channel_channel
  }

  enable_shielded_nodes = true

  # this costs additional money, if we plan to deploy seperate prometheus disable monitoring for example
  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"

  # we are creating vpc-native cluster, benefits of it : https://cloud.google.com/kubernetes-engine/docs/concepts/alias-ips
  networking_mode = "VPC_NATIVE"


  #include node_locations for multi-zonal cluster, not needed when regional cluster set up
  node_locations = [var.zone_backup]

  network    = google_compute_network.vpc.id
  subnetwork = google_compute_subnetwork.subnet.id

  ip_allocation_policy {
    cluster_secondary_range_name  = "gke-pod-range"
    services_secondary_range_name = "gke-service-range"
  }

  #make cluster private if needed

  # private_cluster_config {
  #   enable_private_nodes    = true
  #   enable_private_endpoint = false
  #   master_ipv4_cidr_block  = "172.16.0.0/28"

  # }

  workload_identity_config {
    workload_pool = "${var.project}.svc.id.goog"
  }

  addons_config {
    dns_cache_config {
      enabled = true
    }
  }
  vertical_pod_autoscaling {
    enabled = true
  }
  lifecycle {
    ignore_changes = [
      # Since we provide `remove_default_node_pool = true`, the `node_config` is only relevant for a valid construction of
      # the GKE cluster in the initial creation. As such, any changes to the `node_config` should be ignored.
      node_config,
    ]
  }
}
# Separately Managed Node Pool with autoscaling which is recommended by google
resource "google_container_node_pool" "node-pool-cratis-test" {
  project            = var.project
  name               = "${google_container_cluster.cratis-test-cluster.name}-node-pool"
  location           = var.node_pool_location
  cluster            = google_container_cluster.cratis-test-cluster.name
  initial_node_count = var.node_pool_node_count

  autoscaling {
    min_node_count = "1"
    max_node_count = "2"
  }

  #automatic node upgrades and repairs
  management {
    auto_repair  = "true"
    auto_upgrade = "true"
  }
  node_config {
    machine_type = var.node_pool_node_config_machine_type
    image_type   = var.node_pool_node_config_image_type
    disk_type    = var.node_pool_node_config_disk_type
    disk_size_gb = var.node_pool_node_config_disk_size_gb

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.sa-terraform.email


    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only"
    ]

    labels = {
      env      = var.project
      hostname = "${google_container_cluster.cratis-test-cluster.name}-node"
    }

    # autoscaling nodes must have taints to avoid accidental scheduling
    # taint {
    # key    = "instance_type"
    # value  = "spot"
    # effect = "NoSchedule"
    # }
  }
}
