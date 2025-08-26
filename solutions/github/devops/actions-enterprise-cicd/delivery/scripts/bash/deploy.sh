#!/bin/bash

# GitHub Actions Enterprise CI/CD Platform Deployment Script
# This script automates the deployment of the GitHub Actions Enterprise CI/CD Platform
# including infrastructure provisioning, configuration, and validation.

set -euo pipefail

# Configuration variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
PROJECT_NAME="${PROJECT_NAME:-github-actions-enterprise}"
ENVIRONMENT="${ENVIRONMENT:-dev}"
AWS_REGION="${AWS_REGION:-us-east-1}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Help function
show_help() {
    cat << EOF
GitHub Actions Enterprise CI/CD Platform Deployment Script

USAGE:
    $0 [OPTIONS]

OPTIONS:
    -o, --organization      GitHub organization name (required)
    -t, --token            GitHub personal access token (required)
    -r, --region           AWS region (default: us-east-1)
    -e, --environment      Environment name (default: dev)
    -i, --instance-type    Runner instance type (default: t3.large)
    -m, --min-runners      Minimum number of runners (default: 2)
    -M, --max-runners      Maximum number of runners (default: 10)
    -d, --desired-runners  Desired number of runners (default: 3)
    -a, --auto-approve     Auto-approve Terraform changes
    -v, --validate-only    Only validate configuration, don't deploy
    -c, --cleanup          Cleanup deployed resources
    -h, --help             Show this help message

EXAMPLES:
    # Basic deployment
    $0 --organization myorg --token ghp_xxxxxxxxxxxx

    # Production deployment with larger capacity
    $0 --organization myorg --token ghp_xxxxxxxxxxxx \\
       --environment prod --max-runners 20 --desired-runners 5

    # Validation only
    $0 --organization myorg --token ghp_xxxxxxxxxxxx --validate-only

    # Cleanup deployment
    $0 --organization myorg --token ghp_xxxxxxxxxxxx --cleanup

ENVIRONMENT VARIABLES:
    GITHUB_ORG             GitHub organization name
    GITHUB_TOKEN           GitHub personal access token
    AWS_REGION             AWS region
    ENVIRONMENT            Environment name
    AUTO_APPROVE           Auto-approve Terraform changes (true/false)

PREREQUISITES:
    - AWS CLI configured with appropriate permissions
    - Terraform installed (>= 1.0)
    - GitHub CLI installed
    - jq installed for JSON processing
    - curl installed

EOF
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    local missing_tools=()
    
    # Check required tools
    for tool in aws terraform gh jq curl; do
        if ! command -v "$tool" &> /dev/null; then
            missing_tools+=("$tool")
        fi
    done
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        log_error "Missing required tools: ${missing_tools[*]}"
        log_info "Please install the missing tools and try again."
        exit 1
    fi
    
    # Check AWS credentials
    if ! aws sts get-caller-identity &> /dev/null; then
        log_error "AWS credentials not configured or invalid"
        log_info "Please run 'aws configure' or set AWS environment variables"
        exit 1
    fi
    
    # Check GitHub token
    if [ -n "${GITHUB_TOKEN:-}" ]; then
        if ! gh auth status &> /dev/null; then
            log_info "Authenticating with GitHub using provided token..."
            echo "$GITHUB_TOKEN" | gh auth login --with-token
        fi
    else
        if ! gh auth status &> /dev/null; then
            log_error "GitHub authentication required"
            log_info "Please run 'gh auth login' or set GITHUB_TOKEN environment variable"
            exit 1
        fi
    fi
    
    log_success "All prerequisites met"
}

# Validate configuration
validate_config() {
    log_info "Validating configuration..."
    
    # Required variables
    if [ -z "${GITHUB_ORG:-}" ]; then
        log_error "GitHub organization name is required"
        exit 1
    fi
    
    # Validate GitHub organization access
    if ! gh api "/orgs/$GITHUB_ORG" &> /dev/null; then
        log_error "Cannot access GitHub organization: $GITHUB_ORG"
        log_info "Please check organization name and token permissions"
        exit 1
    fi
    
    # Validate AWS region
    if ! aws ec2 describe-regions --region-names "$AWS_REGION" &> /dev/null; then
        log_error "Invalid AWS region: $AWS_REGION"
        exit 1
    fi
    
    # Validate runner configuration
    if [ "$MIN_RUNNERS" -gt "$MAX_RUNNERS" ]; then
        log_error "Minimum runners ($MIN_RUNNERS) cannot be greater than maximum runners ($MAX_RUNNERS)"
        exit 1
    fi
    
    if [ "$DESIRED_RUNNERS" -lt "$MIN_RUNNERS" ] || [ "$DESIRED_RUNNERS" -gt "$MAX_RUNNERS" ]; then
        log_error "Desired runners ($DESIRED_RUNNERS) must be between min ($MIN_RUNNERS) and max ($MAX_RUNNERS)"
        exit 1
    fi
    
    log_success "Configuration validation passed"
}

