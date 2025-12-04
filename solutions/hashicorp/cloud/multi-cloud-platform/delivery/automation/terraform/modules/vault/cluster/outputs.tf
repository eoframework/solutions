#------------------------------------------------------------------------------
# Vault Cluster Module Outputs
#------------------------------------------------------------------------------

output "vault_endpoint" {
  description = "Vault cluster endpoint URL"
  value       = var.vault.deployment_mode == "self-managed" ? "https://${aws_lb.vault[0].dns_name}:8200" : "https://${var.vault.hcp_vault_cluster_id}.vault.hashicorp.cloud:8200"
}

output "vault_security_group_id" {
  description = "Vault security group ID"
  value       = var.vault.deployment_mode == "self-managed" ? aws_security_group.vault[0].id : ""
}

output "vault_instance_ids" {
  description = "List of Vault instance IDs"
  value       = var.vault.deployment_mode == "self-managed" ? aws_instance.vault[*].id : []
}

output "vault_nlb_arn" {
  description = "Vault NLB ARN"
  value       = var.vault.deployment_mode == "self-managed" ? aws_lb.vault[0].arn : ""
}

output "vault_iam_role_arn" {
  description = "Vault IAM role ARN"
  value       = var.vault.deployment_mode == "self-managed" ? aws_iam_role.vault[0].arn : ""
}
