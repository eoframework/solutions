#------------------------------------------------------------------------------
# Networking Module Outputs (Solution-Level)
#------------------------------------------------------------------------------
# Outputs reference the aws/vpc provider module outputs
#------------------------------------------------------------------------------

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = module.vpc.vpc_cidr
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "db_subnet_group_name" {
  description = "Database subnet group name"
  value       = module.vpc.db_subnet_group_name
}

output "database_security_group_id" {
  description = "Database security group ID"
  value       = module.vpc.database_security_group_id
}

output "internet_gateway_id" {
  description = "Internet gateway ID"
  value       = module.vpc.internet_gateway_id
}

output "nat_gateway_ids" {
  description = "NAT gateway IDs"
  value       = module.vpc.nat_gateway_ids
}
