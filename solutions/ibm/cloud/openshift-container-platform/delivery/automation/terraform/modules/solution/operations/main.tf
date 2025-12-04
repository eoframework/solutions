#------------------------------------------------------------------------------
# OpenShift Solution - Operations Module
#------------------------------------------------------------------------------
# Orchestrates operational infrastructure using AWS provider modules:
# - S3 backup storage
# - CloudWatch alarms
# - DR configuration
#------------------------------------------------------------------------------

locals {
  name_prefix = "${var.cluster_name}-${var.environment}"

  common_tags = merge(var.common_tags, {
    Environment = var.environment
    Cluster     = var.cluster_name
    Platform    = "openshift"
    ManagedBy   = "terraform"
  })
}

#------------------------------------------------------------------------------
# S3 Backup Storage
#------------------------------------------------------------------------------
module "backup" {
  source = "../../aws/s3-backup"
  count  = var.backup.enabled ? 1 : 0

  name_prefix           = local.name_prefix
  bucket_name           = var.backup.s3_bucket
  kms_key_arn           = var.security.kms_key_arn
  etcd_retention_days   = var.backup.retention_days
  config_retention_days = var.backup.retention_days * 3
  log_retention_days    = 365

  common_tags = local.common_tags
}

#------------------------------------------------------------------------------
# CloudWatch Alarms
#------------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "control_plane_cpu" {
  count = var.monitoring.cloudwatch_alarms_enabled ? length(var.control_plane_instance_ids) : 0

  alarm_name          = "${local.name_prefix}-master-${count.index}-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Control plane node ${count.index} CPU utilization"
  alarm_actions       = var.monitoring.sns_topic_arn != null ? [var.monitoring.sns_topic_arn] : []

  dimensions = {
    InstanceId = var.control_plane_instance_ids[count.index]
  }

  tags = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "worker_cpu" {
  count = var.monitoring.cloudwatch_alarms_enabled ? length(var.worker_instance_ids) : 0

  alarm_name          = "${local.name_prefix}-worker-${count.index}-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Worker node ${count.index} CPU utilization"
  alarm_actions       = var.monitoring.sns_topic_arn != null ? [var.monitoring.sns_topic_arn] : []

  dimensions = {
    InstanceId = var.worker_instance_ids[count.index]
  }

  tags = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "api_lb_healthy" {
  count = var.monitoring.cloudwatch_alarms_enabled && var.api_target_group_arn != null ? 1 : 0

  alarm_name          = "${local.name_prefix}-api-healthy-hosts"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "HealthyHostCount"
  namespace           = "AWS/NetworkELB"
  period              = 60
  statistic           = "Average"
  threshold           = 2
  alarm_description   = "API load balancer healthy host count"
  alarm_actions       = var.monitoring.sns_topic_arn != null ? [var.monitoring.sns_topic_arn] : []

  dimensions = {
    TargetGroup  = var.api_target_group_arn
    LoadBalancer = var.api_lb_arn
  }

  tags = local.common_tags
}

#------------------------------------------------------------------------------
# SNS Topic for Alerts
#------------------------------------------------------------------------------
resource "aws_sns_topic" "alerts" {
  count = var.monitoring.create_sns_topic ? 1 : 0

  name = "${local.name_prefix}-alerts"

  tags = local.common_tags
}

resource "aws_sns_topic_subscription" "email" {
  count = var.monitoring.create_sns_topic && var.monitoring.alert_email != null ? 1 : 0

  topic_arn = aws_sns_topic.alerts[0].arn
  protocol  = "email"
  endpoint  = var.monitoring.alert_email
}

#------------------------------------------------------------------------------
# Backup Schedule (using EventBridge)
#------------------------------------------------------------------------------
resource "aws_cloudwatch_event_rule" "etcd_backup" {
  count = var.backup.enabled ? 1 : 0

  name                = "${local.name_prefix}-etcd-backup"
  description         = "Schedule etcd backup"
  schedule_expression = "cron(${var.backup.schedule_cron})"

  tags = local.common_tags
}
