#!/usr/bin/env python3
"""
Update solution README files to the new standardized format.

Updates:
- Solution root README.md
- presales/README.md
- delivery/README.md
"""

import yaml
from pathlib import Path

SOLUTIONS_ROOT = Path(__file__).parent.parent.parent / "solutions"


# Standard presales README content (same for all solutions)
PRESALES_README = """# Presales Resources

This folder contains all presales materials for customer engagement and business case development.

## Documents

### Source Files (`raw/`)

| File | Purpose | Output |
|------|---------|--------|
| `solution-briefing.md` | Executive presentation content | `solution-briefing.pptx` |
| `statement-of-work.md` | Project scope and terms | `statement-of-work.docx` |
| `discovery-questionnaire.csv` | Requirements gathering | `discovery-questionnaire.xlsx` |
| `level-of-effort-estimate.csv` | Resource and cost estimation | `level-of-effort-estimate.xlsx` |
| `infrastructure-costs.csv` | 3-year infrastructure costs | `infrastructure-costs.xlsx` |

### Generated Files

The `.pptx`, `.docx`, and `.xlsx` files are generated from source files using [eof-tools](https://github.com/eoframework/eof-tools). To regenerate:

```bash
cd /path/to/eof-tools
python3 converters/presales/solution-presales-converter.py \\
  --solution-path /path/to/this/solution
```

## How to Use

### For Discovery

1. Start with `discovery-questionnaire.xlsx` to gather customer requirements
2. Review responses to understand scope and constraints
3. Use findings to customize other documents

### For Business Case

1. Review `solution-briefing.pptx` for executive presentation
2. Customize slides with customer-specific information
3. Use `infrastructure-costs.xlsx` for financial discussions

### For Proposal

1. Customize `statement-of-work.docx` with customer details
2. Update pricing in `level-of-effort-estimate.xlsx`
3. Include `infrastructure-costs.xlsx` for total cost of ownership

## Customization

All source files in `raw/` can be edited:
- **Markdown files** - Edit in any text editor
- **CSV files** - Edit in Excel or text editor
- Regenerate outputs after making changes

---

**[EO Framework](https://eoframework.org)** - Exceptional Outcome Framework
"""

# Standard delivery README content (same for all solutions)
DELIVERY_README = """# Delivery Resources

This folder contains all implementation and operational materials for project delivery.

## Documents

| File | Purpose |
|------|---------|
| `implementation-guide.md` | Step-by-step deployment procedures |
| `configuration-templates.md` | Configuration examples and templates |
| `testing-procedures.md` | Testing framework and validation steps |
| `operations-runbook.md` | Day-to-day operations and maintenance |
| `training-materials.md` | User and administrator training content |

## Scripts

The `scripts/` directory contains deployment automation:

```
scripts/
├── bash/           # Shell scripts for setup and configuration
├── python/         # Python automation scripts
├── terraform/      # Infrastructure as Code (if applicable)
└── README.md       # Script execution instructions
```

See [`scripts/README.md`](scripts/README.md) for detailed usage instructions.

## Implementation Workflow

### 1. Planning

- Review `implementation-guide.md` for prerequisites
- Verify access and permissions
- Prepare environment variables

### 2. Deployment

```bash
cd scripts/
# Follow instructions in scripts/README.md
```

### 3. Validation

- Execute tests from `testing-procedures.md`
- Verify all components are operational
- Document any issues

### 4. Handover

- Complete training using `training-materials.md`
- Review `operations-runbook.md` with operations team
- Establish support procedures

## Quick Links

- [Implementation Guide](implementation-guide.md) - Start here
- [Scripts README](scripts/README.md) - Deployment automation
- [Operations Runbook](operations-runbook.md) - Ongoing operations

---

**[EO Framework](https://eoframework.org)** - Exceptional Outcome Framework
"""

