resource "kubernetes_deployment" "be_java_game_price_comparator_staging_deployment" {
  depends_on = [kubernetes_service.postgres_service]
  metadata {
    name = "be-java-game-price-comparator-staging-deployment"

    labels = {
      app = "be-java-game-price-comparator-staging"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "be-java-game-price-comparator-staging"
      }
    }

    template {
      metadata {
        labels = {
          app = "be-java-game-price-comparator-staging"
        }
      }

      spec {
        container {
          name  = "be-java-game-price-comparator-staging"
          image = "docker.io/kkkira/game-price-comparator-staging:latest"

          port {
            container_port = 8080
          }

          env_from {
            secret_ref {
              name = "be-java-game-price-comparator-staging-secret"
            }
          }

          env {
            name = "POSTGRES_URL"

            value_from {
              config_map_key_ref {
                name = "postgres-config"
                key  = "postgres-url"
              }
            }
          }

          env {
            name  = "FRONTEND_URL"
            value = "http://fe-angular-game-price-comparator.staging.nip.io"
          }

          resources {
            limits = {
              cpu = "700m"
            }
          }

          readiness_probe {
            http_get {
              path = "/api/v1/health"
              port = "8080"
            }

            initial_delay_seconds = 20
            timeout_seconds       = 5
            period_seconds        = 30
          }

          image_pull_policy = "Always"
        }
      }
    }

    strategy {
      type = "RollingUpdate"

      rolling_update {
        max_unavailable = "1"
        max_surge       = "1"
      }
    }
  }
}

resource "kubernetes_service" "be_java_game_price_comparator_staging_service" {
  depends_on = [kubernetes_service.postgres_service]
  metadata {
    name = "be-java-game-price-comparator-staging-service"
  }

  spec {
    port {
      protocol    = "TCP"
      port        = 8080
      target_port = "8080"
    }

    selector = {
      app = "be-java-game-price-comparator-staging"
    }

    type = "LoadBalancer"
  }
}