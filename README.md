# EO Framework™ Templates

Welcome to the EO Framework™ Templates repository - a comprehensive collection of pre-sales and delivery templates for enterprise technology solutions.

## Overview

The EO Framework™ is a community-driven standard that accelerates technology solution sales and delivery through standardized templates, processes, and automation scripts.

## Repository Structure

```
templates/
├── .github/                    # 🔧 GitHub Actions workflows and issue templates
│   ├── workflows/              # CI/CD pipelines for template validation
│   └── ISSUE_TEMPLATE/         # Standardized issue and PR templates
├── docs/                       # 📚 Repository governance and standards documentation
│   ├── contributing.md         # Contributor guidelines and submission process
│   ├── template-standards.md   # Quality standards and formatting requirements
│   ├── review-process.md       # Multi-stage review workflow documentation
│   ├── governance.md           # Repository governance and decision-making
│   └── license-guide.md        # BSL 1.1 license usage guidelines
├── master-template/            # 📋 Authoritative foundation for all enterprise solutions
│   └── sample-provider/        # Complete example solution structure
│       └── sample-category/    # Shows proper organization and file naming
│           └── sample-solution/ # Includes all required folders and files
├── tools/                      # 🛠️ Development utilities and automation
│   ├── clone-template.py       # 🏗️ Creates new solution templates from master-template
│   ├── validate-template.py    # ✅ Validates template structure and metadata
│   └── sync-csv.py             # 📊 Generates website CSV export
├── catalog/                    # 📊 Distributed solution discovery system
│   ├── catalog.yml             # Master index with metadata and quick stats
│   ├── providers/              # Provider-specific solution catalogs (11 files)
│   ├── categories/             # Category-based solution catalogs (6 files)
│   ├── schemas/                # JSON schemas for catalog validation
│   ├── tools/                  # Catalog management and search utilities
│   ├── solutions.json          # API-friendly JSON export for integrations
│   └── validation-report.json  # Latest catalog validation results
│   └── sample-provider/        # Complete example solution structure
│       └── sample-category/    # Shows proper organization and file naming
│           └── sample-solution/ # Includes all required folders and files
└── solutions/                  # 📦 Complete enterprise solution libraries
    ├── aws/                    # Amazon Web Services (3 solutions)
    ├── azure/                  # Microsoft Azure (6 solutions)
    ├── cisco/                  # Cisco Systems (5 solutions)
    ├── dell/                   # Dell Technologies (6 solutions)
    ├── github/                 # GitHub (2 solutions)
    ├── google/                 # Google Cloud (2 solutions)
    ├── hashicorp/              # HashiCorp (2 solutions)
    ├── ibm/                    # IBM (2 solutions)
    ├── juniper/                # Juniper Networks (2 solutions)
    ├── microsoft/              # Microsoft 365 (2 solutions)
    └── nvidia/                 # NVIDIA (2 solutions)
```

## Categories

Each provider includes solutions across six key categories:
- **🤖 AI** - Artificial Intelligence and Machine Learning solutions
- **☁️ Cloud** - Cloud infrastructure and platform solutions  
- **🔒 Cyber Security** - Security, compliance, and threat protection
- **🚀 DevOps** - DevOps automation and CI/CD solutions
- **💻 Modern Workspace** - Digital workplace and collaboration
- **🌐 Network** - Network infrastructure and connectivity

## Current Statistics

- **Total Solutions**: 34
- **Active Providers**: 11
- **Solution Categories**: 6
- **Template Completeness**: Full presales, delivery, and documentation

## Quick Start

### Exploring Solutions

Browse solutions through our distributed catalog system:

```bash
# View master catalog with all statistics
cat catalog/catalog.yml

# Browse specific provider solutions
cat catalog/providers/aws.yml
cat catalog/providers/azure.yml

# Browse by category across all providers
cat catalog/categories/ai.yml
cat catalog/categories/cloud.yml

# Use management tools
python3 catalog/tools/aggregator.py    # Combine catalogs for search
python3 catalog/tools/validator.py     # Validate catalog integrity
```

### Creating a New Template

Use our clone utility to create a new solution template:

```bash
python tools/clone-template.py \
  --provider "YourProvider" \
  --category "YourCategory" \
  --solution "YourSolution" \
  --author-name "Your Name" \
  --author-email "your.email@company.com"

# After creating solution, update catalogs
python3 catalog/tools/generator.py
```

### Template Structure

Every solution follows this standard structure:
```
solution-name/
├── README.md                   # Solution overview
├── metadata.yml               # Required metadata
├── docs/                      # Solution documentation
├── presales/                  # Pre-sales materials
└── delivery/                  # Implementation materials
    └── scripts/               # Automation scripts
```

## Contributing

1. Read our [Contributing Guide](docs/contributing.md)
2. Review [Template Standards](docs/template-standards.md)
3. Understand the [Review Process](docs/review-process.md)
4. Create your template using the master template
5. Submit a pull request

## License

This repository is licensed under the Business Source License 1.1 (BSL 1.1). See [LICENSE](LICENSE) for details.

## Support

- 📖 Documentation: [docs/](docs/)
- 🐛 Issues: [GitHub Issues](https://github.com/eoframework/templates/issues)
- 💬 Discussions: [GitHub Discussions](https://github.com/eoframework/templates/discussions)
- 🌐 Website: [EO Framework™](https://eoframework.github.io)

## Community

Join our community and help build the future of exceptional outcomes through collaboration and innovation.

---

© 2025 EO Framework™. All rights reserved.