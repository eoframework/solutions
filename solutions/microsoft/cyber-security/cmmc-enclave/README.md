# CMMC Enclave

**Provider:** Microsoft
**Category:** Cyber Security
**Version:** 1.0.0
**Status:** In Review

## Overview

CMMC-compliant secure enclave for defense contractors

## 📥 Access This Solution

### Quick Download

**Option 1: Using Helper Script**
```bash
curl -O https://raw.githubusercontent.com/eoframework/public-assets/main/download-solution.sh
chmod +x download-solution.sh
./download-solution.sh microsoft/cyber-security/cmmc-enclave
```

**Option 2: Git Sparse Checkout (Recommended)**
```bash
# Clone with sparse checkout
git clone --filter=blob:none --sparse https://github.com/eoframework/public-assets.git
cd public-assets

# Checkout this specific solution
git sparse-checkout set solutions/microsoft/cyber-security/cmmc-enclave

# View the solution
cd solutions/microsoft/cyber-security/cmmc-enclave
ls -la
```

**Option 3: Browse on GitHub**
- View online: https://github.com/eoframework/public-assets/tree/main/solutions/microsoft/cyber-security/cmmc-enclave

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

This solution is licensed under the Business Source License 1.1 (BSL 1.1).

---

**EO Framework™** - Enterprise Optimization Solutions
