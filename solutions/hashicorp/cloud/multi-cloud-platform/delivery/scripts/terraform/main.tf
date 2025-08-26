# HashiCorp Multi-Cloud Infrastructure Management Platform
# This Terraform configuration deploys HashiCorp's complete product suite
# across multiple cloud providers for unified multi-cloud operations.

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.10"
    }
    consul = {
      source  = "hashicorp/consul"
      version = "~> 2.18"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.20"
    }
    nomad = {
      source  = "hashicorp/nomad"
      version = "~> 2.0"
    }
  }

  backend "consul" {
    address = var.consul_backend_address
    scheme  = "https"
    path    = "terraform/multi-cloud-platform/terraform.tfstate"
  }
}

# Local values
locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Solution    = "hashicorp-multi-cloud"
    Owner       = var.owner
    CostCenter  = var.cost_center
  }

  # Cloud provider configurations
  aws_regions    = var.aws_regions
  azure_regions  = var.azure_regions
  gcp_regions    = var.gcp_regions
  
  # HashiCorp product configuration
  hashicorp_products = {
    terraform = var.enable_terraform_enterprise
    consul    = var.enable_consul
    vault     = var.enable_vault
    nomad     = var.enable_nomad
    boundary  = var.enable_boundary
  }
}

# AWS Provider Configuration
provider "aws" {
  alias  = "primary"
  region = local.aws_regions.primary

  default_tags {
    tags = local.common_tags
  }
}

provider "aws" {
  alias  = "secondary"
  region = local.aws_regions.secondary

  default_tags {
    tags = local.common_tags
  }
}

# Azure Provider Configuration
provider "azurerm" {
  features {}
  
  subscription_id = var.azure_subscription_id
}

# Google Cloud Provider Configuration
provider "google" {
  project = var.gcp_project_id
  region  = local.gcp_regions.primary
}

provider "google" {
  alias   = "secondary"
  project = var.gcp_project_id
  region  = local.gcp_regions.secondary
}

# Data sources
data "aws_availability_zones" "aws_primary" {
  provider = aws.primary
  state    = "available"
}

data "aws_availability_zones" "aws_secondary" {
  provider = aws.secondary
  state    = "available"
}

data "azurerm_client_config" "current" {}

# AWS Infrastructure
module "aws_infrastructure" {
  source = "./modules/aws-infrastructure"

  providers = {
    aws.primary   = aws.primary
    aws.secondary = aws.secondary
  }

  project_name = var.project_name
  environment  = var.environment
  
  # Network configuration
  vpc_cidr_primary   = var.aws_vpc_cidrs.primary
  vpc_cidr_secondary = var.aws_vpc_cidrs.secondary
  
  # Compute configuration
  instance_types     = var.aws_instance_types
  min_size          = var.min_cluster_size
  max_size          = var.max_cluster_size
  desired_capacity  = var.desired_cluster_size

  # HashiCorp products configuration
  hashicorp_products = local.hashicorp_products

  tags = local.common_tags
}

# Azure Infrastructure
module "azure_infrastructure" {
  source = "./modules/azure-infrastructure"

  project_name = var.project_name
  environment  = var.environment
  
  # Resource Group
  resource_group_name     = var.azure_resource_group_name
  resource_group_location = local.azure_regions.primary
  
  # Network configuration
  vnet_address_space = var.azure_vnet_address_space
  subnet_prefixes    = var.azure_subnet_prefixes
  
  # Compute configuration
  vm_size          = var.azure_vm_size
  node_count       = var.azure_node_count

  # HashiCorp products configuration
  hashicorp_products = local.hashicorp_products

  tags = local.common_tags
}

# Google Cloud Infrastructure
module "gcp_infrastructure" {
  source = "./modules/gcp-infrastructure"

  providers = {
    google.primary   = google
    google.secondary = google.secondary
  }

  project_name = var.project_name
  environment  = var.environment
  project_id   = var.gcp_project_id
  
  # Network configuration
  vpc_cidr_primary   = var.gcp_vpc_cidrs.primary
  vpc_cidr_secondary = var.gcp_vpc_cidrs.secondary
  
  # Compute configuration
  machine_types    = var.gcp_machine_types
  min_node_count   = var.min_cluster_size
  max_node_count   = var.max_cluster_size
  
  # HashiCorp products configuration
  hashicorp_products = local.hashicorp_products

  labels = local.common_tags
}

# Consul Cluster Configuration
module "consul_cluster" {
  source = "./modules/consul-cluster"
  count  = var.enable_consul ? 1 : 0

  project_name = var.project_name
  environment  = var.environment

