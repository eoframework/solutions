#------------------------------------------------------------------------------
# Consul Cluster Module Variables
#------------------------------------------------------------------------------

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
}

variable "eks_cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  type        = string
}

variable "consul" {
  description = "Consul configuration"
  type = object({
    enabled               = bool
    helm_chart_version    = string
    namespace             = string
    create_namespace      = bool
    datacenter            = string
    server_replicas       = number
    server_storage_size   = number
    server_memory_request = string
    server_cpu_request    = string
    server_memory_limit   = string
    server_cpu_limit      = string
    enable_acls           = bool
    bootstrap_token       = string
    enable_connect_inject = bool
    connect_inject_default = bool
    enable_controller     = bool
    enable_ui             = bool
    enable_metrics        = bool
  })
}
