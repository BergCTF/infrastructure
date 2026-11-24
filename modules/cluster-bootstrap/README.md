# cluster-bootstrap module

Installs Argo CD, registers Git credentials, and seeds the cluster configuration Application.

See the [Forgejo example](../../docs/SETUP.md#forgejo-over-ssh) for private SSH repositories and host key verification.

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

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [helm_release.infra_argocd](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_namespace_v1.infra_argocd](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace_v1) | resource |
| [kubernetes_secret_v1.argocd_challenge_repo](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [kubernetes_secret_v1.argocd_infra_repo](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_argocd_domain"></a> [argocd\_domain](#input\_argocd\_domain) | Public hostname of the Argo CD installation. | `string` | `null` | no |
| <a name="input_argocd_helm_values"></a> [argocd\_helm\_values](#input\_argocd\_helm\_values) | Optional Helm settings for the Argo CD installation, such as SSO and resource limits. | `any` | `{}` | no |
| <a name="input_argocd_webhook_secret"></a> [argocd\_webhook\_secret](#input\_argocd\_webhook\_secret) | GitHub webhook secret for Argo CD. | `string` | `null` | no |
| <a name="input_challenge_repo"></a> [challenge\_repo](#input\_challenge\_repo) | Optional challenge repository URL to register with Argo CD. | `string` | `null` | no |
| <a name="input_challenge_repo_deploy_key"></a> [challenge\_repo\_deploy\_key](#input\_challenge\_repo\_deploy\_key) | SSH private key for a private challenge repository. | `string` | `null` | no |
| <a name="input_git_ssh_known_hosts"></a> [git\_ssh\_known\_hosts](#input\_git\_ssh\_known\_hosts) | Verified OpenSSH known\_hosts entries for self-hosted Git servers. | `string` | `""` | no |
| <a name="input_infra_repo"></a> [infra\_repo](#input\_infra\_repo) | url of argocd infra repo | `string` | n/a | yes |
| <a name="input_infra_repo_deploy_key"></a> [infra\_repo\_deploy\_key](#input\_infra\_repo\_deploy\_key) | Infrastructure repository SSH key. Optional for public HTTPS repositories. | `string` | `null` | no |
| <a name="input_infra_repo_path"></a> [infra\_repo\_path](#input\_infra\_repo\_path) | path in argocd infra repo | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->