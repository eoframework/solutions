# Generic AWS ASG Module - Outputs

output "asg_id" {
  description = "Auto Scaling Group ID"
  value       = aws_autoscaling_group.this.id
}

output "asg_arn" {
  description = "Auto Scaling Group ARN"
  value       = aws_autoscaling_group.this.arn
}

output "asg_name" {
  description = "Auto Scaling Group name"
  value       = aws_autoscaling_group.this.name
}

output "launch_template_id" {
  description = "Launch Template ID"
  value       = aws_launch_template.this.id
}

output "launch_template_arn" {
  description = "Launch Template ARN"
  value       = aws_launch_template.this.arn
}

output "launch_template_latest_version" {
  description = "Latest version of Launch Template"
  value       = aws_launch_template.this.latest_version
}

output "scale_up_policy_arn" {
  description = "Scale up policy ARN"
  value       = var.enable_scaling_policies ? aws_autoscaling_policy.scale_up[0].arn : null
}

output "scale_down_policy_arn" {
  description = "Scale down policy ARN"
  value       = var.enable_scaling_policies ? aws_autoscaling_policy.scale_down[0].arn : null
}
