# Solution Template

This directory contains the master template for creating new EO Framework™ solutions. Use this template as the foundation for all new solution contributions.

## Purpose

The solution template provides:
- **Standardized structure** for all EO Framework™ solutions
- **Pre-configured files** for presales and delivery documentation
- **Automation scaffolding** for deployment scripts across multiple platforms
- **Consistent format** ensuring quality and compatibility across the repository

## Template Structure

```
sample-provider/sample-category/sample-solution/
├── README.md                   # Solution overview
├── metadata.yml                # Solution metadata and classification
├── presales/                   # Pre-sales materials
│   ├── README.md
│   ├── business-case.md
│   ├── executive-presentation.md
│   ├── executive-presentation.pptx
│   ├── roi-calculator.csv
│   ├── requirements-questionnaire.csv
│   ├── level-of-effort-estimate.csv
│   └── statement-of-work.md
└── delivery/                   # Implementation and delivery materials
    ├── README.md
    ├── requirements.csv
    ├── project-plan.csv
    ├── communication-plan.csv
    ├── configuration.csv
    ├── roles.csv
    ├── test-plan.csv
    ├── training-plan.csv
    ├── detailed-design.md
    ├── implementation-guide.md
    ├── closeout-presentation.md
    ├── closeout-presentation.pptx
    └── scripts/                # Automation scripts
        ├── README.md
        ├── terraform/          # Infrastructure as Code
        ├── ansible/            # Configuration management
        ├── python/             # Python automation
        ├── bash/               # Bash scripts
        └── powershell/         # PowerShell scripts
```

## Required Files

Every solution must include these files:

### Core Files

| File | Purpose |
|------|---------|
| `README.md` | Solution overview and navigation hub |
| `metadata.yml` | Structured metadata for catalogs and discovery |

### Presales Files

| File | Purpose |
|------|---------|
| `presales/README.md` | Pre-sales process and materials overview |
| `presales/business-case.md` | ROI analysis and business justification |
| `presales/executive-presentation.md` | Executive stakeholder presentation |
| `presales/roi-calculator.csv` | Financial impact calculator |
| `presales/requirements-questionnaire.csv` | Discovery and assessment framework |

### Delivery Files

| File | Purpose |
|------|---------|
| `delivery/README.md` | Implementation process overview |
| `delivery/requirements.csv` | Detailed requirements matrix |
| `delivery/project-plan.csv` | Implementation project plan |
| `delivery/implementation-guide.md` | Step-by-step deployment procedures |
| `delivery/scripts/README.md` | Automation scripts overview |

## Script Types

The template includes scaffolding for multiple automation platforms:

| Script Type | Purpose | Use Cases |
|-------------|---------|-----------|
| `terraform/` | Infrastructure as Code | Cloud resource provisioning, infrastructure deployment, multi-cloud environments |
| `ansible/` | Configuration management | Server configuration, application deployment, post-deployment configuration |
| `python/` | Custom automation | Complex business logic, API integrations, data processing, custom workflows |
| `bash/` | Linux/Unix automation | System administration, deployment scripts, startup/shutdown procedures |
| `powershell/` | Windows automation | Windows server management, Active Directory, Azure automation, Windows-specific tasks |

## Solution Categories

Solutions must be organized under one of these six standardized categories:

- **ai** - Artificial Intelligence & Machine Learning
- **cloud** - Cloud Infrastructure & Platforms
- **cyber-security** - Security & Compliance Solutions
- **devops** - DevOps & Automation Platforms
- **modern-workspace** - Digital Workplace & Collaboration
- **network** - Network Infrastructure & Connectivity

## Creating a New Solution

### Option 1: Automated (Recommended)

Use the clone script to automatically generate a new solution:

```bash
python3 support/tools/clone-solution-template.py \
  --provider "your-provider" \
  --category "cloud" \
  --solution "your-solution-name" \
  --author-name "Your Name" \
  --author-email "your.email@company.com"
```

This will:
- Create the complete directory structure
- Replace all template variables with your values
- Generate a ready-to-customize solution template

### Option 2: Manual

1. **Copy the template structure:**
   ```bash
   cp -r solution-template/sample-provider/sample-category/sample-solution/ \
         solutions/your-provider/your-category/your-solution/
   ```

2. **Update metadata.yml** with your solution details

3. **Customize all template files** by replacing placeholder content

4. **Validate the structure:**
   ```bash
   python3 support/tools/validate-template.py \
     --path solutions/your-provider/your-category/your-solution/
   ```

## Naming Conventions

- **Provider names:** lowercase, hyphenated (e.g., `aws`, `hashicorp`, `dell`)
- **Category names:** lowercase, hyphenated (e.g., `ai`, `cyber-security`, `modern-workspace`)
- **Solution names:** lowercase, hyphenated, descriptive (e.g., `enterprise-landing-zone`, `intelligent-document-processing`)
- **File names:** lowercase with standard extensions (`.md`, `.yml`, `.csv`, `.pptx`)

## Next Steps

1. **Create your solution** using the automated script
2. **Customize the content** to match your specific solution
3. **Validate the structure** using the validation tool
4. **Submit for review** via pull request

## Support

- **Tools:** See `support/tools/` for automation scripts
- **Documentation:** See `support/docs/` for detailed standards and guidelines
- **Issues:** Report problems via [GitHub Issues](https://github.com/eoframework/solutions/issues)
