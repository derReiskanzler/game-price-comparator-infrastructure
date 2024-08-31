resource "kubernetes_ingress_v1" "fe_angular_game_price_comparator_develop_ingress" {
  metadata {
    name = "fe-angular-game-price-comparator-develop-ingress"
  }

  spec {
    ingress_class_name = "nginx"

    rule {
      host = "fe-angular-game-price-comparator.develop.nip.io"

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "fe-angular-game-price-comparator-develop-service"

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