# Disaster Recovery (DR) Environment

Terraform configuration for the **disaster recovery** environment. This environment mirrors production and is designed for business continuity during outages.

## Architecture Overview

```
                            AWS Backup Cross-Region Replication
                    ┌──────────────────────────────────────────────────┐
                    │                                                  │
                    ▼                                                  │
┌─────────────────────────────────────┐      ┌─────────────────────────────────────┐
│     PRODUCTION (us-east-1)          │      │     DR (us-west-2)                  │
│                                     │      │                                     │
│  ┌───────────────────────────────┐  │      │  ┌───────────────────────────────┐  │
│  │  dr-replication module        │  │      │  │  dr-vault module              │  │
│  │  ─────────────────────────────│  │      │  │  ─────────────────────────────│  │
│  │  AWS Backup:                  │──┼──────┼─▶│  Backup Vault:                │  │
│  │  • Daily EC2 AMI backup       │  │      │  │  • Receives copies            │  │
│  │  • Daily RDS snapshot         │  │      │  │  • 30-day retention           │  │
│  │  • Weekly backup (90d)        │  │      │  │  • Restore IAM role           │  │
│  │  • Tag-based selection        │  │      │  │  • Optional vault lock        │  │
│  └───────────────────────────────┘  │      │  └───────────────────────────────┘  │
│                                     │      │                                     │
│  ┌─────────┐  ┌─────────┐  ┌─────┐ │      │  ┌─────────┐  ┌─────────┐  ┌─────┐ │
│  │   ALB   │  │   ASG   │  │ RDS │ │      │  │   ALB   │  │   ASG   │  │ RDS │ │
│  │ Active  │  │  2-10   │  │ M-AZ│ │      │  │ Standby │  │   1-10  │  │ M-AZ│ │
│  └─────────┘  └─────────┘  └─────┘ │      │  └─────────┘  └─────────┘  └─────┘ │
│                                     │      │       │                            │
│  ┌─────────┐  ┌─────────┐  ┌─────┐ │      │  ┌────┴────┐  ┌─────────┐  ┌─────┐ │
│  │  Redis  │  │   WAF   │  │Guard│ │      │  │  Redis  │  │   WAF   │  │Guard│ │
│  │ Cluster │  │ Enabled │  │Duty │ │      │  │ Cluster │  │Disabled │  │Duty │ │
│  └─────────┘  └─────────┘  └─────┘ │      │  └─────────┘  └─────────┘  └─────┘ │
│                                     │      │                 ▲           ▲      │
└─────────────────────────────────────┘      │            (managed at prod)       │
                                             └─────────────────────────────────────┘
```

## DR vs Production Differences

| Component | Production (us-east-1) | DR (us-west-2) | How Restored |
|-----------|------------------------|----------------|--------------|
| **Region** | us-east-1 (primary) | us-west-2 (secondary) | - |
| **VPC CIDR** | 10.0.0.0/16 | 10.1.0.0/16 | VPC peering compatible |
| **EC2/ASG** | Min: 2, Desired: 3 | Min: 1, Desired: 1 | AWS Backup restores AMI |
| **RDS** | Primary Multi-AZ | Multi-AZ (restored) | Snapshot from DR vault |
| **ElastiCache** | Primary cluster | Fresh cluster | Warms from RDS |
| **ALB** | Active (receives traffic) | Standby (ready) | DNS failover |
| **WAF** | Enabled | **Disabled** | Managed at prod |
| **GuardDuty** | Enabled | **Disabled** | Managed at prod |
| **Backup Module** | Creates backups | **Disabled** | Receives from prod |
| **DR Vault** | Not present | **Enabled** | Stores replicated backups |
| **KMS** | Prod KMS key | DR KMS key | Separate keys per region |
| **CloudTrail** | Enabled | Enabled | Independent audit trail |

## Backup Replication Flow

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                          BACKUP REPLICATION WORKFLOW                            │
└─────────────────────────────────────────────────────────────────────────────────┘

   PRODUCTION (us-east-1)                              DR (us-west-2)
   ─────────────────────                              ────────────────

   ┌──────────────────────────────┐
   │ Resources with Backup=true   │
   │ ┌────────┐ ┌────────┐ ┌────┐ │
   │ │EC2 AMI │ │  RDS   │ │EBS │ │
   │ └────┬───┘ └───┬────┘ └─┬──┘ │
   └──────┼─────────┼────────┼────┘
          │         │        │
          ▼         ▼        ▼
   ┌──────────────────────────────┐
   │   AWS Backup Service         │
   │   (dr-replication module)    │
   │                              │
   │   Schedule: Daily 5 AM UTC   │
   │   Local retention: 7 days    │
   └──────────────┬───────────────┘
                  │
                  │ Cross-Region Copy
                  │ (encrypted with DR KMS key)
                  │
                  ▼
          ┌──────────────────────────────┐
          │   DR Backup Vault            │
          │   (dr-vault module)          │
          │                              │
          │   Retention: 30 days         │
          │   Weekly backups: 90 days    │
          │   Optional vault lock        │
          └──────────────────────────────┘
