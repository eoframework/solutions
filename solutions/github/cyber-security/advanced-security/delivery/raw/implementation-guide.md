---
document_title: Implementation Guide
solution_name: GitHub Advanced Security
document_version: "1.0"
author: "[TECH_LEAD]"
last_updated: "[DATE]"
technology_provider: github
client_name: "[CLIENT]"
client_logo: ../../assets/logos/client_logo.png
vendor_logo: ../../assets/logos/consulting_company_logo.png
eoframework_logo: ../../assets/logos/eo-framework-logo-real.png
---

# Executive Summary

This Implementation Guide provides comprehensive deployment procedures for the GitHub Advanced Security (GHAS) solution. The guide covers GitHub Enterprise Cloud organization setup, CodeQL configuration for 5 programming languages, secret scanning with push protection, Dependabot configuration, and SIEM integration using webhooks and automation scripts.

## Document Purpose

This document serves as the primary technical reference for the implementation team, providing step-by-step procedures for deploying GHAS across 200 repositories. All commands and procedures have been validated against target GitHub Enterprise Cloud environments.

## Implementation Approach

The implementation follows a pilot-validate-expand methodology with phased repository enablement. The approach uses GitHub organization settings for security defaults, GitHub Actions workflows for CodeQL scanning, and GitHub CLI/API for bulk configuration automation.

## Automation Framework Overview

The following automation technologies are included in this delivery.

<!-- TABLE_CONFIG: widths=[20, 30, 25, 25] -->
| Technology | Purpose | Location | Prerequisites |
|------------|---------|----------|---------------|
| GitHub CLI | Organization and repo configuration | `scripts/bash/` | gh CLI 2.x installed |
| Python | Bulk automation and reporting | `scripts/python/` | Python 3.10+, pip |
| GitHub Actions | CodeQL workflow templates | `scripts/workflows/` | Repository access |
| Bash | Shell automation scripts | `scripts/bash/` | Bash 4.0+ |

## Scope Summary

### In Scope

The following components are deployed using the automation framework.

- GitHub Enterprise Cloud organization configuration
- SAML SSO and MFA configuration
- GitHub Advanced Security enablement for 200 repositories
- CodeQL workflow deployment for 5 languages
- Secret scanning with push protection
- Dependabot vulnerability alerts and security updates
- Custom CodeQL query development (15 queries)
- SIEM webhook integration (Splunk/Azure Sentinel)
- Issue tracking integration (JIRA/ServiceNow)

### Out of Scope

The following items are excluded from automated deployment.

- Self-hosted GitHub Enterprise Server
- C/C++ language scanning (Phase 2)
- Custom ML models for security detection
- End-user training delivery (covered separately)

## Timeline Overview

The implementation follows a phased deployment approach with validation gates.

<!-- TABLE_CONFIG: widths=[15, 30, 30, 25] -->
| Phase | Activities | Duration | Exit Criteria |
|-------|------------|----------|---------------|
| 1 | Prerequisites & Organization Setup | 1 week | GitHub org configured, SSO enabled |
| 2 | Pilot Repositories (10 repos) | 2 weeks | CodeQL enabled, 95%+ accuracy |
| 3 | Custom Query Development | 3 weeks | 15 custom queries deployed |
| 4 | Organization-Wide Rollout | 8 weeks | 200 repos enabled, policies enforced |
| 5 | Integration & Testing | 4 weeks | SIEM integration, UAT complete |
| 6 | Go-Live & Hypercare | 6 weeks | Production stable, team trained |

**Total Implementation:** 24 weeks (~6 months)

# Prerequisites

This section documents all requirements that must be satisfied before GHAS deployment can begin.

## Tool Installation

The following tools must be installed on the deployment workstation before proceeding.

### Required Tools Checklist

Use the following checklist to verify all required tools are installed.

- [ ] **GitHub CLI** >= 2.x - GitHub organization management
- [ ] **Python** >= 3.10 - Automation scripts
- [ ] **Git** >= 2.30 - Repository operations
- [ ] **jq** - JSON processing for scripts

### GitHub CLI Installation

Install and configure the GitHub CLI.

