#------------------------------------------------------------------------------
# AWS Self-Hosted GitHub Actions Runners Module - Outputs
#------------------------------------------------------------------------------

output "linux_asg_name" {
  description = "Name of the Linux runner ASG"
  value       = aws_autoscaling_group.linux.name
}

output "linux_asg_arn" {
  description = "ARN of the Linux runner ASG"
  value       = aws_autoscaling_group.linux.arn
}

output "windows_asg_name" {
  description = "Name of the Windows runner ASG"
  value       = length(aws_autoscaling_group.windows) > 0 ? aws_autoscaling_group.windows[0].name : null
}

output "windows_asg_arn" {
  description = "ARN of the Windows runner ASG"
  value       = length(aws_autoscaling_group.windows) > 0 ? aws_autoscaling_group.windows[0].arn : null
}

output "runner_iam_role_arn" {
  description = "ARN of the runner IAM role"
  value       = aws_iam_role.runner.arn
}

output "runner_iam_role_name" {
  description = "Name of the runner IAM role"
  value       = aws_iam_role.runner.name
}

output "runner_instance_profile_arn" {
  description = "ARN of the runner instance profile"
  value       = aws_iam_instance_profile.runner.arn
}

output "github_token_secret_arn" {
  description = "ARN of the GitHub token secret"
  value       = aws_secretsmanager_secret.github_token.arn
}

output "linux_launch_template_id" {
  description = "ID of the Linux launch template"
  value       = aws_launch_template.linux.id
}

output "windows_launch_template_id" {
  description = "ID of the Windows launch template"
  value       = length(aws_launch_template.windows) > 0 ? aws_launch_template.windows[0].id : null
}
