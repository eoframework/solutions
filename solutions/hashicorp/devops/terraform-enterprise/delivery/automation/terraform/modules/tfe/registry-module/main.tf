#------------------------------------------------------------------------------
# Terraform Enterprise Registry Module
#------------------------------------------------------------------------------
# Manages private module registry
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Registry Modules from VCS
#------------------------------------------------------------------------------
resource "tfe_registry_module" "module" {
  for_each = var.registry_modules

  organization = var.organization

  vcs_repo {
    identifier         = each.value.vcs_repo
    oauth_token_id     = var.oauth_token_id
    display_identifier = each.value.display_name
  }

  test_config {
    tests_enabled = each.value.tests_enabled
  }
}

#------------------------------------------------------------------------------
# No-Code Modules (if enabled)
#------------------------------------------------------------------------------
resource "tfe_no_code_module" "nocode" {
  for_each = { for k, v in var.registry_modules : k => v if v.no_code_enabled }

  organization    = var.organization
  registry_module = tfe_registry_module.module[each.key].id
  enabled         = true
}
