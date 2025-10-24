# VxRail Hyperconverged

**Provider:** Dell
**Category:** Cloud
**Version:** 1.0.0
**Status:** In Review

## Overview

Complete HCI platform for enterprise workloads

## 📥 Access This Solution

### Quick Download

**Option 1: Using Helper Script**
```bash
curl -O https://raw.githubusercontent.com/eoframework/public-assets/main/download-solution.sh
chmod +x download-solution.sh
./download-solution.sh dell/cloud/vxrail-hyperconverged
```

**Option 2: Git Sparse Checkout (Recommended)**
```bash
# Clone with sparse checkout
git clone --filter=blob:none --sparse https://github.com/eoframework/public-assets.git
cd public-assets

# Checkout this specific solution
git sparse-checkout set solutions/dell/cloud/vxrail-hyperconverged

# View the solution
cd solutions/dell/cloud/vxrail-hyperconverged
ls -la
```

**Option 3: Browse on GitHub**
- View online: https://github.com/eoframework/public-assets/tree/main/solutions/dell/cloud/vxrail-hyperconverged

## 📁 Solution Structure

This solution includes:

- **`presales/`** - Business case materials, ROI calculators, presentations
- **`delivery/`** - Implementation guides, configuration templates, automation scripts
  - `implementation-guide.md` - Step-by-step implementation instructions
  - `scripts/` - Deployment automation (Bash, Python, Terraform, PowerShell)
  - `scripts/README.md` - Detailed script usage and prerequisites
- **`metadata.yml`** - Solution metadata and requirements
- **`CHANGELOG.md`** - Version history and updates

## 🚀 Getting Started

1. **Review the business case**: See `presales/` for ROI analysis and presentations
2. **Check prerequisites**: Review `delivery/implementation-guide.md` for requirements
3. **Deploy the solution**: Follow instructions in `delivery/scripts/README.md`

For detailed deployment steps, see [`delivery/scripts/README.md`](delivery/scripts/README.md).

## 📄 License

See: https://www.eoframework.org/license/

---

**[EO Framework™](https://eoframework.org)** - Exceptional Outcome Framework
