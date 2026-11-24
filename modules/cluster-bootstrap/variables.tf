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
  description = "Public hostname for Argo CD and its Gateway API route."
  default     = null
}

# email is required for password login -otherwise only discord is supported
variable "email_enabled" {
  type    = bool
  default = false
}

variable "email_username" {
  type    = string
  default = null
}

variable "email_password" {
  type    = string
  default = null
}

check "email_username_set" {
  assert {
    condition     = !var.email_enabled || var.email_username != null
    error_message = "Ensure email_username is set"
  }
}

check "email_password_set" {
  assert {
    condition     = !var.email_enabled || var.email_password != null
    error_message = "Ensure email_password is set"
  }
}

variable "discord_client_id" {
  type    = string
  default = null
}

variable "discord_client_secret" {
  type    = string
  default = null
}

variable "discord_bot_token" {
  type    = string
  default = null
}

variable "berg" {
  type = object({
    enabled     = optional(bool, false)
    pull_secret = optional(string)
    backups = optional(object({
      enabled    = optional(bool, false)
      access_key = optional(string)
      secret_key = optional(string)
    }), {})
  })
  default = {}
}

check "pull_secret_set" {
  assert {
    condition     = !var.berg.enabled || var.berg.pull_secret != null
    error_message = "Ensure pull_secret is set"
  }
}

variable "authentik" {
  type = object({
    enabled = optional(bool, false)
    domain  = optional(string)
    backups = optional(object({
      enabled    = optional(bool, false)
      access_key = optional(string)
      secret_key = optional(string)
    }), {})
  })
  default = {}
}

variable "monitoring" {
  type = object({
    enabled         = optional(bool, false)
    discord_webhook = optional(string)
    loki = optional(object({
      enabled    = optional(bool, false)
      access_key = optional(string)
      secret_key = optional(string)
    }), {})
    mimir = optional(object({
      enabled    = optional(bool, false)
      access_key = optional(string)
      secret_key = optional(string)
    }), {})
    tempo = optional(object({
      enabled    = optional(bool, false)
      access_key = optional(string)
      secret_key = optional(string)
    }), {})
  })
  default = {}
}

variable "dns_api_token" {
  type      = string
  default   = null
  nullable  = true
  sensitive = true

  validation {
    condition = (
      !(var.cert_manager.enabled && var.cert_manager.dns_resolver.enabled || var.external_dns.enabled)
      || try(trimspace(var.dns_api_token) != "", false)
    )
    error_message = "Set dns_api_token when bootstrapping a DNS solver or External DNS."
  }
}

variable "cert_manager" {
  type = object({
    enabled = optional(bool, false)
    dns_resolver = optional(object({
      enabled = optional(bool, false)
    }), {})
  })
  default = {}
}

variable "external_dns" {
  type = object({
    enabled = optional(bool, false)
  })
  default = {}
}
