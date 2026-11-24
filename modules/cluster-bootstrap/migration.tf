# Leave existing namespaces, credentials, and seed objects in place for the GitOps handoff.

removed {
  from = kubernetes_secret_v1.authentik_secret_key
  lifecycle { destroy = false }
}

removed {
  from = kubernetes_secret_v1.authentik_database_backup_secret
  lifecycle { destroy = false }
}

removed {
  from = kubernetes_secret_v1.authentik_bootstrap_token
  lifecycle { destroy = false }
}

removed {
  from = kubernetes_secret_v1.argocd_authentik_secret
  lifecycle { destroy = false }
}

removed {
  from = kubernetes_secret_v1.grafana_oauth_secret
  lifecycle { destroy = false }
}

removed {
  from = kubernetes_secret_v1.berg_client_secret
  lifecycle { destroy = false }
}

removed {
  from = kubernetes_secret_v1.berg_database_backup_secret
  lifecycle { destroy = false }
}

removed {
  from = kubernetes_secret_v1.berg_pull_secret
  lifecycle { destroy = false }
}

removed {
  from = kubernetes_secret_v1.berg_discord_client
  lifecycle { destroy = false }
}

removed {
  from = kubernetes_secret_v1.berg_discord_bot_token
  lifecycle { destroy = false }
}

removed {
  from = kubernetes_secret_v1.cloudflare_api_token
  lifecycle { destroy = false }
}

removed {
  from = kubernetes_secret_v1.ed_dns_api_token
  lifecycle { destroy = false }
}

removed {
  from = kubernetes_secret_v1.loki_objectstorage_credentials
  lifecycle { destroy = false }
}

removed {
  from = kubernetes_secret_v1.mimir_objectstorage_credentials
  lifecycle { destroy = false }
}

removed {
  from = kubernetes_secret_v1.tracing_objectstorage_credentials
  lifecycle { destroy = false }
}

removed {
  from = kubernetes_secret_v1.discord_alert_webhook
  lifecycle { destroy = false }
}

removed {
  from = kubernetes_namespace_v1.infra_monitoring
  lifecycle { destroy = false }
}

removed {
  from = kubernetes_namespace_v1.infra_authentik
  lifecycle { destroy = false }
}

removed {
  from = kubernetes_namespace_v1.berg
  lifecycle { destroy = false }
}

removed {
  from = kubernetes_namespace_v1.infra_logging
  lifecycle { destroy = false }
}

removed {
  from = kubernetes_namespace_v1.infra_cert_manager
  lifecycle { destroy = false }
}

removed {
  from = kubernetes_namespace_v1.infra_external_dns
  lifecycle { destroy = false }
}

removed {
  from = kubernetes_namespace_v1.infra_tracing
  lifecycle { destroy = false }
}

removed {
  from = kubernetes_manifest.appproject_argocd_apps
  lifecycle { destroy = false }
}

removed {
  from = kubernetes_manifest.appproject_misc_argocd_apps
  lifecycle { destroy = false }
}

removed {
  from = kubernetes_manifest.appproject_appprojects
  lifecycle { destroy = false }
}

removed {
  from = kubernetes_manifest.app_misc_apps
  lifecycle { destroy = false }
}
