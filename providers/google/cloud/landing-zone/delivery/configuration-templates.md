# Google Cloud Landing Zone Configuration Templates

## Overview
This document provides standardized configuration templates for deploying and managing Google Cloud Landing Zone components. These templates ensure consistency, security, and compliance across all environments.

## Terraform Variable Templates

### Basic Configuration Template
```hcl
# terraform.tfvars - Basic Configuration
project_id              = "my-landing-zone-001"
organization_id         = "123456789012"
billing_account_id      = "ABCDEF-012345-GHIJKL"
region                  = "us-central1"
environment            = "prod"
network_prefix         = "lz"

# Network Configuration
internal_ip_range = "10.0.0.0/8"

hub_subnets = {
  hub-central = {
    cidr   = "10.0.1.0/24"
    region = "us-central1"
  }
}

shared_services_subnets = {
  shared-central = {
    cidr   = "10.0.2.0/24"
    region = "us-central1"
  }
}

production_spokes = {
  web-app = {
    cidr   = "10.10.0.0/16"
    region = "us-central1"
  }
}

# Security Settings
enable_org_policies = true
enable_security_logging = true
kms_location = "us-central1"

# Labels
labels = {
  created_by    = "terraform"
  project       = "landing-zone"
  environment   = "production"
  owner         = "platform-team"
}
```

### Advanced Configuration Template
```hcl
# terraform.tfvars - Advanced Configuration
project_id              = "enterprise-lz-prod"
organization_id         = "987654321098"
billing_account_id      = "XYZYXZ-654321-ABCABC"
region                  = "us-east1"
environment            = "prod"
network_prefix         = "enterprise"

# Multi-Region Network Configuration
internal_ip_range = "10.0.0.0/8"

hub_subnets = {
  hub-east = {
    cidr   = "10.0.1.0/24"
    region = "us-east1"
  }
  hub-central = {
    cidr   = "10.1.1.0/24"
    region = "us-central1"
  }
  hub-west = {
    cidr   = "10.2.1.0/24"
    region = "us-west1"
  }
}

shared_services_subnets = {
  shared-east = {
    cidr   = "10.0.2.0/24"
    region = "us-east1"
  }
  shared-central = {
    cidr   = "10.1.2.0/24"
    region = "us-central1"
  }
  shared-west = {
    cidr   = "10.2.2.0/24"
    region = "us-west1"
  }
}

production_spokes = {
  web-tier = {
    cidr   = "10.10.0.0/16"
    region = "us-east1"
    secondary_ranges = [
      {
        range_name    = "gke-pods"
        ip_cidr_range = "192.168.0.0/16"
      },
      {
        range_name    = "gke-services"
        ip_cidr_range = "172.16.0.0/16"
      }
    ]
  }
  app-tier = {
    cidr   = "10.20.0.0/16"
    region = "us-central1"
  }
  data-tier = {
    cidr   = "10.30.0.0/16"
    region = "us-central1"
  }
  analytics = {
    cidr   = "10.40.0.0/16"
    region = "us-west1"
  }
}

# DNS Configuration
enable_private_dns   = true
private_dns_domain   = "enterprise.internal"

# Enhanced Security Configuration
kms_location                  = "us"
enable_security_logging       = true
security_logs_retention_days  = 2555  # 7 years
logs_bucket_location         = "US"
enable_scc_notifications     = true

# Organization Policies
enable_org_policies           = true
enable_shielded_vm_policy     = true
enable_os_login_policy        = true
enable_serial_port_policy     = true

# Budget Configuration
enable_budget_alerts         = true
monthly_budget_amount        = 100000
budget_notification_channels = [
  "projects/enterprise-lz-prod/notificationChannels/BUDGET_ALERTS_CHANNEL"
]

# IAM Configuration
folder_iam_members = {
  security = {
    security_admins    = ["group:security-team@enterprise.com"]
    project_creators   = ["group:security-admins@enterprise.com"]
  }
  shared_services = {
    network_admins     = ["group:network-team@enterprise.com"]
    project_creators   = ["group:platform-team@enterprise.com"]
  }
  production = {
    compute_admins     = ["group:production-admins@enterprise.com"]
    project_creators   = ["group:app-teams@enterprise.com"]
  }
}

# VPN Configuration
enable_vpn = true
vpn_config = {
  peer_gateways = {
    datacenter-east = {
      ip_address     = "203.0.113.10"
      shared_secret  = "projects/enterprise-lz-prod/secrets/vpn-shared-secret/versions/latest"
      peer_ip_ranges = ["192.168.0.0/16", "172.16.0.0/12"]
    }
    datacenter-west = {
      ip_address     = "203.0.113.20"
      shared_secret  = "projects/enterprise-lz-prod/secrets/vpn-shared-secret-west/versions/latest"
      peer_ip_ranges = ["10.50.0.0/16", "10.60.0.0/16"]
    }
  }
}

# Enhanced Labels
labels = {
  created_by      = "terraform"
  project         = "enterprise-landing-zone"
  environment     = "production"
  owner           = "platform-engineering"
  cost_center     = "infrastructure"
  compliance      = "sox-pci-hipaa"
  backup_policy   = "tier1-daily"
  monitoring      = "enhanced"
  business_unit   = "enterprise-it"
  data_class      = "confidential"
}
```

