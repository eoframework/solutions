# Test Environment

Terraform configuration for the **test** environment. This environment is optimized for development and testing with minimal costs and simplified configurations.

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
| Instance sizes | Minimal (t3.micro, etc.) | Cost optimization |
| High availability | Disabled | Single AZ deployment |
| Backups | Minimal retention | 7 days or less |
| Encryption | Optional | Simplified testing |
| Monitoring | Basic | Essential metrics only |
| Debug mode | Enabled | Verbose logging |

## Configuration Files

Located in `config/` directory:

| File | Description |
|------|-------------|
| `application.tfvars` | App settings with debug enabled |
| `best-practices.tfvars` | Minimal governance (budget alerts only) |
| `cache.tfvars` | ElastiCache disabled by default |

## eo-deploy.sh Usage

### Basic Commands

```bash
# Initialize Terraform
./eo-deploy.sh init

# Create execution plan
./eo-deploy.sh plan

# Apply configuration
./eo-deploy.sh apply

# Destroy all resources
./eo-deploy.sh destroy

# Validate configuration
./eo-deploy.sh validate

# Format files
./eo-deploy.sh fmt
```

### Advanced Usage

```bash
# Auto-approve (skip confirmation)
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

## Common Tasks

### First-Time Setup

```bash
# 1. Configure AWS credentials
export AWS_PROFILE=your-profile

# 2. Initialize Terraform
./eo-deploy.sh init

# 3. Review the plan
./eo-deploy.sh plan

# 4. Apply (creates all resources)
./eo-deploy.sh apply
```

### Update Configuration

```bash
# 1. Edit config/*.tfvars files as needed

# 2. Review changes
./eo-deploy.sh plan

# 3. Apply changes
./eo-deploy.sh apply
```

### Tear Down Environment

```bash
# Destroy all resources (will prompt for confirmation)
./eo-deploy.sh destroy
```

## Troubleshooting

### "No valid credential sources found"

```bash
# Verify AWS credentials
aws sts get-caller-identity

# Set profile if needed
export AWS_PROFILE=your-profile
```

### "State lock" error

```bash
# If previous run was interrupted
terraform force-unlock <lock-id>
```

### Module errors after updates

```bash
# Re-initialize with upgrade flag
./eo-deploy.sh init -upgrade
```

## Related Documentation

- [Terraform Overview](../README.md) - Parent documentation
- [Terraform Docs](https://www.terraform.io/docs)
