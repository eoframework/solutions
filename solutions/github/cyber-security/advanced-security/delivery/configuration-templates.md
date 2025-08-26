# Security Configuration Templates - GitHub Advanced Security Platform

## Overview
This document provides security configuration templates and examples for deploying the GitHub Advanced Security Platform across different environments and compliance frameworks.

## CodeQL Configuration Templates

### Basic CodeQL Analysis Configuration
```yaml
# .github/codeql/codeql-config.yml
name: "CodeQL Config"

disable-default-queries: false

queries:
  - name: security-and-quality
    uses: security-and-quality
  - name: custom-queries
    uses: ./.github/codeql/custom-queries/

paths:
  - "src/**"
  - "lib/**"

paths-ignore:
  - "node_modules/**"
  - "test/**"
  - "docs/**"
  - "**/*.test.*"

query-filters:
  - exclude:
      id: "js/unused-local-variable"
  - include:
      severity: "error"
      security-severity: "high"
```

### Advanced CodeQL Configuration with Custom Queries
```yaml
# .github/codeql/advanced-config.yml
name: "Advanced CodeQL Config"

disable-default-queries: false

query-suites:
  - security-extended
  - code-scanning

queries:
  - name: security-queries
    uses: security-and-quality
  - name: custom-security
    uses: ./.github/codeql/security/
  - name: organization-queries
    uses: your-org/security-queries@main

paths:
  - "src/**"
  - "lib/**"
  - "api/**"

paths-ignore:
  - "node_modules/**"
  - "vendor/**"
  - "test/**"
  - "**/*.test.*"
  - "**/*.spec.*"
  - "build/**"
  - "dist/**"

query-filters:
  - exclude:
      id: "js/unused-local-variable"
      id: "js/redundant-assignment"
  - include:
      severity: "error"
      security-severity: "medium"
  - exclude:
      tags: "experimental"

packs:
  javascript:
    - "github/codeql/javascript-queries"
    - "your-org/javascript-security-pack"
  python:
    - "github/codeql/python-queries"
    - "your-org/python-security-pack"
```

### Custom CodeQL Queries
```ql
/**
 * @name Hardcoded credentials
 * @description Detects hardcoded credentials in source code
 * @kind problem
 * @problem.severity error
 * @security-severity 9.0
 * @id custom/hardcoded-credentials
 */

import javascript

from StringLiteral str
where
  str.getValue().regexpMatch("(?i).*(password|secret|key|token)\\s*[:=]\\s*['\"][^'\"]{8,}['\"].*")
  and not str.getFile().getBaseName().matches("test%")
  and not str.getFile().getBaseName().matches("spec%")
select str, "Potential hardcoded credential found."
```

## Secret Scanning Configuration

### Organization Secret Scanning Policy
```yaml
# Organization-level secret scanning configuration
secret_scanning:
  enabled: true
  push_protection: true
  
  custom_patterns:
    - name: "Custom API Key Pattern"
      regex: "(?i)custom[_-]?api[_-]?key[_-]?[:=]\\s*['\"]?([a-z0-9]{32})['\"]?"
      entropy_threshold: 3.5
      
    - name: "Database Connection String"
      regex: "(?i)(mysql|postgresql|mongodb)://[^\\s]+:[^\\s]+@[^\\s]+/[^\\s]+"
      
    - name: "Private Key"
      regex: "-----BEGIN (RSA |EC )?PRIVATE KEY-----"
      
  allowlist:
    paths:
      - "test/**"
      - "docs/**"
      - "examples/**"
    secrets:
      - "example.com"
      - "placeholder"
      - "dummy-key-123"
      - "test-secret"

  validity_checks:
    enabled: true
    providers:
      - "github"
      - "aws"
      - "azure"
      - "slack"
```

### Repository Secret Scanning Override
```yaml
# Repository-specific secret scanning configuration
secret_scanning:
  enabled: true
  push_protection: true
  
  repository_allowlist:
    - "config/example.env"
    - "docs/api-examples.md"
    - "test/fixtures/keys.txt"
    
  custom_patterns:
    - name: "Internal Service Token"
      regex: "internal_token_[a-zA-Z0-9]{16}"
      
  notifications:
    email: "security-team@company.com"
    slack: "https://hooks.slack.com/services/..."
```

## Dependency Security Configuration

### Dependabot Configuration
```yaml
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "weekly"
      day: "monday"
      time: "09:00"
    open-pull-requests-limit: 10
    reviewers:
      - "security-team"
    assignees:
      - "lead-developer"
    labels:
      - "dependencies"
      - "security"
    vendor: true
    versioning-strategy: "increase"
    
  - package-ecosystem: "docker"
    directory: "/"
    schedule:
      interval: "weekly"
    ignore:
      - dependency-name: "node"
        versions: ["16.x"]
        
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "monthly"
```

