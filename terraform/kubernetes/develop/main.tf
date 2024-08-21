terraform {
    required_providers {
    aws = {
        source  = "hashicorp/aws"
        version = "~> 5.54.1"
    }
    kubernetes = {
        source  = "hashicorp/kubernetes"
        version = "~> 2.32.0"
    }
    kubectl = {
        source = "gavinbunney/kubectl"
        version = "~> 1.14.0"
    }
  }
}