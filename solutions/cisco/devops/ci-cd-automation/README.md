# Network Infrastructure Pipeline

**Provider:** Cisco
**Category:** DevOps
**Version:** 1.0.0
**Status:** In Review

## Solution Description

Network infrastructure changes often require manual configuration across multiple devices, leading to errors and slow deployment cycles. Teams struggle to track changes, roll back problematic updates, and maintain consistency across environments. Testing network changes in production is risky, but building separate test environments is expensive.

This solution brings DevOps practices to network infrastructure using Cisco automation tools. It enables infrastructure-as-code for network configurations, automated testing of changes, and version-controlled network policies. Teams can deploy network changes through CI/CD pipelines with approval workflows, automated validation, and easy rollback capabilities.


## 📥 Access This Solution

### Quick Download

**Option 1: Using Helper Script**
```bash
curl -O https://raw.githubusercontent.com/eoframework/public-assets/main/download-solution.sh
chmod +x download-solution.sh
./download-solution.sh cisco/devops/ci-cd-automation
```

**Option 2: Git Sparse Checkout (Recommended)**
```bash
# Clone with sparse checkout
git clone --filter=blob:none --sparse https://github.com/eoframework/public-assets.git
cd public-assets

# Checkout this specific solution
git sparse-checkout set solutions/cisco/devops/ci-cd-automation

# View the solution
cd solutions/cisco/devops/ci-cd-automation
ls -la
```

**Option 3: Browse on GitHub**
- View online: https://github.com/eoframework/public-assets/tree/main/solutions/cisco/devops/ci-cd-automation

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
