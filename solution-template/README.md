# Solution Template

This directory contains the master template for creating new EO Framework solutions. Use this template as the foundation for all new solution contributions.

## Purpose

The solution template provides:
- **Standardized structure** for all EO Framework solutions
- **Pre-configured files** for presales and delivery documentation
- **Automation scaffolding** for deployment scripts across multiple platforms
- **Provider best practices** integration (AWS Well-Architected, Azure, GCP)
- **Consistent format** ensuring quality and compatibility across the repository

## Template Structure

```
sample-provider/sample-category/sample-solution/
├── README.md                    # Solution overview
├── metadata.yml                 # Solution metadata and classification
├── assets/
│   ├── diagrams/               # Architecture diagrams
│   └── logos/                  # Branding assets
├── presales/                    # Pre-sales materials
│   ├── raw/                    # Source files (CSV, MD)
│   └── *.xlsx, *.pptx, *.docx  # Generated Office files
└── delivery/                    # Implementation and delivery
    ├── raw/                    # Source files (CSV, MD)
    ├── *.xlsx, *.pptx, *.docx  # Generated Office files
    └── automation/             # Infrastructure as Code
        ├── terraform/          # Standard automation (cross-platform)
        ├── cloudformation/     # Native automation (AWS)
        ├── bicep/              # Native automation (Azure)
        └── helm/               # Native automation (Kubernetes)
```

## Automation Framework

### Standard vs Native Automation

The template supports two automation approaches:

| Approach | Tool | Best For |
|----------|------|----------|
| **Standard** | Terraform | Multi-cloud, complex infrastructure, consistent tooling |
| **Native** | CloudFormation/Bicep/Helm | Single-cloud, latest features, team expertise |

### Terraform Structure (Standard)

```
delivery/automation/terraform/
├── environments/               # Environment-specific configurations
│   ├── prod/                   # Production (full HA, multi-AZ)
│   │   ├── main.tf             # Module composition
│   │   ├── main.tfvars         # Solution identity
│   │   ├── well-architected.tf # Governance modules
│   │   ├── well-architected.tfvars
│   │   ├── providers.tf        # Provider configuration
│   │   ├── variables.tf        # Variable definitions
│   │   └── outputs.tf          # Output definitions
│   ├── test/                   # Test (minimal resources)
│   └── dr/                     # Disaster Recovery (cross-region)
├── modules/
│   ├── aws/                    # AWS resource modules
│   │   ├── vpc/
│   │   ├── alb/
│   │   ├── rds/
│   │   └── well-architected/   # AWS Six Pillars
│   │       ├── operational-excellence/
│   │       ├── security/
│   │       ├── reliability/
│   │       └── cost-optimization/
│   ├── azure/                  # Azure resource modules
│   ├── gcp/                    # GCP resource modules
│   └── solution/               # Solution-specific compositions
└── scripts/
```

### Provider Best Practices Integration

All automation implements provider-specific architectural frameworks:

#### AWS Well-Architected (Six Pillars)

| Pillar | Module | Purpose |
|--------|--------|---------|
| Operational Excellence | `config-rules` | AWS Config for compliance monitoring |
| Security | `guardduty` | Threat detection and response |
| Reliability | `backup-plans` | Centralized backup management |
| Performance Efficiency | `compute-optimizer` | Right-sizing recommendations |
| Cost Optimization | `budgets` | Cost alerting and auto-remediation |
| Sustainability | - | Via right-sizing in other modules |

#### Azure Well-Architected

| Pillar | Module | Purpose |
|--------|--------|---------|
| Reliability | `backup` | Azure Backup and recovery |
| Security | `defender` | Microsoft Defender integration |
| Cost Optimization | `budgets` | Cost Management alerts |
| Operational Excellence | `monitor` | Azure Monitor and diagnostics |

### EO Framework Standards

All automation must follow:

1. **Naming Convention**: `{solution_abbr}-{environment}-{resource}`
   - Example: `vxr-prod-vpc`, `sfi-test-rds`

2. **Required Tags**:
   ```hcl
   tags = {
     Solution     = "vxrail-hyperconverged"
     SolutionAbbr = "vxr"
     Environment  = "prod"
     ManagedBy    = "terraform"
     CostCenter   = "CC-12345"
     Owner        = "team@company.com"
   }
   ```

3. **Environment Characteristics**:
   | Feature | prod | test | dr |
   |---------|------|------|-----|
   | Multi-AZ | Yes | No | Yes |
   | Deletion Protection | Yes | No | Yes |
   | Backup | Full | Daily only | Cross-region |
   | Security | Full | Basic | Full |

## Required Files

### Core Files

| File | Purpose |
|------|---------|
| `README.md` | Solution overview and navigation hub |
| `metadata.yml` | Structured metadata for catalogs and discovery |