```bash
# macOS (using Homebrew)
brew install gh

# Windows (using winget)
winget install --id GitHub.cli

# Linux (Debian/Ubuntu)
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update && sudo apt install gh

# Verify installation
gh --version
```

### GitHub CLI Authentication

Authenticate with your GitHub organization.

```bash
# Authenticate with GitHub (interactive)
gh auth login

# Select:
# - GitHub.com
# - HTTPS
# - Login with a web browser

# Verify authentication
gh auth status

# Set default organization
gh config set org YOUR_ORGANIZATION_NAME
```

### Python Environment Setup

Set up Python environment for automation scripts.

```bash
# Verify Python version
python3 --version

# Create virtual environment
python3 -m venv venv
source venv/bin/activate  # Linux/Mac
# venv\Scripts\activate   # Windows

# Install required packages
pip install PyGithub requests pandas
pip install -r scripts/python/requirements.txt
```

## GitHub Account Configuration

Configure GitHub access and verify required permissions.

### Personal Access Token Creation

Create a personal access token with required scopes.

```bash
# Required scopes for GHAS configuration:
# - repo (Full control of private repositories)
# - admin:org (Full control of orgs and teams)
# - security_events (Read and write security events)
# - write:packages (Write packages - if applicable)

# Create token via GitHub UI:
# Settings > Developer settings > Personal access tokens > Tokens (classic)

# Export token for scripts
export GITHUB_TOKEN="ghp_your_token_here"

# Verify token permissions
gh api user
gh api orgs/YOUR_ORG/repos --paginate -q '.[].name' | wc -l
```

### Required GitHub Permissions

The deployment user/role requires the following permissions.

- **Organization Owner:** Full admin access to organization settings
- **Security Admin:** Manage security features and alerts
- **Repository Admin:** Configure repository settings and branch protection
- **Billing Manager:** View and manage GitHub licensing

### License Validation

Verify GitHub Enterprise and GHAS licensing is available.

```bash
# Check organization license
gh api /orgs/YOUR_ORG -q '.plan'

# Verify GHAS is available
gh api /orgs/YOUR_ORG -q '.two_factor_requirement_enabled'

# List available security features
gh api /orgs/YOUR_ORG -q '.advanced_security_enabled_for_new_repositories'
```

## Prerequisite Validation

Run the prerequisite validation script to verify all requirements.

```bash
# Navigate to scripts directory
cd delivery/scripts/

# Run prerequisite validation
./validate-prerequisites.sh

# Or manually verify each component
gh --version
python3 --version
git --version
gh auth status
```

### Validation Checklist

Complete this checklist before proceeding to environment setup.

- [ ] GitHub CLI installed and accessible in PATH
- [ ] GitHub personal access token created with required scopes
- [ ] Python 3.10+ installed with pip
- [ ] Required Python packages installed
- [ ] Organization owner access verified
- [ ] GitHub Enterprise Cloud license confirmed
- [ ] GHAS licensing confirmed (80 committers)

# Environment Setup

This section covers the initial setup of the GitHub organization environment for GHAS deployment.

## GitHub Organization Configuration

Configure organization-level settings for security.

### Organization Security Defaults

Enable security defaults for new repositories.

```bash
# Enable GHAS for new repositories by default
gh api \
  --method PATCH \
  -H "Accept: application/vnd.github+json" \
  /orgs/YOUR_ORG \
  -f advanced_security_enabled_for_new_repositories=true \
  -f secret_scanning_enabled_for_new_repositories=true \
  -f secret_scanning_push_protection_enabled_for_new_repositories=true \
  -f dependabot_alerts_enabled_for_new_repositories=true \
  -f dependabot_security_updates_enabled_for_new_repositories=true

# Verify settings
gh api /orgs/YOUR_ORG -q '{
  advanced_security: .advanced_security_enabled_for_new_repositories,
  secret_scanning: .secret_scanning_enabled_for_new_repositories,
  push_protection: .secret_scanning_push_protection_enabled_for_new_repositories,
  dependabot: .dependabot_alerts_enabled_for_new_repositories
}'
```

### SAML SSO Configuration

Configure SAML SSO with your corporate identity provider.

