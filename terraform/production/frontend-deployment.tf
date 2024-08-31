resource "kubernetes_deployment" "fe_angular_game_price_comparator_production_deployment" {
  metadata {
    name = "fe-angular-game-price-comparator-production-deployment"

    labels = {
      app = "fe-angular-game-price-comparator-production"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "fe-angular-game-price-comparator-production"
      }
    }

    template {
      metadata {
        labels = {
          app = "fe-angular-game-price-comparator-production"
        }
      }

      spec {
        container {
          name  = "fe-angular-game-price-comparator-production"
          image = "docker.io/derreiskanzler/fe-angular-game-price-comparator-production:latest"

          port {
            container_port = 80
          }

          env {
            name  = "API_BASE_URL"
            value = "http://be-java-game-price-comparator.production.nip.io/api"
          }

          env {
            name  = "ENV"
            value = "production"
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