# cluster module

This module provisions a Talos Kubernetes cluster on Hetzner.

See the [bare-metal setup guide](../../docs/SETUP.md#hetzner-bare-metal-workers) for the Robot inputs and Cilium settings.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.11.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_talos"></a> [talos](#module\_talos) | hcloud-k8s/kubernetes/hcloud | 6.4.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_bare_metal_config_patches"></a> [bare\_metal\_config\_patches](#input\_bare\_metal\_config\_patches) | Talos configuration patches applied to all bare-metal workers. | `list(string)` | `[]` | no |
| <a name="input_bare_metal_nodepools"></a> [bare\_metal\_nodepools](#input\_bare\_metal\_nodepools) | Hetzner Robot worker pools using the upstream hcloud-k8s bare\_metal\_nodepools schema. | `any` | `[]` | no |
| <a name="input_cilium_helm_values"></a> [cilium\_helm\_values](#input\_cilium\_helm\_values) | Optional Helm overrides for the Cilium installation managed by Talos. | `any` | `{}` | no |
| <a name="input_cluster_allow_scheduling_on_control_planes"></a> [cluster\_allow\_scheduling\_on\_control\_planes](#input\_cluster\_allow\_scheduling\_on\_control\_planes) | n/a | `bool` | n/a | yes |
| <a name="input_cluster_domain"></a> [cluster\_domain](#input\_cluster\_domain) | n/a | `string` | n/a | yes |
| <a name="input_control_plane_pools"></a> [control\_plane\_pools](#input\_control\_plane\_pools) | n/a | <pre>list(object({<br/>    name     = string<br/>    type     = string<br/>    location = string<br/>    count    = number<br/>  }))</pre> | n/a | yes |
| <a name="input_env"></a> [env](#input\_env) | Environment name, eg test | `string` | n/a | yes |
| <a name="input_governance_name"></a> [governance\_name](#input\_governance\_name) | Logical grouping of multiple environments | `string` | n/a | yes |
| <a name="input_hcloud_robot_password"></a> [hcloud\_robot\_password](#input\_hcloud\_robot\_password) | Hetzner Robot web service password for dedicated workers. | `string` | `null` | no |
| <a name="input_hcloud_robot_user"></a> [hcloud\_robot\_user](#input\_hcloud\_robot\_user) | Hetzner Robot web service username for dedicated workers. | `string` | `null` | no |
| <a name="input_hcloud_vswitch_id"></a> [hcloud\_vswitch\_id](#input\_hcloud\_vswitch\_id) | Existing Hetzner Robot vSwitch ID. The upstream module creates one by default when bare-metal workers are configured. | `number` | `null` | no |
| <a name="input_hetzner_token"></a> [hetzner\_token](#input\_hetzner\_token) | Hetzner API token for cluster provisioning | `string` | n/a | yes |
| <a name="input_kube_api_loadbalancer_enabled"></a> [kube\_api\_loadbalancer\_enabled](#input\_kube\_api\_loadbalancer\_enabled) | n/a | `bool` | n/a | yes |
| <a name="input_kube_api_oidc_providers"></a> [kube\_api\_oidc\_providers](#input\_kube\_api\_oidc\_providers) | Optional Kubernetes API OIDC issuers using the upstream hcloud-k8s schema. | `any` | `[]` | no |
| <a name="input_worker_pools"></a> [worker\_pools](#input\_worker\_pools) | n/a | <pre>list(object({<br/>    name     = string<br/>    type     = string<br/>    location = string<br/>    count    = number<br/>    subnet   = optional(string)<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_kubeconfig"></a> [kubeconfig](#output\_kubeconfig) | n/a |
| <a name="output_raw_kubeconfig"></a> [raw\_kubeconfig](#output\_raw\_kubeconfig) | n/a |
| <a name="output_talosconfig"></a> [talosconfig](#output\_talosconfig) | n/a |
<!-- END_TF_DOCS -->