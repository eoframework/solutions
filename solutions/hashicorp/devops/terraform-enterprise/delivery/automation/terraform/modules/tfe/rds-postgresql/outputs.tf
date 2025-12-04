#------------------------------------------------------------------------------
# RDS PostgreSQL Module Outputs
#------------------------------------------------------------------------------

output "rds_identifier" {
  description = "RDS instance identifier"
  value       = aws_db_instance.tfe.identifier
}

output "rds_endpoint" {
  description = "RDS endpoint"
  value       = aws_db_instance.tfe.endpoint
}

output "rds_address" {
  description = "RDS hostname"
  value       = aws_db_instance.tfe.address
}

output "rds_port" {
  description = "RDS port"
  value       = aws_db_instance.tfe.port
}

output "rds_arn" {
  description = "RDS ARN"
  value       = aws_db_instance.tfe.arn
}

output "db_password_secret_arn" {
  description = "Secrets Manager ARN for DB password"
  value       = aws_secretsmanager_secret.db_password.arn
}