1. Navigate to Organization Settings > Authentication security
2. Enable SAML single sign-on
3. Configure IdP settings:
   - Sign-on URL: [Your IdP SSO URL]
   - Issuer: [Your IdP Entity ID]
   - Public certificate: [Upload IdP certificate]
4. Test SAML configuration
5. Enforce SAML SSO for all members

```bash
# Verify SAML is enabled
gh api /orgs/YOUR_ORG/saml -q '.enabled'
```

### MFA Requirement

Require multi-factor authentication for all members.

```bash
# Enable MFA requirement
gh api \
  --method PATCH \
  -H "Accept: application/vnd.github+json" \
  /orgs/YOUR_ORG \
  -f two_factor_requirement_enabled=true

# Verify MFA is required
gh api /orgs/YOUR_ORG -q '.two_factor_requirement_enabled'
```

## Repository Inventory

Generate inventory of repositories requiring GHAS enablement.

### Repository Discovery

```bash
# List all repositories in organization
gh repo list YOUR_ORG --limit 500 --json name,language,visibility,isArchived \
  | jq -r '.[] | select(.isArchived == false) | [.name, .language, .visibility] | @csv' \
  > repository-inventory.csv

# Count repositories by language
gh repo list YOUR_ORG --limit 500 --json language \
  | jq -r '.[].language // "None"' | sort | uniq -c | sort -rn

# Expected output:
# 45 JavaScript
# 35 Python
# 30 Java
# 25 C#
# 20 Go
# ... (200 total)
```

### Repository Classification

```bash
# Navigate to Python scripts
cd delivery/scripts/python/

# Generate repository classification report
python3 classify_repositories.py \
  --org YOUR_ORG \
  --output reports/repository-classification.json

# Review classification
cat reports/repository-classification.json | jq '.summary'
```

# Infrastructure Deployment

This section covers the deployment of GHAS security infrastructure components across the organization. The deployment follows a phased approach covering networking configuration, security infrastructure setup, compute resource allocation, and monitoring system integration.

## Networking Configuration

Configure network and webhook infrastructure for security integrations.

### Webhook Endpoint Setup

```bash
# Create organization webhook for security events
gh api \
  --method POST \
  -H "Accept: application/vnd.github+json" \
  /orgs/YOUR_ORG/hooks \
  -f name="web" \
  -f active=true \
  -f events[]="code_scanning_alert" \
  -f events[]="secret_scanning_alert" \
  -f events[]="dependabot_alert" \
  -f events[]="security_advisory" \
  -f config[url]="https://your-siem.example.com/github/webhook" \
  -f config[content_type]="json" \
  -f config[secret]="YOUR_WEBHOOK_SECRET"
```

## Security Infrastructure

Deploy CodeQL scanning infrastructure and secret detection capabilities.

### CodeQL Workflow Templates

Deploy CodeQL workflow templates to repositories.

```yaml
# .github/workflows/codeql.yml
name: "CodeQL"

on:
  push:
    branches: [ "main", "develop" ]
  pull_request:
    branches: [ "main", "develop" ]
  schedule:
    - cron: '0 2 * * *'  # Daily at 2 AM UTC

jobs:
  analyze:
    name: Analyze
    runs-on: ubuntu-latest
    permissions:
      actions: read
      contents: read
      security-events: write

    strategy:
      fail-fast: false
      matrix:
        language: [ 'javascript', 'python' ]

    steps:
    - name: Checkout repository
      uses: actions/checkout@v4

    - name: Initialize CodeQL
      uses: github/codeql-action/init@v3
      with:
        languages: ${{ matrix.language }}
        queries: security-extended

    - name: Autobuild
      uses: github/codeql-action/autobuild@v3

    - name: Perform CodeQL Analysis
      uses: github/codeql-action/analyze@v3
      with:
        category: "/language:${{ matrix.language }}"
```

### Bulk Workflow Deployment

