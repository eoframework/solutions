# EO Framework™ Development Tools

![Tools](https://img.shields.io/badge/Tools-8_Scripts-blue)
![Python](https://img.shields.io/badge/Python-3.8%2B-green)
![Automation](https://img.shields.io/badge/Automation-Production_Ready-orange)
![Status](https://img.shields.io/badge/Status-Active-purple)

## 🎯 **Overview**

This directory contains production-ready development utilities and automation tools for the **EO Framework™ Solutions** repository. These Python scripts and shell utilities enable efficient creation, validation, catalog management, and distribution of enterprise solution templates.

## 📋 **Prerequisites**

### 🐍 **Python Requirements**

**Minimum:**
- **Python Version**: 3.8 or higher (3.9+ recommended)
- **Operating System**: Linux, macOS, Windows
- **Memory**: 512MB RAM minimum
- **Storage**: 100MB free space

**Install Python:**
```bash
# Ubuntu/Debian
sudo apt update && sudo apt install python3 python3-pip

# macOS (using Homebrew)
brew install python3

# Windows (using Chocolatey)
choco install python3

# Verify installation
python3 --version  # Should show 3.8+
```

### 📦 **Dependencies**

```bash
# Install required packages
pip3 install pyyaml>=6.0 jsonschema>=4.0

# Verify installation
python3 -c "import yaml, jsonschema; print('Dependencies installed!')"
```

**Required Packages:**
- **`pyyaml`**: YAML parsing for metadata files
- **`jsonschema`**: Schema validation for catalogs
- **`pathlib`**: Path manipulation (built-in Python 3.4+)

## 🛠️ **Available Tools**

### **1. clone-solution-template.py** - Solution Template Creator

Creates new solution templates from the master template foundation.

**Usage:**
```bash
python3 support/tools/clone-solution-template.py \
  --provider "aws" \
  --category "cloud" \
  --solution "enterprise-landing-zone" \
  --author-name "John Smith" \
  --author-email "john.smith@company.com"
```

**Parameters:**
- `--provider` **(required)**: `aws`, `azure`, `cisco`, `dell`, `github`, `google`, `hashicorp`, `ibm`, `juniper`, `microsoft`, `nvidia`
- `--category` **(required)**: `ai`, `cloud`, `cyber-security`, `devops`, `modern-workspace`, `network`
- `--solution` **(required)**: Solution name (lowercase with hyphens)
- `--author-name` **(required)**: Author's full name
- `--author-email` **(required)**: Author's email address

**Output:**
```
✅ Successfully created: solutions/aws/cloud/enterprise-landing-zone
📝 Next steps: Review metadata.yml, update README.md, add materials
```

---

### **2. validate-template.py** - Template Validator

Comprehensive validation of template structure, metadata, and content quality.

**Usage:**
```bash
# Validate specific template
python3 support/tools/validate-template.py \
  --path solutions/aws/cloud/enterprise-landing-zone

# Validate all templates
python3 support/tools/validate-template.py --all

# Validate with verbose output
python3 support/tools/validate-template.py --all --verbose

# Structure-only validation (faster)
python3 support/tools/validate-template.py \
  --path solutions/aws/cloud/landing-zone --structure-only
```

**Parameters:**
- `--path`: Specific template directory to validate
- `--all`: Validate all templates in repository
- `--verbose`: Show detailed validation information
- `--structure-only`: Check only directory structure (skip content)

**Validation Checks:**
- ✅ Directory structure and required files
- ✅ Metadata schema compliance
- ✅ Security scanning (hardcoded secrets)
- ✅ Content quality and formatting
- ✅ Naming conventions

---

### **3. generate-catalogs.py** - Catalog Generator

Auto-generates distributed catalog system from solution metadata files.

**Usage:**
```bash
python3 support/tools/generate-catalogs.py
```

**What it does:**
- Scans all solution `metadata.yml` files
- Generates provider-specific catalogs (`support/catalog/providers/*.yml`)
- Creates category catalogs (`support/catalog/categories/*.yml`)
- Builds master catalog with statistics (`support/catalog/catalog.yml`)

**Output:**
```
support/catalog/
├── catalog.yml              # Master catalog
├── providers/
│   ├── aws.yml
│   ├── azure.yml
│   └── ... (all providers)
└── categories/
    ├── ai.yml
    ├── cloud.yml
    └── ... (all categories)
```

---

### **4. process-catalogs.py** - Catalog Processor

Processes distributed catalogs into unified exports and reports.

**Usage:**
```bash
python3 support/tools/process-catalogs.py
```

**Features:**
- Loads all catalog files (master, providers, categories)
- Provides search and filtering capabilities
- Generates comprehensive statistics
- Exports unified solution data
- Creates JSON for API consumption

**Output Files:**
- `support/exports/solutions.json` - API-ready dataset
- `support/reports/` - Analytics and reports
- Console output with statistics

---

### **5. validate-catalogs.py** - Catalog Validator

Validates catalog files against JSON schemas for consistency.

**Usage:**
```bash
python3 support/tools/validate-catalogs.py
```

**Validation:**
- Schema compliance for all catalog types
- Cross-reference validation between catalogs
- Path verification (solution directories exist)
- Generates detailed validation reports

---

### **6. export-templates-csv.py** - CSV Export Tool

Generates CSV export for website integration and external systems.

**Usage:**
```bash
# Generate public CSV (default, Git-based URLs)
python3 support/tools/export-templates-csv.py --output-type public --git-based

# Generate internal CSV (for internal use)
python3 support/tools/export-templates-csv.py --output-type private
```

**Parameters:**
- `--output-type`: `private` (internal) or `public` (distribution)
- `--git-based`: Use Git repository URLs (recommended for public)

**Output:**
- `support/exports/solutions.csv` - Website-compatible CSV

**CSV Format:**
```csv
Provider,Category,SolutionName,Description,Version,DownloadUrl,RawURL,LatestTag,Website,SupportEmail,Status
AWS,AI,Intelligent Document Processing,Automate document insights,1.0.0,https://github.com/eoframework/solutions/tree/main/solutions/aws/ai/intelligent-document-processing,...
```

---

### **7. set-solution-status.py** - Solution Status Manager

Sets or updates solution status in metadata.yml files.

**Usage:**
```bash
# Set status for specific solution
python3 support/tools/set-solution-status.py \
  --solution solutions/aws/ai/intelligent-document-processing \
  --status "Active"

# Set status for all solutions
python3 support/tools/set-solution-status.py \
  --all \
  --status "In Review"
```

**Valid Statuses:**
- `Draft` - Work in progress
- `In Review` - Under review
- `Active` - Production ready
- `Beta` - Testing phase
- `Deprecated` - Legacy solution

---

### **8. download-solution.sh** - User Download Helper

Shell script for easy solution downloads (user-facing tool).

**Usage:**
```bash
# Download specific solution
curl -O https://raw.githubusercontent.com/eoframework/solutions/main/support/tools/download-solution.sh
chmod +x download-solution.sh
./download-solution.sh aws/ai/intelligent-document-processing

# Or with version
./download-solution.sh aws/ai/intelligent-document-processing v1.0.0
```

**Features:**
- Simple download interface for non-Git users
- Supports sparse checkout for minimal downloads
- Version-specific downloads via Git tags
- Progress indicators and error handling

---

> **Note:** Document generation tools (solution-doc-builder.py, compute-costs.py, template creation scripts) have been moved to the private `eof-tools` repository for better security and maintenance. See the [eof-tools repository](https://github.com/eoframework/eof-tools) for document generation capabilities.

---

## 🔄 **Common Workflows**

### **Creating a New Solution**

```bash
# Step 1: Create template
python3 support/tools/clone-solution-template.py \
  --provider "aws" \
  --category "cloud" \
  --solution "my-solution" \
  --author-name "Your Name" \
  --author-email "your@email.com"

# Step 2: Customize content
cd solutions/aws/cloud/my-solution
# Edit metadata.yml, README.md, and add solution materials

# Step 3: Validate
python3 support/tools/validate-template.py \
  --path solutions/aws/cloud/my-solution

# Step 4: Update catalogs
python3 support/tools/generate-catalogs.py
python3 support/tools/process-catalogs.py
python3 support/tools/export-templates-csv.py --output-type public --git-based
```

### **Repository Maintenance**

```bash
# Complete health check
echo "🔍 Validating all templates..."
python3 support/tools/validate-template.py --all

echo "🔄 Regenerating catalogs..."
python3 support/tools/generate-catalogs.py

echo "📊 Processing catalog data..."
python3 support/tools/process-catalogs.py

echo "📋 Updating CSV export..."
python3 support/tools/export-templates-csv.py --output-type public --git-based

echo "✅ Maintenance complete!"
```

### **Updating Solution Status**

```bash
# Mark solutions as ready
python3 support/tools/set-solution-status.py \
  --solution solutions/aws/ai/intelligent-document-processing \
  --status "Active"

# Mark all for review
python3 support/tools/set-solution-status.py --all --status "In Review"
```

---

## 🔧 **GitHub Actions Integration**

These tools integrate with repository workflows:

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
        run: pip install pyyaml jsonschema

      - name: Validate templates
        run: python3 support/tools/validate-template.py --all

      - name: Update catalogs
        if: github.ref == 'refs/heads/main'
        run: |
          python3 support/tools/generate-catalogs.py
          python3 support/tools/process-catalogs.py
          python3 support/tools/export-templates-csv.py --output-type public --git-based
```

---

## ❌ **Troubleshooting**

### **Common Issues**

**1. Permission Denied:**
```bash
chmod +x support/tools/*.py support/tools/*.sh
```

**2. Missing Dependencies:**
```bash
pip3 install pyyaml jsonschema
```

**3. Invalid Category/Provider:**
```
Valid categories: ai, cloud, cyber-security, devops, modern-workspace, network
Valid providers: aws, azure, cisco, dell, github, google, hashicorp, ibm, juniper, microsoft, nvidia
```

**4. Template Already Exists:**
```bash
rm -rf solutions/provider/category/solution  # Remove and recreate
```

**5. Path Issues:**
```bash
# Always run from repository root
cd /path/to/solutions
python3 support/tools/script.py
```

### **Exit Codes**
- **0**: Success
- **1**: Warnings present
- **2**: Errors found (must fix)
- **3**: Fatal error

---

## 🎯 **Performance**

- **Template Creation**: <5 seconds
- **Validation (single)**: 1-3 seconds
- **Validation (all 35)**: 1-2 minutes
- **Catalog Generation**: 5-10 seconds
- **Memory Usage**: <100MB

---

## 📞 **Support**

### **Getting Help**
- **Usage**: Run scripts with `--help` flag
- **Issues**: [GitHub Issues](https://github.com/eoframework/solutions/issues)
- **Discussions**: [GitHub Discussions](https://github.com/eoframework/solutions/discussions)
- **Documentation**: Check `support/docs/` for guides

### **Best Practices**
- Always validate after template creation/modification
- Use version control for all changes
- Test in development before production
- Follow established workflows
- Keep tools updated

---

**These production-ready tools ensure consistent quality, efficient workflows, and enterprise-grade automation for the EO Framework™ Solutions repository.**
