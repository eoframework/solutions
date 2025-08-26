# Getting Started with EO Framework™ Templates

This guide walks you through creating your first enterprise solution template using the EO Framework™ Templates repository. You'll learn how to use the master template foundation to create professional, standardized solution documentation and automation.

## Prerequisites

Before you begin, ensure you have:

- **Python 3.7+** installed on your system
- **Git** configured with your credentials
- **Repository access** to EO Framework™ Templates
- **Text editor** or IDE for customization

### Required Python Packages
```bash
pip install pyyaml jsonschema
```

## Quick Start: Create Your First Solution

### Step 1: Choose Your Solution Details

Before creating a template, decide on:

- **Provider**: Technology vendor (e.g., `aws`, `azure`, `juniper`, `cisco`)
- **Category**: Solution type from these options:
  - `ai` - Artificial Intelligence and Machine Learning
  - `cloud` - Cloud infrastructure and platform solutions  
  - `cyber-security` - Security, compliance, and threat protection
  - `devops` - DevOps automation and CI/CD solutions
  - `modern-workspace` - Digital workplace and collaboration
  - `network` - Network infrastructure and connectivity
- **Solution Name**: Descriptive name (will be converted to lowercase with hyphens)
- **Your Information**: Name and email for attribution

### Step 2: Clone the Master Template

Use the automated template cloner to create your solution structure:

```bash
# Navigate to the repository root
cd /path/to/eo-framework-templates

# Run the template cloner
python tools/clone-template.py \
  --provider "your-provider" \
  --category "your-category" \
  --solution "your-solution-name" \
  --author-name "Your Full Name" \
  --author-email "your.email@company.com"
```

**Example**:
```bash
python tools/clone-template.py \
  --provider "juniper" \
  --category "network" \
  --solution "sd-wan-enterprise" \
  --author-name "John Smith" \
  --author-email "john.smith@company.com"
```

### Step 3: Verify Template Creation

The tool will create a complete directory structure:

```
providers/your-provider/your-category/your-solution/
├── README.md                   # Solution overview (customize this first)
├── metadata.yml               # Solution metadata (verify details)
├── docs/                      # Technical documentation
│   ├── architecture.md        # Solution architecture details
│   ├── prerequisites.md       # Requirements and dependencies
│   └── troubleshooting.md     # Common issues and solutions
├── presales/                  # Pre-sales materials
│   ├── README.md              # Presales process overview
│   ├── business-case-template.md        # ROI and justification
│   ├── executive-presentation-template.md  # C-level presentation
│   ├── roi-calculator-template.md       # Financial impact calculator
│   ├── requirements-questionnaire.md   # Customer discovery questions
│   └── solution-design-template.md     # Technical design document
└── delivery/                  # Implementation materials
    ├── README.md              # Delivery process overview
    ├── implementation-guide.md # Step-by-step deployment guide
    ├── configuration-templates.md # Configuration examples
    ├── testing-procedures.md  # Validation and testing steps
    ├── training-materials.md  # User training content
    ├── operations-runbook.md  # Operational procedures
    └── scripts/               # Automation scripts
        ├── README.md          # Scripts overview and usage
        ├── terraform/         # Infrastructure as Code
        ├── ansible/           # Configuration management
        ├── python/            # Custom automation
        ├── powershell/        # Windows administration
        └── bash/              # Linux/Unix scripting
```

## Detailed Customization Guide

### Phase 1: Solution Overview (Start Here)

1. **Edit README.md** - This is your solution's main landing page
   - Update the solution title and description
   - Add key features and benefits
   - Include target use cases and customer scenarios
   - Add technical requirements and prerequisites

2. **Update metadata.yml** - Critical for catalog integration
   - Verify all auto-filled information
   - Add relevant tags for discoverability
   - Set appropriate complexity level
   - Estimate deployment timeframe
   - List supported regions/environments

### Phase 2: Technical Documentation

3. **Architecture Documentation (docs/architecture.md)**
   - Create solution architecture diagrams
   - Document component relationships
   - Explain data flows and integrations
   - Include security considerations

4. **Prerequisites (docs/prerequisites.md)**
   - List all technical requirements
   - Specify minimum system requirements
   - Document required licenses and accounts
   - Include network and security requirements

5. **Troubleshooting Guide (docs/troubleshooting.md)**
   - Document common issues and solutions
   - Include diagnostic procedures
   - Add FAQ section
   - Provide support escalation paths

### Phase 3: Business Materials (Presales)

6. **Business Case Template (presales/business-case-template.md)**
   - Quantify business benefits and ROI
   - Include cost-benefit analysis
   - Add industry benchmarks
   - Document risk mitigation strategies

7. **Executive Presentation (presales/executive-presentation-template.md)**
   - Create C-level presentation deck outline
   - Focus on business outcomes
   - Include success stories and case studies
   - Highlight competitive advantages

8. **ROI Calculator (presales/roi-calculator-template.md)**
   - Build financial impact calculator
   - Include implementation costs
   - Project operational savings
   - Calculate payback period

9. **Requirements Questionnaire (presales/requirements-questionnaire.md)**
   - Create customer discovery questions
   - Identify technical requirements
   - Assess business needs
   - Determine success criteria

