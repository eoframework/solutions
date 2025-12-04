# Deployment Automation

This folder contains deployment automation for the Google Workspace solution.

```
automation/
└── platform-native/     # Platform-native approach for Google Workspace
    ├── workspace/       # Admin SDK Python scripts
    │   ├── scripts/     # Python automation
    │   ├── config/      # Environment configuration files
    │   └── templates/   # CSV templates for bulk operations
    └── gam/             # GAM command scripts for admin tasks
```

## Recommended Approach: Platform-Native

Google Workspace is best deployed using **platform-native tooling** due to:
- Limited Terraform support for Workspace administration
- Admin SDK provides comprehensive API coverage
- GAM (Google Admin Manager) for bulk operations
- Native Google tools for migration (GWMT)

## Folder Structure

```
platform-native/
├── workspace/
│   ├── scripts/
│   │   ├── python/
│   │   │   ├── requirements.txt
│   │   │   ├── setup_workspace.py      # Main deployment script
│   │   │   ├── create_users.py         # User provisioning
│   │   │   ├── create_groups.py        # Group creation
│   │   │   ├── create_org_units.py     # OU structure
│   │   │   ├── configure_sso.py        # SSO configuration
│   │   │   ├── configure_security.py   # Security policies
│   │   │   └── configure_dlp.py        # DLP rules
│   │   └── powershell/
│   │       └── migration_prep.ps1      # Exchange preparation
│   ├── config/
│   │   ├── prod.yaml                   # Production config
│   │   ├── test.yaml                   # Test config
│   │   └── credentials.json.example    # Service account template
│   └── templates/
│       ├── users.csv                   # User import template
│       ├── groups.csv                  # Group import template
│       └── distribution_lists.csv      # DL migration template
└── gam/
    └── commands/
        ├── create_users.gam            # GAM user creation
        ├── create_groups.gam           # GAM group creation
        ├── configure_sharing.gam       # GAM sharing policies
        └── generate_reports.gam        # GAM reporting
```

## Prerequisites

### Python Admin SDK
```bash
# Install dependencies
pip install -r platform-native/workspace/scripts/python/requirements.txt

# Configure service account
# 1. Create service account in GCP Console
# 2. Enable domain-wide delegation
# 3. Authorize scopes in Workspace Admin Console
# 4. Download credentials.json
```

### GAM Installation
```bash
# Install GAM
bash <(curl -s -S -L https://gam-shortn.appspot.com/gam-install)

# Authorize GAM
gam oauth create
```

## Deployment Steps

### 1. Prepare Environment
```bash
cd platform-native/workspace

# Copy and configure credentials
cp config/credentials.json.example config/credentials.json
# Edit with your service account key

# Configure environment
cp config/prod.yaml config/env.yaml
# Edit with deployment parameters
```

### 2. Create Organizational Structure
```bash
# Create OUs
python scripts/python/create_org_units.py --config config/env.yaml

# Create groups
python scripts/python/create_groups.py --config config/env.yaml
```

### 3. Configure Security Policies
```bash
# Configure SSO (if enabled)
python scripts/python/configure_sso.py --config config/env.yaml

# Configure security policies
python scripts/python/configure_security.py --config config/env.yaml

# Configure DLP (if enabled)
python scripts/python/configure_dlp.py --config config/env.yaml
```

### 4. Provision Users
```bash
# Bulk create users from CSV using GAM
cd ../gam
gam batch commands/create_users.gam

# Or using Python
cd ../workspace
python scripts/python/create_users.py --file templates/users.csv
```

## Environment Comparison

| Feature | Production | Test | DR |
|---------|------------|------|-----|
| User Count | 500 | 25 | 500 |
| SSO | Azure AD | Disabled | Azure AD |
| MFA | Enforced | Optional | Enforced |
| DLP | 15 rules | Disabled | 15 rules |
| Vault | 7 years | 1 year | 7 years |
| MDM | Advanced | Basic | Advanced |
| External Sharing | Whitelist | Disabled | Whitelist |
| GAM Automation | Enabled | Disabled | Enabled |

## DR Considerations

Google Workspace is a SaaS platform with built-in redundancy. The DR configuration (`config/dr.yaml`) documents:

- **Backup Strategy**: Google Vault retention, third-party backup options
- **Recovery Procedures**: Account, file, and email restoration methods
- **Contact Information**: Escalation paths for incidents
- **Runbook References**: Links to DR documentation
- **RTO/RPO Targets**: 4-hour RTO, 1-hour RPO

### Running All Steps

```bash
# Full deployment
python scripts/python/setup_workspace.py --config config/prod.yaml

# With dry-run preview
python scripts/python/setup_workspace.py --config config/prod.yaml --dry-run

# Individual step
python scripts/python/setup_workspace.py --config config/prod.yaml --step org-units
```

## Configuration Reference

Configuration is loaded from `delivery/raw/configuration.csv` and converted to YAML config files.

| Environment | Config File | Description |
|-------------|-------------|-------------|
| Production | `config/prod.yaml` | Full production deployment |
| Test | `config/test.yaml` | Minimal test environment |
| DR | `config/dr.yaml` | DR documentation and settings |
