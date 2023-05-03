# terraform state and required providers
terraform {
  backend "local" {

  }
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.6.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "3.4.0"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }

    google = {
      source  = "hashicorp/google"
      version = "~> 4.55.0"
    }

    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 4.55.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.12.0"
    }
  }
}

provider "google" {
  #credentials = " ${file("../../credentials.json")}"
  project = var.project
  region  = var.region
}

provider "google-beta" {
  project = var.project
  region  = var.region
}


#below is config for helm & kubernetes providers if needed

#When using the kubernetes and helm providers, statically defined credentials can allow you to connect to clusters defined in the same config or in a remote state.
#You can configure either using configuration such as the following:
#provider "kubernetes" {
#  load_config_file = false
#
#  host  = "https://${google_container_cluster.cluster.endpoint}"
#  token = data.google_client_config.provider.access_token
#  cluster_ca_certificate = base64decode(
#    google_container_cluster.cluster.master_auth[0].cluster_ca_certificate,
#  )
#}

#//# We use this data provider to expose an access token for communicating with the GKE cluster.
#
#data "google_client_config" "provider" {}
#
#resource "google_compute_project_metadata" "default" {
#  metadata = {
#    enable-oslogin         = true
#    block-project-ssh-keys = true
#  }
#}
