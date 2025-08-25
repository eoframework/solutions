# Terraform Variables for Juniper Mist AI Network Platform Deployment

# Required Variables

variable "mist_api_token" {
  description = "Mist Cloud API token for authentication"
  type        = string
  sensitive   = true
  
  validation {
    condition     = length(var.mist_api_token) > 0
    error_message = "Mist API token cannot be empty."
  }
}

variable "organization_name" {
  description = "Name of the Mist organization"
  type        = string
  
  validation {
    condition     = length(var.organization_name) > 0
    error_message = "Organization name cannot be empty."
  }
}

# Optional Provider Configuration

variable "mist_api_host" {
  description = "Mist API host URL"
  type        = string
  default     = "https://api.mist.com"
}

variable "environment" {
  description = "Environment name (e.g., production, staging, development)"
  type        = string
  default     = "production"
  
  validation {
    condition     = contains(["production", "staging", "development", "test"], var.environment)
    error_message = "Environment must be one of: production, staging, development, test."
  }
}

# Site Configuration

variable "sites" {
  description = "Map of sites to deploy"
  type = map(object({
    address      = string
    country_code = string
    timezone     = string
    latitude     = optional(number)
    longitude    = optional(number)
    
    # Site-specific feature flags
    rtls_enabled              = optional(bool, false)
    rtls_track_asset          = optional(bool, false)
    location_services_enabled = optional(bool, true)
    analytics_enabled         = optional(bool, true)
    engagement_enabled        = optional(bool, false)
    locate_unconnected_clients = optional(bool, false)
    mesh_enabled              = optional(bool, false)
    mesh_allow_dfs           = optional(bool, false)
    mesh_enable_crm          = optional(bool, false)
    
    # Auto upgrade settings
    auto_upgrade_enabled = optional(bool, true)
    auto_upgrade_version = optional(string, "")
    auto_upgrade_time    = optional(string, "02:00")
    auto_upgrade_day     = optional(string, "sun")
    
    # Device thresholds
    device_updown_threshold = optional(number, 0)
    keep_wlans_up_if_down  = optional(bool, false)
    
    # Access Points configuration
    access_points = optional(map(object({
      device_id        = string
      name            = string
      map_id          = optional(string)
      x_coordinate    = optional(number)
      y_coordinate    = optional(number)
      static_ip       = optional(string)
      static_netmask  = optional(string)
      static_gateway  = optional(string)
      led_brightness  = optional(number, 255)
      
      # Radio settings
      radio_24_enabled     = optional(bool, true)
      radio_24_disable_11b = optional(bool, false)
      radio_5_enabled      = optional(bool, true)
      radio_6_enabled      = optional(bool, false)
      
      # Additional features
      usb_enabled = optional(bool, false)
      usb_type    = optional(string, "")
      iot_enabled = optional(bool, false)
    })), {})
    
    # Switches configuration
    switches = optional(map(object({
      device_id   = string
      name        = string
      role        = optional(string, "access")
      port_config = optional(map(any), {})
    })), {})
  }))
  
  validation {
    condition     = length(var.sites) > 0
    error_message = "At least one site must be defined."
  }
}

# WLAN Configuration

variable "corporate_ssid" {
  description = "SSID name for corporate network"
  type        = string
  default     = "Corporate-WiFi"
  
  validation {
    condition     = length(var.corporate_ssid) > 0 && length(var.corporate_ssid) <= 32
    error_message = "Corporate SSID must be between 1 and 32 characters."
  }
}

variable "guest_ssid" {
  description = "SSID name for guest network"
  type        = string
  default     = "Guest-WiFi"
  
  validation {
    condition     = length(var.guest_ssid) > 0 && length(var.guest_ssid) <= 32
    error_message = "Guest SSID must be between 1 and 32 characters."
  }
}

variable "iot_ssid" {
  description = "SSID name for IoT network"
  type        = string
  default     = "IoT-Devices"
  
  validation {
    condition     = length(var.iot_ssid) > 0 && length(var.iot_ssid) <= 32
    error_message = "IoT SSID must be between 1 and 32 characters."
  }
}

