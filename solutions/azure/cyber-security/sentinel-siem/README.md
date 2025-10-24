# Sentinel SIEM

**Provider:** Azure
**Category:** Cyber Security
**Version:** 1.0.0
**Status:** In Review

## Solution Description

Security teams face an overwhelming volume of alerts from multiple tools—firewalls, endpoints, cloud services, and applications. Analysts spend significant time correlating events across systems, investigating false positives, and trying to identify real threats before they cause damage. Without centralized visibility, threats can go undetected across your environment.

This solution implements Azure Sentinel as a cloud-based SIEM that collects security data from across your infrastructure. It correlates events, detects anomalies using built-in analytics rules, and provides investigation tools to respond to incidents. The solution includes pre-configured connectors for common security tools and playbooks for automated response.


## 📥 Access This Solution

### Quick Download

**Option 1: Using Helper Script**
```bash
curl -O https://raw.githubusercontent.com/eoframework/public-assets/main/download-solution.sh
chmod +x download-solution.sh
./download-solution.sh azure/cyber-security/sentinel-siem
```

**Option 2: Git Sparse Checkout (Recommended)**
```bash
# Clone with sparse checkout
git clone --filter=blob:none --sparse https://github.com/eoframework/public-assets.git
cd public-assets

# Checkout this specific solution
git sparse-checkout set solutions/azure/cyber-security/sentinel-siem

# View the solution
cd solutions/azure/cyber-security/sentinel-siem
ls -la
```

**Option 3: Browse on GitHub**
- View online: https://github.com/eoframework/public-assets/tree/main/solutions/azure/cyber-security/sentinel-siem

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
