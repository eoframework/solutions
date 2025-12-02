#------------------------------------------------------------------------------
# Secrets Module
#------------------------------------------------------------------------------
# Provisions secrets in AWS Secrets Manager and SSM Parameter Store.
# Called by environment-specific configurations (prod, test).
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Data Sources
#------------------------------------------------------------------------------

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

#------------------------------------------------------------------------------
# KMS Key for Secrets Encryption (Optional - uses AWS managed key if not set)
#------------------------------------------------------------------------------

resource "aws_kms_key" "secrets" {
  count                   = var.create_kms_key ? 1 : 0
  description             = "KMS key for ${var.name_prefix} secrets encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = merge(var.tags, { Name = "${var.name_prefix}-secrets-key" })
}

resource "aws_kms_alias" "secrets" {
  count         = var.create_kms_key ? 1 : 0
  name          = "alias/${var.name_prefix}-secrets"
  target_key_id = aws_kms_key.secrets[0].key_id
}

#------------------------------------------------------------------------------
# Database Password - Secrets Manager
#------------------------------------------------------------------------------

resource "random_password" "db_password" {
  count            = var.create_db_secret ? 1 : 0
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
  min_upper        = 2
  min_lower        = 2
  min_numeric      = 2
  min_special      = 2
}

resource "aws_secretsmanager_secret" "db_password" {
  count                   = var.create_db_secret ? 1 : 0
  name                    = "${var.name_prefix}-${var.db_password_secret_suffix}"
  description             = "Database master password for ${var.name_prefix}"
  kms_key_id              = var.create_kms_key ? aws_kms_key.secrets[0].arn : null
  recovery_window_in_days = var.secret_recovery_window

  tags = merge(var.tags, {
    Name      = "${var.name_prefix}-db-password"
    Component = "Database"
  })
}

resource "aws_secretsmanager_secret_version" "db_password" {
  count         = var.create_db_secret ? 1 : 0
  secret_id     = aws_secretsmanager_secret.db_password[0].id
  secret_string = random_password.db_password[0].result
}

#------------------------------------------------------------------------------
# Cache Auth Token - SSM Parameter Store (SecureString)
#------------------------------------------------------------------------------

resource "random_password" "cache_auth_token" {
  count   = var.create_cache_secret ? 1 : 0
  length  = 64
  special = false  # Redis auth tokens don't support all special chars
}

resource "aws_ssm_parameter" "cache_auth_token" {
  count       = var.create_cache_secret ? 1 : 0
  name        = "/${var.name_prefix}/${var.cache_auth_token_param_suffix}"
  description = "ElastiCache auth token for ${var.name_prefix}"
  type        = "SecureString"
  value       = random_password.cache_auth_token[0].result
  key_id      = var.create_kms_key ? aws_kms_key.secrets[0].arn : null

  tags = merge(var.tags, {
    Name      = "${var.name_prefix}-cache-auth-token"
    Component = "Cache"
  })
}

#------------------------------------------------------------------------------
# Application API Key - Secrets Manager
#------------------------------------------------------------------------------

resource "random_password" "api_key" {
  count   = var.create_api_key_secret ? 1 : 0
  length  = 48
  special = false
}

resource "aws_secretsmanager_secret" "api_key" {
  count                   = var.create_api_key_secret ? 1 : 0
  name                    = "${var.name_prefix}-${var.api_key_secret_suffix}"
  description             = "Application API key for ${var.name_prefix}"
  kms_key_id              = var.create_kms_key ? aws_kms_key.secrets[0].arn : null
  recovery_window_in_days = var.secret_recovery_window

  tags = merge(var.tags, {
    Name      = "${var.name_prefix}-api-key"
    Component = "Application"
  })
}

resource "aws_secretsmanager_secret_version" "api_key" {
  count         = var.create_api_key_secret ? 1 : 0
  secret_id     = aws_secretsmanager_secret.api_key[0].id
  secret_string = random_password.api_key[0].result
}