```

## Failover Process

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              DR FAILOVER WORKFLOW                               │
└─────────────────────────────────────────────────────────────────────────────────┘

   BEFORE FAILOVER                           AFTER FAILOVER
   ────────────────                          ───────────────

   Users                                     Users
     │                                         │
     ▼                                         ▼
   ┌─────────┐                               ┌─────────┐
   │  DNS    │                               │  DNS    │
   │ (prod)  │                               │  (DR)   │
   └────┬────┘                               └────┬────┘
        │                                         │
        ▼                                         ▼
   ┌─────────┐      DNS Switch              ┌─────────┐
   │  Prod   │  ═══════════════════════▶    │   DR    │
   │  ALB    │  (Manual or Route53)         │   ALB   │
   └────┬────┘                              └────┬────┘
        │                                        │
        ▼                                        ▼
   ┌─────────┐                              ┌─────────┐
   │  Prod   │      Scale Up ASG            │   DR    │
   │  ASG    │  ─────────────────────▶      │  ASG    │
   │  (2-10) │  (from 1 to desired)         │ (1→3)   │
   └─────────┘                              └─────────┘

   ┌─────────────────────────────────────────────────────────────────┐
   │ RESTORE PROCEDURE:                                              │
   │                                                                 │
   │ 1. Restore RDS from latest snapshot in DR vault                │
   │    └─▶ aws backup start-restore-job --recovery-point-arn ...   │
   │                                                                 │
   │ 2. Update RDS endpoint in application config                   │
   │    └─▶ Parameter Store / Secrets Manager                       │
   │                                                                 │
   │ 3. Scale up ASG to production capacity                         │
   │    └─▶ aws autoscaling update-auto-scaling-group               │
   │        --min-size 2 --desired-capacity 3                       │
   │                                                                 │
   │ 4. Switch DNS to DR ALB                                        │
   │    └─▶ Route53 record update or automatic failover             │
   │                                                                 │
   │ 5. Cache warms automatically from restored RDS                 │
   └─────────────────────────────────────────────────────────────────┘
```

## DNS Failover Options

### Option 1: Manual DNS Failover (Default)

```
┌────────────────────────────────────────────────────────────────┐
│ MANUAL FAILOVER                                                │
│                                                                │
│ 1. Operations team detects prod outage                        │
│ 2. Manually update Route53 A record to DR ALB                 │
│ 3. Wait for DNS TTL propagation                               │
│                                                                │
│ RTO: 15-30 minutes (depends on TTL + manual intervention)     │
│ RPO: Last backup (typically < 24 hours)                       │
└────────────────────────────────────────────────────────────────┘
```

### Option 2: Route53 Health Checks (Automatic)

```
┌────────────────────────────────────────────────────────────────┐
│ AUTOMATIC FAILOVER (requires additional Route53 config)       │
│                                                                │
│     Route53                                                    │
│        │                                                       │
│        ▼                                                       │
│  ┌───────────────┐                                            │
│  │ Health Check  │──▶ /health endpoint                        │
│  │ (every 10s)   │                                            │
│  └───────┬───────┘                                            │
│          │                                                     │
│          ▼                                                     │
│  ┌───────────────────────────────────────┐                    │
│  │ Failover Routing Policy               │                    │
│  │                                       │                    │
│  │  Primary: prod-alb.us-east-1...      │                    │
│  │  Secondary: dr-alb.us-west-2...      │                    │
│  └───────────────────────────────────────┘                    │
│                                                                │
│ RTO: ~2 minutes (health check failures + propagation)         │
│ RPO: Last backup (typically < 24 hours)                       │
└────────────────────────────────────────────────────────────────┘
```

## Configuration Files

DR uses **grouped object variables** (same pattern as prod/test):

| File | Description |
|------|-------------|
| `config/project.tfvars` | AWS region (us-west-2), ownership |
| `config/application.tfvars` | Solution identity (same as prod) |
| `config/networking.tfvars` | VPC (10.1.0.0/16), ALB, subnets |
| `config/security.tfvars` | KMS enabled, WAF/GuardDuty **disabled** |
| `config/compute.tfvars` | ASG (1-10 standby), instance types |
| `config/database.tfvars` | RDS config (same as prod) |
| `config/cache.tfvars` | ElastiCache config (same as prod) |
| `config/monitoring.tfvars` | CloudWatch, alarms |
| `config/best-practices.tfvars` | Backup **disabled**, budgets enabled |
| `config/dr-vault.tfvars` | **DR-specific**: vault configuration |

## Quick Start