### Dependency Review Configuration
```yaml
# Dependency review workflow
name: Dependency Review
on:
  pull_request:
    branches: [main]

permissions:
  contents: read
  pull-requests: write

jobs:
  dependency-review:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
        
      - name: Dependency Review
        uses: actions/dependency-review-action@v3
        with:
          fail-on-severity: high
          allow-licenses: "MIT, Apache-2.0, BSD-3-Clause"
          deny-licenses: "GPL-3.0, AGPL-3.0"
          comment-summary-in-pr: true
```

## Security Policy Templates

### Organization Security Policy
```yaml
# Organization security policy configuration
security_policy:
  default_repository_policy:
    private_vulnerability_reporting: true
    security_advisories: true
    
  branch_protection:
    enforce_admins: true
    required_status_checks:
      strict: true
      contexts:
        - "Security / CodeQL Analysis"
        - "Security / Secret Scanning"
        - "Security / Dependency Review"
        
    required_pull_request_reviews:
      required_approving_review_count: 2
      dismiss_stale_reviews: true
      require_code_owner_reviews: true
      restrict_pushes: true
      
    restrictions:
      users: []
      teams: ["security-team"]
      apps: []

  security_features:
    dependency_graph: true
    vulnerability_alerts: true
    security_advisories: true
    secret_scanning: true
    secret_scanning_push_protection: true
    
  compliance:
    frameworks:
      - "SOC2"
      - "PCI-DSS"
      - "GDPR"
    audit_log_retention: 365
    security_log_forwarding: true
```

### Repository Security Policy Template
```markdown
# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 2.x.x   | :white_check_mark: |
| 1.9.x   | :white_check_mark: |
| 1.8.x   | :x:                |
| < 1.8   | :x:                |

## Reporting a Vulnerability

We take security vulnerabilities seriously. Please follow these guidelines:

### Private Reporting
- Use GitHub's private vulnerability reporting feature
- Send detailed information to security@company.com
- Include steps to reproduce the vulnerability

### Response Timeline
- Initial response: 24 hours
- Status update: 72 hours
- Resolution timeline: Based on severity

### Severity Classification
- **Critical**: Immediate attention required
- **High**: 7-day resolution target
- **Medium**: 30-day resolution target
- **Low**: Next release cycle

## Security Best Practices

### For Contributors
- Run security scans before submitting PRs
- Follow secure coding guidelines
- Report suspicious dependencies
- Never commit secrets or credentials

### For Maintainers
- Review all security alerts promptly
- Keep dependencies up to date
- Conduct security reviews for major changes
- Monitor for unusual activity
```

## Compliance Configuration Templates

### SOC 2 Compliance Configuration
```yaml
# SOC 2 compliance configuration
compliance:
  framework: "SOC2"
  
  security_controls:
    access_control:
      - "Multi-factor authentication required"
      - "Role-based access control implemented"
      - "Regular access reviews conducted"
      
    data_protection:
      - "Data encryption in transit and at rest"
      - "Data classification implemented"
      - "Data retention policies enforced"
      
    monitoring:
      - "Security event logging enabled"
      - "Continuous monitoring implemented"
      - "Incident response procedures documented"
      
  audit_requirements:
    log_retention: 365
    backup_retention: 2555  # 7 years
    evidence_collection: true
    
  reporting:
    frequency: "quarterly"
    recipients:
      - "compliance-team@company.com"
      - "audit-team@company.com"
```

### PCI DSS Compliance Configuration
```yaml
# PCI DSS compliance configuration
compliance:
  framework: "PCI-DSS"
  
  security_requirements:
    network_security:
      - "Firewall configuration documented"
      - "Network segmentation implemented"
      - "Secure transmission protocols used"
      
    data_protection:
      - "Cardholder data encryption"
      - "Strong cryptography implementation"
      - "Secure key management"
      
    access_control:
      - "Unique user IDs assigned"
      - "Access control systems implemented"
      - "Regular access reviews"
      
    monitoring:
      - "Security monitoring systems"
      - "File integrity monitoring"
      - "Log review procedures"
      
  vulnerability_management:
    scan_frequency: "quarterly"
    remediation_timeline: 30  # days
    pen_test_frequency: "annual"
```

## SIEM Integration Templates

### Splunk Integration Configuration
```yaml
# Splunk SIEM integration
siem_integration:
  provider: "splunk"
  
  connection:
    url: "https://splunk.company.com:8088"
    token: "${{ secrets.SPLUNK_HEC_TOKEN }}"
    index: "github_security"
    
  event_mapping:
    secret_scanning:
      source_type: "github:secret_scanning"
      severity_mapping:
        critical: "high"
        high: "medium"
        medium: "low"
        
    code_scanning:
      source_type: "github:code_scanning"
      severity_mapping:
        error: "high"
        warning: "medium"
        note: "low"
        
    dependency_alerts:
      source_type: "github:dependabot"
      severity_mapping:
        critical: "critical"
        high: "high"
        moderate: "medium"
        low: "low"
        
  forwarding_rules:
    - event_type: "security_alert"
      conditions:
        severity: ["critical", "high"]
      action: "forward_immediately"
      
    - event_type: "compliance_violation"
      conditions: {}
      action: "forward_immediately"
```

