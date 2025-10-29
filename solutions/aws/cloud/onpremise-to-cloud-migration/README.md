# Onpremise To Cloud Migration

**Provider:** AWS
**Category:** Cloud
**Version:** 1.0.0
**Status:** In Review

## Solution Description

Organizations running on-premise infrastructure face high maintenance costs, capacity constraints, and difficulty scaling to meet changing business needs. Migrating to the cloud is complex—it requires assessing current workloads, planning the migration sequence, converting servers, and validating that applications work correctly in the new environment.

This solution provides a structured approach to migrate on-premise workloads to AWS. It includes discovery tools to inventory current systems, migration planning templates, and automation scripts for common migration patterns. The solution handles server migrations, database conversions, and application modernization while maintaining business continuity throughout the transition.


## 📥 Access This Solution

### Quick Download

**Option 1: Using Helper Script**
```bash
curl -O https://raw.githubusercontent.com/eoframework/solutions/main/support/tools/download-solution.sh
chmod +x download-solution.sh
./download-solution.sh aws/cloud/onpremise-to-cloud-migration
```

**Option 2: Git Sparse Checkout (Recommended)**
```bash
# Clone with sparse checkout
git clone --filter=blob:none --sparse https://github.com/eoframework/solutions.git
cd solutions

# Checkout this specific solution
git sparse-checkout set solutions/aws/cloud/onpremise-to-cloud-migration

# View the solution
cd solutions/aws/cloud/onpremise-to-cloud-migration
ls -la
```

**Option 3: Browse on GitHub**
- View online: https://github.com/eoframework/solutions/tree/main/solutions/aws/cloud/onpremise-to-cloud-migration

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
