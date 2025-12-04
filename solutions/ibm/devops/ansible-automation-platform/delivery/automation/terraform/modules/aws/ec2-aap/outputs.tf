#------------------------------------------------------------------------------
# AWS EC2 AAP Module Outputs
#------------------------------------------------------------------------------

output "controller_instance_ids" {
  description = "Controller instance IDs"
  value       = aws_instance.controller[*].id
}

output "controller_private_ips" {
  description = "Controller private IPs"
  value       = aws_instance.controller[*].private_ip
}

output "execution_instance_ids" {
  description = "Execution node instance IDs"
  value       = aws_instance.execution[*].id
}

output "execution_private_ips" {
  description = "Execution node private IPs"
  value       = aws_instance.execution[*].private_ip
}

output "hub_instance_id" {
  description = "Hub instance ID"
  value       = var.create_hub ? aws_instance.hub[0].id : null
}

output "hub_private_ip" {
  description = "Hub private IP"
  value       = var.create_hub ? aws_instance.hub[0].private_ip : null
}

output "iam_instance_profile_name" {
  description = "IAM instance profile name"
  value       = aws_iam_instance_profile.aap_node.name
}

output "iam_role_arn" {
  description = "IAM role ARN"
  value       = aws_iam_role.aap_node.arn
}
