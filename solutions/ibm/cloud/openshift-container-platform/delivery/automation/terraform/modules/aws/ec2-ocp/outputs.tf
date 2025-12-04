#------------------------------------------------------------------------------
# AWS EC2 OCP Module Outputs
#------------------------------------------------------------------------------

output "bootstrap_instance_id" {
  description = "Bootstrap instance ID"
  value       = var.create_bootstrap ? aws_instance.bootstrap[0].id : null
}

output "bootstrap_private_ip" {
  description = "Bootstrap instance private IP"
  value       = var.create_bootstrap ? aws_instance.bootstrap[0].private_ip : null
}

output "control_plane_instance_ids" {
  description = "List of control plane instance IDs"
  value       = aws_instance.control_plane[*].id
}

output "control_plane_private_ips" {
  description = "List of control plane private IPs"
  value       = aws_instance.control_plane[*].private_ip
}

output "worker_instance_ids" {
  description = "List of worker instance IDs"
  value       = aws_instance.worker[*].id
}

output "worker_private_ips" {
  description = "List of worker private IPs"
  value       = aws_instance.worker[*].private_ip
}

output "iam_instance_profile_name" {
  description = "IAM instance profile name"
  value       = aws_iam_instance_profile.ocp_node.name
}

output "iam_role_arn" {
  description = "IAM role ARN"
  value       = aws_iam_role.ocp_node.arn
}