variable "iot_psk" {
  description = "Pre-shared key for IoT network"
  type        = string
  sensitive   = true
  default     = ""
  
  validation {
    condition     = length(var.iot_psk) == 0 || (length(var.iot_psk) >= 8 && length(var.iot_psk) <= 63)
    error_message = "IoT PSK must be between 8 and 63 characters if specified."
  }
}

# VLAN Configuration

variable "corporate_vlan_id" {
  description = "VLAN ID for corporate network"
  type        = number
  default     = 100
  
  validation {
    condition     = var.corporate_vlan_id >= 1 && var.corporate_vlan_id <= 4094
    error_message = "Corporate VLAN ID must be between 1 and 4094."
  }
}

variable "guest_vlan_id" {
  description = "VLAN ID for guest network"
  type        = number
  default     = 200
  
  validation {
    condition     = var.guest_vlan_id >= 1 && var.guest_vlan_id <= 4094
    error_message = "Guest VLAN ID must be between 1 and 4094."
  }
}

variable "iot_vlan_id" {
  description = "VLAN ID for IoT network"
  type        = number
  default     = 400
  
  validation {
    condition     = var.iot_vlan_id >= 1 && var.iot_vlan_id <= 4094
    error_message = "IoT VLAN ID must be between 1 and 4094."
  }
}

# Network Configuration

variable "corporate_subnet" {
  description = "Subnet for corporate network"
  type        = string
  default     = "10.100.0.0/24"
  
  validation {
    condition     = can(cidrhost(var.corporate_subnet, 0))
    error_message = "Corporate subnet must be a valid CIDR block."
  }
}

variable "guest_subnet" {
  description = "Subnet for guest network"
  type        = string
  default     = "10.200.0.0/24"
  
  validation {
    condition     = can(cidrhost(var.guest_subnet, 0))
    error_message = "Guest subnet must be a valid CIDR block."
  }
}

variable "iot_subnet" {
  description = "Subnet for IoT network"
  type        = string
  default     = "10.400.0.0/24"
  
  validation {
    condition     = can(cidrhost(var.iot_subnet, 0))
    error_message = "IoT subnet must be a valid CIDR block."
  }
}

variable "corporate_gateway" {
  description = "Gateway IP for corporate network"
  type        = string
  default     = "10.100.0.1"
}

variable "guest_gateway" {
  description = "Gateway IP for guest network"
  type        = string
  default     = "10.200.0.1"
}

variable "iot_gateway" {
  description = "Gateway IP for IoT network"
  type        = string
  default     = "10.400.0.1"
}

variable "dhcp_servers" {
  description = "List of DHCP server IP addresses"
  type        = list(string)
  default     = ["10.1.1.10"]
  
  validation {
    condition     = length(var.dhcp_servers) > 0
    error_message = "At least one DHCP server must be specified."
  }
}

variable "dns_servers" {
  description = "List of DNS server IP addresses"
  type        = list(string)
  default     = ["8.8.8.8", "8.8.4.4"]
  
  validation {
    condition     = length(var.dns_servers) > 0
    error_message = "At least one DNS server must be specified."
  }
}

# RADIUS Configuration

variable "radius_auth_servers" {
  description = "RADIUS authentication servers configuration"
  type = list(object({
    host           = string
    port           = optional(number, 1812)
    secret         = string
    require_message_authenticator = optional(bool, false)
    keywrap_enabled = optional(bool, false)
    keywrap_format = optional(string, "hex")
    keywrap_kek    = optional(string, "")
    keywrap_mack   = optional(string, "")
  }))
  default = []
  sensitive = true
}

variable "radius_accounting_servers" {
  description = "RADIUS accounting servers configuration"
  type = list(object({
    host           = string
    port           = optional(number, 1813)
    secret         = string
    require_message_authenticator = optional(bool, false)
    keywrap_enabled = optional(bool, false)
    keywrap_format = optional(string, "hex")
    keywrap_kek    = optional(string, "")
    keywrap_mack   = optional(string, "")
  }))
  default = []
  sensitive = true
}

# Guest Portal Configuration

variable "guest_portal_forward_url" {
  description = "URL to redirect guests after successful authentication"
  type        = string
  default     = "https://www.company.com"
}

