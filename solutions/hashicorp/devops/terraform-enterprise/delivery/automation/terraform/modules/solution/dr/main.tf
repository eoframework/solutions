#------------------------------------------------------------------------------
# DR Module
#------------------------------------------------------------------------------
# Manages Disaster Recovery configuration
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# DR SNS Topic for Failover Notifications
#------------------------------------------------------------------------------
resource "aws_sns_topic" "dr_alerts" {
  name              = "${var.name_prefix}-dr-alerts"
  kms_master_key_id = var.kms_key_arn

  tags = var.common_tags
}

#------------------------------------------------------------------------------
# DR Status Parameter Store
#------------------------------------------------------------------------------
resource "aws_ssm_parameter" "dr_status" {
  name        = "/${var.name_prefix}/dr/status"
  description = "DR status for ${var.name_prefix}"
  type        = "String"
  value = jsonencode({
    enabled       = var.dr.enabled
    strategy      = var.dr.strategy
    rto_minutes   = var.dr.rto_minutes
    rpo_minutes   = var.dr.rpo_minutes
    failover_mode = var.dr.failover_mode
    last_updated  = timestamp()
  })

  tags = var.common_tags
}

#------------------------------------------------------------------------------
# DR Health Check (Route 53)
#------------------------------------------------------------------------------
resource "aws_route53_health_check" "primary" {
  count = var.dr.enabled ? 1 : 0

  fqdn              = var.name_prefix
  port              = 443
  type              = "HTTPS"
  resource_path     = "/health"
  failure_threshold = "3"
  request_interval  = "30"

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-primary-health-check"
  })
}

#------------------------------------------------------------------------------
# CloudWatch Alarm for DR Trigger
#------------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "dr_trigger" {
  count = var.dr.enabled && var.dr.failover_mode == "automatic" ? 1 : 0

  alarm_name          = "${var.name_prefix}-dr-trigger"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 3
  metric_name         = "HealthCheckStatus"
  namespace           = "AWS/Route53"
  period              = 60
  statistic           = "Minimum"
  threshold           = 1
  alarm_description   = "Trigger DR failover when primary health check fails"

  dimensions = {
    HealthCheckId = aws_route53_health_check.primary[0].id
  }

  alarm_actions = [aws_sns_topic.dr_alerts.arn]

  tags = var.common_tags
}

#------------------------------------------------------------------------------
# DR Runbook Document
#------------------------------------------------------------------------------
resource "aws_ssm_document" "dr_runbook" {
  count = var.dr.enabled ? 1 : 0

  name            = "${var.name_prefix}-dr-runbook"
  document_type   = "Automation"
  document_format = "YAML"

  content = yamlencode({
    schemaVersion = "0.3"
    description   = "DR Failover Runbook for ${var.name_prefix}"
    mainSteps = [
      {
        name   = "VerifyPrimaryDown"
        action = "aws:waitForAwsResourceProperty"
        inputs = {
          Service      = "route53"
          Api          = "GetHealthCheckStatus"
          HealthCheckId = aws_route53_health_check.primary[0].id
          PropertySelector = "$.HealthCheckObservations[0].StatusReport.Status"
          DesiredValues = ["Unhealthy"]
        }
      },
      {
        name   = "NotifyStart"
        action = "aws:executeAwsApi"
        inputs = {
          Service  = "sns"
          Api      = "Publish"
          TopicArn = aws_sns_topic.dr_alerts.arn
          Message  = "DR failover initiated for ${var.name_prefix}"
        }
      }
    ]
  })

  tags = var.common_tags
}
