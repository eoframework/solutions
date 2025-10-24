# Landing Zone

**Provider:** Google
**Category:** Cloud
**Version:** 1.0.0
**Status:** In Review

## Solution Description

Starting on Google Cloud without a proper foundation leads to security gaps, disorganized resources, and management challenges as usage grows. Teams need guardrails that prevent misconfigurations while allowing them to work independently. Building a secure, scalable cloud foundation requires understanding Google Cloud best practices and implementing many interconnected configurations.

This solution implements Google Cloud's enterprise foundation blueprint with security controls, networking, identity management, and governance policies. It creates organizational structure, sets up billing, configures logging and monitoring, and establishes policies that enforce security requirements. The landing zone provides teams with secure project environments while maintaining centralized oversight.


## 📥 Access This Solution

### Quick Download

**Option 1: Using Helper Script**
```bash
curl -O https://raw.githubusercontent.com/eoframework/public-assets/main/download-solution.sh
chmod +x download-solution.sh
./download-solution.sh google/cloud/landing-zone
```

**Option 2: Git Sparse Checkout (Recommended)**
```bash
# Clone with sparse checkout
git clone --filter=blob:none --sparse https://github.com/eoframework/public-assets.git
cd public-assets

# Checkout this specific solution
git sparse-checkout set solutions/google/cloud/landing-zone

# View the solution
cd solutions/google/cloud/landing-zone
ls -la
```

**Option 3: Browse on GitHub**
- View online: https://github.com/eoframework/public-assets/tree/main/solutions/google/cloud/landing-zone

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
