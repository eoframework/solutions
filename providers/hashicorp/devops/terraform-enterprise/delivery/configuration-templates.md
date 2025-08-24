# HashiCorp Terraform Enterprise Configuration Templates

## Overview
This document provides standardized configuration templates for deploying and managing the HashiCorp Terraform Enterprise platform. These templates ensure consistency, security, and best practices across all deployments.

## Terraform Configuration Templates

### Basic Production Configuration
```hcl
# terraform.tfvars - Production Configuration
project_name = "tfe-production"
environment  = "prod"
owner        = "platform-team"
cost_center  = "engineering"

# AWS Configuration
aws_region              = "us-east-1"
terraform_state_bucket  = "company-terraform-state"
admin_role_name        = "OrganizationAccountAccessRole"

# Network Configuration
vpc_cidr = "10.100.0.0/16"

public_subnet_cidrs = [
  "10.100.1.0/24",
  "10.100.2.0/24", 
  "10.100.3.0/24"
]

private_subnet_cidrs = [
  "10.100.10.0/24",
  "10.100.11.0/24",
  "10.100.12.0/24"
]

database_subnet_cidrs = [
  "10.100.20.0/24",
  "10.100.21.0/24",
  "10.100.22.0/24"
]

# EKS Configuration
kubernetes_version = "1.28"
node_instance_types = ["m5.xlarge", "m5.2xlarge"]
min_node_count     = 3
max_node_count     = 20
desired_node_count = 6

# Database Configuration
postgres_version        = "14.9"
db_instance_class      = "db.r5.xlarge"
db_allocated_storage   = 500
db_max_allocated_storage = 5000
enable_multi_az        = true

# Domain and SSL
domain_name       = "tfe.company.com"
create_dns_record = true

# Security Configuration
enable_encryption = true
allowed_cidr_blocks = [
  "10.0.0.0/8",      # Corporate network
  "172.16.0.0/16"    # VPN network
]
enable_waf = true
compliance_mode = true
```

### High Availability Configuration
```hcl
# terraform.tfvars - High Availability Configuration
project_name = "tfe-ha"
environment  = "prod"

# Multi-AZ Configuration
enable_multi_az = true
enable_cross_region_backup = true
backup_region = "us-west-2"

# Enhanced EKS Configuration
kubernetes_version = "1.28"
node_instance_types = ["m5.2xlarge", "m5.4xlarge"]
min_node_count     = 6
max_node_count     = 30
desired_node_count = 12

# Database High Availability
postgres_version        = "14.9"
db_instance_class      = "db.r5.2xlarge"
db_allocated_storage   = 1000
db_max_allocated_storage = 10000
enable_multi_az        = true
enable_performance_insights = true

# TFE High Availability
tfe_replica_count = 5
tfe_resources = {
  requests = {
    cpu    = "4000m"
    memory = "8Gi"
  }
  limits = {
    cpu    = "8000m"
    memory = "16Gi"
  }
}

# Enhanced Backup
enable_backup = true
backup_schedule = "0 */6 * * *"  # Every 6 hours
backup_retention_days = 90
enable_cross_region_backup = true
```

## Kubernetes Configuration Templates

### Terraform Enterprise Helm Values
```yaml
# tfe-production-values.yaml
global:
  domain: "tfe.company.com"
  enableMetrics: true
  enableTracing: true

tfe:
  replicaCount: 3
  
  image:
    repository: hashicorp/terraform-enterprise
    tag: "v202401-1"
    pullPolicy: Always

  resources:
    requests:
      cpu: "2000m"
      memory: "4Gi"
    limits:
      cpu: "4000m"
      memory: "8Gi"

  env:
    - name: TFE_OPERATIONAL_MODE
      value: "active-active"
    
    - name: TFE_CAPACITY_CONCURRENCY
      value: "20"
    
    - name: TFE_LOG_LEVEL
      value: "INFO"
    
    - name: TFE_TLS_ENFORCE
      value: "true"
    
    - name: TFE_METRICS_ENABLE
      value: "true"

service:
  type: ClusterIP
  port: 443
  targetPort: 8443

ingress:
  enabled: true
  className: "alb"
  annotations:
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTPS": 443}]'
    alb.ingress.kubernetes.io/ssl-redirect: "443"
  hosts:
    - host: "tfe.company.com"
      paths:
        - path: /
          pathType: Prefix

persistence:
  enabled: true
  storageClass: "gp3"
  accessModes:
    - ReadWriteOnce
  size: 500Gi

autoscaling:
  enabled: true
  minReplicas: 3
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70
  targetMemoryUtilizationPercentage: 80
```

