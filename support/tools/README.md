# EO Framework™ Development Tools

![Tools](https://img.shields.io/badge/Tools-10_Scripts-blue)
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

### **9. solution-doc-builder.py** - Professional Document Builder

Builds professional output documents from raw source files (Markdown, CSV) using branded templates. Supports granular filtering by file type, specific files, or directories for targeted generation.

**Usage:**
```bash
# Generate all outputs for a solution (default - backward compatible)
python3 support/tools/solution-doc-builder.py --path solution-template/

# Generate only Excel files
python3 support/tools/solution-doc-builder.py --path solutions/aws/ai/intelligent-document-processing/ --type excel

# Generate only Word and PowerPoint files
python3 support/tools/solution-doc-builder.py --path solutions/aws/ai/intelligent-document-processing/ --type word pptx

# Generate only a specific file
python3 support/tools/solution-doc-builder.py --path solutions/aws/ai/intelligent-document-processing/ --file statement-of-work.md

# Generate only presales directory files
python3 support/tools/solution-doc-builder.py --path solutions/aws/ai/intelligent-document-processing/ --dir presales

# Dry run - preview what would be generated
python3 support/tools/solution-doc-builder.py --path solutions/aws/ai/intelligent-document-processing/ --dry-run

# Generate for all solutions
find solutions/ -type d -name "sample-solution" -prune -o -type d -mindepth 3 -maxdepth 3 -print | \
  while read dir; do python3 support/tools/solution-doc-builder.py --path "$dir"; done
```

**Parameters:**
- `--path` **(required)**: Directory containing `raw/` subdirectories with source files
- `--type`: Filter by file type (`excel`, `word`, `pptx`) - can specify multiple
- `--file`: Generate only this specific source file (e.g., `statement-of-work.md`)
- `--files`: Comma-separated list of source files to generate
- `--dir`: Process only files in this directory (`presales` or `delivery`)
- `--force`: Regenerate files even if output already exists
- `--dry-run`: Show what would be generated without creating files
- `--quiet`: Suppress progress output (errors only)
- `--verbose`: Show detailed processing including skipped files

**What it does:**
- **CSV → Excel (.xlsx)**: Converts CSV files to styled Excel spreadsheets with:
  - Professional header formatting (blue background, white text)
  - Auto-adjusted column widths
  - Border styling and cell alignment
  - Frozen header rows

- **Markdown → Word (.docx)**: Converts Markdown to formatted Word documents with:
  - Heading hierarchy preservation (H1-H6)
  - Paragraph formatting
  - Bullet and numbered lists
  - Basic text formatting

- **Markdown → PowerPoint (.pptx)**: Converts Markdown to presentations with:
  - EO Framework branded template (from `support/doc-templates/powerpoint/`)
  - H1 headers create title slides
  - H2 headers create content slides
  - Bullet points automatically formatted
  - Professional layouts and styling

**Dependencies:**
```bash
pip3 install pandas openpyxl python-docx python-pptx markdown-it-py
```

**Directory Structure:**
```
solution-name/
├── presales/
│   ├── raw/                           # Source files
│   │   ├── business-case.md
│   │   ├── executive-presentation.md
│   │   └── roi-calculator.csv
│   ├── business-case.docx             # Generated
│   ├── executive-presentation.pptx    # Generated (using template)
│   └── roi-calculator.xlsx            # Generated
└── delivery/
    ├── raw/                           # Source files
    │   ├── implementation-guide.md
    │   └── requirements.csv
    ├── implementation-guide.docx      # Generated
    └── requirements.xlsx              # Generated
```

**Output Example:**
```
🔍 Scanning: solutions/aws/ai/intelligent-document-processing
📁 Found 2 raw directories

📂 Processing: presales/raw
  ✅ business-case.md → business-case.docx
  ✅ executive-presentation.md → executive-presentation.pptx
  ✅ roi-calculator.csv → roi-calculator.xlsx

📂 Processing: delivery/raw
  ✅ implementation-guide.md → implementation-guide.docx
  ✅ requirements.csv → requirements.xlsx

============================================================
📊 Generation Summary
============================================================
✅ CSV → Excel:      2 files
✅ MD → Word:        2 files
✅ MD → PowerPoint:  1 files

📁 Total generated:  5 files
✨ All files generated successfully!
============================================================
```

**Templates:**
- PowerPoint template: `support/doc-templates/powerpoint/EOFramework-Template-3Logos.pptx`
- See: [doc-templates/README.md](../doc-templates/README.md) for template customization

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
# Edit raw/ files: markdown and CSV source files in presales/raw/ and delivery/raw/

# Step 3: Generate professional outputs
cd ../../..  # Back to repo root
python3 support/tools/generate-outputs.py --path solutions/aws/cloud/my-solution

# Step 4: Validate
python3 support/tools/validate-template.py \
  --path solutions/aws/cloud/my-solution

# Step 5: Update catalogs
python3 support/tools/generate-catalogs.py
python3 support/tools/process-catalogs.py
python3 support/tools/export-templates-csv.py --output-type public --git-based
```

### **Repository Maintenance**

```bash
# Complete health check
echo "🔍 Validating all templates..."
python3 support/tools/validate-template.py --all

echo "📄 Regenerating professional outputs..."
find solutions/ -type d -name "sample-solution" -prune -o -type d -mindepth 3 -maxdepth 3 -print | \
  while read dir; do
    if [ -d "$dir/presales/raw" ] || [ -d "$dir/delivery/raw" ]; then
      python3 support/tools/generate-outputs.py --path "$dir"
    fi
  done

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
