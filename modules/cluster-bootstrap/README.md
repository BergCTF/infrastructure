# cluster-bootstrap module

This module authenticates with an existing cluster (eg. one created by the cluster module) and rolls out cluster components required for GitOps

See the [Forgejo example](../../docs/SETUP.md#forgejo-without-github-automation) for private SSH repositories and host key verification.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.11.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 3.0.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 3.0.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_helm"></a> [helm](#provider\_helm) | >= 3.0.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 3.0.0 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |
| <a name="provider_tls"></a> [tls](#provider\_tls) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [helm_release.infra_argocd](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_manifest.app_misc_apps](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.appproject_appprojects](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.appproject_argocd_apps](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.appproject_misc_argocd_apps](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_namespace_v1.berg](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace_v1) | resource |
| [kubernetes_namespace_v1.infra_argocd](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace_v1) | resource |
| [kubernetes_namespace_v1.infra_authentik](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace_v1) | resource |
| [kubernetes_namespace_v1.infra_cert_manager](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace_v1) | resource |
| [kubernetes_namespace_v1.infra_external_dns](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace_v1) | resource |
| [kubernetes_namespace_v1.infra_logging](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace_v1) | resource |
| [kubernetes_namespace_v1.infra_monitoring](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace_v1) | resource |
| [kubernetes_namespace_v1.infra_tracing](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace_v1) | resource |
| [kubernetes_secret_v1.argocd_authentik_secret](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [kubernetes_secret_v1.argocd_challenge_repo](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [kubernetes_secret_v1.argocd_infra_repo](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [kubernetes_secret_v1.authentik_bootstrap_token](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [kubernetes_secret_v1.authentik_database_backup_secret](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [kubernetes_secret_v1.authentik_secret_key](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [kubernetes_secret_v1.berg_client_secret](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [kubernetes_secret_v1.berg_database_backup_secret](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [kubernetes_secret_v1.berg_discord_bot_token](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [kubernetes_secret_v1.berg_discord_client](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [kubernetes_secret_v1.berg_pull_secret](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [kubernetes_secret_v1.cloudflare_api_token](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [kubernetes_secret_v1.discord_alert_webhook](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [kubernetes_secret_v1.ed_dns_api_token](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [kubernetes_secret_v1.grafana_oauth_secret](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [kubernetes_secret_v1.loki_objectstorage_credentials](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [kubernetes_secret_v1.mimir_objectstorage_credentials](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [kubernetes_secret_v1.tracing_objectstorage_credentials](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [random_password.argocd_client_secret](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.authentik_bootstrap_token](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.authentik_secret_key](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.berg_client_secret](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.grafana_client_secret](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.harbor_client_secret](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [tls_private_key.challenge_deploy_key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_private_key.deploy_key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_argocd_webhook_secret"></a> [argocd\_webhook\_secret](#input\_argocd\_webhook\_secret) | GitHub webhook secret for Argo CD. | `string` | `null` | no |
| <a name="input_authentik"></a> [authentik](#input\_authentik) | n/a | <pre>object({<br/>    enabled = bool<br/>    backups = object({<br/>      enabled    = optional(bool, false)<br/>      access_key = optional(string)<br/>      secret_key = optional(string)<br/>    })<br/>  })</pre> | n/a | yes |
| <a name="input_berg"></a> [berg](#input\_berg) | n/a | <pre>object({<br/>    enabled                   = bool<br/>    pull_secret               = optional(string)<br/>    challenge_repo            = optional(string)<br/>    challenge_repo_deploy_key = optional(string)<br/>    backups = object({<br/>      enabled    = optional(bool, false)<br/>      access_key = optional(string)<br/>      secret_key = optional(string)<br/>    })<br/>  })</pre> | n/a | yes |
| <a name="input_cert_manager"></a> [cert\_manager](#input\_cert\_manager) | n/a | <pre>object({<br/>    enabled = optional(bool, true)<br/>    dns_resolver = object({<br/>      enabled = optional(bool, false)<br/>    })<br/>  })</pre> | n/a | yes |
| <a name="input_discord_bot_token"></a> [discord\_bot\_token](#input\_discord\_bot\_token) | n/a | `string` | `null` | no |
| <a name="input_discord_client_id"></a> [discord\_client\_id](#input\_discord\_client\_id) | n/a | `string` | `null` | no |
| <a name="input_discord_client_secret"></a> [discord\_client\_secret](#input\_discord\_client\_secret) | n/a | `string` | `null` | no |
| <a name="input_dns_api_token"></a> [dns\_api\_token](#input\_dns\_api\_token) | n/a | `string` | `null` | no |
| <a name="input_email_enabled"></a> [email\_enabled](#input\_email\_enabled) | email is required for password login -otherwise only discord is supported | `bool` | `false` | no |
| <a name="input_email_password"></a> [email\_password](#input\_email\_password) | n/a | `string` | `null` | no |
| <a name="input_email_username"></a> [email\_username](#input\_email\_username) | n/a | `string` | `null` | no |
| <a name="input_env"></a> [env](#input\_env) | Environment name, eg test | `string` | n/a | yes |
| <a name="input_external_dns"></a> [external\_dns](#input\_external\_dns) | n/a | <pre>object({<br/>    enabled = optional(bool, true)<br/>  })</pre> | n/a | yes |
| <a name="input_git_ssh_known_hosts"></a> [git\_ssh\_known\_hosts](#input\_git\_ssh\_known\_hosts) | Verified OpenSSH known\_hosts entries for self-hosted Git servers. | `string` | `""` | no |
| <a name="input_governance_name"></a> [governance\_name](#input\_governance\_name) | Logical grouping of multiple environments | `string` | n/a | yes |
| <a name="input_infra_repo"></a> [infra\_repo](#input\_infra\_repo) | url of argocd infra repo | `string` | n/a | yes |
| <a name="input_infra_repo_deploy_key"></a> [infra\_repo\_deploy\_key](#input\_infra\_repo\_deploy\_key) | Infrastructure repository SSH key. Optional for public HTTPS repositories. | `string` | `null` | no |
| <a name="input_infra_repo_path"></a> [infra\_repo\_path](#input\_infra\_repo\_path) | path in argocd infra repo | `string` | n/a | yes |
| <a name="input_monitoring"></a> [monitoring](#input\_monitoring) | n/a | <pre>object({<br/>    enabled         = optional(bool, false)<br/>    discord_webhook = optional(string)<br/>    loki = object({<br/>      enabled    = optional(bool, false)<br/>      access_key = optional(string)<br/>      secret_key = optional(string)<br/>    })<br/>    mimir = object({<br/>      enabled    = optional(bool, false)<br/>      access_key = optional(string)<br/>      secret_key = optional(string)<br/>    })<br/>    tempo = object({<br/>      enabled    = optional(bool, false)<br/>      access_key = optional(string)<br/>      secret_key = optional(string)<br/>    })<br/>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_argocd_client_secret"></a> [argocd\_client\_secret](#output\_argocd\_client\_secret) | outputs to be consumed by Authentik module |
| <a name="output_authentik_bootstrap_token"></a> [authentik\_bootstrap\_token](#output\_authentik\_bootstrap\_token) | n/a |
| <a name="output_berg_client_secret"></a> [berg\_client\_secret](#output\_berg\_client\_secret) | n/a |
| <a name="output_challenge_deploy_key_pub"></a> [challenge\_deploy\_key\_pub](#output\_challenge\_deploy\_key\_pub) | n/a |
| <a name="output_grafana_client_secret"></a> [grafana\_client\_secret](#output\_grafana\_client\_secret) | n/a |
| <a name="output_harbor_client_secret"></a> [harbor\_client\_secret](#output\_harbor\_client\_secret) | n/a |
| <a name="output_infra_deploy_key_pub"></a> [infra\_deploy\_key\_pub](#output\_infra\_deploy\_key\_pub) | n/a |
<!-- END_TF_DOCS -->