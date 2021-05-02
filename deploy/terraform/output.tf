output "cluster_name" {
  description = "Cluster name"
  value       = module.gke.name
}

output "backend_ingress_ip" {
  description = "Ingress IP address of backend service"
  value       = kubernetes_service.${var.backend_service_name}.status[0].load_balancer[0].ingress[0].ip
}
