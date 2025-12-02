#------------------------------------------------------------------------------
# AWS Textract Custom Configuration Module
#------------------------------------------------------------------------------
# Template for provisioning custom Textract resources when built-in APIs
# are insufficient. Use this module when you need:
# - Custom Adapters for domain-specific document layouts
# - Custom Queries for extracting specific information
# - Specialized document processing beyond standard forms/tables
#
# When to use built-in APIs vs custom configuration:
# - Built-in APIs: Standard document text detection, forms, tables, expenses, IDs
# - Custom Adapters: Domain-specific layouts (insurance forms, medical records)
# - Custom Queries: Natural language questions about document content
#
# Note: Custom adapters require training samples and have additional costs.
# See document-processing module for built-in API usage pattern.
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Textract Adapter (Custom Document Layout)
#------------------------------------------------------------------------------
# Creates a custom adapter trained on domain-specific document layouts.
# Improves extraction accuracy for specialized document types.
#
# Training requirements:
# - 5-50 sample documents in S3
# - Documents should represent layout variations
# - Annotations in AWS format
#
# resource "aws_textract_adapter" "custom" {
#   adapter_name = "${var.name_prefix}-adapter"
#
#   auto_update = var.auto_update_adapter ? "ENABLED" : "DISABLED"
#
#   feature_types = var.feature_types  # ["TABLES", "FORMS", "QUERIES"]
#
#   tags = var.common_tags
# }

#------------------------------------------------------------------------------
# Adapter Version (Training Run)
#------------------------------------------------------------------------------
# Each adapter version represents a training run with specific samples.
# Multiple versions allow A/B testing and rollback.
#
# resource "aws_textract_adapter_version" "v1" {
#   adapter_id = aws_textract_adapter.custom.adapter_id
#
#   dataset_config {
#     manifest_s3_object {
#       bucket = var.training_bucket_name
#       name   = var.manifest_s3_key
#     }
#   }
#
#   output_config {
#     s3_bucket = var.output_bucket_name
#     s3_prefix = "adapter-output/"
#   }
#
#   kms_key_id = var.kms_key_arn
#
#   tags = var.common_tags
# }

#------------------------------------------------------------------------------
# Custom Queries Configuration
#------------------------------------------------------------------------------
# Textract Queries allow natural language questions about documents.
# Configure common queries as templates for consistent extraction.
#
# Example queries for different document types:
#
# Invoice queries:
#   - "What is the invoice number?"
#   - "What is the total amount due?"
#   - "What is the payment due date?"
#
# Contract queries:
#   - "What is the effective date?"
#   - "Who are the parties involved?"
#   - "What is the contract term?"
#
# Medical form queries:
#   - "What is the patient name?"
#   - "What is the date of service?"
#   - "What is the diagnosis code?"
#
# These queries are passed to Textract AnalyzeDocument API at runtime.
# Store query configurations in a local or variables for reuse:

locals {
  # Example query configurations by document type
  # Uncomment and customize for your use case
  #
  # invoice_queries = [
  #   { text = "What is the invoice number?", alias = "INVOICE_NUMBER" },
  #   { text = "What is the total amount?", alias = "TOTAL_AMOUNT" },
  #   { text = "What is the due date?", alias = "DUE_DATE" },
  #   { text = "What is the vendor name?", alias = "VENDOR_NAME" },
  # ]
  #
  # contract_queries = [
  #   { text = "What is the effective date?", alias = "EFFECTIVE_DATE" },
  #   { text = "What is the expiration date?", alias = "EXPIRATION_DATE" },
  #   { text = "Who are the contracting parties?", alias = "PARTIES" },
  # ]
}

#------------------------------------------------------------------------------
# IAM Role for Textract Custom Operations
#------------------------------------------------------------------------------
resource "aws_iam_role" "textract" {
  count = var.enabled ? 1 : 0

  name = "${var.name_prefix}-textract-custom-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "textract.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy" "textract_s3" {
  count = var.enabled ? 1 : 0

  name = "s3-access"
  role = aws_iam_role.textract[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          var.training_bucket_arn,
          "${var.training_bucket_arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject"
        ]
        Resource = [
          "${var.output_bucket_arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy" "textract_kms" {
  count = var.enabled && var.kms_key_arn != null ? 1 : 0

  name = "kms-access"
  role = aws_iam_role.textract[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = var.kms_key_arn
      }
    ]
  })
}

#------------------------------------------------------------------------------
# SNS Topic for Async Adapter Training Notifications
#------------------------------------------------------------------------------
resource "aws_sns_topic" "textract_training" {
  count = var.enabled ? 1 : 0

  name              = "${var.name_prefix}-textract-training-notifications"
  kms_master_key_id = var.kms_key_arn

  tags = var.common_tags
}
