/*************************
      VOLUME CLAIMS
 *************************/
resource "kubernetes_persistent_volume_claim" "mongodb_pvc" {
  depends_on = [module.gke]
  timeouts {
    create = "3m"
  }
  metadata {
    name = "mongodb-pvc"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }
}

/*************************
     CONFIG MAPS
 *************************/
resource "kubernetes_config_map" "mongodb_configmap" {
  depends_on = [
    kubernetes_persistent_volume_claim.mongodb_pvc,
  ]
  metadata {
    name = "mongodb-configmap"
  }
  data = {
    "mongo-init.js" = "db.createUser({\n  user: 'test',\n  pwd: 'test',\n  roles: [{role: 'readWrite', db: 'test'}]\n});\n"
  }
}

/*************************
     SECRETS
 *************************/
resource "kubernetes_secret" "jwt_secret" {
  depends_on = [
    kubernetes_persistent_volume_claim.mongodb_pvc,
  ]
  metadata {
    name = "jwt-secret"
  }
  data = {
    JWT_SECRET = var.jwt_secret
  }
  type = "Opaque"
}

resource "kubernetes_secret" "mongodb_passwd" {
  depends_on = [
    kubernetes_persistent_volume_claim.mongodb_pvc,
  ]
  metadata {
    name = "mongodb-passwd"
  }
  data = {
    DB_PASSWORD = var.mongodb_pass
  }
  type = "Opaque"
}

/*************************
     SERVICES
 *************************/
resource "kubernetes_service" "mongodb" {
  depends_on = [module.gke]
  timeouts {
    create = "3m"
  }
  metadata {
    name = "mongodb"
    labels = {
      app = "mongodb"
    }
  }
  spec {
    port {
      port = 27017
    }
    selector = {
      app = "mongodb"
    }
    type = "NodePort"
  }
}

resource "kubernetes_service" "realworld_backend" {
  depends_on = [module.gke]
  timeouts {
    create = "3m"
  }
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

resource "kubernetes_service" "realworld_frontend" {
  depends_on = [module.gke]
  timeouts {
    create = "3m"
  }
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

/*************************
     DEPLOYMENTS
 *************************/
resource "kubernetes_deployment" "mongodb" {
  depends_on = [
    kubernetes_secret.mongodb_passwd,
    kubernetes_config_map.mongodb_configmap,
    kubernetes_persistent_volume_claim.mongodb_pvc,
    kubernetes_service.mongodb,
  ]
  metadata {
    name = "mongodb"
    labels = {
      app = "mongodb"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "mongodb"
      }
    }
    template {
      metadata {
        labels = {
          app = "mongodb"
        }
      }
      spec {
        volume {
          name = "mongodb-data-volume"
          persistent_volume_claim {
            claim_name = "mongodb-pvc"
          }
        }
        volume {
          name = "mongodb-init-volume"
          config_map {
            name = "mongodb-configmap"
          }
        }
        container {
          name  = "mongodb"
          image = "mongo:4"
          port {
            container_port = 27017
            protocol       = "TCP"
          }
          env {
            name  = "MONGO_INITDB_ROOT_USERNAME"
            value = "test"
          }
          env {
            name = "MONGO_INITDB_ROOT_PASSWORD"
            value_from {
              secret_key_ref {
                name = "mongodb-passwd"
                key  = "DB_PASSWORD"
              }
            }
          }
          volume_mount {
            name       = "mongodb-data-volume"
            mount_path = "/data/db"
          }
          volume_mount {
            name       = "mongodb-init-volume"
            mount_path = "/docker-entrypoint-initdb.d"
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

resource "kubernetes_deployment" "realworld_backend" {
  depends_on = [
    kubernetes_deployment.mongodb,
    kubernetes_service.realworld_backend,
  ]
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

resource "kubernetes_deployment" "realworld_frontend" {
  depends_on = [
    kubernetes_deployment.realworld_backend,
    kubernetes_service.realworld_frontend,
  ]
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
            value = "http://${kubernetes_service.realworld_backend.load_balancer_ingress[0].ip}:3001"
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

