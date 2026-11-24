terraform {
  # required for "enabled" blocks
  required_version = ">= 1.11.0"

  required_providers {
    authentik = {
      source  = "goauthentik/authentik"
      version = ">= 2025.10.1"
    }

    github = {
      source  = "integrations/github"
      version = ">= 6.0"
    }
  }
}

locals {
  github_repositories = [
    for url in concat([var.cluster.infra_repo.url], var.berg.enabled ? [var.berg.challenge_repo] : []) :
    trimsuffix(reverse(split("/", url))[0], ".git")
  ]
  deploy_key_title = "${var.governance_name}-${var.env}-argocd-credential"
  infra_deploy_key = var.github_enabled ? module.github.generated_deploy_keys["${local.github_repositories[0]}-${local.deploy_key_title}"].private_key_openssh : var.git_credentials.infra_deploy_key
  challenge_deploy_key = !var.berg.enabled ? null : (
    var.github_enabled ? module.github.generated_deploy_keys["${local.github_repositories[1]}-${local.deploy_key_title}"].private_key_openssh : var.git_credentials.challenge_deploy_key
  )
}

module "github" {
  source = "./modules/github"

  lifecycle {
    enabled = var.github_enabled
  }

  providers = {
    github = github
  }

  generate_deploy_keys = [
    for repository in local.github_repositories : {
      title      = local.deploy_key_title
      repository = repository
      read_only  = true
    }
  ]

  argocd_url      = "https://argocd.${var.cluster.domain}"
  argocd_webhooks = local.github_repositories
}

module "cluster" {
  source = "./modules/cluster"

  env             = var.env
  governance_name = var.governance_name
  cluster_domain  = var.cluster.domain
  hetzner_token   = var.hetzner_token

  kube_api_loadbalancer_enabled              = var.cluster.kube_api_loadbalancer_enabled
  cluster_allow_scheduling_on_control_planes = var.cluster.cluster_allow_scheduling_on_control_planes

  control_plane_pools = var.cluster.control_plane_pools
  worker_pools        = var.cluster.worker_pools

  bare_metal_nodepools      = var.cluster.bare_metal_nodepools
  bare_metal_config_patches = var.cluster.bare_metal_config_patches
  hcloud_vswitch_id         = var.cluster.hcloud_vswitch_id
  hcloud_robot_user         = var.hcloud_robot_user
  hcloud_robot_password     = var.hcloud_robot_password
}

provider "kubernetes" {
  host                   = module.cluster.kubeconfig.server
  client_certificate     = module.cluster.kubeconfig.cert
  client_key             = module.cluster.kubeconfig.key
  cluster_ca_certificate = module.cluster.kubeconfig.ca
}

provider "helm" {
  kubernetes = {
    host                   = module.cluster.kubeconfig.server
    client_certificate     = module.cluster.kubeconfig.cert
    client_key             = module.cluster.kubeconfig.key
    cluster_ca_certificate = module.cluster.kubeconfig.ca
  }
}

module "cluster_bootstrap" {
  source     = "./modules/cluster-bootstrap"
  depends_on = [module.cluster, module.github]

  env             = var.env
  governance_name = var.governance_name

  infra_repo            = var.cluster.infra_repo.url
  infra_repo_path       = var.cluster.infra_repo.path
  infra_repo_deploy_key = local.infra_deploy_key
  argocd_webhook_secret = var.github_enabled ? module.github.argocd_webhook_secret : null
  git_ssh_known_hosts   = var.git_ssh_known_hosts

  berg         = merge({ challenge_repo_deploy_key = local.challenge_deploy_key }, var.berg)
  monitoring   = var.monitoring
  authentik    = var.authentik
  cert_manager = var.cert_manager
  external_dns = var.external_dns

  dns_api_token = var.dns_api_token

  email_enabled  = var.authentik.smtp.enabled
  email_username = var.authentik.smtp.username
  email_password = var.authentik.smtp.password

  discord_client_id     = var.discord_client_id
  discord_client_secret = var.discord_client_secret
  discord_bot_token     = var.berg.discord_bot_token
}

provider "authentik" {
  url   = var.authentik.enabled ? "https://${var.authentik.domain}" : null
  token = module.cluster_bootstrap.authentik_bootstrap_token
}

module "authentik" {
  source = "./modules/authentik"

  lifecycle {
    enabled = var.authentik.enabled
  }

  authentik = var.authentik

  bootstrap = {
    default_group = "berg-players"
    groups = {
      "berg-admins" : {
        is_superuser = true
      },
      "challenge-authors" : {},
      "berg-players" : {}
    }
    oidc_clients = merge({
      "argocd" : {
        name            = "ArgoCD"
        slug            = "argocd"
        client_id       = "argocd"
        client_secret   = module.cluster_bootstrap.argocd_client_secret
        launch_url      = "https://argocd.${var.cluster.domain}"
        limit_to_groups = ["berg-admins", "challenge-authors"]
        redirect_uris   = ["https://argocd.${var.cluster.domain}/auth/callback"]
      },
      "kubernetes" : {
        name            = "Kubernetes API"
        slug            = "kubernetes-api"
        client_id       = "kubernetes-api"
        limit_to_groups = ["berg-admins", "challenge-authors"]
        redirect_uris   = ["http://localhost:8000", "http://localhost:18000"]
      },
      }, var.berg.enabled ? {
      "berg" : {
        name            = "Berg"
        slug            = "berg"
        client_id       = "berg"
        client_secret   = module.cluster_bootstrap.berg_client_secret
        launch_url      = "https://${var.berg.domain}"
        limit_to_groups = var.berg.admin_access_only ? ["berg-admins", "challenge-authors"] : []
        redirect_uris   = var.berg.redirect_uris
        extra_scope_mappings = {
          "role-scope-mapping" : {
            scope_name = "role"
            expression = <<-EOF
                return {
                  'role': 'admin' if ak_is_group_member(request.user, name='berg-admins') else 'author' if ak_is_group_member(request.user, name='berg-authors') else 'player'
                }
              EOF
          }
        }
      }
      } : {}, var.monitoring.enabled ? {
      "grafana" : {
        name            = "Grafana"
        slug            = "grafana"
        client_id       = "grafana"
        client_secret   = module.cluster_bootstrap.grafana_client_secret
        launch_url      = "https://${var.monitoring.domain}"
        limit_to_groups = ["berg-admins", "challenge-authors"]
        redirect_uris   = ["https://${var.monitoring.domain}/login/generic_oauth"]
      }
      } : {}, var.harbor.enabled ? {
      "harbor" : {
        name            = "Harbor"
        slug            = "harbor"
        client_id       = "harbor"
        client_secret   = module.cluster_bootstrap.harbor_client_secret
        launch_url      = "https://${var.harbor.domain}"
        limit_to_groups = ["berg-admins", "challenge-authors"]
        redirectl_uris  = ["https://${var.harbor.domain}/c/oidc/callback"]
      }
    } : {})
    authentication = {
      discord = {
        enabled       = var.authentik.authentication.discord.enabled
        guild_id      = var.authentik.authentication.discord.guild_id
        client_id     = var.authentik.authentication.discord.client_id
        client_secret = var.authentik.authentication.discord.client_secret
        role_mappings = var.authentik.authentication.discord.role_mappings
      }
      password = {
        enabled = var.authentik.authentication.password.enabled
      }
    }
    smtp = {
      enabled = var.authentik.authentication.password.enabled || var.authentik.smtp.enabled
    }
    captcha = {
      enabled = var.authentik.authentication.password.enabled || var.authentik.captcha.enabled
    }
  }
}

