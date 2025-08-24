# HashiCorp Multi-Cloud Infrastructure Management Platform - Variables
# This file defines all input variables for the multi-cloud platform deployment

# Project Configuration
variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "hashicorp-multicloud"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "owner" {
  description = "Owner of the resources"
  type        = string
  default     = "platform-team"
}

variable "cost_center" {
  description = "Cost center for resource billing"
  type        = string
  default     = "infrastructure"
}

# Consul Backend Configuration
variable "consul_backend_address" {
  description = "Consul backend address for Terraform state"
  type        = string
  default     = "consul.example.com:8500"
}

# AWS Configuration
variable "aws_regions" {
  description = "AWS regions configuration"
  type = object({
    primary   = string
    secondary = string
  })
  default = {
    primary   = "us-west-2"
    secondary = "us-east-1"
  }
}

variable "aws_vpc_cidrs" {
  description = "VPC CIDR blocks for AWS regions"
  type = object({
    primary   = string
    secondary = string
  })
  default = {
    primary   = "10.0.0.0/16"
    secondary = "10.1.0.0/16"
  }
}

variable "aws_instance_types" {
  description = "EC2 instance types for different workloads"
  type = object({
    consul   = string
    vault    = string
    nomad    = string
    boundary = string
  })
  default = {
    consul   = "m5.xlarge"
    vault    = "m5.xlarge"
    nomad    = "m5.large"
    boundary = "m5.large"
  }
}

# Azure Configuration
variable "azure_subscription_id" {
  description = "Azure subscription ID"
  type        = string
  default     = ""
}

variable "azure_resource_group_name" {
  description = "Azure resource group name"
  type        = string
  default     = "rg-hashicorp-multicloud"
}

variable "azure_regions" {
  description = "Azure regions configuration"
  type = object({
    primary   = string
    secondary = string
  })
  default = {
    primary   = "West US 2"
    secondary = "East US"
  }
}

variable "azure_vnet_address_space" {
  description = "Azure VNet address space"
  type        = list(string)
  default     = ["10.2.0.0/16"]
}

variable "azure_subnet_prefixes" {
  description = "Azure subnet prefixes"
  type        = list(string)
  default     = ["10.2.1.0/24", "10.2.2.0/24", "10.2.3.0/24"]
}

variable "azure_vm_size" {
  description = "Azure VM size"
  type        = string
  default     = "Standard_D4s_v3"
}

variable "azure_node_count" {
  description = "Number of Azure nodes"
  type        = number
  default     = 3
}

# Google Cloud Configuration
variable "gcp_project_id" {
  description = "Google Cloud Project ID"
  type        = string
  default     = ""
}

variable "gcp_regions" {
  description = "GCP regions configuration"
  type = object({
    primary   = string
    secondary = string
  })
  default = {
    primary   = "us-west1"
    secondary = "us-east1"
  }
}

variable "gcp_vpc_cidrs" {
  description = "VPC CIDR blocks for GCP regions"
  type = object({
    primary   = string
    secondary = string
  })
  default = {
    primary   = "10.3.0.0/16"
    secondary = "10.4.0.0/16"
  }
}

variable "gcp_machine_types" {
  description = "GCP machine types for different workloads"
  type = object({
    consul   = string
    vault    = string
    nomad    = string
    boundary = string
  })
  default = {
    consul   = "n1-standard-4"
    vault    = "n1-standard-4"
    nomad    = "n1-standard-2"
    boundary = "n1-standard-2"
  }
}

# Cluster Sizing Configuration
variable "min_cluster_size" {
  description = "Minimum cluster size"
  type        = number
  default     = 3
}

variable "max_cluster_size" {
  description = "Maximum cluster size"
  type        = number
  default     = 10
}

variable "desired_cluster_size" {
  description = "Desired cluster size"
  type        = number
  default     = 5
}

# HashiCorp Products Configuration
variable "enable_terraform_enterprise" {
  description = "Enable Terraform Enterprise deployment"
  type        = bool
  default     = true
}

variable "enable_consul" {
  description = "Enable Consul deployment"
  type        = bool
  default     = true
}

variable "enable_vault" {
  description = "Enable Vault deployment"
  type        = bool
  default     = true
}

