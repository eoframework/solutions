# Microsoft 365 Enterprise Deployment - Production Configuration
# Generated from configuration.csv - do not edit directly
# Regenerate using: generate-powershell-config.py --environment prod

@{
    # ===========================================================================
    # Project Settings
    # ===========================================================================
    solution = @{
        name          = 'M365 Enterprise Deployment'
        abbr          = 'm365'
        provider_name = 'microsoft'
        category_name = 'modern-workspace'
    }

    azure_ad = @{
        tenant_id     = '[TENANT_ID]'                 # Replace with actual tenant ID
        tenant_domain = '[company].onmicrosoft.com'   # Replace with tenant domain
        custom_domain = 'company.com'
    }

    ownership = @{
        cost_center  = 'CC-M365-001'
        owner_email  = 'it-team@company.com'
        project_code = 'PRJ-M365-2025'
    }

    # ===========================================================================
    # M365 Services Settings
    # ===========================================================================
    m365 = @{
        license_type       = 'E5'
        user_count         = 500
        exchange_enabled   = $true
        sharepoint_enabled = $true
        teams_enabled      = $true
        onedrive_enabled   = $true
    }

    # ===========================================================================
    # Identity Settings
    # ===========================================================================
    identity = @{
        azure_ad_connect_enabled   = $true
        sso_enabled                = $true
        mfa_enabled                = $true
        mfa_method                 = 'authenticator'
        conditional_access_enabled = $true
        pim_enabled                = $true
    }

    # ===========================================================================
    # Migration Settings
    # ===========================================================================
    migration = @{
        email_volume_gb          = 250
        file_volume_tb           = 5
        source_system            = 'exchange_onprem'
        hybrid_exchange_enabled  = $true
        pilot_user_count         = 50
        wave_size                = 90
    }

    # ===========================================================================
    # Security Settings
    # ===========================================================================
    security = @{
        defender_for_office_enabled = $true
        safe_links_enabled          = $true
        safe_attachments_enabled    = $true
        attack_simulation_enabled   = $true
        air_enabled                 = $true
    }

    # ===========================================================================
    # Compliance Settings
    # ===========================================================================
    compliance = @{
        dlp_enabled                 = $true
        retention_policy_enabled    = $true
        email_retention_years       = 7
        ediscovery_enabled          = $true
        sensitivity_labels_enabled  = $true
        audit_log_retention_days    = 365
        frameworks                  = @('SOC2', 'GDPR', 'HIPAA')
    }

    # ===========================================================================
    # Teams Voice Settings
    # ===========================================================================
    teams_voice = @{
        enabled                   = $true
        pstn_users                = 150
        audio_conferencing_users  = 200
        calling_plan_type         = 'domestic'
        voicemail_enabled         = $true
    }

    # ===========================================================================
    # Intune Device Management Settings
    # ===========================================================================
    intune = @{
        enabled                   = $true
        enrollment_type           = 'automatic'
        compliance_policy_enabled = $true
        bitlocker_enabled         = $true
        app_protection_enabled    = $true
    }

    # ===========================================================================
    # SharePoint Settings
    # ===========================================================================
    sharepoint = @{
        storage_quota_tb     = 5
        external_sharing     = 'controlled'
        hub_sites_count      = 5
        versioning_enabled   = $true
    }

    # ===========================================================================
    # Monitoring Settings
    # ===========================================================================
    monitoring = @{
        enable_alerts           = $true
        alert_email             = 'it-ops@company.com'
        service_health_alerts   = $true
        usage_analytics_enabled = $true
    }

    # ===========================================================================
    # Operations Settings
    # ===========================================================================
    operations = @{
        support_tier          = 'premier'
        backup_retention_days = 93
        change_window         = 'weekends'
    }

    # ===========================================================================
    # Disaster Recovery Settings
    # ===========================================================================
    dr = @{
        enabled        = $true
        geo_redundancy = $true
        rto_hours      = 1
        rpo_minutes    = 0
    }

    # ===========================================================================
    # Budget Settings
    # ===========================================================================
    budget = @{
        enabled            = $true
        monthly_amount     = 45000
        alert_thresholds   = @(50, 80, 100)
        notification_email = 'finance@company.com'
    }
}
