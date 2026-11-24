variable "infra_repo" {
  type        = string
  description = "url of argocd infra repo"
}

variable "infra_repo_deploy_key" {
  type        = string
  description = "Infrastructure repository SSH key. Optional for public HTTPS repositories."
  default     = null
  sensitive   = true
}

variable "infra_repo_path" {
  type        = string
  description = "path in argocd infra repo"
}

variable "argocd_webhook_secret" {
  type        = string
  description = "GitHub webhook secret for Argo CD."
  default     = null
  sensitive   = true
}

variable "challenge_repo" {
  type        = string
  description = "Optional challenge repository URL to register with Argo CD."
  default     = null
}

variable "challenge_repo_deploy_key" {
  type        = string
  description = "SSH private key for a private challenge repository."
  default     = null
  sensitive   = true
}

variable "git_ssh_known_hosts" {
  type        = string
  description = "Verified OpenSSH known_hosts entries for self-hosted Git servers."
  default     = ""
}

variable "argocd_helm_values" {
  type        = any
  description = "Optional Helm settings for the Argo CD installation, such as SSO and resource limits."
  default     = {}
}

variable "argocd_domain" {
  type        = string
  description = "Public hostname of the Argo CD installation."
  default     = null
}
