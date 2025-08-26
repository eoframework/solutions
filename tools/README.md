# EO Framework™ Development Tools

This directory contains all development utilities and template foundations for the EO Framework™ Templates repository. These tools enable efficient creation, validation, and management of enterprise solution templates.

## Directory Structure

```
tools/
├── README.md               # This file - tools overview and documentation
├── clone-template.py       # 🏗️ Creates new solution templates from master-template
├── validate-template.py    # ✅ Validates template structure and metadata
└── sync-csv.py             # 📊 Generates website CSV export
```

**Note**: The `master-template/` directory is located at the repository root level (`/templates/master-template/`) to emphasize its foundational importance as the authoritative template for all EO Framework™ solutions.

## Script Details

### [clone-template.py](clone-template.py) - Template Creator
**Purpose**: Creates new solution templates from the master template
**Functionality**:
- Copies the complete `master-template/` structure
- Replaces placeholder values with actual solution details
- Creates proper directory structure under `solutions/`
- Updates metadata and documentation files
- Handles file naming and path generation

**Usage**:
```bash
python tools/clone-template.py \
  --provider "ProviderName" \
  --category "category-name" \
  --solution "solution-name" \
  --author-name "Your Name" \
  --author-email "your.email@company.com"
```

**Parameters**:
- `--provider`: Technology provider name (e.g., "aws", "azure", "juniper")
- `--category`: Solution category (ai, cloud, cyber-security, devops, modern-workspace, network)
- `--solution`: Solution name (lowercase with hyphens)
- `--author-name`: Template author's full name
- `--author-email`: Template author's email address

**Output**:
- Creates `solutions/{provider}/{category}/{solution}/` directory
- Populates with complete template structure
- Updates all placeholder content with provided values
- Ready for customization and development

**Example**:
```bash
python tools/clone-template.py \
  --provider "juniper" \
  --category "network" \
  --solution "mist-ai-network" \
  --author-name "John Smith" \
  --author-email "john.smith@company.com"
```

### [validate-template.py](validate-template.py) - Template Validator
**Purpose**: Validates template structure, metadata, and content quality
**Functionality**:
- Checks required directory structure
- Validates metadata.yml schema compliance
- Verifies all required files are present
- Checks file naming conventions
- Validates content formatting and completeness
- Reports errors, warnings, and suggestions

**Usage**:
```bash
# Validate specific template
python tools/validate-template.py --path solutions/juniper/network/mist-ai-network

# Validate all templates
python tools/validate-template.py --all

# Validate with verbose output
python tools/validate-template.py --all --verbose

# Check only structure (skip content validation)
python tools/validate-template.py --path solutions/aws/cloud/landing-zone --structure-only
```

**Parameters**:
- `--path`: Path to specific template directory
- `--all`: Validate all templates in the repository
- `--verbose`: Show detailed validation information
- `--structure-only`: Check only directory structure and required files

**Validation Checks**:
- ✅ **Structure**: Required directories and files present
- ✅ **Metadata**: metadata.yml schema compliance
- ✅ **Naming**: File and directory naming conventions
- ✅ **Content**: Documentation completeness and formatting
- ✅ **Links**: Internal and external link validation
- ✅ **Scripts**: Automation script syntax and standards

**Output Formats**:
- Console output with color-coded results
- Exit codes: 0 (success), 1 (warnings), 2 (errors)
- Detailed error and warning messages
- Summary statistics and recommendations

### [sync-csv.py](sync-csv.py) - CSV Export Tool
**Purpose**: Generates CSV file for website integration and external systems
**Functionality**:
- Scans all solution templates in repository
- Extracts key metadata from each solution
- Generates GitHub URLs for presales and delivery materials
- Creates `templates.csv` for website consumption

**Usage**:
```bash
python tools/sync-csv.py
```

