# Multi Cloud Platform

**Provider:** HashiCorp
**Category:** Cloud
**Version:** 1.0.0
**Status:** In Review

## Solution Description

Organizations using multiple cloud providers face the challenge of different APIs, tools, and workflows for each platform. Managing infrastructure requires cloud-specific expertise and creates dependencies on specific vendors. Deploying the same application across clouds requires building everything multiple times with provider-specific tools.

This solution uses HashiCorp tools (Terraform, Consul, Vault) to create a consistent platform across cloud providers. It enables infrastructure-as-code that works across AWS, Azure, and Google Cloud with the same workflow. The solution provides unified service networking, secrets management, and infrastructure provisioning regardless of underlying cloud provider.


## 📥 Access This Solution

### Quick Download

**Option 1: Using Helper Script**
```bash
curl -O https://raw.githubusercontent.com/eoframework/public-assets/main/download-solution.sh
chmod +x download-solution.sh
./download-solution.sh hashicorp/cloud/multi-cloud-platform
```

**Option 2: Git Sparse Checkout (Recommended)**
```bash
# Clone with sparse checkout
git clone --filter=blob:none --sparse https://github.com/eoframework/public-assets.git
cd public-assets

# Checkout this specific solution
git sparse-checkout set solutions/hashicorp/cloud/multi-cloud-platform

# View the solution
cd solutions/hashicorp/cloud/multi-cloud-platform
ls -la
```

**Option 3: Browse on GitHub**
- View online: https://github.com/eoframework/public-assets/tree/main/solutions/hashicorp/cloud/multi-cloud-platform

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
