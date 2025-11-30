# Solution Database Module
# Deploys: RDS PostgreSQL/MySQL with encryption and CloudWatch alarms

locals {
  name_prefix = var.name_prefix
  common_tags = var.common_tags

  # Construct full secret name from prefix and suffix
  db_password_secret_name = "${var.name_prefix}-${var.database.password_secret_name}"
}

#------------------------------------------------------------------------------
# Retrieve Database Password from Secrets Manager
#------------------------------------------------------------------------------

data "aws_secretsmanager_secret_version" "db_password" {
  count     = var.database.enabled ? 1 : 0
  secret_id = local.db_password_secret_name
}

#------------------------------------------------------------------------------
# RDS Database
#------------------------------------------------------------------------------

module "rds" {
  source = "../../aws/rds"

  name_prefix          = local.name_prefix
  tags                 = local.common_tags
  environment          = var.environment
  db_subnet_group_name = var.db_subnet_group_name
  security_group_ids   = var.security_group_ids
  kms_key_arn          = var.kms_key_arn
  db_password          = var.database.enabled ? data.aws_secretsmanager_secret_version.db_password[0].secret_string : ""
  database             = var.database
}

#------------------------------------------------------------------------------
# CloudWatch Alarms
#------------------------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "db_cpu" {
  count               = var.enable_alarms ? 1 : 0
  alarm_name          = "${local.name_prefix}-db-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Database CPU utilization is high"
  dimensions          = { DBInstanceIdentifier = module.rds.db_instance_identifier }
  alarm_actions       = var.alarm_sns_topic_arn != "" ? [var.alarm_sns_topic_arn] : []
  tags                = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "db_storage" {
  count               = var.enable_alarms ? 1 : 0
  alarm_name          = "${local.name_prefix}-db-storage-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 10737418240 # 10 GB
  alarm_description   = "Database free storage space is low"
  dimensions          = { DBInstanceIdentifier = module.rds.db_instance_identifier }
  alarm_actions       = var.alarm_sns_topic_arn != "" ? [var.alarm_sns_topic_arn] : []
  tags                = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "db_connections" {
  count               = var.enable_alarms ? 1 : 0
  alarm_name          = "${local.name_prefix}-db-connections-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 100
  alarm_description   = "Database connection count is high"
  dimensions          = { DBInstanceIdentifier = module.rds.db_instance_identifier }
  alarm_actions       = var.alarm_sns_topic_arn != "" ? [var.alarm_sns_topic_arn] : []
  tags                = local.common_tags
}
