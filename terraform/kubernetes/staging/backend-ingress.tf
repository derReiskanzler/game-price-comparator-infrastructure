resource "kubernetes_ingress_v1" "be_java_game_price_comparator_staging_ingress" {
  metadata {
    name = "be-java-game-price-comparator-staging-ingress"
  }

  spec {
    ingress_class_name = "nginx"

    rule {
      host = "be-java-game-price-comparator.staging.nip.io"

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "be-java-game-price-comparator-staging-service"

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