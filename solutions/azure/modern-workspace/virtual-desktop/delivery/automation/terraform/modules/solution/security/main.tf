#------------------------------------------------------------------------------
# Security Module
# Creates: Managed Identity, RBAC Assignments
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# User-Assigned Managed Identity
#------------------------------------------------------------------------------
resource "azurerm_user_assigned_identity" "main" {
  name                = "${var.name_prefix}-identity"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.common_tags
}

#------------------------------------------------------------------------------
# RBAC Assignments for Managed Identity
#------------------------------------------------------------------------------
resource "azurerm_role_assignment" "key_vault_secrets_user" {
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.main.principal_id
}

#------------------------------------------------------------------------------
# Customer Managed Key (if enabled)
#------------------------------------------------------------------------------
resource "azurerm_key_vault_key" "encryption" {
  count        = var.security.enable_customer_managed_key ? 1 : 0
  name         = "${var.name_prefix}-encryption-key"
  key_vault_id = var.key_vault_id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]

  depends_on = [azurerm_role_assignment.key_vault_secrets_user]
}
