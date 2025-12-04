#------------------------------------------------------------------------------
# GCP Cloud Armor Module
#------------------------------------------------------------------------------
# Creates Cloud Armor WAF security policies
# Well-Architected Framework: Security
#------------------------------------------------------------------------------

resource "google_compute_security_policy" "default" {
  count = var.cloud_armor.enabled ? 1 : 0

  name    = "${var.name_prefix}-security-policy"
  project = var.project_id

  # Default rule - allow all traffic
  rule {
    action   = "allow"
    priority = "2147483647"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "Default rule - allow all"
  }

  # OWASP Top 10 Protection Rules
  dynamic "rule" {
    for_each = var.cloud_armor.enable_owasp_rules ? ["xss", "sqli", "lfi", "rce", "rfi", "scanner"] : []
    content {
      action   = "deny(403)"
      priority = 1000 + index(["xss", "sqli", "lfi", "rce", "rfi", "scanner"], rule.value)
      match {
        expr {
          expression = "evaluatePreconfiguredExpr('${rule.value}-stable')"
        }
      }
      description = "Block ${upper(rule.value)} attacks"
    }
  }

  # Rate limiting
  dynamic "rule" {
    for_each = var.cloud_armor.enable_rate_limiting ? [1] : []
    content {
      action   = "rate_based_ban"
      priority = "900"
      match {
        versioned_expr = "SRC_IPS_V1"
        config {
          src_ip_ranges = ["*"]
        }
      }
      rate_limit_options {
        conform_action = "allow"
        exceed_action  = "deny(429)"
        rate_limit_threshold {
          count        = var.cloud_armor.rate_limit_requests_per_minute
          interval_sec = 60
        }
        ban_duration_sec = var.cloud_armor.rate_limit_ban_duration_sec
      }
      description = "Rate limit - ${var.cloud_armor.rate_limit_requests_per_minute} requests per minute"
    }
  }

  # Geo-blocking (optional)
  dynamic "rule" {
    for_each = length(var.cloud_armor.blocked_countries) > 0 ? [1] : []
    content {
      action   = "deny(403)"
      priority = "800"
      match {
        expr {
          expression = "origin.region_code in [${join(",", formatlist("'%s'", var.cloud_armor.blocked_countries))}]"
        }
      }
      description = "Block traffic from restricted countries"
    }
  }
}