# Setup Terraform workspace
setup_terraform() {
    log_info "Setting up Terraform workspace..."
    
    local terraform_dir="$PROJECT_ROOT/scripts/terraform"
    cd "$terraform_dir"
    
    # Initialize Terraform
    log_info "Initializing Terraform..."
    terraform init
    
    # Create or select workspace
    if terraform workspace list | grep -q "$ENVIRONMENT"; then
        log_info "Selecting existing workspace: $ENVIRONMENT"
        terraform workspace select "$ENVIRONMENT"
    else
        log_info "Creating new workspace: $ENVIRONMENT"
        terraform workspace new "$ENVIRONMENT"
    fi
    
    # Generate terraform.tfvars
    log_info "Generating Terraform variables..."
    cat > terraform.tfvars << EOF
project_name = "$PROJECT_NAME"
environment = "$ENVIRONMENT"
aws_region = "$AWS_REGION"
github_organization = "$GITHUB_ORG"

# Runner configuration
runner_instance_type = "$INSTANCE_TYPE"
runner_min_size = $MIN_RUNNERS
runner_max_size = $MAX_RUNNERS
runner_desired_capacity = $DESIRED_RUNNERS

# VPC configuration
vpc_cidr = "10.0.0.0/16"
availability_zones = ["${AWS_REGION}a", "${AWS_REGION}b"]

# Tags
tags = {
  Project = "$PROJECT_NAME"
  Environment = "$ENVIRONMENT"
  ManagedBy = "terraform"
  CreatedBy = "$(whoami)"
}
EOF
    
    log_success "Terraform workspace ready"
}

# Deploy infrastructure
deploy_infrastructure() {
    log_info "Deploying infrastructure with Terraform..."
    
    local terraform_dir="$PROJECT_ROOT/scripts/terraform"
    cd "$terraform_dir"
    
    # Plan deployment
    log_info "Creating Terraform plan..."
    terraform plan -out=tfplan -var-file=terraform.tfvars
    
    if [ "$VALIDATE_ONLY" = true ]; then
        log_success "Validation completed successfully"
        return 0
    fi
    
    # Apply deployment
    if [ "$AUTO_APPROVE" = true ]; then
        log_info "Applying Terraform configuration (auto-approved)..."
        terraform apply -auto-approve tfplan
    else
        log_info "Applying Terraform configuration..."
        echo -e "${YELLOW}Please review the plan above and confirm deployment.${NC}"
        terraform apply tfplan
    fi
    
    # Get outputs
    log_info "Retrieving Terraform outputs..."
    terraform output -json > outputs.json
    
    # Display important outputs
    if [ -f outputs.json ]; then
        log_info "Infrastructure deployment completed:"
        
        if jq -e '.vpc_id.value' outputs.json &> /dev/null; then
            local vpc_id=$(jq -r '.vpc_id.value' outputs.json)
            log_info "  VPC ID: $vpc_id"
        fi
        
        if jq -e '.runner_asg_name.value' outputs.json &> /dev/null; then
            local asg_name=$(jq -r '.runner_asg_name.value' outputs.json)
            log_info "  Auto Scaling Group: $asg_name"
        fi
        
        if jq -e '.runner_role_arn.value' outputs.json &> /dev/null; then
            local role_arn=$(jq -r '.runner_role_arn.value' outputs.json)
            log_info "  Runner IAM Role: $role_arn"
        fi
    fi
    
    log_success "Infrastructure deployment completed"
}

