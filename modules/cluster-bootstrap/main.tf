terraform {
  # required for "enabled" blocks
  required_version = ">= 1.11.0"
  required_providers {
    random = {
      source = "hashicorp/random"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 3.0.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 3.0.0"
    }
  }
}
