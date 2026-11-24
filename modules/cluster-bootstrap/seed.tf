locals {
  argocd_namespace = kubernetes_namespace_v1.infra_argocd.metadata[0].name
  destination = {
    namespace = local.argocd_namespace
    server    = "https://kubernetes.default.svc"
  }

  gitops_seed = [
    {
      apiVersion = "argoproj.io/v1alpha1"
      kind       = "AppProject"
      metadata = {
        name      = "cluster-config"
        namespace = local.argocd_namespace
      }
      spec = {
        sourceRepos  = [var.infra_repo]
        destinations = [local.destination]
        namespaceResourceWhitelist = [
          { group = "argoproj.io", kind = "Application" },
          { group = "argoproj.io", kind = "AppProject" }
        ]
      }
    },
    {
      apiVersion = "argoproj.io/v1alpha1"
      kind       = "Application"
      metadata = {
        name      = "cluster-config"
        namespace = local.argocd_namespace
      }
      spec = {
        project     = "cluster-config"
        destination = local.destination
        sources = [
          for path in [var.infra_repo_path, "${trimsuffix(var.infra_repo_path, "/")}/appprojects"] : {
            repoURL        = var.infra_repo
            targetRevision = "HEAD"
            path           = path
            directory      = { recurse = false }
          }
        ]
        syncPolicy = { automated = {} }
      }
    }
  ]
}
