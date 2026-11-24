resource "helm_release" "infra_argocd" {
  # The seed Application can sync as soon as Argo CD starts.
  depends_on = [
    kubernetes_secret_v1.argocd_infra_repo,
    kubernetes_secret_v1.argocd_challenge_repo,
    kubernetes_secret_v1.cloudflare_api_token,
    kubernetes_secret_v1.ed_dns_api_token,
    kubernetes_secret_v1.authentik_secret_key,
    kubernetes_secret_v1.authentik_database_backup_secret,
    kubernetes_secret_v1.authentik_bootstrap_token,
    kubernetes_secret_v1.argocd_authentik_secret,
    kubernetes_secret_v1.grafana_oauth_secret,
    kubernetes_secret_v1.berg_client_secret,
    kubernetes_secret_v1.berg_database_backup_secret,
    kubernetes_secret_v1.berg_pull_secret,
    kubernetes_secret_v1.berg_discord_client,
    kubernetes_secret_v1.berg_discord_bot_token,
    kubernetes_secret_v1.loki_objectstorage_credentials,
    kubernetes_secret_v1.mimir_objectstorage_credentials,
    kubernetes_secret_v1.tracing_objectstorage_credentials,
    kubernetes_secret_v1.discord_alert_webhook,
  ]

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
      server = {
        httproute = {
          enabled   = var.argocd_domain != null
          hostnames = var.argocd_domain == null ? [] : [var.argocd_domain]
          parentRefs = [
            for listener in ["https", "http"] : {
              name        = "gw-berg"
              namespace   = "berg"
              sectionName = listener
            }
          ]
        }
      }
      configs = {
        cm = merge(
          var.argocd_domain == null ? {} : { url = "https://${var.argocd_domain}" },
          var.authentik.enabled && var.authentik.domain != null ? {
            "oidc.config" = yamlencode({
              name            = "Authentik"
              issuer          = "https://${var.authentik.domain}/application/o/argocd/"
              clientID        = "argocd"
              clientSecret    = "$argocd-authentik-secret:oidc.authentik.clientSecret"
              requestedScopes = ["openid", "profile", "email", "groups"]
            })
          } : {},
        )
        rbac = var.authentik.enabled && var.authentik.domain != null ? {
          "policy.csv" = "g, berg-admins, role:admin"
          scopes       = "[groups]"
        } : {}
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
