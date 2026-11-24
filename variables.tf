# cross module variables
variable "env" {
  type        = string
  description = "Environment name, eg test"
}

variable "governance_name" {
  type        = string
  description = "Logical grouping of multiple environments"
}

# variables for cluster module
variable "hetzner_token" {
  type        = string
  description = "API Token for Hetzner infrastructure"
}

# cluster configuration
variable "cluster" {
  type = object({
    domain                                     = string
    kube_api_loadbalancer_enabled              = optional(bool, false)
    cluster_allow_scheduling_on_control_planes = optional(bool, false)

    control_plane_pools = list(object({
      name     = string
      type     = string
      location = string
      count    = number
    }))

    worker_pools = optional(list(object({
      name     = string
      type     = string
      location = string
      count    = number
      subnet   = optional(string)
    })), [])

    bare_metal_nodepools      = optional(any, [])
    bare_metal_config_patches = optional(list(string), [])
    hcloud_vswitch_id         = optional(number)

    kube_api_oidc_providers = optional(any, [])
    cilium_helm_values      = optional(any, {})

    infra_repo = object({
      url  = string
      path = string
    })
  })
}

variable "git_credentials" {
  type = object({
    infra_deploy_key     = optional(string)
    challenge_deploy_key = optional(string)
  })
  description = "Optional read-only Git SSH keys for Argo CD."
  default     = {}
  nullable    = false
  sensitive   = true
}

variable "challenge_repo" {
  type        = string
  description = "Optional challenge repository URL to register with Argo CD."
  default     = null
}

variable "git_ssh_known_hosts" {
  type        = string
  description = "Verified OpenSSH known_hosts entries for self-hosted Git servers."
  default     = ""
  nullable    = false
}

variable "hcloud_robot_user" {
  type        = string
  description = "Hetzner Robot web service username for dedicated workers."
  default     = null
}

variable "hcloud_robot_password" {
  type        = string
  description = "Hetzner Robot web service password for dedicated workers."
  default     = null
  sensitive   = true
}

variable "argocd_helm_values" {
  type        = any
  description = "Optional Helm settings for the Argo CD installation, such as SSO and resource limits."
  default     = {}
}

variable "berg" {
  type = object({
    enabled           = optional(bool, false)
    domain            = optional(string)
    challenge_repo    = optional(string)
    pull_secret       = optional(string)
    admin_access_only = optional(bool, true)
    redirect_uris     = optional(list(string), [])
    backups = optional(object({
      enabled    = optional(bool, false)
      access_key = optional(string)
      secret_key = optional(string)
    }), {})
    discord_bot_token = optional(string, null)
  })
  default = {}

  validation {
    condition     = !var.berg.enabled || try(trimspace(coalesce(var.challenge_repo, var.berg.challenge_repo)) != "", false)
    error_message = "Set challenge_repo when Berg is enabled."
  }
}

variable "harbor" {
  type = object({
    enabled    = optional(bool, false)
    domain     = optional(string)
    access_key = optional(string)
    secret_key = optional(string)
  })
  default = {}
}

variable "authentik" {
  type = object({
    enabled = optional(bool, false)
    domain  = optional(string)
    branding = optional(object({
      title               = optional(string, "")
      favicon             = optional(string, "")
      logo                = optional(string, "")
      background_image    = optional(string, "")
      default_application = optional(string, "")
    }), {})
    backups = optional(object({
      enabled    = optional(bool, false)
      access_key = optional(string)
      secret_key = optional(string)
    }), {})
    authentication = optional(object({
      # enable discord federated authentication
      discord = optional(object({
        # discord is currently required
        enabled = optional(bool, true)
        # required for role mappings
        guild_id      = optional(string)
        client_id     = optional(string)
        client_secret = optional(string)
        # arbitrary group -> discord role id mappings
        role_mappings = optional(map(string), {})
      }), {})
      # enable password authentication
      password = optional(object({
        enabled = optional(bool, false)
      }), {})
    }), {})
    # smtp configuration is required if password authentication is enabled
    smtp = optional(object({
      enabled  = optional(bool, false)
      username = optional(string, null)
      password = optional(string, null)
    }), {})
    # cloudflare turnstile captcha
    captcha = optional(object({
      enabled = optional(bool, false)
    }), {})
  })
  default = {}
}

variable "monitoring" {
  type = object({
    enabled         = optional(bool, false)
    discord_webhook = optional(string)
    domain          = optional(string)
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

variable "discord_client_id" {
  type     = string
  default  = null
  nullable = true
}
variable "discord_client_secret" {
  type     = string
  default  = null
  nullable = true
}

variable "dns_api_token" {
  type      = string
  default   = null
  nullable  = true
  sensitive = true
}

variable "cert_manager" {
  type = object({
    enabled = optional(bool, true)
    dns_resolver = optional(object({
      enabled = optional(bool, true)
    }), {})
  })
  default = {}
}

variable "external_dns" {
  description = "Opt in to seeding the External DNS API token."
  type = object({
    enabled = optional(bool, false)
  })
  default = {}
}
