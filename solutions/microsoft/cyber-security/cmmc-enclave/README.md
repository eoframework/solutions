# CMMC Enclave

**Provider:** MICROSOFT | **Category:** Cyber Security | **Version:** 1.0.0 | **Status:** Production Ready

## Solution Overview

Defense contractors must comply with CMMC (Cybersecurity Maturity Model Certification) requirements to protect Controlled Unclassified Information (CUI). Meeting these requirements means implementing specific security controls, maintaining audit trails, and proving compliance. Building a compliant environment from scratch is complex and time-consuming without clear guidance on required configurations.

This solution creates a secure enclave within Microsoft 365 and Azure that meets CMMC Level 2 requirements. It implements required security controls, configures audit logging, restricts data access, and provides compliance reporting. The enclave isolates CUI data and ensures only authorized users can access it through compliant methods.

### Key Benefits

| Benefit | Impact |
|---------|--------|
| Threat Detection | Real-time monitoring |
| Compliance | Automated policy enforcement |
| Incident Response | Reduced MTTR |

### Core Technologies

- **Microsoft Defender**
- **Microsoft Sentinel**
- **Azure AD**
- **Microsoft Purview**

## Solution Structure

```
cmmc-enclave/
├── presales/                    # Business case & sales materials
│   ├── raw/                     # Source files (markdown, CSV)
│   ├── solution-briefing.pptx   # Executive presentation
│   ├── statement-of-work.docx   # Formal SOW document
│   ├── discovery-questionnaire.xlsx
│   ├── level-of-effort-estimate.xlsx
│   └── infrastructure-costs.xlsx
├── delivery/                    # Implementation resources
│   ├── implementation-guide.md  # Step-by-step deployment
│   ├── configuration-templates.md
│   ├── testing-procedures.md
│   ├── operations-runbook.md
│   └── scripts/                 # Deployment automation
├── assets/                      # Logos and images
│   └── logos/
└── metadata.yml                 # Solution metadata
```

## Getting Started

### Download This Solution

**Option 1: Git Sparse Checkout (Recommended)**
```bash
git clone --filter=blob:none --sparse https://github.com/eoframework/solutions.git
cd solutions
git sparse-checkout set solutions/microsoft/cyber-security/cmmc-enclave
cd solutions/microsoft/cyber-security/cmmc-enclave
```

**Option 2: Download Script**
```bash
curl -O https://raw.githubusercontent.com/eoframework/solutions/main/support/tools/download-solution.sh
chmod +x download-solution.sh
./download-solution.sh microsoft/cyber-security/cmmc-enclave
```

**Option 3: Browse Online**
[View on GitHub](https://github.com/eoframework/solutions/tree/main/solutions/microsoft/cyber-security/cmmc-enclave)

### For Presales Teams

Navigate to **`presales/`** for customer engagement materials:

| Document | Purpose |
|----------|---------|
| `solution-briefing.pptx` | Executive presentation with business case |
| `statement-of-work.docx` | Formal project scope and terms |
| `discovery-questionnaire.xlsx` | Customer requirements gathering |
| `level-of-effort-estimate.xlsx` | Resource and cost estimation |
| `infrastructure-costs.xlsx` | 3-year infrastructure cost breakdown |

### For Delivery Teams

Navigate to **`delivery/`** for implementation:

1. Review `implementation-guide.md` for prerequisites and steps
2. Use `configuration-templates.md` for environment setup
3. Execute scripts in `scripts/` for automated deployment
4. Follow `testing-procedures.md` for validation
5. Reference `operations-runbook.md` for ongoing operations

## Prerequisites

- MICROSOFT Account
- Administrative Access
- Python 3.8+
- PowerShell
- Microsoft Graph

## Use Cases

- **Threat Detection** - Real-time security monitoring
- **Access Control** - Identity and access management
- **Compliance** - Regulatory compliance automation
- **Incident Response** - Security event management

---

**[EO Framework](https://eoframework.org)** - Exceptional Outcome Framework
