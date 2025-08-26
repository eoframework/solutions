# Troubleshooting Guide - GitHub Advanced Security Platform

## Common Issues

### Issue 1: CodeQL Analysis Failures and Performance Issues
**Symptoms:**
- CodeQL analysis jobs failing or timing out during execution
- Incomplete or inconsistent security findings across repositories
- Analysis consuming excessive time or computational resources
- Custom CodeQL queries not executing or producing unexpected results

**Causes:**
- Large codebase size exceeding analysis time limits or memory constraints
- Unsupported programming languages or framework configurations
- Incorrect CodeQL database extraction or compilation errors
- Custom query syntax errors or logic flaws
- Insufficient runner resources for analysis execution

**Solutions:**
1. Optimize CodeQL configuration to exclude unnecessary files and directories
2. Implement incremental analysis for large repositories with change-based scanning
3. Increase runner resources (CPU, memory) for analysis-heavy workloads
4. Review and validate custom CodeQL query syntax and logic
5. Configure appropriate timeout settings and retry mechanisms for analysis jobs

### Issue 2: Secret Scanning False Positives and Detection Issues
**Symptoms:**
- Legitimate code patterns flagged as potential secrets
- Actual secrets not detected by scanning algorithms
- High volume of false positive alerts overwhelming security teams
- Historical secret scanning missing known exposed credentials

**Causes:**
- Overly broad secret detection patterns matching non-secret code
- Secrets using custom formats not covered by default detection rules
- Inadequate allowlisting of known safe patterns and test data
- Incomplete historical scanning due to repository size or complexity
- Custom secret patterns not properly configured or tested

**Solutions:**
1. Implement comprehensive allowlisting for known false positive patterns
2. Develop custom secret patterns for organization-specific credential formats
3. Configure secret validity checking to reduce false positive rates
4. Tune detection sensitivity based on repository context and usage
5. Regularly review and update secret scanning configuration based on findings

### Issue 3: Dependency Review and Vulnerability Management Issues
**Symptoms:**
- Dependency vulnerability alerts for dependencies not actually used
- Missing vulnerability information for known problematic packages
- Automated dependency updates creating breaking changes
- License compliance issues not properly flagged or managed

**Causes:**
- Dependency tree analysis including development or unused dependencies
- Vulnerability database synchronization delays or coverage gaps
- Automated update configuration not respecting version constraints
- License scanning configuration not aligned with organizational policies
- Transitive dependency vulnerabilities not properly tracked

**Solutions:**
1. Configure dependency scanning to focus on production dependencies only
2. Implement manual review process for critical vulnerability updates
3. Configure automated dependency updates with comprehensive testing
4. Align license scanning with organizational legal and compliance requirements
5. Implement dependency pinning and controlled update processes

### Issue 4: Security Policy Enforcement and Compliance Issues
**Symptoms:**
- Security policies not consistently enforced across repositories
- Compliance checks failing due to configuration mismatches
- Branch protection rules bypassed or not properly configured
- Audit trail gaps affecting compliance reporting and evidence collection

**Causes:**
- Inconsistent security policy application across organizational repositories
- Branch protection rules not properly configured or maintained
- Repository settings overriding organizational security policies
- Insufficient permissions for security policy enforcement
- Missing or incomplete audit logging configuration

**Solutions:**
1. Implement organization-level security policies with inheritance controls
2. Regularly audit and validate branch protection rule configuration
3. Configure automated compliance checking with remediation workflows
4. Ensure proper permissions for security policy administration
5. Implement comprehensive audit logging and retention policies

### Issue 5: Integration and Performance Problems
**Symptoms:**
- SIEM integration delays or missing security event data
- Security dashboard showing outdated or incorrect information
- API rate limiting causing integration failures
- Webhook processing delays affecting real-time security responses

**Causes:**
- Network connectivity or authentication issues with external systems
- API rate limits being exceeded by high-volume security event processing
- Webhook endpoint configuration or processing capacity issues
- Data transformation or mapping errors in security tool integration
- Insufficient monitoring of integration health and performance

**Solutions:**
1. Implement robust error handling and retry logic for external integrations
2. Configure appropriate API rate limiting and request batching strategies
3. Scale webhook processing infrastructure to handle peak security event volumes
4. Validate data mapping and transformation logic for security tool integration
5. Implement comprehensive monitoring and alerting for integration health

## Diagnostic Tools

