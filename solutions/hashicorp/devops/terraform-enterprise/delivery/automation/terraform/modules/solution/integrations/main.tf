#------------------------------------------------------------------------------
# Integrations Module
#------------------------------------------------------------------------------
# Handles cross-module connections that would otherwise create circular
# dependencies if placed directly in the individual modules.
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# WAF to ALB Association (connects security → compute)
#------------------------------------------------------------------------------
resource "aws_wafv2_web_acl_association" "alb" {
  count = var.enable_waf && var.alb_arn != "" ? 1 : 0

  resource_arn = var.alb_arn
  web_acl_arn  = var.waf_web_acl_arn
}

#------------------------------------------------------------------------------
# EKS CloudWatch Alarms (connects compute → monitoring)
#------------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "eks_cpu" {
  count               = var.enable_alarms && var.eks_cluster_name != "" ? 1 : 0
  alarm_name          = "${var.name_prefix}-eks-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "node_cpu_utilization"
  namespace           = "ContainerInsights"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "EKS cluster CPU utilization is high"
  dimensions = {
    ClusterName = var.eks_cluster_name
  }
  alarm_actions = [var.sns_topic_arn]
  tags          = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "eks_memory" {
  count               = var.enable_alarms && var.eks_cluster_name != "" ? 1 : 0
  alarm_name          = "${var.name_prefix}-eks-memory-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "node_memory_utilization"
  namespace           = "ContainerInsights"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "EKS cluster memory utilization is high"
  dimensions = {
    ClusterName = var.eks_cluster_name
  }
  alarm_actions = [var.sns_topic_arn]
  tags          = var.common_tags
}

#------------------------------------------------------------------------------
# RDS CloudWatch Alarms (connects database → monitoring)
#------------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "rds_cpu" {
  count               = var.enable_alarms && var.rds_identifier != "" ? 1 : 0
  alarm_name          = "${var.name_prefix}-rds-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "RDS CPU utilization is high"
  dimensions = {
    DBInstanceIdentifier = var.rds_identifier
  }
  alarm_actions = [var.sns_topic_arn]
  tags          = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "rds_storage" {
  count               = var.enable_alarms && var.rds_identifier != "" ? 1 : 0
  alarm_name          = "${var.name_prefix}-rds-storage-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 5368709120 # 5 GB
  alarm_description   = "RDS free storage space is low"
  dimensions = {
    DBInstanceIdentifier = var.rds_identifier
  }
  alarm_actions = [var.sns_topic_arn]
  tags          = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "rds_connections" {
  count               = var.enable_alarms && var.rds_identifier != "" ? 1 : 0
  alarm_name          = "${var.name_prefix}-rds-connections-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 100
  alarm_description   = "RDS connection count is high"
  dimensions = {
    DBInstanceIdentifier = var.rds_identifier
  }
  alarm_actions = [var.sns_topic_arn]
  tags          = var.common_tags
}