## Network Configuration Templates

### Hub VPC Firewall Rules Template
```yaml
# firewall-rules.yaml
hub_firewall_rules:
  - name: allow-internal-hub
    description: "Allow internal communication within hub VPC"
    direction: INGRESS
    priority: 1000
    source_ranges: ["10.0.0.0/8"]
    target_tags: ["internal"]
    allowed:
      - protocol: tcp
        ports: ["22", "80", "443", "3389"]
      - protocol: icmp

  - name: allow-ssh-iap
    description: "Allow SSH through Identity-Aware Proxy"
    direction: INGRESS
    priority: 1000
    source_ranges: ["35.235.240.0/20"]
    target_tags: ["ssh-allowed"]
    allowed:
      - protocol: tcp
        ports: ["22"]

  - name: allow-health-checks
    description: "Allow Google Cloud health checks"
    direction: INGRESS
    priority: 1000
    source_ranges: ["130.211.0.0/22", "35.191.0.0/16"]
    target_tags: ["http-server", "https-server"]
    allowed:
      - protocol: tcp
        ports: ["80", "443", "8080", "8443"]

  - name: deny-all-external
    description: "Deny all external access to internal resources"
    direction: INGRESS
    priority: 65534
    source_ranges: ["0.0.0.0/0"]
    target_tags: ["internal-only"]
    denied:
      - protocol: all
```

### VPC Peering Configuration Template
```yaml
# vpc-peering.yaml
vpc_peering_connections:
  - name: hub-to-shared-services
    network: hub-vpc
    peer_network: shared-services-vpc
    auto_create_routes: true
    export_custom_routes: true
    import_custom_routes: true

  - name: shared-services-to-hub
    network: shared-services-vpc
    peer_network: hub-vpc
    auto_create_routes: true
    export_custom_routes: true
    import_custom_routes: true

  - name: hub-to-prod-web
    network: hub-vpc
    peer_network: prod-web-vpc
    auto_create_routes: true
    export_custom_routes: false
    import_custom_routes: true

  - name: prod-web-to-hub
    network: prod-web-vpc
    peer_network: hub-vpc
    auto_create_routes: true
    export_custom_routes: true
    import_custom_routes: false
```

## Security Configuration Templates

### KMS Key Configuration Template
```yaml
# kms-configuration.yaml
kms_key_rings:
  - name: landing-zone-keyring
    location: us-central1
    
crypto_keys:
  - name: compute-encryption-key
    key_ring: landing-zone-keyring
    purpose: ENCRYPT_DECRYPT
    rotation_period: 2592000s  # 30 days
    
  - name: storage-encryption-key
    key_ring: landing-zone-keyring
    purpose: ENCRYPT_DECRYPT
    rotation_period: 7776000s  # 90 days
    
  - name: database-encryption-key
    key_ring: landing-zone-keyring
    purpose: ENCRYPT_DECRYPT
    rotation_period: 7776000s  # 90 days

key_iam_bindings:
  - key: compute-encryption-key
    role: roles/cloudkms.cryptoKeyEncrypterDecrypter
    members:
      - serviceAccount:compute-sa@project-id.iam.gserviceaccount.com
      - serviceAccount:gke-sa@project-id.iam.gserviceaccount.com
```

