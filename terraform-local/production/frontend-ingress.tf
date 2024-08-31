resource "kubernetes_ingress_v1" "fe_angular_game_price_comparator_production_ingress" {
  metadata {
    name = "fe-angular-game-price-comparator-production-ingress"
  }

  spec {
    ingress_class_name = "nginx"

    rule {
      host = "fe-angular-game-price-comparator.production.nip.io"

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "fe-angular-game-price-comparator-production-service"

              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}