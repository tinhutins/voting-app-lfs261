# Project variables

variable "region" {
  type        = string
  description = "K8s cluster host region."
}
variable "zone" {
  type        = string
  description = "K8s cluster host zone."
}

variable "zone_backup" {
  type        = string
  description = "K8s cluster host additional zone."
}
variable "project" {
  type        = string
  description = "ID of the Google project the K8s cluster is hosted on."
}

# Define variables for Vms
variable "machine_type" {
  default = "n1-standard-1"
}

variable "image" {
  default = "ubuntu-os-cloud/ubuntu-2004-lts"
}


# Cluster variables

variable "cluster_name" {
  type        = string
  description = "Name of the K8s cluster."
}
variable "cluster_release_channel_channel" {
  type        = string
  description = "GKE release channel."
}


# Node pool variables
variable "node_pool_name" {
  type = string
}
variable "node_pool_location" {
  type = string
}
variable "node_pool_node_count" {
  type = number
}
variable "node_pool_node_config_machine_type" {
  type = string
}
variable "node_pool_node_config_image_type" {
  type = string
}
variable "node_pool_node_config_disk_type" {
  type = string
}
variable "node_pool_node_config_disk_size_gb" {
  type = string
}

# gitlab variables

# variable "remote_state_address" {
#   type        = string
#   description = "Gitlab remote state file address"
# }

# variable "remote_state_address_unlock" {
#   type        = string
#   description = "Gitlab remote state file address unlock"
# }

# variable "remote_state_address_lock" {
#   type        = string
#   description = "Gitlab remote state file address lock"
# }

# variable "username" {
#   type        = string
#   description = "Gitlab username to query remote state"
# }

# variable "access_token" {
#   type        = string
#   description = "GitLab access token to query remote state"
# }

# Networking variables

variable "master_ipv4_cidr_block" {
  description = "The IP range in CIDR notation (size must be /28) to use for the hosted master network. This range will be used for assigning internal IP addresses to the master or set of masters, as well as the ILB VIP. This range must not overlap with any other ranges in use within the cluster's network."
  type        = string
  default     = "10.5.0.0/28"
}

# For the example, we recommend a /16 network for the VPC. Note that when changing the size of the network,
# you will have to adjust the 'cidr_subnetwork_width_delta' in the 'vpc_network' -module accordingly.
variable "main_ip_cidr_block" {
  description = "The IP address range of the VPC in CIDR notation. A prefix of /16 is recommended. Do not use a prefix higher than /27."
  type        = string
}

variable "pods_ip_cidr_block" {
  type = string
}

variable "service_ip_cidr_block" {
  type = string
}