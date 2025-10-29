# CMMC Enclave

**Provider:** Microsoft
**Category:** Cyber Security
**Version:** 1.0.0
**Status:** In Review

## Solution Description

Defense contractors must comply with CMMC (Cybersecurity Maturity Model Certification) requirements to protect Controlled Unclassified Information (CUI). Meeting these requirements means implementing specific security controls, maintaining audit trails, and proving compliance. Building a compliant environment from scratch is complex and time-consuming without clear guidance on required configurations.

This solution creates a secure enclave within Microsoft 365 and Azure that meets CMMC Level 2 requirements. It implements required security controls, configures audit logging, restricts data access, and provides compliance reporting. The enclave isolates CUI data and ensures only authorized users can access it through compliant methods.


## 📥 Access This Solution

### Quick Download

**Option 1: Using Helper Script**
```bash
curl -O https://raw.githubusercontent.com/eoframework/solutions/main/support/tools/download-solution.sh
chmod +x download-solution.sh
./download-solution.sh microsoft/cyber-security/cmmc-enclave
```

**Option 2: Git Sparse Checkout (Recommended)**
```bash
# Clone with sparse checkout
git clone --filter=blob:none --sparse https://github.com/eoframework/solutions.git
cd solutions

# Checkout this specific solution
git sparse-checkout set solutions/microsoft/cyber-security/cmmc-enclave

# View the solution
cd solutions/microsoft/cyber-security/cmmc-enclave
ls -la
```

**Option 3: Browse on GitHub**
- View online: https://github.com/eoframework/solutions/tree/main/solutions/microsoft/cyber-security/cmmc-enclave

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
