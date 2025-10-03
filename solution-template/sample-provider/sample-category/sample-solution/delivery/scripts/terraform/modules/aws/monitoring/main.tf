# AWS Monitoring Module
# CloudWatch dashboards, alarms, and logging configuration

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Local values for AWS monitoring
locals {
  monitoring_name_prefix = "${var.name_prefix}-monitoring"

  # Common tags for monitoring resources
  monitoring_tags = merge(var.tags, {
    Module  = "aws-monitoring"
    Purpose = "observability"
  })
}

# CloudWatch Log Group for application logs
resource "aws_cloudwatch_log_group" "application_logs" {
  name              = "/aws/${var.project_name}/${var.environment}/application"
  retention_in_days = var.log_retention_days

  tags = local.monitoring_tags
}

# CloudWatch Log Group for system logs
resource "aws_cloudwatch_log_group" "system_logs" {
  name              = "/aws/${var.project_name}/${var.environment}/system"
  retention_in_days = var.log_retention_days

  tags = local.monitoring_tags
}

# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${local.monitoring_name_prefix}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization"],
            ["AWS/ApplicationELB", "TargetResponseTime"]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.region
          title   = "EC2 and ALB Metrics"
          period  = 300
        }
      },
      {
        type   = "log"
        x      = 0
        y      = 6
        width  = 24
        height = 6

        properties = {
          query   = "SOURCE '${aws_cloudwatch_log_group.application_logs.name}' | fields @timestamp, @message | sort @timestamp desc | limit 100"
          region  = var.region
          title   = "Recent Application Logs"
        }
      }
    ]
  })
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${local.monitoring_name_prefix}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors ec2 cpu utilization"
  alarm_actions       = var.alarm_actions

  tags = local.monitoring_tags
}

resource "aws_cloudwatch_metric_alarm" "high_response_time" {
  alarm_name          = "${local.monitoring_name_prefix}-high-response-time"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  statistic           = "Average"
  threshold           = "2"
  alarm_description   = "This metric monitors ALB response time"
  alarm_actions       = var.alarm_actions

  tags = local.monitoring_tags
}

# SNS Topic for alerts (if not provided)
resource "aws_sns_topic" "alerts" {
  count = length(var.alarm_actions) == 0 ? 1 : 0
  name  = "${local.monitoring_name_prefix}-alerts"

  tags = local.monitoring_tags
}

# CloudTrail for audit logging
resource "aws_cloudtrail" "main" {
  name                          = "${local.monitoring_name_prefix}-trail"
  s3_bucket_name               = aws_s3_bucket.cloudtrail.id
  include_global_service_events = true
  is_multi_region_trail        = true
  enable_logging               = true

  tags = local.monitoring_tags
}

# S3 bucket for CloudTrail logs
resource "aws_s3_bucket" "cloudtrail" {
  bucket        = "${local.monitoring_name_prefix}-cloudtrail-${random_id.bucket_suffix.hex}"
  force_destroy = true

  tags = local.monitoring_tags
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# S3 bucket policy for CloudTrail
resource "aws_s3_bucket_policy" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSCloudTrailAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.cloudtrail.arn
      },
      {
        Sid    = "AWSCloudTrailWrite"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.cloudtrail.arn}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}