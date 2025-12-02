#------------------------------------------------------------------------------
# AWS Step Functions State Machine Module - Outputs
#------------------------------------------------------------------------------

output "state_machine_arn" {
  description = "ARN of the Step Functions state machine"
  value       = aws_sfn_state_machine.this.arn
}

output "state_machine_id" {
  description = "ID of the Step Functions state machine"
  value       = aws_sfn_state_machine.this.id
}

output "state_machine_name" {
  description = "Name of the Step Functions state machine"
  value       = aws_sfn_state_machine.this.name
}

output "role_arn" {
  description = "ARN of the IAM role used by the state machine"
  value       = aws_iam_role.sfn.arn
}

output "role_name" {
  description = "Name of the IAM role used by the state machine"
  value       = aws_iam_role.sfn.name
}

output "log_group_arn" {
  description = "ARN of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.sfn.arn
}

output "log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.sfn.name
}
