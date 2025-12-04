# GitHub Security Module
# Configures security features (Advanced Security, CodeQL, Dependabot)

terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
  }
}

#===============================================================================
# Repository Security and Analysis
#===============================================================================
resource "github_repository_security_and_analysis" "repo" {
  count = var.enable_advanced_security ? 1 : 0

  repository = var.repository_name

  security_and_analysis {
    advanced_security {
      status = "enabled"
    }

    secret_scanning {
      status = var.enable_secret_scanning ? "enabled" : "disabled"
    }

    secret_scanning_push_protection {
      status = var.enable_secret_scanning_push_protection ? "enabled" : "disabled"
    }
  }
}

#===============================================================================
# OIDC Subject Claim Customization
#===============================================================================
resource "github_actions_repository_oidc_subject_claim_customization_template" "repo" {
  count = var.enable_oidc_customization ? 1 : 0

  repository = var.repository_name
  use_default = false
  include_claim_keys = var.oidc_claim_keys
}

#===============================================================================
# Repository Webhook for Security Events
#===============================================================================
resource "github_repository_webhook" "security" {
  count = var.enable_security_webhook ? 1 : 0

  repository = var.repository_name
  active     = true

  configuration {
    url          = var.webhook_url
    content_type = "json"
    insecure_ssl = false
    secret       = var.webhook_secret
  }

  events = var.webhook_events
}
