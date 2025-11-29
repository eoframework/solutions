# Deployment Automation

This folder contains deployment automation for the solution, organized into two approaches:

```
automation/
├── terraform/           # Option A: Standardized Terraform approach
└── platform-native/     # Option B: Best-fit tooling for the platform
```

## Choosing an Approach

Both approaches deploy the same solution. Choose based on your team's context:

### Option A: Terraform (`terraform/`)

**Best for:**
- Teams standardizing on Terraform across all solutions
- Multi-cloud environments requiring consistent tooling
- Organizations with established Terraform workflows and state management
- Scenarios where infrastructure drift detection is critical

**Characteristics:**
- Consistent patterns across AWS, Azure, GCP
- Built-in state management and locking
- Plan/apply workflow with change preview
- Large ecosystem of providers and modules

### Option B: Platform-Native (`platform-native/`)

**Best for:**
- Teams with deep expertise in vendor-specific tooling
- Solutions where first-party vendor support is essential
- Single-cloud/single-vendor deployments
- Scenarios where native tooling provides superior capabilities

**Characteristics:**
- Uses vendor-recommended tooling (Ansible, PowerShell, Bicep, etc.)
- First-party documentation and support
- Tighter integration with vendor ecosystems
- May be simpler for single-platform teams

## Quick Decision Guide

| If your situation is... | Use |
|------------------------|-----|
| Multi-cloud deployment | `terraform/` |
| Team knows Terraform well | `terraform/` |
| Need state management | `terraform/` |
| Cisco/Juniper network devices | `platform-native/ansible/` |
| Microsoft 365 / Azure AD | `platform-native/powershell/` |
| Azure with ARM/Bicep expertise | `platform-native/bicep/` |
| AWS serverless with CDK expertise | `platform-native/cdk/` |
| Physical hardware (Dell, NVIDIA) | `platform-native/ansible/` |
| Red Hat / OpenShift | `platform-native/ansible/` |

## Solution-Specific Recommendation

> **For this solution:** Review the presales Statement of Work and Detailed Design
> to understand the technology stack, then select the appropriate approach.

| Technology | Terraform Support | Native Alternative |
|------------|------------------|-------------------|
| AWS | Excellent | CDK, CloudFormation |
| Azure | Excellent | Bicep, ARM |
| GCP | Excellent | Deployment Manager |
| Cisco | Good (Intersight) | Ansible (cisco.*) |
| Microsoft 365 | Limited | PowerShell (Graph API) |
| Network devices | Varies | Ansible |
| Physical hardware | Limited | Ansible, vendor CLI |

## Folder Structure

### Terraform Approach
```
terraform/
├── environments/
│   ├── production/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── deploy.sh
│   │   └── config/
│   │       ├── project.tfvars
│   │       ├── networking.tfvars
│   │       ├── security.tfvars
│   │       └── compute.tfvars
│   ├── test/
│   └── disaster-recovery/
├── modules/
│   ├── aws/
│   ├── azure/
│   └── gcp/
├── scripts/
└── docs/
```

### Platform-Native Approach
```
platform-native/
├── README.md           # Tool selection guide
└── {tool}/             # Only the optimal tool(s) for this solution
    ├── ...
```

See `platform-native/README.md` for detailed guidance on tool selection and folder structures.

## Getting Started

### Terraform Approach
```bash
cd terraform/environments/production/

# 1. Configure your settings
cp config/project.tfvars.example config/project.tfvars
vim config/project.tfvars

# 2. Initialize and deploy
./deploy.sh init
./deploy.sh plan
./deploy.sh apply
```

### Platform-Native Approach
```bash
cd platform-native/{tool}/

# Follow the README.md in the specific tool folder
```

## Environment Parity

Both approaches support three environments:
- **production** - Live workloads, full redundancy
- **test** - Development and testing, reduced resources
- **disaster-recovery** - Business continuity, alternate region

Ensure configuration is consistent across approaches if both are maintained.
