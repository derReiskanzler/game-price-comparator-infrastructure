resource "kubernetes_service" "fe_angular_game_price_comparator_staging_service" {
  metadata {
    name = "fe-angular-game-price-comparator-staging-service"
  }

  spec {
    port {
      protocol    = "TCP"
      port        = 80
      target_port = "80"
    }

    selector = {
      app = "fe-angular-game-price-comparator-staging"
    }

    type = "LoadBalancer"
  }
}