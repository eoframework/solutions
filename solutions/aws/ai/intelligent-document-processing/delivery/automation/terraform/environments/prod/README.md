# Production Environment

Terraform configuration for the **production** environment. This environment is configured for high availability, security, and operational excellence.

## Quick Start

```bash
# Initialize (first time or after module changes)
./eo-deploy.sh init      # Linux/macOS/WSL
eo-deploy.bat init       # Windows

# Preview changes (ALWAYS review before applying!)
./eo-deploy.sh plan      # Linux/macOS/WSL
eo-deploy.bat plan       # Windows

# Apply changes
./eo-deploy.sh apply     # Linux/macOS/WSL
eo-deploy.bat apply      # Windows
```

## Environment Characteristics

| Aspect | Configuration | Notes |
|--------|---------------|-------|
| Instance sizes | Production-grade | Right-sized for workload |
| High availability | Enabled | Multi-AZ deployment |
| Backups | Full retention | 30+ days, cross-region |
| Encryption | Required | At-rest and in-transit |
| Monitoring | Comprehensive | Full observability stack |
| Debug mode | Disabled | Warn-level logging |

## Configuration Files

Located in `config/` directory:

| File | Description |
|------|-------------|
| `application.tfvars` | Production app settings |
| `best-practices.tfvars` | Full governance and compliance |
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

# Destroy all resources (USE WITH CAUTION!)
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

## Production Safeguards

### Pre-Deployment Checklist

- [ ] Review `terraform plan` output carefully
- [ ] Verify no unintended resource deletions
- [ ] Check for security group changes
- [ ] Confirm backup configurations
- [ ] Notify team of planned changes
- [ ] Schedule maintenance window if needed

### Protected Resources

The following resources have deletion protection enabled:
- RDS databases (`db_deletion_protection = true`)
- S3 buckets with data (requires manual empty before destroy)
- KMS keys (pending deletion period)

### Change Management

For production changes:

1. **Plan** - Review all changes
2. **Peer Review** - Get approval from team
3. **Schedule** - Plan maintenance window
4. **Apply** - Execute with monitoring
5. **Verify** - Confirm successful deployment

## Common Tasks

### First-Time Setup

```bash
# 1. Configure AWS credentials (use production profile)
export AWS_PROFILE=production

# 2. Initialize Terraform
./eo-deploy.sh init

# 3. Review the plan thoroughly
./eo-deploy.sh plan

# 4. Apply (creates all resources)
./eo-deploy.sh apply
```

### Update Configuration

```bash
# 1. Edit config/*.tfvars files as needed

# 2. Review changes carefully
./eo-deploy.sh plan

# 3. Apply during maintenance window
./eo-deploy.sh apply
```

### Emergency Procedures

```bash
# Rollback to previous state (if state is versioned)
# Restore previous tfvars from version control
git checkout HEAD~1 -- config/
./eo-deploy.sh plan
./eo-deploy.sh apply
```

## Troubleshooting

### "No valid credential sources found"

```bash
# Verify AWS credentials
aws sts get-caller-identity

# Set production profile
export AWS_PROFILE=production
```

### "State lock" error

```bash
# If previous run was interrupted (verify no one else is running)
terraform force-unlock <lock-id>
```

### Resource drift detected

```bash
# Refresh state to match actual infrastructure
./eo-deploy.sh refresh

# Then plan to see remaining differences
./eo-deploy.sh plan
```

## Related Documentation

- [Terraform Overview](../README.md) - Parent documentation
- [DR Environment](../dr/README.md) - Disaster recovery configuration
- [Terraform Docs](https://www.terraform.io/docs)
