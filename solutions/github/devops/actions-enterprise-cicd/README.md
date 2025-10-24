# GitHub Workflow Automation

**Provider:** GitHub
**Category:** DevOps
**Version:** 1.0.0
**Status:** In Review

## Solution Description

Development teams need reliable CI/CD automation, but building and maintaining pipeline infrastructure diverts resources from feature development. Different teams often duplicate effort creating similar pipelines. Without standardization, pipelines become difficult to maintain and troubleshoot when issues occur.

This solution establishes enterprise CI/CD using GitHub Actions with reusable workflows and organization-level policies. It provides pipeline templates for common scenarios, centralized secret management, and self-hosted runners for internal deployments. Teams get automated builds and deployments without managing infrastructure, while maintaining security and compliance controls.


## 📥 Access This Solution

### Quick Download

**Option 1: Using Helper Script**
```bash
curl -O https://raw.githubusercontent.com/eoframework/public-assets/main/download-solution.sh
chmod +x download-solution.sh
./download-solution.sh github/devops/actions-enterprise-cicd
```

**Option 2: Git Sparse Checkout (Recommended)**
```bash
# Clone with sparse checkout
git clone --filter=blob:none --sparse https://github.com/eoframework/public-assets.git
cd public-assets

# Checkout this specific solution
git sparse-checkout set solutions/github/devops/actions-enterprise-cicd

# View the solution
cd solutions/github/devops/actions-enterprise-cicd
ls -la
```

**Option 3: Browse on GitHub**
- View online: https://github.com/eoframework/public-assets/tree/main/solutions/github/devops/actions-enterprise-cicd

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
