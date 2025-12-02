#------------------------------------------------------------------------------
# IDP Security Module - Outputs
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# KMS Outputs
#------------------------------------------------------------------------------

output "kms_key_arn" {
  description = "KMS key ARN for encryption"
  value       = aws_kms_key.main.arn
}

output "kms_key_id" {
  description = "KMS key ID"
  value       = aws_kms_key.main.key_id
}

output "kms_alias_arn" {
  description = "KMS alias ARN"
  value       = aws_kms_alias.main.arn
}

#------------------------------------------------------------------------------
# Lambda Security Group Outputs
#------------------------------------------------------------------------------

output "lambda_security_group_id" {
  description = "Lambda VPC security group ID (null if VPC mode disabled)"
  value       = var.lambda_vpc_enabled ? aws_security_group.lambda[0].id : null
}

output "lambda_security_group_ids" {
  description = "Lambda VPC security group IDs as list (empty if VPC mode disabled)"
  value       = var.lambda_vpc_enabled ? [aws_security_group.lambda[0].id] : []
}

#------------------------------------------------------------------------------
# Computed VPC Configuration for Lambda
#------------------------------------------------------------------------------

output "lambda_vpc" {
  description = "Computed Lambda VPC configuration for passing to other modules"
  value = var.lambda_vpc_enabled ? {
    subnet_ids         = var.network.private_subnet_ids
    security_group_ids = [aws_security_group.lambda[0].id]
  } : {
    subnet_ids         = null
    security_group_ids = []
  }
}
