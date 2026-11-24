# Cluster setup

The [deployment guide](DEPLOYING.md) covers cluster provisioning and GitOps
bootstrap. The snippets below extend the inputs to the [root module](../README.md).

## Forgejo without GitHub automation

For private repositories, generate a dedicated SSH keypair per repository and
register the public keys as read-only deploy keys in Forgejo. Pass the private
keys through your deployment environment's secret store. Obtain the Forgejo
SSH host key from the server administrator or verify its fingerprint before
adding it to an OpenSSH known_hosts file. For a non-default port, use the
`[host]:port` known_hosts form.

In your OpenTofu configuration, declare the secret input:

```hcl
variable "forgejo_deploy_keys" {
  type = object({
    infra_deploy_key     = string
    challenge_deploy_key = optional(string)
  })
  sensitive = true
}
```

In your existing infrastructure module call, merge in these settings:

```hcl
github_enabled      = false
git_credentials     = var.forgejo_deploy_keys
git_ssh_known_hosts = file("${path.module}/forgejo_known_hosts")

cluster = {
  # Keep the other cluster settings.
  infra_repo = {
    url  = "ssh://git@forgejo.example.org/ctf/infrastructure.git"
    path = "manifests/example-prod"
  }
}

berg = {
  # Keep the other Berg settings.
  challenge_repo = "ssh://git@forgejo.example.org/ctf/challenges.git"
}
```

Use the same URLs and manifest path in the values you render with
`charts/cluster-template`:

```yaml
infra:
  repo: ssh://git@forgejo.example.org/ctf/infrastructure.git
  path: manifests/example-prod
challenges:
  enabled: true
  repo: ssh://git@forgejo.example.org/ctf/challenges.git
```

For GitHub repositories, the default is still to provision read-only deploy keys
and push webhooks through the GitHub module. With GitHub automation disabled,
Argo CD polls Forgejo for changes. This path needs no GitHub App, GitHub token,
or Forgejo webhook. OpenTofu may still install the GitHub provider plugin
during initialization because the root module declares it. If Berg is disabled,
omit the challenge deploy key and leave `challenges.enabled` off. For public
HTTPS repositories, omit their SSH keys and use their HTTPS clone URLs.

If moving an existing deployment off GitHub, register the replacement keys and
review the plan before applying. Disabling the GitHub module removes its
managed deploy keys and webhooks. Keep the old provider credentials available
for that cleanup.

## Hetzner bare-metal workers

Add `bare_metal_nodepools` inside the existing `cluster` object:

```hcl
bare_metal_nodepools = [{
  name = "dedicated"
  servers = [{
    number       = 1111111
    private_ipv4 = "10.0.88.2"
  }]
}]
```

Set `hcloud_robot_user` and `hcloud_robot_password` as module inputs from your
deployment environment. These are Robot web service credentials. The existing
`hetzner_token` continues to authenticate the cloud control planes and network.
Choose a unique address for each server in the default `10.0.88.0/25` vSwitch
subnet. The first usable address is reserved for the gateway. Set
`cluster.hcloud_vswitch_id` to attach to an existing vSwitch or let the module
create one. Set `cluster.bare_metal_config_patches` to apply extra Talos
configuration to all dedicated workers. The upstream module validates the
[full node pool schema](https://github.com/hcloud-k8s/terraform-hcloud-kubernetes/blob/6.4.0/variables.tf#L494)
and handles rescue mode and Talos installation on the specified servers. Use
dedicated machines whose disks can be reprovisioned. You can omit
`cluster.worker_pools` when all workers are dedicated.

If Argo CD manages Cilium through this repository's cluster chart, also render
with:

```yaml
cilium:
  bareMetal: true
```

This keeps the rendered Cilium routing mode aligned with the upstream Talos
bootstrap. When adding the first dedicated worker to an existing cluster,
coordinate the routing change and check pod connectivity across the two node
types. See the upstream notes on Cilium restarts and Robot firewalls.
[Upstream bare-metal guide](https://github.com/hcloud-k8s/terraform-hcloud-kubernetes/tree/6.4.0#bare-metal-server)
