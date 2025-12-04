# CMMC GCC High Enclave - Test Configuration
# Generated from configuration.csv - do not edit directly
# Regenerate using: generate-powershell-config.py --environment test

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
        owner_email  = 'dev-team@company.com'
        project_code = 'PRJ-CMMC-2025'
    }

    # ===========================================================================
    # M365 GCC High Settings
    # ===========================================================================
    m365_gcc_high = @{
        tenant_domain              = '[tenant].onmicrosoft.us'
        license_sku                = 'SPE_E5_GCC_HIGH'
        user_count                 = 10
        mailbox_archiving_enabled  = $true
        ediscovery_enabled         = $false
    }

    # ===========================================================================
    # Authentication Settings
    # ===========================================================================
    authentication = @{
        cac_piv_required            = $true
        conditional_access_enabled  = $true
        mfa_enforcement             = 'required'
        session_timeout_minutes     = 480
        device_compliance_required  = $false
    }

    # ===========================================================================
    # Security Monitoring Settings
    # ===========================================================================
    security = @{
        sentinel_workspace_name     = 'cmmc-sentinel-test'
        sentinel_retention_days     = 30
        sentinel_ingestion_gb       = 25
        defender_for_cloud_enabled  = $true
        defender_for_office_enabled = $true
        enable_threat_intelligence  = $false
    }

    # ===========================================================================
    # Encryption Settings
    # ===========================================================================
    encryption = @{
        algorithm                   = 'AES-256'
        fips_140_level              = 2
        tls_version                 = '1.2'
        enable_customer_managed_keys = $false
    }

    # ===========================================================================
    # Network Settings
    # ===========================================================================
    network = @{
        vnet_cidr                   = '10.101.0.0/16'
        management_subnet           = '10.101.1.0/24'
        cui_workload_subnet         = '10.101.10.0/24'
        private_endpoint_subnet     = '10.101.20.0/24'
        expressroute_enabled        = $false
        expressroute_bandwidth_mbps = 0
        enable_azure_firewall       = $false
    }

    # ===========================================================================
    # Compute Settings
    # ===========================================================================
    compute = @{
        vm_count             = 2
        vm_size              = 'Standard_D2s_v3'
        os_version           = '2022-datacenter-azure-edition'
        enable_azure_bastion = $true
    }

    # ===========================================================================
    # Storage Settings
    # ===========================================================================
    storage = @{
        account_tier       = 'Standard'
        replication_type   = 'LRS'
        total_capacity_tb  = 0.5
        enable_soft_delete = $true
    }

    # ===========================================================================
    # Compliance Settings
    # ===========================================================================
    compliance = @{
        cmmc_level                  = 'Level2'
        nist_800_171_controls       = 110
        sprs_score_target           = 110
        audit_log_retention_years   = 1
        enable_compliance_manager   = $false
    }

    # ===========================================================================
    # Purview Data Protection Settings
    # ===========================================================================
    purview = @{
        dlp_enabled                 = $true
        sensitivity_labels_enabled  = $true
        retention_policy_years      = 1
    }

    # ===========================================================================
    # Intune Device Management Settings
    # ===========================================================================
    intune = @{
        device_enrollment_required  = $false
        compliance_policy_enabled   = $false
        bitlocker_required          = $true
    }

    # ===========================================================================
    # Monitoring Settings
    # ===========================================================================
    monitoring = @{
        enable_alerts          = $false
        alert_email            = 'dev-team@company.com'
        alert_response_minutes = 60
        enable_workbooks       = $false
    }

    # ===========================================================================
    # Operations Settings
    # ===========================================================================
    operations = @{
        backup_retention_days = 7
        rto_hours             = 24
        rpo_hours             = 4
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
        enabled              = $false
        replication_enabled  = $false
        failover_priority    = 0
    }

    # ===========================================================================
    # Budget Settings
    # ===========================================================================
    budget = @{
        enabled            = $true
        monthly_amount     = 3000
        alert_thresholds   = @(80, 100)
        notification_email = 'dev-team@company.com'
    }
}
