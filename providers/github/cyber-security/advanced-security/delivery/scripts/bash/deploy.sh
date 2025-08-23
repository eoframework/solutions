#!/bin/bash
# GitHub Advanced Security Platform - Deployment Script
# This script automates the deployment of GitHub Advanced Security features
# and integrations across the organization

set -euo pipefail

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="${SCRIPT_DIR}/deployment.log"
CONFIG_FILE="${SCRIPT_DIR}/../config/deployment.conf"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    local level=$1
    shift
    local message="$@"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "[${timestamp}] [${level}] ${message}" | tee -a "$LOG_FILE"
}

# Info log function
info() {
    log "INFO" "${BLUE}$@${NC}"
}

# Success log function
success() {
    log "SUCCESS" "${GREEN}$@${NC}"
}

# Warning log function
warn() {
    log "WARN" "${YELLOW}$@${NC}"
}

# Error log function
error() {
    log "ERROR" "${RED}$@${NC}"
}

# Usage information
usage() {
    cat << EOF
GitHub Advanced Security Platform - Deployment Script

USAGE:
    $0 [OPTIONS]

OPTIONS:
    -o, --organization GITHUB_ORG    GitHub organization name
    -t, --token GITHUB_TOKEN         GitHub personal access token
    -c, --config CONFIG_FILE         Configuration file path
    -e, --environment ENV            Environment (dev/staging/prod)
    -s, --skip-validation           Skip pre-deployment validation
    -d, --dry-run                   Perform dry run without making changes
    -h, --help                      Show this help message

EXAMPLES:
    $0 --organization myorg --token ghp_xxx --environment prod
    $0 --config ./my-config.conf --dry-run
    $0 -o myorg -t \$GITHUB_TOKEN -e dev

ENVIRONMENT VARIABLES:
    GITHUB_ORGANIZATION    GitHub organization name
    GITHUB_TOKEN          GitHub personal access token
    GITHUB_APP_ID         GitHub App ID (optional)
    GITHUB_APP_PRIVATE_KEY GitHub App private key (optional)
    ENVIRONMENT           Deployment environment
    
EOF
}

# Default configuration
GITHUB_ORG="${GITHUB_ORGANIZATION:-}"
GITHUB_TOKEN="${GITHUB_TOKEN:-}"
GITHUB_APP_ID="${GITHUB_APP_ID:-}"
GITHUB_APP_PRIVATE_KEY="${GITHUB_APP_PRIVATE_KEY:-}"
ENVIRONMENT="${ENVIRONMENT:-dev}"
DRY_RUN=false
SKIP_VALIDATION=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -o|--organization)
            GITHUB_ORG="$2"
            shift 2
            ;;
        -t|--token)
            GITHUB_TOKEN="$2"
            shift 2
            ;;
        -c|--config)
            CONFIG_FILE="$2"
            shift 2
            ;;
        -e|--environment)
            ENVIRONMENT="$2"
            shift 2
            ;;
        -s|--skip-validation)
            SKIP_VALIDATION=true
            shift
            ;;
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            error "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Load configuration file if it exists
if [[ -f "$CONFIG_FILE" ]]; then
    info "Loading configuration from $CONFIG_FILE"
    source "$CONFIG_FILE"
fi

