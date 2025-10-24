# VxRail HCI

**Provider:** Dell
**Category:** Cloud
**Version:** 1.0.0
**Status:** In Review

## Solution Description

Traditional data center infrastructure requires separate servers, storage, and networking components that are complex to integrate, scale, and manage. Capacity planning is difficult—organizations often overprovision to avoid outages or underprovision and face performance issues. Managing these separate systems requires specialized expertise and significant time.

This solution implements Dell VxRail hyperconverged infrastructure that combines compute, storage, and networking into a single system. It simplifies deployment with pre-configured nodes that can be added incrementally as needs grow. The solution provides integrated management, automated operations, and seamless integration with VMware for running virtualized workloads.


## 📥 Access This Solution

### Quick Download

**Option 1: Using Helper Script**
```bash
curl -O https://raw.githubusercontent.com/eoframework/public-assets/main/download-solution.sh
chmod +x download-solution.sh
./download-solution.sh dell/cloud/vxrail-hci
```

**Option 2: Git Sparse Checkout (Recommended)**
```bash
# Clone with sparse checkout
git clone --filter=blob:none --sparse https://github.com/eoframework/public-assets.git
cd public-assets

# Checkout this specific solution
git sparse-checkout set solutions/dell/cloud/vxrail-hci

# View the solution
cd solutions/dell/cloud/vxrail-hci
ls -la
```

**Option 3: Browse on GitHub**
- View online: https://github.com/eoframework/public-assets/tree/main/solutions/dell/cloud/vxrail-hci

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