### Organization Policies Template
```yaml
# org-policies.yaml
organization_policies:
  - constraint: compute.requireShieldedVm
    enforce: true
    
  - constraint: compute.disableSerialPortAccess
    enforce: true
    
  - constraint: compute.requireOsLogin
    enforce: true
    
  - constraint: storage.uniformBucketLevelAccess
    enforce: true
    
  - constraint: iam.disableServiceAccountKeyCreation
    enforce: true
    exceptions:
      - projects/terraform-automation-project
      
  - constraint: compute.vmExternalIpAccess
    allowed_values:
      - projects/web-tier-project/zones/us-central1-a
      - projects/web-tier-project/zones/us-central1-b
    denied_values:
      - projects/database-project/*
```

## Monitoring Configuration Templates

### Alerting Policies Template
```yaml
# alerting-policies.yaml
alerting_policies:
  - display_name: "High CPU Usage"
    conditions:
      - display_name: "CPU usage above 80%"
        condition_threshold:
          filter: 'resource.type="gce_instance"'
          comparison: COMPARISON_GT
          threshold_value: 0.8
          duration: 300s
          aggregations:
            - alignment_period: 60s
              per_series_aligner: ALIGN_MEAN
    
  - display_name: "High Memory Usage"
    conditions:
      - display_name: "Memory usage above 85%"
        condition_threshold:
          filter: 'resource.type="gce_instance" AND metric.type="compute.googleapis.com/instance/memory/utilization"'
          comparison: COMPARISON_GT
          threshold_value: 0.85
          duration: 300s
    
  - display_name: "Disk Space Critical"
    conditions:
      - display_name: "Disk usage above 90%"
        condition_threshold:
          filter: 'resource.type="gce_instance" AND metric.type="compute.googleapis.com/instance/disk/utilization"'
          comparison: COMPARISON_GT
          threshold_value: 0.9
          duration: 180s

notification_channels:
  - display_name: "Email Notifications"
    type: email
    labels:
      email_address: "alerts@company.com"
      
  - display_name: "Slack Notifications"
    type: slack
    labels:
      channel_name: "#infrastructure-alerts"
      url: "https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK"
```

### Log Sink Configuration Template
```yaml
# log-sinks.yaml
log_sinks:
  - name: security-logs-sink
    description: "Export security logs to dedicated bucket"
    filter: |
      protoPayload.serviceName="cloudaudit.googleapis.com" AND
      (protoPayload.methodName:"iam" OR 
       protoPayload.methodName:"compute" OR
       protoPayload.methodName:"storage")
    destination: "storage.googleapis.com/security-logs-bucket"
    
  - name: application-logs-sink
    description: "Export application logs to BigQuery"
    filter: |
      resource.type="gce_instance" AND
      (severity="ERROR" OR severity="CRITICAL")
    destination: "bigquery.googleapis.com/projects/logging-project/datasets/application_logs"
    
  - name: network-logs-sink
    description: "Export VPC flow logs for analysis"
    filter: |
      resource.type="gce_subnetwork" AND
      jsonPayload.connection.protocol!="ICMP"
    destination: "pubsub.googleapis.com/projects/logging-project/topics/network-logs"
```

## IAM Configuration Templates

### Service Account Template
```yaml
# service-accounts.yaml
service_accounts:
  - account_id: compute-service-account
    display_name: "Compute Engine Service Account"
    description: "Service account for compute instances"
    project_roles:
      - roles/logging.logWriter
      - roles/monitoring.metricWriter
      - roles/storage.objectViewer
    
  - account_id: gke-service-account
    display_name: "GKE Service Account"
    description: "Service account for GKE clusters"
    project_roles:
      - roles/container.nodeServiceAccount
      - roles/logging.logWriter
      - roles/monitoring.metricWriter
      - roles/storage.objectViewer
    
  - account_id: terraform-service-account
    display_name: "Terraform Automation Account"
    description: "Service account for Terraform deployments"
    organization_roles:
      - roles/resourcemanager.organizationAdmin
      - roles/billing.admin
    folder_roles:
      - folder_id: "123456789"
        role: roles/resourcemanager.folderAdmin
```

