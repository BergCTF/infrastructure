# Authentik module

Configures Authentik login, branding, groups, and OIDC clients. The caller
configures and passes the `goauthentik/authentik` provider with the service URL
and API token. Run this module after Authentik is reachable. The platform root module can
wire this automatically using the credentials generated during bootstrap.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.11.0 |
| <a name="requirement_authentik"></a> [authentik](#requirement\_authentik) | >= 2025.10.1 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_authentik"></a> [authentik](#provider\_authentik) | >= 2025.10.1 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [authentik_application.oidc_app](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/resources/application) | resource |
| [authentik_brand.branding](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/resources/brand) | resource |
| [authentik_flow.berg_authentication_flow](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/resources/flow) | resource |
| [authentik_flow.berg_enrollment_flow](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/resources/flow) | resource |
| [authentik_flow.berg_recovery_flow](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/resources/flow) | resource |
| [authentik_flow.settings_flow](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/resources/flow) | resource |
| [authentik_flow_stage_binding.authenticate_identification](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/resources/flow_stage_binding) | resource |
| [authentik_flow_stage_binding.authenticate_password](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/resources/flow_stage_binding) | resource |
| [authentik_flow_stage_binding.authenticate_user_login](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/resources/flow_stage_binding) | resource |
| [authentik_flow_stage_binding.recovery_email](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/resources/flow_stage_binding) | resource |
| [authentik_flow_stage_binding.recovery_identification](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/resources/flow_stage_binding) | resource |
| [authentik_flow_stage_binding.recovery_password](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/resources/flow_stage_binding) | resource |
| [authentik_flow_stage_binding.recovery_user_login](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/resources/flow_stage_binding) | resource |
| [authentik_flow_stage_binding.recovery_user_write](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/resources/flow_stage_binding) | resource |
| [authentik_flow_stage_binding.register_captcha](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/resources/flow_stage_binding) | resource |
| [authentik_flow_stage_binding.register_email_verification](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/resources/flow_stage_binding) | resource |
| [authentik_flow_stage_binding.register_prompt_first](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/resources/flow_stage_binding) | resource |
| [authentik_flow_stage_binding.register_user_login](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/resources/flow_stage_binding) | resource |
| [authentik_flow_stage_binding.register_user_write](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/resources/flow_stage_binding) | resource |
| [authentik_flow_stage_binding.settings_prompt](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/resources/flow_stage_binding) | resource |
| [authentik_flow_stage_binding.settings_write](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/resources/flow_stage_binding) | resource |
| [authentik_group.groups](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/resources/group) | resource |
| [authentik_policy_binding.authenticate_password_stage](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/resources/policy_binding) | resource |
| [authentik_policy_binding.discord_role_mapping_authentication](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/resources/policy_binding) | resource |
| [authentik_policy_binding.discord_role_mapping_enrollment](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/resources/policy_binding) | resource |
| [authentik_policy_binding.group_access](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/resources/policy_binding) | resource |
| [authentik_policy_binding.recovery_binding_email](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/resources/policy_binding) | resource |
| [authentik_policy_binding.recovery_binding_identification](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/resources/policy_binding) | resource |
| [authentik_policy_binding.settings_access_player](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/resources/policy_binding) | resource |
| [authentik_policy_expression.berg_authentication_password_stage](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/resources/policy_expression) | resource |
| [authentik_policy_expression.berg_recovery_skip_if_restored](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/resources/policy_expression) | resource |
| [authentik_policy_expression.discord_role_mapping_authentication](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/resources/policy_expression) | resource |
| [authentik_policy_expression.discord_role_mapping_enrollment](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/resources/policy_expression) | resource |
| [authentik_property_mapping_provider_scope.role_scope_mapping](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/resources/property_mapping_provider_scope) | resource |
| [authentik_provider_oauth2.oidc_provider](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/resources/provider_oauth2) | resource |
| [authentik_source_oauth.discord](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/resources/source_oauth) | resource |
| [authentik_stage_captcha.cloudflare_captcha](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/resources/stage_captcha) | resource |
| [authentik_stage_email.berg_recovery_email](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/resources/stage_email) | resource |
| [authentik_stage_email.register_email_verification](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/resources/stage_email) | resource |
| [authentik_stage_identification.berg_recovery_identification](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/resources/stage_identification) | resource |
| [authentik_stage_identification.user_identification](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/resources/stage_identification) | resource |
| [authentik_stage_password.berg_authentication_password](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/resources/stage_password) | resource |
| [authentik_stage_prompt.berg_recovery_prompt_password](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/resources/stage_prompt) | resource |
| [authentik_stage_prompt.prompt_first](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/resources/stage_prompt) | resource |
| [authentik_stage_prompt.user_settings](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/resources/stage_prompt) | resource |
| [authentik_stage_prompt_field.prompt_field_email](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/resources/stage_prompt_field) | resource |
| [authentik_stage_prompt_field.prompt_field_password](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/resources/stage_prompt_field) | resource |
| [authentik_stage_prompt_field.prompt_field_password_repeat](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/resources/stage_prompt_field) | resource |
| [authentik_stage_prompt_field.prompt_field_settings_email](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/resources/stage_prompt_field) | resource |
| [authentik_stage_prompt_field.prompt_field_settings_username](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/resources/stage_prompt_field) | resource |
| [authentik_stage_prompt_field.prompt_field_username](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/resources/stage_prompt_field) | resource |
| [authentik_stage_user_login.user_login](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/resources/stage_user_login) | resource |
| [authentik_stage_user_write.berg_recovery_user_write](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/resources/stage_user_write) | resource |
| [authentik_stage_user_write.register_user_write](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/resources/stage_user_write) | resource |
| [authentik_stage_user_write.settings_user_write](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/resources/stage_user_write) | resource |
| [authentik_certificate_key_pair.generated](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/data-sources/certificate_key_pair) | data source |
| [authentik_flow.default_authorization_flow](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/data-sources/flow) | data source |
| [authentik_flow.default_enrollment_flow](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/data-sources/flow) | data source |
| [authentik_flow.default_invalidation_flow](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/data-sources/flow) | data source |
| [authentik_flow.default_source_authentication](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/data-sources/flow) | data source |
| [authentik_property_mapping_provider_scope.openid_email](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/data-sources/property_mapping_provider_scope) | data source |
| [authentik_property_mapping_provider_scope.openid_openid](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/data-sources/property_mapping_provider_scope) | data source |
| [authentik_property_mapping_provider_scope.openid_profile](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/data-sources/property_mapping_provider_scope) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_authentik"></a> [authentik](#input\_authentik) | n/a | <pre>object({<br/>    enabled = bool<br/>    domain  = optional(string)<br/>    branding = object({<br/>      title               = string<br/>      favicon             = string<br/>      logo                = string<br/>      background_image    = string<br/>      default_application = string<br/>    })<br/>    backups = object({<br/>      enabled    = optional(bool, false)<br/>      access_key = optional(string)<br/>      secret_key = optional(string)<br/>    })<br/>  })</pre> | n/a | yes |
| <a name="input_bootstrap"></a> [bootstrap](#input\_bootstrap) | n/a | <pre>object({<br/>    default_group = string<br/>    groups = optional(map(object({<br/>      is_superuser = optional(bool, false)<br/>    })), {})<br/>    oidc_clients = optional(map(object({<br/>      name            = string<br/>      client_id       = string<br/>      client_secret   = optional(string)<br/>      redirect_uris   = list(string)<br/>      limit_to_groups = optional(list(string), [])<br/>      launch_url      = optional(string, "")<br/>      slug            = string<br/>      extra_scope_mappings = optional(map(object({<br/>        scope_name = string<br/>        expression = string<br/>      })), {})<br/>    })), {})<br/>    authentication = optional(object({<br/>      # enable discord federated authentication<br/>      discord = optional(object({<br/>        # discord is currently required<br/>        enabled = optional(bool, true)<br/>        # required for role mappings<br/>        guild_id = optional(string)<br/>        # arbitrary group -> discord role id mappings<br/>        role_mappings = optional(map(string), {})<br/>        client_id     = optional(string)<br/>        client_secret = optional(string)<br/>      }), {})<br/>      # enable password authentication<br/>      password = optional(object({<br/>        enabled = optional(bool, false)<br/>      }), {})<br/>    }), {})<br/>    # smtp configuration is required if password authentication is enabled<br/>    smtp = optional(object({<br/>      enabled = optional(bool, false)<br/>    }), {})<br/>    # cloudflare turnstile captcha<br/>    captcha = optional(object({<br/>      enabled     = optional(bool, false)<br/>      private_key = optional(string, "")<br/>      public_key  = optional(string, "")<br/>      api_url     = optional(string, "")<br/>      js_url      = optional(string, "")<br/>    }), {})<br/>  })</pre> | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->