# Configure GitHub organization
configure_github_org() {
    log_info "Configuring GitHub organization..."
    
    # Enable GitHub Actions
    log_info "Enabling GitHub Actions for organization..."
    gh api -X PUT "/orgs/$GITHUB_ORG/actions/permissions" \
        -f enabled=true \
        -f allowed_actions=selected \
        -f github_owned_allowed=true \
        -f verified_allowed=true
    
    # Configure workflow permissions
    log_info "Configuring workflow permissions..."
    gh api -X PUT "/orgs/$GITHUB_ORG/actions/permissions/workflow" \
        -f default_workflow_permissions=read \
        -f can_approve_pull_request_reviews=false
    
    # Create runner groups
    log_info "Creating runner groups..."
    local runner_groups=("default-runners" "production-runners" "security-runners")
    
    for group in "${runner_groups[@]}"; do
        log_info "Creating runner group: $group"
        if ! gh api -X POST "/orgs/$GITHUB_ORG/actions/runner-groups" \
            -f name="$group" \
            -f visibility="all" \
            -f allows_public_repositories=false &> /dev/null; then
            log_warning "Runner group '$group' may already exist"
        fi
    done
    
    log_success "GitHub organization configured"
}

# Set up workflow templates
setup_workflow_templates() {
    log_info "Setting up organization workflow templates..."
    
    # Check if .github repository exists
    if ! gh repo view "$GITHUB_ORG/.github" &> /dev/null; then
        log_info "Creating .github repository..."
        gh repo create "$GITHUB_ORG/.github" \
            --public \
            --description "Organization workflow templates and configuration"
    fi
    
    # Clone repository
    local temp_dir=$(mktemp -d)
    log_info "Cloning .github repository to $temp_dir..."
    gh repo clone "$GITHUB_ORG/.github" "$temp_dir"
    
    # Create workflow templates directory
    mkdir -p "$temp_dir/workflow-templates"
    
    # Copy workflow templates
    log_info "Creating workflow templates..."
    
    # CI/CD Template
    cat > "$temp_dir/workflow-templates/ci-cd.yml" << 'EOF'
name: CI/CD Pipeline
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: self-hosted
    strategy:
      matrix:
        node-version: [16, 18, 20]
    steps:
      - uses: actions/checkout@v4
      - name: Setup Node.js ${{ matrix.node-version }}
        uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
          cache: 'npm'
      - name: Install dependencies
        run: npm ci
      - name: Run tests
        run: npm test
      - name: Run security scan
        uses: github/codeql-action/analyze@v2

  build:
    needs: test
    runs-on: self-hosted
    steps:
      - uses: actions/checkout@v4
      - name: Build application
        run: npm run build
      - name: Upload build artifacts
        uses: actions/upload-artifact@v3
        with:
          name: build-files
          path: dist/

  deploy:
    needs: build
    runs-on: self-hosted
    if: github.ref == 'refs/heads/main'
    environment: production
    steps:
      - name: Deploy to production
        run: echo "Deploying to production"
EOF

    # Security Scan Template
    cat > "$temp_dir/workflow-templates/security-scan.yml" << 'EOF'
name: Security Scan
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
  schedule:
    - cron: '0 2 * * 1'  # Weekly scan

jobs:
  security-scan:
    runs-on: self-hosted
    permissions:
      actions: read
      contents: read
      security-events: write
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
      
      - name: Initialize CodeQL
        uses: github/codeql-action/init@v2
        with:
          languages: ${{ matrix.language }}
      
      - name: Autobuild
        uses: github/codeql-action/autobuild@v2
      
      - name: Perform CodeQL Analysis
        uses: github/codeql-action/analyze@v2
      
      - name: Run dependency check
        uses: dependency-check/Dependency-Check_Action@main
        with:
          project: 'security-scan'
          path: '.'
EOF

    # Template properties
    cat > "$temp_dir/workflow-templates/ci-cd.properties.json" << 'EOF'
{
    "name": "CI/CD Pipeline",
    "description": "Complete CI/CD pipeline with testing, building, and deployment",
    "iconName": "rocket",
    "categories": ["Deployment"]
}
EOF

    cat > "$temp_dir/workflow-templates/security-scan.properties.json" << 'EOF'
{
    "name": "Security Scan",
    "description": "Comprehensive security scanning with CodeQL and dependency check",
    "iconName": "shield",
    "categories": ["Security"]
}
EOF

    # Commit and push templates
    cd "$temp_dir"
    git config user.name "GitHub Actions Automation"
    git config user.email "actions@$GITHUB_ORG.com"
    git add .
    if git commit -m "Add organization workflow templates"; then
        git push origin main
        log_success "Workflow templates uploaded"
    else
        log_info "No changes to commit"
    fi
    
    # Cleanup
    rm -rf "$temp_dir"
}

