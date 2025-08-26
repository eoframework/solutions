# Juniper Mist AI Network Platform Terraform Configuration
# This Terraform configuration deploys Mist AI Network Platform infrastructure
# including organizations, sites, WLANs, and device configurations.

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    mist = {
      source  = "Juniper/mist"
      version = "~> 0.2"
    }
  }
}

# Configure the Mist Provider
provider "mist" {
  api_token = var.mist_api_token
  host      = var.mist_api_host
}

# Data source to get organization information
data "mist_org" "main" {
  name = var.organization_name
}

# Local values for configuration
locals {
  # Common tags for resources
  common_tags = {
    Environment   = var.environment
    Project      = "Mist AI Network Deployment"
    ManagedBy    = "Terraform"
    DeployDate   = timestamp()
  }
  
  # WLAN templates
  wlan_templates = {
    corporate = {
      ssid           = var.corporate_ssid
      enabled        = true
      hide_ssid      = false
      no_static_ip   = false
      no_static_dns  = false
      band_steer     = true
      
      auth = {
        type                 = "eap"
        enable_mac_auth      = false
        multi_psk_only       = false
        pairwise            = ["wpa2-ccmp", "wpa3-ccmp"]
        private_wlan        = true
        eap_reauth          = true
      }
      
      vlan_enabled = true
      vlan_id      = var.corporate_vlan_id
      interface    = "corporate"
      
      dynamic_vlan = {
        enabled      = true
        type         = "standard"
        default_vlan = var.corporate_vlan_id
      }
      
      acct_servers = var.radius_accounting_servers
      auth_servers = var.radius_auth_servers
      
      qos = {
        class = "best_effort"
      }
      
      roam_mode = "OKC"
      
      wlan_limit_up   = 0  # Unlimited
      wlan_limit_down = 0  # Unlimited
      
      client_limit_up   = 0  # Unlimited  
      client_limit_down = 0  # Unlimited
    }
    
    guest = {
      ssid           = var.guest_ssid
      enabled        = true
      hide_ssid      = false
      no_static_ip   = false
      no_static_dns  = false
      band_steer     = true
      
      auth = {
        type         = "open"
        multi_psk_only = false
      }
      
      vlan_enabled = true
      vlan_id      = var.guest_vlan_id
      interface    = "guest"
      
      portal = {
        enabled                    = true
        bypass_when_cloud_down     = false
        email_enabled              = true
        expire                     = 1440  # 24 hours
        external_portal_url        = ""
        forward_url                = var.guest_portal_forward_url
        privacy_policy_url         = var.guest_portal_privacy_url
        sms_enabled               = false
        sponsors_enabled          = var.guest_portal_sponsors_enabled
        sponsors_notify_all       = false
        terms_url                 = var.guest_portal_terms_url
        thumbnail_url             = ""
      }
      
      qos = {
        class = "best_effort"
      }
      
      wlan_limit_up   = var.guest_bandwidth_limit_mbps * 1000000  # Convert to bps
      wlan_limit_down = var.guest_bandwidth_limit_mbps * 1000000  # Convert to bps
      
      client_limit_up   = 10000000   # 10 Mbps per client
      client_limit_down = 10000000   # 10 Mbps per client
      
      allow_ipv6_ndp    = true
      apply_to          = "site"
      isolation         = true
      limit_bcast       = true
      limit_probe_response = true
    }
    
    iot = {
      ssid           = var.iot_ssid
      enabled        = true
      hide_ssid      = true
      no_static_ip   = false
      no_static_dns  = false
      band_steer     = false  # IoT devices may not support band steering
      
      auth = {
        type     = "psk"
        psk      = var.iot_psk
        pairwise = ["wpa2-ccmp"]  # Many IoT devices don't support WPA3
      }
      
      vlan_enabled = true
      vlan_id      = var.iot_vlan_id
      interface    = "iot"
      
      qos = {
        class = "background"
      }
      
      wlan_limit_up   = 5000000   # 5 Mbps
      wlan_limit_down = 5000000   # 5 Mbps
      
      client_limit_up   = 1000000   # 1 Mbps per device
      client_limit_down = 1000000   # 1 Mbps per device
      
      apply_to          = "site"
      isolation         = true
      limit_bcast       = true
      limit_probe_response = true
      
      # Disable advanced features for IoT compatibility
      disable_11ax      = true
      disable_v1_roam_notify = true
    }
  }
}

