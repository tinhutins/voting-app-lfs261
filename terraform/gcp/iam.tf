# create a service account and keys for auth
resource "google_service_account" "sa-terraform" {
  account_id   = "sa-terraform"
  display_name = "Service Account for Terraform"
  project      = var.project
}

resource "google_service_account_key" "mykey" {
  service_account_id = google_service_account.sa-terraform.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}

#create private_key file that will be used in Ansible/roles/gcp_argo/files/credentials.json

resource "local_file" "myaccountjson" {
  content = base64decode(google_service_account_key.mykey.private_key)
  #filename = "${path.module}/credentials.json"
  filename = "../../../credentials.json"
}

# add needed roles to terraform_service_account
resource "google_project_iam_member" "sa-terraform" {
  for_each = toset([
    "roles/container.admin",
    "roles/compute.admin",
    "roles/storage.admin",
    "roles/serviceusage.serviceUsageAdmin",
  ])
  role    = each.key
  member  = "serviceAccount:${google_service_account.sa-terraform.email}"
  project = var.project
}

# APIs needed to be enabled for GKE to work
resource "google_project_service" "apis_needed" {
  for_each = toset([
    "compute.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "cloudbuild.googleapis.com",
    "container.googleapis.com",

  ])

  service = each.key

  project            = var.project
  disable_on_destroy = false
}



