#------------------------------------------------------------------------------
# AWS Cognito User Pool Module - Variables
#------------------------------------------------------------------------------

variable "user_pool_name" {
  description = "Name of the Cognito User Pool"
  type        = string
}

#------------------------------------------------------------------------------
# Grouped Auth Configuration (preferred - pass entire object)
#------------------------------------------------------------------------------

variable "auth" {
  description = "Grouped authentication configuration (overrides individual variables)"
  type = object({
    enabled                    = optional(bool, true)
    username_attributes        = optional(list(string), ["email"])
    auto_verified_attributes   = optional(list(string), ["email"])
    password_minimum_length    = optional(number, 12)
    password_require_lowercase = optional(bool, true)
    password_require_numbers   = optional(bool, true)
    password_require_symbols   = optional(bool, true)
    password_require_uppercase = optional(bool, true)
    mfa_configuration          = optional(string, "OPTIONAL")
    advanced_security_mode     = optional(string, "AUDIT")
    domain                     = optional(string)
    callback_urls              = optional(list(string), [])
    logout_urls                = optional(list(string), [])
  })
  default = null
}

#------------------------------------------------------------------------------
# Username Configuration
#------------------------------------------------------------------------------

variable "username_attributes" {
  description = "Attributes for username (email, phone_number, or both)"
  type        = list(string)
  default     = ["email"]
}

variable "auto_verified_attributes" {
  description = "Attributes to auto-verify"
  type        = list(string)
  default     = ["email"]
}

#------------------------------------------------------------------------------
# Admin Configuration
#------------------------------------------------------------------------------

variable "allow_admin_create_user_only" {
  description = "Only admins can create users"
  type        = bool
  default     = false
}

variable "invite_email_subject" {
  description = "Subject for invitation email"
  type        = string
  default     = "Your temporary password"
}

variable "invite_email_message" {
  description = "Body for invitation email (must contain {username} and {####})"
  type        = string
  default     = "Your username is {username} and temporary password is {####}."
}

variable "invite_sms_message" {
  description = "SMS invitation message"
  type        = string
  default     = "Your username is {username} and temporary password is {####}."
}

#------------------------------------------------------------------------------
# Password Policy
#------------------------------------------------------------------------------

variable "password_minimum_length" {
  description = "Minimum password length"
  type        = number
  default     = 12
}

variable "password_require_lowercase" {
  description = "Require lowercase in password"
  type        = bool
  default     = true
}

variable "password_require_numbers" {
  description = "Require numbers in password"
  type        = bool
  default     = true
}

variable "password_require_symbols" {
  description = "Require symbols in password"
  type        = bool
  default     = true
}

variable "password_require_uppercase" {
  description = "Require uppercase in password"
  type        = bool
  default     = true
}

variable "temporary_password_validity_days" {
  description = "Days temporary password is valid"
  type        = number
  default     = 7
}

#------------------------------------------------------------------------------
# MFA Configuration
#------------------------------------------------------------------------------

variable "mfa_configuration" {
  description = "MFA configuration: OFF, ON, or OPTIONAL"
  type        = string
  default     = "OPTIONAL"

  validation {
    condition     = contains(["OFF", "ON", "OPTIONAL"], var.mfa_configuration)
    error_message = "MFA configuration must be OFF, ON, or OPTIONAL."
  }
}

#------------------------------------------------------------------------------
# Device Configuration
#------------------------------------------------------------------------------

variable "device_challenge_required" {
  description = "Require device challenge on new device"
  type        = bool
  default     = true
}

variable "device_remember_on_prompt" {
  description = "Only remember device on user prompt"
  type        = bool
  default     = true
}

#------------------------------------------------------------------------------
# Custom Attributes
#------------------------------------------------------------------------------

variable "custom_attributes" {
  description = "List of custom user attributes"
  type = list(object({
    name                     = string
    attribute_data_type      = string # String, Number, DateTime, Boolean
    developer_only_attribute = optional(bool, false)
    mutable                  = optional(bool, true)
    required                 = optional(bool, false)
    min_length               = optional(number)
    max_length               = optional(number)
    min_value                = optional(number)
    max_value                = optional(number)
  }))
  default = []
}

#------------------------------------------------------------------------------
# Email Configuration
#------------------------------------------------------------------------------

variable "ses_email_identity" {
  description = "SES email identity ARN for sending emails"
  type        = string
  default     = null
}

variable "from_email_address" {
  description = "From email address"
  type        = string
  default     = null
}

variable "reply_to_email_address" {
  description = "Reply-to email address"
  type        = string
  default     = null
}

variable "verification_email_subject" {
  description = "Subject for verification email"
  type        = string
  default     = "Your verification code"
}

variable "verification_email_message" {
  description = "Body for verification email (must contain {####})"
  type        = string
  default     = "Your verification code is {####}."
}

#------------------------------------------------------------------------------
# Lambda Triggers
#------------------------------------------------------------------------------

variable "lambda_triggers" {
  description = "Map of Lambda trigger ARNs"
  type        = map(string)
  default     = {}
}

#------------------------------------------------------------------------------
# Advanced Security
#------------------------------------------------------------------------------

variable "advanced_security_mode" {
  description = "Advanced security mode: OFF, AUDIT, or ENFORCED"
  type        = string
  default     = "AUDIT"

  validation {
    condition     = contains(["OFF", "AUDIT", "ENFORCED"], var.advanced_security_mode)
    error_message = "Advanced security mode must be OFF, AUDIT, or ENFORCED."
  }
}

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = string
  default     = "ACTIVE"

  validation {
    condition     = contains(["ACTIVE", "INACTIVE"], var.deletion_protection)
    error_message = "Deletion protection must be ACTIVE or INACTIVE."
  }
}

#------------------------------------------------------------------------------
# Domain Configuration
#------------------------------------------------------------------------------

variable "domain" {
  description = "Cognito domain prefix (or custom domain)"
  type        = string
  default     = null
}

variable "domain_certificate_arn" {
  description = "ACM certificate ARN for custom domain"
  type        = string
  default     = null
}

#------------------------------------------------------------------------------
# User Pool Clients
#------------------------------------------------------------------------------

variable "clients" {
  description = "Map of user pool client configurations"
  type = map(object({
    generate_secret        = optional(bool, false)
    access_token_validity  = optional(number, 1)
    id_token_validity      = optional(number, 1)
    refresh_token_validity = optional(number, 30)
    allowed_oauth_flows    = optional(list(string))
    allowed_oauth_scopes   = optional(list(string))
    callback_urls          = optional(list(string))
    logout_urls            = optional(list(string))
    identity_providers     = optional(list(string), ["COGNITO"])
    explicit_auth_flows    = optional(list(string))
    read_attributes        = optional(list(string))
    write_attributes       = optional(list(string))
  }))
  default = {}
}

#------------------------------------------------------------------------------
# Resource Servers
#------------------------------------------------------------------------------

variable "resource_servers" {
  description = "Map of resource server configurations for custom scopes"
  type = map(object({
    identifier = string
    scopes = list(object({
      name        = string
      description = string
    }))
  }))
  default = {}
}

#------------------------------------------------------------------------------
# User Groups
#------------------------------------------------------------------------------

variable "user_groups" {
  description = "Map of user group configurations"
  type = map(object({
    description = optional(string)
    precedence  = optional(number)
    role_arn    = optional(string)
  }))
  default = {}
}

#------------------------------------------------------------------------------
# Tags
#------------------------------------------------------------------------------

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