# Provider-specific technology mappings
PROVIDER_TECHNOLOGIES = {
    "aws": {
        "ai": ["Amazon SageMaker", "Amazon Bedrock", "AWS Lambda", "Amazon S3"],
        "cloud": ["Amazon EC2", "Amazon VPC", "AWS CloudFormation", "Amazon S3"],
        "cyber-security": ["AWS IAM", "AWS KMS", "Amazon GuardDuty", "AWS Security Hub"],
        "devops": ["AWS CodePipeline", "AWS CodeBuild", "Amazon ECR", "AWS CloudFormation"],
        "network": ["Amazon VPC", "AWS Transit Gateway", "Amazon Route 53", "AWS Direct Connect"],
    },
    "azure": {
        "ai": ["Azure AI Document Intelligence", "Azure Cognitive Services", "Azure Functions", "Azure Blob Storage"],
        "cloud": ["Azure Virtual Machines", "Azure Virtual Network", "Azure Resource Manager", "Azure Storage"],
        "cyber-security": ["Microsoft Sentinel", "Azure Active Directory", "Azure Key Vault", "Microsoft Defender"],
        "devops": ["Azure DevOps", "Azure Pipelines", "Azure Container Registry", "Azure Resource Manager"],
        "network": ["Azure Virtual WAN", "Azure ExpressRoute", "Azure DNS", "Azure Firewall"],
        "modern-workspace": ["Azure Virtual Desktop", "Microsoft Intune", "Azure Active Directory", "Microsoft 365"],
    },
    "dell": {
        "ai": ["Dell Precision Workstations", "NVIDIA GPUs", "Dell PowerEdge", "Dell Storage"],
        "cloud": ["Dell VxRail", "VMware vSphere", "Dell PowerEdge", "Dell PowerStore"],
        "cyber-security": ["Dell SafeID", "Dell Data Protection", "RSA SecurID", "Dell PowerProtect"],
        "devops": ["Dell PowerEdge", "VMware vSphere", "Ansible", "Dell OpenManage"],
        "network": ["Dell PowerSwitch", "Dell SmartFabric", "Dell OS10", "Dell Networking"],
    },
    "cisco": {
        "ai": ["Cisco AI Analytics", "Cisco DNA Center", "Cisco ThousandEyes", "Splunk"],
        "cloud": ["Cisco HyperFlex", "Cisco UCS", "Cisco Intersight", "Cisco ACI"],
        "cyber-security": ["Cisco Secure Access", "Cisco Duo", "Cisco Umbrella", "Cisco ISE"],
        "devops": ["Cisco Intersight", "Ansible", "Terraform", "Cisco ACI"],
        "network": ["Cisco SD-WAN", "Cisco Meraki", "Cisco DNA Center", "Cisco Catalyst"],
    },
    "microsoft": {
        "cyber-security": ["Microsoft Defender", "Microsoft Sentinel", "Azure AD", "Microsoft Purview"],
        "modern-workspace": ["Microsoft 365", "Microsoft Intune", "Azure AD", "Microsoft Teams"],
    },
    "google": {
        "cloud": ["Google Cloud Platform", "Google Kubernetes Engine", "Cloud Storage", "Cloud IAM"],
        "modern-workspace": ["Google Workspace", "Google Drive", "Google Meet", "Google Admin"],
    },
    "github": {
        "cyber-security": ["GitHub Advanced Security", "Dependabot", "Code Scanning", "Secret Scanning"],
        "devops": ["GitHub Actions", "GitHub Packages", "GitHub Codespaces", "GitHub Enterprise"],
    },
    "hashicorp": {
        "cloud": ["Terraform", "Vault", "Consul", "Nomad"],
        "devops": ["Terraform Enterprise", "Vault", "Packer", "Waypoint"],
    },
    "ibm": {
        "cloud": ["Red Hat OpenShift", "IBM Cloud", "IBM Storage", "IBM Power"],
        "devops": ["Ansible Automation Platform", "Red Hat OpenShift", "IBM Cloud Pak", "Ansible Tower"],
    },
    "nvidia": {
        "ai": ["NVIDIA DGX", "NVIDIA A100", "NVIDIA CUDA", "NVIDIA AI Enterprise"],
        "modern-workspace": ["NVIDIA Omniverse", "NVIDIA RTX", "NVIDIA CloudXR", "NVIDIA Virtual GPU"],
    },
    "juniper": {
        "cyber-security": ["Juniper SRX", "Juniper ATP", "Juniper Security Director", "Juniper Policy Enforcer"],
        "network": ["Juniper Mist AI", "Juniper EX Series", "Juniper Apstra", "Juniper Marvis"],
    },
}

