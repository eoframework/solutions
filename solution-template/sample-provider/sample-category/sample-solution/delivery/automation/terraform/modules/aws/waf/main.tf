# Generic AWS WAF Module
# Creates WAFv2 Web ACL with managed rules

terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

#------------------------------------------------------------------------------
# IP Set (for blocking/allowing specific IPs)
#------------------------------------------------------------------------------

resource "aws_wafv2_ip_set" "blocked" {
  count = length(var.blocked_ip_addresses) > 0 ? 1 : 0

  name               = "${var.name_prefix}-blocked-ips"
  scope              = var.scope
  ip_address_version = "IPV4"
  addresses          = var.blocked_ip_addresses

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-blocked-ips"
  })
}

resource "aws_wafv2_ip_set" "allowed" {
  count = length(var.allowed_ip_addresses) > 0 ? 1 : 0

  name               = "${var.name_prefix}-allowed-ips"
  scope              = var.scope
  ip_address_version = "IPV4"
  addresses          = var.allowed_ip_addresses

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-allowed-ips"
  })
}

#------------------------------------------------------------------------------
# Web ACL
#------------------------------------------------------------------------------

resource "aws_wafv2_web_acl" "this" {
  name        = "${var.name_prefix}-waf"
  scope       = var.scope
  description = "WAF for ${var.name_prefix}"

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

  visibility_config {
    cloudwatch_metrics_enabled = var.cloudwatch_metrics_enabled
    metric_name                = "${replace(var.name_prefix, "-", "")}WAF"
    sampled_requests_enabled   = var.sampled_requests_enabled
  }

  # AWS Managed Rules - Common Rule Set
  dynamic "rule" {
    for_each = var.enable_aws_managed_common_rules ? [1] : []
    content {
      name     = "AWSManagedRulesCommonRuleSet"
      priority = 10

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
        cloudwatch_metrics_enabled = var.cloudwatch_metrics_enabled
        metric_name                = "AWSManagedRulesCommonRuleSet"
        sampled_requests_enabled   = var.sampled_requests_enabled
      }
    }
  }

  # AWS Managed Rules - SQL Injection
  dynamic "rule" {
    for_each = var.enable_aws_managed_sqli_rules ? [1] : []
    content {
      name     = "AWSManagedRulesSQLiRuleSet"
      priority = 20

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
        cloudwatch_metrics_enabled = var.cloudwatch_metrics_enabled
        metric_name                = "AWSManagedRulesSQLiRuleSet"
        sampled_requests_enabled   = var.sampled_requests_enabled
      }
    }
  }

  # AWS Managed Rules - Known Bad Inputs
  dynamic "rule" {
    for_each = var.enable_aws_managed_bad_inputs_rules ? [1] : []
    content {
      name     = "AWSManagedRulesKnownBadInputsRuleSet"
      priority = 30

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
        cloudwatch_metrics_enabled = var.cloudwatch_metrics_enabled
        metric_name                = "AWSManagedRulesKnownBadInputsRuleSet"
        sampled_requests_enabled   = var.sampled_requests_enabled
      }
    }
  }

  # Rate Limiting Rule
  dynamic "rule" {
    for_each = var.rate_limit > 0 ? [1] : []
    content {
      name     = "RateLimitRule"
      priority = 1

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
        cloudwatch_metrics_enabled = var.cloudwatch_metrics_enabled
        metric_name                = "RateLimitRule"
        sampled_requests_enabled   = var.sampled_requests_enabled
      }
    }
  }

  # Block IP Set Rule
  dynamic "rule" {
    for_each = length(var.blocked_ip_addresses) > 0 ? [1] : []
    content {
      name     = "BlockedIPSet"
      priority = 2

      action {
        block {}
      }

      statement {
        ip_set_reference_statement {
          arn = aws_wafv2_ip_set.blocked[0].arn
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = var.cloudwatch_metrics_enabled
        metric_name                = "BlockedIPSet"
        sampled_requests_enabled   = var.sampled_requests_enabled
      }
    }
  }

  # Geo Blocking Rule
  dynamic "rule" {
    for_each = length(var.blocked_countries) > 0 ? [1] : []
    content {
      name     = "GeoBlockRule"
      priority = 3

      action {
        block {}
      }

      statement {
        geo_match_statement {
          country_codes = var.blocked_countries
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = var.cloudwatch_metrics_enabled
        metric_name                = "GeoBlockRule"
        sampled_requests_enabled   = var.sampled_requests_enabled
      }
    }
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-waf"
  })
}

# NOTE: Web ACL Association removed from this module to avoid circular dependencies
# Association should be done in environment main.tf INTEGRATIONS section using:
#   resource "aws_wafv2_web_acl_association" "alb" {
#     resource_arn = module.core.alb_arn
#     web_acl_arn  = module.security.waf_web_acl_arn
#   }

#------------------------------------------------------------------------------
# WAF Logging (optional)
#------------------------------------------------------------------------------

resource "aws_wafv2_web_acl_logging_configuration" "this" {
  count = var.logging_enabled && var.log_destination_arn != "" ? 1 : 0

  resource_arn            = aws_wafv2_web_acl.this.arn
  log_destination_configs = [var.log_destination_arn]

  dynamic "redacted_fields" {
    for_each = var.redacted_fields
    content {
      dynamic "single_header" {
        for_each = redacted_fields.value.type == "header" ? [1] : []
        content {
          name = lower(redacted_fields.value.name)
        }
      }
      dynamic "query_string" {
        for_each = redacted_fields.value.type == "query_string" ? [1] : []
        content {}
      }
      dynamic "uri_path" {
        for_each = redacted_fields.value.type == "uri_path" ? [1] : []
        content {}
      }
    }
  }
}
