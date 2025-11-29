# AWS Budgets Module
# Pillar: Cost Optimization
#
# Implements cost monitoring and alerting using AWS Budgets.
# Supports cost, usage, and reservation budgets.

#------------------------------------------------------------------------------
# Monthly Cost Budget
#------------------------------------------------------------------------------

resource "aws_budgets_budget" "monthly_cost" {
  count = var.enable_cost_budget ? 1 : 0

  name         = "${var.name_prefix}-monthly-cost"
  budget_type  = "COST"
  limit_amount = var.monthly_budget_amount
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  # Filter by linked account (optional)
  dynamic "cost_filter" {
    for_each = var.linked_account_ids != null ? [1] : []
    content {
      name   = "LinkedAccount"
      values = var.linked_account_ids
    }
  }

  # Filter by tags (optional)
  dynamic "cost_filter" {
    for_each = var.cost_filter_tags != null ? [1] : []
    content {
      name   = "TagKeyValue"
      values = [for k, v in var.cost_filter_tags : "user:${k}$${v}"]
    }
  }

  # Filter by service (optional)
  dynamic "cost_filter" {
    for_each = var.cost_filter_services != null ? [1] : []
    content {
      name   = "Service"
      values = var.cost_filter_services
    }
  }

  # Alert at threshold percentages
  dynamic "notification" {
    for_each = var.alert_thresholds
    content {
      comparison_operator        = "GREATER_THAN"
      threshold                  = notification.value
      threshold_type             = "PERCENTAGE"
      notification_type          = "ACTUAL"
      subscriber_email_addresses = var.alert_emails
      subscriber_sns_topic_arns  = var.sns_topic_arns
    }
  }

  # Forecasted cost alert
  dynamic "notification" {
    for_each = var.enable_forecast_alert ? [1] : []
    content {
      comparison_operator        = "GREATER_THAN"
      threshold                  = var.forecast_threshold
      threshold_type             = "PERCENTAGE"
      notification_type          = "FORECASTED"
      subscriber_email_addresses = var.alert_emails
      subscriber_sns_topic_arns  = var.sns_topic_arns
    }
  }

  tags = merge(var.common_tags, {
    Name   = "${var.name_prefix}-monthly-cost"
    Pillar = "CostOptimization"
  })
}

#------------------------------------------------------------------------------
# Service-Specific Budgets
#------------------------------------------------------------------------------

resource "aws_budgets_budget" "ec2" {
  count = var.enable_service_budgets && var.ec2_budget_amount > 0 ? 1 : 0

  name         = "${var.name_prefix}-ec2-cost"
  budget_type  = "COST"
  limit_amount = var.ec2_budget_amount
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  cost_filter {
    name   = "Service"
    values = ["Amazon Elastic Compute Cloud - Compute"]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = var.alert_emails
    subscriber_sns_topic_arns  = var.sns_topic_arns
  }

  tags = merge(var.common_tags, {
    Name    = "${var.name_prefix}-ec2-cost"
    Pillar  = "CostOptimization"
    Service = "EC2"
  })
}

resource "aws_budgets_budget" "rds" {
  count = var.enable_service_budgets && var.rds_budget_amount > 0 ? 1 : 0

  name         = "${var.name_prefix}-rds-cost"
  budget_type  = "COST"
  limit_amount = var.rds_budget_amount
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  cost_filter {
    name   = "Service"
    values = ["Amazon Relational Database Service"]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = var.alert_emails
    subscriber_sns_topic_arns  = var.sns_topic_arns
  }

  tags = merge(var.common_tags, {
    Name    = "${var.name_prefix}-rds-cost"
    Pillar  = "CostOptimization"
    Service = "RDS"
  })
}

resource "aws_budgets_budget" "data_transfer" {
  count = var.enable_service_budgets && var.data_transfer_budget_amount > 0 ? 1 : 0

  name         = "${var.name_prefix}-data-transfer-cost"
  budget_type  = "COST"
  limit_amount = var.data_transfer_budget_amount
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  cost_filter {
    name   = "UsageType"
    values = ["DataTransfer-Out-Bytes", "DataTransfer-Regional-Bytes"]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = var.alert_emails
    subscriber_sns_topic_arns  = var.sns_topic_arns
  }

  tags = merge(var.common_tags, {
    Name    = "${var.name_prefix}-data-transfer-cost"
    Pillar  = "CostOptimization"
    Service = "DataTransfer"
  })
}

#------------------------------------------------------------------------------
# Usage Budget (Optional)
#------------------------------------------------------------------------------

resource "aws_budgets_budget" "ec2_hours" {
  count = var.enable_usage_budget ? 1 : 0

  name         = "${var.name_prefix}-ec2-usage-hours"
  budget_type  = "USAGE"
  limit_amount = var.ec2_usage_hours_limit
  limit_unit   = "Hrs"
  time_unit    = "MONTHLY"

  cost_filter {
    name   = "Service"
    values = ["Amazon Elastic Compute Cloud - Compute"]
  }

  cost_filter {
    name   = "UsageType"
    values = ["BoxUsage:*"]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = var.alert_emails
    subscriber_sns_topic_arns  = var.sns_topic_arns
  }

  tags = merge(var.common_tags, {
    Name   = "${var.name_prefix}-ec2-usage-hours"
    Pillar = "CostOptimization"
    Type   = "UsageBudget"
  })
}

#------------------------------------------------------------------------------
# Budget Actions (Auto-remediation)
#------------------------------------------------------------------------------

resource "aws_budgets_budget_action" "stop_ec2" {
  count = var.enable_budget_actions ? 1 : 0

  budget_name        = aws_budgets_budget.monthly_cost[0].name
  action_type        = "RUN_SSM_DOCUMENTS"
  approval_model     = var.budget_action_approval
  notification_type  = "ACTUAL"

  action_threshold {
    action_threshold_type  = "PERCENTAGE"
    action_threshold_value = var.action_threshold
  }

  definition {
    ssm_action_definition {
      action_sub_type = "STOP_EC2_INSTANCES"
      instance_ids    = var.ec2_instance_ids_to_stop
      region          = data.aws_region.current.name
    }
  }

  execution_role_arn = aws_iam_role.budget_action[0].arn

  subscriber {
    subscription_type = "EMAIL"
    address           = var.alert_emails[0]
  }
}

#------------------------------------------------------------------------------
# IAM Role for Budget Actions
#------------------------------------------------------------------------------

resource "aws_iam_role" "budget_action" {
  count = var.enable_budget_actions ? 1 : 0

  name = "${var.name_prefix}-budget-action-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "budgets.amazonaws.com"
      }
    }]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy" "budget_action" {
  count = var.enable_budget_actions ? 1 : 0

  name = "${var.name_prefix}-budget-action-policy"
  role = aws_iam_role.budget_action[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:StopInstances"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:ResourceTag/Environment" = var.environment
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "ssm:StartAutomationExecution"
        ]
        Resource = "*"
      }
    ]
  })
}

#------------------------------------------------------------------------------
# Data Sources
#------------------------------------------------------------------------------

data "aws_region" "current" {}
