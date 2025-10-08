# Solution Packaging System

Automated system for creating public distribution packages from private templates.

## 📦 Overview

This system packages individual solutions into ZIP files for public distribution via the `public-assets` repository, while keeping the private `templates` repository secure.

## 🛠️ Tools

### 1. `package-solution.py`
Creates ZIP packages for individual solutions with version management.

**Usage:**
```bash
python3 support/tools/package-solution.py \
  --solution solutions/aws/ai/intelligent-document-processing \
  --output /path/to/public-assets/solutions \
  --bump patch \
  --changelog "Bug fixes and documentation updates"
```

**Options:**
- `--solution`: Path to solution directory (required)
- `--output`: Output directory (public-assets/solutions/) (required)
- `--version`: Specific version (optional, auto-bumps if not provided)
- `--bump`: Version bump type: major, minor, patch (default: patch)
- `--changelog`: Changelog entry for this version

**What it does:**
1. Reads solution metadata.yml
2. Determines new version number
3. Creates ZIP package excluding private files
4. Sanitizes metadata (removes private fields, adds public URLs)
5. Generates SHA256 checksum
6. Updates manifest.json with version history
7. Copies to both `v{version}/` and `latest/` folders

### 2. `export-templates-csv.py` (Updated)
Generates catalog CSV files for both private and public use.

**Usage:**
```bash
# Private mode (internal paths)
python3 support/tools/export-templates-csv.py --output-type private

# Public mode (public download URLs)
python3 support/tools/export-templates-csv.py --output-type public
```

**Output:**
- Private: `support/exports/solutions.csv` (for internal use)
- Public: `support/exports/solutions-public.csv` (for public-assets/catalog/)

## 🔄 Automated Workflow

### GitHub Actions: `publish-solution-packages.yml`

**Triggers:**
1. **Automatic**: Push to `main` branch with changes in `solutions/**`
2. **Manual**: Workflow dispatch with specific solution

**Process:**
1. **Validate** - Run template validation
2. **Detect Changes** - Identify modified solutions
3. **Determine Version** - Auto-detect bump type based on changes
4. **Package** - Create ZIP files for each changed solution
5. **Publish** - Push to public-assets repository

**Version Bump Detection:**
- **Major**: Commit message contains `BREAKING` or `[major]`
- **Minor**: New files added (*.tf, *.py, *.sh, *.ps1, *.csv)
- **Patch**: Documentation or value changes only

**Manual Trigger:**
```bash
# Via GitHub UI: Actions → Publish Solution Packages → Run workflow
# Select:
#   - Solution path: solutions/aws/ai/intelligent-document-processing
#   - Bump type: patch/minor/major
```

## 📋 Version Management Strategy

### Semantic Versioning: MAJOR.MINOR.PATCH

#### MAJOR (v2.0.0) - Breaking Changes
- Architecture redesign requiring migration
- Terraform state breaking changes
- Incompatible infrastructure changes
- **Trigger**: `[major]` or `BREAKING:` in commit message

#### MINOR (v1.1.0) - New Features
- New Terraform modules/environments
- New automation scripts
- New CSV templates or presentations
- **Trigger**: New files detected

#### PATCH (v1.0.1) - Bug Fixes
- Documentation corrections
- Bug fixes in scripts
- CSV value updates
- **Trigger**: Only modifications, no new files

## 🔒 Metadata Sanitization

### Private Fields (Removed from Public Packages):
- `document_path` - Internal repository paths
- `internal_notes` - Private comments
- `private_notes` - Internal documentation

### Public Fields (Added to Packages):
- `repository`: https://github.com/eoframework/public-assets
- `download_latest`: Direct download URL
- `website`: https://eoframework.com/solutions
- `support_email`: support@eoframework.com
- `maintainers`: Generic public contact

## 📊 Public Assets Structure

```
public-assets/
├── solutions/
│   └── {provider}/{category}/{solution}/
│       ├── latest/
│       │   └── {solution}.zip              # Always current version
│       ├── v1.0.0/
│       │   └── {solution}-v1.0.0.zip       # Specific version
│       ├── v1.1.0/
│       │   └── {solution}-v1.1.0.zip
│       └── manifest.json                    # Version history & metadata
└── catalog/
    └── solutions.csv                        # Public catalog
```

## 🧪 Testing

### Test Packaging Locally:
```bash
# Package a single solution
python3 support/tools/package-solution.py \
  --solution solutions/aws/ai/intelligent-document-processing \
  --output /tmp/test-packages \
  --bump patch \
  --changelog "Test package"

# Verify ZIP contents
unzip -l /tmp/test-packages/aws/ai/intelligent-document-processing/latest/*.zip

# Check sanitized metadata
unzip -p /tmp/test-packages/aws/ai/intelligent-document-processing/latest/*.zip \
  intelligent-document-processing/metadata.yml
```

### Generate Public CSV:
```bash
python3 support/tools/export-templates-csv.py --output-type public
head support/exports/solutions-public.csv
```

## 🚀 Manual Package Creation

If you need to manually package a solution:

```bash
# 1. Package the solution
python3 support/tools/package-solution.py \
  --solution solutions/provider/category/solution-name \
  --output ../public-assets/solutions \
  --bump minor \
  --changelog "Added new DR environment"

# 2. Generate updated catalog
python3 support/tools/export-templates-csv.py --output-type public
cp support/exports/solutions-public.csv ../public-assets/catalog/solutions.csv

# 3. Commit to public-assets
cd ../public-assets
git add solutions/ catalog/
git commit -m "Update solution-name package"
git push origin main
```

## 📝 Manifest.json Structure

Each solution has a `manifest.json` tracking all versions:

```json
{
  "solution": "intelligent-document-processing",
  "provider": "aws",
  "category": "ai",
  "current_version": "1.0.1",
  "last_updated": "2025-10-07",
  "versions": [
    {
      "version": "1.0.1",
      "release_date": "2025-10-07",
      "download_url": "https://github.com/eoframework/public-assets/raw/main/solutions/aws/ai/intelligent-document-processing/v1.0.1/intelligent-document-processing-v1.0.1.zip",
      "size_mb": 0.09,
      "sha256": "27695da260904117...",
      "changelog": "Initial public release",
      "change_type": "patch"
    }
  ]
}
```

## 🔍 Excluded Files

The following patterns are excluded from public packages:
- `.git`, `.gitignore`
- `__pycache__`, `*.pyc`
- `.DS_Store`, `Thumbs.db`
- `.env`, `.env.*`
- `INTERNAL_*`, `private-*`
- `.vscode`, `.idea`
- `*.swp`, `*.swo`

## ✅ Verification

After packaging, verify:
1. ✅ ZIP file created in both `latest/` and `v{version}/`
2. ✅ manifest.json updated with new version
3. ✅ SHA256 checksum generated
4. ✅ Metadata sanitized (no private fields)
5. ✅ Public URLs added to metadata
6. ✅ File size reasonable (< 1 MB for most solutions)

## 🐛 Troubleshooting

**Package size too large:**
- Check for accidentally included binary files
- Verify .gitignore patterns are working
- Ensure __pycache__ directories excluded

**Metadata not sanitized:**
- Check `sanitize_metadata()` function
- Verify private fields list is complete

**Version not bumping:**
- Check manifest.json exists and is valid JSON
- Verify version format is MAJOR.MINOR.PATCH
- Check bump type parameter

## 📞 Support

For issues with packaging:
1. Check tool output for error messages
2. Verify solution has valid metadata.yml
3. Test with `--bump patch` first
4. Review GitHub Actions logs for CI/CD issues
