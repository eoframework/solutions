# Enterprise Landing Zone

**Provider:** Azure
**Category:** Cloud
**Version:** 1.0.0
**Status:** In Review

## Solution Description

Organizations moving to Azure need a secure, well-organized cloud foundation that supports multiple teams and workloads. Without proper setup, environments become disorganized, security gaps emerge, and managing costs and compliance becomes difficult. Building this foundation from scratch requires deep Azure expertise and understanding of best practices.

This solution implements Azure's Enterprise-Scale Landing Zone architecture, providing a secure foundation for cloud operations. It sets up management groups, subscriptions, networking, identity, security controls, and governance policies. The landing zone gives teams self-service capabilities while maintaining centralized security and compliance controls.


## 📥 Access This Solution

### Quick Download

**Option 1: Using Helper Script**
```bash
curl -O https://raw.githubusercontent.com/eoframework/public-assets/main/download-solution.sh
chmod +x download-solution.sh
./download-solution.sh azure/cloud/enterprise-landing-zone
```

**Option 2: Git Sparse Checkout (Recommended)**
```bash
# Clone with sparse checkout
git clone --filter=blob:none --sparse https://github.com/eoframework/public-assets.git
cd public-assets

# Checkout this specific solution
git sparse-checkout set solutions/azure/cloud/enterprise-landing-zone

# View the solution
cd solutions/azure/cloud/enterprise-landing-zone
ls -la
```

**Option 3: Browse on GitHub**
- View online: https://github.com/eoframework/public-assets/tree/main/solutions/azure/cloud/enterprise-landing-zone

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

For license information see: https://www.eoframework.org/license/

---

**[EO Framework™](https://eoframework.org)** - Exceptional Outcome Framework