# Create sites based on variable configuration
resource "mist_site" "sites" {
  for_each = var.sites
  
  org_id = data.mist_org.main.id
  name   = each.key
  
  # Site location and configuration
  address     = each.value.address
  country_code = each.value.country_code
  timezone    = each.value.timezone
  
  # Coordinates if provided
  latlng = can(each.value.latitude) && can(each.value.longitude) ? {
    lat = each.value.latitude
    lng = each.value.longitude
  } : null
  
  # Site settings
  site_settings = {
    # RTLS (Real-Time Location Services) settings
    rtls = {
      enabled = try(each.value.rtls_enabled, false)
      track_asset = try(each.value.rtls_track_asset, false)
    }
    
    # Location Engine settings
    location_engine = {
      enabled = try(each.value.location_services_enabled, true)
    }
    
    # Analytics settings
    analytic = {
      enabled = try(each.value.analytics_enabled, true)
    }
    
    # Engagement settings
    engagement = {
      enabled = try(each.value.engagement_enabled, false)
    }
    
    # LED settings for access points
    led = {
      enabled     = true
      brightness  = 255
    }
    
    # Wifi settings
    wifi = {
      enabled                = true
      locate_unconnected     = try(each.value.locate_unconnected_clients, false)
      mesh_enabled          = try(each.value.mesh_enabled, false)
      mesh_allow_dfs        = try(each.value.mesh_allow_dfs, false)
      mesh_enable_crm       = try(each.value.mesh_enable_crm, false)
      proxy_arp             = "default"
      disable_11k           = false
      disable_radios_when_power_constrained = false
    }
    
    # Auto upgrade settings
    auto_upgrade = {
      enabled     = try(each.value.auto_upgrade_enabled, true)
      version     = try(each.value.auto_upgrade_version, "")
      time_of_day = try(each.value.auto_upgrade_time, "02:00")
      custom_versions = {}
      day_of_week = try(each.value.auto_upgrade_day, "sun")
    }
    
    # Device updown threshold
    device_updown_threshold = try(each.value.device_updown_threshold, 0)
    
    # Uplink port config
    uplink_port_config = {
      keep_wlans_up_if_down = try(each.value.keep_wlans_up_if_down, false)
    }
  }
  
  # Network templates - configure VLANs and network settings
  networks = {
    corporate = {
      vlan_id     = var.corporate_vlan_id
      subnet      = var.corporate_subnet
      dhcp_servers = var.dhcp_servers
      dns_servers  = var.dns_servers
      gateway     = var.corporate_gateway
    }
    
    guest = {
      vlan_id     = var.guest_vlan_id
      subnet      = var.guest_subnet
      dhcp_servers = var.dhcp_servers
      dns_servers  = var.dns_servers
      gateway     = var.guest_gateway
    }
    
    iot = {
      vlan_id     = var.iot_vlan_id
      subnet      = var.iot_subnet
      dhcp_servers = var.dhcp_servers
      dns_servers  = var.dns_servers
      gateway     = var.iot_gateway
    }
  }
  
  # RF templates for site-specific radio settings
  rf_templates = {
    "5" = {
      ant_gain_24     = 0
      ant_gain_5      = 0
      ant_gain_6      = 0
      band_24_usage   = "24"
      band_5_usage    = "5u5l"
      band_6_usage    = "6"
      country_code    = each.value.country_code
      
      # Channel and power settings will be managed by AI
      scanning_enabled = true
    }
  }
  
  tags = merge(local.common_tags, {
    SiteName = each.key
    Address  = each.value.address
  })
}