**Output**: Creates `templates.csv` with columns:
- Provider
- Category  
- Solution Name
- Description
- Pre Sales Templates (GitHub URL)
- Delivery Templates (GitHub URL)
- Status

## Usage Workflows

### Creating a New Template

1. **Run Template Creator**:
   ```bash
   python tools/clone-template.py \
     --provider "your-provider" \
     --category "your-category" \
     --solution "your-solution" \
     --author-name "Your Name" \
     --author-email "your@email.com"
   ```

2. **Customize Template Content**:
   - Edit README.md with solution overview
   - Update metadata.yml with accurate information
   - Develop presales materials
   - Create delivery documentation
   - Write automation scripts

3. **Validate Template**:
   ```bash
   python tools/validate-template.py --path solutions/your-provider/your-category/your-solution
   ```

4. **Update Catalogs**:
   ```bash
   python3 catalog/tools/generator.py
   ```

### Maintaining Existing Templates

1. **Validate All Templates**:
   ```bash
   python tools/validate-template.py --all
   ```

2. **Fix Issues**:
   - Address any errors reported by validator
   - Update content to meet current standards
   - Ensure all required files are present

3. **Re-validate**:
   ```bash
   python tools/validate-template.py --path solutions/specific/template/path
   ```

### CI/CD Integration

These scripts are integrated into the GitHub Actions workflow:

```yaml
# .github/workflows/template-validation.yml
- name: Validate template structure
  run: |
    python tools/validate-template.py --all
```

**Automated Checks**:
- Template structure validation on pull requests
- Content quality checks on template changes
- Catalog generation after successful validation
- Error reporting and build failure on issues

## Script Requirements

### Dependencies
```bash
pip install pyyaml          # YAML parsing and generation
pip install jsonschema      # Schema validation
pip install pathlib         # Path manipulation (Python 3.4+)
```

### Python Version
- **Minimum**: Python 3.7
- **Recommended**: Python 3.9+
- **Compatibility**: Cross-platform (Linux, macOS, Windows)

### File Permissions
Scripts require read/write access to:
- `solutions/` directory (for template creation)
- `master-template/` directory (for template source)
- `catalog/` directory (for catalog updates)

## Error Handling

### Common Issues

1. **Permission Denied**:
   ```bash
   # Fix: Ensure write permissions
   chmod +w solutions/
   ```

2. **Invalid Category**:
   ```bash
   # Fix: Use valid category names
   # Valid: ai, cloud, cyber-security, devops, modern-workspace, network
   ```

3. **Template Already Exists**:
   ```bash
   # Fix: Choose different solution name or remove existing
   ```

4. **Missing Dependencies**:
   ```bash
   # Fix: Install required packages
   pip install pyyaml jsonschema
   ```

### Exit Codes
- **0**: Success, no issues found
- **1**: Warnings present, check output
- **2**: Errors found, must be fixed
- **3**: Fatal error, script couldn't complete

## Script Development

### Adding New Scripts

1. **Follow Naming Convention**: Use descriptive, hyphenated names
2. **Add Documentation**: Include docstring and usage examples
3. **Handle Errors Gracefully**: Provide clear error messages
4. **Support Command Line**: Use argparse for parameter handling
5. **Update This README**: Document new scripts and usage

### Testing Scripts

```bash
# Test template creation
python tools/clone-template.py --provider test --category ai --solution test-solution --author-name "Test User" --author-email "test@example.com"

# Test validation
python tools/validate-template.py --path solutions/test/ai/test-solution

# Cleanup test data
rm -rf solutions/test/
```

## Support and Troubleshooting

### Getting Help
- **Script Usage**: Run with `--help` flag for detailed usage
- **Issues**: Report bugs via GitHub Issues
- **Feature Requests**: Submit via GitHub Discussions
- **Documentation**: Check repository README and docs/

### Best Practices
- Always validate templates after creation or modification
- Use version control for all template changes
- Test scripts in development environment before production use
- Keep scripts updated with latest standards and requirements