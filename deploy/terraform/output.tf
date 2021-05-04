output "cluster_name" {
  description = "Cluster name"
  value       = module.gke.name
}

output "service_account" {
  description = "IP address of the Frontend Service"
  value       = module.gke.service_account
}
output "backend_ip" {
  description = "IP address of the Backend Service"
  value       = kubernetes_service.realworld_backend.status.0.load_balancer.0.ingress.0.ip
}

output "frontend_ip" {
  description = "IP address of the Frontend Service"
  value       = kubernetes_service.realworld_frontend.status.0.load_balancer.0.ingress.0.ip
}
