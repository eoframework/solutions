#------------------------------------------------------------------------------
# AAP Solution - Operations Module
#------------------------------------------------------------------------------
# Manages backup, monitoring, and DR for AAP infrastructure
#------------------------------------------------------------------------------

locals {
  name_prefix = "${var.solution_abbr}-${var.environment}"
}

#------------------------------------------------------------------------------
# CloudWatch Log Groups
#------------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "aap_logs" {
  name              = "/aap/${var.environment}/controller"
  retention_in_days = var.monitoring.log_retention_days
  kms_key_id        = var.kms_key_arn

  tags = var.common_tags
}

resource "aws_cloudwatch_log_group" "execution_logs" {
  name              = "/aap/${var.environment}/execution"
  retention_in_days = var.monitoring.log_retention_days
  kms_key_id        = var.kms_key_arn

  tags = var.common_tags
}

#------------------------------------------------------------------------------
# SNS Topic for Alerts
#------------------------------------------------------------------------------
resource "aws_sns_topic" "aap_alerts" {
  count = var.monitoring.create_sns_topic ? 1 : 0

  name              = "${local.name_prefix}-alerts"
  kms_master_key_id = var.kms_key_arn

  tags = var.common_tags
}

resource "aws_sns_topic_subscription" "email" {
  count = var.monitoring.create_sns_topic && var.monitoring.alert_email != "" ? 1 : 0

  topic_arn = aws_sns_topic.aap_alerts[0].arn
  protocol  = "email"
  endpoint  = var.monitoring.alert_email
}

locals {
  sns_topic_arn = var.monitoring.create_sns_topic ? aws_sns_topic.aap_alerts[0].arn : var.monitoring.sns_topic_arn
}

#------------------------------------------------------------------------------
# CloudWatch Alarms - Controller
#------------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "controller_cpu" {
  count = length(var.controller_instance_ids) > 0 && var.monitoring.cloudwatch_alarms_enabled ? length(var.controller_instance_ids) : 0

  alarm_name          = "${local.name_prefix}-controller-${count.index + 1}-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Controller ${count.index + 1} CPU utilization is high"

  dimensions = {
    InstanceId = var.controller_instance_ids[count.index]
  }

  alarm_actions = local.sns_topic_arn != null ? [local.sns_topic_arn] : []
  ok_actions    = local.sns_topic_arn != null ? [local.sns_topic_arn] : []

  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "controller_status" {
  count = length(var.controller_instance_ids) > 0 && var.monitoring.cloudwatch_alarms_enabled ? length(var.controller_instance_ids) : 0

  alarm_name          = "${local.name_prefix}-controller-${count.index + 1}-status"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "Controller ${count.index + 1} status check failed"

  dimensions = {
    InstanceId = var.controller_instance_ids[count.index]
  }

  alarm_actions = local.sns_topic_arn != null ? [local.sns_topic_arn] : []
  ok_actions    = local.sns_topic_arn != null ? [local.sns_topic_arn] : []

  tags = var.common_tags
}

#------------------------------------------------------------------------------
# CloudWatch Alarms - Database
#------------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "db_cpu" {
  count = var.db_instance_identifier != "" && var.monitoring.cloudwatch_alarms_enabled ? 1 : 0

  alarm_name          = "${local.name_prefix}-db-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "AAP database CPU utilization is high"

  dimensions = {
    DBInstanceIdentifier = var.db_instance_identifier
  }

  alarm_actions = local.sns_topic_arn != null ? [local.sns_topic_arn] : []
  ok_actions    = local.sns_topic_arn != null ? [local.sns_topic_arn] : []

  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "db_storage" {
  count = var.db_instance_identifier != "" && var.monitoring.cloudwatch_alarms_enabled ? 1 : 0

  alarm_name          = "${local.name_prefix}-db-storage-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 10737418240 # 10GB
  alarm_description   = "AAP database free storage is low"

  dimensions = {
    DBInstanceIdentifier = var.db_instance_identifier
  }

  alarm_actions = local.sns_topic_arn != null ? [local.sns_topic_arn] : []
  ok_actions    = local.sns_topic_arn != null ? [local.sns_topic_arn] : []

  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "db_connections" {
  count = var.db_instance_identifier != "" && var.monitoring.cloudwatch_alarms_enabled ? 1 : 0

  alarm_name          = "${local.name_prefix}-db-connections"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 100
  alarm_description   = "AAP database connection count is high"

  dimensions = {
    DBInstanceIdentifier = var.db_instance_identifier
  }

  alarm_actions = local.sns_topic_arn != null ? [local.sns_topic_arn] : []
  ok_actions    = local.sns_topic_arn != null ? [local.sns_topic_arn] : []

  tags = var.common_tags
}

#------------------------------------------------------------------------------
# S3 Bucket for Backups
#------------------------------------------------------------------------------
resource "aws_s3_bucket" "backups" {
  count = var.backup.enabled ? 1 : 0

  bucket = var.backup.s3_bucket

  tags = merge(var.common_tags, {
    Name = var.backup.s3_bucket
  })
}

resource "aws_s3_bucket_versioning" "backups" {
  count = var.backup.enabled ? 1 : 0

  bucket = aws_s3_bucket.backups[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "backups" {
  count = var.backup.enabled ? 1 : 0

  bucket = aws_s3_bucket.backups[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_key_arn
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "backups" {
  count = var.backup.enabled ? 1 : 0

  bucket = aws_s3_bucket.backups[0].id

  rule {
    id     = "backup-retention"
    status = "Enabled"

    filter {
      prefix = ""
    }

    expiration {
      days = var.backup.retention_days
    }

    noncurrent_version_expiration {
      noncurrent_days = var.backup.retention_days
    }
  }
}

resource "aws_s3_bucket_public_access_block" "backups" {
  count = var.backup.enabled ? 1 : 0

  bucket = aws_s3_bucket.backups[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#------------------------------------------------------------------------------
# AWS Backup Plan (optional)
#------------------------------------------------------------------------------
resource "aws_backup_vault" "aap" {
  count = var.backup.enabled && var.backup.use_aws_backup ? 1 : 0

  name        = "${local.name_prefix}-backup-vault"
  kms_key_arn = var.kms_key_arn

  tags = var.common_tags
}

resource "aws_backup_plan" "aap" {
  count = var.backup.enabled && var.backup.use_aws_backup ? 1 : 0

  name = "${local.name_prefix}-backup-plan"

  rule {
    rule_name         = "daily-backup"
    target_vault_name = aws_backup_vault.aap[0].name
    schedule          = "cron(0 2 * * ? *)" # 2 AM UTC daily

    lifecycle {
      delete_after = var.backup.retention_days
    }
  }

  tags = var.common_tags
}
