terraform {
  # required for "enabled" blocks
  required_version = ">= 1.11.0"
  required_providers {
    authentik = {
      source  = "goauthentik/authentik"
      version = ">= 2025.10.1"
    }
  }
}