### Built-in GitHub Security Tools
- **Security Tab**: Repository-level security findings and configuration management
- **Security Overview**: Organization-level security posture and metrics dashboard
- **Security Advisories**: Vulnerability disclosure and management platform
- **Audit Log**: Comprehensive logging of security events and configuration changes
- **API**: GitHub REST and GraphQL APIs for programmatic security data access

### CodeQL Diagnostic Commands
```bash
# Check CodeQL version and database information
codeql version
codeql database info /path/to/database

# Validate custom CodeQL queries
codeql query compile /path/to/custom-query.ql

# Run specific queries against CodeQL database
codeql database analyze /path/to/database \
  --format=sarif-latest \
  --output=/path/to/results.sarif \
  /path/to/queries/

# Examine CodeQL database schema and available libraries
codeql resolve database /path/to/database
codeql resolve library-path /path/to/database
```

### GitHub CLI Security Commands
```bash
# List security alerts for repository
gh api repos/{owner}/{repo}/security-advisories

# Check secret scanning alerts
gh api repos/{owner}/{repo}/secret-scanning/alerts

# Review dependency alerts
gh api repos/{owner}/{repo}/dependabot/alerts

# Monitor security policy compliance
gh api orgs/{org}/security-managers

# Check branch protection status
gh api repos/{owner}/{repo}/branches/{branch}/protection
```

### Security API Monitoring Scripts
```bash
#!/bin/bash
# Monitor security finding trends and metrics

# Get organization security overview
curl -H "Authorization: token $GITHUB_TOKEN" \
  "https://api.github.com/orgs/$ORG/security-advisories"

# Check repository security alerts
curl -H "Authorization: token $GITHUB_TOKEN" \
  "https://api.github.com/repos/$OWNER/$REPO/security-advisories"

# Monitor secret scanning status
curl -H "Authorization: token $GITHUB_TOKEN" \
  "https://api.github.com/repos/$OWNER/$REPO/secret-scanning/alerts"

# Track dependency vulnerability status
curl -H "Authorization: token $GITHUB_TOKEN" \
  "https://api.github.com/repos/$OWNER/$REPO/dependabot/alerts"
```

### External Security Monitoring Tools
- **SIEM Dashboards**: Real-time security event monitoring and correlation
- **Vulnerability Scanners**: Third-party security scanning and assessment tools
- **Security Orchestration**: SOAR platform integration and automated response
- **Compliance Platforms**: GRC platform integration for regulatory compliance
- **Threat Intelligence**: External threat feed integration and analysis

## Performance Optimization

### CodeQL Analysis Optimization
```yaml
# Optimized CodeQL workflow configuration
name: "CodeQL Analysis"
on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

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
      uses: github/codeql-action/init@v2
      with:
        languages: ${{ matrix.language }}
        config-file: ./.github/codeql/codeql-config.yml

    - name: Autobuild
      uses: github/codeql-action/autobuild@v2

    - name: Perform CodeQL Analysis
      uses: github/codeql-action/analyze@v2
      with:
        category: "/language:${{matrix.language}}"
```

### Secret Scanning Optimization
```yaml
# Custom secret scanning patterns
patterns:
  - name: "Custom API Key"
    regex: "(?i)custom[_-]?api[_-]?key[_-]?[:=]\\s*['\"]?([a-z0-9]{32})['\"]?"
    entropy: 3.5
    
  - name: "Database Connection String"
    regex: "(?i)(jdbc|mysql|postgresql)://[^\\s]+"
    validation_url: "internal-validation-service"

# Allowlist configuration
allowlist:
  - "/test/"
  - "/docs/"
  - "example.com"
  - "placeholder-*"
```

### Dependency Review Optimization
- **Scope Configuration**: Focus scanning on production dependencies only
- **Update Automation**: Configure automated updates with testing validation
- **License Management**: Implement organization-wide license policy enforcement
- **Vulnerability Prioritization**: Focus on exploitable vulnerabilities with business impact
- **Supply Chain Security**: Monitor dependency integrity and source validation

## Security Configuration Best Practices

### Repository Security Configuration
```yaml
# Branch protection rules template
protection_rules:
  required_status_checks:
    strict: true
    contexts:
      - "CodeQL Analysis"
      - "Secret Scanning"
      - "Dependency Review"
  
  enforce_admins: true
  required_pull_request_reviews:
    required_approving_review_count: 2
    dismiss_stale_reviews: true
    require_code_owner_reviews: true
  
  restrictions:
    users: []
    teams: ["security-team"]
    apps: []
```

