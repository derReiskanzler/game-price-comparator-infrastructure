resource "kubernetes_role" "frontend_image_checker_role" {
  metadata {
    name = "frontend-image-checker-role"
  }

  rule {
    verbs      = ["get", "list"]
    api_groups = [""]
    resources  = ["pods"]
  }

  rule {
    verbs      = ["get", "list", "update", "patch"]
    api_groups = ["apps"]
    resources  = ["deployments"]
  }
}

resource "kubernetes_role_binding" "frontend_image_checker_rolebinding" {
  metadata {
    name = "frontend-image-checker-rolebinding"
  }

  subject {
    kind = "ServiceAccount"
    name = "default"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "frontend-image-checker-role"
  }
}

resource "kubernetes_cron_job_v1" "frontend_image_checker" {
  metadata {
    name = "frontend-image-checker"
  }

  spec {
    schedule = "*/2 * * * *"

    job_template {
      metadata {}

      spec {
        template {
          metadata {}

          spec {
            container {
              name    = "frontend-image-checker"
              image   = "docker.io/bitnami/kubectl:latest"
              command = ["/bin/bash", "-c", "apt update\napt install -y curl\nDEPLOYMENT_NAME=fe-angular-game-price-comparator-production-deployment\nDOCKER_IMAGE=\"derreiskanzler/fe-angular-game-price-comparator-production\"\nDOCKER_TAG=\"latest\"\nNAMESPACE=default\nCURRENT_DIGEST=$(kubectl get pod -l app=fe-angular-game-price-comparator-production -o=jsonpath='{.items[0].status.containerStatuses[0].imageID}' | cut -d'@' -f2)\nLATEST_DIGEST=$(curl -s https://hub.docker.com/v2/repositories/$${DOCKER_IMAGE}/tags/$${DOCKER_TAG}/ | grep -o '\"digest\":\"[^\"]*')\n\necho --------\necho Current Digest\necho $CURRENT_DIGEST\necho Latest digest\necho $LATEST_DIGEST\necho --------\n\nif [[ \"$LATEST_DIGEST\" != *\"$CURRENT_DIGEST\"* ]]; then\n  echo \"New image version found. Updating the deployment...\"\n  kubectl rollout restart deployment/$DEPLOYMENT_NAME -n $NAMESPACE\n  echo \"Deployment updated successfully.\"\nelse\n  echo \"No new image version found.\"\nfi\n"]

              security_context {
                run_as_user = 0
              }
            }

            restart_policy = "OnFailure"
          }
        }
      }
    }
  }
}