variable "enable_nomad" {
  description = "Enable Nomad deployment"
  type        = bool
  default     = true
}

variable "enable_boundary" {
  description = "Enable Boundary deployment"
  type        = bool
  default     = true
}

# Consul Configuration
variable "consul_datacenter" {
  description = "Consul datacenter name"
  type        = string
  default     = "dc1"
}

variable "consul_encryption_key" {
  description = "Consul encryption key"
  type        = string
  sensitive   = true
  default     = ""
}

variable "consul_connect_enabled" {
  description = "Enable Consul Connect service mesh"
  type        = bool
  default     = true
}

variable "consul_acl_enabled" {
  description = "Enable Consul ACLs"
  type        = bool
  default     = true
}

variable "enable_consul_federation" {
  description = "Enable Consul federation across clouds"
  type        = bool
  default     = true
}

variable "consul_federation_secret" {
  description = "Consul federation secret key"
  type        = string
  sensitive   = true
  default     = ""
}

variable "enable_cross_cloud_service_mesh" {
  description = "Enable cross-cloud service mesh"
  type        = bool
  default     = true
}

variable "consul_mesh_gateway_config" {
  description = "Consul mesh gateway configuration"
  type        = map(any)
  default     = {}
}

variable "consul_connect_ca_provider" {
  description = "Consul Connect CA provider"
  type        = string
  default     = "vault"
}

variable "consul_ca_config" {
  description = "Consul CA configuration"
  type        = map(any)
  default     = {}
}

# Vault Configuration
variable "vault_storage_backend" {
  description = "Vault storage backend"
  type        = string
  default     = "consul"
}

variable "vault_storage_config" {
  description = "Vault storage configuration"
  type        = map(any)
  default     = {}
}

variable "enable_vault_replication" {
  description = "Enable Vault performance replication"
  type        = bool
  default     = true
}

variable "vault_primary_cluster" {
  description = "Primary Vault cluster location"
  type        = string
  default     = "aws-primary"
}

# Nomad Configuration
variable "nomad_datacenter" {
  description = "Nomad datacenter name"
  type        = string
  default     = "dc1"
}

variable "nomad_region" {
  description = "Nomad region name"
  type        = string
  default     = "global"
}

variable "nomad_acl_enabled" {
  description = "Enable Nomad ACLs"
  type        = bool
  default     = true
}

variable "enable_nomad_federation" {
  description = "Enable Nomad federation across regions"
  type        = bool
  default     = true
}

variable "nomad_federation_regions" {
  description = "Nomad federation regions"
  type        = list(string)
  default     = ["aws", "azure", "gcp"]
}

# Boundary Configuration
variable "boundary_database_url" {
  description = "Boundary database connection URL"
  type        = string
  sensitive   = true
  default     = ""
}

variable "boundary_kms_config" {
  description = "Boundary KMS configuration"
  type        = map(any)
  default     = {}
}

# Cross-Cloud Networking
variable "enable_cross_cloud_vpn" {
  description = "Enable cross-cloud VPN connections"
  type        = bool
  default     = true
}

variable "cross_cloud_vpn_secrets" {
  description = "Cross-cloud VPN shared secrets"
  type        = map(string)
  sensitive   = true
  default     = {}
}

variable "enable_aws_transit_gateway" {
  description = "Enable AWS Transit Gateway"
  type        = bool
  default     = true
}

variable "transit_gateway_asn" {
  description = "Transit Gateway ASN"
  type        = number
  default     = 64512
}

variable "enable_cross_cloud_peering" {
  description = "Enable cross-cloud VPC peering"
  type        = bool
  default     = true
}

variable "cross_cloud_peering_config" {
  description = "Cross-cloud peering configuration"
  type        = map(any)
  default     = {}
}

# Monitoring Configuration
variable "prometheus_retention_days" {
  description = "Prometheus metrics retention in days"
  type        = number
  default     = 30
}

variable "grafana_admin_password" {
  description = "Grafana admin password"
  type        = string
  sensitive   = true
  default     = ""
}

variable "alertmanager_config" {
  description = "AlertManager configuration"
  type        = map(any)
  default     = {}
}

variable "monitoring_notification_channels" {
  description = "Monitoring notification channels"
  type        = list(string)
  default     = []
}

