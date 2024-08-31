resource "kubernetes_deployment" "postgres_deployment" {
  metadata {
    name = "postgres-deployment"

    labels = {
      app = "postgres"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "postgres"
      }
    }

    template {
      metadata {
        labels = {
          app = "postgres"
        }
      }

      spec {
        volume {
          name = "postgres-storage"

          persistent_volume_claim {
            claim_name = "postgres-claim"
          }
        }

        container {
          name  = "container-pg"
          image = "docker.io/library/postgres:latest"

          port {
            container_port = 5432
          }

          env {
            name = "POSTGRES_PASSWORD"

            value_from {
              secret_key_ref {
                name = "postgres-secret"
                key  = "postgres-password"
              }
            }
          }

          env {
            name = "POSTGRES_USER"

            value_from {
              secret_key_ref {
                name = "postgres-secret"
                key  = "postgres-user"
              }
            }
          }

          env {
            name = "POSTGRES_DB"

            value_from {
              config_map_key_ref {
                name = "postgres-config"
                key  = "postgres-db"
              }
            }
          }

          env {
            name  = "PGDATA"
            value = "/data/pgdata"
          }

          resources {
            limits = {
              cpu    = "500m"
              memory = "1Gi"
            }
          }

          volume_mount {
            name       = "postgres-storage"
            mount_path = "/data"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "postgres_service" {
  metadata {
    name = "postgres-service"
  }

  spec {
    port {
      protocol    = "TCP"
      port        = 5432
      target_port = "5432"
    }

    selector = {
      app = "postgres"
    }
  }
}

resource "kubernetes_persistent_volume_claim" "postgres_claim" {
  metadata {
    name = "postgres-claim"
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