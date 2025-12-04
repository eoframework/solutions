#==============================================================================
# Ansible Automation Platform - Test Environment
#==============================================================================
# Reduced scale for test/dev purposes with minimal HA and DR
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
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}

#------------------------------------------------------------------------------
# LOCAL VARIABLES
#------------------------------------------------------------------------------
locals {
  environment = "test"
  env_display = "Test"
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
    multi_az       = false  # No HA for test
  }

  security = {
    allowed_cidrs       = ["0.0.0.0/0"]
    kms_key_arn         = null
    acm_certificate_arn = var.security.acm_certificate_arn
  }

  backup = {
    enabled        = false
    retention_days = 7
    s3_bucket      = var.backup.s3_bucket
  }

  dr = {
    enabled                = false
    strategy               = "BACKUP_ONLY"
    rto_hours              = 8
    rpo_hours              = 24
    db_replication_enabled = false
  }

  common_tags = local.common_tags
}

#==============================================================================
# OPERATIONS - Monitoring (minimal for test)
#==============================================================================
module "operations" {
  source = "../../modules/solution/operations"

  solution_abbr = var.solution.abbr
  environment   = local.environment

  controller_instance_ids = module.core.controller_instance_ids
  execution_instance_ids  = module.core.execution_instance_ids
  db_instance_identifier  = module.core.db_instance_identifier
  alb_arn                 = module.core.alb_arn
  kms_key_arn             = null

  monitoring = {
    cloudwatch_alarms_enabled = false  # Minimal for test
    create_sns_topic          = false
    alert_email               = var.ownership.owner_email
    log_retention_days        = 7
  }

  backup = {
    enabled        = false
    retention_days = 7
    s3_bucket      = var.backup.s3_bucket
    use_aws_backup = false
  }

  dr = {
    enabled                = false
    strategy               = "BACKUP_ONLY"
    rto_hours              = 8
    rpo_hours              = 24
    db_replication_enabled = false
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
