# Variables for IBM OpenShift Container Platform deployment

# Project Configuration
variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "openshift-platform"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "prod"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

# AWS Configuration
variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS CLI profile to use"
  type        = string
  default     = "default"
}

# OpenShift Configuration
variable "openshift_version" {
  description = "OpenShift version to deploy"
  type        = string
  default     = "4.14.8"
}

variable "openshift_cluster_manager_token" {
  description = "Red Hat OpenShift Cluster Manager token"
  type        = string
  sensitive   = true
}

variable "rhcs_url" {
  description = "Red Hat Cloud Services API URL"
  type        = string
  default     = "https://api.openshift.com"
}

# Deployment Type Configuration
variable "deployment_type" {
  description = "Type of deployment (single-az, multi-az, private, fips)"
  type        = string
  default     = "multi-az"
  
  validation {
    condition     = contains(["single-az", "multi-az", "private", "fips"], var.deployment_type)
    error_message = "Deployment type must be one of: single-az, multi-az, private, fips."
  }
}

# Network Configuration
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
  
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid CIDR block."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  
  validation {
    condition     = length(var.public_subnet_cidrs) >= 1 && length(var.public_subnet_cidrs) <= 3
    error_message = "Must provide 1-3 public subnet CIDR blocks."
  }
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
  
  validation {
    condition     = length(var.private_subnet_cidrs) >= 1 && length(var.private_subnet_cidrs) <= 3
    error_message = "Must provide 1-3 private subnet CIDR blocks."
  }
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access the cluster"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# Machine Configuration
variable "compute_machine_type" {
  description = "Instance type for worker nodes"
  type        = string
  default     = "m5.2xlarge"
}

variable "compute_replicas" {
  description = "Number of worker nodes"
  type        = number
  default     = 3
  
  validation {
    condition     = var.compute_replicas >= 2 && var.compute_replicas <= 100
    error_message = "Worker node count must be between 2 and 100."
  }
}

# Additional Machine Pool Configuration
variable "enable_additional_machine_pool" {
  description = "Enable additional machine pool for specialized workloads"
  type        = bool
  default     = false
}

variable "additional_machine_type" {
  description = "Instance type for additional machine pool"
  type        = string
  default     = "m5.xlarge"
}

variable "additional_machine_replicas" {
  description = "Number of nodes in additional machine pool"
  type        = number
  default     = 2
}

# Auto-scaling Configuration
variable "enable_autoscaling" {
  description = "Enable cluster autoscaling"
  type        = bool
  default     = false
}

variable "min_replicas" {
  description = "Minimum number of worker nodes for autoscaling"
  type        = number
  default     = 2
}

variable "max_replicas" {
  description = "Maximum number of worker nodes for autoscaling"
  type        = number
  default     = 10
}

# Identity Provider Configuration
variable "identity_provider_type" {
  description = "Type of identity provider (htpasswd, openid, ldap)"
  type        = string
  default     = ""
  
  validation {
    condition     = contains(["", "htpasswd", "openid", "ldap"], var.identity_provider_type)
    error_message = "Identity provider type must be one of: htpasswd, openid, ldap, or empty string."
  }
}

variable "identity_provider_name" {
  description = "Name of the identity provider"
  type        = string
  default     = "cluster-auth"
}

# HTPasswd Identity Provider Configuration
variable "htpasswd_users" {
  description = "Map of htpasswd users and their password hashes"
  type        = map(string)
  default     = {}
  sensitive   = true
}

variable "create_cluster_admin" {
  description = "Create a cluster admin user"
  type        = bool
  default     = true
}

# OpenID Identity Provider Configuration
variable "openid_client_id" {
  description = "OpenID Connect client ID"
  type        = string
  default     = ""
  sensitive   = true
}

variable "openid_client_secret" {
  description = "OpenID Connect client secret"
  type        = string
  default     = ""
  sensitive   = true
}

variable "openid_issuer" {
  description = "OpenID Connect issuer URL"
  type        = string
  default     = ""
}

# Storage Configuration
variable "create_s3_storage" {
  description = "Create S3 bucket for cluster storage"
  type        = bool
  default     = true
}

variable "storage_class" {
  description = "Storage class for persistent volumes"
  type        = string
  default     = "gp3-csi"
}

# Load Balancer Configuration
variable "create_additional_alb" {
  description = "Create additional Application Load Balancer"
  type        = bool
  default     = false
}