# Category-specific use cases
CATEGORY_USE_CASES = {
    "ai": [
        "Document Processing - Automated data extraction and classification",
        "Predictive Analytics - ML-driven business insights",
        "Process Automation - Intelligent workflow automation",
        "Data Analysis - Pattern recognition and anomaly detection",
    ],
    "cloud": [
        "Infrastructure Modernization - Legacy system migration",
        "Disaster Recovery - Business continuity and failover",
        "Hybrid Cloud - On-premises and cloud integration",
        "Scalable Computing - Elastic resource provisioning",
    ],
    "cyber-security": [
        "Threat Detection - Real-time security monitoring",
        "Access Control - Identity and access management",
        "Compliance - Regulatory compliance automation",
        "Incident Response - Security event management",
    ],
    "devops": [
        "CI/CD Pipelines - Automated build and deployment",
        "Infrastructure as Code - Automated provisioning",
        "Container Management - Orchestration and scaling",
        "Configuration Management - Consistent environments",
    ],
    "network": [
        "Network Modernization - Legacy infrastructure upgrade",
        "SD-WAN Deployment - Software-defined networking",
        "Network Security - Segmentation and access control",
        "Performance Optimization - Bandwidth and latency improvement",
    ],
    "modern-workspace": [
        "Remote Work Enablement - Secure remote access",
        "Collaboration - Team productivity tools",
        "Device Management - Endpoint management and security",
        "Identity Management - Single sign-on and MFA",
    ],
}

# Key benefits by category
CATEGORY_BENEFITS = {
    "ai": [
        ("Processing Time", "Up to 90% reduction"),
        ("Accuracy", "99%+ automated processing"),
        ("Cost Savings", "Significant operational reduction"),
    ],
    "cloud": [
        ("Deployment Time", "Up to 70% faster"),
        ("Availability", "99.9%+ uptime SLA"),
        ("Cost Optimization", "Right-sized infrastructure"),
    ],
    "cyber-security": [
        ("Threat Detection", "Real-time monitoring"),
        ("Compliance", "Automated policy enforcement"),
        ("Incident Response", "Reduced MTTR"),
    ],
    "devops": [
        ("Deployment Frequency", "Multiple deploys per day"),
        ("Lead Time", "Hours instead of weeks"),
        ("Recovery Time", "Minutes instead of hours"),
    ],
    "network": [
        ("Network Performance", "Improved throughput"),
        ("Management", "Centralized control"),
        ("Reliability", "99.99% availability"),
    ],
    "modern-workspace": [
        ("User Productivity", "Enhanced collaboration"),
        ("Security", "Zero-trust architecture"),
        ("Management", "Unified endpoint control"),
    ],
}


def get_technologies(provider: str, category: str) -> list:
    """Get technologies for a provider/category combination."""
    provider_techs = PROVIDER_TECHNOLOGIES.get(provider, {})
    return provider_techs.get(category, [f"{provider.upper()} Services", "Infrastructure as Code", "Automation Tools", "Monitoring Stack"])


def get_use_cases(category: str) -> list:
    """Get use cases for a category."""
    return CATEGORY_USE_CASES.get(category, [
        "Business Process Automation",
        "Infrastructure Management",
        "Security and Compliance",
        "Operational Excellence",
    ])


def get_benefits(category: str) -> list:
    """Get benefits for a category."""
    return CATEGORY_BENEFITS.get(category, [
        ("Efficiency", "Improved operations"),
        ("Cost", "Optimized spending"),
        ("Quality", "Enhanced outcomes"),
    ])


