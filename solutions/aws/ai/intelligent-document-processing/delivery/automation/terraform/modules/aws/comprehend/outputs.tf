#------------------------------------------------------------------------------
# AWS Comprehend Custom Models Module - Outputs
#------------------------------------------------------------------------------

output "role_arn" {
  description = "ARN of the Comprehend IAM role"
  value       = var.enabled ? aws_iam_role.comprehend[0].arn : null
}

output "role_name" {
  description = "Name of the Comprehend IAM role"
  value       = var.enabled ? aws_iam_role.comprehend[0].name : null
}

# Uncomment when document classifier is enabled
# output "classifier_arn" {
#   description = "ARN of the custom document classifier"
#   value       = aws_comprehend_document_classifier.custom.arn
# }

# Uncomment when entity recognizer is enabled
# output "entity_recognizer_arn" {
#   description = "ARN of the custom entity recognizer"
#   value       = aws_comprehend_entity_recognizer.custom.arn
# }

# Uncomment when flywheel is enabled
# output "flywheel_arn" {
#   description = "ARN of the Comprehend flywheel"
#   value       = aws_comprehend_flywheel.main.arn
# }
