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
    infra_deploy_key      = optional(string)
    challenge_deploy_key  = optional(string)
    argocd_webhook_secret = optional(string)
  })
  description = "Optional read-only Git SSH keys and GitHub webhook secret for Argo CD."
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