### Presales Files (presales/raw/)

| File | Purpose |
|------|---------|
| `statement-of-work.md` | Scope, timeline, budget, deliverables |
| `solution-briefing.md` | Architecture, services, pricing |
| `discovery-questionnaire.csv` | Client requirements assessment |
| `level-of-effort.csv` | Effort estimation |
| `infrastructure-costs.csv` | Infrastructure cost breakdown |

### Delivery Files (delivery/raw/)

| File | Purpose |
|------|---------|
| `detailed-design.md` | Technical architecture and design |
| `implementation-guide.md` | Deployment procedures and training |
| `project-plan.csv` | Timeline, milestones, RACI |
| `configuration.csv` | Environment configuration parameters |
| `test-plan.csv` | Testing procedures and cases |
| `closeout-presentation.md` | Project completion presentation |

### Automation Files (delivery/automation/terraform/)

| File | Purpose |
|------|---------|
| `environments/*/main.tf` | Module composition |
| `environments/*/main.tfvars` | Solution identity variables |
| `environments/*/well-architected.tf` | Governance modules |
| `environments/*/well-architected.tfvars` | Governance settings |
| `environments/*/providers.tf` | Provider and backend configuration |
| `environments/*/variables.tf` | Variable definitions with validation |

## Creating a New Solution

### Step 1: Clone Template

```bash
# Copy template structure
cp -r solution-template/sample-provider/sample-category/sample-solution/ \
      solutions/{provider}/{category}/{solution-name}/
```

### Step 2: Configure Solution Identity

Edit `delivery/automation/terraform/environments/prod/main.tfvars`:

```hcl
solution_name = "my-solution"
solution_abbr = "mysol"
provider_name = "aws"
category_name = "cloud"

aws_region  = "us-east-1"
cost_center = "CC-12345"
owner_email = "team@company.com"
```

### Step 3: Configure Well-Architected Settings

Edit `delivery/automation/terraform/environments/prod/well-architected.tfvars`:

```hcl
# Operational Excellence
enable_config_rules = true

# Reliability
enable_backup_plans = true
backup_daily_retention = 30
enable_backup_cross_region = true

# Cost Optimization
enable_budgets = true
monthly_budget_amount = 5000
budget_alert_emails = ["finance@company.com"]
```

### Step 4: Validate Configuration

```bash
# Validate automation
python eof-tools/automation/scripts/validate-automation.py \
    solutions/{provider}/{category}/{solution-name}/

# Terraform validation
cd solutions/{provider}/{category}/{solution-name}/delivery/automation/terraform/environments/prod
terraform validate
terraform fmt -check
```

### Step 5: Deploy

```bash
cd environments/prod
./deploy.sh init
./deploy.sh plan
./deploy.sh apply
```

## Naming Conventions

- **Provider names:** lowercase, hyphenated (e.g., `aws`, `dell`, `microsoft`)
- **Category names:** lowercase, hyphenated (e.g., `ai`, `cloud`, `cyber-security`)
- **Solution names:** lowercase, hyphenated, descriptive (e.g., `vxrail-hyperconverged`)
- **Solution abbreviation:** 3-4 lowercase alphanumeric (e.g., `vxr`, `sfi`)
- **File names:** lowercase with standard extensions (`.md`, `.csv`, `.tf`)

## Solution Categories

Solutions must be organized under one of these categories:

- **ai** - Artificial Intelligence & Machine Learning
- **cloud** - Cloud Infrastructure & Platforms
- **cyber-security** - Security & Compliance Solutions
- **devops** - DevOps & Automation Platforms
- **modern-workspace** - Digital Workplace & Collaboration
- **network** - Network Infrastructure & Connectivity

## Documentation Reference

- **Automation Framework**: `eof-tools/automation/docs/AUTOMATION_FRAMEWORK.md`
- **Terraform Standards**: `eof-tools/automation/docs/TERRAFORM_STANDARDS.md`
- **Well-Architected Integration**: `eof-tools/automation/docs/WELL_ARCHITECTED_INTEGRATION.md`
- **Delivery Specification**: `eof-tools/generators/delivery/prompts/SPECIFICATION.md`

## Workflow

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Presales      │     │   Delivery      │     │   Automation    │
│   SOW/Config    │────▶│ configuration   │────▶│   Terraform     │
│                 │     │     .csv        │     │   .tfvars       │
└─────────────────┘     └─────────────────┘     └─────────────────┘
                                                        │
                                                        ▼
                                                ┌─────────────────┐
                                                │  Provider Best  │
                                                │   Practices +   │
                                                │  EO Standards   │
                                                └─────────────────┘
```

## Support

- **Tools:** See `eof-tools/automation/` for automation scripts
- **Documentation:** See `eof-tools/automation/docs/` for detailed standards
- **Validation:** Run `validate-automation.py` before committing
