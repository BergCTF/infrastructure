# Deploying

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
