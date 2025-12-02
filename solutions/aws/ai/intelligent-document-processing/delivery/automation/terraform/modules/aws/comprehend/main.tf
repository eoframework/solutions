#------------------------------------------------------------------------------
# AWS Comprehend Custom Models Module
#------------------------------------------------------------------------------
# Template for provisioning custom Comprehend resources when built-in APIs
# are insufficient. Use this module when you need:
# - Custom document classifiers trained on domain-specific documents
# - Custom entity recognizers for industry-specific entity types
# - Flywheel for continuous model improvement
#
# When to use built-in APIs vs custom models:
# - Built-in APIs: General entity detection, PII, sentiment, key phrases
# - Custom models: Domain-specific classification, custom entity types
#
# Note: Custom models require training data and incur endpoint costs.
# See document-processing module for built-in API usage pattern.
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Custom Document Classifier
#------------------------------------------------------------------------------
# Trains a classifier to categorize documents into custom categories.
# Requires labeled training data in S3.
#
# Training data format (CSV):
#   CLASS_LABEL,document text or S3 URI
#
# resource "aws_comprehend_document_classifier" "custom" {
#   name = "${var.name_prefix}-document-classifier"
#
#   data_access_role_arn = aws_iam_role.comprehend.arn
#   language_code        = var.language_code
#
#   input_data_config {
#     s3_uri      = var.training_data_s3_uri
#     data_format = "COMPREHEND_CSV"
#   }
#
#   output_data_config {
#     s3_uri    = "${var.output_bucket_uri}/classifier-output/"
#     kms_key_id = var.kms_key_arn
#   }
#
#   # Optional: Use for real-time inference
#   mode = var.enable_realtime ? "REAL_TIME" : "ASYNC"
#
#   # Optional: Specify model version
#   version_name = var.model_version
#
#   tags = var.common_tags
# }

#------------------------------------------------------------------------------
# Custom Entity Recognizer
#------------------------------------------------------------------------------
# Trains a recognizer to detect domain-specific entities.
# Requires annotated training data in S3.
#
# Training data formats:
# - Annotations: JSON file with entity locations
# - Entity list: CSV with entity text and type
#
# resource "aws_comprehend_entity_recognizer" "custom" {
#   name = "${var.name_prefix}-entity-recognizer"
#
#   data_access_role_arn = aws_iam_role.comprehend.arn
#   language_code        = var.language_code
#
#   input_data_config {
#     entity_types {
#       type = "CUSTOM_ENTITY_TYPE_1"
#     }
#     entity_types {
#       type = "CUSTOM_ENTITY_TYPE_2"
#     }
#
#     # Option 1: Annotations format
#     annotations {
#       s3_uri = var.annotations_s3_uri
#     }
#     documents {
#       s3_uri = var.documents_s3_uri
#     }
#
#     # Option 2: Entity list format (simpler, less accurate)
#     # entity_list {
#     #   s3_uri = var.entity_list_s3_uri
#     # }
#   }
#
#   tags = var.common_tags
# }

#------------------------------------------------------------------------------
# Comprehend Flywheel (Continuous Model Improvement)
#------------------------------------------------------------------------------
# Creates a flywheel for iterative model training and improvement.
# Useful for production systems that need ongoing model updates.
#
# resource "aws_comprehend_flywheel" "main" {
#   name = "${var.name_prefix}-flywheel"
#
#   data_access_role_arn = aws_iam_role.comprehend.arn
#
#   data_lake_s3_uri = var.data_lake_s3_uri
#
#   # Associate with existing classifier or entity recognizer
#   active_model_arn = aws_comprehend_document_classifier.custom.arn
#
#   model_type = "DOCUMENT_CLASSIFIER"  # or "ENTITY_RECOGNIZER"
#
#   data_security_config {
#     model_kms_key_id      = var.kms_key_arn
#     volume_kms_key_id     = var.kms_key_arn
#     data_lake_kms_key_id  = var.kms_key_arn
#   }
#
#   tags = var.common_tags
# }

#------------------------------------------------------------------------------
# IAM Role for Comprehend
#------------------------------------------------------------------------------
resource "aws_iam_role" "comprehend" {
  count = var.enabled ? 1 : 0

  name = "${var.name_prefix}-comprehend-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "comprehend.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy" "comprehend_s3" {
  count = var.enabled ? 1 : 0

  name = "s3-access"
  role = aws_iam_role.comprehend[0].id

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

resource "aws_iam_role_policy" "comprehend_kms" {
  count = var.enabled && var.kms_key_arn != null ? 1 : 0

  name = "kms-access"
  role = aws_iam_role.comprehend[0].id

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
