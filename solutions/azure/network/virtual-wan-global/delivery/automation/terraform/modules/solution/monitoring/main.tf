#------------------------------------------------------------------------------
# Virtual WAN Monitoring Module
# Creates: Log Analytics Workspace, Network Watcher, Diagnostic Settings
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Log Analytics Workspace
#------------------------------------------------------------------------------
resource "azurerm_log_analytics_workspace" "main" {
  name                = "${var.name_prefix}-law"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.log_analytics_sku
  retention_in_days   = var.log_retention_days

  tags = var.common_tags
}

#------------------------------------------------------------------------------
# Action Group for Alerts
#------------------------------------------------------------------------------
resource "azurerm_monitor_action_group" "main" {
  count               = var.enable_alerts ? 1 : 0
  name                = "${var.name_prefix}-actiongroup"
  resource_group_name = var.resource_group_name
  short_name          = substr(var.name_prefix, 0, 12)

  email_receiver {
    name          = "ops-team"
    email_address = var.alert_email
  }

  tags = var.common_tags
}

#------------------------------------------------------------------------------
# Virtual WAN Diagnostic Settings
#------------------------------------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "vwan" {
  count                      = var.virtual_wan_id != null ? 1 : 0
  name                       = "${var.name_prefix}-vwan-diag"
  target_resource_id         = var.virtual_wan_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  enabled_log {
    category = "AuditEvent"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

#------------------------------------------------------------------------------
# Primary Hub Diagnostic Settings
#------------------------------------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "primary_hub" {
  count                      = var.primary_hub_id != null ? 1 : 0
  name                       = "${var.name_prefix}-hub-primary-diag"
  target_resource_id         = var.primary_hub_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  enabled_log {
    category = "AuditEvent"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

#------------------------------------------------------------------------------
# Secondary Hub Diagnostic Settings
#------------------------------------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "secondary_hub" {
  count                      = var.secondary_hub_id != null ? 1 : 0
  name                       = "${var.name_prefix}-hub-secondary-diag"
  target_resource_id         = var.secondary_hub_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  enabled_log {
    category = "AuditEvent"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

#------------------------------------------------------------------------------
# Primary Firewall Diagnostic Settings
#------------------------------------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "primary_firewall" {
  count                      = var.primary_firewall_id != null ? 1 : 0
  name                       = "${var.name_prefix}-fw-primary-diag"
  target_resource_id         = var.primary_firewall_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  enabled_log {
    category = "AzureFirewallApplicationRule"
  }

  enabled_log {
    category = "AzureFirewallNetworkRule"
  }

  enabled_log {
    category = "AzureFirewallDnsProxy"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

#------------------------------------------------------------------------------
# Secondary Firewall Diagnostic Settings
#------------------------------------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "secondary_firewall" {
  count                      = var.secondary_firewall_id != null ? 1 : 0
  name                       = "${var.name_prefix}-fw-secondary-diag"
  target_resource_id         = var.secondary_firewall_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  enabled_log {
    category = "AzureFirewallApplicationRule"
  }

  enabled_log {
    category = "AzureFirewallNetworkRule"
  }

  enabled_log {
    category = "AzureFirewallDnsProxy"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

#------------------------------------------------------------------------------
# VPN Gateway Alerts
#------------------------------------------------------------------------------
resource "azurerm_monitor_metric_alert" "vpn_gateway_health" {
  count               = var.enable_alerts && var.primary_vpn_gateway_id != null ? 1 : 0
  name                = "${var.name_prefix}-vpngw-health"
  resource_group_name = var.resource_group_name
  scopes              = [var.primary_vpn_gateway_id]
  description         = "VPN Gateway health status alert"
  severity            = 1

  criteria {
    metric_namespace = "Microsoft.Network/vpnGateways"
    metric_name      = "TunnelAverageBandwidth"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 1
  }

  action {
    action_group_id = azurerm_monitor_action_group.main[0].id
  }

  tags = var.common_tags
}

#------------------------------------------------------------------------------
# Firewall Threat Intelligence Alerts
#------------------------------------------------------------------------------
resource "azurerm_monitor_metric_alert" "firewall_threats" {
  count               = var.enable_alerts && var.primary_firewall_id != null ? 1 : 0
  name                = "${var.name_prefix}-fw-threats"
  resource_group_name = var.resource_group_name
  scopes              = [var.primary_firewall_id]
  description         = "Azure Firewall threat detection alert"
  severity            = 0

  criteria {
    metric_namespace = "Microsoft.Network/azureFirewalls"
    metric_name      = "ThreatIntelHits"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 0
  }

  action {
    action_group_id = azurerm_monitor_action_group.main[0].id
  }

  tags = var.common_tags
}

#------------------------------------------------------------------------------
# Network Watcher
#------------------------------------------------------------------------------
resource "azurerm_network_watcher" "primary" {
  count               = var.enable_network_watcher ? 1 : 0
  name                = "${var.name_prefix}-nw-primary"
  resource_group_name = var.resource_group_name
  location            = var.location

  tags = var.common_tags
}

resource "azurerm_network_watcher" "secondary" {
  count               = var.enable_network_watcher && var.secondary_location != null ? 1 : 0
  name                = "${var.name_prefix}-nw-secondary"
  resource_group_name = var.resource_group_name
  location            = var.secondary_location

  tags = var.common_tags
}
