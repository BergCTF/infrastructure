terraform {
  required_version = ">= 1.11.0"

  required_providers {
    authentik = {
      source  = "goauthentik/authentik"
      version = ">= 2025.10.1"
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

locals {
  authentik_domain = coalesce(var.authentik.domain, "idp.${var.cluster.domain}")
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

  kube_api_oidc_providers = var.cluster.kube_api_oidc_providers
  cilium_helm_values      = var.cluster.cilium_helm_values
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
  source = "./modules/cluster-bootstrap"

  infra_repo                = var.cluster.infra_repo.url
  infra_repo_path           = var.cluster.infra_repo.path
  infra_repo_deploy_key     = var.git_credentials.infra_deploy_key
  challenge_repo            = try(coalesce(var.challenge_repo, var.berg.challenge_repo), null)
  challenge_repo_deploy_key = var.git_credentials.challenge_deploy_key
  git_ssh_known_hosts       = var.git_ssh_known_hosts
  argocd_helm_values        = var.argocd_helm_values
  argocd_domain             = "argocd.${var.cluster.domain}"

  berg         = var.berg
  monitoring   = var.monitoring
  authentik    = merge(var.authentik, { domain = local.authentik_domain })
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
  url   = var.authentik.enabled ? "https://${local.authentik_domain}" : null
  token = module.cluster_bootstrap.authentik_bootstrap_token
}

module "authentik" {
  source = "./modules/authentik"

  lifecycle {
    enabled = var.authentik.enabled
  }

  authentik = merge(var.authentik, { domain = local.authentik_domain })

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
                  'role': 'admin' if ak_is_group_member(request.user, name='berg-admins') else 'author' if ak_is_group_member(request.user, name='challenge-authors') else 'player'
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
        launch_url      = "https://${coalesce(var.monitoring.domain, "grafana.${var.cluster.domain}")}"
        limit_to_groups = ["berg-admins", "challenge-authors"]
        redirect_uris   = ["https://${coalesce(var.monitoring.domain, "grafana.${var.cluster.domain}")}/login/generic_oauth"]
      }
      } : {}, var.harbor.enabled ? {
      "harbor" : {
        name            = "Harbor"
        slug            = "harbor"
        client_id       = "harbor"
        client_secret   = module.cluster_bootstrap.harbor_client_secret
        launch_url      = "https://${var.harbor.domain}"
        limit_to_groups = ["berg-admins", "challenge-authors"]
        redirect_uris   = ["https://${var.harbor.domain}/c/oidc/callback"]
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
