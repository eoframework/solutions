# GitHub Advanced Security Platform - Training Materials

## Table of Contents

1. [Training Overview](#training-overview)
2. [Prerequisites](#prerequisites)
3. [Module 1: GitHub Advanced Security Fundamentals](#module-1-github-advanced-security-fundamentals)
4. [Module 2: CodeQL Security Analysis](#module-2-codeql-security-analysis)
5. [Module 3: Secret Scanning Implementation](#module-3-secret-scanning-implementation)
6. [Module 4: Dependency Vulnerability Management](#module-4-dependency-vulnerability-management)
7. [Module 5: SIEM Integration and Monitoring](#module-5-siem-integration-and-monitoring)
8. [Module 6: Compliance and Audit Management](#module-6-compliance-and-audit-management)
9. [Module 7: Incident Response Procedures](#module-7-incident-response-procedures)
10. [Module 8: Advanced Configuration and Automation](#module-8-advanced-configuration-and-automation)
11. [Hands-on Exercises](#hands-on-exercises)
12. [Assessment and Certification](#assessment-and-certification)
13. [Additional Resources](#additional-resources)

## Training Overview

### Objectives

By the end of this training program, participants will be able to:

- **Configure and manage** GitHub Advanced Security features across an organization
- **Implement comprehensive security scanning** workflows using CodeQL, secret scanning, and dependency analysis
- **Integrate security monitoring** with enterprise SIEM systems (Splunk, Azure Sentinel, Datadog)
- **Establish compliance monitoring** for SOC 2, PCI DSS, GDPR, and HIPAA frameworks
- **Respond effectively** to security incidents and vulnerability alerts
- **Automate security processes** using GitHub Actions and custom scripts
- **Generate comprehensive reports** for executive and compliance stakeholders

### Training Format

- **Duration**: 3 days (24 hours total)
- **Format**: Blended learning (instructor-led sessions + hands-on labs)
- **Class Size**: Maximum 12 participants
- **Prerequisites**: Basic GitHub knowledge, security fundamentals
- **Materials**: Access to GitHub organization, lab environment, documentation

### Target Audience

- **Security Engineers and Analysts**
- **DevOps and Platform Engineers**
- **Compliance and Risk Management Teams**
- **Development Team Leads**
- **IT Security Managers**

## Prerequisites

### Required Knowledge

- Basic understanding of Git and GitHub workflows
- Familiarity with software development lifecycle (SDLC)
- Understanding of common security vulnerabilities (OWASP Top 10)
- Basic knowledge of CI/CD pipelines
- Command line interface experience (CLI)

### Required Access

- GitHub organization with Advanced Security enabled
- Administrative access to configure security settings
- Access to SIEM systems (if applicable)
- Development environment for hands-on exercises

### Recommended Preparation

- Review GitHub Actions documentation
- Complete GitHub Fundamentals course
- Read OWASP Secure Coding Practices
- Familiarize with your organization's security policies

## Module 1: GitHub Advanced Security Fundamentals

### Learning Objectives

- Understand the GitHub Advanced Security platform architecture
- Configure organization-wide security settings
- Enable security features for repositories
- Establish security baselines and policies

### Topics Covered

#### 1.1 Platform Overview

**GitHub Advanced Security Components**
- CodeQL semantic code analysis
- Secret scanning and push protection
- Dependency vulnerability detection
- Security advisories and alerts
- Compliance and audit capabilities

**Architecture and Integration Points**
- GitHub Enterprise integration
- API endpoints and webhooks
- Third-party tool integrations
- Reporting and analytics capabilities

#### 1.2 Organization Configuration

**Security Settings Management**
```bash
# Enable organization-wide security features
curl -X PATCH \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/orgs/$ORG_NAME \
  -d '{
    "advanced_security_enabled_for_new_repositories": true,
    "secret_scanning_enabled_for_new_repositories": true,
    "secret_scanning_push_protection_enabled_for_new_repositories": true,
    "dependency_graph_enabled_for_new_repositories": true,
    "dependabot_alerts_enabled_for_new_repositories": true
  }'
```

**Two-Factor Authentication Policy**
- Enforcing 2FA across the organization
- Managing compliance and exceptions
- Monitoring authentication events

**Member Permissions and Access Control**
- Repository access management
- Security team permissions
- Audit log review processes

#### 1.3 Repository Security Configuration

**Branch Protection Rules**
- Required status checks configuration
- Code review requirements
- Admin enforcement policies
- Merge restrictions and controls

**Security and Analysis Features**
- Vulnerability alerts activation
- Dependabot security updates
- Code scanning setup
- Secret scanning configuration

### Hands-on Exercise 1.1: Organization Setup

**Scenario**: Configure a new GitHub organization for enterprise security.

**Tasks**:
1. Enable Advanced Security for the organization
2. Configure two-factor authentication requirements
3. Set up default security settings for new repositories
4. Create security team with appropriate permissions
5. Configure organization-wide branch protection policies

**Expected Outcome**: Fully configured organization ready for security scanning implementation.

## Module 2: CodeQL Security Analysis

### Learning Objectives

- Implement CodeQL scanning workflows
- Configure custom security queries
- Analyze and triage security findings
- Integrate CodeQL with CI/CD pipelines

### Topics Covered

#### 2.1 CodeQL Fundamentals

**Understanding CodeQL**
- Semantic code analysis principles
- Query language basics
- Supported programming languages
- Database generation and analysis

**CodeQL Query Structure**
```ql
import cpp

from Function f
where f.getName() = "strcpy"
select f, "Potentially unsafe function call"
```

#### 2.2 Workflow Implementation

**GitHub Actions CodeQL Workflow**
```yaml
name: "CodeQL Security Analysis"

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]
  schedule:
    - cron: '0 2 * * 1'  # Weekly scan

jobs:
  analyze:
    name: Analyze Code
    runs-on: ubuntu-latest
    permissions:
      actions: read
      contents: read
      security-events: write

    strategy:
      fail-fast: false
      matrix:
        language: [ 'javascript', 'python', 'java' ]

    steps:
    - name: Checkout repository
      uses: actions/checkout@v4

    - name: Initialize CodeQL
      uses: github/codeql-action/init@v3
      with:
        languages: ${{ matrix.language }}
        queries: security-extended,security-and-quality
        config-file: ./.github/codeql/codeql-config.yml

    - name: Autobuild
      uses: github/codeql-action/autobuild@v3

    - name: Perform CodeQL Analysis
      uses: github/codeql-action/analyze@v3
      with:
        category: "/language:${{matrix.language}}"
        upload: true
```

**Custom Configuration**
```yaml
# .github/codeql/codeql-config.yml
name: "Security Analysis Configuration"

queries:
  - uses: security-extended
  - uses: security-and-quality
  - ./custom-queries/security-patterns.ql

paths-ignore:
  - node_modules
  - dist
  - build
  - test/fixtures

paths:
  - src
  - lib
  - app
```

#### 2.3 Custom Query Development

**Creating Security-Specific Queries**
```ql
/**
 * @name Hard-coded credentials
 * @description Detect potential hard-coded credentials in source code
 * @kind problem
 * @problem.severity warning
 * @id custom/hardcoded-credentials
 */

import javascript

from StringLiteral s
where s.getValue().regexpMatch("(?i).*(password|token|key|secret).*=.*[\"'][^\"']{8,}[\"'].*")
select s, "Potential hard-coded credential detected"
```

#### 2.4 Results Analysis and Triage

**Security Alert Management**
- Alert classification and prioritization
- False positive identification
- Remediation tracking
- Team assignment and workflows

**Integration with Issue Tracking**
- Automatic issue creation
- Security label management
- Escalation procedures
- Resolution tracking

### Hands-on Exercise 2.1: CodeQL Implementation

**Scenario**: Implement comprehensive CodeQL scanning for a multi-language repository.

**Tasks**:
1. Create CodeQL workflow for JavaScript, Python, and Java
2. Configure custom security queries
3. Set up automated scanning schedule
4. Analyze sample security findings
5. Create remediation workflow

**Expected Outcome**: Functional CodeQL implementation with custom security queries and automated analysis.

## Module 3: Secret Scanning Implementation

### Learning Objectives

- Configure secret scanning across repositories
- Implement push protection policies
- Create custom secret patterns
- Establish secret remediation procedures

### Topics Covered

#### 3.1 Secret Scanning Configuration

**Repository-Level Configuration**
```python
#!/usr/bin/env python3
"""
GitHub Secret Scanning Configuration Script
Enables secret scanning with push protection across repositories
"""

import requests
import json

class SecretScanningManager:
    def __init__(self, token, org):
        self.token = token
        self.org = org
        self.headers = {
            'Authorization': f'token {token}',
            'Accept': 'application/vnd.github.v3+json'
        }
    
    def enable_secret_scanning(self, repo_name):
        """Enable secret scanning for a repository"""
        url = f'https://api.github.com/repos/{self.org}/{repo_name}/secret-scanning/alerts'
        
        try:
            response = requests.put(url, headers=self.headers)
            if response.status_code == 204:
                print(f"✓ Secret scanning enabled for {repo_name}")
            else:
                print(f"✗ Failed to enable secret scanning for {repo_name}")
        except Exception as e:
            print(f"Error enabling secret scanning: {e}")
    
    def enable_push_protection(self, repo_name):
        """Enable push protection for a repository"""
        url = f'https://api.github.com/repos/{self.org}/{repo_name}'
        data = {
            'secret_scanning_push_protection_enabled': True
        }
        
        try:
            response = requests.patch(url, headers=self.headers, json=data)
            if response.status_code == 200:
                print(f"✓ Push protection enabled for {repo_name}")
            else:
                print(f"✗ Failed to enable push protection for {repo_name}")
        except Exception as e:
            print(f"Error enabling push protection: {e}")
    
    def get_secret_alerts(self, repo_name):
        """Retrieve secret scanning alerts"""
        url = f'https://api.github.com/repos/{self.org}/{repo_name}/secret-scanning/alerts'
        
        try:
            response = requests.get(url, headers=self.headers)
            if response.status_code == 200:
                alerts = response.json()
                return alerts
            else:
                print(f"Failed to retrieve alerts for {repo_name}")
                return []
        except Exception as e:
            print(f"Error retrieving alerts: {e}")
            return []

# Usage example
manager = SecretScanningManager('your-token', 'your-org')
manager.enable_secret_scanning('repo-name')
manager.enable_push_protection('repo-name')
```

#### 3.2 Custom Secret Patterns

**Defining Custom Patterns**
```python
custom_patterns = [
    {
        "name": "Custom API Key Pattern",
        "pattern": r"(?i)(?:api[_-]?key|apikey)\s*[:=]\s*[\"']?([a-zA-Z0-9]{32,})[\"']?",
        "description": "Detects custom API key patterns"
    },
    {
        "name": "Database Connection String",
        "pattern": r"(?i)(?:database|db)[_-]?(?:url|connection|string)\s*[:=]\s*[\"']?([^\"'\s]+)[\"']?",
        "description": "Detects database connection strings"
    },
    {
        "name": "Private Key Pattern",
        "pattern": r"-----BEGIN\s+(?:RSA\s+|EC\s+|DSA\s+|OPENSSH\s+)?PRIVATE\s+KEY-----",
        "description": "Detects private key formats"
    }
]
```

#### 3.3 Alert Management and Remediation

**Automated Alert Processing**
```python
class SecretAlertManager:
    def __init__(self, token, org):
        self.token = token
        self.org = org
        self.headers = {
            'Authorization': f'token {token}',
            'Accept': 'application/vnd.github.v3+json'
        }
    
    def process_alerts(self, repo_name):
        """Process and categorize secret alerts"""
        alerts = self.get_secret_alerts(repo_name)
        
        for alert in alerts:
            severity = self.categorize_alert(alert)
            self.route_alert(alert, severity)
    
    def categorize_alert(self, alert):
        """Categorize alert based on secret type and location"""
        secret_type = alert.get('secret_type', '').lower()
        
        high_risk_patterns = [
            'aws_access_key_id',
            'private_key',
            'oauth_token',
            'database_password'
        ]
        
        if any(pattern in secret_type for pattern in high_risk_patterns):
            return 'critical'
        elif 'test' in alert.get('path', '').lower():
            return 'low'
        else:
            return 'medium'
    
    def route_alert(self, alert, severity):
        """Route alert based on severity"""
        if severity == 'critical':
            self.create_incident(alert)
            self.notify_security_team(alert)
        elif severity == 'medium':
            self.create_issue(alert)
        else:
            self.log_alert(alert)
```

#### 3.4 Remediation Workflows

**Secret Rotation Procedures**
1. **Immediate Actions**
   - Revoke exposed credential
   - Generate new credential
   - Update systems using the credential

2. **Code Remediation**
   - Remove secret from code history
   - Implement proper secret management
   - Add preventive controls

3. **Monitoring and Verification**
   - Verify secret rotation
   - Monitor for continued exposure
   - Update security documentation

### Hands-on Exercise 3.1: Secret Scanning Setup

**Scenario**: Implement comprehensive secret scanning with custom patterns and automated remediation.

**Tasks**:
1. Enable secret scanning across all repositories
2. Configure push protection policies
3. Create custom secret detection patterns
4. Implement alert processing workflow
5. Test secret detection and remediation

**Expected Outcome**: Comprehensive secret scanning implementation with automated detection, alerting, and remediation processes.

## Module 4: Dependency Vulnerability Management

### Learning Objectives

- Configure dependency vulnerability scanning
- Manage Dependabot alerts and updates
- Implement custom vulnerability analysis
- Establish dependency governance policies

### Topics Covered

#### 4.1 Dependency Scanning Setup

**Dependabot Configuration**
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
    commit-message:
      prefix: "security"
      include: "scope"
    
  - package-ecosystem: "pip"
    directory: "/python-app"
    schedule:
      interval: "daily"
    allow:
      - dependency-type: "direct"
      - dependency-type: "indirect"
        update-type: "security"
    
  - package-ecosystem: "docker"
    directory: "/docker"
    schedule:
      interval: "weekly"
    ignore:
      - dependency-name: "base-image"
        versions: ["< 2.0"]
```

#### 4.2 Custom Vulnerability Analysis

**Vulnerability Assessment Script**
```python
#!/usr/bin/env python3
"""
Advanced Dependency Vulnerability Scanner
Performs comprehensive dependency analysis beyond standard Dependabot
"""

import requests
import json
import subprocess
import sys
from packaging import version
import yaml

class DependencyScanner:
    def __init__(self, repo_path, github_token):
        self.repo_path = repo_path
        self.github_token = github_token
        self.vulnerabilities = []
        
    def scan_dependencies(self):
        """Main scanning function"""
        print("🔍 Starting comprehensive dependency vulnerability scan...")
        
        # Scan different package managers
        self.scan_npm_dependencies()
        self.scan_python_dependencies()
        self.scan_java_dependencies()
        self.scan_docker_dependencies()
        
        # Generate comprehensive report
        self.generate_vulnerability_report()
        
    def scan_npm_dependencies(self):
        """Scan npm dependencies for vulnerabilities"""
        try:
            # Run npm audit
            result = subprocess.run(
                ['npm', 'audit', '--json'],
                cwd=self.repo_path,
                capture_output=True,
                text=True
            )
            
            if result.stdout:
                audit_data = json.loads(result.stdout)
                self.process_npm_vulnerabilities(audit_data)
                
        except Exception as e:
            print(f"Error scanning npm dependencies: {e}")
    
    def scan_python_dependencies(self):
        """Scan Python dependencies using safety"""
        try:
            result = subprocess.run(
                ['safety', 'check', '--json'],
                cwd=self.repo_path,
                capture_output=True,
                text=True
            )
            
            if result.stdout:
                safety_data = json.loads(result.stdout)
                self.process_python_vulnerabilities(safety_data)
                
        except Exception as e:
            print(f"Error scanning Python dependencies: {e}")
    
    def process_npm_vulnerabilities(self, audit_data):
        """Process npm audit results"""
        if 'vulnerabilities' in audit_data:
            for package, vuln_info in audit_data['vulnerabilities'].items():
                vulnerability = {
                    'package_manager': 'npm',
                    'package_name': package,
                    'severity': vuln_info.get('severity', 'unknown'),
                    'vulnerable_versions': vuln_info.get('range', ''),
                    'patched_versions': vuln_info.get('fixAvailable', ''),
                    'description': vuln_info.get('title', ''),
                    'cve': vuln_info.get('cwe', []),
                    'recommendation': self.generate_recommendation(vuln_info)
                }
                self.vulnerabilities.append(vulnerability)
    
    def generate_recommendation(self, vuln_info):
        """Generate remediation recommendations"""
        if vuln_info.get('fixAvailable'):
            return f"Update to version {vuln_info['fixAvailable']}"
        elif vuln_info.get('severity') == 'critical':
            return "Immediate remediation required - consider alternative package"
        else:
            return "Monitor for updates and security patches"
    
    def generate_vulnerability_report(self):
        """Generate comprehensive vulnerability report"""
        report = {
            'scan_timestamp': datetime.utcnow().isoformat(),
            'repository': self.repo_path,
            'total_vulnerabilities': len(self.vulnerabilities),
            'severity_breakdown': self.calculate_severity_breakdown(),
            'vulnerabilities': self.vulnerabilities,
            'recommendations': self.generate_executive_summary()
        }
        
        # Save detailed report
        with open('vulnerability_report.json', 'w') as f:
            json.dump(report, f, indent=2)
        
        # Generate executive summary
        self.generate_executive_report(report)
    
    def calculate_severity_breakdown(self):
        """Calculate vulnerability severity distribution"""
        breakdown = {'critical': 0, 'high': 0, 'medium': 0, 'low': 0}
        
        for vuln in self.vulnerabilities:
            severity = vuln.get('severity', 'unknown').lower()
            if severity in breakdown:
                breakdown[severity] += 1
                
        return breakdown
    
    def generate_executive_summary(self):
        """Generate executive-level recommendations"""
        critical_count = sum(1 for v in self.vulnerabilities if v.get('severity') == 'critical')
        
        if critical_count > 0:
            return [
                "URGENT: Critical vulnerabilities detected requiring immediate attention",
                "Implement emergency patching procedures",
                "Consider temporary service restrictions if necessary"
            ]
        else:
            return [
                "Continue regular dependency maintenance",
                "Monitor for new vulnerability disclosures",
                "Maintain automated update processes"
            ]

# Usage
scanner = DependencyScanner('/path/to/repo', 'github-token')
scanner.scan_dependencies()
```

#### 4.3 Automated Update Management

**Dependabot PR Review Workflow**
```yaml
name: "Dependabot PR Review"

on:
  pull_request:
    branches: [ main ]

jobs:
  dependabot-review:
    runs-on: ubuntu-latest
    if: ${{ github.actor == 'dependabot[bot]' }}
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
    
    - name: Analyze dependency update
      id: analyze
      run: |
        # Extract package information from PR
        echo "package_name=$(echo '${{ github.event.pull_request.title }}' | grep -oP '(?<=Bump )\S+')" >> $GITHUB_OUTPUT
        echo "version_from=$(echo '${{ github.event.pull_request.title }}' | grep -oP '(?<=from )\S+')" >> $GITHUB_OUTPUT
        echo "version_to=$(echo '${{ github.event.pull_request.title }}' | grep -oP '(?<=to )\S+')" >> $GITHUB_OUTPUT
    
    - name: Security assessment
      run: |
        # Perform security assessment of the update
        npm audit --audit-level moderate
        
    - name: Run tests
      run: |
        npm test
        npm run security-test
    
    - name: Auto-approve low-risk updates
      if: ${{ steps.analyze.outputs.update_type == 'patch' }}
      run: |
        gh pr review --approve "$PR_URL"
        gh pr merge --auto --squash "$PR_URL"
      env:
        PR_URL: ${{ github.event.pull_request.html_url }}
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### Hands-on Exercise 4.1: Dependency Management

**Scenario**: Implement comprehensive dependency vulnerability management for a multi-language project.

**Tasks**:
1. Configure Dependabot for npm, pip, and Docker
2. Implement custom vulnerability scanning
3. Create automated PR review workflow
4. Set up vulnerability alert routing
5. Test dependency update processes

**Expected Outcome**: Comprehensive dependency management system with automated updates, security assessment, and vulnerability tracking.

## Module 5: SIEM Integration and Monitoring

### Learning Objectives

- Integrate GitHub security events with enterprise SIEM systems
- Configure automated event forwarding
- Implement custom monitoring dashboards
- Establish alerting and escalation procedures

### Topics Covered

#### 5.1 SIEM Architecture and Integration

**Integration Architecture Overview**
```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   GitHub        │    │   Integration    │    │   SIEM System   │
│   Advanced      │───▶│   Layer          │───▶│   (Splunk/      │
│   Security      │    │   (Webhook/API)  │    │   Sentinel)     │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                       │                       │
         │              ┌─────────────────┐              │
         │              │   Enrichment    │              │
         └─────────────▶│   & Processing  │◀─────────────┘
                        └─────────────────┘
```

#### 5.2 Splunk Integration

**Splunk HTTP Event Collector Setup**
```python
#!/usr/bin/env python3
"""
GitHub Security Events to Splunk Forwarder
Real-time forwarding of GitHub security events to Splunk
"""

import requests
import json
import hmac
import hashlib
from datetime import datetime
import logging

class SplunkForwarder:
    def __init__(self, splunk_host, hec_token, verify_ssl=True):
        self.splunk_host = splunk_host
        self.hec_token = hec_token
        self.verify_ssl = verify_ssl
        self.hec_url = f"{splunk_host}/services/collector/event"
        
        # Configure logging
        logging.basicConfig(level=logging.INFO)
        self.logger = logging.getLogger(__name__)
    
    def forward_security_alert(self, alert_data, source_repo):
        """Forward GitHub security alert to Splunk"""
        
        # Enrich alert with additional context
        enriched_event = self.enrich_security_alert(alert_data, source_repo)
        
        # Prepare Splunk event
        splunk_event = {
            "time": int(datetime.utcnow().timestamp()),
            "source": "github_advanced_security",
            "sourcetype": "github:security:alert",
            "host": source_repo,
            "index": "security",
            "event": enriched_event
        }
        
        # Send to Splunk
        return self.send_to_splunk(splunk_event)
    
    def enrich_security_alert(self, alert_data, source_repo):
        """Enrich security alert with additional context"""
        
        # Extract key information
        alert_type = alert_data.get('action', 'unknown')
        severity = self.calculate_severity(alert_data)
        
        enriched_data = {
            "github_org": alert_data.get('organization', {}).get('login', ''),
            "repository": source_repo,
            "alert_type": alert_type,
            "severity": severity,
            "alert_id": alert_data.get('alert', {}).get('id', ''),
            "created_at": alert_data.get('alert', {}).get('created_at', ''),
            "updated_at": alert_data.get('alert', {}).get('updated_at', ''),
            "state": alert_data.get('alert', {}).get('state', ''),
            "vulnerability_details": self.extract_vulnerability_details(alert_data),
            "affected_files": self.extract_affected_files(alert_data),
            "remediation_guidance": self.generate_remediation_guidance(alert_data),
            "compliance_impact": self.assess_compliance_impact(alert_data),
            "raw_alert": alert_data
        }
        
        return enriched_data
    
    def calculate_severity(self, alert_data):
        """Calculate normalized severity score"""
        
        severity_mapping = {
            'critical': 4,
            'high': 3,
            'medium': 2,
            'low': 1,
            'unknown': 0
        }
        
        github_severity = alert_data.get('alert', {}).get('severity', 'unknown').lower()
        return severity_mapping.get(github_severity, 0)
    
    def send_to_splunk(self, event_data):
        """Send event to Splunk HEC"""
        
        headers = {
            'Authorization': f'Splunk {self.hec_token}',
            'Content-Type': 'application/json'
        }
        
        try:
            response = requests.post(
                self.hec_url,
                headers=headers,
                data=json.dumps(event_data),
                verify=self.verify_ssl,
                timeout=30
            )
            
            if response.status_code == 200:
                self.logger.info(f"Successfully forwarded event to Splunk: {event_data['event']['alert_id']}")
                return True
            else:
                self.logger.error(f"Failed to forward to Splunk: {response.status_code} - {response.text}")
                return False
                
        except Exception as e:
            self.logger.error(f"Error forwarding to Splunk: {str(e)}")
            return False

# Webhook handler for real-time forwarding
class GitHubWebhookHandler:
    def __init__(self, webhook_secret, splunk_forwarder):
        self.webhook_secret = webhook_secret
        self.splunk_forwarder = splunk_forwarder
        self.logger = logging.getLogger(__name__)
    
    def verify_webhook_signature(self, payload, signature):
        """Verify GitHub webhook signature"""
        expected_signature = hmac.new(
            self.webhook_secret.encode('utf-8'),
            payload,
            hashlib.sha256
        ).hexdigest()
        
        return hmac.compare_digest(f"sha256={expected_signature}", signature)
    
    def handle_webhook(self, request_headers, request_body):
        """Handle incoming GitHub webhook"""
        
        # Verify signature
        signature = request_headers.get('X-Hub-Signature-256', '')
        if not self.verify_webhook_signature(request_body, signature):
            self.logger.warning("Invalid webhook signature")
            return False
        
        # Parse payload
        try:
            payload = json.loads(request_body)
        except json.JSONDecodeError:
            self.logger.error("Invalid JSON payload")
            return False
        
        # Process security events
        event_type = request_headers.get('X-GitHub-Event', '')
        
        if event_type in ['security_advisory', 'secret_scanning_alert', 'code_scanning_alert']:
            repository = payload.get('repository', {}).get('full_name', '')
            self.splunk_forwarder.forward_security_alert(payload, repository)
            return True
        
        return False

# Usage example
splunk_forwarder = SplunkForwarder(
    splunk_host="https://splunk.company.com:8088",
    hec_token="your-hec-token"
)

webhook_handler = GitHubWebhookHandler(
    webhook_secret="your-webhook-secret",
    splunk_forwarder=splunk_forwarder
)
```

#### 5.3 Azure Sentinel Integration

**Log Analytics Workspace Integration**
```python
import requests
import json
import hmac
import hashlib
import base64
from datetime import datetime

class AzureSentinelForwarder:
    def __init__(self, workspace_id, shared_key):
        self.workspace_id = workspace_id
        self.shared_key = shared_key
        self.log_type = "GitHubSecurity"
        
    def forward_security_events(self, events):
        """Forward GitHub security events to Azure Sentinel"""
        
        # Prepare events for Log Analytics
        log_data = []
        for event in events:
            processed_event = self.process_event(event)
            log_data.append(processed_event)
        
        # Send to Log Analytics
        return self.post_data(json.dumps(log_data))
    
    def process_event(self, event):
        """Process individual security event"""
        return {
            "TimeGenerated": datetime.utcnow().isoformat() + "Z",
            "Organization": event.get('organization', {}).get('login', ''),
            "Repository": event.get('repository', {}).get('full_name', ''),
            "AlertType": event.get('action', ''),
            "Severity": event.get('alert', {}).get('severity', ''),
            "AlertId": event.get('alert', {}).get('id', ''),
            "State": event.get('alert', {}).get('state', ''),
            "CreatedAt": event.get('alert', {}).get('created_at', ''),
            "UpdatedAt": event.get('alert', {}).get('updated_at', ''),
            "RawEvent": json.dumps(event)
        }
    
    def build_signature(self, date, content_length, method, content_type, resource):
        """Build authorization signature for Log Analytics"""
        
        x_headers = 'x-ms-date:' + date
        string_to_hash = method + "\n" + str(content_length) + "\n" + content_type + "\n" + x_headers + "\n" + resource
        bytes_to_hash = bytes(string_to_hash, 'UTF-8')
        decoded_key = base64.b64decode(self.shared_key)
        encoded_hash = base64.b64encode(hmac.new(decoded_key, bytes_to_hash, digestmod=hashlib.sha256).digest()).decode()
        authorization = "SharedKey {}:{}".format(self.workspace_id, encoded_hash)
        
        return authorization
    
    def post_data(self, body):
        """POST data to Log Analytics workspace"""
        
        method = 'POST'
        content_type = 'application/json'
        resource = '/api/logs'
        rfc1123date = datetime.utcnow().strftime('%a, %d %b %Y %H:%M:%S GMT')
        content_length = len(body)
        
        signature = self.build_signature(rfc1123date, content_length, method, content_type, resource)
        
        uri = f'https://{self.workspace_id}.ods.opinsights.azure.com{resource}?api-version=2016-04-01'
        
        headers = {
            'content-type': content_type,
            'Authorization': signature,
            'Log-Type': self.log_type,
            'x-ms-date': rfc1123date
        }
        
        try:
            response = requests.post(uri, data=body, headers=headers)
            if 200 <= response.status_code <= 299:
                print(f"Successfully forwarded {len(json.loads(body))} events to Azure Sentinel")
                return True
            else:
                print(f"Failed to forward to Azure Sentinel: {response.status_code}")
                return False
        except Exception as e:
            print(f"Error forwarding to Azure Sentinel: {str(e)}")
            return False
```

### Hands-on Exercise 5.1: SIEM Integration

**Scenario**: Implement real-time security event forwarding to Splunk and Azure Sentinel.

**Tasks**:
1. Configure webhook endpoints for security events
2. Implement Splunk HEC integration
3. Set up Azure Sentinel Log Analytics forwarding
4. Create event enrichment and processing
5. Test end-to-end event flow

**Expected Outcome**: Real-time security event forwarding to enterprise SIEM systems with enriched context and automated processing.

## Module 6: Compliance and Audit Management

### Learning Objectives

- Implement compliance monitoring for multiple frameworks
- Generate automated compliance reports
- Establish audit trails and documentation
- Create executive dashboards and metrics

### Topics Covered

#### 6.1 Compliance Framework Implementation

**Multi-Framework Compliance Monitoring**
```python
#!/usr/bin/env python3
"""
GitHub Security Compliance Monitor
Comprehensive compliance monitoring for SOC 2, PCI DSS, GDPR, and HIPAA
"""

import requests
import json
from datetime import datetime, timedelta
import pandas as pd
from typing import Dict, List, Any

class ComplianceMonitor:
    def __init__(self, github_token: str, organization: str):
        self.github_token = github_token
        self.organization = organization
        self.headers = {
            'Authorization': f'token {github_token}',
            'Accept': 'application/vnd.github.v3+json'
        }
        
        # Define compliance requirements
        self.compliance_requirements = {
            'SOC2': {
                'access_control': ['2fa_required', 'admin_approval', 'audit_logs'],
                'system_monitoring': ['vulnerability_scanning', 'incident_response'],
                'data_protection': ['encryption_at_rest', 'encryption_in_transit'],
                'availability': ['backup_procedures', 'disaster_recovery']
            },
            'PCI_DSS': {
                'secure_development': ['code_review', 'vulnerability_testing'],
                'access_control': ['2fa_required', 'least_privilege'],
                'monitoring': ['audit_logs', 'security_monitoring'],
                'data_protection': ['encryption_requirements', 'secure_storage']
            },
            'GDPR': {
                'data_protection': ['privacy_by_design', 'data_encryption'],
                'access_rights': ['data_access_controls', 'user_consent'],
                'incident_response': ['breach_notification', 'impact_assessment'],
                'documentation': ['privacy_policies', 'processing_records']
            },
            'HIPAA': {
                'access_control': ['user_authentication', 'access_logs'],
                'audit_controls': ['activity_monitoring', 'audit_trails'],
                'integrity': ['data_integrity', 'transmission_security'],
                'transmission_security': ['end_to_end_encryption', 'secure_channels']
            }
        }
    
    def assess_organization_compliance(self) -> Dict[str, Any]:
        """Assess organization-level compliance across all frameworks"""
        
        print("🔍 Starting comprehensive compliance assessment...")
        
        # Gather organization data
        org_data = self.get_organization_data()
        repo_data = self.get_repositories_data()
        security_data = self.get_security_configuration()
        
        # Assess each compliance framework
        compliance_results = {}
        
        for framework in self.compliance_requirements.keys():
            compliance_results[framework] = self.assess_framework_compliance(
                framework, org_data, repo_data, security_data
            )
        
        # Generate comprehensive report
        return self.generate_compliance_report(compliance_results)
    
    def assess_framework_compliance(self, framework: str, org_data: Dict, 
                                   repo_data: List, security_data: Dict) -> Dict:
        """Assess compliance for a specific framework"""
        
        requirements = self.compliance_requirements[framework]
        results = {
            'framework': framework,
            'assessment_date': datetime.utcnow().isoformat(),
            'overall_score': 0,
            'category_scores': {},
            'findings': [],
            'recommendations': []
        }
        
        total_checks = 0
        passed_checks = 0
        
        for category, checks in requirements.items():
            category_score = 0
            category_total = len(checks)
            
            for check in checks:
                if self.evaluate_compliance_check(check, org_data, repo_data, security_data):
                    category_score += 1
                    passed_checks += 1
                else:
                    results['findings'].append({
                        'category': category,
                        'check': check,
                        'status': 'non-compliant',
                        'description': self.get_check_description(check)
                    })
                
                total_checks += 1
            
            results['category_scores'][category] = {
                'score': category_score,
                'total': category_total,
                'percentage': (category_score / category_total) * 100
            }
        
        results['overall_score'] = (passed_checks / total_checks) * 100 if total_checks > 0 else 0
        results['recommendations'] = self.generate_recommendations(framework, results['findings'])
        
        return results
    
    def evaluate_compliance_check(self, check: str, org_data: Dict, 
                                 repo_data: List, security_data: Dict) -> bool:
        """Evaluate individual compliance check"""
        
        check_functions = {
            '2fa_required': lambda: org_data.get('two_factor_requirement_enabled', False),
            'admin_approval': lambda: self.check_admin_approval_policies(repo_data),
            'audit_logs': lambda: self.check_audit_logging(org_data),
            'vulnerability_scanning': lambda: security_data.get('vulnerability_scanning_enabled', False),
            'code_review': lambda: self.check_code_review_requirements(repo_data),
            'encryption_at_rest': lambda: self.check_encryption_settings(security_data),
            'backup_procedures': lambda: self.check_backup_configuration(org_data),
            # Add more check functions as needed
        }
        
        check_function = check_functions.get(check)
        if check_function:
            try:
                return check_function()
            except Exception as e:
                print(f"Error evaluating check {check}: {str(e)}")
                return False
        
        # Default to non-compliant if check not implemented
        return False
    
    def generate_compliance_report(self, compliance_results: Dict) -> Dict:
        """Generate comprehensive compliance report"""
        
        report = {
            'report_metadata': {
                'organization': self.organization,
                'generated_at': datetime.utcnow().isoformat(),
                'report_version': '2.0',
                'scope': 'GitHub Advanced Security Platform'
            },
            'executive_summary': self.generate_executive_summary(compliance_results),
            'framework_assessments': compliance_results,
            'consolidated_findings': self.consolidate_findings(compliance_results),
            'action_plan': self.generate_action_plan(compliance_results),
            'metrics': self.calculate_compliance_metrics(compliance_results)
        }
        
        # Save report
        self.save_compliance_report(report)
        
        return report
    
    def generate_executive_summary(self, compliance_results: Dict) -> Dict:
        """Generate executive summary of compliance status"""
        
        summary = {
            'overall_compliance_score': 0,
            'framework_scores': {},
            'critical_findings': 0,
            'total_findings': 0,
            'improvement_trend': self.calculate_improvement_trend(),
            'key_recommendations': []
        }
        
        total_score = 0
        framework_count = len(compliance_results)
        
        for framework, results in compliance_results.items():
            score = results['overall_score']
            summary['framework_scores'][framework] = score
            total_score += score
            
            # Count findings
            critical_findings = len([f for f in results['findings'] 
                                   if self.is_critical_finding(f)])
            summary['critical_findings'] += critical_findings
            summary['total_findings'] += len(results['findings'])
            
            # Collect top recommendations
            if results['recommendations'][:2]:  # Top 2 recommendations per framework
                summary['key_recommendations'].extend(results['recommendations'][:2])
        
        summary['overall_compliance_score'] = total_score / framework_count if framework_count > 0 else 0
        
        return summary

    def save_compliance_report(self, report: Dict):
        """Save compliance report to file"""
        
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        filename = f'compliance_report_{self.organization}_{timestamp}.json'
        
        with open(filename, 'w') as f:
            json.dump(report, f, indent=2)
        
        print(f"📊 Compliance report saved: {filename}")
        
        # Generate Excel report for executives
        self.generate_excel_report(report, f'compliance_report_{self.organization}_{timestamp}.xlsx')

    def generate_excel_report(self, report: Dict, filename: str):
        """Generate Excel compliance report for executives"""
        
        with pd.ExcelWriter(filename, engine='openpyxl') as writer:
            # Executive Summary
            exec_summary = pd.DataFrame([report['executive_summary']])
            exec_summary.to_excel(writer, sheet_name='Executive Summary', index=False)
            
            # Framework Scores
            framework_data = []
            for framework, results in report['framework_assessments'].items():
                framework_data.append({
                    'Framework': framework,
                    'Overall Score': f"{results['overall_score']:.1f}%",
                    'Total Findings': len(results['findings']),
                    'Status': 'Compliant' if results['overall_score'] >= 80 else 'Non-Compliant'
                })
            
            framework_df = pd.DataFrame(framework_data)
            framework_df.to_excel(writer, sheet_name='Framework Scores', index=False)
            
            # Detailed Findings
            findings_data = []
            for framework, results in report['framework_assessments'].items():
                for finding in results['findings']:
                    findings_data.append({
                        'Framework': framework,
                        'Category': finding['category'],
                        'Check': finding['check'],
                        'Status': finding['status'],
                        'Description': finding['description']
                    })
            
            if findings_data:
                findings_df = pd.DataFrame(findings_data)
                findings_df.to_excel(writer, sheet_name='Detailed Findings', index=False)
        
        print(f"📈 Excel report generated: {filename}")

# Usage example
monitor = ComplianceMonitor('your-github-token', 'your-organization')
compliance_report = monitor.assess_organization_compliance()
```

### Hands-on Exercise 6.1: Compliance Monitoring

**Scenario**: Implement comprehensive compliance monitoring for SOC 2, PCI DSS, GDPR, and HIPAA frameworks.

**Tasks**:
1. Configure compliance assessment framework
2. Implement automated compliance checking
3. Generate executive compliance reports
4. Set up compliance dashboard and metrics
5. Create compliance alert and notification system

**Expected Outcome**: Comprehensive compliance monitoring system with automated assessment, reporting, and executive dashboards.

## Module 7: Incident Response Procedures

### Learning Objectives

- Establish security incident response procedures
- Implement automated incident detection and classification
- Create escalation workflows and communication plans
- Develop post-incident analysis and improvement processes

### Topics Covered

#### 7.1 Incident Response Framework

**Incident Response Lifecycle**
```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Preparation   │    │    Detection     │    │  Containment    │
│   - Policies    │───▶│   - Monitoring   │───▶│  - Isolation    │
│   - Training    │    │   - Analysis     │    │  - Mitigation   │
│   - Tools       │    │   - Validation   │    │  - Evidence     │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         ▲                       ▲                       │
         │               ┌───────────────┐               │
         │               │   Recovery    │               │
         └───────────────│  - Restoration│◀──────────────┘
                         │  - Validation │
                         │  - Monitoring │
                         └───────────────┘
                                 │
                         ┌───────────────┐
                         │ Post-Incident │
                         │  - Analysis   │
                         │  - Lessons    │
                         │  - Updates    │
                         └───────────────┘
```

#### 7.2 Automated Incident Detection

**Security Incident Detector**
```python
#!/usr/bin/env python3
"""
GitHub Security Incident Detection and Response System
Automated detection, classification, and response to security incidents
"""

import requests
import json
from datetime import datetime, timedelta
from enum import Enum
from dataclasses import dataclass
from typing import List, Dict, Optional
import smtplib
from email.mime.text import MimeText
from email.mime.multipart import MimeMultipart

class IncidentSeverity(Enum):
    CRITICAL = "critical"
    HIGH = "high"
    MEDIUM = "medium"
    LOW = "low"

class IncidentType(Enum):
    CODE_VULNERABILITY = "code_vulnerability"
    SECRET_EXPOSURE = "secret_exposure"
    DEPENDENCY_VULNERABILITY = "dependency_vulnerability"
    POLICY_VIOLATION = "policy_violation"
    UNAUTHORIZED_ACCESS = "unauthorized_access"

@dataclass
class SecurityIncident:
    incident_id: str
    incident_type: IncidentType
    severity: IncidentSeverity
    title: str
    description: str
    affected_repositories: List[str]
    detection_time: datetime
    status: str = "open"
    assigned_team: Optional[str] = None
    escalation_level: int = 1
    raw_alert_data: Optional[Dict] = None

class IncidentDetector:
    def __init__(self, github_token: str, organization: str):
        self.github_token = github_token
        self.organization = organization
        self.headers = {
            'Authorization': f'token {github_token}',
            'Accept': 'application/vnd.github.v3+json'
        }
        self.incidents: List[SecurityIncident] = []
        
        # Define severity thresholds and rules
        self.severity_rules = {
            'secret_scanning': {
                'critical': ['private_key', 'oauth_token', 'database_password'],
                'high': ['api_key', 'access_token'],
                'medium': ['webhook_secret', 'signing_key'],
                'low': ['test_token', 'placeholder']
            },
            'code_scanning': {
                'critical': ['sql_injection', 'command_injection', 'path_traversal'],
                'high': ['xss', 'csrf', 'insecure_deserialization'],
                'medium': ['weak_cryptography', 'information_disclosure'],
                'low': ['code_quality', 'maintainability']
            },
            'dependency_scanning': {
                'critical': ['remote_code_execution', 'privilege_escalation'],
                'high': ['authentication_bypass', 'data_exposure'],
                'medium': ['denial_of_service', 'information_disclosure'],
                'low': ['deprecated_function', 'version_warning']
            }
        }
    
    def detect_incidents(self) -> List[SecurityIncident]:
        """Main incident detection function"""
        
        print("🔍 Starting security incident detection...")
        
        # Collect security alerts from various sources
        secret_alerts = self.get_secret_scanning_alerts()
        code_alerts = self.get_code_scanning_alerts()
        dependency_alerts = self.get_dependency_alerts()
        
        # Process and classify alerts
        for alert in secret_alerts:
            incident = self.process_secret_alert(alert)
            if incident:
                self.incidents.append(incident)
        
        for alert in code_alerts:
            incident = self.process_code_alert(alert)
            if incident:
                self.incidents.append(incident)
        
        for alert in dependency_alerts:
            incident = self.process_dependency_alert(alert)
            if incident:
                self.incidents.append(incident)
        
        # Apply incident correlation and deduplication
        self.correlate_incidents()
        
        print(f"📊 Detected {len(self.incidents)} security incidents")
        return self.incidents
    
    def process_secret_alert(self, alert: Dict) -> Optional[SecurityIncident]:
        """Process secret scanning alert and create incident"""
        
        secret_type = alert.get('secret_type', '').lower()
        repository = alert.get('repository', {}).get('full_name', '')
        
        # Determine severity based on secret type
        severity = self.determine_secret_severity(secret_type)
        
        # Skip low-severity secrets in test files
        if severity == IncidentSeverity.LOW and 'test' in alert.get('path', '').lower():
            return None
        
        incident = SecurityIncident(
            incident_id=f"SECRET-{alert.get('number', 'UNKNOWN')}-{int(datetime.utcnow().timestamp())}",
            incident_type=IncidentType.SECRET_EXPOSURE,
            severity=severity,
            title=f"Secret exposure detected: {secret_type}",
            description=f"Secret of type '{secret_type}' detected in {repository} at {alert.get('path', 'unknown path')}",
            affected_repositories=[repository],
            detection_time=datetime.utcnow(),
            raw_alert_data=alert
        )
        
        return incident
    
    def determine_secret_severity(self, secret_type: str) -> IncidentSeverity:
        """Determine severity based on secret type"""
        
        for severity_level, secret_types in self.severity_rules['secret_scanning'].items():
            if any(s_type in secret_type for s_type in secret_types):
                return IncidentSeverity(severity_level)
        
        return IncidentSeverity.MEDIUM  # Default severity
    
    def correlate_incidents(self):
        """Correlate related incidents and reduce noise"""
        
        # Group incidents by repository and type
        incident_groups = {}
        
        for incident in self.incidents:
            for repo in incident.affected_repositories:
                key = f"{repo}:{incident.incident_type.value}"
                if key not in incident_groups:
                    incident_groups[key] = []
                incident_groups[key].append(incident)
        
        # Merge similar incidents
        correlated_incidents = []
        
        for group_incidents in incident_groups.values():
            if len(group_incidents) > 1:
                # Create consolidated incident
                primary_incident = max(group_incidents, key=lambda x: x.severity.value)
                primary_incident.title = f"Multiple {primary_incident.incident_type.value} issues detected"
                primary_incident.description += f" (Consolidated from {len(group_incidents)} alerts)"
                correlated_incidents.append(primary_incident)
            else:
                correlated_incidents.extend(group_incidents)
        
        self.incidents = correlated_incidents

class IncidentResponseManager:
    def __init__(self, detector: IncidentDetector, config: Dict):
        self.detector = detector
        self.config = config
        self.response_teams = {
            IncidentSeverity.CRITICAL: "security-team-critical",
            IncidentSeverity.HIGH: "security-team-high",
            IncidentSeverity.MEDIUM: "security-team-medium",
            IncidentSeverity.LOW: "security-team-low"
        }
    
    def respond_to_incidents(self, incidents: List[SecurityIncident]):
        """Orchestrate incident response for all incidents"""
        
        for incident in incidents:
            print(f"🚨 Responding to incident: {incident.incident_id}")
            
            # Classify and assign
            self.classify_and_assign(incident)
            
            # Execute response based on severity
            if incident.severity == IncidentSeverity.CRITICAL:
                self.handle_critical_incident(incident)
            elif incident.severity == IncidentSeverity.HIGH:
                self.handle_high_incident(incident)
            else:
                self.handle_standard_incident(incident)
            
            # Create incident ticket
            self.create_incident_ticket(incident)
            
            # Log incident
            self.log_incident(incident)
    
    def handle_critical_incident(self, incident: SecurityIncident):
        """Handle critical security incidents"""
        
        print(f"🔥 CRITICAL INCIDENT: {incident.title}")
        
        # Immediate actions
        self.send_immediate_notification(incident)
        self.escalate_to_management(incident)
        
        # If secret exposure, attempt automatic remediation
        if incident.incident_type == IncidentType.SECRET_EXPOSURE:
            self.initiate_secret_rotation(incident)
        
        # If code vulnerability, create emergency fix branch
        if incident.incident_type == IncidentType.CODE_VULNERABILITY:
            self.create_emergency_fix_branch(incident)
    
    def send_immediate_notification(self, incident: SecurityIncident):
        """Send immediate notification for critical incidents"""
        
        # Email notification
        self.send_email_notification(incident, urgent=True)
        
        # Slack notification
        self.send_slack_notification(incident, urgent=True)
        
        # SMS notification for critical incidents
        if incident.severity == IncidentSeverity.CRITICAL:
            self.send_sms_notification(incident)
    
    def create_incident_ticket(self, incident: SecurityIncident):
        """Create incident tracking ticket"""
        
        ticket_data = {
            "title": f"[SECURITY] {incident.title}",
            "body": self.format_incident_description(incident),
            "labels": [
                "security",
                f"severity-{incident.severity.value}",
                f"type-{incident.incident_type.value}"
            ],
            "assignees": [self.response_teams[incident.severity]]
        }
        
        # Create GitHub issue for incident tracking
        for repo in incident.affected_repositories:
            self.create_github_issue(repo, ticket_data)
    
    def format_incident_description(self, incident: SecurityIncident) -> str:
        """Format incident description for ticket creation"""
        
        description = f"""
## Security Incident Report

**Incident ID**: {incident.incident_id}
**Detection Time**: {incident.detection_time.isoformat()}
**Severity**: {incident.severity.value.upper()}
**Type**: {incident.incident_type.value.replace('_', ' ').title()}

### Description
{incident.description}

### Affected Repositories
{chr(10).join(f"- {repo}" for repo in incident.affected_repositories)}

### Response Actions
- [ ] Investigate and confirm the security issue
- [ ] Assess impact and affected systems
- [ ] Implement containment measures
- [ ] Develop and apply remediation
- [ ] Verify resolution and test
- [ ] Document lessons learned

### Timeline
- **Detection**: {incident.detection_time.isoformat()}
- **Assignment**: {datetime.utcnow().isoformat()}
- **Target Resolution**: {(datetime.utcnow() + timedelta(hours=self.get_sla_hours(incident.severity))).isoformat()}

### Contact Information
- **Assigned Team**: {incident.assigned_team}
- **Escalation Contact**: security-manager@company.com
- **24/7 Security Hotline**: +1-555-SECURITY

---
*This incident was automatically detected and created by GitHub Advanced Security Platform*
        """
        
        return description.strip()
    
    def get_sla_hours(self, severity: IncidentSeverity) -> int:
        """Get SLA resolution time in hours"""
        sla_hours = {
            IncidentSeverity.CRITICAL: 4,
            IncidentSeverity.HIGH: 24,
            IncidentSeverity.MEDIUM: 72,
            IncidentSeverity.LOW: 168
        }
        return sla_hours.get(severity, 72)

# Usage example
detector = IncidentDetector('your-github-token', 'your-organization')
response_manager = IncidentResponseManager(detector, {
    'email_smtp_server': 'smtp.company.com',
    'slack_webhook_url': 'https://hooks.slack.com/...',
    'sms_service_url': 'https://sms-api.company.com'
})

# Detect and respond to incidents
incidents = detector.detect_incidents()
response_manager.respond_to_incidents(incidents)
```

### Hands-on Exercise 7.1: Incident Response Implementation

**Scenario**: Implement automated incident detection and response system for security events.

**Tasks**:
1. Configure incident detection and classification
2. Implement automated response workflows
3. Set up escalation and notification procedures
4. Create incident tracking and documentation
5. Test incident response procedures

**Expected Outcome**: Comprehensive incident response system with automated detection, classification, response, and tracking capabilities.

## Module 8: Advanced Configuration and Automation

### Learning Objectives

- Implement advanced GitHub Actions workflows for security automation
- Configure custom security policies and governance
- Develop comprehensive monitoring and alerting systems
- Create executive reporting and analytics dashboards

### Topics Covered

#### 8.1 Advanced GitHub Actions Security Workflows

**Comprehensive Security Automation Pipeline**
```yaml
name: "Advanced Security Pipeline"

on:
  push:
    branches: [ main, develop, release/* ]
  pull_request:
    branches: [ main, develop ]
  schedule:
    - cron: '0 2 * * *'  # Daily security scan
  workflow_dispatch:
    inputs:
      scan_type:
        description: 'Type of security scan'
        required: true
        default: 'full'
        type: choice
        options:
        - full
        - quick
        - compliance
      target_branch:
        description: 'Target branch for scanning'
        required: false
        default: 'main'

env:
  SECURITY_SCAN_TIMEOUT: 1800
  COMPLIANCE_FRAMEWORKS: "SOC2,PCI-DSS,GDPR,HIPAA"

jobs:
  security-analysis:
    runs-on: ubuntu-latest
    permissions:
      actions: read
      contents: read
      security-events: write
      issues: write
      pull-requests: write

    strategy:
      fail-fast: false
      matrix:
        analysis-type: [
          'codeql',
          'secret-scanning',
          'dependency-scanning',
          'container-scanning',
          'iac-scanning',
          'compliance-check'
        ]

    steps:
    - name: Checkout repository
      uses: actions/checkout@v4
      with:
        fetch-depth: 0
        token: ${{ secrets.GITHUB_TOKEN }}

    - name: Setup security scanning environment
      run: |
        echo "Setting up security scanning environment..."
        echo "SCAN_ID=scan-$(date +%Y%m%d-%H%M%S)-${{ github.run_id }}" >> $GITHUB_ENV
        echo "SCAN_TYPE=${{ github.event.inputs.scan_type || 'full' }}" >> $GITHUB_ENV
        
    - name: CodeQL Security Analysis
      if: matrix.analysis-type == 'codeql'
      uses: ./.github/actions/advanced-codeql
      with:
        languages: 'javascript,python,java,csharp,cpp,go'
        queries: 'security-extended,security-and-quality'
        config-file: '.github/codeql/advanced-config.yml'
        custom-queries-path: '.github/codeql/custom-queries'
        
    - name: Advanced Secret Scanning
      if: matrix.analysis-type == 'secret-scanning'
      uses: ./.github/actions/advanced-secret-scan
      with:
        custom-patterns: '.github/security/secret-patterns.yml'
        exclude-paths: '.github/security/secret-scan-exclusions.yml'
        notification-webhook: ${{ secrets.SECURITY_WEBHOOK_URL }}
        
    - name: Comprehensive Dependency Scanning
      if: matrix.analysis-type == 'dependency-scanning'
      uses: ./.github/actions/comprehensive-dependency-scan
      with:
        package-managers: 'npm,pip,maven,gradle,nuget,composer'
        vulnerability-db: 'github,snyk,osv'
        risk-threshold: 'medium'
        auto-fix: 'patch-only'
        
    - name: Container Security Scanning
      if: matrix.analysis-type == 'container-scanning'
      uses: ./.github/actions/container-security-scan
      with:
        dockerfile-paths: './docker,./containers'
        image-registries: 'docker.io,ghcr.io'
        security-policies: '.github/security/container-policies.yml'
        
    - name: Infrastructure as Code Scanning
      if: matrix.analysis-type == 'iac-scanning'
      uses: ./.github/actions/iac-security-scan
      with:
        terraform-paths: './terraform,./infra'
        kubernetes-paths: './k8s,./kubernetes'
        cloud-providers: 'aws,azure,gcp'
        compliance-frameworks: ${{ env.COMPLIANCE_FRAMEWORKS }}
        
    - name: Compliance Validation
      if: matrix.analysis-type == 'compliance-check'
      uses: ./.github/actions/compliance-validator
      with:
        frameworks: ${{ env.COMPLIANCE_FRAMEWORKS }}
        policy-path: '.github/security/compliance-policies'
        evidence-collection: true
        
    - name: Security Results Processing
      uses: ./.github/actions/security-results-processor
      with:
        scan-id: ${{ env.SCAN_ID }}
        analysis-type: ${{ matrix.analysis-type }}
        result-format: 'sarif,json,html'
        upload-artifacts: true
        
    - name: Security Alert Management
      if: failure() || success()
      uses: ./.github/actions/security-alert-manager
      with:
        webhook-url: ${{ secrets.SECURITY_WEBHOOK_URL }}
        slack-channel: '#security-alerts'
        email-recipients: 'security-team@company.com'
        create-issues: true
        
  security-reporting:
    needs: security-analysis
    runs-on: ubuntu-latest
    if: always()
    
    steps:
    - name: Generate Security Dashboard
      uses: ./.github/actions/security-dashboard-generator
      with:
        scan-results: ${{ needs.security-analysis.outputs.results }}
        dashboard-type: 'executive,technical,compliance'
        export-formats: 'html,pdf,json'
        
    - name: Update Security Metrics
      uses: ./.github/actions/security-metrics-updater
      with:
        metrics-endpoint: ${{ secrets.METRICS_API_ENDPOINT }}
        dashboard-url: ${{ secrets.DASHBOARD_URL }}
        
    - name: Compliance Report Generation
      if: contains(github.event.inputs.scan_type, 'compliance') || github.event.schedule
      uses: ./.github/actions/compliance-report-generator
      with:
        frameworks: ${{ env.COMPLIANCE_FRAMEWORKS }}
        evidence-path: './security-evidence'
        report-format: 'pdf,xlsx'
        
  security-governance:
    runs-on: ubuntu-latest
    if: github.event_name == 'pull_request'
    
    steps:
    - name: Security Policy Enforcement
      uses: ./.github/actions/security-policy-enforcer
      with:
        policy-path: '.github/security/governance-policies.yml'
        enforcement-level: 'strict'
        exemption-process: 'security-approval'
        
    - name: Security Review Assignment
      uses: ./.github/actions/security-review-assigner
      with:
        security-team: 'security-reviewers'
        risk-assessment: 'automatic'
        review-requirements: '.github/security/review-requirements.yml'
```

#### 8.2 Custom Security Actions

**Advanced CodeQL Action**
```yaml
# .github/actions/advanced-codeql/action.yml
name: 'Advanced CodeQL Analysis'
description: 'Comprehensive CodeQL security analysis with custom queries'

inputs:
  languages:
    description: 'Programming languages to analyze'
    required: true
  queries:
    description: 'Query suites to run'
    required: true
  config-file:
    description: 'CodeQL configuration file path'
    required: false
  custom-queries-path:
    description: 'Path to custom security queries'
    required: false

outputs:
  results-path:
    description: 'Path to analysis results'
    value: ${{ steps.analyze.outputs.results-path }}
  security-score:
    description: 'Overall security score'
    value: ${{ steps.score.outputs.security-score }}

runs:
  using: 'composite'
  steps:
    - name: Initialize CodeQL with custom configuration
      uses: github/codeql-action/init@v3
      with:
        languages: ${{ inputs.languages }}
        queries: ${{ inputs.queries }}
        config-file: ${{ inputs.config-file }}
        
    - name: Load custom security queries
      if: inputs.custom-queries-path
      shell: bash
      run: |
        echo "Loading custom security queries from ${{ inputs.custom-queries-path }}"
        find ${{ inputs.custom-queries-path }} -name "*.ql" -exec echo "Found query: {}" \;
        
    - name: Build codebase
      uses: github/codeql-action/autobuild@v3
      
    - name: Perform CodeQL Analysis
      id: analyze
      uses: github/codeql-action/analyze@v3
      with:
        category: "/security-analysis"
        upload: true
        
    - name: Calculate security score
      id: score
      shell: bash
      run: |
        # Calculate security score based on findings
        CRITICAL=$(jq '.runs[0].results | map(select(.level == "error")) | length' results.sarif)
        HIGH=$(jq '.runs[0].results | map(select(.level == "warning")) | length' results.sarif)
        MEDIUM=$(jq '.runs[0].results | map(select(.level == "note")) | length' results.sarif)
        
        # Calculate weighted score (100 - weighted issues)
        SCORE=$((100 - (CRITICAL * 10 + HIGH * 5 + MEDIUM * 2)))
        SCORE=$((SCORE > 0 ? SCORE : 0))
        
        echo "security-score=$SCORE" >> $GITHUB_OUTPUT
        echo "Security Score: $SCORE/100"
```

### Hands-on Exercise 8.1: Advanced Automation

**Scenario**: Implement comprehensive security automation with custom actions and governance policies.

**Tasks**:
1. Create advanced security automation pipeline
2. Develop custom GitHub Actions for security scanning
3. Implement security governance and policy enforcement
4. Configure automated reporting and dashboards
5. Test comprehensive security automation workflow

**Expected Outcome**: Advanced security automation system with custom actions, governance policies, and comprehensive reporting capabilities.

## Hands-on Exercises

### Exercise 1: Complete Platform Setup

**Objective**: Configure a complete GitHub Advanced Security platform for a multi-team organization.

**Scenario**: You are setting up GitHub Advanced Security for a financial services company with 50+ repositories across 5 development teams. The organization must comply with SOC 2, PCI DSS, and internal security policies.

**Tasks**:
1. **Organization Configuration**
   - Enable Advanced Security features
   - Configure 2FA requirements
   - Set up security teams and permissions
   - Configure default repository settings

2. **Repository Security Setup**
   - Enable security features across all repositories
   - Configure branch protection rules
   - Set up code scanning workflows
   - Implement secret scanning with custom patterns

3. **Compliance Implementation**
   - Configure compliance monitoring
   - Set up audit logging
   - Implement compliance reporting
   - Create evidence collection processes

4. **SIEM Integration**
   - Configure Splunk integration
   - Set up real-time event forwarding
   - Create security dashboards
   - Implement alert routing

**Deliverables**:
- Fully configured GitHub organization
- Security scanning workflows for all repositories
- SIEM integration with real-time forwarding
- Compliance monitoring and reporting system
- Documentation of configuration and processes

### Exercise 2: Incident Response Simulation

**Objective**: Test the complete incident response process using simulated security events.

**Scenario**: A critical secret has been detected in a production repository, and a high-severity CodeQL vulnerability has been found in the payment processing module.

**Tasks**:
1. **Incident Detection**
   - Trigger secret scanning alert
   - Generate CodeQL vulnerability alert
   - Test automated incident creation

2. **Response Execution**
   - Verify alert routing and escalation
   - Test notification systems
   - Execute containment procedures
   - Implement remediation steps

3. **Communication and Coordination**
   - Test stakeholder notifications
   - Verify escalation procedures
   - Document incident timeline
   - Coordinate team responses

4. **Recovery and Lessons Learned**
   - Implement fixes and verify resolution
   - Conduct post-incident review
   - Update procedures based on learnings
   - Generate executive summary

**Deliverables**:
- Complete incident response documentation
- Timeline of detection to resolution
- Post-incident analysis report
- Updated procedures and processes
- Executive summary presentation

### Exercise 3: Custom Security Integration

**Objective**: Develop and implement custom security integrations for organization-specific requirements.

**Scenario**: Your organization uses custom security tools and has specific compliance requirements that need to be integrated with GitHub Advanced Security.

**Tasks**:
1. **Custom Pattern Development**
   - Create custom secret detection patterns
   - Develop organization-specific CodeQL queries
   - Implement custom vulnerability assessments

2. **Tool Integration**
   - Integrate with custom SAST tools
   - Connect to proprietary vulnerability databases
   - Implement custom compliance checks

3. **Workflow Automation**
   - Create custom GitHub Actions
   - Implement advanced automation workflows
   - Set up custom reporting and analytics

4. **Testing and Validation**
   - Test custom integrations
   - Validate security detection accuracy
   - Verify compliance coverage

**Deliverables**:
- Custom security patterns and queries
- Integration code and documentation
- Automated testing procedures
- Performance and accuracy metrics
- Integration maintenance procedures

## Assessment and Certification

### Knowledge Assessment

**Multiple Choice Questions** (Sample)

1. Which GitHub Advanced Security feature provides semantic code analysis?
   a) Secret Scanning
   b) Dependency Analysis
   c) CodeQL
   d) Vulnerability Alerts

2. What is the recommended approach for handling critical secret exposures?
   a) Create an issue for tracking
   b) Immediately revoke and rotate the credential
   c) Wait for the next security review
   d) Archive the repository

3. Which compliance framework requires breach notification within 72 hours?
   a) SOC 2
   b) PCI DSS
   c) GDPR
   d) HIPAA

**Practical Assessment Tasks**

1. **Configuration Demonstration**
   - Configure a repository with comprehensive security features
   - Demonstrate proper branch protection setup
   - Show compliance monitoring configuration

2. **Incident Response Simulation**
   - Respond to a simulated security incident
   - Demonstrate proper escalation procedures
   - Document response activities

3. **Integration Implementation**
   - Implement SIEM integration
   - Configure custom security patterns
   - Demonstrate automated reporting

### Certification Requirements

**Prerequisites**:
- Completion of all training modules
- Successful completion of hands-on exercises
- Passing score on knowledge assessment (80% minimum)
- Demonstration of practical skills

**Certification Levels**:

1. **GitHub Advanced Security Practitioner**
   - Basic configuration and management
   - Standard security scanning implementation
   - Basic incident response procedures

2. **GitHub Advanced Security Professional**
   - Advanced configuration and customization
   - SIEM integration and automation
   - Compliance monitoring and reporting
   - Custom development and integration

3. **GitHub Advanced Security Expert**
   - Enterprise-scale implementations
   - Advanced automation and orchestration
   - Custom tool development
   - Incident response leadership
   - Training delivery capabilities

**Continuing Education**:
- Annual recertification required
- Completion of advanced modules
- Participation in security community
- Contribution to security knowledge base

## Additional Resources

### Documentation and References

**GitHub Documentation**:
- [GitHub Advanced Security Overview](https://docs.github.com/en/get-started/learning-about-github/about-github-advanced-security)
- [CodeQL Documentation](https://codeql.github.com/docs/)
- [Secret Scanning Documentation](https://docs.github.com/en/code-security/secret-scanning)
- [Dependency Review](https://docs.github.com/en/code-security/supply-chain-security)

**Security Frameworks**:
- [OWASP Security Knowledge Framework](https://owasp.org/www-project-security-knowledge-framework/)
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)
- [ISO 27001 Information Security Management](https://www.iso.org/isoiec-27001-information-security.html)

**Compliance Resources**:
- [SOC 2 Compliance Guide](https://www.aicpa.org/interestareas/frc/assuranceadvisoryservices/sorhome.html)
- [PCI DSS Requirements](https://www.pcisecuritystandards.org/document_library)
- [GDPR Compliance Guidelines](https://gdpr.eu/)
- [HIPAA Security Rule](https://www.hhs.gov/hipaa/for-professionals/security/index.html)

### Tools and Utilities

**Security Scanning Tools**:
- [Snyk](https://snyk.io/) - Vulnerability scanning
- [Semgrep](https://semgrep.dev/) - Static analysis
- [TruffleHog](https://trufflesecurity.com/) - Secret detection
- [Bandit](https://bandit.readthedocs.io/) - Python security linting

**SIEM Platforms**:
- [Splunk](https://www.splunk.com/) - Enterprise SIEM
- [Azure Sentinel](https://azure.microsoft.com/en-us/services/azure-sentinel/) - Cloud SIEM
- [Datadog Security Monitoring](https://www.datadoghq.com/product/security-monitoring/) - Cloud monitoring

**Development Tools**:
- [GitHub CLI](https://cli.github.com/) - Command line interface
- [VS Code GitHub Extension](https://marketplace.visualstudio.com/items?itemName=GitHub.vscode-pull-request-github) - IDE integration
- [Postman](https://www.postman.com/) - API testing

### Community and Support

**GitHub Community**:
- [GitHub Community Forum](https://github.community/)
- [GitHub Security Advisories](https://github.com/advisories)
- [GitHub Security Lab](https://securitylab.github.com/)

**Security Communities**:
- [DevSecOps Community](https://www.devsecops.org/)
- [OWASP Local Chapters](https://owasp.org/chapters/)
- [Security BSides Events](http://www.securitybsides.com/)

**Professional Development**:
- [CISSP Certification](https://www.isc2.org/Certifications/CISSP)
- [GSEC Certification](https://www.giac.org/certification/security-essentials-gsec)
- [DevSecOps Certification](https://www.practical-devsecops.com/certified-devsecops-professional/)

### Sample Code and Templates

**Repository Templates**:
- Security-first repository template
- Compliance-ready workflow templates
- Incident response playbooks
- Security policy templates

**Code Examples**:
- Custom CodeQL queries for common vulnerabilities
- Secret scanning patterns for enterprise tools
- SIEM integration scripts
- Compliance automation tools

**Configuration Files**:
- Advanced Dependabot configurations
- Branch protection policy templates
- Security workflow examples
- Monitoring and alerting configurations

---

**Training Program Version**: 2.0  
**Last Updated**: 2024  
**Next Review**: Quarterly  
**Feedback**: training-feedback@company.com

This comprehensive training program provides the foundation for implementing and managing GitHub Advanced Security at enterprise scale. Regular updates ensure alignment with the latest security practices and GitHub feature releases.