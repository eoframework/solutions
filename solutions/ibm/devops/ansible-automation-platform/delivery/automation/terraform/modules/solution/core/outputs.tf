#------------------------------------------------------------------------------
# AAP Solution - Core Module Outputs
#------------------------------------------------------------------------------

output "vpc_id" {
  description = "VPC ID"
  value       = local.vpc_id
}

output "controller_url" {
  description = "AAP Controller URL"
  value       = "https://${aws_lb.controller.dns_name}"
}

output "controller_lb_dns_name" {
  description = "Controller ALB DNS name"
  value       = aws_lb.controller.dns_name
}

output "controller_instance_ids" {
  description = "Controller instance IDs"
  value       = module.aap_nodes.controller_instance_ids
}

output "controller_private_ips" {
  description = "Controller private IPs"
  value       = module.aap_nodes.controller_private_ips
}

output "execution_instance_ids" {
  description = "Execution node instance IDs"
  value       = module.aap_nodes.execution_instance_ids
}

output "execution_private_ips" {
  description = "Execution node private IPs"
  value       = module.aap_nodes.execution_private_ips
}

output "hub_instance_id" {
  description = "Hub instance ID"
  value       = module.aap_nodes.hub_instance_id
}

output "hub_private_ip" {
  description = "Hub private IP"
  value       = module.aap_nodes.hub_private_ip
}

output "database_endpoint" {
  description = "Database endpoint"
  value       = module.database.db_endpoint
}

output "database_address" {
  description = "Database address"
  value       = module.database.db_address
}

output "controller_security_group_id" {
  description = "Controller security group ID"
  value       = aws_security_group.controller.id
}

output "execution_security_group_id" {
  description = "Execution security group ID"
  value       = aws_security_group.execution.id
}

output "alb_arn" {
  description = "ALB ARN"
  value       = aws_lb.controller.arn
}

output "alb_dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.controller.dns_name
}

output "alb_arn_suffix" {
  description = "ALB ARN suffix for CloudWatch metrics"
  value       = aws_lb.controller.arn_suffix
}

output "db_endpoint" {
  description = "Database endpoint"
  value       = module.database.db_endpoint
}

output "db_instance_identifier" {
  description = "Database instance identifier"
  value       = module.database.db_instance_identifier
}
