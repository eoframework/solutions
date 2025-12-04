#------------------------------------------------------------------------------
# Monitoring Module (Solution-Level)
#------------------------------------------------------------------------------
# Composes aws/cloudwatch provider module for Terraform Enterprise monitoring
#------------------------------------------------------------------------------

data "aws_region" "current" {}

#------------------------------------------------------------------------------
# CloudWatch Module
#------------------------------------------------------------------------------
module "cloudwatch" {
  source = "../../aws/cloudwatch"

  name_prefix = var.name_prefix
  common_tags = var.common_tags
  kms_key_arn = var.kms_key_arn

  # SNS Topic for alerts
  create_sns_topic = true

  # Log Group
  create_log_group   = true
  log_group_name     = "/tfe/${var.name_prefix}"
  log_retention_days = var.monitoring.log_retention_days

  # Dashboard
  create_dashboard = var.monitoring.enable_dashboard
  dashboard_body = var.monitoring.enable_dashboard ? jsonencode({
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
          stat   = "Average"
          period = 300
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
          stat   = "Average"
          period = 300
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
          stat   = "Average"
          period = 300
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
          stat   = "Average"
          period = 300
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 12
        height = 6
        properties = {
          title  = "RDS Database Connections"
          region = data.aws_region.current.name
          metrics = [
            ["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", var.rds_identifier]
          ]
          stat   = "Average"
          period = 300
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 12
        width  = 12
        height = 6
        properties = {
          title  = "RDS Read/Write IOPS"
          region = data.aws_region.current.name
          metrics = [
            ["AWS/RDS", "ReadIOPS", "DBInstanceIdentifier", var.rds_identifier],
            ["AWS/RDS", "WriteIOPS", "DBInstanceIdentifier", var.rds_identifier]
          ]
          stat   = "Average"
          period = 300
        }
      }
    ]
  }) : "{}"
}
