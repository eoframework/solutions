#==============================================================================
# Ansible Automation Platform - DR Environment
#==============================================================================
# DR strategy: ACTIVE_PASSIVE with database replication
# This environment mirrors production in a secondary region
#==============================================================================

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {}
}

provider "aws" {
  region = var.aws_region  # Different region for DR

  default_tags {
    tags = local.common_tags
  }
}

#------------------------------------------------------------------------------
# LOCAL VARIABLES
#------------------------------------------------------------------------------
locals {
  environment = "dr"
  env_display = "Disaster Recovery"
  name_prefix = "${var.solution.abbr}-${local.environment}"

  common_tags = {
    Solution      = var.solution.name
    Provider      = var.solution.provider_name
    Category      = var.solution.category_name
    Environment   = local.env_display
    CostCenter    = var.ownership.cost_center
    ProjectCode   = var.ownership.project_code
    OwnerEmail    = var.ownership.owner_email
    ManagedBy     = "terraform"
    Purpose       = "DR"
    Standby       = "true"
  }
}

#==============================================================================
# FOUNDATION - Core Infrastructure
#==============================================================================
module "core" {
  source = "../../modules/solution/core"

  environment = local.environment

  solution = {
    name          = var.solution.name
    abbr          = var.solution.abbr
    provider_name = var.solution.provider_name
    category_name = var.solution.category_name
  }

  create_vpc = true

  network = {
    vpc_cidr           = var.network.vpc_cidr
    public_subnets     = var.network.public_subnets
    private_subnets    = var.network.private_subnets
    availability_zones = var.network.availability_zones
  }

  compute = {
    ami_id                   = var.compute.ami_id
    key_name                 = var.compute.key_name
    controller_count         = var.compute.controller_count
    controller_instance_type = var.compute.controller_instance_type
    execution_count          = var.compute.execution_count
    execution_instance_type  = var.compute.execution_instance_type
    hub_instance_type        = var.compute.hub_instance_type
  }

  database = {
    host           = var.database.host
    port           = var.database.port
    name           = var.database.name
    username       = var.database.username
    password       = var.database_password
    instance_class = var.database.instance_class
    storage_gb     = var.database.storage_gb
    multi_az       = var.database.multi_az
  }

  security = {
    allowed_cidrs       = ["0.0.0.0/0"]
    kms_key_arn         = var.security.kms_key_arn
    acm_certificate_arn = var.security.acm_certificate_arn
  }

  backup = {
    enabled        = var.backup.enabled
    retention_days = var.backup.retention_days
    s3_bucket      = var.backup.s3_bucket
  }

  dr = {
    enabled                = var.dr.enabled
    strategy               = var.dr.strategy
    rto_hours              = var.dr.rto_hours
    rpo_hours              = var.dr.rpo_hours
    db_replication_enabled = var.dr.db_replication_enabled
  }

  common_tags = local.common_tags
}

#==============================================================================
# OPERATIONS - Monitoring, Backup
#==============================================================================
module "operations" {
  source = "../../modules/solution/operations"

  solution_abbr = var.solution.abbr
  environment   = local.environment

  controller_instance_ids = module.core.controller_instance_ids
  execution_instance_ids  = module.core.execution_instance_ids
  db_instance_identifier  = module.core.db_instance_identifier
  alb_arn                 = module.core.alb_arn
  kms_key_arn             = var.security.kms_key_arn

  monitoring = {
    cloudwatch_alarms_enabled = true
    create_sns_topic          = true
    alert_email               = var.ownership.owner_email
    log_retention_days        = 30
  }

  backup = {
    enabled        = var.backup.enabled
    retention_days = var.backup.retention_days
    s3_bucket      = var.backup.s3_bucket
    use_aws_backup = false
  }

  dr = {
    enabled                = var.dr.enabled
    strategy               = var.dr.strategy
    rto_hours              = var.dr.rto_hours
    rpo_hours              = var.dr.rpo_hours
    db_replication_enabled = var.dr.db_replication_enabled
  }

  common_tags = local.common_tags

  depends_on = [module.core]
}

#==============================================================================
# INTEGRATIONS - Cross-module connections
#==============================================================================
resource "aws_ssm_parameter" "controller_url" {
  name        = "/aap/${local.environment}/controller/url"
  description = "AAP Controller URL"
  type        = "String"
  value       = "https://${module.core.alb_dns_name}"

  tags = local.common_tags

  depends_on = [module.core]
}

resource "aws_ssm_parameter" "db_endpoint" {
  name        = "/aap/${local.environment}/database/endpoint"
  description = "AAP PostgreSQL database endpoint"
  type        = "String"
  value       = module.core.db_endpoint

  tags = local.common_tags

  depends_on = [module.core]
}

#------------------------------------------------------------------------------
# DR Status Output (for runbook automation)
#------------------------------------------------------------------------------
resource "aws_ssm_parameter" "dr_status" {
  name        = "/aap/${local.environment}/dr/status"
  description = "DR environment status"
  type        = "String"
  value       = "STANDBY"

  tags = local.common_tags
}

resource "aws_ssm_parameter" "failover_runbook" {
  name        = "/aap/${local.environment}/dr/failover_runbook"
  description = "DR failover runbook URL"
  type        = "String"
  value       = "https://runbooks.example.com/aap-dr-failover"

  tags = local.common_tags
}
