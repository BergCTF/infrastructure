resource "helm_release" "infra_argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = kubernetes_namespace_v1.infra_argocd.metadata[0].name
  version    = "10.18.3"

  # install crds via talos
  skip_crds = true
  values = [
    yamlencode({
      global = var.argocd_domain == null ? {} : { domain = var.argocd_domain }
      configs = {
        cm     = var.argocd_domain == null ? {} : { url = "https://${var.argocd_domain}" }
        params = { "server.insecure" = true }
      }
    }),
    yamlencode(var.argocd_helm_values),
    yamlencode({
      configs = { ssh = { extraHosts = var.git_ssh_known_hosts } }
      extraObjects = concat(
        try(var.argocd_helm_values.extraObjects, []),
        local.gitops_seed,
      )
    }),
  ]
  set_sensitive = var.argocd_webhook_secret == null ? [] : [{
    name  = "configs.secret.githubSecret"
    value = var.argocd_webhook_secret
  }]
  set = [
    {
      name  = "crds.install"
      value = "false"
    }
  ]
}

resource "kubernetes_secret_v1" "argocd_infra_repo" {
  metadata {
    name      = "repo-argocd-configs"
    namespace = kubernetes_namespace_v1.infra_argocd.metadata[0].name
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  data = merge({
    type = "git"
    url  = var.infra_repo
    }, var.infra_repo_deploy_key == null ? {} : {
    sshPrivateKey = var.infra_repo_deploy_key
  })

  type = "Opaque"
}

resource "kubernetes_secret_v1" "argocd_challenge_repo" {
  lifecycle { enabled = var.challenge_repo != null }
  metadata {
    name      = "repo-challenges"
    namespace = kubernetes_namespace_v1.infra_argocd.metadata[0].name
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  data = merge({
    type = "git"
    url  = var.challenge_repo
    }, var.challenge_repo_deploy_key == null ? {} : {
    sshPrivateKey = var.challenge_repo_deploy_key
  })

  type = "Opaque"
}