```bash
# Navigate to scripts directory
cd delivery/scripts/

# Deploy CodeQL workflows to pilot repositories
python3 deploy_codeql_workflow.py \
  --org YOUR_ORG \
  --repos pilot-repos.txt \
  --languages javascript,python \
  --query-suite security-extended

# Deploy to all repositories by language
python3 deploy_codeql_workflow.py \
  --org YOUR_ORG \
  --language javascript \
  --query-suite security-extended

python3 deploy_codeql_workflow.py \
  --org YOUR_ORG \
  --language python \
  --query-suite security-extended
```

## Compute Infrastructure

Configure GitHub Actions runners for CodeQL scanning.

### Runner Configuration

```bash
# Verify GitHub-hosted runners are available
gh api /orgs/YOUR_ORG/actions/runner-groups -q '.runner_groups[].name'

# Check runner usage limits
gh api /orgs/YOUR_ORG/settings/billing/actions -q '{total_minutes_used, included_minutes}'
```

## Monitoring Infrastructure

Deploy monitoring and alerting for security scanning.

### Alert Monitoring Setup

```bash
# List organization webhooks
gh api /orgs/YOUR_ORG/hooks -q '.[] | {id, name, events, config}'

# Check recent webhook deliveries
gh api /orgs/YOUR_ORG/hooks/HOOK_ID/deliveries -q '.[0:5] | .[] | {id, status_code, delivered_at}'

# Redeliver failed webhook
gh api \
  --method POST \
  /orgs/YOUR_ORG/hooks/HOOK_ID/deliveries/DELIVERY_ID/attempts
```

# Application Configuration

This section covers the configuration of GHAS features for each application repository.

## Secret Scanning Configuration

Enable secret scanning organization-wide.

```bash
# Enable secret scanning for all repositories
python3 enable_secret_scanning.py \
  --org YOUR_ORG \
  --enable-push-protection \
  --all-repos

# Verify secret scanning enabled
gh api /repos/YOUR_ORG/REPO_NAME \
  -q '{secret_scanning: .security_and_analysis.secret_scanning.status, push_protection: .security_and_analysis.secret_scanning_push_protection.status}'
```

### Push Protection Configuration

Configure push protection to block secrets.

```bash
# Enable push protection for existing repositories
for repo in $(gh repo list YOUR_ORG --json name -q '.[].name'); do
  gh api \
    --method PUT \
    -H "Accept: application/vnd.github+json" \
    /repos/YOUR_ORG/$repo/secret-scanning/push-protection \
    -f status=enabled
done
```

### Custom Secret Patterns

Configure custom secret patterns for proprietary patterns.

```bash
# Navigate to GitHub organization settings
# Security > Code security and analysis > Secret scanning

# Add custom patterns via API
gh api \
  --method POST \
  -H "Accept: application/vnd.github+json" \
  /orgs/YOUR_ORG/secret-scanning/custom-patterns \
  -f name="Proprietary API Key" \
  -f pattern="YOUR_COMPANY_API_[A-Za-z0-9]{32}" \
  -f description="Matches internal API keys"
```

## Dependabot Configuration

Enable Dependabot for all repositories.

```bash
# Enable Dependabot alerts organization-wide
python3 enable_dependabot.py \
  --org YOUR_ORG \
  --enable-security-updates \
  --all-repos

# Verify Dependabot enabled
gh api /repos/YOUR_ORG/REPO_NAME \
  -q '{dependabot_alerts: .security_and_analysis.dependabot_alerts.status, security_updates: .security_and_analysis.dependabot_security_updates.status}'
```

### Dependabot Configuration File

Deploy Dependabot configuration to repositories.

```yaml
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "daily"
    open-pull-requests-limit: 10
    labels:
      - "dependencies"
      - "security"

  - package-ecosystem: "pip"
    directory: "/"
    schedule:
      interval: "daily"
    open-pull-requests-limit: 10

  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
```

### Bulk Dependabot Deployment

```bash
# Deploy dependabot.yml to all repositories
python3 deploy_dependabot_config.py \
  --org YOUR_ORG \
  --template templates/dependabot.yml \
  --all-repos
```

## Custom CodeQL Queries

Deploy custom CodeQL queries for organization-specific patterns.

### Custom Query Repository Setup

```bash
# Create custom queries repository
gh repo create YOUR_ORG/codeql-custom-queries --private

# Clone and add queries
git clone https://github.com/YOUR_ORG/codeql-custom-queries
cd codeql-custom-queries
mkdir -p queries/javascript queries/python queries/java
```

