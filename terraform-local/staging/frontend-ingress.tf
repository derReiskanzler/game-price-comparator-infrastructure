resource "kubernetes_ingress_v1" "fe_angular_game_price_comparator_staging_ingress" {
  metadata {
    name = "fe-angular-game-price-comparator-staging-ingress"
  }

  spec {
    ingress_class_name = "nginx"

    rule {
      host = "fe-angular-game-price-comparator.staging.nip.io"

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "fe-angular-game-price-comparator-staging-service"

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