# Cognitive Document Processor

**Provider:** Azure
**Category:** AI
**Version:** 1.0.0
**Status:** In Review

## Solution Description

Businesses handle large volumes of forms and documents that require manual review and data entry. Processing insurance claims, loan applications, or customer onboarding forms ties up staff in repetitive tasks. Errors in manual processing lead to delays, rework, and compliance issues.

This solution uses Azure AI Document Intelligence (Form Recognizer) to automatically extract data from structured and semi-structured documents. It processes forms, receipts, invoices, and identity documents, extracting key fields and validating data. The solution integrates with existing business processes and can handle high document volumes with consistent accuracy.


## 📥 Access This Solution

### Quick Download

**Option 1: Using Helper Script**
```bash
curl -O https://raw.githubusercontent.com/eoframework/public-assets/main/download-solution.sh
chmod +x download-solution.sh
./download-solution.sh azure/ai/document-intelligence
```

**Option 2: Git Sparse Checkout (Recommended)**
```bash
# Clone with sparse checkout
git clone --filter=blob:none --sparse https://github.com/eoframework/public-assets.git
cd public-assets

# Checkout this specific solution
git sparse-checkout set solutions/azure/ai/document-intelligence

# View the solution
cd solutions/azure/ai/document-intelligence
ls -la
```

**Option 3: Browse on GitHub**
- View online: https://github.com/eoframework/public-assets/tree/main/solutions/azure/ai/document-intelligence

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
