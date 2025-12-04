# Microsoft 365 Enterprise Deployment - Test Configuration
# Generated from configuration.csv - do not edit directly
# Regenerate using: generate-powershell-config.py --environment test

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
        tenant_id     = '[TENANT_ID]'
        tenant_domain = '[company].onmicrosoft.com'
        custom_domain = 'company.com'
    }

    ownership = @{
        cost_center  = 'CC-M365-001'
        owner_email  = 'dev-team@company.com'
        project_code = 'PRJ-M365-2025'
    }

    # ===========================================================================
    # M365 Services Settings
    # ===========================================================================
    m365 = @{
        license_type       = 'E3'
        user_count         = 50
        exchange_enabled   = $true
        sharepoint_enabled = $true
        teams_enabled      = $true
        onedrive_enabled   = $true
    }

    # ===========================================================================
    # Identity Settings
    # ===========================================================================
    identity = @{
        azure_ad_connect_enabled   = $false
        sso_enabled                = $true
        mfa_enabled                = $true
        mfa_method                 = 'authenticator'
        conditional_access_enabled = $false
        pim_enabled                = $false
    }

    # ===========================================================================
    # Migration Settings
    # ===========================================================================
    migration = @{
        email_volume_gb          = 25
        file_volume_tb           = 0.5
        source_system            = 'exchange_onprem'
        hybrid_exchange_enabled  = $false
        pilot_user_count         = 10
        wave_size                = 20
    }

    # ===========================================================================
    # Security Settings
    # ===========================================================================
    security = @{
        defender_for_office_enabled = $true
        safe_links_enabled          = $true
        safe_attachments_enabled    = $true
        attack_simulation_enabled   = $false
        air_enabled                 = $false
    }

    # ===========================================================================
    # Compliance Settings
    # ===========================================================================
    compliance = @{
        dlp_enabled                 = $false
        retention_policy_enabled    = $false
        email_retention_years       = 1
        ediscovery_enabled          = $false
        sensitivity_labels_enabled  = $false
        audit_log_retention_days    = 90
        frameworks                  = @('SOC2')
    }

    # ===========================================================================
    # Teams Voice Settings
    # ===========================================================================
    teams_voice = @{
        enabled                   = $false
        pstn_users                = 0
        audio_conferencing_users  = 0
        calling_plan_type         = 'none'
        voicemail_enabled         = $false
    }

    # ===========================================================================
    # Intune Device Management Settings
    # ===========================================================================
    intune = @{
        enabled                   = $false
        enrollment_type           = 'manual'
        compliance_policy_enabled = $false
        bitlocker_enabled         = $false
        app_protection_enabled    = $false
    }

    # ===========================================================================
    # SharePoint Settings
    # ===========================================================================
    sharepoint = @{
        storage_quota_tb     = 1
        external_sharing     = 'disabled'
        hub_sites_count      = 1
        versioning_enabled   = $true
    }

    # ===========================================================================
    # Monitoring Settings
    # ===========================================================================
    monitoring = @{
        enable_alerts           = $false
        alert_email             = 'dev-team@company.com'
        service_health_alerts   = $false
        usage_analytics_enabled = $false
    }

    # ===========================================================================
    # Operations Settings
    # ===========================================================================
    operations = @{
        support_tier          = 'standard'
        backup_retention_days = 30
        change_window         = 'any'
    }

    # ===========================================================================
    # Disaster Recovery Settings
    # ===========================================================================
    dr = @{
        enabled        = $false
        geo_redundancy = $false
        rto_hours      = 24
        rpo_minutes    = 60
    }

    # ===========================================================================
    # Budget Settings
    # ===========================================================================
    budget = @{
        enabled            = $true
        monthly_amount     = 5000
        alert_thresholds   = @(80, 100)
        notification_email = 'dev-team@company.com'
    }
}
