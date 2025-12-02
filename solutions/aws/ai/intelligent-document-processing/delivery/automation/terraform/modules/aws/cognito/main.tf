#------------------------------------------------------------------------------
# AWS Cognito User Pool Module
#------------------------------------------------------------------------------
# Creates Cognito User Pool for IDP API authentication
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Local Variables - Resolve grouped vs individual variables
#------------------------------------------------------------------------------
# When var.auth is provided, use it; otherwise fall back to individual variables
locals {
  # Use grouped auth config if provided, otherwise use individual variables
  auth = var.auth != null ? var.auth : {
    enabled                    = true
    username_attributes        = var.username_attributes
    auto_verified_attributes   = var.auto_verified_attributes
    password_minimum_length    = var.password_minimum_length
    password_require_lowercase = var.password_require_lowercase
    password_require_numbers   = var.password_require_numbers
    password_require_symbols   = var.password_require_symbols
    password_require_uppercase = var.password_require_uppercase
    mfa_configuration          = var.mfa_configuration
    advanced_security_mode     = var.advanced_security_mode
    domain                     = var.domain
    callback_urls              = []
    logout_urls                = []
  }
}

resource "aws_cognito_user_pool" "this" {
  name = var.user_pool_name

  # Username configuration
  username_attributes      = local.auth.username_attributes
  auto_verified_attributes = local.auth.auto_verified_attributes

  # Account recovery
  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  # Admin create user config
  admin_create_user_config {
    allow_admin_create_user_only = var.allow_admin_create_user_only

    invite_message_template {
      email_subject = var.invite_email_subject
      email_message = var.invite_email_message
      sms_message   = var.invite_sms_message
    }
  }

  # Password policy
  password_policy {
    minimum_length                   = local.auth.password_minimum_length
    require_lowercase                = local.auth.password_require_lowercase
    require_numbers                  = local.auth.password_require_numbers
    require_symbols                  = local.auth.password_require_symbols
    require_uppercase                = local.auth.password_require_uppercase
    temporary_password_validity_days = var.temporary_password_validity_days
  }

  # MFA configuration
  mfa_configuration = local.auth.mfa_configuration

  dynamic "software_token_mfa_configuration" {
    for_each = local.auth.mfa_configuration != "OFF" ? [1] : []
    content {
      enabled = true
    }
  }

  # Device tracking
  device_configuration {
    challenge_required_on_new_device      = var.device_challenge_required
    device_only_remembered_on_user_prompt = var.device_remember_on_prompt
  }

  # User attribute schema
  dynamic "schema" {
    for_each = var.custom_attributes
    content {
      name                     = schema.value.name
      attribute_data_type      = schema.value.attribute_data_type
      developer_only_attribute = lookup(schema.value, "developer_only_attribute", false)
      mutable                  = lookup(schema.value, "mutable", true)
      required                 = lookup(schema.value, "required", false)

      dynamic "string_attribute_constraints" {
        for_each = schema.value.attribute_data_type == "String" ? [1] : []
        content {
          min_length = lookup(schema.value, "min_length", 0)
          max_length = lookup(schema.value, "max_length", 2048)
        }
      }

      dynamic "number_attribute_constraints" {
        for_each = schema.value.attribute_data_type == "Number" ? [1] : []
        content {
          min_value = lookup(schema.value, "min_value", null)
          max_value = lookup(schema.value, "max_value", null)
        }
      }
    }
  }

  # Email configuration
  email_configuration {
    email_sending_account  = var.ses_email_identity != null ? "DEVELOPER" : "COGNITO_DEFAULT"
    source_arn             = var.ses_email_identity
    from_email_address     = var.from_email_address
    reply_to_email_address = var.reply_to_email_address
  }

  # Verification message template
  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
    email_subject        = var.verification_email_subject
    email_message        = var.verification_email_message
  }

  # Lambda triggers
  dynamic "lambda_config" {
    for_each = length(var.lambda_triggers) > 0 ? [1] : []
    content {
      pre_sign_up                    = lookup(var.lambda_triggers, "pre_sign_up", null)
      post_confirmation              = lookup(var.lambda_triggers, "post_confirmation", null)
      pre_authentication             = lookup(var.lambda_triggers, "pre_authentication", null)
      post_authentication            = lookup(var.lambda_triggers, "post_authentication", null)
      pre_token_generation           = lookup(var.lambda_triggers, "pre_token_generation", null)
      custom_message                 = lookup(var.lambda_triggers, "custom_message", null)
      define_auth_challenge          = lookup(var.lambda_triggers, "define_auth_challenge", null)
      create_auth_challenge          = lookup(var.lambda_triggers, "create_auth_challenge", null)
      verify_auth_challenge_response = lookup(var.lambda_triggers, "verify_auth_challenge_response", null)
      user_migration                 = lookup(var.lambda_triggers, "user_migration", null)
    }
  }

  # Advanced security (for WAF integration)
  user_pool_add_ons {
    advanced_security_mode = local.auth.advanced_security_mode
  }

  # Deletion protection
  deletion_protection = var.deletion_protection

  tags = merge(var.common_tags, {
    Name = var.user_pool_name
  })
}

