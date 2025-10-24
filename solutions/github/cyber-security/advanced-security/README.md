# CodeQL Security Scanner

**Provider:** GitHub
**Category:** Cyber Security
**Version:** 1.0.0
**Status:** In Review

## Solution Description

Security vulnerabilities in code often go undetected until after deployment, when they become expensive to fix and may already be exploited. Manual code reviews miss subtle security issues, and separate security scanning tools create friction in the development process. Developers need security feedback early, when fixing issues is fastest and cheapest.

This solution implements GitHub Advanced Security with CodeQL scanning integrated into development workflows. It automatically analyzes code for security vulnerabilities, detects secrets accidentally committed, and scans dependencies for known issues. Developers receive immediate feedback in pull requests, and security teams get visibility into risks across all repositories.


## 📥 Access This Solution

### Quick Download

**Option 1: Using Helper Script**
```bash
curl -O https://raw.githubusercontent.com/eoframework/public-assets/main/download-solution.sh
chmod +x download-solution.sh
./download-solution.sh github/cyber-security/advanced-security
```

**Option 2: Git Sparse Checkout (Recommended)**
```bash
# Clone with sparse checkout
git clone --filter=blob:none --sparse https://github.com/eoframework/public-assets.git
cd public-assets

# Checkout this specific solution
git sparse-checkout set solutions/github/cyber-security/advanced-security

# View the solution
cd solutions/github/cyber-security/advanced-security
ls -la
```

**Option 3: Browse on GitHub**
- View online: https://github.com/eoframework/public-assets/tree/main/solutions/github/cyber-security/advanced-security

## 🚀 Getting Started

### 1. Download the Solution
Use one of the download options above to get the complete solution package.

### 2. Pre-Sales Activities
Navigate to **`presales/`** for business case development and stakeholder engagement:
- Business case materials and ROI calculators
- Executive presentations and solution briefs
- Level of Effort (LOE) estimates
- Statement of Work (SOW) templates

### 3. Delivery and Implementation
Navigate to **`delivery/`** for project execution:
- Project plan and communication plan
- Requirements documentation
- Implementation guides and configuration templates
- **`scripts/`** folder - Deployment automation (Bash, Python, Terraform, PowerShell)
  - See [`delivery/scripts/README.md`](delivery/scripts/README.md) for detailed deployment instructions

### 4. Customize for Your Needs
All templates and configuration files can be modified to meet your specific requirements.

## 📄 License

For license information see: <a href="https://www.eoframework.org/license/" target="_blank">https://www.eoframework.org/license/</a>

---

**<a href="https://eoframework.org" target="_blank">EO Framework™</a>** - Exceptional Outcome Framework
