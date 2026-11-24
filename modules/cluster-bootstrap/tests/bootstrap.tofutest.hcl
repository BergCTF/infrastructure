mock_provider "kubernetes" {}
mock_provider "helm" {}
mock_provider "random" {}

variables {
  infra_repo                = "ssh://git@forgejo.example.org/ctf/infrastructure.git"
  infra_repo_path           = "manifests/example-prod"
  infra_repo_deploy_key     = "fake-infrastructure-key"
  challenge_repo            = "ssh://git@forgejo.example.org/ctf/challenges.git"
  challenge_repo_deploy_key = "fake-challenge-key"
  git_ssh_known_hosts       = "forgejo.example.org ssh-ed25519 mock-host-key"
  argocd_domain             = "argocd.example.org"

}

run "private_gitops_seed" {
  command = plan

  assert {
    condition     = kubernetes_secret_v1.argocd_infra_repo.data.sshPrivateKey == var.infra_repo_deploy_key && kubernetes_secret_v1.argocd_challenge_repo.data.sshPrivateKey == var.challenge_repo_deploy_key
    error_message = "The configured private keys must reach both repository secrets."
  }

  assert {
    condition = (
      yamldecode(helm_release.infra_argocd.values[2]).extraObjects[0].spec.sourceRepos[0] == var.infra_repo &&
      yamldecode(helm_release.infra_argocd.values[2]).extraObjects[1].spec.sources[1].path == "manifests/example-prod/appprojects" &&
      yamldecode(helm_release.infra_argocd.values[2]).configs.ssh.extraHosts == var.git_ssh_known_hosts
    )
    error_message = "The Argo CD release must install the scoped seed and Forgejo host key."
  }
}

run "public_gitops_seed" {
  command = plan

  variables {
    infra_repo                = "https://forgejo.example.org/ctf/infrastructure.git"
    infra_repo_deploy_key     = null
    challenge_repo            = null
    challenge_repo_deploy_key = null

  }

  assert {
    condition     = !contains(keys(kubernetes_secret_v1.argocd_infra_repo.data), "sshPrivateKey")
    error_message = "A public repository must work without an SSH key."
  }
}

run "seed_credentials" {
  command = plan

  variables {
    dns_api_token = "test-dns-token"
    cert_manager  = { enabled = true, dns_resolver = { enabled = true } }
    external_dns  = { enabled = true }
    authentik     = { enabled = true, domain = "idp.example.org" }
  }

  assert {
    condition = (
      kubernetes_secret_v1.cloudflare_api_token.metadata[0].namespace == "infra-cert-manager" &&
      kubernetes_secret_v1.ed_dns_api_token.metadata[0].namespace == "infra-external-dns" &&
      kubernetes_secret_v1.cloudflare_api_token.data["api-token"] == var.dns_api_token &&
      kubernetes_secret_v1.ed_dns_api_token.data["api-token"] == var.dns_api_token
    )
    error_message = "Bootstrap must write the DNS token to both namespaces."
  }

  assert {
    condition = (
      kubernetes_secret_v1.authentik_bootstrap_token.data.token == output.authentik_bootstrap_token &&
      kubernetes_secret_v1.argocd_authentik_secret.data["oidc.authentik.clientSecret"] == output.argocd_client_secret &&
      yamldecode(yamldecode(helm_release.infra_argocd.values[0]).configs.cm["oidc.config"]).issuer == "https://idp.example.org/application/o/argocd/"
    )
    error_message = "Bootstrap must seed the Authentik token and connect the Argo CD OIDC client."
  }
}

run "dns_token_required" {
  command = plan

  variables {
    cert_manager = { enabled = true, dns_resolver = { enabled = true } }
  }

  expect_failures = [var.dns_api_token]
}
