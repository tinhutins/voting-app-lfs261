output "kubernetes_cluster_host" {
  value       = google_container_cluster.cratis-test-cluster.endpoint
  description = "GKE Cluster Host"
}