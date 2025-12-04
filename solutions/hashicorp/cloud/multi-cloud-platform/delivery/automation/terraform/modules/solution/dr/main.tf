#------------------------------------------------------------------------------
# Disaster Recovery Module
#------------------------------------------------------------------------------
# Cross-region replication and DR infrastructure
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# DR KMS Key (in DR region)
#------------------------------------------------------------------------------
resource "aws_kms_key" "dr" {
  provider = aws.dr

  description             = "${var.name_prefix} DR encryption key"
  deletion_window_in_days = var.dr.key_rotation_days
  enable_key_rotation     = true

  tags = merge(var.common_tags, {
    Purpose = "DisasterRecovery"
  })
}

resource "aws_kms_alias" "dr" {
  provider = aws.dr

  name          = "alias/${var.name_prefix}-dr"
  target_key_id = aws_kms_key.dr.key_id
}

#------------------------------------------------------------------------------
# S3 Replication Bucket (DR Region)
#------------------------------------------------------------------------------
resource "aws_s3_bucket" "dr" {
  provider = aws.dr

  bucket = "${var.name_prefix}-dr-${var.dr_region}"

  tags = merge(var.common_tags, {
    Purpose = "DisasterRecovery"
  })
}

resource "aws_s3_bucket_versioning" "dr" {
  provider = aws.dr

  bucket = aws_s3_bucket.dr.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "dr" {
  provider = aws.dr

  bucket = aws_s3_bucket.dr.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.dr.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "dr" {
  provider = aws.dr
  count    = var.dr.enable_lifecycle ? 1 : 0

  bucket = aws_s3_bucket.dr.id

  rule {
    id     = "archive"
    status = "Enabled"

    transition {
      days          = var.dr.archive_after_days
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = var.dr.coldline_after_days
      storage_class = "GLACIER"
    }
  }
}

#------------------------------------------------------------------------------
# Route 53 Health Check (for failover)
#------------------------------------------------------------------------------
resource "aws_route53_health_check" "primary" {
  count = var.dr.enable_health_check ? 1 : 0

  fqdn              = var.dr.primary_endpoint
  port              = var.dr.health_check_port
  type              = "HTTPS"
  resource_path     = var.dr.health_check_path
  failure_threshold = var.dr.unhealthy_threshold
  request_interval  = var.dr.health_check_interval_sec

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-primary-health"
  })
}

#------------------------------------------------------------------------------
# CloudWatch Alarm for DR Status
#------------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "dr_health" {
  count = var.dr.enable_health_check ? 1 : 0

  alarm_name          = "${var.name_prefix}-dr-health"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "HealthCheckStatus"
  namespace           = "AWS/Route53"
  period              = 60
  statistic           = "Minimum"
  threshold           = 1
  alarm_description   = "Primary region health check failed"

  dimensions = {
    HealthCheckId = aws_route53_health_check.primary[0].id
  }

  tags = var.common_tags
}
