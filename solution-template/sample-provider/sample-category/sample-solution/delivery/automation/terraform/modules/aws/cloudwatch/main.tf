# Generic AWS CloudWatch Module
# Creates CloudWatch dashboards, alarms, log groups, and metric filters

terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

data "aws_region" "current" {}

#------------------------------------------------------------------------------
# Log Groups
#------------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "this" {
  for_each = var.log_groups

  name              = each.value.name
  retention_in_days = each.value.retention_days
  kms_key_id        = var.kms_key_arn

  tags = merge(var.tags, {
    Name = each.value.name
  })
}

#------------------------------------------------------------------------------
# Metric Filters
#------------------------------------------------------------------------------

resource "aws_cloudwatch_log_metric_filter" "this" {
  for_each = var.metric_filters

  name           = each.key
  log_group_name = each.value.log_group_name
  pattern        = each.value.pattern

  metric_transformation {
    name          = each.value.metric_name
    namespace     = each.value.metric_namespace
    value         = each.value.metric_value
    default_value = lookup(each.value, "default_value", null)
  }

  depends_on = [aws_cloudwatch_log_group.this]
}

#------------------------------------------------------------------------------
# Alarms
#------------------------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "this" {
  for_each = var.alarms

  alarm_name          = "${var.name_prefix}-${each.key}"
  alarm_description   = each.value.description
  comparison_operator = each.value.comparison_operator
  evaluation_periods  = each.value.evaluation_periods
  metric_name         = each.value.metric_name
  namespace           = each.value.namespace
  period              = each.value.period
  statistic           = each.value.statistic
  threshold           = each.value.threshold
  treat_missing_data  = lookup(each.value, "treat_missing_data", "missing")

  dimensions = lookup(each.value, "dimensions", {})

  alarm_actions             = var.alarm_actions
  ok_actions                = var.ok_actions
  insufficient_data_actions = var.insufficient_data_actions

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-${each.key}"
  })
}

#------------------------------------------------------------------------------
# Dashboard
#------------------------------------------------------------------------------

resource "aws_cloudwatch_dashboard" "this" {
  count = var.create_dashboard ? 1 : 0

  dashboard_name = "${var.name_prefix}-dashboard"
  dashboard_body = var.dashboard_body != "" ? var.dashboard_body : jsonencode({
    widgets = concat(
      # Header widget
      [{
        type   = "text"
        x      = 0
        y      = 0
        width  = 24
        height = 1
        properties = {
          markdown = "# ${var.name_prefix} Infrastructure Dashboard"
        }
      }],
      # Custom widgets from variable
      var.dashboard_widgets
    )
  })
}

#------------------------------------------------------------------------------
# SNS Topic for Alarms (optional)
#------------------------------------------------------------------------------

resource "aws_sns_topic" "alarms" {
  count = var.create_sns_topic ? 1 : 0

  name              = "${var.name_prefix}-alarms"
  kms_master_key_id = var.kms_key_arn

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-alarms"
  })
}

resource "aws_sns_topic_subscription" "email" {
  for_each = var.create_sns_topic ? toset(var.alarm_email_endpoints) : toset([])

  topic_arn = aws_sns_topic.alarms[0].arn
  protocol  = "email"
  endpoint  = each.value
}

#------------------------------------------------------------------------------
# Composite Alarms (optional)
#------------------------------------------------------------------------------

resource "aws_cloudwatch_composite_alarm" "this" {
  for_each = var.composite_alarms

  alarm_name        = "${var.name_prefix}-${each.key}"
  alarm_description = each.value.description
  alarm_rule        = each.value.alarm_rule

  alarm_actions             = var.alarm_actions
  ok_actions                = var.ok_actions
  insufficient_data_actions = var.insufficient_data_actions

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-${each.key}"
  })

  depends_on = [aws_cloudwatch_metric_alarm.this]
}
