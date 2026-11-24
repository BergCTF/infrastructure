resource "kubernetes_namespace_v1" "infra_argocd" {
  metadata {
    name = "infra-argocd"
    labels = {
      "app.kubernetes.io/name"             = "infra-argocd"
      "app.kubernetes.io/component"        = "infra"
      "app.kubernetes.io/part-of"          = "infra"
      "pod-security.kubernetes.io/enforce" = "restricted"
    }
  }
}