### Custom Roles Template
```yaml
# custom-roles.yaml
custom_roles:
  - role_id: landing_zone_network_admin
    title: "Landing Zone Network Administrator"
    description: "Custom role for network administration in landing zone"
    stage: GA
    included_permissions:
      - compute.networks.create
      - compute.networks.delete
      - compute.networks.get
      - compute.networks.list
      - compute.subnetworks.create
      - compute.subnetworks.delete
      - compute.subnetworks.get
      - compute.subnetworks.list
      - compute.firewalls.create
      - compute.firewalls.delete
      - compute.firewalls.get
      - compute.firewalls.list
    
  - role_id: landing_zone_security_admin
    title: "Landing Zone Security Administrator"
    description: "Custom role for security administration in landing zone"
    stage: GA
    included_permissions:
      - cloudkms.keyRings.create
      - cloudkms.keyRings.get
      - cloudkms.keyRings.list
      - cloudkms.cryptoKeys.create
      - cloudkms.cryptoKeys.get
      - cloudkms.cryptoKeys.list
      - securitycenter.findings.list
      - securitycenter.sources.list
```

## Backup and Disaster Recovery Templates

### Backup Policy Template
```yaml
# backup-policies.yaml
backup_policies:
  - name: production-daily-backup
    schedule: "0 2 * * *"  # Daily at 2 AM
    retention_days: 30
    target_resources:
      - type: compute_disk
        filter: "labels.backup_policy=daily"
      - type: sql_instance
        filter: "labels.environment=production"
    
  - name: critical-hourly-backup
    schedule: "0 * * * *"  # Every hour
    retention_days: 7
    target_resources:
      - type: compute_disk
        filter: "labels.backup_policy=critical"
    
  - name: weekly-archive-backup
    schedule: "0 0 * * 0"  # Weekly on Sunday
    retention_days: 365
    storage_class: "COLDLINE"
    target_resources:
      - type: storage_bucket
        filter: "labels.data_class=archive"
```

### Disaster Recovery Configuration Template
```yaml
# disaster-recovery.yaml
disaster_recovery:
  primary_region: us-central1
  secondary_region: us-east1
  
  replication_config:
    - service: cloud_sql
      replication_type: synchronous
      backup_retention: 7
      point_in_time_recovery: true
      
    - service: cloud_storage
      replication_type: regional
      versioning: true
      lifecycle_management: true
      
    - service: compute_persistent_disk
      snapshot_schedule: daily
      cross_region_replication: true
  
  failover_procedures:
    - trigger: manual
      rto_minutes: 30  # Recovery Time Objective
      rpo_minutes: 5   # Recovery Point Objective
      
    - trigger: automatic
      health_check_failures: 3
      timeout_seconds: 300
      fallback_region: us-east1
```

## Usage Instructions

### 1. Template Selection
Choose the appropriate template based on:
- Organization size and complexity
- Security requirements
- Compliance needs
- Performance requirements
- Budget constraints

### 2. Customization Steps
1. **Copy** the relevant template
2. **Update** project IDs, organization IDs, and billing accounts
3. **Modify** network ranges to match your IP addressing plan
4. **Adjust** security controls based on requirements
5. **Configure** monitoring and alerting thresholds
6. **Review** IAM permissions and roles

### 3. Validation Process
1. **Syntax Check**: Validate YAML/HCL syntax
2. **Security Review**: Ensure least privilege principles
3. **Network Validation**: Verify IP ranges don't conflict
4. **Cost Estimation**: Calculate expected costs
5. **Compliance Check**: Verify regulatory requirements

### 4. Deployment Steps
1. **Initialize** Terraform workspace
2. **Plan** deployment with configuration
3. **Review** planned changes
4. **Apply** configuration in phases
5. **Validate** deployment success
6. **Document** any customizations

---
**Configuration Templates Version**: 1.0  
**Last Updated**: [DATE]  
**Maintained by**: Platform Engineering Team