# DNS Configuration
variable "manage_dns" {
  description = "Manage DNS records for the cluster"
  type        = bool
  default     = false
}

variable "cluster_domain" {
  description = "Domain name for the cluster"
  type        = string
  default     = "openshift.company.com"
}

variable "route53_zone_id" {
  description = "Route53 hosted zone ID (if manage_dns is false but using existing zone)"
  type        = string
  default     = ""
}

# Monitoring and Logging Configuration
variable "enable_cluster_monitoring" {
  description = "Enable cluster monitoring stack"
  type        = bool
  default     = true
}

variable "enable_user_workload_monitoring" {
  description = "Enable user workload monitoring"
  type        = bool
  default     = true
}

variable "monitoring_retention_days" {
  description = "Retention period for monitoring data in days"
  type        = number
  default     = 7
}

# Security Configuration
variable "enable_fips" {
  description = "Enable FIPS 140-2 compliance"
  type        = bool
  default     = false
}

variable "enable_etcd_encryption" {
  description = "Enable etcd encryption at rest"
  type        = bool
  default     = true
}

variable "kms_key_deletion_window" {
  description = "KMS key deletion window in days"
  type        = number
  default     = 7
  
  validation {
    condition     = var.kms_key_deletion_window >= 7 && var.kms_key_deletion_window <= 30
    error_message = "KMS key deletion window must be between 7 and 30 days."
  }
}

# Backup Configuration
variable "enable_cluster_backup" {
  description = "Enable cluster backup to S3"
  type        = bool
  default     = true
}

variable "backup_schedule" {
  description = "Cron schedule for cluster backups"
  type        = string
  default     = "0 2 * * *" # Daily at 2 AM
}

variable "backup_retention_days" {
  description = "Retention period for cluster backups in days"
  type        = number
  default     = 30
}

# Compliance Configuration
variable "compliance_scanning" {
  description = "Enable compliance scanning"
  type        = bool
  default     = false
}

variable "compliance_profiles" {
  description = "List of compliance profiles to apply"
  type        = list(string)
  default     = ["ocp4-cis", "ocp4-pci-dss"]
}

# Resource Limits
variable "cluster_resource_quota" {
  description = "Default resource quota for namespaces"
  type = object({
    requests_cpu      = string
    requests_memory   = string
    limits_cpu        = string
    limits_memory     = string
    persistentvolumeclaims = number
  })
  default = {
    requests_cpu      = "100m"
    requests_memory   = "128Mi"
    limits_cpu        = "200m"
    limits_memory     = "256Mi"
    persistentvolumeclaims = 5
  }
}

# Networking Configuration
variable "network_type" {
  description = "Network plugin type (OpenShiftSDN, OVNKubernetes)"
  type        = string
  default     = "OVNKubernetes"
  
  validation {
    condition     = contains(["OpenShiftSDN", "OVNKubernetes"], var.network_type)
    error_message = "Network type must be either OpenShiftSDN or OVNKubernetes."
  }
}

variable "service_cidr" {
  description = "CIDR block for services"
  type        = string
  default     = "172.30.0.0/16"
}

variable "pod_cidr" {
  description = "CIDR block for pods"
  type        = string
  default     = "10.128.0.0/14"
}

variable "host_prefix" {
  description = "Host prefix for pod network"
  type        = number
  default     = 23
  
  validation {
    condition     = var.host_prefix >= 16 && var.host_prefix <= 32
    error_message = "Host prefix must be between 16 and 32."
  }
}

# Additional Configuration
variable "additional_trust_bundle" {
  description = "Additional CA trust bundle"
  type        = string
  default     = ""
}

variable "cluster_network_mtu" {
  description = "MTU for cluster network"
  type        = number
  default     = 1450
}

variable "disable_user_workload_monitoring" {
  description = "Disable user workload monitoring"
  type        = bool
  default     = false
}

variable "enable_proxy" {
  description = "Enable HTTP/HTTPS proxy configuration"
  type        = bool
  default     = false
}

variable "http_proxy" {
  description = "HTTP proxy URL"
  type        = string
  default     = ""
}

variable "https_proxy" {
  description = "HTTPS proxy URL"
  type        = string
  default     = ""
}

variable "no_proxy" {
  description = "Comma-separated list of destinations excluded from proxying"
  type        = string
  default     = ""
}