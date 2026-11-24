# Deploying

## Initial deployment

Render and commit the cluster chart under `cluster.infra_repo.path`. That
directory should contain the rendered top-level Applications and the
`appprojects/` subdirectory. Use the same infrastructure URL and path in
the chart values so its child Applications can locate their manifests.

Supply `dns_api_token` through your deployment environment for the default
cert-manager DNS solver. Provision the cluster first:

```bash
tofu plan -var-file ./envs/myenv.tfvars -target=module.berg-cluster.module.cluster
```

Once the Kubernetes API is reachable, run a normal plan and apply the reviewed
changes. If Authentik is enabled, exclude its API configuration during this
pass (`-exclude=module.berg-cluster.module.authentik`), since the service will
come up through GitOps. OpenTofu creates the seed Secrets before the Argo CD
Helm release. Argo CD then syncs the committed manifests, including cert-manager
and the gateway Certificate.

Once Argo CD creates the Certificate, wait for TLS to be ready:

```bash
kubectl -n berg wait --for=condition=Ready certificate/berg-gateway-tls --timeout=10m
```

After DNS resolves and Authentik is reachable over HTTPS, plan and apply again
with Authentik API configuration included. See the [setup guide](SETUP.md) for
Forgejo, dedicated workers, and seed credential inputs.
