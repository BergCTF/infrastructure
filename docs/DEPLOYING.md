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

## Initial deployment

Create the Git repositories and render and commit the cluster manifests. The
[setup guide](SETUP.md) shows how to configure Forgejo and dedicated workers.

Plan the initial cluster in isolation so the Kubernetes API exists before
OpenTofu discovers resources for bootstrap. Adapt the module prefix to your
configuration.

```bash
tofu plan -var-file ./envs/myenv.tfvars -target=module.berg-cluster.module.cluster
```

After creating the cluster, plan without the target to bootstrap Kubernetes
and Argo CD. If Authentik will be managed through this stack, defer its API
configuration until the service is reachable.

```bash
tofu plan -var-file ./envs/myenv.tfvars -exclude=module.berg-cluster.module.authentik
tofu plan -var-file ./envs/myenv.tfvars
```

Review each plan before applying the corresponding configuration.
