#------------------------------------------------------------------------------
# GitHub Security Configuration Module
#------------------------------------------------------------------------------
# Manages security-specific configurations including:
# - Secret scanning custom patterns
# - Security advisories
# - Security policies
#------------------------------------------------------------------------------

terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

#------------------------------------------------------------------------------
# Organization Secret Scanning Custom Patterns
#------------------------------------------------------------------------------
resource "github_organization_custom_properties" "security_properties" {
  for_each = var.custom_properties

  property_name = each.value.property_name
  value_type    = each.value.value_type
  description   = each.value.description
  required      = each.value.required
  default_value = each.value.default_value

  dynamic "allowed_values" {
    for_each = each.value.allowed_values != null ? [1] : []
    content {
      values = each.value.allowed_values
    }
  }
}

#------------------------------------------------------------------------------
# Repository Custom Properties Assignment
#------------------------------------------------------------------------------
resource "github_repository_custom_property" "repo_properties" {
  for_each = var.repository_properties

  repository    = each.value.repository
  property_name = each.value.property_name
  value         = each.value.value
}

#------------------------------------------------------------------------------
# Organization IP Allow List (Enterprise Cloud only)
#------------------------------------------------------------------------------
resource "github_organization_ip_allowlist" "allowed_ips" {
  for_each = var.ip_allowlist

  name    = each.value.name
  cidr    = each.value.cidr
  enabled = each.value.enabled
}