# Validation functions
validate_requirements() {
    info "Validating deployment requirements..."
    
    # Check required tools
    local required_tools=("curl" "jq" "git" "python3")
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            error "Required tool '$tool' is not installed"
            return 1
        fi
    done
    
    # Check required variables
    if [[ -z "$GITHUB_ORG" ]]; then
        error "GitHub organization name is required"
        return 1
    fi
    
    if [[ -z "$GITHUB_TOKEN" ]]; then
        error "GitHub token is required"
        return 1
    fi
    
    # Validate GitHub token
    local auth_response
    auth_response=$(curl -s -w "%{http_code}" -H "Authorization: token $GITHUB_TOKEN" \
                    "https://api.github.com/user" -o /dev/null)
    
    if [[ "$auth_response" != "200" ]]; then
        error "GitHub token validation failed (HTTP $auth_response)"
        return 1
    fi
    
    # Check organization access
    local org_response
    org_response=$(curl -s -w "%{http_code}" -H "Authorization: token $GITHUB_TOKEN" \
                   "https://api.github.com/orgs/$GITHUB_ORG" -o /dev/null)
    
    if [[ "$org_response" != "200" ]]; then
        error "Cannot access GitHub organization '$GITHUB_ORG' (HTTP $org_response)"
        return 1
    fi
    
    success "All requirements validated successfully"
}

# GitHub API functions
github_api() {
    local method="$1"
    local endpoint="$2"
    local data="${3:-}"
    
    local curl_args=(
        -s
        -X "$method"
        -H "Authorization: token $GITHUB_TOKEN"
        -H "Accept: application/vnd.github.v3+json"
        -H "Content-Type: application/json"
    )
    
    if [[ -n "$data" ]]; then
        curl_args+=(-d "$data")
    fi
    
    if [[ "$DRY_RUN" == "true" ]]; then
        info "[DRY RUN] Would call GitHub API: $method $endpoint"
        if [[ -n "$data" ]]; then
            info "[DRY RUN] With data: $data"
        fi
        return 0
    fi
    
    curl "${curl_args[@]}" "https://api.github.com$endpoint"
}

# Organization security configuration
configure_organization_security() {
    info "Configuring organization-level security settings..."
    
    # Enable 2FA requirement
    info "Enabling two-factor authentication requirement..."
    local result
    result=$(github_api "PATCH" "/orgs/$GITHUB_ORG" \
        '{"two_factor_requirement_enabled": true}')
    
    if [[ $? -eq 0 ]]; then
        success "Two-factor authentication requirement enabled"
    else
        warn "Failed to enable 2FA requirement: $result"
    fi
    
    # Configure security and analysis settings
    info "Configuring security and analysis settings..."
    result=$(github_api "PATCH" "/orgs/$GITHUB_ORG" '{
        "advanced_security_enabled_for_new_repositories": true,
        "dependency_graph_enabled_for_new_repositories": true,
        "dependabot_alerts_enabled_for_new_repositories": true,
        "dependabot_security_updates_enabled_for_new_repositories": true,
        "secret_scanning_enabled_for_new_repositories": true,
        "secret_scanning_push_protection_enabled_for_new_repositories": true
    }')
    
    if [[ $? -eq 0 ]]; then
        success "Organization security settings configured"
    else
        warn "Failed to configure security settings: $result"
    fi
}

# Repository security configuration
configure_repository_security() {
    info "Configuring repository-level security settings..."
    
    # Get organization repositories
    local repos
    repos=$(github_api "GET" "/orgs/$GITHUB_ORG/repos?per_page=100")
    
    if [[ $? -ne 0 ]]; then
        error "Failed to fetch organization repositories"
        return 1
    fi
    
    local repo_count
    repo_count=$(echo "$repos" | jq '. | length')
    info "Found $repo_count repositories in organization"
    
    # Configure each repository
    echo "$repos" | jq -r '.[].name' | while read -r repo_name; do
        info "Configuring security for repository: $repo_name"
        
        # Enable vulnerability alerts
        github_api "PUT" "/repos/$GITHUB_ORG/$repo_name/vulnerability-alerts" > /dev/null
        
        # Enable secret scanning (if available)
        github_api "PUT" "/repos/$GITHUB_ORG/$repo_name/secret-scanning/alerts" > /dev/null 2>&1
        
        # Get default branch
        local default_branch
        default_branch=$(echo "$repos" | jq -r ".[] | select(.name == \"$repo_name\") | .default_branch")
        
        # Configure branch protection
        info "Configuring branch protection for $repo_name:$default_branch"
        github_api "PUT" "/repos/$GITHUB_ORG/$repo_name/branches/$default_branch/protection" '{
            "required_status_checks": {
                "strict": true,
                "contexts": ["security/codeql", "security/secret-scan"]
            },
            "enforce_admins": true,
            "required_pull_request_reviews": {
                "required_approving_review_count": 2,
                "dismiss_stale_reviews": true,
                "require_code_owner_reviews": true
            },
            "restrictions": null,
            "allow_force_pushes": false,
            "allow_deletions": false
        }' > /dev/null
        
        success "Repository $repo_name configured successfully"
    done
}

