#------------------------------------------------------------------------------
# Azure Kubernetes Service Module - Variables
#------------------------------------------------------------------------------

variable "name" {
  description = "AKS cluster name"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "dns_prefix" {
  description = "DNS prefix"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = null
}

variable "sku_tier" {
  description = "SKU tier (Free or Standard)"
  type        = string
  default     = "Free"
}

variable "automatic_channel_upgrade" {
  description = "Automatic channel upgrade (patch, rapid, node-image, stable, none)"
  type        = string
  default     = "stable"
}

variable "node_resource_group" {
  description = "Node resource group name"
  type        = string
  default     = null
}

variable "private_cluster_enabled" {
  description = "Enable private cluster"
  type        = bool
  default     = false
}

variable "private_dns_zone_id" {
  description = "Private DNS zone ID"
  type        = string
  default     = null
}

variable "workload_identity_enabled" {
  description = "Enable workload identity"
  type        = bool
  default     = false
}

variable "oidc_issuer_enabled" {
  description = "Enable OIDC issuer"
  type        = bool
  default     = false
}

variable "azure_policy_enabled" {
  description = "Enable Azure Policy"
  type        = bool
  default     = false
}

variable "http_application_routing_enabled" {
  description = "Enable HTTP application routing"
  type        = bool
  default     = false
}

#------------------------------------------------------------------------------
# Default Node Pool
#------------------------------------------------------------------------------
variable "default_node_pool" {
  description = "Default node pool configuration"
  type = object({
    name                         = string
    vm_size                      = string
    vnet_subnet_id               = string
    node_count                   = optional(number)
    enable_auto_scaling          = optional(bool, false)
    min_count                    = optional(number)
    max_count                    = optional(number)
    max_pods                     = optional(number)
    os_disk_size_gb              = optional(number)
    os_disk_type                 = optional(string, "Managed")
    zones                        = optional(list(string))
    enable_node_public_ip        = optional(bool, false)
    node_labels                  = optional(map(string), {})
    node_taints                  = optional(list(string), [])
    only_critical_addons_enabled = optional(bool, false)
    max_surge                    = optional(string, "10%")
  })
}

#------------------------------------------------------------------------------
# Additional Node Pools
#------------------------------------------------------------------------------
variable "node_pools" {
  description = "Additional node pools"
  type = map(object({
    vm_size               = string
    node_count            = optional(number)
    enable_auto_scaling   = optional(bool, false)
    min_count             = optional(number)
    max_count             = optional(number)
    max_pods              = optional(number)
    os_disk_size_gb       = optional(number)
    os_disk_type          = optional(string, "Managed")
    os_type               = optional(string, "Linux")
    vnet_subnet_id        = optional(string)
    zones                 = optional(list(string))
    enable_node_public_ip = optional(bool, false)
    node_labels           = optional(map(string), {})
    node_taints           = optional(list(string), [])
    priority              = optional(string, "Regular")
    eviction_policy       = optional(string)
    spot_max_price        = optional(number)
    mode                  = optional(string, "User")
    max_surge             = optional(string, "10%")
  }))
  default = {}
}

#------------------------------------------------------------------------------
# Identity
#------------------------------------------------------------------------------
variable "identity_type" {
  description = "Identity type (SystemAssigned or UserAssigned)"
  type        = string
  default     = "SystemAssigned"
}

variable "identity_ids" {
  description = "User assigned identity IDs"
  type        = list(string)
  default     = null
}

#------------------------------------------------------------------------------
# Network Profile
#------------------------------------------------------------------------------
variable "network_plugin" {
  description = "Network plugin (azure, kubenet, or none)"
  type        = string
  default     = "azure"
}

variable "network_policy" {
  description = "Network policy (azure or calico)"
  type        = string
  default     = null
}

variable "dns_service_ip" {
  description = "DNS service IP"
  type        = string
  default     = null
}

variable "service_cidr" {
  description = "Service CIDR"
  type        = string
  default     = null
}

variable "load_balancer_sku" {
  description = "Load balancer SKU (basic or standard)"
  type        = string
  default     = "standard"
}

variable "outbound_type" {
  description = "Outbound type (loadBalancer, userDefinedRouting, managedNATGateway, userAssignedNATGateway)"
  type        = string
  default     = "loadBalancer"
}

variable "load_balancer_profile" {
  description = "Load balancer profile"
  type = object({
    managed_outbound_ip_count = optional(number)
    outbound_ip_address_ids   = optional(list(string))
    outbound_ip_prefix_ids    = optional(list(string))
    outbound_ports_allocated  = optional(number)
    idle_timeout_in_minutes   = optional(number)
  })
  default = null
}

#------------------------------------------------------------------------------
# Azure AD RBAC
#------------------------------------------------------------------------------
variable "azure_ad_rbac_enabled" {
  description = "Enable Azure AD RBAC"
  type        = bool
  default     = false
}

variable "azure_ad_rbac_managed" {
  description = "Managed Azure AD RBAC"
  type        = bool
  default     = true
}

variable "azure_ad_tenant_id" {
  description = "Azure AD tenant ID"
  type        = string
  default     = null
}

variable "azure_ad_admin_group_object_ids" {
  description = "Azure AD admin group object IDs"
  type        = list(string)
  default     = []
}

variable "azure_rbac_enabled" {
  description = "Enable Azure RBAC for Kubernetes authorization"
  type        = bool
  default     = false
}

#------------------------------------------------------------------------------
# Monitoring
#------------------------------------------------------------------------------
variable "oms_agent_enabled" {
  description = "Enable OMS agent"
  type        = bool
  default     = false
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID"
  type        = string
  default     = null
}

#------------------------------------------------------------------------------
# Key Vault Secrets Provider
#------------------------------------------------------------------------------
variable "key_vault_secrets_provider_enabled" {
  description = "Enable Key Vault secrets provider"
  type        = bool
  default     = false
}

variable "secret_rotation_enabled" {
  description = "Enable secret rotation"
  type        = bool
  default     = true
}

variable "secret_rotation_interval" {
  description = "Secret rotation interval"
  type        = string
  default     = "2m"
}

#------------------------------------------------------------------------------
# Maintenance Window
#------------------------------------------------------------------------------
variable "maintenance_window" {
  description = "Maintenance window configuration"
  type = object({
    allowed = list(object({
      day   = string
      hours = list(number)
    }))
    not_allowed = optional(list(object({
      start = string
      end   = string
    })), [])
  })
  default = null
}

#------------------------------------------------------------------------------
# Auto Scaler Profile
#------------------------------------------------------------------------------
variable "auto_scaler_profile" {
  description = "Auto scaler profile"
  type = object({
    balance_similar_node_groups      = optional(bool, false)
    expander                         = optional(string, "random")
    max_graceful_termination_sec     = optional(number, 600)
    max_node_provisioning_time       = optional(string, "15m")
    max_unready_nodes                = optional(number, 3)
    max_unready_percentage           = optional(number, 45)
    new_pod_scale_up_delay           = optional(string, "10s")
    scale_down_delay_after_add       = optional(string, "10m")
    scale_down_delay_after_delete    = optional(string, "10s")
    scale_down_delay_after_failure   = optional(string, "3m")
    scan_interval                    = optional(string, "10s")
    scale_down_unneeded              = optional(string, "10m")
    scale_down_unready               = optional(string, "20m")
    scale_down_utilization_threshold = optional(number, 0.5)
    empty_bulk_delete_max            = optional(number, 10)
    skip_nodes_with_local_storage    = optional(bool, true)
    skip_nodes_with_system_pods      = optional(bool, true)
  })
  default = null
}

#------------------------------------------------------------------------------
# Tags
#------------------------------------------------------------------------------
variable "common_tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