# Configure secrets
configure_secrets() {
    log_info "Configuring organization secrets..."
    
    # AWS credentials (if available)
    if [ -n "${AWS_ACCESS_KEY_ID:-}" ] && [ -n "${AWS_SECRET_ACCESS_KEY:-}" ]; then
        log_info "Setting AWS credentials as organization secrets..."
        gh secret set AWS_ACCESS_KEY_ID --org "$GITHUB_ORG" --body "$AWS_ACCESS_KEY_ID"
        gh secret set AWS_SECRET_ACCESS_KEY --org "$GITHUB_ORG" --body "$AWS_SECRET_ACCESS_KEY"
        gh secret set AWS_REGION --org "$GITHUB_ORG" --body "$AWS_REGION"
    fi
    
    # Additional secrets can be set here
    # gh secret set CUSTOM_SECRET --org "$GITHUB_ORG" --body "secret-value"
    
    log_success "Organization secrets configured"
}

# Set up monitoring
setup_monitoring() {
    log_info "Setting up monitoring and alerting..."
    
    # Create CloudWatch dashboard
    local dashboard_name="$PROJECT_NAME-$ENVIRONMENT"
    
    cat > /tmp/dashboard.json << EOF
{
  "widgets": [
    {
      "type": "metric",
      "x": 0,
      "y": 0,
      "width": 12,
      "height": 6,
      "properties": {
        "metrics": [
          ["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", "$PROJECT_NAME-runners-$ENVIRONMENT"]
        ],
        "period": 300,
        "stat": "Average",
        "region": "$AWS_REGION",
        "title": "Runner CPU Utilization"
      }
    },
    {
      "type": "metric",
      "x": 12,
      "y": 0,
      "width": 12,
      "height": 6,
      "properties": {
        "metrics": [
          ["AWS/AutoScaling", "GroupDesiredCapacity", "AutoScalingGroupName", "$PROJECT_NAME-runners-$ENVIRONMENT"],
          [".", "GroupInServiceInstances", ".", "."],
          [".", "GroupTotalInstances", ".", "."]
        ],
        "period": 300,
        "stat": "Average",
        "region": "$AWS_REGION",
        "title": "Runner Capacity"
      }
    }
  ]
}
EOF

    aws cloudwatch put-dashboard \
        --dashboard-name "$dashboard_name" \
        --dashboard-body file:///tmp/dashboard.json \
        --region "$AWS_REGION"
    
    # Create CloudWatch alarms
    log_info "Creating CloudWatch alarms..."
    
    # Runner availability alarm
    aws cloudwatch put-metric-alarm \
        --alarm-name "$PROJECT_NAME-$ENVIRONMENT-runner-availability" \
        --alarm-description "Monitor GitHub Actions runner availability" \
        --metric-name GroupInServiceInstances \
        --namespace AWS/AutoScaling \
        --statistic Average \
        --period 300 \
        --evaluation-periods 2 \
        --threshold 1 \
        --comparison-operator LessThanThreshold \
        --dimensions Name=AutoScalingGroupName,Value="$PROJECT_NAME-runners-$ENVIRONMENT" \
        --region "$AWS_REGION"
    
    log_success "Monitoring configured"
    
    rm -f /tmp/dashboard.json
}