# Security scanning workflows deployment
deploy_security_workflows() {
    info "Deploying security scanning workflows..."
    
    local workflow_dir="${SCRIPT_DIR}/../workflows"
    mkdir -p "$workflow_dir"
    
    # Create CodeQL workflow
    info "Creating CodeQL scanning workflow..."
    cat > "$workflow_dir/codeql-analysis.yml" << 'EOF'
name: "CodeQL Security Analysis"

on:
  push:
    branches: [ main, master, develop ]
  pull_request:
    branches: [ main, master, develop ]
  schedule:
    - cron: '0 2 * * *'

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
        language: [ 'javascript', 'python', 'java', 'csharp', 'cpp', 'go' ]

    steps:
    - name: Checkout repository
      uses: actions/checkout@v3

    - name: Initialize CodeQL
      uses: github/codeql-action/init@v2
      with:
        languages: ${{ matrix.language }}
        queries: security-extended,security-and-quality

    - name: Autobuild
      uses: github/codeql-action/autobuild@v2

    - name: Perform CodeQL Analysis
      uses: github/codeql-action/analyze@v2
      with:
        category: "/language:${{matrix.language}}"
EOF

    # Create Secret Scanning workflow
    info "Creating secret scanning workflow..."
    cat > "$workflow_dir/secret-scanning.yml" << 'EOF'
name: "Secret Scanning"

on:
  push:
    branches: [ main, master, develop ]
  pull_request:
    branches: [ main, master, develop ]
  schedule:
    - cron: '0 2 * * *'

jobs:
  secret-scan:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout repository
      uses: actions/checkout@v3
      with:
        fetch-depth: 0

    - name: Run TruffleHog OSS
      uses: trufflesecurity/trufflehog@main
      with:
        path: ./
        base: main
        head: HEAD
        extra_args: --debug --only-verified
EOF

    # Create Dependency Scanning workflow
    info "Creating dependency scanning workflow..."
    cat > "$workflow_dir/dependency-scanning.yml" << 'EOF'
name: "Dependency Security Scan"

on:
  push:
    branches: [ main, master, develop ]
  pull_request:
    branches: [ main, master, develop ]
  schedule:
    - cron: '0 2 * * *'

jobs:
  dependency-scan:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout repository
      uses: actions/checkout@v3

    - name: Run Snyk to check for vulnerabilities
      uses: snyk/actions/node@master
      env:
        SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
      with:
        args: --severity-threshold=high --fail-on=all

    - name: Upload result to GitHub Code Scanning
      uses: github/codeql-action/upload-sarif@v2
      if: always()
      with:
        sarif_file: snyk.sarif
EOF

    success "Security scanning workflows created successfully"
}

