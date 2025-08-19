# EO Framework™ Templates

Welcome to the EO Framework™ Templates repository - a comprehensive collection of pre-sales and delivery templates for enterprise technology solutions.

## Overview

The EO Framework™ is a community-driven standard that accelerates technology solution sales and delivery through standardized templates, processes, and automation scripts.

## Repository Structure

```
templates/
├── .github/                    # GitHub workflows and configuration
├── docs/                       # Repository documentation and governance
├── scripts/                    # Repository utilities and automation
├── _sample-template/           # Template for creating new solutions
└── providers/                  # All technology provider solutions
    ├── aws/                    # Amazon Web Services solutions
    ├── azure/                  # Microsoft Azure solutions
    ├── google/                 # Google Cloud solutions
    ├── microsoft/              # Microsoft 365 solutions
    ├── ibm/                    # IBM solutions
    ├── hashicorp/              # HashiCorp solutions
    ├── github/                 # GitHub solutions
    ├── nvidia/                 # NVIDIA solutions
    ├── dell/                   # Dell Technologies solutions
    ├── juniper/                # Juniper Networks solutions
    └── cisco/                  # Cisco solutions
```

## Categories

Each provider includes solutions across five key categories:
- **Cloud** - Infrastructure, storage, compute services
- **Network** - Connectivity, routing, load balancing
- **Cyber Security** - Identity, threat protection, compliance
- **DevOps** - CI/CD, automation, orchestration
- **AI** - Machine learning, analytics, intelligent services

## Quick Start

### Creating a New Template

Use our clone utility to create a new solution template:

```bash
python scripts/clone-template.py \
  --provider "YourProvider" \
  --category "YourCategory" \
  --solution "YourSolution" \
  --author-name "Your Name" \
  --author-email "your.email@company.com"
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

1. Read our [Contributing Guide](docs/CONTRIBUTING.md)
2. Review [Template Standards](docs/TEMPLATE_STANDARDS.md)
3. Understand the [Review Process](docs/REVIEW_PROCESS.md)
4. Create your template using the sample template
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