#------------------------------------------------------------------------------
# Terraform Enterprise Team Module
#------------------------------------------------------------------------------
# Manages TFE teams with RBAC
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Standard Teams
#------------------------------------------------------------------------------
locals {
  teams = {
    admins = {
      name = "administrators"
      organization_access = {
        manage_workspaces        = true
        manage_policies          = true
        manage_modules           = true
        manage_providers         = true
        manage_run_tasks         = true
        manage_vcs_settings      = true
        read_workspaces          = true
        read_projects            = true
        manage_projects          = true
        manage_membership        = true
      }
    }
    operators = {
      name = "operators"
      organization_access = {
        manage_workspaces        = true
        manage_policies          = false
        manage_modules           = false
        manage_providers         = false
        manage_run_tasks         = false
        manage_vcs_settings      = false
        read_workspaces          = true
        read_projects            = true
        manage_projects          = false
        manage_membership        = false
      }
    }
    developers = {
      name = "developers"
      organization_access = {
        manage_workspaces        = false
        manage_policies          = false
        manage_modules           = false
        manage_providers         = false
        manage_run_tasks         = false
        manage_vcs_settings      = false
        read_workspaces          = true
        read_projects            = true
        manage_projects          = false
        manage_membership        = false
      }
    }
    security_reviewers = {
      name = "security-reviewers"
      organization_access = {
        manage_workspaces        = false
        manage_policies          = true
        manage_modules           = false
        manage_providers         = false
        manage_run_tasks         = false
        manage_vcs_settings      = false
        read_workspaces          = true
        read_projects            = true
        manage_projects          = false
        manage_membership        = false
      }
    }
    viewers = {
      name = "viewers"
      organization_access = {
        manage_workspaces        = false
        manage_policies          = false
        manage_modules           = false
        manage_providers         = false
        manage_run_tasks         = false
        manage_vcs_settings      = false
        read_workspaces          = true
        read_projects            = true
        manage_projects          = false
        manage_membership        = false
      }
    }
  }
}

#------------------------------------------------------------------------------
# Teams
#------------------------------------------------------------------------------
resource "tfe_team" "team" {
  for_each = local.teams

  name         = each.value.name
  organization = var.organization

  organization_access {
    manage_workspaces        = each.value.organization_access.manage_workspaces
    manage_policies          = each.value.organization_access.manage_policies
    manage_modules           = each.value.organization_access.manage_modules
    manage_providers         = each.value.organization_access.manage_providers
    manage_run_tasks         = each.value.organization_access.manage_run_tasks
    manage_vcs_settings      = each.value.organization_access.manage_vcs_settings
    read_workspaces          = each.value.organization_access.read_workspaces
    read_projects            = each.value.organization_access.read_projects
    manage_projects          = each.value.organization_access.manage_projects
    manage_membership        = each.value.organization_access.manage_membership
  }
}

#------------------------------------------------------------------------------
# Team Tokens
#------------------------------------------------------------------------------
resource "tfe_team_token" "team" {
  for_each = { for k, v in local.teams : k => v if k != "viewers" }

  team_id = tfe_team.team[each.key].id
}