### Organization Security Policies
```yaml
# Security policy template
security_policy:
  secret_scanning:
    enabled: true
    push_protection: true
    
  dependency_graph:
    enabled: true
    
  vulnerability_alerts:
    enabled: true
    
  automated_security_fixes:
    enabled: true
    
  private_vulnerability_reporting:
    enabled: true
```

### Custom CodeQL Queries
```ql
/**
 * @name Custom SQL Injection Detection
 * @description Detects potential SQL injection vulnerabilities
 * @kind path-problem
 * @id custom/sql-injection
 */

import javascript
import DataFlow::PathGraph

class SqlInjectionConfig extends TaintTracking::Configuration {
  SqlInjectionConfig() { this = "SqlInjectionConfig" }

  override predicate isSource(DataFlow::Node source) {
    source instanceof RemoteFlowSource
  }

  override predicate isSink(DataFlow::Node sink) {
    exists(SqlExecution sql |
      sink = sql.getQuery()
    )
  }
}

from SqlInjectionConfig config, DataFlow::PathNode source, DataFlow::PathNode sink
where config.hasFlowPath(source, sink)
select sink.getNode(), source, sink, "Potential SQL injection vulnerability."
```

## Advanced Troubleshooting

### SIEM Integration Debugging
```bash
# Test SIEM webhook endpoint connectivity
curl -X POST -H "Content-Type: application/json" \
  -d '{"test": "security event"}' \
  https://siem.company.com/webhook/github

# Validate security event data transformation
jq '.security_event | {
  timestamp: .created_at,
  severity: .severity,
  repository: .repository.full_name,
  finding: .security_advisory.summary
}' security_event.json

# Monitor webhook delivery status
gh api /repos/$OWNER/$REPO/hooks/$HOOK_ID/deliveries
```

### Custom Query Development
```bash
# Test custom CodeQL queries locally
codeql database create test-db --language=javascript --source-root=./src

# Compile and test custom query
codeql query compile custom-security-check.ql
codeql query run custom-security-check.ql --database=test-db

# Validate query results and performance
codeql database analyze test-db custom-security-check.ql \
  --format=sarif-latest --output=results.sarif
```

### Performance Analysis
```bash
# Analyze CodeQL database size and complexity
du -sh /path/to/codeql/database
find /path/to/codeql/database -name "*.bqrs" -exec du -h {} \;

# Monitor API rate limit usage
curl -H "Authorization: token $GITHUB_TOKEN" \
  "https://api.github.com/rate_limit"

# Check webhook processing performance
tail -f /var/log/webhook-processor.log | grep "processing_time"
```

## Support Escalation

### Level 1 Support (Security Team)
- **Internal Documentation**: Security runbooks and troubleshooting guides
- **Security Operations**: SOC monitoring and incident response procedures
- **Tool Documentation**: GitHub Advanced Security official documentation
- **Community Resources**: GitHub Security Community and OWASP resources
- **Vendor Support**: Security tool vendor documentation and basic support

### Level 2 Support (Platform Engineering)
- **Advanced Configuration**: Complex security policy and integration troubleshooting
- **Custom Development**: CodeQL query development and security automation
- **Integration Issues**: SIEM, SOAR, and enterprise system integration problems
- **Performance Optimization**: Security scanning performance and resource optimization
- **Compliance Issues**: Regulatory compliance and audit trail problems

### Level 3 Support (GitHub Support)
- **GitHub Enterprise Support**: Official GitHub Advanced Security support
- **Professional Services**: GitHub security consulting and implementation services
- **Security Research**: GitHub Security Lab collaboration and custom query development
- **Product Engineering**: Escalation to GitHub security product development team
- **Critical Incidents**: Emergency security incident response and coordination

### Emergency Escalation
- **Zero-Day Vulnerabilities**: Immediate response for critical vulnerability discoveries
- **Security Breaches**: Emergency security incident response and containment
- **Compliance Violations**: Critical compliance incident response and remediation
- **System Outages**: Security platform availability and service restoration
- **Data Integrity**: Security data corruption or loss incident response

## Monitoring and Health Checks