#------------------------------------------------------------------------------
# User Pool Domain
#------------------------------------------------------------------------------
resource "aws_cognito_user_pool_domain" "this" {
  count = local.auth.domain != null && local.auth.domain != "" ? 1 : 0

  domain          = local.auth.domain
  certificate_arn = var.domain_certificate_arn
  user_pool_id    = aws_cognito_user_pool.this.id
}

#------------------------------------------------------------------------------
# User Pool Client
#------------------------------------------------------------------------------
resource "aws_cognito_user_pool_client" "this" {
  for_each = var.clients

  name         = each.key
  user_pool_id = aws_cognito_user_pool.this.id

  # Client secret
  generate_secret = each.value.generate_secret

  # Token validity
  access_token_validity  = lookup(each.value, "access_token_validity", 1)
  id_token_validity      = lookup(each.value, "id_token_validity", 1)
  refresh_token_validity = lookup(each.value, "refresh_token_validity", 30)

  token_validity_units {
    access_token  = "hours"
    id_token      = "hours"
    refresh_token = "days"
  }

  # OAuth configuration
  allowed_oauth_flows_user_pool_client = lookup(each.value, "allowed_oauth_flows", null) != null
  allowed_oauth_flows                  = lookup(each.value, "allowed_oauth_flows", [])
  allowed_oauth_scopes                 = lookup(each.value, "allowed_oauth_scopes", [])
  callback_urls                        = lookup(each.value, "callback_urls", [])
  logout_urls                          = lookup(each.value, "logout_urls", [])
  supported_identity_providers         = lookup(each.value, "identity_providers", ["COGNITO"])

  # Auth flows
  explicit_auth_flows = lookup(each.value, "explicit_auth_flows", [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ])

  # Security
  prevent_user_existence_errors = "ENABLED"
  enable_token_revocation       = true

  # Read/write attributes
  read_attributes  = lookup(each.value, "read_attributes", null)
  write_attributes = lookup(each.value, "write_attributes", null)
}

#------------------------------------------------------------------------------
# Resource Server (for custom scopes)
#------------------------------------------------------------------------------
resource "aws_cognito_resource_server" "this" {
  for_each = var.resource_servers

  identifier   = each.value.identifier
  name         = each.key
  user_pool_id = aws_cognito_user_pool.this.id

  dynamic "scope" {
    for_each = each.value.scopes
    content {
      scope_name        = scope.value.name
      scope_description = scope.value.description
    }
  }
}

#------------------------------------------------------------------------------
# User Groups
#------------------------------------------------------------------------------
resource "aws_cognito_user_group" "this" {
  for_each = var.user_groups

  name         = each.key
  description  = lookup(each.value, "description", null)
  precedence   = lookup(each.value, "precedence", null)
  role_arn     = lookup(each.value, "role_arn", null)
  user_pool_id = aws_cognito_user_pool.this.id
}
