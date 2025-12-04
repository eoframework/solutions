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

## Well-Architected Framework

This solution implements the Google Workspace Well-Architected Framework across all five pillars:

### Operational Excellence
| Feature | Production | Test | DR |
|---------|------------|------|-----|
| Org Units | Full hierarchy | Full hierarchy | Full hierarchy |
| Groups | 4 default groups | 1 group | 4 default groups |
| GAM Automation | Enabled | Disabled | Enabled |
| Admin SDK | Enabled | Disabled | Enabled |
| Training Hours | 8 | 4 | 8 |
| Change Champions | 10 | 2 | 10 |

### Security
| Feature | Production | Test | DR |
|---------|------------|------|-----|
| SSO | Azure AD | Disabled | Azure AD |
| MFA | Enforced | Optional | Enforced |
| DLP Rules | 15 | 0 | 15 |
| Google Vault | 7 years | 1 year | 7 years |
| MDM Level | Advanced | Basic | Advanced |
| Context-Aware Access | Enabled | Disabled | Enabled |
| External Sharing | Whitelist | Disabled | Whitelist |

### Reliability
| Feature | Production | Test | DR |
|---------|------------|------|-----|
| Directory Sync | 4 hours | Disabled | 4 hours |
| Vault Backup | Enabled | Disabled | Enabled |
| Hypercare | 30 days | 14 days | 30 days |
| RTO | - | - | 4 hours |
| RPO | - | - | 1 hour |
| DR Testing | - | - | Quarterly |

### Performance Efficiency
| Feature | Production | Test | DR |
|---------|------------|------|-----|
| Edition | Business Plus | Business Starter | Business Plus |
| Users | 500 | 25 | 500 |
| Shared Drives | 15 | 3 | 15 |
| Meet Recording | Enabled | Disabled | Enabled |
| Meet Participants | 500 | 100 | 500 |

### Cost Optimization
| Feature | Production | Test | DR |
|---------|------------|------|-----|
| License Cost/mo | $9,000 | $450 | $9,000 |
| Prof Services | $38,400 | $9,600 | $38,400 |
| Training Budget | $5,000 | $1,000 | $5,000 |

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
│   │   └── python/
│   │       ├── requirements.txt
│   │       ├── setup_workspace.py      # Main deployment orchestrator
│   │       ├── create_org_units.py     # OU structure
│   │       ├── create_groups.py        # Group creation
│   │       ├── configure_sso.py        # SSO configuration
│   │       ├── configure_security.py   # Security policies
│   │       └── configure_dlp.py        # DLP rules
│   ├── config/
│   │   ├── prod.yaml                   # Production config
│   │   ├── test.yaml                   # Test config
│   │   └── dr.yaml                     # DR config
│   ├── templates/
│   │   ├── users.csv                   # User import template
│   │   └── groups.csv                  # Group import template
│   └── eo-deploy.sh                    # Deployment wrapper script
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

## Deployment

### Using eo-deploy.sh (Recommended)

```bash
cd platform-native/workspace

# Set environment (default: prod)
export EO_ENVIRONMENT=prod

# Preview all changes (dry-run)
./eo-deploy.sh plan

# Full deployment
./eo-deploy.sh deploy

# Individual steps
./eo-deploy.sh org-units      # Create organizational units
./eo-deploy.sh groups         # Create groups
./eo-deploy.sh sso            # Configure SSO
./eo-deploy.sh security       # Configure security policies
./eo-deploy.sh dlp            # Configure DLP

# Validate configuration
./eo-deploy.sh validate
```

### Using Python Directly

```bash
cd platform-native/workspace

# Full deployment
python scripts/python/setup_workspace.py --config config/prod.yaml

# With dry-run preview
python scripts/python/setup_workspace.py --config config/prod.yaml --dry-run

# Individual step
python scripts/python/setup_workspace.py --config config/prod.yaml --step org-units
```

### Using GAM

```bash
cd platform-native/gam

# Bulk create users from CSV
gam batch commands/create_users.gam

# Create groups
gam batch commands/create_groups.gam

# Configure sharing policies
gam batch commands/configure_sharing.gam
```

## DR Considerations

Google Workspace is a SaaS platform with built-in redundancy. The DR configuration (`config/dr.yaml`) documents:

- **Backup Strategy**: Google Vault retention, third-party backup options
- **Recovery Procedures**: Account, file, and email restoration methods
- **Contact Information**: Escalation paths for incidents
- **Runbook References**: Links to DR documentation
- **RTO/RPO Targets**: 4-hour RTO, 1-hour RPO

### DR Testing

DR testing should be conducted quarterly:
1. Verify Vault search and export functionality
2. Test account recovery procedures
3. Validate data restoration from trash/Vault
4. Review security incident response procedures
5. Update runbook documentation

## Configuration Reference

Configuration is loaded from `delivery/raw/configuration.csv` and converted to YAML config files.

| Environment | Config File | Description |
|-------------|-------------|-------------|
| Production | `config/prod.yaml` | Full production deployment |
| Test | `config/test.yaml` | Minimal test environment |
| DR | `config/dr.yaml` | DR documentation and settings |

## Security Best Practices

1. **Store credentials securely** - Never commit `credentials.json` to git
2. **Use service accounts** - Avoid using personal admin accounts
3. **Enable audit logging** - Monitor Admin Console activity
4. **Review DLP rules** - Regularly audit data protection policies
5. **Test MFA recovery** - Ensure backup codes are documented