# Create WLANs for each site
resource "mist_site_wlan" "corporate_wlans" {
  for_each = var.sites
  
  site_id = mist_site.sites[each.key].id
  
  # Corporate WLAN configuration
  ssid     = local.wlan_templates.corporate.ssid
  enabled  = local.wlan_templates.corporate.enabled
  
  # Authentication settings
  auth = local.wlan_templates.corporate.auth
  
  # VLAN settings  
  vlan_enabled = local.wlan_templates.corporate.vlan_enabled
  vlan_id      = local.wlan_templates.corporate.vlan_id
  interface    = local.wlan_templates.corporate.interface
  
  # Dynamic VLAN settings
  dynamic_vlan = local.wlan_templates.corporate.dynamic_vlan
  
  # RADIUS server configuration
  acct_servers = local.wlan_templates.corporate.acct_servers
  auth_servers = local.wlan_templates.corporate.auth_servers
  
  # QoS and performance settings
  qos                = local.wlan_templates.corporate.qos
  band_steer        = local.wlan_templates.corporate.band_steer
  roam_mode         = local.wlan_templates.corporate.roam_mode
  
  # Bandwidth limits
  wlan_limit_up     = local.wlan_templates.corporate.wlan_limit_up
  wlan_limit_down   = local.wlan_templates.corporate.wlan_limit_down
  client_limit_up   = local.wlan_templates.corporate.client_limit_up
  client_limit_down = local.wlan_templates.corporate.client_limit_down
  
  depends_on = [mist_site.sites]
}

resource "mist_site_wlan" "guest_wlans" {
  for_each = var.sites
  
  site_id = mist_site.sites[each.key].id
  
  # Guest WLAN configuration
  ssid     = local.wlan_templates.guest.ssid
  enabled  = local.wlan_templates.guest.enabled
  
  # Authentication settings (open with portal)
  auth = local.wlan_templates.guest.auth
  
  # VLAN settings
  vlan_enabled = local.wlan_templates.guest.vlan_enabled
  vlan_id      = local.wlan_templates.guest.vlan_id
  interface    = local.wlan_templates.guest.interface
  
  # Captive portal settings
  portal = local.wlan_templates.guest.portal
  
  # QoS and performance settings
  qos                = local.wlan_templates.guest.qos
  band_steer        = local.wlan_templates.guest.band_steer
  
  # Bandwidth limits
  wlan_limit_up     = local.wlan_templates.guest.wlan_limit_up
  wlan_limit_down   = local.wlan_templates.guest.wlan_limit_down
  client_limit_up   = local.wlan_templates.guest.client_limit_up
  client_limit_down = local.wlan_templates.guest.client_limit_down
  
  # Security and isolation settings
  allow_ipv6_ndp         = local.wlan_templates.guest.allow_ipv6_ndp
  apply_to              = local.wlan_templates.guest.apply_to
  isolation             = local.wlan_templates.guest.isolation
  limit_bcast           = local.wlan_templates.guest.limit_bcast
  limit_probe_response  = local.wlan_templates.guest.limit_probe_response
  
  depends_on = [mist_site.sites]
}

resource "mist_site_wlan" "iot_wlans" {
  for_each = var.sites
  
  site_id = mist_site.sites[each.key].id
  
  # IoT WLAN configuration
  ssid     = local.wlan_templates.iot.ssid
  enabled  = local.wlan_templates.iot.enabled
  hide_ssid = local.wlan_templates.iot.hide_ssid
  
  # Authentication settings (PSK)
  auth = local.wlan_templates.iot.auth
  
  # VLAN settings
  vlan_enabled = local.wlan_templates.iot.vlan_enabled
  vlan_id      = local.wlan_templates.iot.vlan_id
  interface    = local.wlan_templates.iot.interface
  
  # QoS and performance settings (optimized for IoT)
  qos                = local.wlan_templates.iot.qos
  band_steer        = local.wlan_templates.iot.band_steer
  
  # Bandwidth limits (restrictive for IoT)
  wlan_limit_up     = local.wlan_templates.iot.wlan_limit_up
  wlan_limit_down   = local.wlan_templates.iot.wlan_limit_down
  client_limit_up   = local.wlan_templates.iot.client_limit_up
  client_limit_down = local.wlan_templates.iot.client_limit_down
  
  # Security and isolation settings
  apply_to              = local.wlan_templates.iot.apply_to
  isolation             = local.wlan_templates.iot.isolation
  limit_bcast           = local.wlan_templates.iot.limit_bcast
  limit_probe_response  = local.wlan_templates.iot.limit_probe_response
  
  # IoT-specific optimizations
  disable_11ax              = local.wlan_templates.iot.disable_11ax
  disable_v1_roam_notify    = local.wlan_templates.iot.disable_v1_roam_notify
  
  depends_on = [mist_site.sites]
}

