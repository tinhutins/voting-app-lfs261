# Project variables
project     = "test-ci-cd-379808"
region      = "europe-central2"
zone        = "europe-central2-a"
zone_backup = "europe-central2-b"

# Cluster variables
cluster_name                    = "cratis-test-gke"
cluster_release_channel_channel = "STABLE"


# Node pool variables
node_pool_name                     = "node-pool-1"
node_pool_location                 = "europe-central2-a"
node_pool_node_count               = 1
node_pool_node_config_machine_type = "e2-medium"
#node_pool_node_config_image_type   = "COS_CONTAINERD"
node_pool_node_config_image_type   = "UBUNTU_CONTAINERD"
node_pool_node_config_disk_type    = "pd-standard"
node_pool_node_config_disk_size_gb = "30"


# Networking variables

main_ip_cidr_block    = "10.10.0.0/18"
pods_ip_cidr_block    = "10.48.0.0/22"
service_ip_cidr_block = "10.52.0.0/24"
