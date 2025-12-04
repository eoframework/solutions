#------------------------------------------------------------------------------
# HashiCorp Terraform Enterprise - DR Environment
#------------------------------------------------------------------------------
# Disaster Recovery deployment with standby infrastructure:
# - Terraform Enterprise on AWS EKS in DR region
# - RDS with replication from primary
# - Active-passive failover capability
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Locals
#------------------------------------------------------------------------------
locals {
  environment = basename(path.module)
  name_prefix = "${var.solution.abbr}-${local.environment}"

  # Environment display name mapping
  env_display_name = {
    prod = "Production"
    test = "Test"
    dr   = "Disaster Recovery"
  }

  #----------------------------------------------------------------------------
  # Shared Configuration Objects
  #----------------------------------------------------------------------------
  project = {
    name        = var.solution.abbr
    environment = local.environment
  }

  common_tags = {
    Solution     = var.solution.name
    SolutionAbbr = var.solution.abbr
    Environment  = local.environment
    Provider     = var.solution.provider_name
    Category     = var.solution.category_name
    Region       = var.aws.region
    ManagedBy    = "terraform"
    CostCenter   = var.ownership.cost_center
    Owner        = var.ownership.owner_email
    ProjectCode  = var.ownership.project_code
    Purpose      = "DisasterRecovery"
    Standby      = "true"
  }
}

#------------------------------------------------------------------------------
# Data Sources
#------------------------------------------------------------------------------
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_availability_zones" "available" {
  state = "available"
}

#===============================================================================
# FOUNDATION - Core infrastructure that other modules depend on
#===============================================================================
#------------------------------------------------------------------------------
# Networking (VPC, Subnets, NAT)
#------------------------------------------------------------------------------
module "networking" {
  source = "../../modules/solution/networking"

  name_prefix = local.name_prefix
  common_tags = local.common_tags
  network     = var.network
}

#------------------------------------------------------------------------------
# Security (KMS, IAM, WAF ACL)
#------------------------------------------------------------------------------
module "security" {
  source = "../../modules/solution/security"

  name_prefix = local.name_prefix
  common_tags = local.common_tags
  security    = var.security

  depends_on = [module.networking]
}

#===============================================================================
# CORE PLATFORM - Terraform Enterprise DR infrastructure
#===============================================================================
#------------------------------------------------------------------------------
# EKS Cluster (for Terraform Enterprise DR)
#------------------------------------------------------------------------------
module "eks" {
  source = "../../modules/tfe/eks-cluster"

  name_prefix        = local.name_prefix
  common_tags        = local.common_tags
  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids
  compute            = var.compute
  kms_key_arn        = module.security.kms_key_arn

  depends_on = [module.networking, module.security]
}

#------------------------------------------------------------------------------
# RDS PostgreSQL (Terraform Enterprise state - replicated from primary)
#------------------------------------------------------------------------------
module "database" {
  source = "../../modules/tfe/rds-postgresql"

  name_prefix          = local.name_prefix
  common_tags          = local.common_tags
  vpc_id               = module.networking.vpc_id
  db_subnet_group_name = module.networking.db_subnet_group_name
  security_group_ids   = [module.networking.database_security_group_id]
  kms_key_arn          = module.security.kms_key_arn
  database             = var.database

  depends_on = [module.networking, module.security]
}

#------------------------------------------------------------------------------
# Terraform Enterprise Installation (standby mode)
#------------------------------------------------------------------------------
module "tfe" {
  source = "../../modules/tfe/organization"

  name_prefix          = local.name_prefix
  common_tags          = local.common_tags
  eks_cluster_name     = module.eks.cluster_name
  eks_cluster_endpoint = module.eks.cluster_endpoint
  rds_endpoint         = module.database.rds_endpoint
  rds_database_name    = var.database.rds_database_name
  kms_key_arn          = module.security.kms_key_arn
  tfe                  = var.tfe
  vault_enabled        = var.vault.enabled
  vault_endpoint       = var.vault.enabled ? var.vault_endpoint : ""

  depends_on = [module.eks, module.database]
}

#------------------------------------------------------------------------------
# Terraform Enterprise Workspaces
#------------------------------------------------------------------------------
module "workspaces" {
  source = "../../modules/tfe/workspace"

  organization = module.tfe.organization_name
  tfe          = var.tfe
  integration  = var.integration
  environment  = local.environment

  depends_on = [module.tfe]
}

#------------------------------------------------------------------------------
# Terraform Enterprise Teams
#------------------------------------------------------------------------------
module "teams" {
  source = "../../modules/tfe/team"

  organization = module.tfe.organization_name
  tfe          = var.tfe
  security     = var.security

  depends_on = [module.tfe]
}

#===============================================================================
# GOVERNANCE - Sentinel policies
#===============================================================================
#------------------------------------------------------------------------------
# Sentinel Policy Sets
#------------------------------------------------------------------------------
module "sentinel" {
  source = "../../modules/tfe/policy-set"
  count  = var.sentinel.enabled ? 1 : 0

  name_prefix  = local.name_prefix
  organization = module.tfe.organization_name
  sentinel     = var.sentinel
  integration  = var.integration

  depends_on = [module.tfe]
}

#===============================================================================
# OPERATIONS - Monitoring and DR
#===============================================================================
#------------------------------------------------------------------------------
# Monitoring (CloudWatch, Dashboards)
#------------------------------------------------------------------------------
module "monitoring" {
  source = "../../modules/solution/monitoring"

  name_prefix      = local.name_prefix
  common_tags      = local.common_tags
  project_name     = var.solution.name
  environment      = local.environment
  kms_key_arn      = module.security.kms_key_arn
  eks_cluster_name = module.eks.cluster_name
  rds_identifier   = module.database.rds_identifier
  monitoring       = var.monitoring

  depends_on = [module.eks, module.database]
}

#------------------------------------------------------------------------------
# Backup Configuration
#------------------------------------------------------------------------------
module "backup" {
  source = "../../modules/solution/backup"
  count  = var.backup.enabled ? 1 : 0

  name_prefix   = local.name_prefix
  common_tags   = local.common_tags
  kms_key_arn   = module.security.kms_key_arn
  rds_arn       = module.database.rds_arn
  backup        = var.backup

  depends_on = [module.security, module.database]
}

#------------------------------------------------------------------------------
# DR Management
#------------------------------------------------------------------------------
module "dr" {
  source = "../../modules/solution/dr"
  count  = var.dr.enabled ? 1 : 0

  name_prefix   = local.name_prefix
  environment   = local.environment
  common_tags   = local.common_tags
  kms_key_arn   = module.security.kms_key_arn
  dr_region     = var.aws.dr_region
  dr            = var.dr

  depends_on = [module.security, module.database]
}

#===============================================================================
# INTEGRATIONS - Cross-module connections (via integrations module)
#===============================================================================
module "integrations" {
  source = "../../modules/solution/integrations"

  name_prefix = local.name_prefix
  common_tags = local.common_tags

  # WAF to ALB association
  enable_waf      = var.security.enable_waf
  waf_web_acl_arn = module.security.waf_web_acl_arn
  alb_arn         = module.eks.alb_arn

  # CloudWatch alarms
  enable_alarms    = var.monitoring.enable_dashboard
  sns_topic_arn    = module.monitoring.sns_topic_arn
  eks_cluster_name = module.eks.cluster_name
  rds_identifier   = module.database.rds_identifier

  depends_on = [module.security, module.eks, module.database, module.monitoring]
}
