terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 5.54.1"
        }
        ansible = {
            source  = "ansible/ansible"
            version = "~> 1.3.0"
        }
    }
}

provider "aws" {
  region = "us-east-1"
}
