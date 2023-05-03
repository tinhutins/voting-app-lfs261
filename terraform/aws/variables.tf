# Project variables

variable "region" {
  type        = string
  description = "EKS cluster host region."
}

# eks variables
variable "cluster_name" {
  type = string
}
variable "addons" {
  type = list(object({
    name    = string
    version = string
  }))

  default = [
    {
      # Enable service networking within your cluster.
      name    = "kube-proxy"
      version = "v1.25.6-eksbuild.2"
    },
    {
      # Enable pod networking within your cluster.
      name    = "vpc-cni"
      version = "v1.12.5-eksbuild.2"
    },
    {
      # Enable service discovery within your cluster.
      name    = "coredns"
      version = "v1.9.3-eksbuild.2"
    },
  ]
}



# Node pool variables
variable "node_pool_name" {
  type = string
}
variable "node_pool_node_count" {
  type = number
}
variable "node_pool_ami_type" {
  type = string
}
variable "capacity_type" {
  type = string
}
variable "node_pool_instance_type" {
}
variable "node_pool_disk_size_gb" {
  type = string
}

# network variables
variable "main_vpc_cidr" {
  type = string
}
variable "private-eu-central-1a_cidr" {
  type = string
}

variable "private-eu-central-1b_cidr" {
  type = string
}

variable "public-eu-central-1a_cidr" {
  type = string
}

variable "public-eu-central-1b_cidr" {
  type = string
}
variable "av_zone-1a" {
  type = string
}

variable "av_zone-1b" {
  type = string
}
