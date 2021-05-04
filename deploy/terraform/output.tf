output "cluster_name" {
  description = "Cluster name"
  value       = module.gke.name
}

output "service_account" {
  description = "Service account name"
  value       = module.gke.service_account
}

output "backend_ip" {
  description = "IP address of Backend Service"
  value       = kubernetes_service.realworld_backend.load_balancer_ingress[0].ip
}

output "frontend_ip" {
  description = "IP address of Frontend Service"
  value       = kubernetes_service.realworld_frontend.load_balancer_ingress[0].ip
}
