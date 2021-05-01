resource "kubernetes_service" "mongodb" {
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

resource "kubernetes_deployment" "mongodb" {
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
            claim_name = "mongodb-volume-claim"
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

