resource "kubernetes_ingress_v1" "be_java_game_price_comparator_production_ingress" {
  metadata {
    name = "be-java-game-price-comparator-production-ingress"
  }

  spec {
    ingress_class_name = "nginx"

    rule {
      host = "be-java-game-price-comparator.production.nip.io"

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "be-java-game-price-comparator-production-service"

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