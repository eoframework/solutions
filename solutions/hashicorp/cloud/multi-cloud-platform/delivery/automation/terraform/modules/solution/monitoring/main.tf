#------------------------------------------------------------------------------
# Monitoring Module
#------------------------------------------------------------------------------
# CloudWatch dashboards, metrics, and SNS topics for alerting
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# SNS Topic for Alerts
#------------------------------------------------------------------------------
resource "aws_sns_topic" "alerts" {
  name              = "${var.name_prefix}-alerts"
  kms_master_key_id = var.kms_key_arn

  tags = var.common_tags
}

resource "aws_sns_topic_subscription" "email" {
  count = var.monitoring.alert_email != "" ? 1 : 0

  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.monitoring.alert_email
}

#------------------------------------------------------------------------------
# CloudWatch Dashboard
#------------------------------------------------------------------------------
resource "aws_cloudwatch_dashboard" "main" {
  count = var.monitoring.enable_dashboard ? 1 : 0

  dashboard_name = "${var.name_prefix}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "EKS Cluster CPU"
          region = data.aws_region.current.name
          metrics = [
            ["ContainerInsights", "node_cpu_utilization", "ClusterName", var.eks_cluster_name]
          ]
          period = 300
          stat   = "Average"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "EKS Cluster Memory"
          region = data.aws_region.current.name
          metrics = [
            ["ContainerInsights", "node_memory_utilization", "ClusterName", var.eks_cluster_name]
          ]
          period = 300
          stat   = "Average"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          title  = "RDS CPU Utilization"
          region = data.aws_region.current.name
          metrics = [
            ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", var.rds_identifier]
          ]
          period = 300
          stat   = "Average"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          title  = "RDS Free Storage"
          region = data.aws_region.current.name
          metrics = [
            ["AWS/RDS", "FreeStorageSpace", "DBInstanceIdentifier", var.rds_identifier]
          ]
          period = 300
          stat   = "Average"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 12
        height = 6
        properties = {
          title  = "RDS Connections"
          region = data.aws_region.current.name
          metrics = [
            ["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", var.rds_identifier]
          ]
          period = 300
          stat   = "Average"
        }
      }
    ]
  })
}

#------------------------------------------------------------------------------
# CloudWatch Log Groups
#------------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "application" {
  name              = "/aws/${var.name_prefix}/application"
  retention_in_days = var.monitoring.log_retention_days
  kms_key_id        = var.kms_key_arn

  tags = var.common_tags
}

resource "aws_cloudwatch_log_group" "platform" {
  name              = "/aws/${var.name_prefix}/platform"
  retention_in_days = var.monitoring.log_retention_days
  kms_key_id        = var.kms_key_arn

  tags = var.common_tags
}

#------------------------------------------------------------------------------
# Data Sources
#------------------------------------------------------------------------------
data "aws_region" "current" {}
