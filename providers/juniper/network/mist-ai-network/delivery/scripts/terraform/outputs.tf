# Terraform Outputs for Juniper Mist AI Network Platform Deployment

# Organization Information
output "organization_id" {
  description = "Mist organization ID"
  value       = data.mist_org.main.id
}

output "organization_name" {
  description = "Mist organization name"
  value       = data.mist_org.main.name
}

# Site Information
output "sites" {
  description = "Deployed sites information"
  value = {
    for site_key, site in mist_site.sites : site_key => {
      id           = site.id
      name         = site.name
      address      = site.address
      country_code = site.country_code
      timezone     = site.timezone
      created_time = site.created_time
      modified_time = site.modified_time
    }
  }
}

output "site_ids" {
  description = "Map of site names to site IDs"
  value = {
    for site_key, site in mist_site.sites : site_key => site.id
  }
}

output "site_count" {
  description = "Total number of sites deployed"
  value       = length(mist_site.sites)
}

# WLAN Information
output "corporate_wlans" {
  description = "Corporate WLAN configurations"
  value = {
    for site_key, wlan in mist_site_wlan.corporate_wlans : site_key => {
      id      = wlan.id
      site_id = wlan.site_id
      ssid    = wlan.ssid
      enabled = wlan.enabled
      vlan_id = wlan.vlan_id
      created_time = wlan.created_time
      modified_time = wlan.modified_time
    }
  }
}

output "guest_wlans" {
  description = "Guest WLAN configurations"
  value = {
    for site_key, wlan in mist_site_wlan.guest_wlans : site_key => {
      id      = wlan.id
      site_id = wlan.site_id
      ssid    = wlan.ssid
      enabled = wlan.enabled
      vlan_id = wlan.vlan_id
      created_time = wlan.created_time
      modified_time = wlan.modified_time
    }
  }
}

output "iot_wlans" {
  description = "IoT WLAN configurations"
  value = {
    for site_key, wlan in mist_site_wlan.iot_wlans : site_key => {
      id        = wlan.id
      site_id   = wlan.site_id
      ssid      = wlan.ssid
      enabled   = wlan.enabled
      vlan_id   = wlan.vlan_id
      hide_ssid = wlan.hide_ssid
      created_time = wlan.created_time
      modified_time = wlan.modified_time
    }
  }
}

output "wlan_summary" {
  description = "Summary of all WLANs deployed"
  value = {
    total_wlans = (
      length(mist_site_wlan.corporate_wlans) +
      length(mist_site_wlan.guest_wlans) +
      length(mist_site_wlan.iot_wlans)
    )
    corporate_count = length(mist_site_wlan.corporate_wlans)
    guest_count     = length(mist_site_wlan.guest_wlans)
    iot_count       = length(mist_site_wlan.iot_wlans)
  }
}

# Access Point Information
output "access_points" {
  description = "Deployed access points information"
  value = {
    for ap_key, ap in mist_device_ap.access_points : ap_key => {
      id       = ap.id
      site_id  = ap.site_id
      name     = ap.name
      device_id = ap.device_id
      map_id   = ap.map_id
      x        = ap.x
      y        = ap.y
      created_time = ap.created_time
      modified_time = ap.modified_time
    }
  }
  sensitive = false
}

output "access_point_count" {
  description = "Total number of access points deployed"
  value       = length(mist_device_ap.access_points)
}

output "access_points_by_site" {
  description = "Access points grouped by site"
  value = {
    for site_key, site in var.sites : site_key => [
      for ap_key, ap in mist_device_ap.access_points : {
        name      = ap.name
        device_id = ap.device_id
        ap_id     = ap.id
      } if ap.site_id == mist_site.sites[site_key].id
    ]
  }
}

# Switch Information
output "switches" {
  description = "Deployed switches information"
  value = {
    for sw_key, sw in mist_device_switch.switches : sw_key => {
      id       = sw.id
      site_id  = sw.site_id
      name     = sw.name
      device_id = sw.device_id
      role     = sw.role
      created_time = sw.created_time
      modified_time = sw.modified_time
    }
  }
  sensitive = false
}

output "switch_count" {
  description = "Total number of switches deployed"
  value       = length(mist_device_switch.switches)
}

output "switches_by_site" {
  description = "Switches grouped by site"
  value = {
    for site_key, site in var.sites : site_key => [
      for sw_key, sw in mist_device_switch.switches : {
        name      = sw.name
        device_id = sw.device_id
        switch_id = sw.id
        role      = sw.role
      } if sw.site_id == mist_site.sites[site_key].id
    ]
  }
}

# Network Configuration
output "network_configuration" {
  description = "Network configuration summary"
  value = {
    corporate = {
      ssid     = var.corporate_ssid
      vlan_id  = var.corporate_vlan_id
      subnet   = var.corporate_subnet
      gateway  = var.corporate_gateway
    }
    guest = {
      ssid     = var.guest_ssid
      vlan_id  = var.guest_vlan_id
      subnet   = var.guest_subnet
      gateway  = var.guest_gateway
      bandwidth_limit_mbps = var.guest_bandwidth_limit_mbps
    }
    iot = {
      ssid     = var.iot_ssid
      vlan_id  = var.iot_vlan_id
      subnet   = var.iot_subnet
      gateway  = var.iot_gateway
    }
    infrastructure = {
      dhcp_servers = var.dhcp_servers
      dns_servers  = var.dns_servers
    }
  }
}

# Security Configuration Summary
output "security_configuration" {
  description = "Security configuration summary"
  value = {
    radius_auth_servers_count = length(var.radius_auth_servers)
    radius_acct_servers_count = length(var.radius_accounting_servers)
    guest_portal_enabled     = true
    iot_network_isolated     = true
    wpa3_enabled            = true
  }
  sensitive = false
}

