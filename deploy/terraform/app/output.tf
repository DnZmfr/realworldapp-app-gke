output "backend_ip" {
  description = "IP address of Backend Service"
  value       = kubernetes_service.realworld_backend.status.0.load_balancer.0.ingress.0.ip
}

output "frontend_ip" {
  description = "IP address of Frontend Service"
  value       = kubernetes_service.realworld_frontend.status.0.load_balancer.0.ingress.0.ip
}
