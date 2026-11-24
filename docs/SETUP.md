# Cluster setup

The [deployment guide](DEPLOYING.md) covers cluster provisioning and GitOps
bootstrap. The snippets below extend the inputs to the [root module](../README.md).

## Git access

Git authentication is supplied to the cluster as credentials.

### Forgejo over SSH

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
git_credentials     = var.forgejo_deploy_keys
git_ssh_known_hosts = file("${path.module}/forgejo_known_hosts")

cluster = {
  # Keep the other cluster settings.
  infra_repo = {
    url  = "ssh://git@forgejo.example.org/ctf/infrastructure.git"
    path = "manifests/example-prod"
  }
}

challenge_repo = "ssh://git@forgejo.example.org/ctf/challenges.git"
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

Argo CD polls Forgejo. For public HTTPS repositories, omit their SSH keys and
use HTTPS clone URLs. Omit the challenge URL and key from OpenTofu when the
challenge repository requires no Argo CD repository registration.

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

The Talos module selects tunnel routing automatically for dedicated workers.
It supplies Cilium, Hubble Relay, and the Hubble UI. Set
`cluster.cilium_helm_values` for overrides such as Cilium Prometheus settings.
[Upstream bare-metal guide](https://github.com/hcloud-k8s/terraform-hcloud-kubernetes/tree/6.4.0#bare-metal-server)

## Gateway

The cluster chart deploys kgateway and a shared Gateway named `gw-berg` in the
`berg` namespace. Point the platform and challenge DNS names at its Hetzner
load balancer. The Gateway serves HTTP on 80, HTTPS on 443, and challenge
traffic on 1337 (HTTPS) and 31337 (TLS termination).

With cert-manager enabled, the chart requests the `berg-gateway-tls`
certificate through its configured ClusterIssuer. If you disable cert-manager,
provide a TLS Secret named `berg-gateway-tls` in the `berg` namespace.

## Seed credentials and add-ons

OpenTofu writes the enabled seed credentials before Argo CD starts. Pass
`dns_api_token` into the root module for the default cert-manager DNS solver
and External DNS. Set the token through your deployment secret store. The
bootstrap module writes it to both namespaces, and cert-manager issues the
gateway certificate after DNS validation. Protect access to the OpenTofu state,
which contains the seeded credentials.

Keep workload configuration in the chart. Set `berg.enabled`,
`authentik.enabled`, and `monitoring.enabled` as module inputs when you use
those features, and pass their credentials through the corresponding inputs.
For a deployment that supplies its own TLS Secret or DNS records, disable the
matching bootstrap inputs (`cert_manager`, `external_dns`) and chart features.
For example, the chart can omit these optional workloads:

```yaml
berg:
  enabled: false
authentik:
  enabled: false
certManager:
  enabled: false
dns:
  externalDnsEnabled: false
```

The bootstrap module creates these Secrets when their corresponding options
are enabled. It generates the Authentik bootstrap token and OAuth client
secrets, and takes the DNS, registry, backup, and Discord credentials as inputs.

| Feature | Namespace | Secret | Keys |
| --- | --- | --- | --- |
| Berg image pulls | `berg` | `berg-pull-secret` | `.dockerconfigjson` with type `kubernetes.io/dockerconfigjson` |
| Berg OIDC | `berg` | `berg-client-secret` | `clientSecret` |
| Berg Discord | `berg` | `berg-discord-client`, `berg-discord-bot-token` | `clientId`, `clientSecret`; `token` |
| Berg database backups | `berg` | `database-berg-cluster-backup-s3-creds` | `ACCESS_KEY_ID`, `ACCESS_SECRET_KEY` |
| Authentik | `infra-authentik` | `authentik-extra-secret`, `authentik-bootstrap-token` | `secret_key`, optional `email_username`, `email_password`; `token` |
| Authentik database backups | `infra-authentik` | `database-authentik-cluster-backup-s3-creds` | `ACCESS_KEY_ID`, `ACCESS_SECRET_KEY` |
| DNS certificate solver | `infra-cert-manager` | `dns-api-key` | `api-token` |
| External DNS | `infra-external-dns` | `dns-api-key` | `api-token` |
| Argo CD OIDC | `infra-argocd` | `argocd-authentik-secret` | `oidc.authentik.clientSecret` |
| Grafana OIDC | `infra-monitoring` | `auth-generic-oauth-secret` | `client_id`, `client_secret` |
| Discord alerting | `infra-monitoring` | `discord-webhook` | `webhook` |
| Loki and Mimir storage | `infra-logging`, `infra-monitoring` | `loki-objectstorage-credentials`, `mimir-objectstorage-credentials` | `S3_ACCESS_KEY_ID`, `S3_SECRET_ACCESS_KEY` |
| Tempo storage | `infra-tracing` | `tracing-objectstorage-credentials` | `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` |

When Authentik is enabled, the root module uses those generated credentials
to configure the OIDC clients once the service is reachable. Argo CD uses the
seeded OIDC client secret, and optional `argocd_helm_values` can override SSO
settings.
Configure Kubernetes API OIDC only if needed:

```hcl
# In the cluster object
kube_api_oidc_providers = [{
  issuer_url     = "https://idp.prod.example.org/application/o/kubernetes-api/"
  audiences      = ["kubernetes-api"]
  username_claim = "email"
  groups_claim   = "groups"
  groups_prefix  = "oidc:"
}]
```
