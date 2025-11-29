# Generic AWS ElastiCache Module - Outputs

output "replication_group_id" {
  description = "Replication group ID"
  value       = aws_elasticache_replication_group.this.id
}

output "replication_group_arn" {
  description = "Replication group ARN"
  value       = aws_elasticache_replication_group.this.arn
}

output "primary_endpoint" {
  description = "Primary endpoint address"
  value       = aws_elasticache_replication_group.this.primary_endpoint_address
}

output "reader_endpoint" {
  description = "Reader endpoint address"
  value       = aws_elasticache_replication_group.this.reader_endpoint_address
}

output "port" {
  description = "Port"
  value       = aws_elasticache_replication_group.this.port
}

output "connection_string" {
  description = "Redis connection string"
  value       = "redis://${aws_elasticache_replication_group.this.primary_endpoint_address}:${aws_elasticache_replication_group.this.port}"
}

output "parameter_group_name" {
  description = "Parameter group name"
  value       = aws_elasticache_parameter_group.this.name
}
