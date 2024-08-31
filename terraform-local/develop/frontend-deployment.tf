resource "kubernetes_deployment" "fe_angular_game_price_comparator_develop_deployment" {
  metadata {
    name = "fe-angular-game-price-comparator-develop-deployment"

    labels = {
      app = "fe-angular-game-price-comparator-develop"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "fe-angular-game-price-comparator-develop"
      }
    }

    template {
      metadata {
        labels = {
          app = "fe-angular-game-price-comparator-develop"
        }
      }

      spec {
        container {
          name  = "fe-angular-game-price-comparator-develop"
          image = "docker.io/derreiskanzler/fe-angular-game-price-comparator-develop:latest"

          port {
            container_port = 80
          }

          env {
            name  = "API_BASE_URL"
            value = "http://be-java-game-price-comparator.develop.nip.io/api"
          }

          env {
            name  = "ENV"
            value = "develop"
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