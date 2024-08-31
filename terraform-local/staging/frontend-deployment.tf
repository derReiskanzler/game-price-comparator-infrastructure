resource "kubernetes_deployment" "fe_angular_game_price_comparator_staging_deployment" {
  metadata {
    name = "fe-angular-game-price-comparator-staging-deployment"

    labels = {
      app = "fe-angular-game-price-comparator-staging"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "fe-angular-game-price-comparator-staging"
      }
    }

    template {
      metadata {
        labels = {
          app = "fe-angular-game-price-comparator-staging"
        }
      }

      spec {
        container {
          name  = "fe-angular-game-price-comparator-staging"
          image = "docker.io/derreiskanzler/fe-angular-game-price-comparator-staging:latest"

          port {
            container_port = 80
          }

          env {
            name  = "API_BASE_URL"
            value = "http://be-java-game-price-comparator.staging.nip.io/api"
          }

          env {
            name  = "ENV"
            value = "staging"
          }

          resources {
            limits = {
              cpu    = "500m"
              memory = "256Mi"
            }
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