locals {
  env_vars = { for line in file("${path.module}/.env") : split("=", line)[0] => split("=", line)[1] }
}

resource "kubernetes_secret" "be-java-game-price-comparator-develop-secret" {
  metadata {
    name      = "be-java-game-price-comparator-develop-secret"
  }

  data = {
    for key, value in local.env_vars : key => base64encode(value)
  }
}