10. **Solution Design (presales/solution-design-template.md)**
    - Document technical solution approach
    - Include sizing and capacity planning
    - Add integration requirements
    - Specify customization needs

### Phase 4: Implementation Materials (Delivery)

11. **Implementation Guide (delivery/implementation-guide.md)**
    - Create step-by-step deployment procedures
    - Include pre-deployment checklists
    - Document configuration steps
    - Add validation procedures

12. **Configuration Templates (delivery/configuration-templates.md)**
    - Provide working configuration examples
    - Include parameter explanations
    - Add environment-specific variations
    - Document best practices

13. **Testing Procedures (delivery/testing-procedures.md)**
    - Define comprehensive test plans
    - Include functional testing scenarios
    - Add performance validation steps
    - Document acceptance criteria

14. **Training Materials (delivery/training-materials.md)**
    - Create user training curriculum
    - Include hands-on exercises
    - Add administrator guides
    - Provide certification paths

15. **Operations Runbook (delivery/operations-runbook.md)**
    - Document daily operational procedures
    - Include monitoring and alerting
    - Add maintenance schedules
    - Provide incident response procedures

### Phase 5: Automation Scripts (delivery/scripts/)

16. **Infrastructure as Code (delivery/scripts/terraform/)**
    - Create Terraform modules
    - Include variable definitions
    - Add output specifications
    - Provide deployment examples

17. **Configuration Management (delivery/scripts/ansible/)**
    - Build Ansible playbooks
    - Include inventory templates
    - Add role definitions
    - Document playbook execution

18. **Custom Automation (delivery/scripts/python/)**
    - Write deployment automation
    - Include utility scripts
    - Add data migration tools
    - Provide monitoring scripts

19. **Platform Scripts (delivery/scripts/powershell/ and bash/)**
    - Create platform-specific automation
    - Include system preparation scripts
    - Add service management tools
    - Provide backup and recovery scripts

## Quality Assurance

### Step 4: Validate Your Template

After customization, validate your template structure and content:

```bash
# Validate specific template
python tools/validate-template.py --path providers/your-provider/your-category/your-solution

# Run comprehensive validation
python tools/validate-template.py --path providers/your-provider/your-category/your-solution --verbose
```

**Common Validation Issues:**
- Missing required files
- Invalid metadata format
- Broken internal links
- Incomplete documentation sections

### Step 5: Update Repository Catalogs

Generate updated catalogs to include your new solution:

```bash
# Update distributed catalog system
python3 catalog/tools/generator.py

# Generate API exports
python3 catalog/tools/aggregator.py

# Validate catalog integrity
python3 catalog/tools/validator.py

# Generate website export
python tools/sync-csv.py
```

### Step 6: Final Review Checklist

Before submitting your solution:

- [ ] **README.md** - Clear overview with value proposition
- [ ] **metadata.yml** - Complete and accurate metadata
- [ ] **Architecture docs** - Comprehensive technical documentation
- [ ] **Business materials** - Professional presales content
- [ ] **Implementation guide** - Detailed deployment procedures
- [ ] **Automation scripts** - Working, tested scripts
- [ ] **Validation** - All validation checks pass
- [ ] **Catalogs updated** - Solution appears in discovery systems

## Advanced Topics

### Custom Solution Categories

If your solution doesn't fit standard categories, document why and consider:
- Creating a new category (requires approval)
- Using the closest existing category
- Adding custom tags for better discovery

### Multi-Provider Solutions

For solutions spanning multiple providers:
- Choose the primary provider for directory placement
- Document all provider dependencies
- Include integration guides for each provider

### Solution Versioning

For solution updates:
- Update version in metadata.yml
- Document changes in README.md
- Maintain backward compatibility when possible
- Update automation scripts for new versions

## Getting Help

### Support Resources

- **Template Issues**: Use `python tools/validate-template.py --help`
- **Catalog Problems**: Check `catalog/README.md`
- **Documentation Standards**: Review `docs/template-standards.md`
- **Review Process**: See `docs/review-process.md`

### Community Support

- **GitHub Issues**: Report bugs and request features
- **GitHub Discussions**: Ask questions and share ideas
- **Contributing Guide**: See `docs/contributing.md`

### Best Practices

1. **Start Small**: Begin with core documentation, expand gradually
2. **Use Examples**: Reference existing solutions for inspiration
3. **Test Everything**: Validate all scripts and procedures
4. **Get Feedback**: Share early drafts for community input
5. **Stay Updated**: Keep content current with technology changes

## Next Steps

After creating your solution:

1. **Submit for Review** - Follow the review process in `docs/review-process.md`
2. **Gather Feedback** - Engage with the community for improvements
3. **Iterate and Improve** - Continuously enhance based on feedback
4. **Share Knowledge** - Help others learn from your experience

## Example Solutions

Reference these existing solutions for inspiration:
- **Juniper Mist AI Network** (`providers/juniper/network/mist-ai-network/`)
- **Juniper SRX Firewall** (`providers/juniper/cyber-security/srx-firewall-platform/`)

These examples demonstrate complete, professional solution templates that follow EO Framework™ standards.

---

**Ready to create your first solution?** Start with the Quick Start section above and begin building your enterprise solution template today!