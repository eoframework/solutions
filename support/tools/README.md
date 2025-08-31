# EO Framework™ Development Tools

![Tools](https://img.shields.io/badge/Tools-6_Scripts-blue)
![Python](https://img.shields.io/badge/Python-3.8%2B-green)
![Automation](https://img.shields.io/badge/Automation-Complete-orange)
![Status](https://img.shields.io/badge/Status-Production_Ready-purple)

## 🎯 **Overview**

This directory contains the complete suite of development utilities and automation tools for the **EO Framework™ Templates** repository. These production-ready Python scripts enable efficient creation, validation, catalog management, and quality assurance of enterprise solution templates.

## 📋 **Prerequisites and Installation**

### 🐍 **Python Installation Requirements**

**Minimum Requirements:**
- **Python Version**: 3.8 or higher (3.9+ recommended)
- **Operating System**: Linux, macOS, Windows (with proper path handling)
- **Memory**: 512MB RAM minimum for large repository processing
- **Storage**: 100MB free space for temporary files and outputs

**Installing Python (if not installed):**

```bash
# Ubuntu/Debian
sudo apt update && sudo apt install python3 python3-pip

# CentOS/RHEL/Fedora
sudo dnf install python3 python3-pip

# macOS (using Homebrew)
brew install python3

# Windows (using Chocolatey)
choco install python3

# Or download from https://python.org/downloads/
```

**Verify Python Installation:**
```bash
python3 --version  # Should show 3.8+ 
pip3 --version     # Should show pip version
```

### 📦 **Required Dependencies**

**Install Required Python Packages:**
```bash
# Essential packages for all tools
pip3 install pyyaml>=6.0 jsonschema>=4.0 click>=8.0

# Optional but recommended for development
pip3 install black>=22.0 flake8>=4.0 pytest>=7.0

# Verify installation
python3 -c "import yaml, jsonschema, click; print('All dependencies installed successfully!')"
```

**Dependencies Overview:**
- **`pyyaml`**: YAML parsing and generation for metadata files
- **`jsonschema`**: Schema validation for catalog and metadata compliance
- **`click`**: Enhanced command-line interface and argument parsing
- **`pathlib`**: Advanced path manipulation (built into Python 3.4+)
- **`datetime`**: Timestamp generation and date handling (built-in)

### 🔧 **Environment Setup**

**Repository Access:**
```bash
# Clone repository (if not already done)
git clone https://github.com/eoframework/templates.git
cd templates

# Verify tools directory structure
ls -la support/tools/

# Make scripts executable (Linux/macOS)
chmod +x support/tools/*.py

# Test basic functionality
python3 support/tools/validate-template.py --help
```

**Development Environment (Optional):**
```bash
# Set up Python virtual environment (recommended)
python3 -m venv venv
source venv/bin/activate  # Linux/macOS
# OR: venv\Scripts\activate  # Windows

# Install development dependencies in virtual environment
pip install -r requirements.txt  # If requirements.txt exists
```

## 🛠️ **Tool Scripts Overview**

### 🏗️ **1. clone-template.py - Template Creator**
**Purpose**: Creates new solution templates from the master template foundation

**Core Functionality:**
- Copies complete `master-template/` structure to new solution directory
- Replaces all placeholder values with actual solution details
- Creates proper directory structure under `solutions/[provider]/[category]/[solution]/`
- Updates metadata.yml with author information and current timestamps
- Performs input validation and provides guided next steps

**Usage:**
```bash
# Basic template creation
python3 support/tools/clone-template.py \
  --provider "aws" \
  --category "cloud" \
  --solution "enterprise-landing-zone" \
  --author-name "John Smith" \
  --author-email "john.smith@company.com"

# Example with different provider and category
python3 support/tools/clone-template.py \
  --provider "cisco" \
  --category "network" \
  --solution "sd-wan-enterprise" \
  --author-name "Network Engineer" \
  --author-email "network@company.com"
```

**Parameters:**
- `--provider` **(required)**: Technology provider name
  - Valid: `aws`, `azure`, `cisco`, `dell`, `github`, `google`, `hashicorp`, `ibm`, `juniper`, `microsoft`, `nvidia`
- `--category` **(required)**: Solution category
  - Valid: `ai`, `cloud`, `cyber-security`, `devops`, `modern-workspace`, `network`
- `--solution` **(required)**: Solution name (lowercase with hyphens)
- `--author-name` **(required)**: Template author's full name
- `--author-email` **(required)**: Template author's email address

**Output Example:**
```
✅ Successfully created new template: solutions/aws/cloud/enterprise-landing-zone
📝 Next steps:
   1. Review and update solutions/aws/cloud/enterprise-landing-zone/metadata.yml
   2. Update solutions/aws/cloud/enterprise-landing-zone/README.md with solution details
   3. Add presales materials to solutions/aws/cloud/enterprise-landing-zone/presales/
   4. Add delivery materials to solutions/aws/cloud/enterprise-landing-zone/delivery/
   5. Test all automation scripts
   6. Submit pull request for review
```

### ✅ **2. validate-template.py - Template Validator**
**Purpose**: Comprehensive validation of template structure, metadata, and content quality

**Core Functionality:**
- Validates required directory structure and files
- Checks metadata.yml schema compliance and required fields
- Performs security scanning for hardcoded secrets
- Validates file naming conventions and content formatting
- Provides detailed error reports with remediation guidance

**Usage:**
```bash
# Validate specific template
python3 support/tools/validate-template.py \
  --path solutions/aws/cloud/enterprise-landing-zone

# Validate all templates in repository
python3 support/tools/validate-template.py --all

# Validate with verbose output for debugging
python3 support/tools/validate-template.py --all --verbose

# Quick structure-only validation
python3 support/tools/validate-template.py \
  --path solutions/cisco/network/sd-wan-enterprise --structure-only
```

**Parameters:**
- `--path`: Specific template directory path to validate
- `--all`: Validate all templates in the repository
- `--verbose`: Show detailed validation information and debugging output
- `--structure-only`: Check only directory structure and required files (skip content)

**Validation Checks:**
- ✅ **Structure Validation**: Required directories (`docs/`, `presales/`, `delivery/`, `delivery/scripts/`)
- ✅ **File Validation**: Required files (`README.md`, `metadata.yml`, documentation files)
- ✅ **Metadata Schema**: YAML schema compliance and required field validation
- ✅ **Security Scanning**: Detection of potential hardcoded secrets and credentials
- ✅ **Content Quality**: Documentation completeness and formatting standards
- ✅ **Naming Conventions**: File and directory naming standard compliance

**Output Examples:**
```
Validating template: solutions/aws/cloud/enterprise-landing-zone
✅ Validation PASSED

Validating template: solutions/cisco/network/incomplete-solution  
❌ Validation FAILED
   ERROR: Missing required file: docs/architecture.md
   ERROR: Missing required field in metadata.yml: description
⚠️  Warnings:
   WARNING: Potential secret in delivery/scripts/setup.sh: contains 'password'
```

### 📊 **3. process-catalogs.py - Catalog Processor**
**Purpose**: Processes distributed catalogs into unified exports and reports for consumption

**Core Functionality:**
- Loads and combines master, provider, and category catalogs
- Provides advanced search and filtering capabilities
- Generates comprehensive statistics and metrics
- Exports unified solution data for external systems
- Supports API integration and data analysis

**Usage:**
```bash
# Run complete catalog processing
python3 support/tools/process-catalogs.py

# The script automatically:
# - Loads all catalog files
# - Processes solution data
# - Generates exports and reports
# - Creates JSON for API consumption
# - Displays summary metrics
```

**Key Features:**
- **Unified Search**: Search across all solutions with text, provider, category, and tag filters
- **Statistics Generation**: Comprehensive metrics by provider, category, complexity, and deployment time
- **JSON Export**: API-ready solution data export for website and external integrations
- **Performance Metrics**: Solution usage analytics and adoption tracking

**Output Files Generated:**
- `support/exports/solutions.json` - Complete solution dataset for API consumption
- `support/reports/` - Various reports and analytics files
- Console output with comprehensive statistics and metrics

### 🔄 **4. generate-catalogs.py - Catalog Generator**
**Purpose**: Auto-generates catalog system from solution metadata.yml files

**Core Functionality:**
- Scans all solution directories for metadata.yml files
- Auto-generates provider-specific catalogs
- Creates category-based cross-provider catalogs
- Builds comprehensive master catalog with statistics
- Maintains distributed catalog architecture for scalability

**Usage:**
```bash
# Generate complete catalog system
python3 support/tools/generate-catalogs.py

# Automatically scans solutions/ directory and generates:
# - support/catalog/providers/*.yml (provider catalogs)  
# - support/catalog/categories/*.yml (category catalogs)
# - support/catalog/catalog.yml (master catalog)
```

**Generated Catalog Structure:**
```
support/catalog/
├── catalog.yml                 # Master catalog with statistics and references
├── providers/                  # Provider-specific catalogs
│   ├── aws.yml
│   ├── azure.yml
│   ├── cisco.yml
│   └── ... (all providers)
└── categories/                 # Category-specific cross-provider catalogs
    ├── ai.yml
    ├── cloud.yml
    ├── cyber-security.yml
    └── ... (all categories)

support/exports/
├── solutions.json             # API-ready comprehensive solution dataset
└── templates.csv              # Website-ready CSV format

support/reports/
└── validation-report.json     # Quality and validation reports
```

**Key Features:**
- **Auto-Discovery**: Automatically finds and processes all solution metadata
- **Statistics Calculation**: Provider/category solution counts, complexity distribution
- **Cross-References**: Maintains proper links between catalogs for navigation
- **Version Tracking**: Timestamps and version information for cache invalidation

### 🔍 **5. validate-catalogs.py - Catalog Validator** 
**Purpose**: Validates catalog files against JSON schemas for consistency and compliance

**Core Functionality:**
- Validates master catalog against schema definitions
- Checks provider and category catalog compliance
- Verifies cross-references between catalogs
- Validates solution path accuracy and accessibility
- Generates comprehensive validation reports

**Usage:**
```bash
# The validator runs automatically as part of process-catalogs.py
# Or can be run independently for targeted catalog validation

python3 support/tools/validate-catalogs.py
```

**Validation Features:**
- **Schema Compliance**: JSON schema validation for all catalog types
- **Cross-Reference Validation**: Ensures all catalog links are valid
- **Path Verification**: Validates all solution paths exist and are accessible
- **Report Generation**: Detailed validation reports with error categorization

### 📋 **6. export-templates-csv.py - CSV Export Tool**
**Purpose**: Generates CSV export for website integration and external system consumption

**Core Functionality:**
- Scans all solution templates in repository
- Extracts key metadata from each solution
- Generates properly formatted GitHub URLs for all materials
- Creates website-compatible CSV format with standard columns

**Usage:**
```bash
# Generate CSV export for website
python3 support/tools/export-templates-csv.py

# Output: support/exports/templates.csv
```

**CSV Output Format:**
| Column | Description | Example |
|--------|-------------|---------|
| Provider | Technology provider name | AWS |
| Category | Solution category | Cloud Infrastructure |
| Solution Name | Human-readable solution name | Enterprise Landing Zone |
| Description | Brief solution description | Comprehensive AWS foundation setup |
| Pre Sales Templates | GitHub URL to presales materials | https://github.com/... |
| Delivery Templates | GitHub URL to delivery materials | https://github.com/... |
| Status | Current solution status | Active |

## 🔄 **Common Workflows**

### 🚀 **Creating a New Template Workflow**

**Step 1: Create Template Foundation**
```bash
python3 support/tools/clone-template.py \
  --provider "your-provider" \
  --category "your-category" \
  --solution "your-solution-name" \
  --author-name "Your Full Name" \
  --author-email "your@email.com"
```

**Step 2: Customize Template Content**
```bash
# Navigate to your new template
cd solutions/your-provider/your-category/your-solution-name

# Edit core files
vim README.md          # Solution overview
vim metadata.yml       # Solution metadata
vim docs/architecture.md  # Technical architecture
vim presales/business-case-template.md  # Business justification
```

**Step 3: Validate Template**
```bash
python3 support/tools/validate-template.py \
  --path solutions/your-provider/your-category/your-solution-name
```

**Step 4: Update Repository Catalogs**
```bash
python3 support/tools/generate-catalogs.py      # Generate catalogs
python3 support/tools/process-catalogs.py       # Process into exports
python3 support/tools/export-templates-csv.py   # Update CSV export
```

### 🔧 **Quality Assurance Workflow**

**Validate All Templates:**
```bash
python3 support/tools/validate-template.py --all
```

**Fix Issues and Re-validate:**
```bash
# Fix reported issues in templates
python3 support/tools/validate-template.py \
  --path solutions/provider/category/solution
```

**Update All Repository Data:**
```bash
python3 support/tools/generate-catalogs.py && \
python3 support/tools/process-catalogs.py && \
python3 support/tools/export-templates-csv.py
```

### 📊 **Repository Maintenance Workflow**

**Complete Repository Health Check:**
```bash
# Run all tools in maintenance sequence
echo "🔍 Validating all templates..."
python3 support/tools/validate-template.py --all

echo "🔄 Regenerating catalogs..."
python3 support/tools/generate-catalogs.py

echo "📊 Processing catalog data..."
python3 support/tools/process-catalogs.py

echo "📋 Updating CSV export..."
python3 support/tools/export-templates-csv.py

echo "✅ Repository maintenance complete!"
```

## 🔧 **Integration with CI/CD**

### GitHub Actions Integration

The tools are integrated into the repository's GitHub Actions workflow:

```yaml
# .github/workflows/template-validation.yml
name: Template Validation
on:
  pull_request:
    paths: ['solutions/**']
  push:
    branches: [main]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v4
        with:
          python-version: '3.9'
      
      - name: Install dependencies
        run: pip install pyyaml jsonschema click
      
      - name: Validate templates
        run: python3 support/tools/validate-template.py --all
      
      - name: Update catalogs
        if: github.ref == 'refs/heads/main'
        run: |
          python3 support/tools/generate-catalogs.py
          python3 support/tools/process-catalogs.py
          python3 support/tools/export-templates-csv.py
```

### Pre-commit Hooks Integration

```bash
# Install pre-commit hooks
pip install pre-commit

# Create .pre-commit-config.yaml
cat << EOF > .pre-commit-config.yaml
repos:
  - repo: local
    hooks:
      - id: validate-templates
        name: Validate Templates
        entry: python3 support/tools/validate-template.py --all
        language: system
        pass_filenames: false
EOF

# Install hooks
pre-commit install
```

## ❌ **Error Handling and Troubleshooting**

### **Common Issues and Solutions**

**1. Permission Denied Errors:**
```bash
# Issue: Cannot write to solutions/ directory
# Solution: Fix permissions
chmod -R 755 solutions/
```

**2. Invalid Category/Provider:**
```bash
# Issue: Category 'invalid-cat' not in standard categories
# Solution: Use valid categories
# Valid categories: ai, cloud, cyber-security, devops, modern-workspace, network
# Valid providers: aws, azure, cisco, dell, github, google, hashicorp, ibm, juniper, microsoft, nvidia
```

**3. Missing Dependencies:**
```bash
# Issue: ModuleNotFoundError: No module named 'yaml'
# Solution: Install required packages
pip3 install pyyaml jsonschema click
```

**4. Template Already Exists:**
```bash
# Issue: Template already exists at target path
# Solution: Either remove existing or choose different name
rm -rf solutions/provider/category/solution  # Remove existing
# OR use different solution name
```

**5. Metadata Validation Failures:**
```bash
# Issue: Missing required metadata field: description
# Solution: Add required fields to metadata.yml
# Required fields: provider, category, solution_name, description, version, status, maintainers, tags
```

**6. Path-Related Issues:**
```bash
# Issue: Template path does not exist
# Solution: Ensure you're running from repository root
cd /path/to/templates  # Navigate to repository root
python3 support/tools/script.py  # Run script
```

### **Exit Codes Reference**
- **0**: Success, no issues found
- **1**: Warnings present, check output for details
- **2**: Errors found, must be fixed before proceeding
- **3**: Fatal error, script couldn't complete execution

### **Debugging and Verbose Output**
```bash
# Enable verbose output for debugging
python3 support/tools/validate-template.py --all --verbose

# Check Python path and imports
python3 -c "import sys; print(sys.path)"
python3 -c "import yaml, jsonschema, click; print('All imports successful')"

# Verify file permissions
ls -la support/tools/
ls -la solutions/
```

## 🎯 **Performance and Optimization**

### **Performance Characteristics**
- **Template Creation**: <5 seconds per template
- **Validation (single)**: 1-3 seconds per template  
- **Validation (all)**: 1-2 minutes for 35+ templates
- **Catalog Generation**: 5-10 seconds for full repository
- **Memory Usage**: <100MB for typical repository size

### **Optimization Tips**
```bash
# Use structure-only validation for faster checks
python3 support/tools/validate-template.py --all --structure-only

# Process specific provider/category only
python3 support/tools/validate-template.py --path solutions/aws/

# Use virtual environment to avoid dependency conflicts
python3 -m venv venv && source venv/bin/activate
```

## 🤝 **Contributing and Development**

### **Adding New Scripts**
1. **Follow Naming Convention**: Use descriptive, hyphenated names (e.g., `new-feature-tool.py`)
2. **Add Documentation**: Include comprehensive docstring and usage examples
3. **Handle Errors Gracefully**: Provide clear error messages and exit codes
4. **Support Command Line**: Use `argparse` or `click` for parameter handling
5. **Update This README**: Document new scripts, parameters, and usage

### **Testing Scripts**
```bash
# Create test template for development
python3 support/tools/clone-template.py \
  --provider "test-provider" \
  --category "ai" \
  --solution "test-solution" \
  --author-name "Test User" \
  --author-email "test@example.com"

# Validate test template
python3 support/tools/validate-template.py --path solutions/test-provider/ai/test-solution

# Clean up test data
rm -rf solutions/test-provider/
```

### **Code Quality Standards**
- **PEP 8 Compliance**: Follow Python style guidelines
- **Error Handling**: Comprehensive try/catch blocks with specific error messages
- **Documentation**: Clear docstrings and inline comments
- **Modularity**: Reusable functions and classes where appropriate
- **Cross-Platform**: Support Linux, macOS, and Windows path handling

---

## 📞 **Support and Resources**

### **Getting Help**
- **Script Usage**: Run any script with `--help` flag for detailed usage information
- **Issues**: Report bugs via [GitHub Issues](https://github.com/eoframework/templates/issues)
- **Feature Requests**: Submit via [GitHub Discussions](https://github.com/eoframework/templates/discussions)
- **Documentation**: Check [repository docs](../../docs/) for comprehensive guidance

### **Best Practices**
- Always run validation after template creation or modification
- Use version control for all template changes and script modifications
- Test scripts in development environment before production use
- Keep tools updated with latest repository standards and requirements
- Follow established workflows for consistent results and quality

**These comprehensive development tools ensure consistent quality, efficient workflows, and enterprise-grade automation for the EO Framework™ Templates repository.**