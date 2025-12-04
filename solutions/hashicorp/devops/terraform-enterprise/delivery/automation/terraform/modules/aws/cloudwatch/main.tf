#------------------------------------------------------------------------------
# AWS CloudWatch Module (Provider-Level Primitive)
#------------------------------------------------------------------------------
# Reusable CloudWatch resources (log groups, dashboards, alarms, SNS)
#------------------------------------------------------------------------------

data "aws_region" "current" {}

#------------------------------------------------------------------------------
# SNS Topic for Alerts
#------------------------------------------------------------------------------
resource "aws_sns_topic" "alerts" {
  count = var.create_sns_topic ? 1 : 0

  name              = "${var.name_prefix}-alerts"
  kms_master_key_id = var.kms_key_arn != "" ? var.kms_key_arn : null

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-alerts"
  })
}

#------------------------------------------------------------------------------
# CloudWatch Log Group
#------------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "main" {
  count = var.create_log_group ? 1 : 0

  name              = var.log_group_name != "" ? var.log_group_name : "/${var.name_prefix}/logs"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.kms_key_arn != "" ? var.kms_key_arn : null

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-logs"
  })
}

#------------------------------------------------------------------------------
# CloudWatch Dashboard
#------------------------------------------------------------------------------
resource "aws_cloudwatch_dashboard" "main" {
  count = var.create_dashboard ? 1 : 0

  dashboard_name = "${var.name_prefix}-dashboard"
  dashboard_body = var.dashboard_body
}

#------------------------------------------------------------------------------
# CloudWatch Alarms
#------------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "alarms" {
  for_each = var.alarms

  alarm_name          = "${var.name_prefix}-${each.key}"
  comparison_operator = each.value.comparison_operator
  evaluation_periods  = each.value.evaluation_periods
  metric_name         = each.value.metric_name
  namespace           = each.value.namespace
  period              = each.value.period
  statistic           = each.value.statistic
  threshold           = each.value.threshold
  alarm_description   = each.value.description
  treat_missing_data  = lookup(each.value, "treat_missing_data", "missing")

  dimensions = each.value.dimensions

  alarm_actions             = var.create_sns_topic ? [aws_sns_topic.alerts[0].arn] : var.alarm_actions
  ok_actions                = var.create_sns_topic ? [aws_sns_topic.alerts[0].arn] : var.ok_actions
  insufficient_data_actions = var.create_sns_topic ? [aws_sns_topic.alerts[0].arn] : var.insufficient_data_actions

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-${each.key}"
  })
}
