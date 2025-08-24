# HashiCorp Multi-Cloud Infrastructure Management Platform - Outputs
# This file defines all output values from the multi-cloud platform deployment

# Project Information
output "project_name" {
  description = "Name of the deployed project"
  value       = var.project_name
}

output "environment" {
  description = "Environment name"
  value       = var.environment
}

output "deployment_timestamp" {
  description = "Deployment timestamp"
  value       = timestamp()
}

# AWS Infrastructure Outputs
output "aws_infrastructure" {
  description = "AWS infrastructure details"
  value = var.enable_terraform_enterprise ? {
    primary_region   = local.aws_regions.primary
    secondary_region = local.aws_regions.secondary
    vpc_ids          = module.aws_infrastructure.vpc_ids
    subnet_ids       = module.aws_infrastructure.subnet_ids
    security_groups  = module.aws_infrastructure.security_group_ids
    load_balancers   = module.aws_infrastructure.load_balancer_arns
    kms_keys        = module.aws_infrastructure.kms_key_ids
  } : {}
}

output "aws_consul_endpoints" {
  description = "AWS Consul cluster endpoints"
  value       = var.enable_consul ? module.aws_infrastructure.consul_endpoints : []
  sensitive   = true
}

output "aws_vault_endpoints" {
  description = "AWS Vault cluster endpoints"
  value       = var.enable_vault ? module.aws_infrastructure.vault_endpoints : []
  sensitive   = true
}

output "aws_nomad_endpoints" {
  description = "AWS Nomad cluster endpoints"
  value       = var.enable_nomad ? module.aws_infrastructure.nomad_endpoints : []
  sensitive   = true
}

output "aws_boundary_endpoints" {
  description = "AWS Boundary endpoints"
  value       = var.enable_boundary ? module.aws_infrastructure.boundary_workers : []
  sensitive   = true
}

# Azure Infrastructure Outputs
output "azure_infrastructure" {
  description = "Azure infrastructure details"
  value = {
    resource_group_name = var.azure_resource_group_name
    primary_region     = local.azure_regions.primary
    vnet_ids          = module.azure_infrastructure.vnet_ids
    subnet_ids        = module.azure_infrastructure.subnet_ids
    security_groups   = module.azure_infrastructure.network_security_group_ids
    load_balancers    = module.azure_infrastructure.load_balancer_ids
    key_vault_ids     = module.azure_infrastructure.key_vault_ids
  }
}

output "azure_consul_endpoints" {
  description = "Azure Consul cluster endpoints"
  value       = var.enable_consul ? module.azure_infrastructure.consul_endpoints : []
  sensitive   = true
}

output "azure_vault_endpoints" {
  description = "Azure Vault cluster endpoints"
  value       = var.enable_vault ? module.azure_infrastructure.vault_endpoints : []
  sensitive   = true
}

output "azure_nomad_endpoints" {
  description = "Azure Nomad cluster endpoints"
  value       = var.enable_nomad ? module.azure_infrastructure.nomad_endpoints : []
  sensitive   = true
}

output "azure_boundary_endpoints" {
  description = "Azure Boundary endpoints"
  value       = var.enable_boundary ? module.azure_infrastructure.boundary_workers : []
  sensitive   = true
}

# Google Cloud Infrastructure Outputs
output "gcp_infrastructure" {
  description = "Google Cloud infrastructure details"
  value = {
    project_id       = var.gcp_project_id
    primary_region   = local.gcp_regions.primary
    secondary_region = local.gcp_regions.secondary
    vpc_names        = module.gcp_infrastructure.vpc_names
    subnet_names     = module.gcp_infrastructure.subnet_names
    firewall_rules   = module.gcp_infrastructure.firewall_rule_names
    load_balancers   = module.gcp_infrastructure.load_balancer_names
    kms_keys        = module.gcp_infrastructure.kms_key_ids
  }
}

output "gcp_consul_endpoints" {
  description = "GCP Consul cluster endpoints"
  value       = var.enable_consul ? module.gcp_infrastructure.consul_endpoints : []
  sensitive   = true
}

output "gcp_vault_endpoints" {
  description = "GCP Vault cluster endpoints"
  value       = var.enable_vault ? module.gcp_infrastructure.vault_endpoints : []
  sensitive   = true
}

output "gcp_nomad_endpoints" {
  description = "GCP Nomad cluster endpoints"
  value       = var.enable_nomad ? module.gcp_infrastructure.nomad_endpoints : []
  sensitive   = true
}

output "gcp_boundary_endpoints" {
  description = "GCP Boundary endpoints"
  value       = var.enable_boundary ? module.gcp_infrastructure.boundary_workers : []
  sensitive   = true
}

