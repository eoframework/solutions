#------------------------------------------------------------------------------
# Azure DevOps Configuration - Test Environment
#------------------------------------------------------------------------------

devops = {
  organization_url          = "https://dev.azure.com/[ORGANIZATION_NAME]"
  organization_name         = "[ORGANIZATION_NAME]"
  project_name              = "EnterpriseDevOps-Test"
  project_description       = "Enterprise DevOps Platform - Test"
  version_control           = "Git"
  work_item_template        = "Agile"
  enable_repos              = true
  enable_pipelines          = true
  enable_artifacts          = true
  enable_test_plans         = true
}

service_connections = {
  azure_rm_enabled          = true
  service_principal_id      = "[SERVICE_PRINCIPAL_ID]"
  service_principal_key     = "[SERVICE_PRINCIPAL_KEY]"
}

pipelines = {
  enable_ci                 = true
  enable_cd                 = true
  build_agents_pool         = "Azure Pipelines"
  enable_pull_request_build = true
}
