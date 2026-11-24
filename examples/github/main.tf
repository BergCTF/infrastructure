terraform {
  required_version = ">= 1.11.0"

  required_providers {
    github = {
      source  = "integrations/github"
      version = ">= 6.0"
    }
  }
}

variable "github_owner" {
  type        = string
  description = "GitHub organization or account that owns the repositories."
}

variable "repositories" {
  type = object({
    infrastructure = string
    challenges     = optional(string)
  })
  description = "Repository names within the GitHub owner."
}

variable "deploy_key_title" {
  type        = string
  description = "Title used for this environment's deploy keys."
}

variable "argocd_url" {
  type        = string
  description = "Base URL of the Argo CD server."
}

provider "github" {
  owner = var.github_owner
}

locals {
  repositories = distinct(compact([var.repositories.infrastructure, var.repositories.challenges]))
}

module "github" {
  source = "../../modules/github"

  argocd_url      = var.argocd_url
  argocd_webhooks = local.repositories
  generate_deploy_keys = [
    for repository in local.repositories : {
      repository = repository
      title      = var.deploy_key_title
    }
  ]
}

output "git_credentials" {
  description = "Pass this object to the infrastructure stack's git_credentials input."
  sensitive   = true
  value = {
    infra_deploy_key = module.github.generated_deploy_keys["${var.repositories.infrastructure}-${var.deploy_key_title}"].private_key_openssh
    challenge_deploy_key = var.repositories.challenges == null ? null : (
      module.github.generated_deploy_keys["${var.repositories.challenges}-${var.deploy_key_title}"].private_key_openssh
    )
    argocd_webhook_secret = module.github.argocd_webhook_secret
  }
}