### Custom Query Example

```ql
// queries/javascript/custom-api-key-exposure.ql
/**
 * @name Hardcoded proprietary API key
 * @description Detects hardcoded proprietary API keys in source code
 * @kind problem
 * @problem.severity error
 * @security-severity 8.0
 * @precision high
 * @id custom/api-key-exposure
 * @tags security
 *       custom
 */

import javascript

from StringLiteral literal
where literal.getValue().regexpMatch("YOUR_COMPANY_API_[A-Za-z0-9]{32}")
select literal, "Hardcoded proprietary API key detected"
```

### Deploy Custom Queries

```bash
# Reference custom queries in workflow
# .github/codeql/codeql-config.yml
queries:
  - uses: security-extended
  - uses: YOUR_ORG/codeql-custom-queries/queries@main
```

# Integration Testing

This section covers integration testing procedures for GHAS deployment.

## Test Environment Preparation

Prepare test repositories and data.

```bash
# Create test repository with known vulnerabilities
gh repo create YOUR_ORG/ghas-test-repo --private

# Add vulnerable code for testing
git clone https://github.com/YOUR_ORG/ghas-test-repo
cd ghas-test-repo

# Add JavaScript file with XSS vulnerability
cat > vulnerable.js << 'EOF'
const express = require('express');
const app = express();

app.get('/search', (req, res) => {
  // Vulnerable: XSS via reflected input
  res.send('<h1>Results for: ' + req.query.q + '</h1>');
});
EOF

git add vulnerable.js
git commit -m "Add test vulnerable code"
git push
```

## Functional Test Execution

### CodeQL Detection Tests

```bash
# Execute CodeQL detection test
python3 validate.py \
  --environment production \
  --test-suite codeql-detection \
  --verbose \
  --report

# Test secret scanning
echo "AWS_ACCESS_KEY=AKIAIOSFODNN7EXAMPLE" > test-secrets.txt
# Attempt to commit (should be blocked by push protection)
```

### Detection Accuracy Tests

```bash
# Run accuracy validation against ground truth
python3 validate.py \
  --environment production \
  --test-suite detection-accuracy \
  --ground-truth samples/vulnerabilities.json

# Calculate accuracy metrics
python3 calculate_accuracy.py \
  --results reports/detection-results.json \
  --expected samples/expected-results.json
```

### Performance Tests

```bash
# Measure PR scan duration
python3 validate.py \
  --environment production \
  --test-suite performance \
  --repos sample-repos.txt \
  --report

# Review scan timing
cat reports/performance-results.json | jq '.average_scan_duration'
```

## Test Success Criteria

Complete this checklist before proceeding.

- [ ] All CodeQL workflows triggering on PR
- [ ] Detection accuracy > 95% on test cases
- [ ] Push protection blocking known secrets
- [ ] Dependabot alerts generating for vulnerable dependencies
- [ ] SIEM receiving webhook events
- [ ] PR scan duration < 15 minutes average

# Security Validation

This section covers security validation procedures for GHAS deployment.

## Security Configuration Audit

### Repository Security Scan

```bash
# Audit security settings across all repositories
python3 audit_security.py \
  --org YOUR_ORG \
  --output reports/security-audit.json

# Check for misconfigurations
cat reports/security-audit.json | jq '.repositories[] | select(.issues | length > 0)'
```

### Branch Protection Validation

```bash
# Verify branch protection on default branches
for repo in $(gh repo list YOUR_ORG --json name -q '.[].name'); do
  echo "Checking $repo..."
  gh api /repos/YOUR_ORG/$repo/branches/main/protection -q '.required_status_checks.contexts' 2>/dev/null
done

# Expected: CodeQL required check present
```

### Access Control Validation

```bash
# List organization members and their roles
gh api /orgs/YOUR_ORG/members -q '.[] | {login, role}'

# List teams and their repository access
gh api /orgs/YOUR_ORG/teams -q '.[] | {name, slug, permission}'
```

## Compliance Validation

### Encryption Validation

