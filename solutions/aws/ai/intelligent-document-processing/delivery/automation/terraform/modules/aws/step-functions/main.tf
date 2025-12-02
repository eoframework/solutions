#------------------------------------------------------------------------------
# AWS Step Functions State Machine Module
#------------------------------------------------------------------------------
# Creates Step Functions workflow for IDP document processing orchestration
#------------------------------------------------------------------------------

resource "aws_sfn_state_machine" "this" {
  name     = var.name
  role_arn = aws_iam_role.sfn.arn

  definition = var.definition

  type = var.express_workflow ? "EXPRESS" : "STANDARD"

  logging_configuration {
    log_destination        = "${aws_cloudwatch_log_group.sfn.arn}:*"
    include_execution_data = var.log_include_execution_data
    level                  = var.log_level
  }

  dynamic "tracing_configuration" {
    for_each = var.xray_tracing_enabled ? [1] : []
    content {
      enabled = true
    }
  }

  tags = merge(var.common_tags, {
    Name = var.name
  })
}

#------------------------------------------------------------------------------
# IAM Role for Step Functions
#------------------------------------------------------------------------------

resource "aws_iam_role" "sfn" {
  name = "${var.name}-sfn-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "states.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.common_tags
}

#------------------------------------------------------------------------------
# IAM Policy for Lambda Invocations
#------------------------------------------------------------------------------

resource "aws_iam_role_policy" "lambda_invoke" {
  count = length(var.lambda_arns) > 0 ? 1 : 0

  name = "${var.name}-lambda-invoke"
  role = aws_iam_role.sfn.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "lambda:InvokeFunction"
        Resource = var.lambda_arns
      }
    ]
  })
}

#------------------------------------------------------------------------------
# IAM Policy for DynamoDB Access
#------------------------------------------------------------------------------

resource "aws_iam_role_policy" "dynamodb" {
  count = length(var.dynamodb_table_arns) > 0 ? 1 : 0

  name = "${var.name}-dynamodb"
  role = aws_iam_role.sfn.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = var.dynamodb_table_arns
      }
    ]
  })
}

#------------------------------------------------------------------------------
# IAM Policy for S3 Access
#------------------------------------------------------------------------------

resource "aws_iam_role_policy" "s3" {
  count = length(var.s3_bucket_arns) > 0 ? 1 : 0

  name = "${var.name}-s3"
  role = aws_iam_role.sfn.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [for arn in var.s3_bucket_arns : "${arn}/*"]
      },
      {
        Effect   = "Allow"
        Action   = "s3:ListBucket"
        Resource = var.s3_bucket_arns
      }
    ]
  })
}

#------------------------------------------------------------------------------
# IAM Policy for Textract
#------------------------------------------------------------------------------

resource "aws_iam_role_policy" "textract" {
  count = var.enable_textract ? 1 : 0

  name = "${var.name}-textract"
  role = aws_iam_role.sfn.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "textract:StartDocumentTextDetection",
          "textract:StartDocumentAnalysis",
          "textract:GetDocumentTextDetection",
          "textract:GetDocumentAnalysis",
          "textract:AnalyzeDocument",
          "textract:DetectDocumentText",
          "textract:AnalyzeExpense",
          "textract:AnalyzeID"
        ]
        Resource = "*"
      }
    ]
  })
}

#------------------------------------------------------------------------------
# IAM Policy for Comprehend
#------------------------------------------------------------------------------

resource "aws_iam_role_policy" "comprehend" {
  count = var.enable_comprehend ? 1 : 0

  name = "${var.name}-comprehend"
  role = aws_iam_role.sfn.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "comprehend:DetectEntities",
          "comprehend:DetectKeyPhrases",
          "comprehend:DetectPiiEntities",
          "comprehend:DetectSentiment",
          "comprehend:ClassifyDocument",
          "comprehend:ContainsPiiEntities"
        ]
        Resource = "*"
      }
    ]
  })
}

#------------------------------------------------------------------------------
# IAM Policy for SQS
#------------------------------------------------------------------------------

resource "aws_iam_role_policy" "sqs" {
  count = length(var.sqs_queue_arns) > 0 ? 1 : 0

  name = "${var.name}-sqs"
  role = aws_iam_role.sfn.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = var.sqs_queue_arns
      }
    ]
  })
}

#------------------------------------------------------------------------------
# IAM Policy for SNS
#------------------------------------------------------------------------------

resource "aws_iam_role_policy" "sns" {
  count = length(var.sns_topic_arns) > 0 ? 1 : 0

  name = "${var.name}-sns"
  role = aws_iam_role.sfn.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "sns:Publish"
        Resource = var.sns_topic_arns
      }
    ]
  })
}

#------------------------------------------------------------------------------
# IAM Policy for CloudWatch Logs
#------------------------------------------------------------------------------

resource "aws_iam_role_policy" "logs" {
  name = "${var.name}-logs"
  role = aws_iam_role.sfn.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogDelivery",
          "logs:GetLogDelivery",
          "logs:UpdateLogDelivery",
          "logs:DeleteLogDelivery",
          "logs:ListLogDeliveries",
          "logs:PutResourcePolicy",
          "logs:DescribeResourcePolicies",
          "logs:DescribeLogGroups"
        ]
        Resource = "*"
      }
    ]
  })
}

#------------------------------------------------------------------------------
# IAM Policy for X-Ray Tracing
#------------------------------------------------------------------------------

resource "aws_iam_role_policy" "xray" {
  count = var.xray_tracing_enabled ? 1 : 0

  name = "${var.name}-xray"
  role = aws_iam_role.sfn.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "xray:PutTraceSegments",
          "xray:PutTelemetryRecords",
          "xray:GetSamplingRules",
          "xray:GetSamplingTargets"
        ]
        Resource = "*"
      }
    ]
  })
}

#------------------------------------------------------------------------------
# CloudWatch Log Group
#------------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "sfn" {
  name              = "/aws/vendedlogs/states/${var.name}"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.kms_key_arn

  tags = var.common_tags
}

#------------------------------------------------------------------------------
# Additional Custom IAM Policies
#------------------------------------------------------------------------------

resource "aws_iam_role_policy" "custom" {
  for_each = var.custom_policies

  name   = each.key
  role   = aws_iam_role.sfn.id
  policy = each.value
}
