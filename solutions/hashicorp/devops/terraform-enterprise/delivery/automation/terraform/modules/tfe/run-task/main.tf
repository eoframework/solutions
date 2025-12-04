#------------------------------------------------------------------------------
# Terraform Enterprise Run Task Module
#------------------------------------------------------------------------------
# Manages TFE run tasks for external integrations
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Run Tasks
#------------------------------------------------------------------------------
locals {
  run_tasks = {
    slack = {
      enabled     = var.integration.slack_enabled
      name        = "slack-notification"
      description = "Notify Slack channel on run events"
      url         = "https://hooks.slack.com/services/placeholder"
      enabled     = true
      category    = "task"
    }
    servicenow = {
      enabled     = var.integration.servicenow_enabled
      name        = "servicenow-cmdb"
      description = "Update ServiceNow CMDB on infrastructure changes"
      url         = "https://instance.service-now.com/api/placeholder"
      enabled     = true
      category    = "task"
    }
  }
}

resource "tfe_organization_run_task" "task" {
  for_each = { for k, v in local.run_tasks : k => v if v.enabled }

  organization = var.organization
  url          = each.value.url
  name         = "${var.name_prefix}-${each.value.name}"
  description  = each.value.description
  enabled      = each.value.enabled
  category     = each.value.category
}
