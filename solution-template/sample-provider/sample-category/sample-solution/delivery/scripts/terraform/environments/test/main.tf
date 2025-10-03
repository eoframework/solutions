# Test Environment - Infrastructure Deployment
# Clean infrastructure configuration focused on resource deployment

# Local values for common resource naming and tagging
locals {
  # Resource naming convention: {project}-{environment}-{resource}
  name_prefix = "${var.project_name}-test"

  # Common tags applied to all resources
  common_tags = merge(
    {
      Project     = var.project_name
      Environment = "test"
      ManagedBy   = "Terraform"
    },
    var.additional_tags,
    {
      Purpose      = "Testing"
      AutoShutdown = "Enabled"
      MaxRuntime   = var.max_runtime_hours
      CostOptimized = "true"
    }
  )
}

# AWS Resources (when enabled)
module "aws_infrastructure" {
  count  = var.enable_aws_resources ? 1 : 0
  source = "../../modules/aws"

  # Core configuration
  project_name = var.project_name
  environment  = "test"
  name_prefix  = local.name_prefix
  region       = var.aws_region

  # Common tags
  tags = local.common_tags
}

# Azure Resources (when enabled)
module "azure_infrastructure" {
  count  = var.enable_azure_resources ? 1 : 0
  source = "../../modules/azure"

  # Core configuration
  project_name    = var.project_name
  environment     = "test"
  name_prefix     = local.name_prefix
  location        = var.azure_location
  subscription_id = var.azure_subscription_id

  # Common tags
  tags = local.common_tags
}

# Google Cloud Resources (when enabled)
module "gcp_infrastructure" {
  count  = var.enable_gcp_resources ? 1 : 0
  source = "../../modules/gcp"

  # Core configuration
  project_name = var.project_name
  environment  = "test"
  name_prefix  = local.name_prefix
  project_id   = var.gcp_project_id
  region       = var.gcp_region

  # Common tags as labels (GCP naming convention)
  labels = {
    for k, v in local.common_tags :
    lower(replace(k, " ", "_")) => lower(replace(v, " ", "_"))
  }
}

# Note: Monitoring is now handled within each provider module
# AWS monitoring: module.aws_infrastructure[0].monitoring
# Azure monitoring: module.azure_infrastructure[0].monitoring
# GCP monitoring: module.gcp_infrastructure[0].monitoring