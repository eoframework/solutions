# EO Framework™ Solutions - Git-Based Distribution Guide

## Overview

EO Framework™ solutions are distributed directly through Git repositories, allowing you to:

- ✅ **Browse before downloading** - Preview all files on GitHub
- ✅ **Selective checkout** - Download only the solutions you need
- ✅ **Version control** - Access specific versions via Git tags
- ✅ **Contribute back** - Fork, improve, and submit pull requests
- ✅ **Stay updated** - Pull latest changes easily

---

## Repository Structure

```
eoframework/public-assets (Public Repository)
├── solutions/
│   ├── aws/
│   │   ├── ai/
│   │   │   └── intelligent-document-processing/
│   │   │       ├── README.md
│   │   │       ├── metadata.yml
│   │   │       ├── CHANGELOG.md
│   │   │       ├── presales/
│   │   │       └── delivery/
│   │   └── cloud/
│   │       └── ...
│   ├── azure/
│   ├── cisco/
│   └── ...
└── catalog/
    ├── solutions.csv
    └── solutions.json
```

---

## Quick Start

### Option 1: Browse on GitHub (No Download)

Simply visit:
```
https://github.com/eoframework/public-assets
```

Navigate through folders to preview solutions.

---

### Option 2: Clone Specific Solution (Recommended)

```bash
# 1. Clone repository with sparse checkout
git clone --filter=blob:none --sparse https://github.com/eoframework/public-assets.git
cd public-assets

# 2. Checkout only the solution you need
git sparse-checkout set solutions/aws/ai/intelligent-document-processing

# 3. Use the solution
cd solutions/aws/ai/intelligent-document-processing
cat README.md
```

**What this does:**
- Downloads only the files you need (~200KB vs 10MB full repo)
- Sets up Git tracking for updates
- Keeps your workspace clean

---

### Option 3: Clone Multiple Solutions

```bash
# Clone repository structure
git clone --filter=blob:none --sparse https://github.com/eoframework/public-assets.git
cd public-assets

# Add multiple solutions
git sparse-checkout set \
  solutions/aws/ai/intelligent-document-processing \
  solutions/azure/cloud/landing-zone \
  solutions/cisco/network/sd-wan-enterprise

# Or add entire provider
git sparse-checkout set solutions/aws
```

---

### Option 4: Clone Everything

```bash
# Full clone (if you need all solutions)
git clone https://github.com/eoframework/public-assets.git
cd public-assets
```

**Size:** ~8-10MB for all 35+ solutions

---

## Version Management

### Get Latest Version (Default)

When you clone, you automatically get the latest version:

```bash
git clone --sparse https://github.com/eoframework/public-assets.git
cd public-assets
git sparse-checkout set solutions/aws/ai/intelligent-document-processing

# Check version
cat solutions/aws/ai/intelligent-document-processing/metadata.yml | grep version
```

---

### Get Specific Version

Each solution version is tagged in Git:

```bash
# Clone repository
git clone --sparse https://github.com/eoframework/public-assets.git
cd public-assets

# List available tags for a solution
git tag | grep "aws/ai/intelligent-document-processing"

# Example output:
# aws/ai/intelligent-document-processing-v1.0.0
# aws/ai/intelligent-document-processing-v1.1.0
# aws/ai/intelligent-document-processing-v1.2.0

# Checkout specific version
git checkout tags/aws/ai/intelligent-document-processing-v1.1.0
git sparse-checkout set solutions/aws/ai/intelligent-document-processing
```

---

### View Version History

```bash
cd solutions/aws/ai/intelligent-document-processing

# View changelog
cat CHANGELOG.md

# View Git history
git log --oneline -- .

# View changes between versions
git diff aws/ai/intelligent-document-processing-v1.0.0..aws/ai/intelligent-document-processing-v1.1.0
```

---

## Update Solutions

### Update to Latest Version

```bash
cd public-assets

# Pull latest changes
git checkout main
git pull origin main

# Your sparse checkout automatically updates
```

---

### Switch Versions

