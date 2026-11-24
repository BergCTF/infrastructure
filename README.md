# Berg infrastructure

The core module provisions Talos on Hetzner, installs Argo CD, and points it
at a Git repository containing the rendered cluster chart. OpenTofu seeds
DNS and any enabled service credentials before Argo CD syncs.

## Usage

For a public repository and the default DNS setup:

```hcl
module "platform" {
  source = "../infrastructure"

  env             = "prod"
  governance_name = "example"
  hetzner_token   = var.hetzner_token
  dns_api_token   = var.dns_api_token

  cluster = {
    domain                                     = "prod.example.org"
    cluster_allow_scheduling_on_control_planes = true
    control_plane_pools = [{
      name     = "control"
      type     = "cx23"
      location = "fsn1"
      count    = 1
    }]
    infra_repo = {
      url  = "https://forgejo.example.org/ctf/infrastructure.git"
      path = "manifests/example-prod"
    }
  }
}
```

- [Set up Git access, Hetzner bare-metal workers, and add-ons](docs/SETUP.md)
- [Deploy or upgrade a cluster](docs/DEPLOYING.md)

| Module | Purpose |
| --- | --- |
| [Cluster](modules/cluster/README.md) | Talos and Kubernetes on Hetzner Cloud and Robot |
| [Cluster bootstrap](modules/cluster-bootstrap/README.md) | Argo CD and the initial Kubernetes GitOps resources |
| [Authentik](modules/authentik/README.md) | Identity provider configuration |
| [Harbor](modules/harbor/README.md) | Registry configuration |

Regenerate the reference sections after changing module interfaces with
`terraform-docs markdown table --output-file README.md --output-mode inject .`.
Run the same command from each changed module directory.

## Todo

