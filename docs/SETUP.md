# Cluster setup

The [deployment guide](DEPLOYING.md) covers cluster provisioning and GitOps
bootstrap. The snippets below extend the inputs to the [root module](../README.md).

## Git access

Git authentication is supplied to the cluster as credentials. For GitHub-managed
deploy keys and a push webhook, use the [standalone GitHub example](../examples/github/README.md).

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

## Add-ons and secrets

Deploy add-ons from the rendered cluster chart. Keep feature configuration in
Helm values and provide credentials from your secret manager. For a smaller
deployment, use these optional chart settings:

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

The chart keeps its previous enablement defaults. Supply the Secret names and
keys below for the features you use. Create them in the listed namespaces
through your existing Kubernetes secret delivery workflow.

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
| Grafana OIDC | `infra-monitoring` | `auth-generic-oauth-secret` | `client_id`, `client_secret` |
| Discord alerting | `infra-monitoring` | `discord-webhook` | `webhook` |
| Loki and Mimir storage | `infra-logging`, `infra-monitoring` | `loki-objectstorage-credentials`, `mimir-objectstorage-credentials` | `S3_ACCESS_KEY_ID`, `S3_SECRET_ACCESS_KEY` |
| Tempo storage | `infra-tracing` | `tracing-objectstorage-credentials` | `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` |

Create Authentik clients through a blueprint or the [standalone Authentik
module](../modules/authentik/README.md) once the service is reachable. Match
the client secrets in Authentik to the secrets used by the applications.
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

Argo CD itself is managed by the bootstrap Helm release. Set
`argocd_helm_values.configs.cm` for OIDC, and
`argocd_helm_values.configs.rbac` for claims-based authorization. For example:

```hcl
argocd_helm_values = {
  configs = {
    cm = {
      "oidc.config" = yamlencode({
        name            = "Authentik"
        issuer          = "https://idp.prod.example.org/application/o/argocd/"
        clientID        = "argocd"
        clientSecret    = "$argocd-authentik-secret:oidc.authentik.clientSecret"
        requestedScopes = ["openid", "profile", "email", "groups"]
      })
    }
    rbac = {
      "policy.csv" = "g, berg-admins, role:admin"
      "scopes"     = "[groups]"
    }
  }
}
```

For this example, populate the `argocd-authentik-secret` Secret in
`infra-argocd` with the key `oidc.authentik.clientSecret` and label it
`app.kubernetes.io/part-of: argocd`. Verify group-based sign-in before
disabling the local Argo CD administrator.