### Microsoft Sentinel Integration
```yaml
# Microsoft Sentinel integration
siem_integration:
  provider: "azure_sentinel"
  
  connection:
    workspace_id: "${{ secrets.SENTINEL_WORKSPACE_ID }}"
    shared_key: "${{ secrets.SENTINEL_SHARED_KEY }}"
    log_type: "GitHubSecurity"
    
  data_collection:
    security_alerts: true
    audit_logs: true
    repository_events: true
    
  alert_rules:
    - name: "High Severity Vulnerability"
      query: |
        GitHubSecurity_CL
        | where severity_s == "critical" or severity_s == "high"
        | summarize count() by repository_s, bin(TimeGenerated, 1h)
        | where count_ > 5
      frequency: "PT15M"
      severity: "High"
```

## Security Automation Templates

### Automated Response Workflow
```yaml
name: Security Response Automation
on:
  repository_vulnerability_alert:
    types: [create]

jobs:
  triage:
    runs-on: ubuntu-latest
    steps:
      - name: Assess Severity
        id: assess
        run: |
          severity="${{ github.event.alert.security_advisory.severity }}"
          if [[ "$severity" == "critical" || "$severity" == "high" ]]; then
            echo "escalate=true" >> $GITHUB_OUTPUT
          fi
          
      - name: Create Security Issue
        if: steps.assess.outputs.escalate == 'true'
        uses: actions/github-script@v7
        with:
          script: |
            const issue = await github.rest.issues.create({
              owner: context.repo.owner,
              repo: context.repo.repo,
              title: `Security Alert: ${{ github.event.alert.security_advisory.summary }}`,
              body: `A ${{ github.event.alert.security_advisory.severity }} severity vulnerability has been detected.
              
              **Package:** ${{ github.event.alert.affected_package_name }}
              **Range:** ${{ github.event.alert.affected_range }}
              **Fixed In:** ${{ github.event.alert.fixed_in }}
              
              **Details:** ${{ github.event.alert.security_advisory.description }}`,
              labels: ['security', 'vulnerability', '${{ github.event.alert.security_advisory.severity }}'],
              assignees: ['security-team']
            });
            
      - name: Notify Security Team
        if: steps.assess.outputs.escalate == 'true'
        run: |
          curl -X POST "${{ secrets.SLACK_WEBHOOK }}" \
            -H "Content-Type: application/json" \
            -d '{
              "text": "🚨 Critical Security Alert",
              "blocks": [{
                "type": "section",
                "text": {
                  "type": "mrkdwn",
                  "text": "A critical vulnerability has been detected in ${{ github.repository }}"
                }
              }]
            }'
```

### Security Metrics Collection
```yaml
name: Security Metrics Collection
on:
  schedule:
    - cron: '0 9 * * 1'  # Weekly on Monday

jobs:
  collect-metrics:
    runs-on: ubuntu-latest
    steps:
      - name: Collect Security Data
        run: |
          # Collect CodeQL findings
          gh api "/repos/${{ github.repository }}/code-scanning/analyses" \
            --jq '.[] | select(.created_at > (now - 604800))' > codeql_findings.json
          
          # Collect secret scanning alerts
          gh api "/repos/${{ github.repository }}/secret-scanning/alerts" \
            --jq '.[] | select(.created_at > (now - 604800))' > secret_findings.json
          
          # Collect dependency alerts
          gh api "/repos/${{ github.repository }}/dependabot/alerts" \
            --jq '.[] | select(.created_at > (now - 604800))' > dependency_findings.json
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          
      - name: Generate Security Report
        run: |
          python3 << 'EOF'
          import json
          import datetime
          
          # Process security findings
          with open('codeql_findings.json') as f:
              codeql_data = json.load(f)
          
          with open('secret_findings.json') as f:
              secret_data = json.load(f)
              
          with open('dependency_findings.json') as f:
              dependency_data = json.load(f)
          
          # Generate summary report
          report = {
              "date": datetime.datetime.now().isoformat(),
              "repository": "${{ github.repository }}",
              "metrics": {
                  "codeql_findings": len(codeql_data),
                  "secret_findings": len(secret_data),
                  "dependency_findings": len(dependency_data)
              }
          }
          
          with open('security_report.json', 'w') as f:
              json.dump(report, f, indent=2)
          EOF
          
      - name: Upload Report
        uses: actions/upload-artifact@v3
        with:
          name: security-report
          path: security_report.json
```

## Customization Guidelines

### Environment-Specific Configuration
- **Development**: Relaxed policies for rapid development
- **Staging**: Production-like security with testing data
- **Production**: Strict security policies and monitoring

### Compliance-Specific Settings
- **SOC 2**: Focus on access controls and monitoring
- **PCI DSS**: Emphasis on data protection and network security
- **GDPR**: Data privacy and protection controls
- **HIPAA**: Healthcare-specific security requirements

### Integration Considerations
- SIEM platform capabilities and data format requirements
- Existing security tool ecosystem integration points
- Alert fatigue prevention through intelligent filtering
- Automated response capabilities and approval workflows