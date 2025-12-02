#------------------------------------------------------------------------------
# AWS Textract Custom Configuration Module - Outputs
#------------------------------------------------------------------------------

output "role_arn" {
  description = "ARN of the Textract custom operations IAM role"
  value       = var.enabled ? aws_iam_role.textract[0].arn : null
}

output "role_name" {
  description = "Name of the Textract custom operations IAM role"
  value       = var.enabled ? aws_iam_role.textract[0].name : null
}

output "training_topic_arn" {
  description = "ARN of the SNS topic for training notifications"
  value       = var.enabled ? aws_sns_topic.textract_training[0].arn : null
}

# Uncomment when adapter is enabled
# output "adapter_id" {
#   description = "ID of the custom Textract adapter"
#   value       = aws_textract_adapter.custom.adapter_id
# }

# output "adapter_arn" {
#   description = "ARN of the custom Textract adapter"
#   value       = aws_textract_adapter.custom.arn
# }

# output "adapter_version_id" {
#   description = "ID of the adapter version"
#   value       = aws_textract_adapter_version.v1.adapter_version_id
# }
