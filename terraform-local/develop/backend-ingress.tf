resource "kubernetes_ingress_v1" "be_java_game_price_comparator_develop_ingress" {
  metadata {
    name = "be-java-game-price-comparator-develop-ingress"
  }

  spec {
    ingress_class_name = "nginx"

    rule {
      host = "be-java-game-price-comparator.develop.nip.io"

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "be-java-game-price-comparator-develop-service"

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