terraform {
  required_version = ">= 1.11.0"

  required_providers {
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
  challenge_repo            = var.challenge_repo
  challenge_repo_deploy_key = var.git_credentials.challenge_deploy_key
  git_ssh_known_hosts       = var.git_ssh_known_hosts
  argocd_helm_values        = var.argocd_helm_values
  argocd_domain             = "argocd.${var.cluster.domain}"
}