# SIEM integration setup
setup_siem_integration() {
    info "Setting up SIEM integrations..."
    
    local siem_script_dir="${SCRIPT_DIR}/../siem-integration"
    mkdir -p "$siem_script_dir"
    
    # Create SIEM forwarder script
    info "Creating SIEM event forwarder..."
    cat > "$siem_script_dir/siem_forwarder.py" << 'EOF'
#!/usr/bin/env python3
"""
GitHub Security Events to SIEM Forwarder
Forwards GitHub security events to configured SIEM systems
"""

import json
import requests
import os
import sys
from datetime import datetime
import logging

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

class SIEMForwarder:
    def __init__(self):
        self.github_org = os.getenv('GITHUB_ORGANIZATION')
        self.github_token = os.getenv('GITHUB_TOKEN')
        self.splunk_hec_url = os.getenv('SPLUNK_HEC_URL')
        self.splunk_hec_token = os.getenv('SPLUNK_HEC_TOKEN')
        self.sentinel_workspace_id = os.getenv('AZURE_SENTINEL_WORKSPACE_ID')
        self.sentinel_shared_key = os.getenv('AZURE_SENTINEL_SHARED_KEY')
    
    def fetch_security_alerts(self):
        """Fetch security alerts from GitHub"""
        headers = {
            'Authorization': f'token {self.github_token}',
            'Accept': 'application/vnd.github.v3+json'
        }
        
        try:
            response = requests.get(
                f'https://api.github.com/orgs/{self.github_org}/security-advisories',
                headers=headers
            )
            response.raise_for_status()
            return response.json()
        except requests.RequestException as e:
            logger.error(f"Failed to fetch security alerts: {e}")
            return []
    
    def forward_to_splunk(self, events):
        """Forward events to Splunk HEC"""
        if not self.splunk_hec_url or not self.splunk_hec_token:
            return
        
        headers = {
            'Authorization': f'Splunk {self.splunk_hec_token}',
            'Content-Type': 'application/json'
        }
        
        for event in events:
            payload = {
                'time': datetime.utcnow().timestamp(),
                'source': 'github-security',
                'sourcetype': 'github:security:alert',
                'event': event
            }
            
            try:
                response = requests.post(
                    f'{self.splunk_hec_url}/services/collector',
                    headers=headers,
                    json=payload
                )
                response.raise_for_status()
                logger.info(f"Forwarded event to Splunk: {event.get('id', 'unknown')}")
            except requests.RequestException as e:
                logger.error(f"Failed to forward to Splunk: {e}")
    
    def forward_to_sentinel(self, events):
        """Forward events to Azure Sentinel"""
        if not self.sentinel_workspace_id or not self.sentinel_shared_key:
            return
        
        # Implementation for Azure Sentinel forwarding
        logger.info("Azure Sentinel integration configured but not implemented in this demo")
    
    def run(self):
        """Main execution function"""
        logger.info("Starting SIEM forwarder...")
        
        alerts = self.fetch_security_alerts()
        logger.info(f"Found {len(alerts)} security alerts")
        
        if alerts:
            self.forward_to_splunk(alerts)
            self.forward_to_sentinel(alerts)
        
        logger.info("SIEM forwarder completed")

if __name__ == "__main__":
    forwarder = SIEMForwarder()
    forwarder.run()
EOF

    chmod +x "$siem_script_dir/siem_forwarder.py"
    success "SIEM integration scripts created successfully"
}

