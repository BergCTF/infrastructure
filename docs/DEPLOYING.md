# Deploying

## Upgrading an existing deployment

The cluster wrapper now uses Hcloud Kubernetes 6.4.0. Existing deployments on
3.20.1 should stage the major-version upgrades. Read the upstream migration
notes for [4.0](https://github.com/hcloud-k8s/terraform-hcloud-kubernetes/releases/tag/4.0.0),
[5.0](https://github.com/hcloud-k8s/terraform-hcloud-kubernetes/releases/tag/5.0.0),
and [6.0](https://github.com/hcloud-k8s/terraform-hcloud-kubernetes/releases/tag/6.0.0).
In particular, the v4 Talos configuration migration requires a rolling reboot.
For existing Hetzner Cloud worker pools, set each `cluster.worker_pools[*].subnet`
to its current CIDR before the v5 step to preserve subnet assignments. Review
the plan at each step for node or network replacement. Add dedicated workers
after the existing cluster upgrade is healthy.

The Argo CD chart is now 10.18.3 and the Talos CRD URLs are pinned to Argo CD
v3.6.2. For an existing cluster, follow the Argo CD upgrade guides for the
intermediate releases and update the installed Application, AppProject, and
ApplicationSet CRDs before upgrading the Helm release. The release delegates
CRD installation to Talos. [Argo CD upgrade guides](https://argo-cd.readthedocs.io/en/stable/operator-manual/upgrading/overview/)

## Switching to the simplified stack

Render and commit the new chart before retiring old Applications, so their
parent Applications stop generating them. Keep automated pruning off during
the handoff.

1. **Move repository credentials first.** Remove `github_enabled` from the
   caller and supply `git_credentials`. Move `berg.challenge_repo` to the
   top-level `challenge_repo` input if it needs Argo CD registration.
   Existing GitHub users can transfer the deploy-key, TLS key, and webhook
   state to the standalone GitHub example. Follow its
   [migration guide](../examples/github/README.md). Keep the existing webhook
   secret and deploy keys in use through the transition.
2. **Transfer add-on ownership.** The plan should forget the old add-on
   namespaces and Kubernetes secrets while preserving their live objects.
   The chart owns those namespaces and add-on manifests. Import or recreate
   the existing secrets in your secret delivery workflow before rotating
   anything. Remove the old `berg`, `authentik`, `harbor`, `monitoring`,
   `cert_manager`, `external_dns`, DNS and Discord inputs from the caller.
   Move any managed Authentik API resources to the standalone Authentik
   module via state migration if you want to keep managing them with OpenTofu.
   Explicitly carry over Kubernetes and Argo CD OIDC settings when in use.
   [Secret and OIDC settings](SETUP.md#add-ons-and-secrets)
3. **Hand Cilium back to Talos.** Disable automatic sync on the old Cilium
   Application and remove it with non-cascading deletion so CNI resources
   stay running. Preserve any custom Cilium values via
   `cluster.cilium_helm_values`. After applying the new machine config,
   reconcile bootstrap manifests on the current Kubernetes version using
   `talosctl upgrade-k8s --to <current-version>`. Preview with `--dry-run`
   first and check the agent, operator, and cross-node pod connectivity.
   [Talos bootstrap manifest update behavior](https://github.com/siderolabs/talos/discussions/7835)
4. **Hand Argo CD to the bootstrap release.** Ensure the old `app-argocd`
   GitOps Application stops syncing
   before applying the Helm release, then remove it without cascading.
   Transfer any custom Argo CD settings to `argocd_helm_values`. The
   `cluster-config` Application takes over the rendered root and AppProject
   directories. Remove the old `argocd-configs` and `appprojects` child
   Applications without cascading after the updated `misc-apps` stops
   generating them. Confirm the Argo CD hostname now routes to the
   `argocd-server` service and that login and repository access work.

During the handoff, keep cascading deletion and automated pruning off for
the superseded Applications. Review the plan and stop if it proposes deleting
add-on secrets or namespaces. Removed legacy deploy-key generators and passwords
in OpenTofu state can disappear after you have transferred the credentials each
consumer still uses.

## Initial deployment

Render and commit the cluster chart under `cluster.infra_repo.path`. That
directory should contain the rendered top-level Applications and the
`appprojects/` subdirectory. Use the same infrastructure URL and path in
the chart values so its child Applications can locate their manifests.

Provision the cluster first:

```bash
tofu plan -var-file ./envs/myenv.tfvars -target=module.berg-cluster.module.cluster
```

Once the Kubernetes API is reachable, run a normal plan and apply the reviewed
changes. The Argo CD Helm install creates the root Application and AppProject.
Argo CD then reads the committed manifests and deploys the add-ons. See the
[setup guide](SETUP.md) for Forgejo, dedicated workers, and add-on secrets.
