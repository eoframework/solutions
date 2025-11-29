# Platform-Native Automation

This folder contains the **platform-native** automation approach for this solution - using tooling that is optimal for the specific vendor/platform being deployed.

## When to Use Platform-Native

Choose this approach when:

- Your team has deep expertise in the vendor's native tooling
- First-party vendor support is important
- The solution is single-cloud/single-vendor
- The native tooling provides capabilities not available in Terraform

## Selecting the Right Tool

Based on the solution type, add the appropriate folder(s):

| Solution Type | Recommended Tool | Folder to Create |
|---------------|------------------|------------------|
| Cisco network devices | Ansible | `ansible/` |
| Juniper network devices | Ansible | `ansible/` |
| Dell hardware (iDRAC, PowerSwitch) | Ansible | `ansible/` |
| Microsoft 365 / Azure AD | PowerShell | `powershell/` |
| Azure infrastructure | Bicep | `bicep/` |
| Azure Sentinel / compliance | Bicep + PowerShell | `bicep/` + `powershell/` |
| AWS serverless applications | Python + AWS CDK | `cdk/` or `python/` |
| Red Hat / IBM solutions | Ansible | `ansible/` |
| NVIDIA hardware clusters | Ansible + Bash | `ansible/` |
| Google Workspace | Python + GAM | `python/` |
| GitHub configuration | Python + gh CLI | `python/` |

## Folder Structure Examples

### Network Device Solution (Cisco, Juniper, Dell)
```
platform-native/
└── ansible/
    ├── ansible.cfg
    ├── inventory/
    │   ├── production.yml
    │   ├── test.yml
    │   └── group_vars/
    ├── playbooks/
    │   ├── deploy.yml
    │   ├── configure.yml
    │   └── validate.yml
    ├── roles/
    └── requirements.yml
```

### Microsoft Solution (M365, Azure AD, Compliance)
```
platform-native/
└── powershell/
    ├── Deploy-Solution.ps1
    ├── Configure-Policies.ps1
    ├── modules/
    │   └── SolutionHelpers.psm1
    └── config/
        ├── production.json
        └── test.json
```

### Azure Solution (with Bicep)
```
platform-native/
├── bicep/
│   ├── main.bicep
│   ├── modules/
│   │   ├── networking.bicep
│   │   ├── compute.bicep
│   │   └── security.bicep
│   └── parameters/
│       ├── production.bicepparam
│       └── test.bicepparam
└── powershell/
    └── Configure-Sentinel.ps1    # For config not supported in Bicep
```

### AWS Serverless Solution
```
platform-native/
└── cdk/
    ├── app.py
    ├── cdk.json
    ├── requirements.txt
    └── stacks/
        ├── __init__.py
        ├── networking.py
        ├── lambda_stack.py
        └── api_stack.py
```

## Implementation Guidelines

1. **Create only the folders you need** - Don't add empty placeholder folders
2. **Include a README** in each tool folder explaining the deployment process
3. **Mirror the environment structure** - Support production, test, disaster-recovery
4. **Use consistent patterns** - Follow the vendor's best practices and conventions

## Comparison with Terraform Approach

| Aspect | Terraform (`../terraform/`) | Platform-Native |
|--------|----------------------------|-----------------|
| Multi-cloud | Excellent | Single platform |
| State management | Built-in | Manual or external |
| Vendor support | Community | First-party |
| Learning curve | One tool for all | Tool per platform |
| Provider maturity | Varies | Usually mature |
| Team expertise | Terraform skills | Platform-specific skills |

## Getting Started

1. Identify the optimal tooling for your solution (see table above)
2. Create the appropriate folder(s) in this directory
3. Add the deployment scripts/playbooks/templates
4. Document the deployment process in a README
5. Test in the test environment before production