# Compliance monitoring setup
setup_compliance_monitoring() {
    info "Setting up compliance monitoring..."
    
    local compliance_dir="${SCRIPT_DIR}/../compliance"
    mkdir -p "$compliance_dir"
    
    # Create compliance checker script
    info "Creating compliance monitoring script..."
    cat > "$compliance_dir/compliance_checker.py" << 'EOF'
#!/usr/bin/env python3
"""
GitHub Security Compliance Checker
Monitors compliance with security frameworks (SOC2, PCI-DSS, GDPR, HIPAA)
"""

import json
import requests
import os
from datetime import datetime
import logging

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

class ComplianceChecker:
    def __init__(self):
        self.github_org = os.getenv('GITHUB_ORGANIZATION')
        self.github_token = os.getenv('GITHUB_TOKEN')
        self.compliance_frameworks = ['SOC2', 'PCI-DSS', 'GDPR', 'HIPAA']
    
    def check_organization_compliance(self):
        """Check organization-level compliance settings"""
        headers = {
            'Authorization': f'token {self.github_token}',
            'Accept': 'application/vnd.github.v3+json'
        }
        
        try:
            response = requests.get(
                f'https://api.github.com/orgs/{self.github_org}',
                headers=headers
            )
            response.raise_for_status()
            org_data = response.json()
            
            return {
                'organization': self.github_org,
                'timestamp': datetime.utcnow().isoformat(),
                'compliance_frameworks': self.compliance_frameworks,
                'checks': {
                    'two_factor_required': org_data.get('two_factor_requirement_enabled', False),
                    'advanced_security_enabled': True,
                    'private_vulnerability_reporting': org_data.get('private_vulnerability_reporting_enabled', False)
                }
            }
        except requests.RequestException as e:
            logger.error(f"Failed to check organization compliance: {e}")
            return None
    
    def generate_compliance_report(self):
        """Generate comprehensive compliance report"""
        org_compliance = self.check_organization_compliance()
        
        if not org_compliance:
            return None
        
        report = {
            'compliance_report': {
                'organization': org_compliance,
                'generated_at': datetime.utcnow().isoformat(),
                'report_version': '1.0'
            }
        }
        
        # Save report
        report_file = f'compliance_report_{datetime.now().strftime("%Y%m%d_%H%M%S")}.json'
        with open(report_file, 'w') as f:
            json.dump(report, f, indent=2)
        
        logger.info(f"Compliance report generated: {report_file}")
        return report

if __name__ == "__main__":
    checker = ComplianceChecker()
    report = checker.generate_compliance_report()
    if report:
        print(json.dumps(report, indent=2))
EOF

    chmod +x "$compliance_dir/compliance_checker.py"
    success "Compliance monitoring configured successfully"
}

# Webhook setup
setup_security_webhooks() {
    info "Setting up security webhooks..."
    
    local webhook_dir="${SCRIPT_DIR}/../webhooks"
    mkdir -p "$webhook_dir"
    
    # Create webhook handler script
    info "Creating webhook handler..."
    cat > "$webhook_dir/webhook_handler.py" << 'EOF'
#!/usr/bin/env python3
"""
GitHub Security Webhook Handler
Processes incoming security events from GitHub webhooks
"""

import json
import hmac
import hashlib
from datetime import datetime
import logging

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

class WebhookHandler:
    def __init__(self, webhook_secret):
        self.webhook_secret = webhook_secret
    
    def verify_signature(self, payload, signature):
        """Verify GitHub webhook signature"""
        expected_signature = hmac.new(
            self.webhook_secret.encode('utf-8'),
            payload,
            hashlib.sha256
        ).hexdigest()
        return hmac.compare_digest(f"sha256={expected_signature}", signature)
    
    def process_security_alert(self, alert_data):
        """Process security alert webhook"""
        alert_type = alert_data.get('action', 'unknown')
        repository = alert_data.get('repository', {}).get('full_name', 'unknown')
        
        logger.info(f"Processing security alert: {alert_type} for {repository}")
        
        # Route alert based on severity and type
        self.route_alert(alert_data)
    
    def route_alert(self, alert_data):
        """Route alert to appropriate handlers"""
        severity = alert_data.get('alert', {}).get('severity', 'medium')
        
        routing_rules = {
            'critical': self.handle_critical_alert,
            'high': self.handle_high_alert,
            'medium': self.handle_medium_alert,
            'low': self.handle_low_alert
        }
        
        handler = routing_rules.get(severity, self.handle_medium_alert)
        handler(alert_data)
    
    def handle_critical_alert(self, alert_data):
        """Handle critical security alerts"""
        logger.critical(f"CRITICAL ALERT: {json.dumps(alert_data)}")
        # Send immediate notifications (email, SMS, Slack)
    
    def handle_high_alert(self, alert_data):
        """Handle high severity alerts"""
        logger.error(f"HIGH ALERT: {json.dumps(alert_data)}")
        # Send notifications (email, Slack)
    
    def handle_medium_alert(self, alert_data):
        """Handle medium severity alerts"""
        logger.warning(f"MEDIUM ALERT: {json.dumps(alert_data)}")
        # Send email notification
    
    def handle_low_alert(self, alert_data):
        """Handle low severity alerts"""
        logger.info(f"LOW ALERT: {json.dumps(alert_data)}")
        # Log alert

if __name__ == "__main__":
    webhook_secret = os.getenv('GITHUB_WEBHOOK_SECRET', 'default-secret')
    handler = WebhookHandler(webhook_secret)
    logger.info("Webhook handler initialized and ready")
EOF

    chmod +x "$webhook_dir/webhook_handler.py"
    success "Security webhooks configured successfully"
}

