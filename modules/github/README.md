# github module

This module provisions deploy keys to the target github repos. Currently, only adopting existing repos is intended.

See the [standalone GitHub example](../../examples/github/README.md) to provision credentials for the platform stack.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_github"></a> [github](#requirement\_github) | >= 6.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_github"></a> [github](#provider\_github) | >= 6.0 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |
| <a name="provider_tls"></a> [tls](#provider\_tls) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [github_repository_deploy_key.generated_deploy_key](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_deploy_key) | resource |
| [github_repository_webhook.argocd_webhook](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_webhook) | resource |
| [random_password.argocd_webhook_secret](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [tls_private_key.generated_deploy_key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_argocd_url"></a> [argocd\_url](#input\_argocd\_url) | Base URL to the argocd server | `string` | n/a | yes |
| <a name="input_argocd_webhooks"></a> [argocd\_webhooks](#input\_argocd\_webhooks) | n/a | `list(string)` | `[]` | no |
| <a name="input_generate_deploy_keys"></a> [generate\_deploy\_keys](#input\_generate\_deploy\_keys) | n/a | <pre>list(object({<br/>    repository = string<br/>    title      = string<br/>    read_only  = optional(bool, true)<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_argocd_webhook_secret"></a> [argocd\_webhook\_secret](#output\_argocd\_webhook\_secret) | n/a |
| <a name="output_generated_deploy_keys"></a> [generated\_deploy\_keys](#output\_generated\_deploy\_keys) | n/a |
<!-- END_TF_DOCS -->