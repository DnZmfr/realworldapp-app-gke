resource "kubernetes_service" "realworld_backend" {
  metadata {
    name = "realworld-backend"

    labels = {
      app = "realworld-backend"
    }
  }

  spec {
    port {
      protocol = "TCP"
      port     = 3001
    }

    selector = {
      app = "realworld-backend"
    }

    type = "LoadBalancer"
  }
}

resource "kubernetes_deployment" "realworld_backend" {
  metadata {
    name = "realworld-backend"

    labels = {
      app = "realworld-backend"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "realworld-backend"
      }
    }

    template {
      metadata {
        labels = {
          app = "realworld-backend"
        }
      }

      spec {
        container {
          name  = "realworld-backend"
          image = "gcr.io/toptal-realworld-app/realworld-backend"

          port {
            container_port = 3001
            protocol       = "TCP"
          }

          env {
            name  = "BACKEND_URL"
            value = "http://realworld-backend.default.svc.cluster.local:3001"
          }

          env {
            name  = "MONGODB_STORE_CONNECTION_STRING"
            value = "mongodb://test:test@mongodb.default.svc.cluster.local:27017/test"
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

          liveness_probe {
            tcp_socket {
              port = "3001"
            }

            initial_delay_seconds = 15
            period_seconds        = 20
          }

          readiness_probe {
            tcp_socket {
              port = "3001"
            }

            initial_delay_seconds = 5
            period_seconds        = 10
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

