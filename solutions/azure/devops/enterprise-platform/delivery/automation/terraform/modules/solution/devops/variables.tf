#------------------------------------------------------------------------------
# Azure DevOps Module - Variables
#------------------------------------------------------------------------------

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
}

variable "devops" {
  description = "Azure DevOps configuration"
  type = object({
    organization_url          = string
    organization_name         = string
    project_name              = string
    project_description       = string
    version_control           = string
    work_item_template        = string
    enable_repos              = bool
    enable_pipelines          = bool
    enable_artifacts          = bool
    enable_test_plans         = bool
  })
}

variable "pipelines" {
  description = "Pipeline configuration"
  type = object({
    enable_ci                 = bool
    enable_cd                 = bool
    build_agents_pool         = string
    enable_pull_request_build = bool
  })
}

variable "service_connections" {
  description = "Service connection configuration"
  type = object({
    azure_rm_enabled          = bool
    service_principal_id      = string
    service_principal_key     = string
  })
}

variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "tenant_id" {
  description = "Azure AD tenant ID"
  type        = string
}

variable "key_vault_id" {
  description = "Key Vault ID for storing secrets"
  type        = string
}