```bash
# Verify all traffic uses HTTPS (GitHub enforces this)
# Verify webhook secrets are configured
gh api /orgs/YOUR_ORG/hooks -q '.[] | {id, config: .config.insecure_ssl}'
```

### Audit Logging Validation

```bash
# Verify audit log is accessible
gh api /orgs/YOUR_ORG/audit-log?per_page=5 -q '.[] | {action, actor, created_at}'

# Check for security-related events
gh api "/orgs/YOUR_ORG/audit-log?phrase=action:secret_scanning" -q '.[0:10]'
```

## Security Validation Checklist

- [ ] SAML SSO enforced for all members
- [ ] MFA required organization-wide
- [ ] Branch protection on default branches
- [ ] CodeQL checks required for merge
- [ ] Secret scanning enabled on all repositories
- [ ] Push protection blocking secrets
- [ ] Webhook secrets configured
- [ ] Audit logging operational

# Migration & Cutover

This section covers production cutover procedures for GHAS deployment.

## Pre-Migration Checklist

- [ ] All 200 repositories with CodeQL enabled
- [ ] Detection accuracy validated at 95%+
- [ ] SIEM integration tested and operational
- [ ] Security champions trained and certified
- [ ] Rollback plan documented
- [ ] Stakeholder approval obtained
- [ ] Developer communication sent

## Production Cutover

### Enable Branch Protection

```bash
# Enable required CodeQL checks on default branches
python3 enable_branch_protection.py \
  --org YOUR_ORG \
  --require-codeql \
  --all-repos

# Verify branch protection
gh api /repos/YOUR_ORG/REPO_NAME/branches/main/protection \
  -q '.required_status_checks'
```

### Traffic Validation

```bash
# Monitor GitHub Actions usage
gh api /orgs/YOUR_ORG/settings/billing/actions -q '{total_minutes_used, included_minutes}'

# Check security alert volume
gh api /orgs/YOUR_ORG/code-scanning/alerts -q 'length'
gh api /orgs/YOUR_ORG/secret-scanning/alerts -q 'length'
```

## Rollback Procedures

If critical issues are identified, execute rollback.

```bash
# Disable CodeQL workflow
gh workflow disable codeql.yml --repo YOUR_ORG/REPO_NAME

# Remove branch protection requirement
gh api \
  --method DELETE \
  /repos/YOUR_ORG/REPO_NAME/branches/main/protection/required_status_checks

# Disable push protection (emergency only)
gh api \
  --method PUT \
  /repos/YOUR_ORG/REPO_NAME/secret-scanning/push-protection \
  -f status=disabled
```

# Operational Handover

This section covers the transition to ongoing operations.

## Monitoring Dashboard Access

### GitHub Security Overview

```bash
# Access Security Overview
# https://github.com/orgs/YOUR_ORG/security/overview

# API access to security metrics
gh api /orgs/YOUR_ORG/code-scanning/alerts?state=open -q 'length'
gh api /orgs/YOUR_ORG/secret-scanning/alerts?state=open -q 'length'
gh api /orgs/YOUR_ORG/dependabot/alerts?state=open -q 'length'
```

### Key Metrics to Monitor

The following metrics should be monitored continuously.

<!-- TABLE_CONFIG: widths=[25, 25, 25, 25] -->
| Metric | Threshold | Alert Severity | Response |
|--------|-----------|----------------|----------|
| Detection Accuracy | < 93% | Warning | Review detection patterns |
| Open Critical Alerts | > 0 for 24h | Critical | Escalate to security team |
| PR Scan Duration | > 20 minutes | Warning | Investigate workflow |
| Push Protection Bypass | Any occurrence | Info | Review bypass justification |
| Webhook Failures | > 10% | Warning | Check SIEM connectivity |

## Support Transition

### Support Model

The following support model is implemented for GHAS operations.

<!-- TABLE_CONFIG: widths=[15, 30, 25, 30] -->
| Tier | Responsibility | Team | Response Time |
|------|---------------|------|---------------|
| L1 | Initial triage, developer questions | Security Champions | 15 minutes |
| L2 | Technical troubleshooting | Security Operations | 1 hour |
| L3 | Complex issues, custom queries | Vendor Support | 4 hours |
| L4 | GitHub platform issues | GitHub Support | Per contract |