```bash
# Currently on v1.1.0, want to switch to v1.2.0
git checkout tags/aws/ai/intelligent-document-processing-v1.2.0

# Go back to latest
git checkout main
```

---

## Advanced Workflows

### Download Single File

Don't need the entire solution? Grab just one file:

```bash
# Download a specific file directly
wget https://raw.githubusercontent.com/eoframework/public-assets/main/solutions/aws/ai/intelligent-document-processing/README.md

# Or use curl
curl -O https://raw.githubusercontent.com/eoframework/public-assets/main/solutions/aws/ai/intelligent-document-processing/presales/business-case.md
```

---

### Compare Solutions

```bash
# Clone and compare two similar solutions
git clone --sparse https://github.com/eoframework/public-assets.git
cd public-assets

git sparse-checkout set \
  solutions/aws/cloud/landing-zone \
  solutions/azure/cloud/landing-zone

# Compare architectures
diff solutions/aws/cloud/landing-zone/docs/architecture.md \
     solutions/azure/cloud/landing-zone/docs/architecture.md
```

---

### Fork and Contribute

```bash
# 1. Fork the repository on GitHub
#    Visit: https://github.com/eoframework/public-assets
#    Click "Fork"

# 2. Clone your fork
git clone https://github.com/YOUR-USERNAME/public-assets.git
cd public-assets

# 3. Make improvements
cd solutions/aws/ai/intelligent-document-processing
# Edit files...

# 4. Commit and push
git add .
git commit -m "Improve AWS IDP terraform scripts"
git push origin main

# 5. Create pull request on GitHub
```

---

## Download Helper Script

For users who prefer a simpler download experience:

```bash
# Download the helper script
curl -O https://raw.githubusercontent.com/eoframework/public-assets/main/download-solution.sh
chmod +x download-solution.sh

# Download latest version of a solution
./download-solution.sh aws/ai/intelligent-document-processing

# Download specific version
./download-solution.sh aws/ai/intelligent-document-processing v1.1.0

# This creates: intelligent-document-processing/ folder with all files
```

---

## Troubleshooting

### "I don't see any files after sparse checkout"

Make sure you're in the right directory:
```bash
# After sparse-checkout, navigate into the solution
cd solutions/aws/ai/intelligent-document-processing
ls -la
```

### "How do I see all available solutions?"

```bash
# Browse online
https://github.com/eoframework/public-assets/tree/main/solutions

# Or view catalog
wget https://raw.githubusercontent.com/eoframework/public-assets/main/catalog/solutions.csv
cat solutions.csv
```

### "Sparse checkout not working"

Make sure you have Git 2.25+:
```bash
git --version

# If older, update Git or use full clone:
git clone https://github.com/eoframework/public-assets.git
```

---

## Tag Naming Convention

All solution tags follow this format:
```
{provider}/{category}/{solution-name}-v{version}

Examples:
aws/ai/intelligent-document-processing-v1.2.0
azure/cloud/landing-zone-v2.0.1
cisco/network/sd-wan-enterprise-v1.0.0
```

---

## FAQ

**Q: How is this different from downloading a ZIP?**
A: With Git, you get:
- Browse files before downloading
- Version history and changelog
- Easy updates (`git pull`)
- Ability to contribute improvements
- Smaller downloads with sparse checkout

**Q: Can I still download as a ZIP?**
A: Yes! On GitHub, click the "Code" button → "Download ZIP"

**Q: How do I know when a solution is updated?**
A: Watch the repository on GitHub, or check the CHANGELOG.md file in each solution

**Q: Are all solutions publicly available?**
A: Only solutions with status "Active" or "Beta" are published. "Draft" and "In Review" solutions remain private.

**Q: Can I use these solutions commercially?**
A: Please review the LICENSE file. BSL 1.1 allows evaluation and development but requires licensing for production use.

---

## Support

- **Documentation:** https://docs.eoframework.com
- **Issues:** https://github.com/eoframework/public-assets/issues
- **Email:** support@eoframework.com
- **Website:** https://eoframework.com

---

**Ready to get started?** Visit https://github.com/eoframework/public-assets
