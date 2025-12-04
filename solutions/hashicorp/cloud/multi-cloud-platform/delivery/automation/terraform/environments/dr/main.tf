#------------------------------------------------------------------------------
# HashiCorp Multi-Cloud Platform - Production Environment
#------------------------------------------------------------------------------
# Enterprise multi-cloud infrastructure automation platform:
# - Terraform Cloud on AWS EKS for centralized IaC
# - HashiCorp Vault for secrets management and dynamic credentials
# - HashiCorp Consul for service mesh (optional)
# - Sentinel policies for governance
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
# CORE PLATFORM - HashiCorp infrastructure components
#===============================================================================
#------------------------------------------------------------------------------
# EKS Cluster (for Terraform Cloud)
#------------------------------------------------------------------------------
module "eks" {
  source = "../../modules/aws/eks"

  name_prefix        = local.name_prefix
  common_tags        = local.common_tags
  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids
  compute            = var.compute
  kms_key_arn        = module.security.kms_key_arn

  depends_on = [module.networking, module.security]
}

#------------------------------------------------------------------------------
# RDS PostgreSQL (Terraform Cloud state backend)
#------------------------------------------------------------------------------
module "database" {
  source = "../../modules/aws/rds"

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
# HashiCorp Vault Cluster
#------------------------------------------------------------------------------
module "vault" {
  source = "../../modules/vault/cluster"
  count  = var.vault.enabled ? 1 : 0

  name_prefix        = local.name_prefix
  common_tags        = local.common_tags
  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids
  kms_key_arn        = module.security.kms_key_arn
  vault              = var.vault

  depends_on = [module.networking, module.security]
}

#------------------------------------------------------------------------------
# Terraform Cloud/Enterprise Configuration
#------------------------------------------------------------------------------
module "tfc" {
  source = "../../modules/tfe/organization"

  name_prefix    = local.name_prefix
  common_tags    = local.common_tags
  tfc            = var.tfc
  vault_enabled  = var.vault.enabled
  vault_endpoint = var.vault.enabled ? module.vault[0].vault_endpoint : ""

  depends_on = [module.eks, module.database, module.vault]
}

#------------------------------------------------------------------------------
# HashiCorp Consul Service Mesh
#------------------------------------------------------------------------------
module "consul" {
  source = "../../modules/consul/cluster"
  count  = var.consul.enabled ? 1 : 0

  name_prefix         = local.name_prefix
  common_tags         = local.common_tags
  eks_cluster_name    = module.eks.cluster_name
  eks_cluster_endpoint = module.eks.cluster_endpoint
  consul              = var.consul

  depends_on = [module.eks]
}

#===============================================================================
# GOVERNANCE - Sentinel policies and compliance
#===============================================================================
#------------------------------------------------------------------------------
# Sentinel Policy Sets
#------------------------------------------------------------------------------
module "sentinel" {
  source = "../../modules/tfe/policy-set"
  count  = var.sentinel.enabled ? 1 : 0

  name_prefix      = local.name_prefix
  organization     = module.tfc.organization_name
  sentinel         = var.sentinel

  depends_on = [module.tfc]
}

#===============================================================================
# OPERATIONS - Monitoring, compliance, and DR
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
  backup        = var.backup

  depends_on = [module.security]
}

#------------------------------------------------------------------------------
# Disaster Recovery
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

  # Vault AWS secrets engine
  vault_enabled             = var.vault.enabled
  vault_aws_secrets_enabled = var.vault.aws_secrets_enabled
  vault_aws_access_key      = var.vault_aws_access_key
  vault_aws_secret_key      = var.vault_aws_secret_key
  aws_region                = var.aws.region
  vault_credential_ttl_seconds = var.vault.credential_ttl_seconds

  # CloudWatch alarms
  enable_alarms    = var.monitoring.enable_dashboard
  sns_topic_arn    = module.monitoring.sns_topic_arn
  eks_cluster_name = module.eks.cluster_name
  rds_identifier   = module.database.rds_identifier

  depends_on = [module.security, module.eks, module.database, module.monitoring, module.vault]
}