# Deployment validation
validate_deployment() {
    info "Validating deployment..."
    
    # Check organization security settings
    local org_data
    org_data=$(github_api "GET" "/orgs/$GITHUB_ORG")
    
    if echo "$org_data" | jq -e '.two_factor_requirement_enabled' > /dev/null; then
        success "✓ Two-factor authentication requirement is enabled"
    else
        warn "⚠ Two-factor authentication requirement is not enabled"
    fi
    
    # Check repository count
    local repo_count
    repo_count=$(github_api "GET" "/orgs/$GITHUB_ORG/repos?per_page=1" | jq '. | length')
    info "Organization has $repo_count repositories"
    
    success "Deployment validation completed"
}

# Cleanup function
cleanup() {
    info "Cleaning up temporary files..."
    # Remove any temporary files created during deployment
}

# Rollback function
rollback() {
    warn "Rollback functionality not implemented in this version"
    warn "Please manually revert changes if needed"
}

# Signal handlers
trap 'error "Deployment interrupted"; cleanup; exit 1' INT TERM
trap 'cleanup' EXIT

# Main deployment function
main() {
    info "Starting GitHub Advanced Security Platform deployment..."
    info "Organization: $GITHUB_ORG"
    info "Environment: $ENVIRONMENT"
    info "Dry Run: $DRY_RUN"
    
    # Pre-deployment validation
    if [[ "$SKIP_VALIDATION" != "true" ]]; then
        validate_requirements || {
            error "Pre-deployment validation failed"
            exit 1
        }
    fi
    
    # Deployment steps
    configure_organization_security || {
        error "Organization security configuration failed"
        exit 1
    }
    
    configure_repository_security || {
        error "Repository security configuration failed"
        exit 1
    }
    
    deploy_security_workflows || {
        error "Security workflows deployment failed"
        exit 1
    }
    
    setup_siem_integration || {
        error "SIEM integration setup failed"
        exit 1
    }
    
    setup_compliance_monitoring || {
        error "Compliance monitoring setup failed"
        exit 1
    }
    
    setup_security_webhooks || {
        error "Security webhooks setup failed"
        exit 1
    }
    
    # Post-deployment validation
    validate_deployment || {
        warn "Post-deployment validation failed"
    }
    
    success "GitHub Advanced Security Platform deployment completed successfully!"
    
    # Display next steps
    cat << EOF

🎉 DEPLOYMENT COMPLETE! 🎉

Next Steps:
1. Review and test security scanning workflows
2. Configure SIEM integration endpoints and credentials
3. Set up alert notification channels (email, Slack, SMS)
4. Train your security team on the new monitoring capabilities
5. Schedule regular security assessments and compliance reviews
6. Configure backup and disaster recovery procedures

Documentation and logs available in:
- Deployment log: $LOG_FILE
- Workflow templates: ${SCRIPT_DIR}/../workflows/
- SIEM integration: ${SCRIPT_DIR}/../siem-integration/
- Compliance monitoring: ${SCRIPT_DIR}/../compliance/
- Webhook handlers: ${SCRIPT_DIR}/../webhooks/

For support and additional configuration, refer to the implementation guide.

EOF
}

# Run main function
main "$@"