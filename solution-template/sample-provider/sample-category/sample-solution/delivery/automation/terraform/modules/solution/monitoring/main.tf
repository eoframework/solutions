# Solution Monitoring Module
# Deploys: CloudWatch Dashboard, Log Groups, SNS Topics, X-Ray
#
# This module is optional - include for comprehensive observability.
#
# Uses generic AWS CloudWatch module for reusable components.

locals {
  name_prefix = var.name_prefix
  common_tags = var.common_tags

  # Extract ALB name from ARN for CloudWatch metrics
  alb_name = var.alb_arn != "" ? element(split("/", var.alb_arn), length(split("/", var.alb_arn)) - 1) : ""
}

data "aws_region" "current" {}

#------------------------------------------------------------------------------
# CloudWatch Resources (using generic CloudWatch module)
#------------------------------------------------------------------------------

module "cloudwatch" {
  source = "../../aws/cloudwatch"

  name_prefix       = local.name_prefix
  tags              = local.common_tags
  kms_key_arn       = var.kms_key_arn
  create_sns_topic  = true
  alarm_email_endpoints = var.alarm_email != "" ? [var.alarm_email] : []

  # Log Groups
  log_groups = merge(
    {
      application = {
        name           = "/aws/application/${local.name_prefix}"
        retention_days = var.monitoring.log_retention_days
      }
    },
    var.monitoring.enable_container_insights ? {
      ecs = {
        name           = "/aws/ecs/${local.name_prefix}"
        retention_days = var.monitoring.log_retention_days
      }
    } : {}
  )

  # Dashboard
  create_dashboard = var.monitoring.enable_dashboard
  dashboard_widgets = var.monitoring.enable_dashboard ? concat(
    # ALB Metrics (if ALB exists)
    var.alb_arn != "" ? [
      {
        type   = "metric"
        x      = 0
        y      = 1
        width  = 8
        height = 6
        properties = {
          title  = "ALB Request Count"
          region = data.aws_region.current.id
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", local.alb_name, { stat = "Sum", period = 60 }]
          ]
        }
      },
      {
        type   = "metric"
        x      = 8
        y      = 1
        width  = 8
        height = 6
        properties = {
          title  = "ALB Response Time"
          region = data.aws_region.current.id
          metrics = [
            ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", local.alb_name, { stat = "Average", period = 60 }]
          ]
        }
      },
      {
        type   = "metric"
        x      = 16
        y      = 1
        width  = 8
        height = 6
        properties = {
          title  = "ALB HTTP Errors"
          region = data.aws_region.current.id
          metrics = [
            ["AWS/ApplicationELB", "HTTPCode_ELB_4XX_Count", "LoadBalancer", local.alb_name, { stat = "Sum", period = 60, color = "#ff7f0e" }],
            ["AWS/ApplicationELB", "HTTPCode_ELB_5XX_Count", "LoadBalancer", local.alb_name, { stat = "Sum", period = 60, color = "#d62728" }]
          ]
        }
      }
    ] : [],

    # ASG Metrics (if ASG exists)
    var.asg_name != "" ? [
      {
        type   = "metric"
        x      = 0
        y      = 7
        width  = 8
        height = 6
        properties = {
          title  = "ASG Instance Count"
          region = data.aws_region.current.id
          metrics = [
            ["AWS/AutoScaling", "GroupDesiredCapacity", "AutoScalingGroupName", var.asg_name, { stat = "Average", period = 60 }],
            ["AWS/AutoScaling", "GroupInServiceInstances", "AutoScalingGroupName", var.asg_name, { stat = "Average", period = 60 }]
          ]
        }
      },
      {
        type   = "metric"
        x      = 8
        y      = 7
        width  = 8
        height = 6
        properties = {
          title  = "EC2 CPU Utilization"
          region = data.aws_region.current.id
          metrics = [
            ["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", var.asg_name, { stat = "Average", period = 60 }]
          ]
        }
      },
      {
        type   = "metric"
        x      = 16
        y      = 7
        width  = 8
        height = 6
        properties = {
          title  = "EC2 Network"
          region = data.aws_region.current.id
          metrics = [
            ["AWS/EC2", "NetworkIn", "AutoScalingGroupName", var.asg_name, { stat = "Sum", period = 60 }],
            ["AWS/EC2", "NetworkOut", "AutoScalingGroupName", var.asg_name, { stat = "Sum", period = 60 }]
          ]
        }
      }
    ] : [],

    # RDS Metrics (if RDS exists)
    var.rds_identifier != "" ? [
      {
        type   = "metric"
        x      = 0
        y      = 13
        width  = 8
        height = 6
        properties = {
          title  = "RDS CPU Utilization"
          region = data.aws_region.current.id
          metrics = [
            ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", var.rds_identifier, { stat = "Average", period = 60 }]
          ]
        }
      },
      {
        type   = "metric"
        x      = 8
        y      = 13
        width  = 8
        height = 6
        properties = {
          title  = "RDS Connections"
          region = data.aws_region.current.id
          metrics = [
            ["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", var.rds_identifier, { stat = "Average", period = 60 }]
          ]
        }
      },
      {
        type   = "metric"
        x      = 16
        y      = 13
        width  = 8
        height = 6
        properties = {
          title  = "RDS Free Storage"
          region = data.aws_region.current.id
          metrics = [
            ["AWS/RDS", "FreeStorageSpace", "DBInstanceIdentifier", var.rds_identifier, { stat = "Average", period = 60 }]
          ]
        }
      }
    ] : [],

    # Cache Metrics (if cache exists)
    var.cache_cluster_id != "" ? [
      {
        type   = "metric"
        x      = 0
        y      = 19
        width  = 8
        height = 6
        properties = {
          title  = "Cache CPU Utilization"
          region = data.aws_region.current.id
          metrics = [
            ["AWS/ElastiCache", "CPUUtilization", "CacheClusterId", var.cache_cluster_id, { stat = "Average", period = 60 }]
          ]
        }
      },
      {
        type   = "metric"
        x      = 8
        y      = 19
        width  = 8
        height = 6
        properties = {
          title  = "Cache Hit Rate"
          region = data.aws_region.current.id
          metrics = [
            ["AWS/ElastiCache", "CacheHitRate", "CacheClusterId", var.cache_cluster_id, { stat = "Average", period = 60 }]
          ]
        }
      },
      {
        type   = "metric"
        x      = 16
        y      = 19
        width  = 8
        height = 6
        properties = {
          title  = "Cache Memory Usage"
          region = data.aws_region.current.id
          metrics = [
            ["AWS/ElastiCache", "DatabaseMemoryUsagePercentage", "CacheClusterId", var.cache_cluster_id, { stat = "Average", period = 60 }]
          ]
        }
      }
    ] : []
  ) : []
}

#------------------------------------------------------------------------------
# X-Ray Sampling Rule
#------------------------------------------------------------------------------

resource "aws_xray_sampling_rule" "main" {
  count = var.monitoring.enable_xray_tracing ? 1 : 0

  rule_name      = "${local.name_prefix}-sampling"
  priority       = 1000
  version        = 1
  reservoir_size = 1
  fixed_rate     = 0.05
  url_path       = "*"
  host           = "*"
  http_method    = "*"
  service_type   = "*"
  service_name   = var.project_name
  resource_arn   = "*"

  attributes = {}
}
