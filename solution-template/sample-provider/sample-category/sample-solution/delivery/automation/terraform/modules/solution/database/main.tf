# Solution Database Module
# Deploys: RDS PostgreSQL/MySQL with subnet group, parameter group, and encryption
#
# This module is optional - only include in environments that need a database.
#
# Uses generic AWS RDS module for reusable components.

terraform {
  required_version = ">= 1.6.0"
}

locals {
  name_prefix = var.name_prefix
  common_tags = var.common_tags
}

#------------------------------------------------------------------------------
# RDS Database (using generic RDS module)
#------------------------------------------------------------------------------

module "rds" {
  source = "../../aws/rds"

  name_prefix          = local.name_prefix
  tags                 = local.common_tags
  db_subnet_group_name = var.db_subnet_group_name
  security_group_ids   = var.security_group_ids
  engine               = var.db_engine
  engine_version       = var.db_engine_version
  instance_class       = var.db_instance_class
  allocated_storage    = var.db_allocated_storage
  max_allocated_storage = var.db_max_allocated_storage
  storage_type         = var.db_storage_type
  storage_encrypted    = var.db_storage_encrypted
  kms_key_arn          = var.db_storage_encrypted ? var.kms_key_arn : null
  database_name        = var.db_name
  master_username      = var.db_username
  master_password      = var.db_password
  multi_az             = var.db_multi_az
  backup_retention_period = var.db_backup_retention
  backup_window        = var.db_backup_window
  maintenance_window   = var.db_maintenance_window
  performance_insights_enabled = var.db_performance_insights
  cloudwatch_logs_exports = var.db_cloudwatch_logs_exports
  deletion_protection  = var.db_deletion_protection
  skip_final_snapshot  = var.environment == "test" ? true : false
  final_snapshot_identifier = var.environment != "test" ? "${local.name_prefix}-db-final-snapshot" : null
  parameters           = var.db_parameters
}

#------------------------------------------------------------------------------
# CloudWatch Alarms
#------------------------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "db_cpu" {
  count = var.enable_alarms ? 1 : 0

  alarm_name          = "${local.name_prefix}-db-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Database CPU utilization is high"

  dimensions = {
    DBInstanceIdentifier = module.rds.db_instance_identifier
  }

  alarm_actions = var.alarm_sns_topic_arn != "" ? [var.alarm_sns_topic_arn] : []

  tags = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "db_storage" {
  count = var.enable_alarms ? 1 : 0

  alarm_name          = "${local.name_prefix}-db-storage-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 10737418240 # 10 GB in bytes
  alarm_description   = "Database free storage space is low"

  dimensions = {
    DBInstanceIdentifier = module.rds.db_instance_identifier
  }

  alarm_actions = var.alarm_sns_topic_arn != "" ? [var.alarm_sns_topic_arn] : []

  tags = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "db_connections" {
  count = var.enable_alarms ? 1 : 0

  alarm_name          = "${local.name_prefix}-db-connections-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = var.db_max_connections_threshold
  alarm_description   = "Database connection count is high"

  dimensions = {
    DBInstanceIdentifier = module.rds.db_instance_identifier
  }

  alarm_actions = var.alarm_sns_topic_arn != "" ? [var.alarm_sns_topic_arn] : []

  tags = local.common_tags
}
