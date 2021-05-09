output "cluster_name" {
  description = "Cluster name"
  value       = module.gke.name
}

output "service_account" {
  description = "Service account name"
  value       = module.gke.service_account
}