# HashiCorp Products Outputs
output "consul_cluster" {
  description = "Consul cluster information"
  value = var.enable_consul ? {
    datacenter          = var.consul_datacenter
    ui_url             = module.consul_cluster[0].ui_url
    api_endpoints      = module.consul_cluster[0].api_endpoints
    federation_enabled = var.enable_consul_federation
    connect_enabled    = var.consul_connect_enabled
    acl_enabled        = var.consul_acl_enabled
    cluster_endpoints  = module.consul_cluster[0].cluster_endpoints
    ca_cert            = module.consul_cluster[0].ca_certificate
  } : {}
  sensitive = true
}

output "vault_cluster" {
  description = "Vault cluster information"
  value = var.enable_vault ? {
    ui_url                    = module.vault_cluster[0].ui_url
    api_endpoints            = module.vault_cluster[0].api_endpoints
    performance_replication  = var.enable_vault_replication
    primary_cluster         = var.vault_primary_cluster
    storage_backend         = var.vault_storage_backend
    cluster_endpoints       = module.vault_cluster[0].cluster_endpoints
    root_token             = module.vault_cluster[0].root_token
    unseal_keys            = module.vault_cluster[0].unseal_keys
  } : {}
  sensitive = true
}

output "nomad_cluster" {
  description = "Nomad cluster information"
  value = var.enable_nomad ? {
    datacenter         = var.nomad_datacenter
    region            = var.nomad_region
    ui_url            = module.nomad_cluster[0].ui_url
    api_endpoints     = module.nomad_cluster[0].api_endpoints
    federation_enabled = var.enable_nomad_federation
    acl_enabled       = var.nomad_acl_enabled
    cluster_endpoints = module.nomad_cluster[0].cluster_endpoints
    bootstrap_token   = module.nomad_cluster[0].bootstrap_token
  } : {}
  sensitive = true
}

output "boundary_cluster" {
  description = "Boundary cluster information"
  value = var.enable_boundary ? {
    ui_url            = module.boundary_cluster[0].ui_url
    api_endpoints     = module.boundary_cluster[0].api_endpoints
    worker_endpoints  = module.boundary_cluster[0].worker_endpoints
    auth_methods     = module.boundary_cluster[0].auth_methods
    admin_login_name = module.boundary_cluster[0].admin_login_name
    admin_password   = module.boundary_cluster[0].admin_password
  } : {}
  sensitive = true
}

# Service Mesh Outputs
output "service_mesh" {
  description = "Service mesh configuration and endpoints"
  value = var.enable_consul && var.consul_connect_enabled ? {
    mesh_gateways         = module.service_mesh[0].mesh_gateway_endpoints
    cross_cloud_enabled   = var.enable_cross_cloud_service_mesh
    ca_provider          = var.consul_connect_ca_provider
    service_intentions   = module.service_mesh[0].service_intentions
    sidecar_services     = module.service_mesh[0].sidecar_services
  } : {}
}

# Cross-Cloud Networking Outputs
output "cross_cloud_networking" {
  description = "Cross-cloud networking configuration"
  value = {
    vpn_connections      = module.cross_cloud_networking.vpn_connection_ids
    transit_gateway_id   = var.enable_aws_transit_gateway ? module.cross_cloud_networking.transit_gateway_id : null
    peering_connections  = module.cross_cloud_networking.peering_connection_ids
    routing_tables       = module.cross_cloud_networking.routing_table_ids
    network_acls        = module.cross_cloud_networking.network_acl_ids
  }
}

# Monitoring Outputs
output "monitoring" {
  description = "Monitoring and observability endpoints"
  value = {
    prometheus_endpoints = module.monitoring.prometheus_endpoints
    grafana_url         = module.monitoring.grafana_url
    grafana_admin_user  = module.monitoring.grafana_admin_user
    alertmanager_url    = module.monitoring.alertmanager_url
    jaeger_ui_url       = module.monitoring.jaeger_ui_url
    elasticsearch_endpoint = module.monitoring.elasticsearch_endpoint
    kibana_url          = module.monitoring.kibana_url
    metrics_endpoints   = {
      consul = var.enable_consul ? module.consul_cluster[0].metrics_endpoints : []
      vault  = var.enable_vault ? module.vault_cluster[0].metrics_endpoints : []
      nomad  = var.enable_nomad ? module.nomad_cluster[0].metrics_endpoints : []
    }
  }
  sensitive = true
}

# Security and Compliance Outputs
output "security_compliance" {
  description = "Security and compliance configuration"
  value = {
    compliance_frameworks = var.compliance_frameworks
    audit_logging_enabled = var.enable_audit_logging
    security_scanning     = var.enable_security_scanning
    policy_as_code       = var.enable_policy_as_code
    audit_log_buckets    = module.security_compliance.audit_log_buckets
    security_scan_reports = module.security_compliance.security_scan_report_locations
    compliance_reports   = module.security_compliance.compliance_report_locations
  }
}

