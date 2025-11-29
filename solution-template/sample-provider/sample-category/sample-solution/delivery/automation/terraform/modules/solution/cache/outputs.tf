# Solution Cache Module - Outputs
# Outputs from generic ElastiCache module

output "cache_endpoint" {
  description = "Primary endpoint for the cache cluster"
  value       = module.elasticache.primary_endpoint
}

output "cache_port" {
  description = "Cache port"
  value       = module.elasticache.port
}

output "cache_replication_group_id" {
  description = "Replication group ID"
  value       = module.elasticache.replication_group_id
}

output "cache_replication_group_arn" {
  description = "Replication group ARN"
  value       = module.elasticache.replication_group_arn
}

output "cache_reader_endpoint" {
  description = "Reader endpoint for the cache cluster"
  value       = module.elasticache.reader_endpoint
}

output "cache_parameter_group_name" {
  description = "Cache parameter group name"
  value       = module.elasticache.parameter_group_name
}

output "cache_connection_string" {
  description = "Redis connection string"
  value       = module.elasticache.connection_string
}
