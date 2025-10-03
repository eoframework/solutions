# Azure Module Variables
# Variables specific to Azure provider resources

# Core Configuration
variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "name_prefix" {
  description = "Naming prefix for resources"
  type        = string
}

variable "location" {
  description = "Azure location"
  type        = string
}

variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
  default     = null
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# Networking Variables
variable "vnet_cidr" {
  description = "CIDR block for the Virtual Network"
  type        = string
  default     = "10.1.0.0/16"
}

variable "subnet_cidrs" {
  description = "CIDR blocks for subnets"
  type = map(string)
  default = {
    web  = "10.1.1.0/24"
    app  = "10.1.2.0/24"
    data = "10.1.3.0/24"
    mgmt = "10.1.4.0/24"
  }
}

variable "enable_ddos_protection" {
  description = "Enable DDoS Protection Standard"
  type        = bool
  default     = false
}

# Security Variables
variable "network_security_groups" {
  description = "Network Security Group configurations"
  type = map(object({
    rules = list(object({
      name                       = string
      priority                   = number
      direction                  = string
      access                     = string
      protocol                   = string
      source_port_range          = string
      destination_port_range     = string
      source_address_prefix      = string
      destination_address_prefix = string
    }))
  }))
  default = {}
}

variable "enable_key_vault" {
  description = "Enable Azure Key Vault"
  type        = bool
  default     = true
}

# Compute Variables
variable "vms" {
  description = "Virtual Machine configurations"
  type = map(object({
    size                            = string
    admin_username                  = string
    disable_password_authentication = bool
    os_disk_caching                = string
    os_disk_storage_account_type   = string
    source_image_reference = object({
      publisher = string
      offer     = string
      sku       = string
      version   = string
    })
  }))
  default = {}
}

variable "sql_config" {
  description = "Azure SQL Database configuration"
  type = object({
    sku_name                     = string
    max_size_gb                  = number
    auto_pause_delay_in_minutes  = number
    min_capacity                 = number
    max_capacity                 = number
    zone_redundant               = bool
  })
  default = {
    sku_name                     = "S1"
    max_size_gb                  = 32
    auto_pause_delay_in_minutes  = -1
    min_capacity                 = 0.5
    max_capacity                 = 2
    zone_redundant               = false
  }
}

# Scale Set Variables
variable "enable_scale_set" {
  description = "Enable Virtual Machine Scale Set"
  type        = bool
  default     = false
}

variable "scale_set_config" {
  description = "Virtual Machine Scale Set configuration"
  type = object({
    sku                = string
    instances          = number
    admin_username     = string
    source_image_reference = object({
      publisher = string
      offer     = string
      sku       = string
      version   = string
    })
    os_disk = object({
      storage_account_type = string
      caching              = string
    })
    automatic_os_upgrade_policy = object({
      disable_automatic_rollback  = bool
      enable_automatic_os_upgrade = bool
    })
    rolling_upgrade_policy = object({
      max_batch_instance_percent             = number
      max_unhealthy_instance_percent         = number
      max_unhealthy_upgraded_instance_percent = number
      pause_time_between_batches             = string
    })
  })
  default = {
    sku                = "Standard_D2s_v3"
    instances          = 2
    admin_username     = "azureadmin"
    source_image_reference = {
      publisher = "Canonical"
      offer     = "0001-com-ubuntu-server-focal"
      sku       = "20_04-lts-gen2"
      version   = "latest"
    }
    os_disk = {
      storage_account_type = "Standard_LRS"
      caching              = "ReadWrite"
    }
    automatic_os_upgrade_policy = {
      disable_automatic_rollback  = false
      enable_automatic_os_upgrade = true
    }
    rolling_upgrade_policy = {
      max_batch_instance_percent             = 20
      max_unhealthy_instance_percent         = 20
      max_unhealthy_upgraded_instance_percent = 5
      pause_time_between_batches             = "PT0S"
    }
  }
}

# Load Balancer Variables
variable "enable_load_balancer" {
  description = "Enable load balancer"
  type        = bool
  default     = false
}

variable "load_balancer_config" {
  description = "Load balancer configuration"
  type = object({
    type = string # Basic, Standard
    sku  = string # Basic, Standard, Gateway
  })
  default = {
    type = "Standard"
    sku  = "Standard"
  }
}