# outputs to be consumed by Authentik module
output "argocd_client_secret" {
  value     = random_password.argocd_client_secret.result
  sensitive = true
}

output "grafana_client_secret" {
  value     = random_password.grafana_client_secret.result
  sensitive = true
}

output "berg_client_secret" {
  value     = random_password.berg_client_secret.result
  sensitive = true
}

output "harbor_client_secret" {
  value     = random_password.harbor_client_secret.result
  sensitive = true
}

output "authentik_bootstrap_token" {
  value     = random_password.authentik_bootstrap_token.result
  sensitive = true
}