  # Multi-cloud configuration
  aws_clusters   = module.aws_infrastructure.consul_endpoints
  azure_clusters = module.azure_infrastructure.consul_endpoints
  gcp_clusters   = module.gcp_infrastructure.consul_endpoints

  # Consul configuration
  consul_datacenter       = var.consul_datacenter
  consul_encryption_key   = var.consul_encryption_key
  consul_connect_enabled  = var.consul_connect_enabled
  consul_acl_enabled      = var.consul_acl_enabled

  # Federation configuration
  enable_federation       = var.enable_consul_federation
  federation_secret_key   = var.consul_federation_secret

  depends_on = [
    module.aws_infrastructure,
    module.azure_infrastructure,
    module.gcp_infrastructure
  ]
}

# Vault Cluster Configuration
module "vault_cluster" {
  source = "./modules/vault-cluster"
  count  = var.enable_vault ? 1 : 0

  project_name = var.project_name
  environment  = var.environment

  # Multi-cloud configuration
  aws_clusters   = module.aws_infrastructure.vault_endpoints
  azure_clusters = module.azure_infrastructure.vault_endpoints
  gcp_clusters   = module.gcp_infrastructure.vault_endpoints

  # Vault configuration
  vault_kms_key_aws   = module.aws_infrastructure.vault_kms_key
  vault_kms_key_azure = module.azure_infrastructure.vault_kms_key
  vault_kms_key_gcp   = module.gcp_infrastructure.vault_kms_key

  # Storage backends
  vault_storage_backend = var.vault_storage_backend
  storage_configuration = var.vault_storage_config

  # Performance Replication
  enable_performance_replication = var.enable_vault_replication
  performance_primary_cluster    = var.vault_primary_cluster

  depends_on = [
    module.aws_infrastructure,
    module.azure_infrastructure,
    module.gcp_infrastructure
  ]
}

# Nomad Cluster Configuration
module "nomad_cluster" {
  source = "./modules/nomad-cluster"
  count  = var.enable_nomad ? 1 : 0

  project_name = var.project_name
  environment  = var.environment

  # Multi-cloud configuration
  aws_clusters   = module.aws_infrastructure.nomad_endpoints
  azure_clusters = module.azure_infrastructure.nomad_endpoints
  gcp_clusters   = module.gcp_infrastructure.nomad_endpoints

  # Nomad configuration
  nomad_datacenter    = var.nomad_datacenter
  nomad_region        = var.nomad_region
  nomad_acl_enabled   = var.nomad_acl_enabled

  # Federation configuration
  enable_federation   = var.enable_nomad_federation
  federation_regions  = var.nomad_federation_regions

  # Integration with Consul and Vault
  consul_integration = var.enable_consul
  vault_integration  = var.enable_vault
  
  consul_address = var.enable_consul ? module.consul_cluster[0].consul_address : ""
  vault_address  = var.enable_vault ? module.vault_cluster[0].vault_address : ""

  depends_on = [
    module.consul_cluster,
    module.vault_cluster
  ]
}

# Boundary Configuration
module "boundary_cluster" {
  source = "./modules/boundary-cluster"
  count  = var.enable_boundary ? 1 : 0

  project_name = var.project_name
  environment  = var.environment

  # Multi-cloud configuration
  aws_workers   = module.aws_infrastructure.boundary_workers
  azure_workers = module.azure_infrastructure.boundary_workers
  gcp_workers   = module.gcp_infrastructure.boundary_workers

  # Boundary configuration
  boundary_database_url = var.boundary_database_url
  boundary_kms_config   = var.boundary_kms_config
  
  # Integration with Vault
  vault_integration = var.enable_vault
  vault_address     = var.enable_vault ? module.vault_cluster[0].vault_address : ""

  depends_on = [
    module.aws_infrastructure,
    module.azure_infrastructure,
    module.gcp_infrastructure,
    module.vault_cluster
  ]
}

# Cross-Cloud Networking
module "cross_cloud_networking" {
  source = "./modules/cross-cloud-networking"

  project_name = var.project_name
  environment  = var.environment

  # Cloud provider configurations
  aws_vpc_ids    = module.aws_infrastructure.vpc_ids
  azure_vnet_ids = module.azure_infrastructure.vnet_ids
  gcp_vpc_names  = module.gcp_infrastructure.vpc_names

  # VPN Gateway configuration
  enable_vpn_gateways = var.enable_cross_cloud_vpn
  vpn_shared_secrets  = var.cross_cloud_vpn_secrets

  # Transit Gateway configuration
  enable_transit_gateway = var.enable_aws_transit_gateway
  transit_gateway_asn    = var.transit_gateway_asn

  # Peering configuration
  enable_vpc_peering     = var.enable_cross_cloud_peering
  peering_configurations = var.cross_cloud_peering_config

