#------------------------------------------------------------------------------
# Best Practices Module
# Creates: Backup, Budget Alerts, Azure Policies
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Recovery Services Vault (for VM Backup)
#------------------------------------------------------------------------------
resource "azurerm_recovery_services_vault" "main" {
  count               = var.backup.enabled ? 1 : 0
  name                = "${var.name_prefix}-rsv"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  soft_delete_enabled = true

  tags = var.common_tags
}

resource "azurerm_backup_policy_vm" "main" {
  count               = var.backup.enabled ? 1 : 0
  name                = "${var.name_prefix}-backup-policy"
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.main[0].name

  backup {
    frequency = "Daily"
    time      = "23:00"
  }

  retention_daily {
    count = var.backup.retention_days
  }
}

#------------------------------------------------------------------------------
# Budget Alert
#------------------------------------------------------------------------------
resource "azurerm_consumption_budget_resource_group" "main" {
  count             = var.budget.enabled ? 1 : 0
  name              = "${var.name_prefix}-budget"
  resource_group_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.resource_group_name}"

  amount     = var.budget.monthly_amount
  time_grain = "Monthly"

  time_period {
    start_date = formatdate("YYYY-MM-01'T'00:00:00'Z'", timestamp())
  }

  notification {
    enabled   = true
    threshold = var.budget.alert_thresholds[0]
    operator  = "GreaterThan"

    contact_emails = [
      var.budget.notification_email,
    ]
  }

  dynamic "notification" {
    for_each = length(var.budget.alert_thresholds) > 1 ? [var.budget.alert_thresholds[1]] : []
    content {
      enabled   = true
      threshold = notification.value
      operator  = "GreaterThan"

      contact_emails = [
        var.budget.notification_email,
      ]
    }
  }

  dynamic "notification" {
    for_each = length(var.budget.alert_thresholds) > 2 ? [var.budget.alert_thresholds[2]] : []
    content {
      enabled   = true
      threshold = notification.value
      operator  = "GreaterThan"

      contact_emails = [
        var.budget.notification_email,
      ]

      contact_groups = var.action_group_id != null ? [var.action_group_id] : []
    }
  }
}

#------------------------------------------------------------------------------
# Data Source
#------------------------------------------------------------------------------
data "azurerm_client_config" "current" {}
