#------------------------------------------------------------------------------
# Sentinel Policy Set Module
#------------------------------------------------------------------------------
# Creates Sentinel policy sets for governance and compliance
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Policy Set
#------------------------------------------------------------------------------
resource "tfe_policy_set" "main" {
  name         = "${var.name_prefix}-policies"
  description  = "Sentinel policies for ${var.name_prefix}"
  organization = var.organization
  kind         = "sentinel"
  global       = var.sentinel.global_policies

  # VCS-driven policies
  dynamic "vcs_repo" {
    for_each = var.sentinel.vcs_repo != "" ? [1] : []
    content {
      identifier         = var.sentinel.vcs_repo
      branch             = var.sentinel.vcs_branch
      ingress_submodules = false
      oauth_token_id     = var.sentinel.oauth_token_id
    }
  }

  policy_tool_version = var.sentinel.policy_tool_version
}

#------------------------------------------------------------------------------
# Individual Policies (for non-VCS mode)
#------------------------------------------------------------------------------
resource "tfe_policy" "cost_estimation" {
  count = var.sentinel.enable_cost_policies ? 1 : 0

  name         = "cost-estimation-limits"
  description  = "Enforce cost estimation limits"
  organization = var.organization
  kind         = "sentinel"
  enforce_mode = var.sentinel.cost_policy_enforcement

  policy = <<-EOT
import "tfrun"
import "decimal"

# Maximum allowed monthly cost increase
max_monthly_cost_increase = decimal.new(${var.sentinel.max_monthly_cost_increase})

# Get the cost estimate
cost_estimate = tfrun.cost_estimate

main = rule {
  cost_estimate.delta_monthly_cost.lte(max_monthly_cost_increase)
}
EOT
}

resource "tfe_policy" "mandatory_tags" {
  count = var.sentinel.enable_tag_policies ? 1 : 0

  name         = "mandatory-tags"
  description  = "Enforce mandatory tags on all resources"
  organization = var.organization
  kind         = "sentinel"
  enforce_mode = var.sentinel.tag_policy_enforcement

  policy = <<-EOT
import "tfplan/v2" as tfplan

# Required tags
required_tags = ${jsonencode(var.sentinel.required_tags)}

# Get all resources
all_resources = filter tfplan.resource_changes as _, rc {
  rc.mode is "managed" and
  (rc.change.actions contains "create" or rc.change.actions contains "update")
}

# Check for tags attribute
has_required_tags = rule {
  all all_resources as _, resource {
    all required_tags as tag {
      resource.change.after.tags else {} contains tag
    }
  }
}

main = rule {
  has_required_tags
}
EOT
}

resource "tfe_policy" "allowed_providers" {
  count = var.sentinel.enable_provider_policies ? 1 : 0

  name         = "allowed-providers"
  description  = "Restrict to allowed providers"
  organization = var.organization
  kind         = "sentinel"
  enforce_mode = var.sentinel.provider_policy_enforcement

  policy = <<-EOT
import "tfconfig/v2" as tfconfig

# Allowed providers
allowed_providers = ${jsonencode(var.sentinel.allowed_providers)}

# Get all providers
providers = filter tfconfig.providers as _, p {
  true
}

# Check providers are in allowed list
providers_allowed = rule {
  all providers as _, provider {
    provider.name in allowed_providers
  }
}

main = rule {
  providers_allowed
}
EOT
}

#------------------------------------------------------------------------------
# Policy Set Parameters
#------------------------------------------------------------------------------
resource "tfe_policy_set_parameter" "common" {
  for_each = var.sentinel.parameters

  key          = each.key
  value        = each.value.value
  sensitive    = each.value.sensitive
  policy_set_id = tfe_policy_set.main.id
}
