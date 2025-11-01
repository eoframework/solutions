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
│   ├── business-case.docx
│   ├── executive-presentation.pptx
│   ├── statement-of-work.docx
│   ├── roi-calculator.xlsx
│   ├── requirements-questionnaire.xlsx
│   └── level-of-effort-estimate.xlsx
└── delivery/                   # Implementation and delivery materials
    ├── README.md
    ├── detailed-design.docx
    ├── implementation-guide.docx
    ├── closeout-presentation.pptx
    ├── requirements.xlsx
    ├── project-plan.xlsx
    ├── communication-plan.xlsx
    ├── configuration.xlsx
    ├── roles.xlsx
    ├── test-plan.xlsx
    ├── training-plan.xlsx
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
| `presales/business-case.docx` | ROI analysis and business justification |
| `presales/executive-presentation.pptx` | Executive stakeholder presentation |
| `presales/statement-of-work.docx` | Statement of work template |
| `presales/roi-calculator.xlsx` | Financial impact calculator |
| `presales/requirements-questionnaire.xlsx` | Discovery and assessment framework |
| `presales/level-of-effort-estimate.xlsx` | Effort estimation template |

### Delivery Files

| File | Purpose |
|------|---------|
| `delivery/README.md` | Implementation process overview |
| `delivery/detailed-design.docx` | Detailed technical design |
| `delivery/implementation-guide.docx` | Step-by-step deployment procedures |
| `delivery/closeout-presentation.pptx` | Project closeout presentation |
| `delivery/requirements.xlsx` | Detailed requirements matrix |
| `delivery/project-plan.xlsx` | Implementation project plan |
| `delivery/communication-plan.xlsx` | Stakeholder communication plan |
| `delivery/configuration.xlsx` | Configuration specifications |
| `delivery/roles.xlsx` | Team roles and responsibilities |
| `delivery/test-plan.xlsx` | Testing strategy and plan |
| `delivery/training-plan.xlsx` | User training plan |
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
