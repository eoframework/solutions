# Disaster Recovery Environment Outputs
# Direct outputs from infrastructure modules

output "project_name" {
  description = "Name of the project"
  value       = var.project_name
}

output "environment" {
  description = "Environment name"
  value       = "disaster-recovery"
}

output "aws_infrastructure" {
  description = "AWS infrastructure outputs"
  value       = var.enable_aws_resources ? module.aws_infrastructure[0] : null
}

output "azure_infrastructure" {
  description = "Azure infrastructure outputs"
  value       = var.enable_azure_resources ? module.azure_infrastructure[0] : null
}

output "gcp_infrastructure" {
  description = "GCP infrastructure outputs"
  value       = var.enable_gcp_resources ? module.gcp_infrastructure[0] : null
}

output "monitoring" {
  description = "Monitoring configuration from active providers"
  value = {
    aws   = var.enable_aws_resources ? module.aws_infrastructure[0].monitoring : null
    azure = var.enable_azure_resources ? module.azure_infrastructure[0].monitoring : null
    gcp   = var.enable_gcp_resources ? module.gcp_infrastructure[0].monitoring : null
  }
}

output "deployment_summary" {
  description = "Disaster recovery deployment summary"
  value = {
    project_name        = var.project_name
    environment         = "disaster-recovery"
    enabled_providers   = [
      var.enable_aws_resources ? "aws" : null,
      var.enable_azure_resources ? "azure" : null,
      var.enable_gcp_resources ? "gcp" : null
    ]
    aws_region         = var.enable_aws_resources ? var.aws_region : null
    azure_location     = var.enable_azure_resources ? var.azure_location : null
    gcp_region         = var.enable_gcp_resources ? var.gcp_region : null
    deployment_time    = timestamp()
  }
}

output "dr_configuration" {
  description = "Disaster recovery specific configuration"
  value = {
    rto = var.recovery_time_objective
    rpo = var.recovery_point_objective
  }
}