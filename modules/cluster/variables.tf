# cross module variables
variable "env" {
  type        = string
  description = "Environment name, eg test"
}

variable "governance_name" {
  type        = string
  description = "Logical grouping of multiple environments"
}

variable "hetzner_token" {
  type        = string
  description = "Hetzner API token for cluster provisioning"
}

check "hetzner_token_set" {
  assert {
    condition     = var.hetzner_token != null
    error_message = "Ensure hetzner_token is set"
  }
}

variable "control_plane_pools" {
  type = list(object({
    name     = string
    type     = string
    location = string
    count    = number
  }))
}

variable "worker_pools" {
  type = list(object({
    name     = string
    type     = string
    location = string
    count    = number
    subnet   = optional(string)
  }))
  default = []
}

variable "cluster_domain" {
  type = string
}

variable "kube_api_loadbalancer_enabled" {
  type = bool
}

variable "cluster_allow_scheduling_on_control_planes" {
  type = bool
}

variable "bare_metal_nodepools" {
  description = "Hetzner Robot worker pools using the upstream hcloud-k8s bare_metal_nodepools schema."
  type        = any
  default     = []
}

variable "bare_metal_config_patches" {
  description = "Talos configuration patches applied to all bare-metal workers."
  type        = list(string)
  default     = []
}

variable "hcloud_vswitch_id" {
  description = "Existing Hetzner Robot vSwitch ID. The upstream module creates one by default when bare-metal workers are configured."
  type        = number
  default     = null
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

variable "kube_api_oidc_providers" {
  type        = any
  description = "Optional Kubernetes API OIDC issuers using the upstream hcloud-k8s schema."
  default     = []
}

variable "cilium_helm_values" {
  type        = any
  description = "Optional Helm overrides for the Cilium installation managed by Talos."
  default     = {}
}
