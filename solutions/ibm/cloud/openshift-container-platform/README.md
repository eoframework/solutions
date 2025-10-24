# Openshift Container Platform

**Provider:** IBM
**Category:** Cloud
**Version:** 1.0.0
**Status:** In Review

## Solution Description

Organizations adopting containers need a platform that runs applications consistently across different environments—data center, cloud, and edge. Kubernetes alone requires significant expertise and additional tools for logging, monitoring, networking, and security. Development teams need self-service capabilities while operations teams need control and visibility.

This solution deploys Red Hat OpenShift on IBM Cloud as an enterprise Kubernetes platform. It adds developer tools, integrated CI/CD, security policies, and operational capabilities on top of Kubernetes. The platform provides a consistent runtime environment across locations, includes built-in monitoring and logging, and gives developers self-service application deployment with guardrails.


## 📥 Access This Solution

### Quick Download

**Option 1: Using Helper Script**
```bash
curl -O https://raw.githubusercontent.com/eoframework/public-assets/main/download-solution.sh
chmod +x download-solution.sh
./download-solution.sh ibm/cloud/openshift-container-platform
```

**Option 2: Git Sparse Checkout (Recommended)**
```bash
# Clone with sparse checkout
git clone --filter=blob:none --sparse https://github.com/eoframework/public-assets.git
cd public-assets

# Checkout this specific solution
git sparse-checkout set solutions/ibm/cloud/openshift-container-platform

# View the solution
cd solutions/ibm/cloud/openshift-container-platform
ls -la
```

**Option 3: Browse on GitHub**
- View online: https://github.com/eoframework/public-assets/tree/main/solutions/ibm/cloud/openshift-container-platform

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