def generate_readme(solution_path: Path) -> str:
    """Generate README content for a solution."""
    metadata_path = solution_path / "metadata.yml"
    if not metadata_path.exists():
        return None

    with open(metadata_path) as f:
        metadata = yaml.safe_load(f)

    provider = metadata.get("provider", "unknown")
    category = metadata.get("category", "unknown")
    solution_name = metadata.get("solution_name", "unknown")
    display_name = metadata.get("solution_display_name", solution_name)
    version = metadata.get("version", "1.0.0")
    status = metadata.get("status", "In Review")
    long_desc = metadata.get("long_description", metadata.get("description", ""))

    # Clean up long description
    long_desc = long_desc.strip()

    # Get prerequisites from metadata
    requirements = metadata.get("requirements", {})
    prereqs = requirements.get("prerequisites", [])
    tools = requirements.get("tools", [])

    # Get technologies, use cases, and benefits
    technologies = get_technologies(provider, category)
    use_cases = get_use_cases(category)
    benefits = get_benefits(category)

    # Build solution path for URLs
    solution_url_path = f"{provider}/{category}/{solution_name}"

    # Generate README
    readme = f"""# {display_name}

**Provider:** {provider.upper()} | **Category:** {category.replace('-', ' ').title()} | **Version:** {version} | **Status:** Production Ready

## Solution Overview

{long_desc}

### Key Benefits

| Benefit | Impact |
|---------|--------|
"""

    for benefit, impact in benefits:
        readme += f"| {benefit} | {impact} |\n"

    readme += f"""
### Core Technologies

"""
    for tech in technologies:
        readme += f"- **{tech}**\n"

    readme += f"""
## Solution Structure

```
{solution_name}/
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
git sparse-checkout set solutions/{solution_url_path}
cd solutions/{solution_url_path}
```

**Option 2: Download Script**
```bash
curl -O https://raw.githubusercontent.com/eoframework/solutions/main/support/tools/download-solution.sh
chmod +x download-solution.sh
./download-solution.sh {solution_url_path}
```

**Option 3: Browse Online**
[View on GitHub](https://github.com/eoframework/solutions/tree/main/solutions/{solution_url_path})

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

"""

    for prereq in prereqs:
        readme += f"- {prereq}\n"
    for tool in tools:
        readme += f"- {tool}\n"

    if not prereqs and not tools:
        readme += f"- {provider.upper()} account with appropriate permissions\n"
        readme += "- Administrative access to target environment\n"
        readme += "- Required CLI tools installed\n"

    readme += f"""
## Use Cases

"""
    for use_case in use_cases[:4]:
        readme += f"- **{use_case.split(' - ')[0]}** - {use_case.split(' - ')[1] if ' - ' in use_case else use_case}\n"

    readme += """
---

**[EO Framework](https://eoframework.org)** - Exceptional Outcome Framework
"""

    return readme


def update_presales_readme(solution_path: Path) -> bool:
    """Update presales/README.md with standard content."""
    presales_path = solution_path / "presales"
    if not presales_path.exists():
        return False

    readme_path = presales_path / "README.md"
    with open(readme_path, 'w') as f:
        f.write(PRESALES_README)
    return True


def update_delivery_readme(solution_path: Path) -> bool:
    """Update delivery/README.md with standard content."""
    delivery_path = solution_path / "delivery"
    if not delivery_path.exists():
        return False

    readme_path = delivery_path / "README.md"
    with open(readme_path, 'w') as f:
        f.write(DELIVERY_README)
    return True


def main():
    """Update all solution READMEs."""
    import argparse

    parser = argparse.ArgumentParser(description="Update solution README files")
    parser.add_argument("--root-only", action="store_true", help="Only update root READMEs")
    parser.add_argument("--presales-only", action="store_true", help="Only update presales READMEs")
    parser.add_argument("--delivery-only", action="store_true", help="Only update delivery READMEs")
    parser.add_argument("--all", action="store_true", help="Update all READMEs (default)")
    args = parser.parse_args()

    # Default to all if no specific flag
    update_root = args.root_only or args.all or not (args.presales_only or args.delivery_only)
    update_presales = args.presales_only or args.all or not (args.root_only or args.delivery_only)
    update_delivery = args.delivery_only or args.all or not (args.root_only or args.presales_only)

    solutions = list(SOLUTIONS_ROOT.glob("*/*/*"))
    solutions = [s for s in solutions if s.is_dir() and (s / "metadata.yml").exists()]

    root_updated = 0
    presales_updated = 0
    delivery_updated = 0

    for solution_path in sorted(solutions):
        solution_name = solution_path.name

        # Update root README
        if update_root:
            # Skip AWS IDP root as it's the manually crafted reference
            if "intelligent-document-processing" not in str(solution_path):
                readme_content = generate_readme(solution_path)
                if readme_content:
                    readme_path = solution_path / "README.md"
                    with open(readme_path, 'w') as f:
                        f.write(readme_content)
                    root_updated += 1

        # Update presales README
        if update_presales:
            if update_presales_readme(solution_path):
                presales_updated += 1

        # Update delivery README
        if update_delivery:
            if update_delivery_readme(solution_path):
                delivery_updated += 1

        print(f"Updated {solution_name}")

    print(f"\nDone!")
    if update_root:
        print(f"  Root READMEs: {root_updated}")
    if update_presales:
        print(f"  Presales READMEs: {presales_updated}")
    if update_delivery:
        print(f"  Delivery READMEs: {delivery_updated}")


if __name__ == "__main__":
    main()