```bash
# 1. Ensure production is deployed first
cd ../prod
./eo-deploy.sh apply

# 2. Get production outputs (needed for dr-replication config)
terraform output dr_replication_vault_arn  # Copy this to prod dr-replication.tfvars

# 3. Deploy DR environment
cd ../dr
./eo-deploy.sh init
./eo-deploy.sh plan
./eo-deploy.sh apply

# 4. Update prod dr-replication.tfvars with DR vault ARN
# Edit prod/config/dr-replication.tfvars:
#   dr_vault_arn = "<output from step 2>"
#   dr_kms_key_arn = "<DR KMS key ARN>"

# 5. Re-apply prod to enable cross-region backup
cd ../prod
./eo-deploy.sh apply
```

## Deployment Order

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           DEPLOYMENT SEQUENCE                                   │
└─────────────────────────────────────────────────────────────────────────────────┘

   STEP 1                    STEP 2                    STEP 3
   ──────                    ──────                    ──────

┌──────────────┐        ┌──────────────┐        ┌──────────────┐
│ Deploy PROD  │───────▶│  Deploy DR   │───────▶│ Update PROD  │
│ (us-east-1)  │        │  (us-west-2) │        │ dr-replication│
└──────────────┘        └──────────────┘        └──────────────┘
       │                       │                       │
       │                       │                       │
       ▼                       ▼                       ▼
• VPC, ALB, ASG         • VPC, ALB, ASG         • Enable backup
• RDS, Redis            • RDS, Redis              replication
• WAF, GuardDuty        • DR Vault              • Set dr_vault_arn
• Monitoring            • Monitoring            • Set dr_kms_key_arn
• dr-replication        • (no backup plans)
  (disabled initially)
```

## DR Operations

### Failover Procedure

```bash
# 1. ASSESS - Confirm production is unavailable
./eo-deploy.sh plan  # DR should show no changes

# 2. RESTORE RDS - Restore from latest backup in DR vault
aws backup start-restore-job \
  --recovery-point-arn "arn:aws:backup:us-west-2:ACCOUNT:recovery-point:xxx" \
  --iam-role-arn "$(terraform output -raw dr_restore_role_arn)" \
  --resource-type RDS \
  --metadata '{"DBInstanceClass":"db.t3.medium"}'

# 3. SCALE ASG - Increase to production capacity
aws autoscaling update-auto-scaling-group \
  --auto-scaling-group-name "$(terraform output -raw asg_name)" \
  --min-size 2 --desired-capacity 3

# 4. UPDATE DNS - Point traffic to DR ALB
# Manual: Update Route53 A record to DR ALB DNS name
# Or: Route53 automatic failover activates

# 5. MONITOR - Watch CloudWatch dashboard
# DR dashboard shows all metrics
```

### Failback Procedure

```bash
# 1. VERIFY PROD - Confirm production is healthy
cd ../prod && ./eo-deploy.sh plan

# 2. SYNC DATA - Export DR data, import to prod
# (Application-specific data migration)

# 3. UPDATE DNS - Point traffic back to production
# Update Route53 or disable failover

# 4. SCALE DOWN DR - Return to standby capacity
cd ../dr
aws autoscaling update-auto-scaling-group \
  --auto-scaling-group-name "$(terraform output -raw asg_name)" \
  --min-size 1 --desired-capacity 1
```

## DR Types Comparison

| Type | RTO | RPO | Cost | Description |
|------|-----|-----|------|-------------|
| **Backup & Restore** | Hours | Hours | Lowest | Restore from backups only |
| **Pilot Light** | Hours | Minutes | Low | DB replica, minimal compute |
| **Warm Standby** | Minutes | Minutes | Medium | Reduced capacity, scale on failover |
| **Hot Standby** | Seconds | Near-zero | High | Full capacity, instant failover |
| **Active-Active** | None | None | Highest | Both regions serve traffic |

**This template uses Warm Standby:**
- Reduced ASG capacity (1 instance standby)
- Full capacity available on scale-up
- AWS Backup for cross-region data replication
- Manual or automatic DNS failover

## Troubleshooting

### "No valid credential sources found"

```bash
# Verify AWS credentials for DR region
export AWS_PROFILE=dr-region
export AWS_REGION=us-west-2
aws sts get-caller-identity
```

### Backup not appearing in DR vault

```bash
# Check backup job status in production
aws backup list-backup-jobs --by-resource-type RDS --region us-east-1

# Check copy job status
aws backup list-copy-jobs --region us-east-1

# Verify DR vault exists
aws backup list-backup-vaults --region us-west-2
```

### RDS restore fails

```bash
# List available recovery points in DR vault
aws backup list-recovery-points-by-backup-vault \
  --backup-vault-name "$(terraform output -raw dr_vault_name)" \
  --region us-west-2

# Check restore job status
aws backup describe-restore-job --restore-job-id <job-id> --region us-west-2
```

## Related Documentation

- [Production Environment](../prod/README.md) - Primary environment
- [Test Environment](../test/README.md) - Testing environment
- [Modules Documentation](../../modules/README.md) - Module details
- [Terraform Overview](../README.md) - Parent documentation