# Validate deployment
validate_deployment() {
    log_info "Validating deployment..."
    
    # Check GitHub organization settings
    log_info "Checking GitHub Actions permissions..."
    local permissions=$(gh api "/orgs/$GITHUB_ORG/actions/permissions")
    if echo "$permissions" | jq -e '.enabled == true' &> /dev/null; then
        log_success "GitHub Actions is enabled"
    else
        log_error "GitHub Actions is not enabled"
        return 1
    fi
    
    # Check runner availability
    log_info "Checking runner availability..."
    local runners=$(gh api "/orgs/$GITHUB_ORG/actions/runners")
    local total_runners=$(echo "$runners" | jq '.total_count')
    local online_runners=$(echo "$runners" | jq '[.runners[] | select(.status == "online")] | length')
    
    log_info "Total runners: $total_runners"
    log_info "Online runners: $online_runners"
    
    if [ "$online_runners" -gt 0 ]; then
        log_success "Runners are online and available"
    else
        log_warning "No runners are currently online"
        log_info "Runners may still be starting up. Check again in a few minutes."
    fi
    
    # Check infrastructure
    if [ -f "outputs.json" ]; then
        log_info "Checking infrastructure..."
        local asg_name=$(jq -r '.runner_asg_name.value // empty' outputs.json)
        if [ -n "$asg_name" ]; then
            local asg_status=$(aws autoscaling describe-auto-scaling-groups \
                --auto-scaling-group-names "$asg_name" \
                --region "$AWS_REGION" \
                --query 'AutoScalingGroups[0].Instances[?LifecycleState==`InService`]' \
                --output json)
            local healthy_instances=$(echo "$asg_status" | jq length)
            log_info "Healthy instances in ASG: $healthy_instances"
        fi
    fi
    
    log_success "Deployment validation completed"
}

# Cleanup resources
cleanup_deployment() {
    log_info "Cleaning up deployment resources..."
    
    if [ "$AUTO_APPROVE" = true ]; then
        local approve_flag="-auto-approve"
    else
        local approve_flag=""
        echo -e "${YELLOW}This will destroy all deployed resources. Are you sure? (y/N)${NC}"
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            log_info "Cleanup cancelled"
            return 0
        fi
    fi
    
    local terraform_dir="$PROJECT_ROOT/scripts/terraform"
    cd "$terraform_dir"
    
    # Select workspace
    if terraform workspace list | grep -q "$ENVIRONMENT"; then
        terraform workspace select "$ENVIRONMENT"
    else
        log_error "Workspace $ENVIRONMENT not found"
        return 1
    fi
    
    # Destroy infrastructure
    log_info "Destroying infrastructure..."
    terraform destroy $approve_flag -var-file=terraform.tfvars
    
    # Remove CloudWatch dashboard
    log_info "Removing CloudWatch dashboard..."
    aws cloudwatch delete-dashboards \
        --dashboard-names "$PROJECT_NAME-$ENVIRONMENT" \
        --region "$AWS_REGION" || true
    
    # Remove CloudWatch alarms
    log_info "Removing CloudWatch alarms..."
    aws cloudwatch delete-alarms \
        --alarm-names "$PROJECT_NAME-$ENVIRONMENT-runner-availability" \
        --region "$AWS_REGION" || true
    
    log_success "Cleanup completed"
}

# Generate deployment report
generate_report() {
    log_info "Generating deployment report..."
    
    local report_file="$PROJECT_ROOT/deployment-report-$(date +%Y%m%d-%H%M%S).md"
    
    cat > "$report_file" << EOF
# GitHub Actions Enterprise CI/CD Platform Deployment Report

**Generated:** $(date)
**Organization:** $GITHUB_ORG
**Environment:** $ENVIRONMENT
**Region:** $AWS_REGION

## Configuration

- **Project Name:** $PROJECT_NAME
- **Instance Type:** $INSTANCE_TYPE
- **Runner Capacity:** $MIN_RUNNERS - $MAX_RUNNERS (desired: $DESIRED_RUNNERS)

## Deployment Status

EOF

    # Add runner information
    if command -v gh &> /dev/null && gh auth status &> /dev/null; then
        local runners=$(gh api "/orgs/$GITHUB_ORG/actions/runners" 2>/dev/null || echo '{"total_count": 0, "runners": []}')
        local total_runners=$(echo "$runners" | jq '.total_count')
        local online_runners=$(echo "$runners" | jq '[.runners[] | select(.status == "online")] | length')
        
        cat >> "$report_file" << EOF
### GitHub Actions Runners

- **Total Runners:** $total_runners
- **Online Runners:** $online_runners
- **Organization:** https://github.com/$GITHUB_ORG

EOF
    fi
    
    # Add infrastructure information
    if [ -f "scripts/terraform/outputs.json" ]; then
        cat >> "$report_file" << EOF
### Infrastructure

EOF
        
        if jq -e '.vpc_id.value' scripts/terraform/outputs.json &> /dev/null; then
            local vpc_id=$(jq -r '.vpc_id.value' scripts/terraform/outputs.json)
            echo "- **VPC ID:** $vpc_id" >> "$report_file"
        fi
        
        if jq -e '.runner_asg_name.value' scripts/terraform/outputs.json &> /dev/null; then
            local asg_name=$(jq -r '.runner_asg_name.value' scripts/terraform/outputs.json)
            echo "- **Auto Scaling Group:** $asg_name" >> "$report_file"
        fi
    fi
    
    cat >> "$report_file" << EOF

## Next Steps

1. **Test the Platform**
   - Create a test repository with a simple workflow
   - Verify workflows execute on self-hosted runners

2. **Configure Additional Settings**
   - Set up additional organization secrets as needed
   - Configure repository-specific settings

3. **Team Onboarding**
   - Train development teams on GitHub Actions
   - Provide documentation and best practices

4. **Monitoring**
   - Set up additional monitoring and alerting
   - Configure notification channels

## Resources

- **GitHub Organization:** https://github.com/$GITHUB_ORG
- **AWS Console:** https://console.aws.amazon.com/ec2/v2/home?region=$AWS_REGION
- **CloudWatch Dashboard:** https://console.aws.amazon.com/cloudwatch/home?region=$AWS_REGION#dashboards:name=$PROJECT_NAME-$ENVIRONMENT

EOF
    
    log_success "Deployment report generated: $report_file"
}