variable "guest_portal_privacy_url" {
  description = "Privacy policy URL for guest portal"
  type        = string
  default     = "https://www.company.com/privacy"
}

variable "guest_portal_terms_url" {
  description = "Terms of service URL for guest portal"
  type        = string
  default     = "https://www.company.com/terms"
}

variable "guest_portal_sponsors_enabled" {
  description = "Enable sponsor approval for guest access"
  type        = bool
  default     = false
}

variable "guest_bandwidth_limit_mbps" {
  description = "Bandwidth limit for guest network in Mbps"
  type        = number
  default     = 10
  
  validation {
    condition     = var.guest_bandwidth_limit_mbps > 0 && var.guest_bandwidth_limit_mbps <= 1000
    error_message = "Guest bandwidth limit must be between 1 and 1000 Mbps."
  }
}

# Quality of Service Configuration

variable "qos_profiles" {
  description = "QoS profiles configuration"
  type = map(object({
    name        = string
    description = optional(string, "")
    
    # Traffic classes configuration
    classes = list(object({
      name                = string
      dscp_marking        = number
      priority            = number
      guaranteed_bandwidth = optional(number, 0)
      max_bandwidth       = optional(number, 0)
      queue_size          = optional(number, 64)
    }))
  }))
  default = {
    standard = {
      name        = "Standard QoS Profile"
      description = "Standard QoS configuration for enterprise networks"
      
      classes = [
        {
          name                = "Voice"
          dscp_marking        = 46  # EF
          priority            = 7
          guaranteed_bandwidth = 100000  # 100 kbps
          max_bandwidth       = 0        # Unlimited
          queue_size          = 32
        },
        {
          name                = "Video"
          dscp_marking        = 34  # AF41
          priority            = 6
          guaranteed_bandwidth = 1000000  # 1 Mbps
          max_bandwidth       = 0         # Unlimited
          queue_size          = 64
        },
        {
          name                = "Business"
          dscp_marking        = 18  # AF21
          priority            = 4
          guaranteed_bandwidth = 0
          max_bandwidth       = 0
          queue_size          = 64
        },
        {
          name                = "Best_Effort"
          dscp_marking        = 0   # Default
          priority            = 2
          guaranteed_bandwidth = 0
          max_bandwidth       = 0
          queue_size          = 64
        },
        {
          name                = "Background"
          dscp_marking        = 8   # CS1
          priority            = 1
          guaranteed_bandwidth = 0
          max_bandwidth       = 1000000  # 1 Mbps max
          queue_size          = 32
        }
      ]
    }
  }
}

# Security Configuration

variable "wlan_security_settings" {
  description = "WLAN security settings"
  type = object({
    # Corporate network security
    corporate = object({
      enable_mac_auth          = optional(bool, false)
      multi_psk_only          = optional(bool, false)
      private_wlan            = optional(bool, true)
      eap_reauth              = optional(bool, true)
      eap_reauth_period       = optional(number, 3600)
      enable_wireless_bridging = optional(bool, false)
      disable_wmm             = optional(bool, false)
      disable_ht_cc_protection = optional(bool, false)
    })
    
    # Guest network security
    guest = object({
      portal_expire_minutes    = optional(number, 1440)  # 24 hours
      portal_session_timeout   = optional(number, 0)     # No timeout
      portal_idle_timeout      = optional(number, 0)     # No timeout
      portal_bypass_when_cloud_down = optional(bool, false)
    })
    
    # IoT network security
    iot = object({
      disable_11ax            = optional(bool, true)   # Better compatibility
      disable_wmm             = optional(bool, false)
      disable_ht_cc_protection = optional(bool, false)
      enable_wireless_bridging = optional(bool, false)
    })
  })
  default = {
    corporate = {
      enable_mac_auth          = false
      multi_psk_only          = false
      private_wlan            = true
      eap_reauth              = true
      eap_reauth_period       = 3600
      enable_wireless_bridging = false
      disable_wmm             = false
      disable_ht_cc_protection = false
    }
    
    guest = {
      portal_expire_minutes    = 1440
      portal_session_timeout   = 0
      portal_idle_timeout      = 0
      portal_bypass_when_cloud_down = false
    }
    
    iot = {
      disable_11ax            = true
      disable_wmm             = false
      disable_ht_cc_protection = false
      enable_wireless_bridging = false
    }
  }
}

