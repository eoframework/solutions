#==============================================================================
# Ansible Automation Platform - Production Environment
#==============================================================================
# This file contains ONLY module references with no direct resource definitions.
# All resources are managed through the two-tier module architecture:
#   main.tf -> solution modules -> provider modules (AWS)
#==============================================================================

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    # Configure via backend.tfvars or environment variables
  }
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
  environment = "prod"
  env_display = "Production"
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
#------------------------------------------------------------------------------
# Core Module (VPC, Security Groups, EC2, RDS, ALB)
#------------------------------------------------------------------------------
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
# OPERATIONS - Monitoring, Backup, DR
#==============================================================================
#------------------------------------------------------------------------------
# Operations Module (CloudWatch, SNS, S3 Backups)
#------------------------------------------------------------------------------
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
# INTEGRATIONS - Cross-module connections that break circular dependencies
#==============================================================================
#------------------------------------------------------------------------------
# SSM Parameters for Ansible Configuration
#------------------------------------------------------------------------------
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

resource "aws_ssm_parameter" "hub_url" {
  count = module.core.hub_instance_id != "" ? 1 : 0

  name        = "/aap/${local.environment}/hub/url"
  description = "AAP Private Automation Hub URL"
  type        = "String"
  value       = var.platform.hub_url

  tags = local.common_tags

  depends_on = [module.core]
}

#------------------------------------------------------------------------------
# CloudWatch Dashboard
#------------------------------------------------------------------------------
resource "aws_cloudwatch_dashboard" "aap" {
  dashboard_name = "${local.name_prefix}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "Controller CPU Utilization"
          region = var.aws_region
          metrics = [
            for idx, id in module.core.controller_instance_ids : [
              "AWS/EC2", "CPUUtilization",
              "InstanceId", id,
              { label = "Controller ${idx + 1}" }
            ]
          ]
          period = 300
          stat   = "Average"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "Database CPU & Connections"
          region = var.aws_region
          metrics = [
            ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", module.core.db_instance_identifier, { label = "CPU %" }],
            [".", "DatabaseConnections", ".", ".", { label = "Connections", yAxis = "right" }]
          ]
          period = 300
          stat   = "Average"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          title  = "ALB Request Count"
          region = var.aws_region
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", module.core.alb_arn_suffix]
          ]
          period = 300
          stat   = "Sum"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          title  = "ALB Target Response Time"
          region = var.aws_region
          metrics = [
            ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", module.core.alb_arn_suffix]
          ]
          period = 300
          stat   = "Average"
        }
      }
    ]
  })

  depends_on = [module.core, module.operations]
}

#------------------------------------------------------------------------------
# Budget Alert (Cost Optimization Best Practice)
#------------------------------------------------------------------------------
resource "aws_budgets_budget" "aap" {
  count = var.budget.enabled ? 1 : 0

  name         = "${local.name_prefix}-monthly-budget"
  budget_type  = "COST"
  limit_amount = tostring(var.budget.monthly_amount_usd)
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  cost_filter {
    name   = "TagKeyValue"
    values = ["user:Solution$${var.solution.name}"]
  }

  dynamic "notification" {
    for_each = var.budget.alert_thresholds

    content {
      comparison_operator        = "GREATER_THAN"
      threshold                  = notification.value
      threshold_type             = "PERCENTAGE"
      notification_type          = "ACTUAL"
      subscriber_email_addresses = [var.ownership.owner_email]
    }
  }
}
