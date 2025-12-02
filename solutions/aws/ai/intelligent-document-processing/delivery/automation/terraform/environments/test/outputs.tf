#------------------------------------------------------------------------------
# IDP Test Environment - Outputs
#------------------------------------------------------------------------------
# Outputs for the test environment serverless IDP infrastructure
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Environment Identity
#------------------------------------------------------------------------------

output "environment" {
  description = "Environment identifier"
  value       = local.environment
}

output "environment_display" {
  description = "Environment display name"
  value       = lookup(local.env_display_name, local.environment, local.environment)
}

output "name_prefix" {
  description = "Resource naming prefix"
  value       = local.name_prefix
}

output "region" {
  description = "AWS region"
  value       = data.aws_region.current.id
}

#------------------------------------------------------------------------------
# Storage Outputs (S3 + DynamoDB)
#------------------------------------------------------------------------------

output "documents_bucket_name" {
  description = "Name of the documents S3 bucket"
  value       = module.storage.documents_bucket_name
}

output "documents_bucket_arn" {
  description = "ARN of the documents S3 bucket"
  value       = module.storage.documents_bucket_arn
}

output "results_table_name" {
  description = "Name of the results DynamoDB table"
  value       = module.storage.results_table_name
}

output "results_table_arn" {
  description = "ARN of the results DynamoDB table"
  value       = module.storage.results_table_arn
}

output "jobs_table_name" {
  description = "Name of the processing jobs DynamoDB table"
  value       = module.storage.jobs_table_name
}

output "jobs_table_arn" {
  description = "ARN of the processing jobs DynamoDB table"
  value       = module.storage.jobs_table_arn
}

#------------------------------------------------------------------------------
# Document Processing Outputs
#------------------------------------------------------------------------------

output "state_machine_arn" {
  description = "ARN of the document processing Step Functions state machine"
  value       = module.document_processing.state_machine_arn
}

output "state_machine_name" {
  description = "Name of the document processing Step Functions state machine"
  value       = module.document_processing.state_machine_name
}

output "lambda_arns" {
  description = "ARNs of the document processing Lambda functions"
  value       = module.document_processing.lambda_arns
}

#------------------------------------------------------------------------------
# Human Review Outputs
#------------------------------------------------------------------------------

output "human_review_enabled" {
  description = "Whether human review (A2I) is enabled"
  value       = var.human_review.enabled
}

output "review_queue_url" {
  description = "URL of the human review SQS queue"
  value       = var.human_review.enabled ? module.human_review[0].review_queue_url : null
}

#------------------------------------------------------------------------------
# API Outputs
#------------------------------------------------------------------------------

output "api_endpoint" {
  description = "API Gateway endpoint URL"
  value       = module.api.invoke_url
}

output "api_id" {
  description = "API Gateway REST API ID"
  value       = module.api.api_id
}

output "api_stage" {
  description = "API Gateway stage name"
  value       = var.api.stage_name
}

#------------------------------------------------------------------------------
# Authentication Outputs
#------------------------------------------------------------------------------

output "cognito_enabled" {
  description = "Whether Cognito authentication is enabled"
  value       = var.auth.enabled
}

output "user_pool_id" {
  description = "Cognito User Pool ID"
  value       = var.auth.enabled ? module.auth[0].user_pool_id : null
}

output "user_pool_arn" {
  description = "Cognito User Pool ARN"
  value       = var.auth.enabled ? module.auth[0].user_pool_arn : null
}

output "user_pool_endpoint" {
  description = "Cognito User Pool endpoint"
  value       = var.auth.enabled ? module.auth[0].user_pool_endpoint : null
}

output "web_client_id" {
  description = "Cognito Web Client ID"
  value       = var.auth.enabled ? module.auth[0].client_ids["web"] : null
}

#------------------------------------------------------------------------------
# Security Outputs
#------------------------------------------------------------------------------

output "kms_key_arn" {
  description = "KMS key ARN for encryption"
  value       = aws_kms_key.main.arn
}

output "kms_key_id" {
  description = "KMS key ID"
  value       = aws_kms_key.main.key_id
}

#------------------------------------------------------------------------------
# Test Environment Summary
#------------------------------------------------------------------------------

output "deployment_summary" {
  description = "Test deployment summary"
  value = {
    # Identity
    solution_name    = var.solution.name
    solution_abbr    = var.solution.abbr
    environment      = local.environment
    environment_name = lookup(local.env_display_name, local.environment, local.environment)
    name_prefix      = local.name_prefix
    region           = data.aws_region.current.id

    # Ownership
    cost_center  = var.ownership.cost_center
    owner        = var.ownership.owner_email
    project_code = var.ownership.project_code

    # Resources
    documents_bucket  = module.storage.documents_bucket_name
    results_table     = module.storage.results_table_name
    jobs_table        = module.storage.jobs_table_name
    api_endpoint      = module.api.invoke_url
    state_machine_arn = module.document_processing.state_machine_arn

    # Auth
    cognito_enabled = var.auth.enabled
    user_pool_id    = var.auth.enabled ? module.auth[0].user_pool_id : null

    # Test-specific settings
    test_optimizations = {
      dynamodb_billing_mode    = "PAY_PER_REQUEST"
      pitr_enabled             = false
      human_review_enabled     = var.human_review.enabled
      alarms_enabled           = var.monitoring.enable_alarms
      log_retention_days       = var.logging.retention_days
    }

    # Deployed modules
    deployed_modules = [
      "storage",
      "document-processing",
      var.human_review.enabled ? "human-review" : null,
      "api",
      var.auth.enabled ? "auth" : null
    ]

    # Timestamp
    deployment_time = timestamp()
  }
}

#------------------------------------------------------------------------------
# Testing Helpers
#------------------------------------------------------------------------------

output "test_commands" {
  description = "Helpful commands for testing the IDP solution"
  value = {
    health_check   = "curl ${module.api.invoke_url}/health"
    upload_doc     = "curl -X POST ${module.api.invoke_url}/documents -H 'Content-Type: application/json' -d '{\"filename\": \"test.pdf\"}'"
    list_docs      = "curl ${module.api.invoke_url}/documents"
    check_s3       = "aws s3 ls s3://${module.storage.documents_bucket_name}"
    check_dynamodb = "aws dynamodb scan --table-name ${module.storage.results_table_name} --max-items 5"
    check_sfn      = "aws stepfunctions list-executions --state-machine-arn ${module.document_processing.state_machine_arn} --max-items 5"
  }
}
