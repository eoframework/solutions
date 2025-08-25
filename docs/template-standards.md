# EO Framework™ Template Standards

This document defines the required standards for all templates in the repository.

## Repository Structure Standards

### Required Files
Every solution template must include:
```
providers/[provider]/[category]/[solution]/
├── README.md                 # Solution overview and usage
├── metadata.yml             # Required metadata schema
├── docs/                    # Solution-specific documentation
├── presales/               # Pre-sales materials
└── delivery/               # Implementation materials
    └── scripts/            # Automation scripts
```

### Naming Conventions
- **Providers:** lowercase, no spaces (e.g., `aws`, `microsoft`, `hashicorp`)
- **Categories:** lowercase, hyphenated (e.g., `cloud`, `cyber-security`, `devops`)
- **Solutions:** lowercase, hyphenated, descriptive (e.g., `ec2-compute`, `iam-identity`)

## Metadata Standards

### Required metadata.yml Fields
```yaml
provider: "Provider Name"
category: "Category Name"
solution_name: "Solution Name"
description: "Brief solution description"
version: "X.Y.Z"
status: "Active|Draft|Deprecated"
maintainers:
  - name: "Maintainer Name"
    email: "email@company.com"
    role: "Role Title"
tags: ["tag1", "tag2", "tag3"]
requirements:
  prerequisites: []
  tools: []
  skills: []
```

## Content Standards

### Documentation Requirements
- **README.md:** Solution overview, prerequisites, quick start
- **docs/architecture.md:** Technical architecture details
- **docs/prerequisites.md:** Detailed requirements
- **docs/troubleshooting.md:** Common issues and solutions

### Presales Materials
- Requirements gathering tools
- Solution design templates
- Business case materials
- Presentation templates
- ROI calculators

### Delivery Materials
- Implementation guides
- Automation scripts (tested)
- Configuration templates
- Testing procedures
- Training materials
- Operations runbooks

## Quality Standards

### Code Quality
- All scripts must be tested
- Include error handling
- Follow provider best practices
- Use parameterized configurations
- Include rollback procedures

### Security Standards
- No hardcoded credentials
- Follow security best practices
- Include security baselines
- Implement least privilege access
- Regular security reviews

### Documentation Quality
- Clear and concise writing
- Include examples
- Step-by-step procedures
- Version control information
- Contact information

## File Format Standards

### Acceptable Formats
- **Documentation:** .md, .docx
- **Spreadsheets:** .xlsx
- **Presentations:** .pptx
- **Diagrams:** .drawio, .png, .svg
- **Code:** Provider-specific formats
- **Configuration:** .yml, .json, .xml

### File Size Limits
- Individual files: 50MB maximum
- Binary files should be compressed
- Large datasets should be linked externally

## Version Control Standards

### Branching Strategy
- Create feature branches for new templates
- Use descriptive branch names
- Keep changes focused and atomic

### Commit Messages
- Use conventional commit format
- Include solution context
- Reference issue numbers

### Pull Request Requirements
- Complete template validation
- Provider team approval
- Category team approval
- Core team final approval

## Testing Standards

### Required Testing
- Syntax validation
- Security scanning
- Template structure verification
- Script functionality testing
- Documentation completeness

### Testing Environments
- Use non-production environments only
- Clean up resources after testing
- Document test procedures
- Include test results

## Compliance Standards

### License Compliance
- All templates under BSL 1.1
- Include proper license headers
- Respect third-party licenses
- Document license requirements

### Export Control
- Comply with export regulations
- Mark controlled content appropriately
- Follow organizational policies
- Get legal approval when required