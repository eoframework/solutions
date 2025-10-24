# Zero Trust Network Gateway

**Provider:** Cisco
**Category:** Cyber Security
**Version:** 1.0.0
**Status:** In Review

## Solution Description

Traditional network security assumes users inside the network perimeter are trusted, but remote work and cloud applications have eliminated clear perimeters. Users access applications from various devices and locations, making it difficult to verify identity and enforce security policies. Breaches often occur when attackers gain initial access and move laterally through the network.

This solution implements zero-trust network access using Cisco security technologies. It verifies every access request regardless of location, enforces least-privilege access, and continuously validates user and device trust. The solution provides secure access to applications without exposing the entire network and logs all access for compliance and investigation.


## 📥 Access This Solution

### Quick Download

**Option 1: Using Helper Script**
```bash
curl -O https://raw.githubusercontent.com/eoframework/public-assets/main/download-solution.sh
chmod +x download-solution.sh
./download-solution.sh cisco/cyber-security/secure-access
```

**Option 2: Git Sparse Checkout (Recommended)**
```bash
# Clone with sparse checkout
git clone --filter=blob:none --sparse https://github.com/eoframework/public-assets.git
cd public-assets

# Checkout this specific solution
git sparse-checkout set solutions/cisco/cyber-security/secure-access

# View the solution
cd solutions/cisco/cyber-security/secure-access
ls -la
```

**Option 3: Browse on GitHub**
- View online: https://github.com/eoframework/public-assets/tree/main/solutions/cisco/cyber-security/secure-access

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
