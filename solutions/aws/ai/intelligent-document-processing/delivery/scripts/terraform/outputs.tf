# AWS Intelligent Document Processing - Outputs

output "document_bucket_name" {
  description = "Name of the S3 bucket for document storage"
  value       = aws_s3_bucket.document_storage.bucket
}

output "document_bucket_arn" {
  description = "ARN of the S3 bucket for document storage"
  value       = aws_s3_bucket.document_storage.arn
}

output "processing_queue_url" {
  description = "URL of the SQS queue for document processing"
  value       = aws_sqs_queue.document_processing.url
}

output "processing_queue_arn" {
  description = "ARN of the SQS queue for document processing"
  value       = aws_sqs_queue.document_processing.arn
}

output "lambda_function_name" {
  description = "Name of the Lambda function for document processing"
  value       = aws_lambda_function.document_processor.function_name
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function for document processing"
  value       = aws_lambda_function.document_processor.arn
}

output "lambda_execution_role_arn" {
  description = "ARN of the Lambda execution role"
  value       = aws_iam_role.lambda_execution_role.arn
}

output "textract_service_role_arn" {
  description = "ARN of the Textract service role"
  value       = aws_iam_role.textract_service_role.arn
}

output "aws_region" {
  description = "AWS region where resources are deployed"
  value       = var.aws_region
}

output "project_name" {
  description = "Project name used for resource naming"
  value       = var.project_name
}

output "environment" {
  description = "Environment name"
  value       = var.environment
}