### Network Policies
```yaml
# network-policies.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: terraform-enterprise-netpol
  namespace: terraform-enterprise
spec:
  podSelector:
    matchLabels:
      app: terraform-enterprise
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: ingress-system
    ports:
    - protocol: TCP
      port: 8443
  - from:
    - namespaceSelector:
        matchLabels:
          name: monitoring
    ports:
    - protocol: TCP
      port: 9090
  egress:
  - to: []
    ports:
    - protocol: TCP
      port: 443
    - protocol: TCP
      port: 5432
    - protocol: UDP
      port: 53
```

## Security Configuration Templates

### Sentinel Policies
```hcl
# sentinel-policies/restrict-instance-types.sentinel
import "tfplan/v2" as tfplan

# List of allowed instance types
allowed_instance_types = [
  "t3.micro",
  "t3.small", 
  "t3.medium",
  "t3.large",
  "m5.large",
  "m5.xlarge"
]

# Rule to enforce allowed instance types
main = rule {
  all tfplan.resource_changes as _, rc {
    rc.type is "aws_instance" and
    rc.mode is "managed" and
    (rc.change.actions contains "create" or
     rc.change.actions contains "update") implies
    rc.change.after.instance_type in allowed_instance_types
  }
}
```

```hcl
# sentinel-policies/require-tags.sentinel
import "tfplan/v2" as tfplan

# Required tags
required_tags = [
  "Environment",
  "Owner",
  "Project", 
  "CostCenter"
]

# Rule to enforce required tags
main = rule {
  all tfplan.resource_changes as _, rc {
    rc.type in ["aws_instance", "aws_s3_bucket", "aws_rds_cluster"] and
    rc.mode is "managed" and
    (rc.change.actions contains "create" or
     rc.change.actions contains "update") implies
    all required_tags as tag {
      rc.change.after.tags[tag] else false
    }
  }
}
```

### IAM Policy Templates
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "TerraformEnterpriseAccess",
      "Effect": "Allow",
      "Action": [
        "ec2:*",
        "s3:*",
        "rds:*",
        "eks:*",
        "iam:ListRoles",
        "iam:PassRole",
        "kms:*"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "aws:RequestedRegion": ["us-east-1", "us-west-2"]
        }
      }
    },
    {
      "Sid": "DenyDestructiveActions",
      "Effect": "Deny",
      "Action": [
        "s3:DeleteBucket",
        "rds:DeleteDBInstance",
        "eks:DeleteCluster"
      ],
      "Resource": "*",
      "Condition": {
        "StringNotEquals": {
          "aws:username": "terraform-enterprise-admin"
        }
      }
    }
  ]
}
```

## Monitoring Configuration Templates

### Prometheus Configuration
```yaml
# prometheus-config.yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - "terraform-enterprise-rules.yml"

