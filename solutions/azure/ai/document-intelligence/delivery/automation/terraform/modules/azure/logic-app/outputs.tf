#------------------------------------------------------------------------------
# Azure Logic App Module - Outputs
#------------------------------------------------------------------------------

output "id" {
  description = "Logic App ID"
  value       = azurerm_logic_app_workflow.this.id
}

output "name" {
  description = "Logic App name"
  value       = azurerm_logic_app_workflow.this.name
}

output "access_endpoint" {
  description = "Logic App access endpoint"
  value       = azurerm_logic_app_workflow.this.access_endpoint
}

output "connector_endpoint_ip_addresses" {
  description = "Connector endpoint IP addresses"
  value       = azurerm_logic_app_workflow.this.connector_endpoint_ip_addresses
}

output "connector_outbound_ip_addresses" {
  description = "Connector outbound IP addresses"
  value       = azurerm_logic_app_workflow.this.connector_outbound_ip_addresses
}

output "workflow_endpoint_ip_addresses" {
  description = "Workflow endpoint IP addresses"
  value       = azurerm_logic_app_workflow.this.workflow_endpoint_ip_addresses
}

output "workflow_outbound_ip_addresses" {
  description = "Workflow outbound IP addresses"
  value       = azurerm_logic_app_workflow.this.workflow_outbound_ip_addresses
}

output "identity" {
  description = "Identity block"
  value       = azurerm_logic_app_workflow.this.identity
}

output "principal_id" {
  description = "System-assigned identity principal ID"
  value       = try(azurerm_logic_app_workflow.this.identity[0].principal_id, null)
}
