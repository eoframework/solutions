#------------------------------------------------------------------------------
# Secrets Module - Outputs
#------------------------------------------------------------------------------
# Note: Actual secret VALUES are never exposed in outputs.
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# KMS Key
#------------------------------------------------------------------------------

output "kms_key_arn" {
  description = "KMS key ARN for secrets encryption"
  value       = var.create_kms_key ? aws_kms_key.secrets[0].arn : null
}

output "kms_key_alias" {
  description = "KMS key alias"
  value       = var.create_kms_key ? aws_kms_alias.secrets[0].name : null
}

#------------------------------------------------------------------------------
# Database Password Secret
#------------------------------------------------------------------------------

output "db_password_secret_name" {
  description = "Secrets Manager secret name for database password"
  value       = var.create_db_secret ? aws_secretsmanager_secret.db_password[0].name : null
}

output "db_password_secret_arn" {
  description = "Secrets Manager secret ARN for database password"
  value       = var.create_db_secret ? aws_secretsmanager_secret.db_password[0].arn : null
}

#------------------------------------------------------------------------------
# Cache Auth Token Parameter
#------------------------------------------------------------------------------

output "cache_auth_token_param_name" {
  description = "SSM parameter name for cache auth token"
  value       = var.create_cache_secret ? aws_ssm_parameter.cache_auth_token[0].name : null
}

output "cache_auth_token_param_arn" {
  description = "SSM parameter ARN for cache auth token"
  value       = var.create_cache_secret ? aws_ssm_parameter.cache_auth_token[0].arn : null
}

#------------------------------------------------------------------------------
# API Key Secret
#------------------------------------------------------------------------------

output "api_key_secret_name" {
  description = "Secrets Manager secret name for API key"
  value       = var.create_api_key_secret ? aws_secretsmanager_secret.api_key[0].name : null
}

output "api_key_secret_arn" {
  description = "Secrets Manager secret ARN for API key"
  value       = var.create_api_key_secret ? aws_secretsmanager_secret.api_key[0].arn : null
}

#------------------------------------------------------------------------------
# Summary
#------------------------------------------------------------------------------

output "secrets_summary" {
  description = "Summary of created secrets for documentation"
  value = {
    database = var.create_db_secret ? {
      type   = "SecretsManager"
      name   = aws_secretsmanager_secret.db_password[0].name
      lookup = "aws secretsmanager get-secret-value --secret-id ${aws_secretsmanager_secret.db_password[0].name}"
    } : null

    cache = var.create_cache_secret ? {
      type   = "SSMParameter"
      name   = aws_ssm_parameter.cache_auth_token[0].name
      lookup = "aws ssm get-parameter --name ${aws_ssm_parameter.cache_auth_token[0].name} --with-decryption"
    } : null

    api_key = var.create_api_key_secret ? {
      type   = "SecretsManager"
      name   = aws_secretsmanager_secret.api_key[0].name
      lookup = "aws secretsmanager get-secret-value --secret-id ${aws_secretsmanager_secret.api_key[0].name}"
    } : null
  }
}
