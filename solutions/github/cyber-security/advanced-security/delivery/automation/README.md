# GitHub Advanced Security - Automation

Infrastructure as Code and automation for GitHub Advanced Security implementation.

## Overview

This automation framework implements comprehensive security controls for GitHub organizations using:

- **Terraform** - Organization, repository, and security configuration
- **GitHub Actions** - Reusable security scanning workflows
- **Configuration Management** - Centralized security policies and settings

## Architecture

```
automation/
├── terraform/
│   ├── modules/
│   │   ├── organization/       # Org-level settings, teams, webhooks
│   │   ├── repository/         # Repo security, branch protection
│   │   ├── actions/            # GitHub Actions configuration
│   │   └── security/           # Security policies, IP allowlist
│   └── environments/
│       ├── prod/               # Production environment
│       └── test/               # Test environment
├── github-actions/
│   ├── workflows/              # Reusable workflow templates
│   │   ├── codeql-analysis.yml
│   │   ├── secret-scanning.yml
│   │   └── dependency-review.yml
│   └── actions/                # Custom actions
└── config/
    ├── codeql-config.yml.tpl   # CodeQL configuration template
    ├── dependabot.yml.tpl      # Dependabot configuration template
    └── SECURITY.md             # Security policy template
```

## Features

### Security Controls

