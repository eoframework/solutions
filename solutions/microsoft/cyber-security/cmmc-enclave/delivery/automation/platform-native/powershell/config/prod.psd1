# CMMC GCC High Enclave - Production Configuration
# Generated from configuration.csv - do not edit directly
# Regenerate using: generate-powershell-config.py --environment prod

@{
    # ===========================================================================
    # Project Settings
    # ===========================================================================
    solution = @{
        name          = 'CMMC GCC High Enclave'
        abbr          = 'cmmc'
        provider_name = 'microsoft'
        category_name = 'cyber-security'
    }

    azure_gov = @{
        tenant_id       = '[GOV_TENANT_ID]'       # Replace with actual tenant ID
        subscription_id = '[GOV_SUBSCRIPTION_ID]' # Replace with actual subscription ID
        region          = 'usgovvirginia'
        dr_region       = 'usgovtexas'
    }

    ownership = @{
        cost_center  = 'CC-CMMC-001'
        owner_email  = 'cmmc-team@company.com'
        project_code = 'PRJ-CMMC-2025'
    }

    # ===========================================================================
    # M365 GCC High Settings
    # ===========================================================================
    m365_gcc_high = @{
        tenant_domain              = '[tenant].onmicrosoft.us'
        license_sku                = 'SPE_E5_GCC_HIGH'
        user_count                 = 50
        mailbox_archiving_enabled  = $true
        ediscovery_enabled         = $true
    }

    # ===========================================================================
    # Authentication Settings
    # ===========================================================================
    authentication = @{
        cac_piv_required            = $true
        conditional_access_enabled  = $true
        mfa_enforcement             = 'required'
        session_timeout_minutes     = 480
        device_compliance_required  = $true
    }

    # ===========================================================================
    # Security Monitoring Settings
    # ===========================================================================
    security = @{
        sentinel_workspace_name     = 'cmmc-sentinel-prod'
        sentinel_retention_days     = 90
        sentinel_ingestion_gb       = 100
        defender_for_cloud_enabled  = $true
        defender_for_office_enabled = $true
        enable_threat_intelligence  = $true
    }

    # ===========================================================================
    # Encryption Settings
    # ===========================================================================
    encryption = @{
        algorithm                   = 'AES-256'
        fips_140_level              = 2
        tls_version                 = '1.2'
        enable_customer_managed_keys = $true
    }

    # ===========================================================================
    # Network Settings
    # ===========================================================================
    network = @{
        vnet_cidr                   = '10.100.0.0/16'
        management_subnet           = '10.100.1.0/24'
        cui_workload_subnet         = '10.100.10.0/24'
        private_endpoint_subnet     = '10.100.20.0/24'
        expressroute_enabled        = $true
        expressroute_bandwidth_mbps = 1000
        enable_azure_firewall       = $true
    }

    # ===========================================================================
    # Compute Settings
    # ===========================================================================
    compute = @{
        vm_count             = 5
        vm_size              = 'Standard_D4s_v3'
        os_version           = '2022-datacenter-azure-edition'
        enable_azure_bastion = $true
    }

    # ===========================================================================
    # Storage Settings
    # ===========================================================================
    storage = @{
        account_tier       = 'Premium'
        replication_type   = 'GRS'
        total_capacity_tb  = 2
        enable_soft_delete = $true
    }

    # ===========================================================================
    # Compliance Settings
    # ===========================================================================
    compliance = @{
        cmmc_level                  = 'Level2'
        nist_800_171_controls       = 110
        sprs_score_target           = 110
        audit_log_retention_years   = 7
        enable_compliance_manager   = $true
    }

    # ===========================================================================
    # Purview Data Protection Settings
    # ===========================================================================
    purview = @{
        dlp_enabled                 = $true
        sensitivity_labels_enabled  = $true
        retention_policy_years      = 7
    }

    # ===========================================================================
    # Intune Device Management Settings
    # ===========================================================================
    intune = @{
        device_enrollment_required  = $true
        compliance_policy_enabled   = $true
        bitlocker_required          = $true
    }

    # ===========================================================================
    # Monitoring Settings
    # ===========================================================================
    monitoring = @{
        enable_alerts          = $true
        alert_email            = 'soc-team@company.com'
        alert_response_minutes = 15
        enable_workbooks       = $true
    }

    # ===========================================================================
    # Operations Settings
    # ===========================================================================
    operations = @{
        backup_retention_days = 30
        rto_hours             = 4
        rpo_hours             = 1
        patch_schedule        = 'monthly'
    }

    # ===========================================================================
    # Vulnerability Management Settings
    # ===========================================================================
    vulnerability = @{
        scan_frequency        = 'monthly'
        remediation_sla_days  = 30
    }

    # ===========================================================================
    # Disaster Recovery Settings
    # ===========================================================================
    dr = @{
        enabled              = $true
        replication_enabled  = $true
        failover_priority    = 1
    }

    # ===========================================================================
    # Budget Settings
    # ===========================================================================
    budget = @{
        enabled            = $true
        monthly_amount     = 20000
        alert_thresholds   = @(50, 80, 100)
        notification_email = 'finance@company.com'
    }
}
