#------------------------------------------------------------------------------
# AWS WAF Module (Provider-Level Primitive)
#------------------------------------------------------------------------------
# Reusable WAF Web ACL with managed rules
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# WAF Web ACL
#------------------------------------------------------------------------------
resource "aws_wafv2_web_acl" "main" {
  name        = "${var.name_prefix}-waf"
  description = var.description
  scope       = var.scope

  default_action {
    dynamic "allow" {
      for_each = var.default_action == "allow" ? [1] : []
      content {}
    }
    dynamic "block" {
      for_each = var.default_action == "block" ? [1] : []
      content {}
    }
  }

  # AWS Managed Rules - Common Rule Set
  dynamic "rule" {
    for_each = var.enable_common_rules ? [1] : []
    content {
      name     = "AWSManagedRulesCommonRuleSet"
      priority = 1

      override_action {
        none {}
      }

      statement {
        managed_rule_group_statement {
          name        = "AWSManagedRulesCommonRuleSet"
          vendor_name = "AWS"
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = var.enable_cloudwatch_metrics
        metric_name                = "${var.name_prefix}-common-rules"
        sampled_requests_enabled   = var.enable_sampled_requests
      }
    }
  }

  # Rate-based rule
  dynamic "rule" {
    for_each = var.enable_rate_limiting ? [1] : []
    content {
      name     = "RateLimitRule"
      priority = 2

      action {
        block {}
      }

      statement {
        rate_based_statement {
          limit              = var.rate_limit
          aggregate_key_type = "IP"
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = var.enable_cloudwatch_metrics
        metric_name                = "${var.name_prefix}-rate-limit"
        sampled_requests_enabled   = var.enable_sampled_requests
      }
    }
  }

  # AWS Managed Rules - Known Bad Inputs
  dynamic "rule" {
    for_each = var.enable_bad_inputs_rules ? [1] : []
    content {
      name     = "AWSManagedRulesKnownBadInputsRuleSet"
      priority = 3

      override_action {
        none {}
      }

      statement {
        managed_rule_group_statement {
          name        = "AWSManagedRulesKnownBadInputsRuleSet"
          vendor_name = "AWS"
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = var.enable_cloudwatch_metrics
        metric_name                = "${var.name_prefix}-bad-inputs"
        sampled_requests_enabled   = var.enable_sampled_requests
      }
    }
  }

  # AWS Managed Rules - SQL Injection
  dynamic "rule" {
    for_each = var.enable_sqli_rules ? [1] : []
    content {
      name     = "AWSManagedRulesSQLiRuleSet"
      priority = 4

      override_action {
        none {}
      }

      statement {
        managed_rule_group_statement {
          name        = "AWSManagedRulesSQLiRuleSet"
          vendor_name = "AWS"
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = var.enable_cloudwatch_metrics
        metric_name                = "${var.name_prefix}-sqli"
        sampled_requests_enabled   = var.enable_sampled_requests
      }
    }
  }

  # IP Block List
  dynamic "rule" {
    for_each = length(var.blocked_ip_addresses) > 0 ? [1] : []
    content {
      name     = "IPBlockList"
      priority = 5

      action {
        block {}
      }

      statement {
        ip_set_reference_statement {
          arn = aws_wafv2_ip_set.blocked[0].arn
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = var.enable_cloudwatch_metrics
        metric_name                = "${var.name_prefix}-ip-block"
        sampled_requests_enabled   = var.enable_sampled_requests
      }
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = var.enable_cloudwatch_metrics
    metric_name                = "${var.name_prefix}-waf"
    sampled_requests_enabled   = var.enable_sampled_requests
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-waf"
  })
}

#------------------------------------------------------------------------------
# IP Set for Block List
#------------------------------------------------------------------------------
resource "aws_wafv2_ip_set" "blocked" {
  count = length(var.blocked_ip_addresses) > 0 ? 1 : 0

  name               = "${var.name_prefix}-blocked-ips"
  description        = "Blocked IP addresses"
  scope              = var.scope
  ip_address_version = "IPV4"
  addresses          = var.blocked_ip_addresses

  tags = var.common_tags
}

#------------------------------------------------------------------------------
# WAF Logging
#------------------------------------------------------------------------------
resource "aws_wafv2_web_acl_logging_configuration" "main" {
  count = var.enable_logging ? 1 : 0

  log_destination_configs = var.log_destination_arns
  resource_arn            = aws_wafv2_web_acl.main.arn

  dynamic "redacted_fields" {
    for_each = var.redacted_fields
    content {
      dynamic "single_header" {
        for_each = redacted_fields.value.type == "single_header" ? [1] : []
        content {
          name = redacted_fields.value.name
        }
      }
    }
  }
}
