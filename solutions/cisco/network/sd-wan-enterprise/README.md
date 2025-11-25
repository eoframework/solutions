# SD-WAN Enterprise

**Provider:** CISCO | **Category:** Network | **Version:** 1.0.0 | **Status:** Production Ready

## Solution Overview

Branch offices traditionally require expensive MPLS circuits for connectivity to headquarters and cloud services. Managing individual configurations for each branch is time-consuming, and changes require site visits or complex remote procedures. Users experience poor performance when accessing cloud applications over backhauled connections through the data center.

This solution deploys Cisco SD-WAN to connect branch offices using multiple internet connections instead of costly MPLS. It automatically routes traffic based on application requirements and network conditions, providing better performance and reliability. The solution centralizes management, allows policy changes across all branches simultaneously, and improves cloud application access with direct internet breakout.

### Key Benefits

| Benefit | Impact |
|---------|--------|
| Network Performance | Improved throughput |
| Management | Centralized control |
| Reliability | 99.99% availability |

### Core Technologies

- **Cisco SD-WAN**
- **Cisco Meraki**
- **Cisco DNA Center**
- **Cisco Catalyst**

## Solution Structure

```
sd-wan-enterprise/
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
git sparse-checkout set solutions/cisco/network/sd-wan-enterprise
cd solutions/cisco/network/sd-wan-enterprise
```

**Option 2: Download Script**
```bash
curl -O https://raw.githubusercontent.com/eoframework/solutions/main/support/tools/download-solution.sh
chmod +x download-solution.sh
./download-solution.sh cisco/network/sd-wan-enterprise
```

**Option 3: Browse Online**
[View on GitHub](https://github.com/eoframework/solutions/tree/main/solutions/cisco/network/sd-wan-enterprise)

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

- CISCO Account
- Administrative Access
- Python 3.8+
- Ansible

## Use Cases

- **Network Modernization** - Legacy infrastructure upgrade
- **SD-WAN Deployment** - Software-defined networking
- **Network Security** - Segmentation and access control
- **Performance Optimization** - Bandwidth and latency improvement

---

**[EO Framework](https://eoframework.org)** - Exceptional Outcome Framework
