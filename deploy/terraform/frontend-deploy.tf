resource "kubernetes_service" "realworld_frontend" {
  metadata {
    name = "realworld-frontend"
  }

  spec {
    port {
      protocol    = "TCP"
      port        = 80
      target_port = "3002"
    }

    selector = {
      app = "realworld-frontend"
    }

    type = "LoadBalancer"
  }
}

resource "kubernetes_deployment" "realworld_frontend" {
  metadata {
    name = "realworld-frontend"

    labels = {
      app = "realworld-frontend"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "realworld-frontend"
      }
    }

    template {
      metadata {
        labels = {
          app = "realworld-frontend"
        }
      }

      spec {
        container {
          name  = "realworld-frontend"
          image = "gcr.io/toptal-realworld-app/realworld-frontend"

          port {
            container_port = 3002
            protocol       = "TCP"
          }

          env {
            name  = "BACKEND_URL"
            value = "http://realworld-backend.default.svc.cluster.local:3001"
          }

          env {
            name  = "FRONTEND_URL"
            value = "http://realworld-frontend.default.svc.cluster.local:3002"
          }

          env {
            name = "JWT_SECRET"

            value_from {
              secret_key_ref {
                name = "jwt-secret"
                key  = "JWT_SECRET"
              }
            }
          }

          image_pull_policy = "Always"
        }
      }
    }

    strategy {
      type = "RollingUpdate"

      rolling_update {
        max_unavailable = "25%"
        max_surge       = "25%"
      }
    }
  }
}

