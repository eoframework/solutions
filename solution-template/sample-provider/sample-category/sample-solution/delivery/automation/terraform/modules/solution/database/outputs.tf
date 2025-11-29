# Solution Database Module - Outputs
# Outputs from generic RDS module

output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = module.rds.endpoint
}

output "rds_address" {
  description = "RDS instance address (hostname only)"
  value       = module.rds.address
}

output "rds_port" {
  description = "RDS instance port"
  value       = module.rds.port
}

output "rds_identifier" {
  description = "RDS instance identifier"
  value       = module.rds.db_instance_identifier
}

output "rds_arn" {
  description = "RDS instance ARN"
  value       = module.rds.db_instance_arn
}

output "rds_database_name" {
  description = "Database name"
  value       = module.rds.database_name
}

output "rds_username" {
  description = "Master username"
  value       = module.rds.username
  sensitive   = true
}

output "db_parameter_group_name" {
  description = "DB parameter group name"
  value       = module.rds.parameter_group_name
}
