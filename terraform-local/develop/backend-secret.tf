locals {
  env_file_content = file("${path.module}/.env")
  env_vars = {
    for line in split("\n", trimspace(local.env_file_content)) :
    trimspace(split("=", line)[0]) => trimspace(split("=", line)[1])
    if length(trimspace(line)) > 0 && !startswith(trimspace(line), "#")
  }
}

resource "kubernetes_secret" "be-java-game-price-comparator-develop-secret" {
  metadata {
    name      = "be-java-game-price-comparator-develop-secret"
  }

  data = {
    for key, value in local.env_vars : key => value
  }
}