# RF Management Configuration

variable "rf_management" {
  description = "RF management and optimization settings"
  type = object({
    enable_ai_optimization    = optional(bool, true)
    enable_band_steering     = optional(bool, true)
    enable_client_balancing  = optional(bool, true)
    enable_load_balancing    = optional(bool, true)
    enable_airtime_fairness  = optional(bool, true)
    
    # Channel settings
    auto_channel_selection = optional(bool, true)
    avoid_dfs_channels    = optional(bool, false)
    
    # Power settings
    auto_power_adjustment = optional(bool, true)
    min_power_level      = optional(number, -10)
    max_power_level      = optional(number, 20)
    
    # Client settings
    max_clients_per_ap   = optional(number, 100)
    client_balancing_threshold = optional(number, 12)
    
    # Roaming settings
    enable_fast_roaming  = optional(bool, true)
    rssi_threshold      = optional(number, -70)
  })
  default = {
    enable_ai_optimization    = true
    enable_band_steering     = true
    enable_client_balancing  = true
    enable_load_balancing    = true
    enable_airtime_fairness  = true
    auto_channel_selection   = true
    avoid_dfs_channels      = false
    auto_power_adjustment   = true
    min_power_level         = -10
    max_power_level         = 20
    max_clients_per_ap      = 100
    client_balancing_threshold = 12
    enable_fast_roaming     = true
    rssi_threshold          = -70
  }
}

# Monitoring and Analytics Configuration

variable "monitoring_settings" {
  description = "Monitoring and analytics configuration"
  type = object({
    enable_device_profiling    = optional(bool, true)
    enable_user_analytics     = optional(bool, true)
    enable_application_analytics = optional(bool, true)
    enable_location_analytics  = optional(bool, true)
    enable_capacity_analytics  = optional(bool, true)
    
    # Data retention settings
    analytics_retention_days   = optional(number, 90)
    event_retention_days      = optional(number, 30)
    
    # Alert thresholds
    device_offline_threshold_minutes = optional(number, 5)
    high_cpu_threshold_percent      = optional(number, 80)
    high_memory_threshold_percent   = optional(number, 85)
    high_channel_utilization_percent = optional(number, 70)
  })
  default = {
    enable_device_profiling     = true
    enable_user_analytics      = true
    enable_application_analytics = true
    enable_location_analytics   = true
    enable_capacity_analytics   = true
    analytics_retention_days    = 90
    event_retention_days       = 30
    device_offline_threshold_minutes = 5
    high_cpu_threshold_percent  = 80
    high_memory_threshold_percent = 85
    high_channel_utilization_percent = 70
  }
}

# Integration Configuration

variable "integration_settings" {
  description = "External system integration settings"
  type = object({
    # Syslog configuration
    enable_syslog         = optional(bool, false)
    syslog_servers       = optional(list(object({
      host     = string
      port     = optional(number, 514)
      facility = optional(number, 16)
      protocol = optional(string, "udp")
      tag      = optional(string, "mist")
    })), [])
    
    # SNMP configuration
    enable_snmp          = optional(bool, false)
    snmp_community       = optional(string, "public")
    snmp_contact         = optional(string, "")
    snmp_location        = optional(string, "")
    
    # Webhook configuration
    enable_webhooks      = optional(bool, false)
    webhook_endpoints    = optional(list(object({
      name    = string
      url     = string
      secret  = optional(string, "")
      events  = list(string)
      enabled = optional(bool, true)
    })), [])
    
    # API rate limiting
    api_rate_limit_enabled = optional(bool, true)
    api_rate_limit_requests_per_minute = optional(number, 1000)
  })
  default = {
    enable_syslog         = false
    syslog_servers       = []
    enable_snmp          = false
    snmp_community       = "public"
    snmp_contact         = ""
    snmp_location        = ""
    enable_webhooks      = false
    webhook_endpoints    = []
    api_rate_limit_enabled = true
    api_rate_limit_requests_per_minute = 1000
  }
  sensitive = true
}