  depends_on = [
    module.aws_infrastructure,
    module.azure_infrastructure,
    module.gcp_infrastructure
  ]
}

# Service Mesh Configuration
module "service_mesh" {
  source = "./modules/service-mesh"
  count  = var.enable_consul && var.consul_connect_enabled ? 1 : 0

  project_name = var.project_name
  environment  = var.environment

  # Consul Connect configuration
  consul_clusters = module.consul_cluster[0].cluster_endpoints
  
  # Cross-cloud service mesh
  enable_cross_cloud_mesh = var.enable_cross_cloud_service_mesh
  mesh_gateways           = var.consul_mesh_gateway_config

  # Certificate Authority
  connect_ca_provider = var.consul_connect_ca_provider
  ca_configuration   = var.consul_ca_config

  depends_on = [
    module.consul_cluster
  ]
}

# Monitoring and Observability
module "monitoring" {
  source = "./modules/monitoring"

  project_name = var.project_name
  environment  = var.environment

  # Multi-cloud monitoring endpoints
  aws_monitoring_endpoints   = module.aws_infrastructure.monitoring_endpoints
  azure_monitoring_endpoints = module.azure_infrastructure.monitoring_endpoints
  gcp_monitoring_endpoints   = module.gcp_infrastructure.monitoring_endpoints

  # HashiCorp product monitoring
  consul_metrics_endpoints = var.enable_consul ? module.consul_cluster[0].metrics_endpoints : []
  vault_metrics_endpoints  = var.enable_vault ? module.vault_cluster[0].metrics_endpoints : []
  nomad_metrics_endpoints  = var.enable_nomad ? module.nomad_cluster[0].metrics_endpoints : []

  # Monitoring configuration
  prometheus_retention = var.prometheus_retention_days
  grafana_admin_password = var.grafana_admin_password

  # Alerting configuration
  alert_manager_config = var.alertmanager_config
  notification_channels = var.monitoring_notification_channels

  depends_on = [
    module.consul_cluster,
    module.vault_cluster,
    module.nomad_cluster
  ]
}

# Backup and Disaster Recovery
module "backup_disaster_recovery" {
  source = "./modules/backup-disaster-recovery"

  project_name = var.project_name
  environment  = var.environment

  # Backup configuration
  enable_automated_backups = var.enable_automated_backups
  backup_schedule         = var.backup_schedule
  backup_retention_days   = var.backup_retention_days

  # Cross-cloud backup replication
  enable_cross_cloud_backup = var.enable_cross_cloud_backup
  backup_replication_regions = var.backup_replication_regions

  # HashiCorp product backup
  consul_backup_config = var.consul_backup_config
  vault_backup_config  = var.vault_backup_config
  nomad_backup_config  = var.nomad_backup_config

  # Disaster recovery configuration
  enable_disaster_recovery = var.enable_disaster_recovery
  dr_regions              = var.disaster_recovery_regions
  rto_minutes             = var.recovery_time_objective
  rpo_minutes             = var.recovery_point_objective

  depends_on = [
    module.consul_cluster,
    module.vault_cluster,
    module.nomad_cluster
  ]
}

# Security and Compliance
module "security_compliance" {
  source = "./modules/security-compliance"

  project_name = var.project_name
  environment  = var.environment

  # Security scanning
  enable_security_scanning = var.enable_security_scanning
  security_scan_schedule  = var.security_scan_schedule

  # Compliance frameworks
  compliance_frameworks = var.compliance_frameworks
  
  # Audit logging
  enable_audit_logging    = var.enable_audit_logging
  audit_log_retention     = var.audit_log_retention_days

  # Policy as Code
  enable_policy_as_code   = var.enable_policy_as_code
  sentinel_policies       = var.sentinel_policies
  opa_policies           = var.opa_policies

  depends_on = [
    module.consul_cluster,
    module.vault_cluster,
    module.nomad_cluster
  ]
}

# Cost Management
module "cost_management" {
  source = "./modules/cost-management"

  project_name = var.project_name
  environment  = var.environment

  # Multi-cloud cost tracking
  aws_cost_allocation_tags    = local.common_tags
  azure_cost_allocation_tags  = local.common_tags
  gcp_cost_allocation_labels  = local.common_tags

  # Cost optimization
  enable_cost_optimization    = var.enable_cost_optimization
  cost_optimization_schedule  = var.cost_optimization_schedule

  # Budget alerts
  enable_budget_alerts        = var.enable_budget_alerts
  monthly_budget_thresholds   = var.monthly_budget_thresholds
  budget_notification_emails  = var.budget_notification_emails

  depends_on = [
    module.aws_infrastructure,
    module.azure_infrastructure,
    module.gcp_infrastructure
  ]
}