# Device Status Information (from data sources)
output "device_status" {
  description = "Device status information"
  value = {
    for site_key, devices in data.mist_site_devices.site_devices : site_key => {
      total_devices = length(devices.devices)
      access_points = length([for d in devices.devices : d if d.type == "ap"])
      switches      = length([for d in devices.devices : d if d.type == "switch"])
      online_devices = length([for d in devices.devices : d if d.status == "connected"])
      offline_devices = length([for d in devices.devices : d if d.status != "connected"])
    }
  }
}

# Deployment Metadata
output "deployment_info" {
  description = "Deployment metadata and information"
  value = {
    deployment_time = timestamp()
    environment     = var.environment
    terraform_version = terraform.version
    
    # Resource counts
    resource_counts = {
      sites          = length(mist_site.sites)
      corporate_wlans = length(mist_site_wlan.corporate_wlans)
      guest_wlans    = length(mist_site_wlan.guest_wlans)
      iot_wlans      = length(mist_site_wlan.iot_wlans)
      access_points  = length(mist_device_ap.access_points)
      switches       = length(mist_device_switch.switches)
    }
    
    # Configuration summary
    configuration_summary = {
      ai_optimization_enabled = var.rf_management.enable_ai_optimization
      location_services_enabled = var.monitoring_settings.enable_location_analytics
      analytics_enabled = var.monitoring_settings.enable_user_analytics
      syslog_enabled = var.integration_settings.enable_syslog
      snmp_enabled = var.integration_settings.enable_snmp
      webhooks_enabled = var.integration_settings.enable_webhooks
    }
  }
}

# Management URLs
output "management_urls" {
  description = "Mist Cloud management URLs"
  value = {
    dashboard_url = "https://manage.mist.com/admin/?org_id=${data.mist_org.main.id}"
    
    site_urls = {
      for site_key, site in mist_site.sites : site_key => 
      "https://manage.mist.com/admin/?org_id=${data.mist_org.main.id}#!dashboard/site/${site.id}"
    }
    
    api_documentation = "https://api.mist.com/api/v1/docs"
    support_portal   = "https://support.juniper.net"
  }
}

# Configuration Validation Results
output "validation_results" {
  description = "Configuration validation results"
  value = {
    valid_corporate_vlan = (
      var.corporate_vlan_id >= 1 && 
      var.corporate_vlan_id <= 4094 &&
      var.corporate_vlan_id != var.guest_vlan_id &&
      var.corporate_vlan_id != var.iot_vlan_id
    )
    
    valid_guest_vlan = (
      var.guest_vlan_id >= 1 && 
      var.guest_vlan_id <= 4094 &&
      var.guest_vlan_id != var.corporate_vlan_id &&
      var.guest_vlan_id != var.iot_vlan_id
    )
    
    valid_iot_vlan = (
      var.iot_vlan_id >= 1 && 
      var.iot_vlan_id <= 4094 &&
      var.iot_vlan_id != var.corporate_vlan_id &&
      var.iot_vlan_id != var.guest_vlan_id
    )
    
    unique_vlans = length(distinct([
      var.corporate_vlan_id,
      var.guest_vlan_id,
      var.iot_vlan_id
    ])) == 3
    
    valid_subnets = alltrue([
      can(cidrhost(var.corporate_subnet, 0)),
      can(cidrhost(var.guest_subnet, 0)),
      can(cidrhost(var.iot_subnet, 0))
    ])
    
    configuration_valid = (
      length(var.sites) > 0 &&
      length(var.corporate_ssid) > 0 &&
      length(var.guest_ssid) > 0 &&
      length(var.iot_ssid) > 0
    )
  }
}

# Quick Start Information
output "quick_start_info" {
  description = "Quick start information for administrators"
  value = {
    next_steps = [
      "1. Access the Mist Dashboard at https://manage.mist.com",
      "2. Navigate to your organization: ${data.mist_org.main.name}",
      "3. Review deployed sites and verify device connectivity",
      "4. Test WLAN connectivity using corporate, guest, and IoT networks",
      "5. Configure additional features using the AI-driven recommendations",
      "6. Set up monitoring and alerting based on your requirements"
    ]
    
    important_notes = [
      "All access points will auto-configure via cloud management",
      "Marvis AI assistant is available for troubleshooting and optimization", 
      "Location services are enabled and will begin collecting analytics",
      "Guest portal is configured and ready for use",
      "IoT network is isolated and bandwidth-limited for security"
    ]
    
    support_resources = [
      "Mist Documentation: https://www.mist.com/documentation/",
      "Juniper Support: https://support.juniper.net",
      "Mist Community: https://community.juniper.net",
      "Training Resources: https://www.mist.com/training/"
    ]
  }
}

# Cost Estimation (if available)
output "estimated_monthly_cost" {
  description = "Estimated monthly cost breakdown (requires cost data)"
  value = {
    note = "Actual costs may vary based on subscription type and usage"
    
    license_estimates = {
      access_point_licenses = length(mist_device_ap.access_points)
      switch_licenses      = length(mist_device_switch.switches)
      location_services_aps = length([
        for site_key, site in var.sites : site_key 
        if try(site.location_services_enabled, true)
      ])
    }
    
    feature_utilization = {
      ai_optimization = var.rf_management.enable_ai_optimization
      location_services = var.monitoring_settings.enable_location_analytics
      advanced_analytics = var.monitoring_settings.enable_application_analytics
    }
  }
}