### Security Platform Health Monitoring
```yaml
# Security health check workflow
name: Security Platform Health Check
on:
  schedule:
    - cron: '0 */4 * * *'  # Every 4 hours

jobs:
  health-check:
    runs-on: ubuntu-latest
    steps:
    - name: Check CodeQL Analysis Status
      run: |
        FAILURES=$(gh api "/repos/${{ github.repository }}/code-scanning/analyses" \
          | jq '[.[] | select(.created_at > (now - 86400)) | select(.error != null)] | length')
        if [ "$FAILURES" -gt 0 ]; then
          echo "CodeQL analysis failures detected: $FAILURES"
          exit 1
        fi

    - name: Check Secret Scanning Status
      run: |
        OPEN_ALERTS=$(gh api "/repos/${{ github.repository }}/secret-scanning/alerts" \
          | jq '[.[] | select(.state == "open")] | length')
        echo "Open secret scanning alerts: $OPEN_ALERTS"

    - name: Check Dependency Alerts
      run: |
        CRITICAL_ALERTS=$(gh api "/repos/${{ github.repository }}/dependabot/alerts" \
          | jq '[.[] | select(.security_advisory.severity == "critical")] | length')
        if [ "$CRITICAL_ALERTS" -gt 0 ]; then
          echo "Critical dependency alerts detected: $CRITICAL_ALERTS"
          exit 1
        fi
```

### Security Metrics Collection
```bash
#!/bin/bash
# Collect comprehensive security metrics

# CodeQL analysis metrics
CODEQL_SUCCESS_RATE=$(gh api "/repos/$OWNER/$REPO/code-scanning/analyses" \
  | jq '[.[] | select(.created_at > (now - 604800))] | 
    [length, map(select(.error == null)) | length] | 
    .[1] / .[0] * 100')

# Secret scanning metrics
SECRET_RESOLUTION_TIME=$(gh api "/repos/$OWNER/$REPO/secret-scanning/alerts" \
  | jq '[.[] | select(.state == "resolved")] | 
    map((((.resolved_at | fromdateiso8601) - (.created_at | fromdateiso8601)) / 86400)) | 
    add / length')

# Dependency alert metrics
DEPENDENCY_COVERAGE=$(gh api "/repos/$OWNER/$REPO/dependabot/alerts" \
  | jq '[.[] | select(.security_advisory.severity == "high" or 
    .security_advisory.severity == "critical")] | 
    [length, map(select(.state == "fixed")) | length] | 
    .[1] / .[0] * 100')

echo "CodeQL Success Rate: ${CODEQL_SUCCESS_RATE}%"
echo "Average Secret Resolution Time: ${SECRET_RESOLUTION_TIME} days"
echo "High/Critical Dependency Fix Rate: ${DEPENDENCY_COVERAGE}%"
```

### Automated Security Reporting
```yaml
# Executive security report generation
name: Security Executive Report
on:
  schedule:
    - cron: '0 9 * * 1'  # Weekly on Monday

jobs:
  generate-report:
    runs-on: ubuntu-latest
    steps:
    - name: Collect Security Metrics
      id: metrics
      run: |
        # Generate comprehensive security metrics
        python scripts/security-metrics-collector.py \
          --output-format json \
          --timeframe "7d" \
          > security-metrics.json

    - name: Generate Executive Report
      run: |
        python scripts/executive-report-generator.py \
          --metrics security-metrics.json \
          --template templates/executive-report.html \
          --output reports/weekly-security-report.html

    - name: Send Report
      uses: 8398a7/action-slack@v3
      with:
        status: success
        custom_payload: |
          {
            "text": "Weekly Security Report",
            "attachments": [{
              "color": "good",
              "title": "Security Metrics Summary",
              "text": "Weekly security metrics report has been generated and is available in the security dashboard."
            }]
          }
        webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

## Business Continuity and Disaster Recovery

### Security Data Backup and Recovery
- **Configuration Backup**: Regular backup of security policies and configurations
- **Historical Data**: Backup of security findings and vulnerability data
- **Audit Trail**: Comprehensive backup of security audit logs and evidence
- **Integration Settings**: Backup of security tool integrations and workflows
- **Custom Queries**: Version control and backup of custom CodeQL queries

### Incident Response and Recovery
- **Security Incident Playbooks**: Defined procedures for various security incident types
- **Communication Plans**: Stakeholder communication during security incidents
- **Recovery Procedures**: Step-by-step recovery from security platform outages
- **Evidence Preservation**: Procedures for preserving security evidence during incidents
- **Lessons Learned**: Post-incident analysis and process improvement

### Compliance Continuity
- **Audit Preparation**: Maintained readiness for regulatory audits and assessments
- **Evidence Collection**: Automated collection and preservation of compliance evidence
- **Regulatory Reporting**: Continuous compliance reporting and status monitoring
- **Risk Assessment**: Ongoing risk assessment and mitigation planning
- **Policy Updates**: Regular review and update of security policies and procedures