# Device templates for consistent AP configuration
resource "mist_device_ap" "access_points" {
  for_each = {
    for ap in flatten([
      for site_key, site in var.sites : [
        for ap_key, ap in try(site.access_points, {}) : {
          site_key = site_key
          ap_key   = ap_key
          ap_config = ap
          site_id = mist_site.sites[site_key].id
        }
      ]
    ]) : "${ap.site_key}-${ap.ap_key}" => ap
  }
  
  site_id   = each.value.site_id
  device_id = each.value.ap_config.device_id
  name      = each.value.ap_config.name
  
  # Location information
  map_id = try(each.value.ap_config.map_id, "")
  x      = try(each.value.ap_config.x_coordinate, 0)
  y      = try(each.value.ap_config.y_coordinate, 0)
  
  # Device-specific settings
  ip_config = {
    type = "dhcp"  # Use DHCP by default
    
    # Static IP configuration if specified
    ip      = try(each.value.ap_config.static_ip, "")
    netmask = try(each.value.ap_config.static_netmask, "")
    gateway = try(each.value.ap_config.static_gateway, "")
  }
  
  # LED settings
  led = {
    enabled    = true
    brightness = try(each.value.ap_config.led_brightness, 255)
  }
  
  # Radio settings (will be optimized by AI)
  radio_config = {
    band_24 = {
      enabled       = try(each.value.ap_config.radio_24_enabled, true)
      disabled_11b  = try(each.value.ap_config.radio_24_disable_11b, false)
    }
    
    band_5 = {
      enabled = try(each.value.ap_config.radio_5_enabled, true)
    }
    
    band_6 = {
      enabled = try(each.value.ap_config.radio_6_enabled, false)  # Enable for Wi-Fi 6E APs only
    }
    
    scanning_enabled = true  # Enable spectrum scanning
  }
  
  # USB configuration if applicable
  usb_config = {
    enabled = try(each.value.ap_config.usb_enabled, false)
    type    = try(each.value.ap_config.usb_type, "")
  }
  
  # IoT configuration
  iot_config = {
    enabled = try(each.value.ap_config.iot_enabled, false)
  }
  
  depends_on = [mist_site.sites]
}

# Switch configuration (if switches are defined)
resource "mist_device_switch" "switches" {
  for_each = {
    for sw in flatten([
      for site_key, site in var.sites : [
        for sw_key, sw in try(site.switches, {}) : {
          site_key = site_key
          sw_key   = sw_key
          sw_config = sw
          site_id = mist_site.sites[site_key].id
        }
      ]
    ]) : "${sw.site_key}-${sw.sw_key}" => sw
  }
  
  site_id   = each.value.site_id
  device_id = each.value.sw_config.device_id
  name      = each.value.sw_config.name
  
  # Switch role and configuration
  role = try(each.value.sw_config.role, "access")
  
  # Port configuration
  port_config = try(each.value.sw_config.port_config, {})
  
  depends_on = [mist_site.sites]
}

# Data source to retrieve device statistics after deployment
data "mist_site_devices" "site_devices" {
  for_each = var.sites
  
  site_id = mist_site.sites[each.key].id
  
  depends_on = [
    mist_device_ap.access_points,
    mist_device_switch.switches
  ]
}