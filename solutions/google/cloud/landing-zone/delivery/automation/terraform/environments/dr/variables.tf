#------------------------------------------------------------------------------
# GCP Landing Zone Production Variables
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Solution Identity
#------------------------------------------------------------------------------
variable "solution" {
  description = "Solution identification object"
  type = object({
    name          = string
    abbr          = string
    provider_name = string
    category_name = string
  })
}

variable "gcp" {
  description = "GCP project and region configuration"
  type = object({
    project_id = string
    region     = string
    dr_region  = string
    zone       = string
  })
}

variable "ownership" {
  description = "Ownership and billing information"
  type = object({
    cost_center  = string
    owner_email  = string
    project_code = string
  })
}

#------------------------------------------------------------------------------
# Organization
#------------------------------------------------------------------------------
variable "organization" {
  description = "GCP Organization configuration"
  type = object({
    org_id             = string
    domain             = string
    billing_account_id = string
    display_name       = string
  })
}

#------------------------------------------------------------------------------
# Folders
#------------------------------------------------------------------------------
variable "folders" {
  description = "Folder hierarchy configuration"
  type = object({
    dev_display_name     = string
    staging_display_name = string
    prod_display_name    = string
    shared_display_name  = string
    sandbox_display_name = string
  })
}

#------------------------------------------------------------------------------
# Projects
#------------------------------------------------------------------------------
variable "projects" {
  description = "Project configuration"
  type = object({
    host_project_name       = string
    logging_project_name    = string
    security_project_name   = string
    monitoring_project_name = string
    initial_count           = number
    team_count              = number
  })
}

#------------------------------------------------------------------------------
# Network
#------------------------------------------------------------------------------
variable "network" {
  description = "Network configuration"
  type = object({
    vpc_name                      = string
    vpc_routing_mode              = string
    subnet_dev_cidr               = string
    subnet_staging_cidr           = string
    subnet_prod_cidr              = string
    subnet_shared_cidr            = string
    enable_private_google_access  = bool
    enable_flow_logs              = bool
    flow_log_sampling             = number
    flow_log_aggregation_interval = string
  })
}

variable "interconnect" {
  description = "Interconnect configuration"
  type = object({
    type          = string
    bandwidth     = string
    location      = string
    vlan_count    = number
    bgp_asn_gcp   = number
    bgp_asn_onprem = string
    enabled       = bool
  })
}

variable "nat" {
  description = "Cloud NAT configuration"
  type = object({
    enabled          = bool
    gateway_count    = number
    logging_enabled  = bool
    min_ports_per_vm = number
    cloud_router_asn = number
  })
  default = {
    enabled          = true
    gateway_count    = 3
    logging_enabled  = true
    min_ports_per_vm = 64
    cloud_router_asn = 64514
  }
}

#------------------------------------------------------------------------------
# Identity
#------------------------------------------------------------------------------
variable "identity" {
  description = "Identity configuration"
  type = object({
    cloud_identity_license   = string
    saml_sso_enabled         = bool
    idp_type                 = string
    mfa_enforcement          = string
    admin_count              = number
    directory_sync_enabled   = bool
  })
}

#------------------------------------------------------------------------------
# Security
#------------------------------------------------------------------------------
variable "security" {
  description = "Security configuration"
  type = object({
    scc_tier                  = string
    scc_asset_discovery       = bool
    chronicle_enabled         = bool
    chronicle_ingestion_volume = string
    chronicle_retention       = string
    cloud_armor_enabled       = bool
    cloud_ids_enabled         = bool
    cloud_ids_endpoints       = number
  })
}

variable "org_policy" {
  description = "Organization policy configuration"
  type = object({
    allowed_locations          = list(string)
    external_ip_policy         = string
    sa_key_creation            = string
    require_shielded_vm        = bool
    disable_serial_port_access = bool
    policy_count               = number
  })
}

#------------------------------------------------------------------------------
# Encryption
#------------------------------------------------------------------------------
variable "kms" {
  description = "Cloud KMS configuration"
  type = object({
    keyring_name      = string
    keyring_location  = string
    key_count         = number
    key_rotation_days = number
    key_algorithm     = string
    protection_level  = string
  })
  default = {
    keyring_name      = "landing-zone-keyring"
    keyring_location  = "us"
    key_count         = 6
    key_rotation_days = 90
    key_algorithm     = "GOOGLE_SYMMETRIC_ENCRYPTION"
    protection_level  = "SOFTWARE"
  }
}

#------------------------------------------------------------------------------
# Logging
#------------------------------------------------------------------------------
variable "logging" {
  description = "Logging configuration"
  type = object({
    sink_type                = string
    retention_days           = number
    bigquery_retention_years = number
    volume_gb_month          = number
    enable_audit_logs        = bool
    enable_data_access_logs  = bool
  })
}

#------------------------------------------------------------------------------
# Monitoring
#------------------------------------------------------------------------------
variable "monitoring" {
  description = "Monitoring configuration"
  type = object({
    dashboard_count        = number
    alert_policy_count     = number
    notification_channels  = list(string)
    uptime_check_enabled   = bool
    log_based_metrics      = bool
  })
}

#------------------------------------------------------------------------------
# Budget
#------------------------------------------------------------------------------
variable "budget" {
  description = "Budget configuration"
  type = object({
    enabled            = bool
    monthly_amount     = number
    alert_thresholds   = list(number)
    currency           = string
    notification_email = string
  })
}

#------------------------------------------------------------------------------
# Automation
#------------------------------------------------------------------------------
variable "automation" {
  description = "Automation configuration"
  type = object({
    terraform_version           = string
    state_bucket_name           = string
    state_bucket_location       = string
    project_provisioning_target = string
  })
}

#------------------------------------------------------------------------------
# DR
#------------------------------------------------------------------------------
variable "dr" {
  description = "Disaster recovery configuration"
  type = object({
    enabled                  = bool
    strategy                 = string
    rto_minutes              = number
    rpo_minutes              = number
    failover_mode            = string
    cross_region_replication = bool
  })
}
