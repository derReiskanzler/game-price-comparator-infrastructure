resource "kubernetes_service" "fe_angular_game_price_comparator_develop_service" {
  metadata {
    name = "fe-angular-game-price-comparator-develop-service"
  }

  spec {
    port {
      protocol    = "TCP"
      port        = 80
      target_port = "80"
    }

    selector = {
      app = "fe-angular-game-price-comparator-develop"
    }

    type = "LoadBalancer"
  }
}