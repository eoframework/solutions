# Generic AWS RDS Module - Outputs

output "db_instance_id" {
  description = "RDS instance ID"
  value       = aws_db_instance.this.id
}

output "db_instance_arn" {
  description = "RDS instance ARN"
  value       = aws_db_instance.this.arn
}

output "db_instance_identifier" {
  description = "RDS instance identifier"
  value       = aws_db_instance.this.identifier
}

output "endpoint" {
  description = "RDS endpoint"
  value       = aws_db_instance.this.endpoint
}

output "address" {
  description = "RDS address (hostname)"
  value       = aws_db_instance.this.address
}

output "port" {
  description = "RDS port"
  value       = aws_db_instance.this.port
}

output "database_name" {
  description = "Database name"
  value       = aws_db_instance.this.db_name
}

output "username" {
  description = "Master username"
  value       = aws_db_instance.this.username
  sensitive   = true
}

output "parameter_group_name" {
  description = "Parameter group name"
  value       = aws_db_parameter_group.this.name
}
