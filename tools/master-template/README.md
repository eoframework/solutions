# Master Template Reference

This directory contains the reference template structure for creating new EO Framework™ enterprise solutions. It serves as the foundation for all solution templates in the repository and demonstrates the complete file structure, naming conventions, and content organization.

## Purpose and Usage

### Purpose
- **Template Foundation**: Base structure for creating new solution templates
- **Standards Reference**: Demonstrates proper file organization and naming
- **Content Guidelines**: Shows required content types and formatting
- **Automation Source**: Used by `scripts/clone-template.py` for template generation

### Usage
**DO NOT** modify this template directly. Instead:
1. Use `scripts/clone-template.py` to create new templates
2. Reference this structure when manually creating solutions
3. Follow the file naming and organization patterns shown here

## Directory Structure

```
master-template/
└── sample-provider/           # Provider name (lowercase, hyphenated)
    └── sample-category/       # Category name (standardized category)
        └── sample-solution/   # Solution name (lowercase, hyphenated)
            ├── README.md                   # Solution overview and value proposition
            ├── metadata.yml               # Required solution metadata
            ├── docs/                      # Technical documentation
            │   ├── README.md              # Documentation overview
            │   ├── architecture.md       # Solution architecture details
            │   ├── prerequisites.md      # Requirements and dependencies
            │   └── troubleshooting.md    # Common issues and solutions
            ├── presales/                  # Pre-sales materials
            │   ├── README.md              # Presales overview and guidance
            │   ├── business-case-template.md        # ROI and justification
            │   ├── executive-presentation-template.md  # Executive summary
            │   ├── roi-calculator-template.md       # Financial calculator
            │   ├── requirements-questionnaire.md   # Customer discovery
            │   └── solution-design-template.md     # Technical design
            └── delivery/                  # Implementation materials
                ├── README.md              # Delivery process overview
                ├── implementation-guide.md # Step-by-step deployment
                ├── configuration-templates.md # Config examples
                ├── testing-procedures.md  # Validation and testing
                ├── training-materials.md  # User training content
                ├── operations-runbook.md  # Operational procedures
                └── scripts/               # Automation scripts
                    ├── README.md          # Scripts overview
                    ├── terraform/         # Infrastructure as Code
                    │   ├── main.tf
                    │   ├── variables.tf
                    │   ├── outputs.tf
                    │   └── terraform.tfvars.example
                    ├── ansible/           # Configuration management
                    │   └── playbook.yml
                    ├── python/            # Custom automation
                    │   └── deploy.py
                    ├── powershell/        # Windows administration
                    │   └── deploy.ps1
                    └── bash/              # Linux/Unix scripting
                        └── deploy.sh
```

## File Standards

### Required Files
Every solution template **MUST** include these files:
- `README.md` - Solution overview
- `metadata.yml` - Standardized metadata
- `docs/README.md` - Documentation index
- `presales/README.md` - Presales overview
- `delivery/README.md` - Delivery overview
- `delivery/scripts/README.md` - Scripts documentation

### Naming Conventions

#### Directory Names
- **Provider**: Lowercase, hyphenated (e.g., `juniper`, `dell`, `hashicorp`)
- **Category**: Standardized values only:
  - `ai` - Artificial Intelligence
  - `cloud` - Cloud Infrastructure
  - `cyber-security` - Security and Compliance
  - `devops` - DevOps and Automation
  - `modern-workspace` - Digital Workplace
  - `network` - Network Infrastructure
- **Solution**: Lowercase, hyphenated, descriptive (e.g., `mist-ai-network`, `srx-firewall-platform`)

#### File Names
- Use lowercase with hyphens for multi-word names
- Follow consistent naming patterns:
  - `README.md` (exactly this case)
  - `metadata.yml` (lowercase)
  - Template files: `*-template.md`
  - Procedures: `*-procedures.md`
  - Guides: `*-guide.md`

### Content Standards

#### README Files
- Clear, concise overview of purpose
- Value proposition and business benefits
- Technical requirements and specifications
- Links to relevant documentation

#### Metadata Schema
```yaml
# Required fields
solution_name: "Sample Solution"
provider: "sample-provider"
category: "sample-category"
version: "1.0.0"
description: "Brief solution description"

# Business information
complexity: "intermediate"  # basic|intermediate|advanced|enterprise
deployment_time: "4-6 weeks"
business_value: []
roi_metrics: {}

# Technical information
tags: []
prerequisites: []
supported_regions: []
compliance_frameworks: []

# Organizational information
author:
  name: "Author Name"
  email: "author@company.com"
maintainers: []
last_updated: "2025-01-15"
status: "Active"
```

## Template Placeholders

The master template contains placeholder values that are automatically replaced when using `scripts/clone-template.py`:

### Replacement Variables
- `{PROVIDER_NAME}` → Provider name (e.g., "Juniper")
- `{PROVIDER_SLUG}` → Provider slug (e.g., "juniper")
- `{CATEGORY_NAME}` → Category display name (e.g., "Network")
- `{CATEGORY_SLUG}` → Category slug (e.g., "network")
- `{SOLUTION_NAME}` → Solution display name (e.g., "Mist AI Network")
- `{SOLUTION_SLUG}` → Solution slug (e.g., "mist-ai-network")
- `{AUTHOR_NAME}` → Template author name
- `{AUTHOR_EMAIL}` → Template author email
- `{CURRENT_DATE}` → Current date in ISO format

### Manual Replacement
If creating templates manually, replace all placeholder values with actual content before use.

## Quality Requirements

### Documentation Completeness
- All README files must have substantive content
- Architecture diagrams and technical details required
- Business case with quantified benefits
- Complete deployment procedures

### Script Standards
- All scripts must be functional and tested
- Include error handling and logging
- Follow language-specific best practices
- Provide clear usage documentation

### Content Quality
- Professional writing with proper grammar
- Technical accuracy and current information
- Clear examples and use cases
- Consistent formatting and style

## Validation

Before submitting any template based on this sample:

1. **Structure Check**: Ensure all required files and directories exist
2. **Content Review**: All placeholder content replaced with real information
3. **Script Testing**: Automation scripts function correctly
4. **Quality Validation**: Run `python scripts/validate-template.py`
5. **Catalog Update**: Execute `python3 catalog/tools/generator.py`

## Support

For questions about using this template:
- **Template Creation**: See [scripts/README.md](../scripts/README.md)
- **Standards**: Review [docs/template-standards.md](../docs/template-standards.md)
- **Process**: Check [docs/contributing.md](../docs/contributing.md)
- **Issues**: Report via GitHub Issues