# Backup and Disaster Recovery
variable "enable_automated_backups" {
  description = "Enable automated backups"
  type        = bool
  default     = true
}

variable "backup_schedule" {
  description = "Backup schedule (cron format)"
  type        = string
  default     = "0 2 * * *"
}

variable "backup_retention_days" {
  description = "Backup retention in days"
  type        = number
  default     = 30
}

variable "enable_cross_cloud_backup" {
  description = "Enable cross-cloud backup replication"
  type        = bool
  default     = true
}

variable "backup_replication_regions" {
  description = "Backup replication regions"
  type        = list(string)
  default     = ["us-east-1", "us-west-2", "eu-west-1"]
}

variable "consul_backup_config" {
  description = "Consul backup configuration"
  type        = map(any)
  default     = {}
}

variable "vault_backup_config" {
  description = "Vault backup configuration"
  type        = map(any)
  default     = {}
}

variable "nomad_backup_config" {
  description = "Nomad backup configuration"
  type        = map(any)
  default     = {}
}

variable "enable_disaster_recovery" {
  description = "Enable disaster recovery"
  type        = bool
  default     = true
}

variable "disaster_recovery_regions" {
  description = "Disaster recovery regions"
  type        = list(string)
  default     = ["us-east-1", "eu-west-1"]
}

variable "recovery_time_objective" {
  description = "Recovery Time Objective (RTO) in minutes"
  type        = number
  default     = 60
}

variable "recovery_point_objective" {
  description = "Recovery Point Objective (RPO) in minutes"
  type        = number
  default     = 15
}

# Security and Compliance
variable "enable_security_scanning" {
  description = "Enable security vulnerability scanning"
  type        = bool
  default     = true
}

variable "security_scan_schedule" {
  description = "Security scan schedule (cron format)"
  type        = string
  default     = "0 0 * * 0"
}

variable "compliance_frameworks" {
  description = "Compliance frameworks to adhere to"
  type        = list(string)
  default     = ["SOC2", "PCI-DSS", "HIPAA"]
}

variable "enable_audit_logging" {
  description = "Enable comprehensive audit logging"
  type        = bool
  default     = true
}

variable "audit_log_retention_days" {
  description = "Audit log retention in days"
  type        = number
  default     = 90
}

variable "enable_policy_as_code" {
  description = "Enable policy as code enforcement"
  type        = bool
  default     = true
}

variable "sentinel_policies" {
  description = "Sentinel policy configurations"
  type        = list(string)
  default     = []
}

variable "opa_policies" {
  description = "Open Policy Agent policy configurations"
  type        = list(string)
  default     = []
}

# Cost Management
variable "enable_cost_optimization" {
  description = "Enable automated cost optimization"
  type        = bool
  default     = true
}

variable "cost_optimization_schedule" {
  description = "Cost optimization schedule (cron format)"
  type        = string
  default     = "0 6 * * 1"
}

variable "enable_budget_alerts" {
  description = "Enable budget alerts"
  type        = bool
  default     = true
}

variable "monthly_budget_thresholds" {
  description = "Monthly budget thresholds for alerts"
  type = object({
    warning  = number
    critical = number
  })
  default = {
    warning  = 80
    critical = 95
  }
}

variable "budget_notification_emails" {
  description = "Email addresses for budget notifications"
  type        = list(string)
  default     = []
}

# SSL/TLS Configuration
variable "ssl_certificate_arn" {
  description = "SSL certificate ARN for HTTPS endpoints"
  type        = string
  default     = ""
}

variable "domain_name" {
  description = "Domain name for HashiCorp services"
  type        = string
  default     = "hashicorp.example.com"
}

variable "route53_zone_id" {
  description = "Route 53 hosted zone ID"
  type        = string
  default     = ""
}

# Advanced Configuration
variable "enable_advanced_monitoring" {
  description = "Enable advanced monitoring and observability"
  type        = bool
  default     = true
}

variable "enable_log_aggregation" {
  description = "Enable centralized log aggregation"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "Log retention in days"
  type        = number
  default     = 30
}

variable "enable_distributed_tracing" {
  description = "Enable distributed tracing with Jaeger"
  type        = bool
  default     = true
}

variable "custom_tags" {
  description = "Custom tags to apply to all resources"
  type        = map(string)
  default     = {}
}