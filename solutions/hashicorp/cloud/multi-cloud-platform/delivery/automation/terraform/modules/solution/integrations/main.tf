#------------------------------------------------------------------------------
# Integrations Module
#------------------------------------------------------------------------------
# Handles cross-module connections to avoid circular dependencies:
# - WAF to ALB association
# - Vault AWS secrets engine
# - CloudWatch alarms for platform health
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
# Vault AWS Secrets Engine (connects vault → aws)
#------------------------------------------------------------------------------
resource "vault_aws_secret_backend" "aws" {
  count = var.vault_enabled && var.vault_aws_secrets_enabled ? 1 : 0

  access_key = var.vault_aws_access_key
  secret_key = var.vault_aws_secret_key
  region     = var.aws_region

  default_lease_ttl_seconds = var.vault_credential_ttl_seconds
  max_lease_ttl_seconds     = var.vault_credential_ttl_seconds * 2
}

resource "vault_aws_secret_backend_role" "admin" {
  count = var.vault_enabled && var.vault_aws_secrets_enabled ? 1 : 0

  backend         = vault_aws_secret_backend.aws[0].path
  name            = "admin"
  credential_type = "iam_user"

  policy_document = <<-EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "*",
      "Resource": "*"
    }
  ]
}
EOT
}

resource "vault_aws_secret_backend_role" "readonly" {
  count = var.vault_enabled && var.vault_aws_secrets_enabled ? 1 : 0

  backend         = vault_aws_secret_backend.aws[0].path
  name            = "readonly"
  credential_type = "iam_user"

  policy_document = <<-EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:Describe*",
        "s3:Get*",
        "s3:List*",
        "rds:Describe*",
        "eks:Describe*",
        "eks:List*"
      ],
      "Resource": "*"
    }
  ]
}
EOT
}

#------------------------------------------------------------------------------
# EKS CloudWatch Alarms (connects monitoring → compute)
#------------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "eks_cpu" {
  count = var.enable_alarms && var.eks_cluster_name != "" ? 1 : 0

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
  ok_actions    = [var.sns_topic_arn]

  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "eks_memory" {
  count = var.enable_alarms && var.eks_cluster_name != "" ? 1 : 0

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
  ok_actions    = [var.sns_topic_arn]

  tags = var.common_tags
}

#------------------------------------------------------------------------------
# RDS CloudWatch Alarms (connects monitoring → database)
#------------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "rds_cpu" {
  count = var.enable_alarms && var.rds_identifier != "" ? 1 : 0

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
  ok_actions    = [var.sns_topic_arn]

  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "rds_storage" {
  count = var.enable_alarms && var.rds_identifier != "" ? 1 : 0

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
  ok_actions    = [var.sns_topic_arn]

  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "rds_connections" {
  count = var.enable_alarms && var.rds_identifier != "" ? 1 : 0

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
  ok_actions    = [var.sns_topic_arn]

  tags = var.common_tags
}
