#==============================================================================
# OpenShift Container Platform - DR Environment
#==============================================================================
# This file contains ONLY module references with no direct resource definitions.
# All resources are managed through the two-tier module architecture:
#   main.tf -> solution modules -> provider modules (AWS)
#
# DR Strategy: ACTIVE_PASSIVE
# - Secondary cluster in different region
# - etcd backup replication enabled
# - Standby infrastructure ready for failover
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
  environment   = "dr"
  env_display   = "Disaster Recovery"
  name_prefix   = "${var.cluster.name}-${local.environment}"

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
  aws_region  = var.aws_region

  cluster = {
    name             = var.cluster.name
    base_domain      = var.cluster.base_domain
    version          = var.cluster.version
    install_type     = var.cluster.install_type
    platform         = var.cluster.platform
    api_internal     = false
    create_bootstrap = false
  }

  compute = {
    control_plane_count         = var.compute.control_plane_count
    control_plane_instance_type = var.compute.control_plane_instance_type
    control_plane_cpu           = var.compute.control_plane_cpu
    control_plane_memory_gb     = var.compute.control_plane_memory_gb
    worker_count                = var.compute.worker_count
    worker_instance_type        = var.compute.worker_instance_type
    worker_cpu                  = var.compute.worker_cpu
    worker_memory_gb            = var.compute.worker_memory_gb
    rhcos_ami                   = var.compute.rhcos_ami
    key_name                    = var.compute.key_name
  }

  network = {
    type               = var.network.type
    vpc_cidr           = var.network.vpc_cidr
    pod_cidr           = var.network.pod_cidr
    service_cidr       = var.network.service_cidr
    cluster_mtu        = var.network.cluster_mtu
    public_subnets     = var.network.public_subnets
    private_subnets    = var.network.private_subnets
    availability_zones = var.network.availability_zones
  }

  security = {
    allowed_api_cidrs        = var.security.allowed_api_cidrs
    kms_key_arn              = var.security.kms_key_arn
    pod_security_admission   = var.security.pod_security_admission
    network_policies_enabled = var.security.network_policies_enabled
    image_scanning_enabled   = var.security.image_scanning_enabled
    acs_enabled              = var.security.acs_enabled
  }

  dns = {
    create_hosted_zone = false
    private_zone       = false
  }

  common_tags = local.common_tags
}

#==============================================================================
# OPERATIONS - Backup, Monitoring, DR
#==============================================================================
module "operations" {
  source = "../../modules/solution/operations"

  environment  = local.environment
  cluster_name = var.cluster.name

  control_plane_instance_ids = module.core.control_plane_instance_ids
  worker_instance_ids        = module.core.worker_instance_ids

  backup = {
    enabled        = var.backup.enabled
    schedule_cron  = var.backup.schedule_cron
    retention_days = var.backup.retention_days
    s3_bucket      = var.backup.s3_bucket
  }

  dr = {
    enabled             = var.dr.enabled
    strategy            = var.dr.strategy
    rto_hours           = var.dr.rto_hours
    rpo_hours           = var.dr.rpo_hours
    replication_enabled = var.dr.replication_enabled
  }

  monitoring = {
    cloudwatch_alarms_enabled = true
    create_sns_topic          = true
    sns_topic_arn             = null
    alert_email               = var.ownership.owner_email
  }

  security = {
    kms_key_arn = var.security.kms_key_arn
  }

  common_tags = local.common_tags

  depends_on = [module.core]
}

#==============================================================================
# INTEGRATIONS - Cross-module connections
#==============================================================================
#------------------------------------------------------------------------------
# SSM Parameters for Ansible Configuration
#------------------------------------------------------------------------------
resource "aws_ssm_parameter" "cluster_api" {
  name        = "/ocp/${local.environment}/cluster/api"
  description = "OpenShift cluster API endpoint"
  type        = "String"
  value       = var.cluster.api_endpoint

  tags = local.common_tags
}

resource "aws_ssm_parameter" "cluster_console" {
  name        = "/ocp/${local.environment}/cluster/console"
  description = "OpenShift cluster console URL"
  type        = "String"
  value       = var.cluster.console_url

  tags = local.common_tags
}

#------------------------------------------------------------------------------
# DR Status Output (for runbook automation)
#------------------------------------------------------------------------------
resource "aws_ssm_parameter" "dr_status" {
  name        = "/ocp/${local.environment}/dr/status"
  description = "DR environment status"
  type        = "String"
  value       = "STANDBY"

  tags = local.common_tags
}

resource "aws_ssm_parameter" "failover_runbook" {
  name        = "/ocp/${local.environment}/dr/failover_runbook"
  description = "DR failover runbook URL"
  type        = "String"
  value       = "https://runbooks.example.com/ocp-dr-failover"

  tags = local.common_tags
}
