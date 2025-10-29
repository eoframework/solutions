# HyperFlex Cloud Bridge

**Provider:** Cisco
**Category:** Cloud
**Version:** 1.0.0
**Status:** In Review

## Solution Description

Organizations running workloads both on-premise and in the cloud need seamless connectivity and consistent management across environments. Managing separate infrastructure, security policies, and operational tools for each environment creates complexity and increases overhead. Applications that span both environments face performance and reliability challenges.

This solution implements Cisco HyperFlex to create a unified hybrid infrastructure platform. It extends on-premise data center capabilities into the cloud with consistent networking, security, and management. The solution allows workloads to move between environments and provides centralized visibility and control across all infrastructure.


## 📥 Access This Solution

### Quick Download

**Option 1: Using Helper Script**
```bash
curl -O https://raw.githubusercontent.com/eoframework/solutions/main/support/tools/download-solution.sh
chmod +x download-solution.sh
./download-solution.sh cisco/cloud/hybrid-infrastructure
```

**Option 2: Git Sparse Checkout (Recommended)**
```bash
# Clone with sparse checkout
git clone --filter=blob:none --sparse https://github.com/eoframework/solutions.git
cd solutions

# Checkout this specific solution
git sparse-checkout set solutions/cisco/cloud/hybrid-infrastructure

# View the solution
cd solutions/cisco/cloud/hybrid-infrastructure
ls -la
```

**Option 3: Browse on GitHub**
- View online: https://github.com/eoframework/solutions/tree/main/solutions/cisco/cloud/hybrid-infrastructure

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
