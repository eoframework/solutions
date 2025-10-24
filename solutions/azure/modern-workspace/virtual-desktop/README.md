# Virtual Desktop

**Provider:** Azure
**Category:** Modern Workspace
**Version:** 1.0.0
**Status:** In Review

## Solution Description

Remote and hybrid work requires secure access to corporate applications and desktops from any location. Traditional VPN solutions struggle with performance and user experience. Managing physical desktops or individual virtual machines for remote workers is expensive and difficult to scale during rapid workforce changes.

This solution deploys Azure Virtual Desktop to provide managed Windows desktops and applications through the cloud. Users access their work environment from any device with a consistent experience. The solution handles session management, scaling based on demand, and integrates with existing identity systems. IT teams can quickly provision new users and update applications centrally.


## 📥 Access This Solution

### Quick Download

**Option 1: Using Helper Script**
```bash
curl -O https://raw.githubusercontent.com/eoframework/public-assets/main/download-solution.sh
chmod +x download-solution.sh
./download-solution.sh azure/modern-workspace/virtual-desktop
```

**Option 2: Git Sparse Checkout (Recommended)**
```bash
# Clone with sparse checkout
git clone --filter=blob:none --sparse https://github.com/eoframework/public-assets.git
cd public-assets

# Checkout this specific solution
git sparse-checkout set solutions/azure/modern-workspace/virtual-desktop

# View the solution
cd solutions/azure/modern-workspace/virtual-desktop
ls -la
```

**Option 3: Browse on GitHub**
- View online: https://github.com/eoframework/public-assets/tree/main/solutions/azure/modern-workspace/virtual-desktop

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
