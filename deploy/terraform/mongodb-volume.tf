resource "kubernetes_persistent_volume_claim" "mongodb_volume_claim" {
  metadata {
    name = "mongodb-volume-claim"
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