### Escalation Contacts

The following contacts are available for escalation.

<!-- TABLE_CONFIG: widths=[25, 25, 30, 20] -->
| Role | Name | Email | Phone |
|------|------|-------|-------|
| Security Lead | [NAME] | security@company.com | [PHONE] |
| Security Champion Lead | [NAME] | champions@company.com | [PHONE] |
| Emergency | On-Call | oncall@company.com | [PHONE] |

# Training Program

This section documents the training program for GHAS operations.

## Training Overview

Training ensures all user groups achieve competency with GHAS features.

### Training Schedule

The following training modules are delivered as part of the implementation.

<!-- TABLE_CONFIG: widths=[10, 28, 17, 10, 15, 20] -->
| ID | Module Name | Audience | Hours | Format | Prerequisites |
|----|-------------|----------|-------|--------|---------------|
| TRN-001 | GHAS Overview | All Developers | 1 | VILT | None |
| TRN-002 | CodeQL Alert Remediation | Developers | 2 | Hands-On | TRN-001 |
| TRN-003 | Security Champion Certification | Champions | 4 | Hands-On | TRN-001 |
| TRN-004 | Push Protection Workflow | Developers | 1 | Video | TRN-001 |
| TRN-005 | Admin Configuration | Administrators | 3 | Hands-On | TRN-001 |
| TRN-006 | Custom Query Development | Security Team | 4 | Hands-On | TRN-003 |

## Training Materials

The following training materials are provided.

- Developer Quick Start Guide (one-page reference)
- Security Champion Certification Guide (30 pages)
- Video tutorials (5 recordings, 60 minutes total)
- Hands-on lab exercises
- FAQ document
- Quick reference cards

# Appendices

## Appendix A: Environment Reference

The following table documents the production environment configuration.

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Parameter | Value | Description |
|-----------|-------|-------------|
| Organization | YOUR_ORG | GitHub organization name |
| Platform | GitHub Enterprise Cloud | GitHub.com hosted |
| Repositories | 200 | Total repositories in scope |
| Active Committers | 80 | GHAS licensing basis |
| Languages | 5 | JavaScript, Python, Java, C#, Go |

## Appendix B: Troubleshooting Guide

The following table documents common issues and resolutions.

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Issue | Possible Cause | Resolution |
|-------|---------------|------------|
| CodeQL workflow fails | Build error in repository | Review workflow logs, fix build |
| Push protection false positive | Custom pattern too broad | Refine pattern regex |
| Slow PR scans | Large repository | Enable incremental analysis |
| Webhook delivery failures | SIEM connectivity | Check firewall rules, endpoint URL |
| Detection accuracy low | Missing language coverage | Add appropriate language to workflow |

### Diagnostic Commands

```bash
# Check CodeQL workflow status
gh run list --workflow=codeql.yml --repo YOUR_ORG/REPO_NAME

# View CodeQL workflow logs
gh run view RUN_ID --log --repo YOUR_ORG/REPO_NAME

# List open security alerts
gh api /repos/YOUR_ORG/REPO_NAME/code-scanning/alerts?state=open

# Check webhook delivery status
gh api /orgs/YOUR_ORG/hooks/HOOK_ID/deliveries

# View audit log for security events
gh api "/orgs/YOUR_ORG/audit-log?phrase=action:code_scanning"
```

## Appendix C: GitHub API Reference

The following table documents relevant API endpoints.

<!-- TABLE_CONFIG: widths=[30, 25, 25, 20] -->
| Endpoint | Method | Purpose | Rate Limit |
|----------|--------|---------|------------|
| /orgs/{org}/code-scanning/alerts | GET | List org code scanning alerts | 5000/hr |
| /orgs/{org}/secret-scanning/alerts | GET | List org secret alerts | 5000/hr |
| /orgs/{org}/dependabot/alerts | GET | List org Dependabot alerts | 5000/hr |
| /repos/{owner}/{repo}/code-scanning/alerts | GET | List repo alerts | 5000/hr |
| /orgs/{org}/audit-log | GET | Query audit log | 1750/hr |
