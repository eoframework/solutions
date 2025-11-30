# Disaster Recovery (DR) Environment

Terraform configuration for the **disaster recovery** environment. This environment mirrors production and is designed for business continuity during outages.

## Quick Start

```bash
# Initialize (first time or after module changes)
./eo-deploy.sh init      # Linux/macOS/WSL
eo-deploy.bat init       # Windows

# Preview changes
./eo-deploy.sh plan      # Linux/macOS/WSL
eo-deploy.bat plan       # Windows

# Apply changes
./eo-deploy.sh apply     # Linux/macOS/WSL
eo-deploy.bat apply      # Windows
```

## Environment Characteristics

| Aspect | Configuration | Notes |
|--------|---------------|-------|
| Instance sizes | Matches production | Ready for failover |
| High availability | Enabled | Multi-AZ deployment |
| Backups | Cross-region | Replicated from prod |
| Encryption | Required | Same keys/policies as prod |
| Monitoring | Comprehensive | Failover alerting |
| Region | Secondary | Geographically separated |

## Configuration Files

Located in `config/` directory:

| File | Description |
|------|-------------|
| `application.tfvars` | DR app settings (matches prod) |
| `best-practices.tfvars` | DR-focused governance |
| `cache.tfvars` | ElastiCache with HA enabled |

## eo-deploy.sh Usage

### Basic Commands

```bash
# Initialize Terraform
./eo-deploy.sh init

# Create execution plan
./eo-deploy.sh plan

# Apply configuration
./eo-deploy.sh apply

# Destroy all resources (USE WITH EXTREME CAUTION!)
./eo-deploy.sh destroy

# Validate configuration
./eo-deploy.sh validate

# Format files
./eo-deploy.sh fmt
```

### Advanced Usage

```bash
# Auto-approve (use only in CI/CD with proper gates)
./eo-deploy.sh apply -auto-approve

# Target specific resource
./eo-deploy.sh plan -target=module.vpc

# Show outputs
./eo-deploy.sh output

# Show current state
./eo-deploy.sh show
```

### Windows Usage

Replace `./eo-deploy.sh` with `eo-deploy.bat`:

```cmd
eo-deploy.bat init
eo-deploy.bat plan
eo-deploy.bat apply
```

## DR Operations

### Failover Procedure

In case of production outage:

1. **Assess** - Confirm production is unavailable
2. **Notify** - Alert stakeholders of failover
3. **Verify DR** - Ensure DR environment is healthy
   ```bash
   ./eo-deploy.sh plan  # Should show no changes
   ```
4. **Update DNS** - Point traffic to DR region
5. **Monitor** - Watch for issues during failover
6. **Document** - Record timeline and actions

### Failback Procedure

When production is restored:

1. **Verify Production** - Confirm prod is healthy
2. **Sync Data** - Replicate DR changes back to prod
3. **Test Production** - Validate functionality
4. **Update DNS** - Point traffic back to production
5. **Monitor** - Watch for issues during failback

### DR Testing

Regular DR testing schedule:

```bash
# Quarterly DR test procedure
# 1. Deploy fresh DR environment
./eo-deploy.sh init
./eo-deploy.sh apply

# 2. Verify all resources
./eo-deploy.sh output

# 3. Run application smoke tests
# 4. Document results
# 5. Clean up if using separate test DR
```

## Common Tasks

### First-Time Setup

```bash
# 1. Configure AWS credentials (use DR region profile)
export AWS_PROFILE=dr-region
export AWS_REGION=us-west-2  # Example DR region

# 2. Initialize Terraform
./eo-deploy.sh init

# 3. Review the plan
./eo-deploy.sh plan

# 4. Apply (creates all resources)
./eo-deploy.sh apply
```

### Keep DR in Sync with Production

```bash
# After production changes, apply same to DR
# 1. Copy updated tfvars from prod if needed
# 2. Review changes
./eo-deploy.sh plan

# 3. Apply to keep DR current
./eo-deploy.sh apply
```

### Verify DR Readiness

```bash
# Check DR state matches expected
./eo-deploy.sh plan
# Output should show: "No changes. Infrastructure is up-to-date."
```

## Troubleshooting

### "No valid credential sources found"

```bash
# Verify AWS credentials for DR region
aws sts get-caller-identity

# Set DR profile
export AWS_PROFILE=dr-region
```

### "State lock" error

```bash
# If previous run was interrupted
terraform force-unlock <lock-id>
```

### Cross-region replication issues

```bash
# Check replication status in AWS console
# Verify IAM permissions for cross-region access
# Check KMS key policies allow DR region
```

## Related Documentation

- [Terraform Overview](../README.md) - Parent documentation
- [Production Environment](../prod/README.md) - Primary environment
- [Terraform Docs](https://www.terraform.io/docs)