- **CodeQL Analysis**: Static application security testing (SAST)
  - 300+ built-in vulnerability patterns
  - Custom query support
  - Multi-language support (JavaScript, Python, Java, C#, Go, C++)

- **Secret Scanning**: Credential detection and prevention
  - GitHub partner patterns (200+ secret types)
  - Custom pattern support
  - Push protection to block secrets

- **Dependabot**: Software composition analysis (SCA)
  - Automated vulnerability detection
  - Security update automation
  - Multi-ecosystem support (npm, pip, Maven, NuGet, Go)

- **Branch Protection**: Code review enforcement
  - Required approvals (configurable)
  - Status check requirements
  - Signed commits
  - Linear history enforcement

### Integration

- **SIEM Integration**: Forward security events to Splunk, Azure Sentinel
- **Issue Tracking**: Automated ticket creation in JIRA, ServiceNow
- **Notifications**: Slack, Teams, Email, PagerDuty alerts

## Quick Start

### Prerequisites

- GitHub Enterprise Cloud with Advanced Security license
- Terraform >= 1.6.0
- GitHub personal access token with admin:org scope
- Access to target GitHub organization

### 1. Configure Variables

Copy the example configuration:

```bash
cd terraform/environments/prod
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your values:

```hcl
github_org_name = "your-organization"
owner_email     = "security-team@company.com"

# Security features
advanced_security_enabled = true
secret_scanning_enabled   = true
push_protection_enabled   = true

# CodeQL configuration
codeql_languages    = "javascript,python,java,csharp,go"
codeql_query_suites = "security-extended"
```

### 2. Set Sensitive Variables

Set sensitive values via environment variables:

```bash
export TF_VAR_github_token="ghp_your_token_here"
export TF_VAR_siem_webhook_url="https://your-siem.com/webhook"
export TF_VAR_siem_webhook_secret="your_secret_here"
```

### 3. Initialize and Deploy

```bash
cd terraform/environments/prod

# Initialize Terraform
terraform init

# Review planned changes
terraform plan

# Apply configuration
terraform apply
```

### 4. Deploy GitHub Actions Workflows

Copy workflow templates to your repositories:

```bash
# Copy workflows to target repository
cp ../../github-actions/workflows/*.yml /path/to/your/repo/.github/workflows/

# Commit and push
cd /path/to/your/repo
git add .github/workflows/
git commit -m "Add security scanning workflows"
git push
```

## Configuration Reference

### Organization Module

Configures organization-level settings:

```hcl
module "organization" {
  source = "../../modules/organization"

  organization_name    = "your-org"
  billing_email        = "billing@company.com"

  # Security settings
  advanced_security_enabled       = true
  secret_scanning_enabled         = true
  push_protection_enabled         = true
  dependabot_alerts_enabled       = true

  # Webhooks for SIEM integration
  webhooks = {
    siem = {
      url    = var.siem_webhook_url
      secret = var.siem_webhook_secret
      events = ["code_scanning_alert", "secret_scanning_alert"]
    }
  }
}
```

### Repository Module

Enables security features per repository:

```hcl
module "repository_security" {
  source = "../../modules/repository"

  repositories = {
    "my-app" = {
      advanced_security_enabled       = true
      secret_scanning_enabled         = true
      push_protection_enabled         = true
      dependabot_security_updates     = true
      branch_protection_enabled       = true
      protected_branch                = "main"
      required_approving_review_count = 2
      require_codeql_pass             = true
    }
  }
}
```

### Actions Module

Configures GitHub Actions permissions and secrets:

```hcl
module "actions" {
  source = "../../modules/actions"

  allowed_actions      = "selected"
  github_owned_allowed = true
  verified_allowed     = true
  patterns_allowed     = ["github/*", "actions/*"]

  organization_secrets = {
    SIEM_WEBHOOK_URL = {
      visibility      = "all"
      plaintext_value = var.siem_webhook_url
    }
  }
}
```

## GitHub Actions Workflows

### CodeQL Analysis

Scans code for security vulnerabilities on every PR and daily:

```yaml
# .github/workflows/codeql-analysis.yml
name: "CodeQL Security Analysis"
on:
  push:
    branches: [main]
  pull_request:
  schedule:
    - cron: '0 2 * * *'
```

**Languages Supported**: JavaScript, Python, Java, C#, Go, C++

### Secret Scanning

Validates commits don't contain secrets:

```yaml
# .github/workflows/secret-scanning.yml
name: "Secret Scanning Validation"
on:
  push:
  pull_request:
```

**Scanners**: TruffleHog, Gitleaks

### Dependency Review

Reviews dependency changes in pull requests:

```yaml
# .github/workflows/dependency-review.yml
name: "Dependency Review"
on:
  pull_request:
```

**Features**: License checking, vulnerability detection, auto-merge for patches

## Environment Strategy

### Production Environment

- **Full security enforcement**
- 2+ required approvals
- CodeQL check required
- Push protection enabled
- Strict branch protection
- SIEM integration active

### Test Environment

- **Relaxed policies for development**
- 1 required approval
- CodeQL warnings only
- Push protection disabled
- Flexible branch rules
- No SIEM integration

## Security Best Practices

### CodeQL Configuration

1. **Use security-extended query suite** for comprehensive coverage
2. **Add custom queries** for organization-specific patterns
3. **Exclude test directories** from analysis
4. **Set appropriate timeouts** for large repositories

### Secret Scanning

1. **Enable push protection** in production
2. **Add custom patterns** for proprietary secrets
3. **Configure bypass workflow** with approval process
4. **Monitor secret validity** via partner integrations

### Branch Protection

1. **Require 2+ approvals** for production code
2. **Dismiss stale reviews** on new commits
3. **Require code owner review** for sensitive paths
4. **Block force pushes** and deletions
5. **Require status checks** to pass

## Troubleshooting

### Common Issues

#### Terraform Provider Authentication

```bash
# Verify token has required scopes
gh auth status

# Required scopes:
# - admin:org (organization configuration)
# - repo (repository settings)
# - workflow (GitHub Actions)
```

#### CodeQL Analysis Timeout

```hcl
# Increase timeout for large repositories
codeql_timeout_minutes = 90
codeql_ram_mb          = 8192
```

#### Branch Protection Conflicts

```bash
# Check existing protection rules
gh api /repos/OWNER/REPO/branches/main/protection

# Remove conflicting rules before applying
terraform state rm module.repository_security.github_branch_protection_v3.protection[\"repo-name\"]
```

### Validation Commands

```bash
# Verify organization settings
gh api /orgs/YOUR_ORG | jq '.security_settings'

# List repositories with Advanced Security
gh api /orgs/YOUR_ORG/repos | jq '.[] | select(.security_and_analysis.advanced_security.status == "enabled") | .name'

# Check webhook deliveries
gh api /orgs/YOUR_ORG/hooks/HOOK_ID/deliveries
```

## Maintenance

### Regular Tasks

**Weekly**:
- Review security alert trends
- Validate webhook delivery success rates
- Check CodeQL query performance

**Monthly**:
- Update custom CodeQL queries
- Review branch protection rule effectiveness
- Audit organization access and permissions

**Quarterly**:
- Review and update security policies
- Validate compliance framework alignment
- Update Terraform module versions

### Updating Configuration

```bash
# Make changes to terraform.tfvars or *.tf files

# Review changes
terraform plan

# Apply updates
terraform apply

# Verify changes
terraform output
```

### Rolling Back Changes

```bash
# Revert to previous state
terraform state pull > backup.tfstate
terraform apply -state=backup.tfstate

# Or destroy and recreate
terraform destroy -target=module.repository_security
terraform apply
```

## Compliance

### Supported Frameworks

- **SOC 2**: Automated security controls and audit logging
- **PCI-DSS**: Secure coding requirements via CodeQL
- **HIPAA**: Security controls for protected health information
- **GDPR**: Data protection controls and audit trail

### Audit Evidence

```bash
# Export security alert history
gh api /orgs/YOUR_ORG/security-advisories > security-advisories.json

# Export audit log
gh api /orgs/YOUR_ORG/audit-log > audit-log.json

# Generate compliance report
terraform output -json > compliance-state.json
```

## Support

### Documentation

- [GitHub Advanced Security Documentation](https://docs.github.com/en/enterprise-cloud@latest/get-started/learning-about-github/about-github-advanced-security)
- [Terraform GitHub Provider](https://registry.terraform.io/providers/integrations/github/latest/docs)
- [CodeQL Documentation](https://codeql.github.com/docs/)

### Contact

- **Security Team**: security-team@company.com
- **Platform Team**: platform-team@company.com

---

**Last Updated**: December 2025
**Version**: 1.0
**Maintained By**: EO Framework GitHub Solutions Team
