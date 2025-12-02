#------------------------------------------------------------------------------
# AWS SQS Queue Module
#------------------------------------------------------------------------------
# Creates SQS queue for IDP async document processing
#------------------------------------------------------------------------------

resource "aws_sqs_queue" "this" {
  name = var.fifo_queue ? "${var.queue_name}.fifo" : var.queue_name

  # FIFO configuration
  fifo_queue                  = var.fifo_queue
  content_based_deduplication = var.fifo_queue ? var.content_based_deduplication : null
  deduplication_scope         = var.fifo_queue ? var.deduplication_scope : null
  fifo_throughput_limit       = var.fifo_queue ? var.fifo_throughput_limit : null

  # Message configuration
  delay_seconds              = var.delay_seconds
  max_message_size           = var.max_message_size
  message_retention_seconds  = var.message_retention_seconds
  receive_wait_time_seconds  = var.receive_wait_time_seconds
  visibility_timeout_seconds = var.visibility_timeout_seconds

  # Encryption
  sqs_managed_sse_enabled = var.kms_key_arn == null ? true : null
  kms_master_key_id       = var.kms_key_arn
  kms_data_key_reuse_period_seconds = var.kms_key_arn != null ? var.kms_data_key_reuse_period : null

  # Dead-letter queue
  redrive_policy = var.dlq_arn != null ? jsonencode({
    deadLetterTargetArn = var.dlq_arn
    maxReceiveCount     = var.max_receive_count
  }) : null

  # Redrive allow policy (for DLQ)
  redrive_allow_policy = var.is_dlq ? jsonencode({
    redrivePermission = "byQueue"
    sourceQueueArns   = var.source_queue_arns
  }) : null

  tags = merge(var.common_tags, {
    Name = var.queue_name
  })
}

#------------------------------------------------------------------------------
# Queue Policy
#------------------------------------------------------------------------------

resource "aws_sqs_queue_policy" "this" {
  count = var.queue_policy != null || length(var.allowed_principals) > 0 ? 1 : 0

  queue_url = aws_sqs_queue.this.id
  policy    = var.queue_policy != null ? var.queue_policy : data.aws_iam_policy_document.queue_policy[0].json
}

data "aws_iam_policy_document" "queue_policy" {
  count = var.queue_policy == null && length(var.allowed_principals) > 0 ? 1 : 0

  statement {
    sid    = "AllowSendMessage"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = var.allowed_principals
    }

    actions = [
      "sqs:SendMessage"
    ]

    resources = [aws_sqs_queue.this.arn]
  }

  # Allow S3 bucket notifications
  dynamic "statement" {
    for_each = length(var.allowed_s3_bucket_arns) > 0 ? [1] : []
    content {
      sid    = "AllowS3Notifications"
      effect = "Allow"

      principals {
        type        = "Service"
        identifiers = ["s3.amazonaws.com"]
      }

      actions = ["sqs:SendMessage"]

      resources = [aws_sqs_queue.this.arn]

      condition {
        test     = "ArnLike"
        variable = "aws:SourceArn"
        values   = var.allowed_s3_bucket_arns
      }
    }
  }

  # Allow SNS topic subscriptions
  dynamic "statement" {
    for_each = length(var.allowed_sns_topic_arns) > 0 ? [1] : []
    content {
      sid    = "AllowSNSSubscriptions"
      effect = "Allow"

      principals {
        type        = "Service"
        identifiers = ["sns.amazonaws.com"]
      }

      actions = ["sqs:SendMessage"]

      resources = [aws_sqs_queue.this.arn]

      condition {
        test     = "ArnLike"
        variable = "aws:SourceArn"
        values   = var.allowed_sns_topic_arns
      }
    }
  }

  # Allow Lambda invocations
  dynamic "statement" {
    for_each = length(var.allowed_lambda_arns) > 0 ? [1] : []
    content {
      sid    = "AllowLambdaAccess"
      effect = "Allow"

      principals {
        type        = "Service"
        identifiers = ["lambda.amazonaws.com"]
      }

      actions = [
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes"
      ]

      resources = [aws_sqs_queue.this.arn]

      condition {
        test     = "ArnLike"
        variable = "aws:SourceArn"
        values   = var.allowed_lambda_arns
      }
    }
  }
}

#------------------------------------------------------------------------------
# Dead Letter Queue (optional, created if enabled)
#------------------------------------------------------------------------------

resource "aws_sqs_queue" "dlq" {
  count = var.create_dlq ? 1 : 0

  name = var.fifo_queue ? "${var.queue_name}-dlq.fifo" : "${var.queue_name}-dlq"

  fifo_queue                  = var.fifo_queue
  content_based_deduplication = var.fifo_queue ? var.content_based_deduplication : null

  message_retention_seconds = var.dlq_message_retention_seconds

  sqs_managed_sse_enabled = var.kms_key_arn == null ? true : null
  kms_master_key_id       = var.kms_key_arn

  tags = merge(var.common_tags, {
    Name = "${var.queue_name}-dlq"
  })
}

#------------------------------------------------------------------------------
# Update main queue with DLQ reference (when DLQ is created by this module)
#------------------------------------------------------------------------------

resource "aws_sqs_queue_redrive_policy" "this" {
  count = var.create_dlq ? 1 : 0

  queue_url = aws_sqs_queue.this.id

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq[0].arn
    maxReceiveCount     = var.max_receive_count
  })
}

resource "aws_sqs_queue_redrive_allow_policy" "dlq" {
  count = var.create_dlq ? 1 : 0

  queue_url = aws_sqs_queue.dlq[0].id

  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue"
    sourceQueueArns   = [aws_sqs_queue.this.arn]
  })
}