# Backup and Disaster Recovery Outputs
output "backup_disaster_recovery" {
  description = "Backup and disaster recovery configuration"
  value = {
    backup_enabled           = var.enable_automated_backups
    backup_schedule         = var.backup_schedule
    backup_retention_days   = var.backup_retention_days
    cross_cloud_backup      = var.enable_cross_cloud_backup
    disaster_recovery       = var.enable_disaster_recovery
    backup_locations        = module.backup_disaster_recovery.backup_locations
    dr_regions             = var.disaster_recovery_regions
    rto_minutes            = var.recovery_time_objective
    rpo_minutes            = var.recovery_point_objective
    backup_schedules       = module.backup_disaster_recovery.backup_schedules
  }
}

# Cost Management Outputs
output "cost_management" {
  description = "Cost management and optimization information"
  value = {
    cost_optimization_enabled = var.enable_cost_optimization
    budget_alerts_enabled     = var.enable_budget_alerts
    monthly_budget_thresholds = var.monthly_budget_thresholds
    cost_allocation_tags      = local.common_tags
    budget_notification_emails = var.budget_notification_emails
    cost_dashboards           = module.cost_management.cost_dashboard_urls
  }
}

# DNS and SSL Outputs
output "dns_ssl_configuration" {
  description = "DNS and SSL configuration"
  value = {
    domain_name         = var.domain_name
    route53_zone_id     = var.route53_zone_id
    ssl_certificate_arn = var.ssl_certificate_arn
    dns_records        = module.cross_cloud_networking.dns_records
  }
  sensitive = true
}

# Connection Information
output "connection_info" {
  description = "Connection information for HashiCorp products"
  value = {
    consul = var.enable_consul ? {
      ui_url      = module.consul_cluster[0].ui_url
      api_address = module.consul_cluster[0].api_endpoints[0]
      token       = module.consul_cluster[0].bootstrap_token
    } : {}
    vault = var.enable_vault ? {
      ui_url      = module.vault_cluster[0].ui_url
      api_address = module.vault_cluster[0].api_endpoints[0]
      root_token  = module.vault_cluster[0].root_token
    } : {}
    nomad = var.enable_nomad ? {
      ui_url      = module.nomad_cluster[0].ui_url
      api_address = module.nomad_cluster[0].api_endpoints[0]
      token       = module.nomad_cluster[0].bootstrap_token
    } : {}
    boundary = var.enable_boundary ? {
      ui_url         = module.boundary_cluster[0].ui_url
      api_address    = module.boundary_cluster[0].api_endpoints[0]
      admin_username = module.boundary_cluster[0].admin_login_name
      admin_password = module.boundary_cluster[0].admin_password
    } : {}
  }
  sensitive = true
}

# Platform Status and Health
output "platform_status" {
  description = "Overall platform status and health information"
  value = {
    deployment_complete = true
    enabled_products = {
      terraform_enterprise = var.enable_terraform_enterprise
      consul              = var.enable_consul
      vault               = var.enable_vault
      nomad               = var.enable_nomad
      boundary            = var.enable_boundary
    }
    cross_cloud_networking = var.enable_cross_cloud_vpn
    service_mesh_enabled   = var.enable_consul && var.consul_connect_enabled
    monitoring_enabled     = var.enable_advanced_monitoring
    backup_enabled         = var.enable_automated_backups
    disaster_recovery      = var.enable_disaster_recovery
    compliance_frameworks  = var.compliance_frameworks
  }
}

# Quick Start Information
output "quick_start_urls" {
  description = "Quick start URLs for accessing HashiCorp products"
  value = {
    consul_ui   = var.enable_consul ? module.consul_cluster[0].ui_url : "Not enabled"
    vault_ui    = var.enable_vault ? module.vault_cluster[0].ui_url : "Not enabled"
    nomad_ui    = var.enable_nomad ? module.nomad_cluster[0].ui_url : "Not enabled"
    boundary_ui = var.enable_boundary ? module.boundary_cluster[0].ui_url : "Not enabled"
    grafana     = module.monitoring.grafana_url
    prometheus  = module.monitoring.prometheus_endpoints[0]
  }
}

# Resource Summary
output "resource_summary" {
  description = "Summary of deployed resources across all clouds"
  value = {
    aws_resources = {
      vpcs             = length(module.aws_infrastructure.vpc_ids)
      subnets          = length(module.aws_infrastructure.subnet_ids)
      security_groups  = length(module.aws_infrastructure.security_group_ids)
      instances        = module.aws_infrastructure.instance_count
    }
    azure_resources = {
      resource_groups  = 1
      vnets           = length(module.azure_infrastructure.vnet_ids)
      subnets         = length(module.azure_infrastructure.subnet_ids)
      vms             = module.azure_infrastructure.vm_count
    }
    gcp_resources = {
      vpcs            = length(module.gcp_infrastructure.vpc_names)
      subnets         = length(module.gcp_infrastructure.subnet_names)
      instances       = module.gcp_infrastructure.instance_count
    }
    total_estimated_cost_monthly = module.cost_management.estimated_monthly_cost
  }
}