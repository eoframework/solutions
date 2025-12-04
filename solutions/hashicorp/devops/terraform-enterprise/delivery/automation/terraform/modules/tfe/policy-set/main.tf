#------------------------------------------------------------------------------
# Terraform Enterprise Policy Set Module
#------------------------------------------------------------------------------
# Manages Sentinel policy sets for governance
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Policy Sets by Domain
#------------------------------------------------------------------------------
locals {
  policy_sets = {
    security = {
      name        = "security-policies"
      description = "Security-focused Sentinel policies"
      global      = true
      policies = [
        "require-encryption",
        "restrict-public-access",
        "enforce-iam-policies",
        "validate-security-groups"
      ]
    }
    cost = {
      name        = "cost-policies"
      description = "Cost governance Sentinel policies"
      global      = true
      policies = [
        "restrict-instance-types",
        "require-cost-tags",
        "limit-resource-count"
      ]
    }
    compliance = {
      name        = "compliance-policies"
      description = "Compliance framework Sentinel policies"
      global      = true
      policies = [
        "require-logging",
        "enforce-tagging",
        "validate-resource-naming"
      ]
    }
  }
}

#------------------------------------------------------------------------------
# Policy Sets
#------------------------------------------------------------------------------
resource "tfe_policy_set" "policy_set" {
  for_each = var.sentinel.enabled ? local.policy_sets : {}

  name         = "${var.name_prefix}-${each.value.name}"
  description  = each.value.description
  organization = var.organization
  global       = each.value.global
  kind         = "sentinel"

  # VCS-backed policy set
  dynamic "vcs_repo" {
    for_each = var.integration.github_vcs_enabled ? [1] : []
    content {
      identifier         = "${var.integration.github_org}/sentinel-policies"
      branch             = "main"
      ingress_submodules = false
      oauth_token_id     = data.tfe_oauth_client.github[0].oauth_token_id
    }
  }
}

#------------------------------------------------------------------------------
# Data Source for OAuth Client
#------------------------------------------------------------------------------
data "tfe_oauth_client" "github" {
  count = var.integration.github_vcs_enabled ? 1 : 0

  organization     = var.organization
  service_provider = "github"
}

#------------------------------------------------------------------------------
# Sentinel Parameters (shared across policies)
#------------------------------------------------------------------------------
resource "tfe_policy_set_parameter" "enforcement_level" {
  for_each = var.sentinel.enabled ? local.policy_sets : {}

  key          = "enforcement_level"
  value        = var.sentinel.enforcement_level
  policy_set_id = tfe_policy_set.policy_set[each.key].id
}
