# Production Environment - Full Deployment
#
# Composes: core + database + cache + security + monitoring
#
# This is a full production deployment with:
# - VPC, ALB, ASG (core)
# - RDS with Multi-AZ (database)
# - ElastiCache Redis cluster (cache)
# - WAF, GuardDuty, CloudTrail (security)
# - CloudWatch Dashboard, X-Ray (monitoring)
#
# See providers.tf for Terraform/AWS provider configuration
# See README.md for prerequisites and setup instructions

#------------------------------------------------------------------------------
# Naming Standards & Common Tags
#------------------------------------------------------------------------------
# All resources use consistent naming: {solution_abbr}-{environment}-{resource}
# Environment is auto-discovered from folder name or can be overridden
#------------------------------------------------------------------------------

locals {
  # Auto-discover environment from folder name (prod, test, dr)
  environment = basename(path.module)

  # Environment display names for human-readable outputs
  env_display_name = {
    prod = "Production"
    test = "Test"
    dr   = "Disaster Recovery"
  }

  # Standardized naming prefix: {solution_abbr}-{environment}
  # Example: vxr-prod, sfi-test, pci-dr
  name_prefix = "${var.solution.abbr}-${local.environment}"

  # Common tags applied to ALL resources via provider default_tags
  common_tags = {
    Solution     = var.solution.name
    SolutionAbbr = var.solution.abbr
    Environment  = local.environment
    EnvDisplay   = lookup(local.env_display_name, local.environment, local.environment)
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
# Core Infrastructure (Required)
#------------------------------------------------------------------------------

module "core" {
  source = "../../modules/solution/core"

  # Naming
  name_prefix     = local.name_prefix
  project_name    = var.solution.name
  environment     = local.environment
  additional_tags = local.common_tags

  # Pass grouped configurations
  network     = var.network
  security    = var.security
  compute     = var.compute
  alb         = var.alb
  application = var.application

  # Cross-module references
  kms_key_arn = module.security.kms_key_arn
}

#------------------------------------------------------------------------------
# Security (WAF, GuardDuty, CloudTrail, KMS)
#------------------------------------------------------------------------------

module "security" {
  source = "../../modules/solution/security"

  name_prefix = local.name_prefix
  common_tags = local.common_tags
  alb_arn     = module.core.alb_arn

  # Pass security configuration
  security = var.security
}

#------------------------------------------------------------------------------
# Database (RDS)
#------------------------------------------------------------------------------

module "database" {
  source = "../../modules/solution/database"

  name_prefix          = local.name_prefix
  common_tags          = local.common_tags
  environment          = local.environment
  db_subnet_group_name = module.core.db_subnet_group_name
  security_group_ids   = [module.core.database_security_group_id]
  kms_key_arn          = module.security.kms_key_arn

  # Pass database configuration
  database = var.database

  # Alarms
  enable_alarms       = true
  alarm_sns_topic_arn = module.monitoring.sns_topic_arn
}

#------------------------------------------------------------------------------
# Cache (ElastiCache Redis)
#------------------------------------------------------------------------------

module "cache" {
  source = "../../modules/solution/cache"
  count  = var.cache.enabled ? 1 : 0

  name_prefix                   = local.name_prefix
  common_tags                   = local.common_tags
  elasticache_subnet_group_name = module.core.elasticache_subnet_group_name
  security_group_ids            = [module.core.cache_security_group_id]
  kms_key_arn                   = module.security.kms_key_arn

  # Pass cache configuration
  cache = var.cache

  # Alarms
  enable_alarms       = true
  alarm_sns_topic_arn = module.monitoring.sns_topic_arn
}

#------------------------------------------------------------------------------
# Monitoring (CloudWatch, X-Ray)
#------------------------------------------------------------------------------

module "monitoring" {
  source = "../../modules/solution/monitoring"

  name_prefix  = local.name_prefix
  common_tags  = local.common_tags
  project_name = var.solution.name
  environment  = local.environment
  kms_key_arn  = module.security.kms_key_arn

  # Resource references
  alb_arn          = module.core.alb_arn
  asg_name         = module.core.asg_name
  rds_identifier   = module.database.rds_identifier
  cache_cluster_id = var.cache.enabled ? module.cache[0].cache_replication_group_id : ""

  # Pass monitoring configuration
  monitoring = var.monitoring
}

#------------------------------------------------------------------------------
# Best Practices (Config, GuardDuty, Backup, Budgets)
#------------------------------------------------------------------------------

module "best_practices" {
  source = "../../modules/solution/best-practices"

  name_prefix   = local.name_prefix
  common_tags   = local.common_tags
  environment   = local.environment
  kms_key_arn   = module.security.kms_key_arn
  sns_topic_arn = module.monitoring.sns_topic_arn

  # Pass grouped configurations
  config_rules       = var.config_rules
  guardduty_enhanced = var.guardduty_enhanced
  backup             = var.backup
  budget             = var.budget
}