Some things aren't currently included, such as:
- provisioning DNS (required for certs to work)
- provisioning Cloudflare Captchas
- provisioning AWS SES credentials (mails for Authentik)
- provisioning S3 buckets (Hetzner is long term a bad choice here as the buckets don't allow nice granularity easily)

There's probably a bunch of stuff we can disable assuming we don't want authentik password auth


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.11.0 |
| <a name="requirement_authentik"></a> [authentik](#requirement\_authentik) | >= 2025.10.1 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 3.0.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 3.0.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_authentik"></a> [authentik](#module\_authentik) | ./modules/authentik | n/a |
| <a name="module_cluster"></a> [cluster](#module\_cluster) | ./modules/cluster | n/a |
| <a name="module_cluster_bootstrap"></a> [cluster\_bootstrap](#module\_cluster\_bootstrap) | ./modules/cluster-bootstrap | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_argocd_helm_values"></a> [argocd\_helm\_values](#input\_argocd\_helm\_values) | Optional Helm settings for the Argo CD installation, such as SSO and resource limits. | `any` | `{}` | no |
| <a name="input_authentik"></a> [authentik](#input\_authentik) | n/a | <pre>object({<br/>    enabled = optional(bool, false)<br/>    domain  = optional(string)<br/>    branding = optional(object({<br/>      title               = optional(string, "")<br/>      favicon             = optional(string, "")<br/>      logo                = optional(string, "")<br/>      background_image    = optional(string, "")<br/>      default_application = optional(string, "")<br/>    }), {})<br/>    backups = optional(object({<br/>      enabled    = optional(bool, false)<br/>      access_key = optional(string)<br/>      secret_key = optional(string)<br/>    }), {})<br/>    authentication = optional(object({<br/>      # enable discord federated authentication<br/>      discord = optional(object({<br/>        # discord is currently required<br/>        enabled = optional(bool, true)<br/>        # required for role mappings<br/>        guild_id      = optional(string)<br/>        client_id     = optional(string)<br/>        client_secret = optional(string)<br/>        # arbitrary group -> discord role id mappings<br/>        role_mappings = optional(map(string), {})<br/>      }), {})<br/>      # enable password authentication<br/>      password = optional(object({<br/>        enabled = optional(bool, false)<br/>      }), {})<br/>    }), {})<br/>    # smtp configuration is required if password authentication is enabled<br/>    smtp = optional(object({<br/>      enabled  = optional(bool, false)<br/>      username = optional(string, null)<br/>      password = optional(string, null)<br/>    }), {})<br/>    # cloudflare turnstile captcha<br/>    captcha = optional(object({<br/>      enabled = optional(bool, false)<br/>    }), {})<br/>  })</pre> | `{}` | no |
| <a name="input_berg"></a> [berg](#input\_berg) | n/a | <pre>object({<br/>    enabled           = optional(bool, false)<br/>    domain            = optional(string)<br/>    challenge_repo    = optional(string)<br/>    pull_secret       = optional(string)<br/>    admin_access_only = optional(bool, true)<br/>    redirect_uris     = optional(list(string), [])<br/>    backups = optional(object({<br/>      enabled    = optional(bool, false)<br/>      access_key = optional(string)<br/>      secret_key = optional(string)<br/>    }), {})<br/>    discord_bot_token = optional(string, null)<br/>  })</pre> | `{}` | no |
| <a name="input_cert_manager"></a> [cert\_manager](#input\_cert\_manager) | n/a | <pre>object({<br/>    enabled = optional(bool, true)<br/>    dns_resolver = optional(object({<br/>      enabled = optional(bool, true)<br/>    }), {})<br/>  })</pre> | `{}` | no |
| <a name="input_challenge_repo"></a> [challenge\_repo](#input\_challenge\_repo) | Optional challenge repository URL to register with Argo CD. | `string` | `null` | no |
| <a name="input_cluster"></a> [cluster](#input\_cluster) | cluster configuration | <pre>object({<br/>    domain                                     = string<br/>    kube_api_loadbalancer_enabled              = optional(bool, false)<br/>    cluster_allow_scheduling_on_control_planes = optional(bool, false)<br/><br/>    control_plane_pools = list(object({<br/>      name     = string<br/>      type     = string<br/>      location = string<br/>      count    = number<br/>    }))<br/><br/>    worker_pools = optional(list(object({<br/>      name     = string<br/>      type     = string<br/>      location = string<br/>      count    = number<br/>      subnet   = optional(string)<br/>    })), [])<br/><br/>    bare_metal_nodepools      = optional(any, [])<br/>    bare_metal_config_patches = optional(list(string), [])<br/>    hcloud_vswitch_id         = optional(number)<br/><br/>    kube_api_oidc_providers = optional(any, [])<br/>    cilium_helm_values      = optional(any, {})<br/><br/>    infra_repo = object({<br/>      url  = string<br/>      path = string<br/>    })<br/>  })</pre> | n/a | yes |
| <a name="input_discord_client_id"></a> [discord\_client\_id](#input\_discord\_client\_id) | n/a | `string` | `null` | no |
| <a name="input_discord_client_secret"></a> [discord\_client\_secret](#input\_discord\_client\_secret) | n/a | `string` | `null` | no |
| <a name="input_dns_api_token"></a> [dns\_api\_token](#input\_dns\_api\_token) | n/a | `string` | `null` | no |
| <a name="input_env"></a> [env](#input\_env) | Environment name, eg test | `string` | n/a | yes |
| <a name="input_external_dns"></a> [external\_dns](#input\_external\_dns) | Opt in to seeding the External DNS API token. | <pre>object({<br/>    enabled = optional(bool, false)<br/>  })</pre> | `{}` | no |
| <a name="input_git_credentials"></a> [git\_credentials](#input\_git\_credentials) | Optional read-only Git SSH keys for Argo CD. | <pre>object({<br/>    infra_deploy_key     = optional(string)<br/>    challenge_deploy_key = optional(string)<br/>  })</pre> | `{}` | no |
| <a name="input_git_ssh_known_hosts"></a> [git\_ssh\_known\_hosts](#input\_git\_ssh\_known\_hosts) | Verified OpenSSH known\_hosts entries for self-hosted Git servers. | `string` | `""` | no |
| <a name="input_governance_name"></a> [governance\_name](#input\_governance\_name) | Logical grouping of multiple environments | `string` | n/a | yes |
| <a name="input_harbor"></a> [harbor](#input\_harbor) | n/a | <pre>object({<br/>    enabled    = optional(bool, false)<br/>    domain     = optional(string)<br/>    access_key = optional(string)<br/>    secret_key = optional(string)<br/>  })</pre> | `{}` | no |
| <a name="input_hcloud_robot_password"></a> [hcloud\_robot\_password](#input\_hcloud\_robot\_password) | Hetzner Robot web service password for dedicated workers. | `string` | `null` | no |
| <a name="input_hcloud_robot_user"></a> [hcloud\_robot\_user](#input\_hcloud\_robot\_user) | Hetzner Robot web service username for dedicated workers. | `string` | `null` | no |
| <a name="input_hetzner_token"></a> [hetzner\_token](#input\_hetzner\_token) | API Token for Hetzner infrastructure | `string` | n/a | yes |
| <a name="input_monitoring"></a> [monitoring](#input\_monitoring) | n/a | <pre>object({<br/>    enabled         = optional(bool, false)<br/>    discord_webhook = optional(string)<br/>    domain          = optional(string)<br/>    loki = optional(object({<br/>      enabled    = optional(bool, false)<br/>      access_key = optional(string)<br/>      secret_key = optional(string)<br/>    }), {})<br/>    mimir = optional(object({<br/>      enabled    = optional(bool, false)<br/>      access_key = optional(string)<br/>      secret_key = optional(string)<br/>    }), {})<br/>    tempo = optional(object({<br/>      enabled    = optional(bool, false)<br/>      access_key = optional(string)<br/>      secret_key = optional(string)<br/>    }), {})<br/>  })</pre> | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_kubeconfig"></a> [kubeconfig](#output\_kubeconfig) | n/a |
| <a name="output_talosconfig"></a> [talosconfig](#output\_talosconfig) | n/a |
<!-- END_TF_DOCS -->