# Solutions Library

35 enterprise solutions from 11 technology providers, organized by category.

## Browse by Provider

| Provider | Solutions | Focus Areas |
|----------|-----------|-------------|
| AWS | 3 | AI document processing, cloud migration, disaster recovery |
| Azure | 6 | AI, cloud landing zones, security, DevOps, VDI, networking |
| Cisco | 5 | Network analytics, hybrid cloud, security, SD-WAN |
| Dell | 6 | AI workstations, HCI, authentication, CI infrastructure |
| GitHub | 2 | Code security, enterprise CI/CD |
| Google | 2 | Cloud landing zones, Workspace |
| HashiCorp | 2 | Multi-cloud automation, Terraform Enterprise |
| IBM | 2 | OpenShift, Ansible Automation Platform |
| Juniper | 2 | Firewalls, AI-driven networking |
| Microsoft | 2 | CMMC compliance, M365 deployment |
| NVIDIA | 3 | DGX SuperPOD, GPU clusters, Omniverse |

## Browse by Category

| Category | Count | Examples |
|----------|-------|----------|
| **AI** | 6 | Document processing, GPU computing, network analytics |
| **Cloud** | 9 | Landing zones, HCI, migration, disaster recovery |
| **Cyber Security** | 7 | SIEM, firewalls, zero trust, compliance |
| **DevOps** | 6 | CI/CD pipelines, infrastructure automation |
| **Modern Workspace** | 4 | Virtual desktops, collaboration platforms |
| **Network** | 3 | SD-WAN, datacenter switching, AI networking |

## Solution Structure

Each solution follows a standard structure:

```
solution-name/
├── README.md              # Solution overview
├── metadata.yml           # Solution metadata
├── presales/              # Business case & sales materials
│   ├── raw/               # Source files (markdown, CSV)
│   └── *.xlsx, *.pptx, *.docx  # Generated documents
├── delivery/              # Implementation resources
│   ├── implementation-guide.md
│   ├── scripts/           # Deployment automation
│   └── ...
└── assets/                # Logos and diagrams
```

## Download a Solution

**Option 1: Git Sparse Checkout**
```bash
git clone --filter=blob:none --sparse https://github.com/eoframework/solutions.git
cd solutions
git sparse-checkout set solutions/aws/ai/intelligent-document-processing
```

**Option 2: Download Script**
```bash
curl -O https://raw.githubusercontent.com/eoframework/solutions/main/support/tools/download-solution.sh
chmod +x download-solution.sh
./download-solution.sh aws/ai/intelligent-document-processing
```

## Creating New Solutions

Use the [solution-template](../solution-template/) as a starting point:

```bash
cp -r solution-template/sample-provider/sample-category/sample-solution \
  solutions/your-provider/your-category/your-solution
```

See [Contributing Guidelines](../CONTRIBUTING.md) for details.

---

**[EO Framework](https://eoframework.org)** - Exceptional Outcome Framework
