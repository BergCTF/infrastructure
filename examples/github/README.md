# Optional GitHub repository automation

This OpenTofu root provisions read-only deploy keys and push webhooks on
existing GitHub repositories. Use a GitHub credential authorized to manage
keys and webhooks for the selected owner and supply it to the GitHub provider
through your normal credential store.

```hcl
github_owner     = "example"
argocd_url       = "https://argocd.prod.example.org"
deploy_key_title = "example-prod-argocd-credential"
repositories = {
  infrastructure = "infrastructure"
  challenges     = "challenges"
}
```

Run `tofu init` and plan this example with those variables before applying.
Read the sensitive `git_credentials` output in your secret delivery workflow
and pass that object as the core module's `git_credentials` input. Omit
`repositories.challenges` if you only need a key and webhook for the
infrastructure repository.

## Transfer an existing GitHub module

Use the previous deploy key title, which was
`<governance_name>-<env>-argocd-credential`. Back up the current state using
your backend's encrypted state backup procedure. Transfer the old
`module.<infrastructure-call>.module.github` state to `module.github` in
this example's state before applying either stack. Move the entire module so
the private keys and webhook secret are preserved alongside the GitHub
objects. Plan the destination first and check that it does not recreate keys
or webhooks. Securely supply the resulting `git_credentials` to the core
stack and review both plans before applying. When treating both calls as part
of one state, use a caller-level `moved` block with those same module
addresses instead of transferring state between backends.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.11.0 |
| <a name="requirement_github"></a> [github](#requirement\_github) | >= 6.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_github"></a> [github](#module\_github) | ../../modules/github | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_argocd_url"></a> [argocd\_url](#input\_argocd\_url) | Base URL of the Argo CD server. | `string` | n/a | yes |
| <a name="input_deploy_key_title"></a> [deploy\_key\_title](#input\_deploy\_key\_title) | Title used for this environment's deploy keys. | `string` | n/a | yes |
| <a name="input_github_owner"></a> [github\_owner](#input\_github\_owner) | GitHub organization or account that owns the repositories. | `string` | n/a | yes |
| <a name="input_repositories"></a> [repositories](#input\_repositories) | Repository names within the GitHub owner. | <pre>object({<br/>    infrastructure = string<br/>    challenges     = optional(string)<br/>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_git_credentials"></a> [git\_credentials](#output\_git\_credentials) | Pass this object to the infrastructure stack's git\_credentials input. |
<!-- END_TF_DOCS -->