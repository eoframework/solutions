#==============================================================================
# OpenShift Container Platform - DR Environment Variables
#==============================================================================
# Identical structure to production for consistency.
# Values differ per environment via tfvars files.
#==============================================================================

variable "aws_region" {
  description = "AWS region for DR deployment (different from prod)"
  type        = string
  default     = "us-west-2"  # Different region for DR
}

variable "solution" {
  description = "Solution metadata"
  type = object({
    name          = string
    abbr          = string
    provider_name = string
    category_name = string
  })
}

variable "cluster" {
  description = "OpenShift cluster configuration"
  type = object({
    name         = string
    base_domain  = string
    version      = string
    api_endpoint = string
    console_url  = string
    install_type = string
    platform     = string
  })
}

variable "compute" {
  description = "Compute resources configuration"
  type = object({
    control_plane_count         = number
    control_plane_cpu           = number
    control_plane_memory_gb     = number
    control_plane_instance_type = string
    worker_count                = number
    worker_cpu                  = number
    worker_memory_gb            = number
    worker_instance_type        = string
    rhcos_ami                   = string
    key_name                    = string
  })
}

variable "network" {
  description = "Network configuration"
  type = object({
    type               = string
    pod_cidr           = string
    service_cidr       = string
    cluster_mtu        = number
    vpc_cidr           = string
    public_subnets     = list(string)
    private_subnets    = list(string)
    availability_zones = list(string)
  })
}

variable "storage" {
  description = "Storage configuration"
  type = object({
    odf_enabled   = bool
    odf_capacity_tb = number
    class_block   = string
    class_file    = string
    default_class = string
  })
}

variable "auth" {
  description = "Authentication configuration"
  type = object({
    ldap_enabled          = bool
    ldap_url              = string
    ldap_bind_dn          = string
    ldap_user_search_base = string
    ldap_group_search_base = string
    oauth_timeout_seconds = number
    htpasswd_backup_enabled = bool
  })
}

variable "monitoring" {
  description = "Monitoring configuration"
  type = object({
    prometheus_enabled        = bool
    prometheus_retention_days = number
    alertmanager_target       = string
    grafana_enabled           = bool
  })
}

variable "logging" {
  description = "Logging configuration"
  type = object({
    efk_enabled             = bool
    retention_days          = number
    elasticsearch_storage_gb = number
    elasticsearch_replicas  = number
  })
}

variable "registry" {
  description = "Container registry configuration"
  type = object({
    quay_enabled              = bool
    quay_hostname             = string
    quay_storage_gb           = number
    internal_registry_replicas = number
  })
}

variable "gitops" {
  description = "GitOps configuration"
  type = object({
    argocd_enabled  = bool
    argocd_repo_url = string
    argocd_replicas = number
  })
}

variable "pipelines" {
  description = "CI/CD pipelines configuration"
  type = object({
    tekton_enabled          = bool
    default_service_account = string
    timeout_hours           = number
  })
}

variable "servicemesh" {
  description = "Service mesh configuration"
  type = object({
    istio_enabled         = bool
    mtls_mode             = string
    tracing_enabled       = bool
    tracing_sampling_rate = number
  })
}

variable "security" {
  description = "Security configuration"
  type = object({
    pod_security_admission   = string
    network_policies_enabled = bool
    image_scanning_enabled   = bool
    acs_enabled              = bool
    allowed_api_cidrs        = list(string)
    kms_key_arn              = string
  })
  default = {
    pod_security_admission   = "restricted"
    network_policies_enabled = true
    image_scanning_enabled   = true
    acs_enabled              = true
    allowed_api_cidrs        = ["0.0.0.0/0"]
    kms_key_arn              = null
  }
}

variable "backup" {
  description = "Backup configuration"
  type = object({
    enabled        = bool
    schedule_cron  = string
    retention_days = number
    s3_bucket      = string
  })
}

variable "dr" {
  description = "Disaster recovery configuration"
  type = object({
    enabled             = bool
    strategy            = string
    rto_hours           = number
    rpo_hours           = number
    replication_enabled = bool
    replica_region      = optional(string, "us-west-2")
  })
}

variable "ownership" {
  description = "Resource ownership metadata"
  type = object({
    cost_center  = string
    owner_email  = string
    project_code = string
  })
}

variable "budget" {
  description = "Budget configuration"
  type = object({
    enabled           = bool
    monthly_amount_usd = number
    alert_thresholds  = list(number)
  })
}
