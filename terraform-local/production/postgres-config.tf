resource "kubernetes_config_map" "postgres_config" {
  metadata {
    name = "postgres-config"
  }

  data = {
    postgres-db  = "gameforum"
    postgres-url = "postgres-service"
  }
}