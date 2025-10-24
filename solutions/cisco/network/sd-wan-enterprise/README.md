# SD-WAN Enterprise

**Provider:** Cisco
**Category:** Network
**Version:** 1.0.0
**Status:** In Review

## Solution Description

Branch offices traditionally require expensive MPLS circuits for connectivity to headquarters and cloud services. Managing individual configurations for each branch is time-consuming, and changes require site visits or complex remote procedures. Users experience poor performance when accessing cloud applications over backhauled connections through the data center.

This solution deploys Cisco SD-WAN to connect branch offices using multiple internet connections instead of costly MPLS. It automatically routes traffic based on application requirements and network conditions, providing better performance and reliability. The solution centralizes management, allows policy changes across all branches simultaneously, and improves cloud application access with direct internet breakout.


## 📥 Access This Solution

### Quick Download

**Option 1: Using Helper Script**
```bash
curl -O https://raw.githubusercontent.com/eoframework/public-assets/main/download-solution.sh
chmod +x download-solution.sh
./download-solution.sh cisco/network/sd-wan-enterprise
```

**Option 2: Git Sparse Checkout (Recommended)**
```bash
# Clone with sparse checkout
git clone --filter=blob:none --sparse https://github.com/eoframework/public-assets.git
cd public-assets

# Checkout this specific solution
git sparse-checkout set solutions/cisco/network/sd-wan-enterprise

# View the solution
cd solutions/cisco/network/sd-wan-enterprise
ls -la
```

**Option 3: Browse on GitHub**
- View online: https://github.com/eoframework/public-assets/tree/main/solutions/cisco/network/sd-wan-enterprise

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