scrape_configs:
  - job_name: 'terraform-enterprise'
    static_configs:
      - targets: ['tfe.company.com:9090']
    metrics_path: '/metrics'
    scheme: 'https'
    
  - job_name: 'kubernetes-pods'
    kubernetes_sd_configs:
      - role: pod
    relabel_configs:
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
        action: keep
        regex: true
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
        action: replace
        target_label: __metrics_path__
        regex: (.+)

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - alertmanager.monitoring.svc.cluster.local:9093
```

### Alerting Rules
```yaml
# terraform-enterprise-rules.yml
groups:
- name: terraform-enterprise
  rules:
  - alert: TerraformEnterpriseDown
    expr: up{job="terraform-enterprise"} == 0
    for: 5m
    labels:
      severity: critical
    annotations:
      summary: "Terraform Enterprise is down"
      description: "Terraform Enterprise has been down for more than 5 minutes."

  - alert: TerraformEnterpriseHighCPU
    expr: rate(container_cpu_usage_seconds_total{pod=~"terraform-enterprise-.*"}[5m]) * 100 > 80
    for: 10m
    labels:
      severity: warning
    annotations:
      summary: "Terraform Enterprise high CPU usage"
      description: "CPU usage is above 80% for {{ $labels.pod }}"

  - alert: TerraformEnterpriseHighMemory
    expr: container_memory_usage_bytes{pod=~"terraform-enterprise-.*"} / container_spec_memory_limit_bytes * 100 > 85
    for: 10m
    labels:
      severity: warning
    annotations:
      summary: "Terraform Enterprise high memory usage"
      description: "Memory usage is above 85% for {{ $labels.pod }}"
```

## Backup Configuration Templates

### Database Backup Script
```bash
#!/bin/bash
# backup-database.sh

set -euo pipefail

# Configuration
DB_HOST="${TFE_DATABASE_HOST}"
DB_NAME="${TFE_DATABASE_NAME}"
DB_USER="${TFE_DATABASE_USER}"
BACKUP_BUCKET="${TFE_BACKUP_BUCKET}"
BACKUP_PREFIX="database-backups"
RETENTION_DAYS=30

# Create backup
BACKUP_FILE="tfe-db-backup-$(date +%Y%m%d-%H%M%S).sql"

echo "Creating database backup: ${BACKUP_FILE}"
pg_dump -h "${DB_HOST}" -U "${DB_USER}" -d "${DB_NAME}" > "${BACKUP_FILE}"

# Compress backup
gzip "${BACKUP_FILE}"
BACKUP_FILE="${BACKUP_FILE}.gz"

# Upload to S3
echo "Uploading backup to S3..."
aws s3 cp "${BACKUP_FILE}" "s3://${BACKUP_BUCKET}/${BACKUP_PREFIX}/${BACKUP_FILE}"

# Clean up local file
rm "${BACKUP_FILE}"

# Clean up old backups
echo "Cleaning up backups older than ${RETENTION_DAYS} days..."
aws s3 ls "s3://${BACKUP_BUCKET}/${BACKUP_PREFIX}/" | \
  while read -r line; do
    backup_date=$(echo $line | awk '{print $1}')
    backup_file=$(echo $line | awk '{print $4}')
    
    if [[ $(date -d "${backup_date}" +%s) -lt $(date -d "-${RETENTION_DAYS} days" +%s) ]]; then
      echo "Deleting old backup: ${backup_file}"
      aws s3 rm "s3://${BACKUP_BUCKET}/${BACKUP_PREFIX}/${backup_file}"
    fi
  done

echo "Database backup completed successfully"
```

## Usage Instructions

### Environment Setup
1. **Copy Configuration Template**: Choose appropriate template for your environment
2. **Customize Values**: Update all placeholder values with environment-specific data
3. **Validate Configuration**: Run `terraform validate` to check syntax
4. **Security Review**: Review all security settings and access controls

### Deployment Process
1. **Initialize Terraform**: `terraform init`
2. **Plan Deployment**: `terraform plan -var-file=terraform.tfvars`
3. **Review Changes**: Carefully review all planned changes
4. **Apply Configuration**: `terraform apply -var-file=terraform.tfvars`
5. **Validate Deployment**: Run post-deployment validation tests

### Configuration Management
- Store sensitive values in AWS Secrets Manager or HashiCorp Vault
- Use Terraform workspaces for environment separation
- Implement proper state file management and locking
- Regular backup of Terraform state files
- Document all customizations and deviations from templates

---
**Configuration Templates Version**: 1.0  
**Last Updated**: 2024-01-15  
**Maintained by**: Platform Engineering Team