# Main function
main() {
    local GITHUB_ORG=""
    local GITHUB_TOKEN=""
    local INSTANCE_TYPE="t3.large"
    local MIN_RUNNERS=2
    local MAX_RUNNERS=10
    local DESIRED_RUNNERS=3
    local AUTO_APPROVE=false
    local VALIDATE_ONLY=false
    local CLEANUP=false
    
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
            -r|--region)
                AWS_REGION="$2"
                shift 2
                ;;
            -e|--environment)
                ENVIRONMENT="$2"
                shift 2
                ;;
            -i|--instance-type)
                INSTANCE_TYPE="$2"
                shift 2
                ;;
            -m|--min-runners)
                MIN_RUNNERS="$2"
                shift 2
                ;;
            -M|--max-runners)
                MAX_RUNNERS="$2"
                shift 2
                ;;
            -d|--desired-runners)
                DESIRED_RUNNERS="$2"
                shift 2
                ;;
            -a|--auto-approve)
                AUTO_APPROVE=true
                shift
                ;;
            -v|--validate-only)
                VALIDATE_ONLY=true
                shift
                ;;
            -c|--cleanup)
                CLEANUP=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Use environment variables if not provided via CLI
    GITHUB_ORG="${GITHUB_ORG:-${GITHUB_ORG:-}}"
    GITHUB_TOKEN="${GITHUB_TOKEN:-${GITHUB_TOKEN:-}}"
    AUTO_APPROVE="${AUTO_APPROVE:-${AUTO_APPROVE:-false}}"
    
    # Display configuration
    log_info "GitHub Actions Enterprise CI/CD Platform Deployment"
    log_info "=================================================="
    log_info "Organization: $GITHUB_ORG"
    log_info "Environment: $ENVIRONMENT"
    log_info "AWS Region: $AWS_REGION"
    log_info "Instance Type: $INSTANCE_TYPE"
    log_info "Runner Capacity: $MIN_RUNNERS - $MAX_RUNNERS (desired: $DESIRED_RUNNERS)"
    log_info "Auto Approve: $AUTO_APPROVE"
    log_info "Validate Only: $VALIDATE_ONLY"
    log_info "Cleanup: $CLEANUP"
    echo
    
    # Execute deployment steps
    check_prerequisites
    validate_config
    
    if [ "$CLEANUP" = true ]; then
        cleanup_deployment
        exit 0
    fi
    
    setup_terraform
    deploy_infrastructure
    
    if [ "$VALIDATE_ONLY" = true ]; then
        log_success "Validation completed successfully"
        exit 0
    fi
    
    configure_github_org
    setup_workflow_templates
    configure_secrets
    setup_monitoring
    
    # Wait for runners to come online
    log_info "Waiting for runners to come online..."
    sleep 60
    
    validate_deployment
    generate_report
    
    log_success "GitHub Actions Enterprise CI/CD Platform deployment completed successfully!"
    log_info "Check the deployment report for next steps and additional information."
}

# Execute main function with all arguments
main "$@"