# Virtual Wan Global

**Provider:** AZURE | **Category:** Network | **Version:** 1.0.0 | **Status:** Production Ready

## Solution Overview

Organizations with multiple offices, data centers, and cloud resources need reliable connectivity between all locations. Managing separate connections, routing, and security policies for each site is complex and expensive. Network performance issues impact user experience and application availability across distributed operations.

This solution implements Azure Virtual WAN to create a unified global network connecting branches, data centers, and Azure regions. It provides optimized routing through Microsoft's global network, centralized security policies, and simplified management of all connections. The solution reduces network latency and makes it easier to add new locations.

### Key Benefits

| Benefit | Impact |
|---------|--------|
| Network Performance | Improved throughput |
| Management | Centralized control |
| Reliability | 99.99% availability |

### Core Technologies

- **Azure Virtual WAN**
- **Azure ExpressRoute**
- **Azure DNS**
- **Azure Firewall**

## Solution Structure

```
virtual-wan-global/
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
git sparse-checkout set solutions/azure/network/virtual-wan-global
cd solutions/azure/network/virtual-wan-global
```

**Option 2: Download Script**
```bash
curl -O https://raw.githubusercontent.com/eoframework/solutions/main/support/tools/download-solution.sh
chmod +x download-solution.sh
./download-solution.sh azure/network/virtual-wan-global
```

**Option 3: Browse Online**
[View on GitHub](https://github.com/eoframework/solutions/tree/main/solutions/azure/network/virtual-wan-global)

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

- AZURE Account
- Administrative Access
- Python 3.8+
- Azure CLI
- PowerShell

## Use Cases

- **Network Modernization** - Legacy infrastructure upgrade
- **SD-WAN Deployment** - Software-defined networking
- **Network Security** - Segmentation and access control
- **Performance Optimization** - Bandwidth and latency improvement

---

**[EO Framework](https://eoframework.org)** - Exceptional Outcome Framework
