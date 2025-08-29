#!/bin/bash
# Azure Sentinel SIEM - Bash Deployment Script
# Main deployment script for Azure Sentinel SIEM solution on Linux/Unix environments

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="sentinel_deployment_$(date +%Y%m%d_%H%M%S).log"
CONFIG_FILE="${SCRIPT_DIR}/sentinel_config.json"

# Default values
RESOURCE_GROUP_NAME=""
LOCATION="East US 2"
WORKSPACE_NAME=""
SUBSCRIPTION_ID=""
RETENTION_DAYS=730
DAILY_QUOTA_GB=500
ENABLE_DATA_CONNECTORS=false
CREATE_SAMPLE_RULES=false
VALIDATE_ONLY=false

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case $level in
        "INFO")
            echo -e "${BLUE}[$timestamp] [INFO]${NC} $message" | tee -a "$LOG_FILE"
            ;;
        "SUCCESS")
            echo -e "${GREEN}[$timestamp] [SUCCESS]${NC} $message" | tee -a "$LOG_FILE"
            ;;
        "WARNING")
            echo -e "${YELLOW}[$timestamp] [WARNING]${NC} $message" | tee -a "$LOG_FILE"
            ;;
        "ERROR")
            echo -e "${RED}[$timestamp] [ERROR]${NC} $message" | tee -a "$LOG_FILE"
            ;;
    esac
}

# Usage information
usage() {
    cat << EOF
Azure Sentinel SIEM Deployment Script

Usage: $0 [OPTIONS]

Required Options:
    -s, --subscription-id SUBSCRIPTION_ID    Azure subscription ID
    -g, --resource-group RESOURCE_GROUP      Resource group name
    -w, --workspace WORKSPACE_NAME           Log Analytics workspace name

Optional Options:
    -l, --location LOCATION                  Azure location (default: East US 2)
    -r, --retention-days DAYS                Data retention days (default: 730)
    -q, --daily-quota-gb GB                  Daily ingestion quota in GB (default: 500)
    -c, --enable-connectors                  Enable data connectors
    -a, --create-sample-rules                Create sample analytics rules
    -v, --validate-only                      Only validate existing deployment
    -f, --config-file FILE                   Configuration file path
    -h, --help                               Show this help message

Examples:
    $0 -s "12345678-1234-5678-9012-123456789012" \\
       -g "rg-sentinel-prod-001" \\
       -w "law-sentinel-prod-001" \\
       -c -a

    $0 --validate-only -s "sub-id" -g "rg-name" -w "workspace-name"
EOF
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -s|--subscription-id)
                SUBSCRIPTION_ID="$2"
                shift 2
                ;;
            -g|--resource-group)
                RESOURCE_GROUP_NAME="$2"
                shift 2
                ;;
            -w|--workspace)
                WORKSPACE_NAME="$2"
                shift 2
                ;;
            -l|--location)
                LOCATION="$2"
                shift 2
                ;;
            -r|--retention-days)
                RETENTION_DAYS="$2"
                shift 2
                ;;
            -q|--daily-quota-gb)
                DAILY_QUOTA_GB="$2"
                shift 2
                ;;
            -c|--enable-connectors)
                ENABLE_DATA_CONNECTORS=true
                shift
                ;;
            -a|--create-sample-rules)
                CREATE_SAMPLE_RULES=true
                shift
                ;;
            -v|--validate-only)
                VALIDATE_ONLY=true
                shift
                ;;
            -f|--config-file)
                CONFIG_FILE="$2"
                shift 2
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                log "ERROR" "Unknown parameter: $1"
                usage
                exit 1
                ;;
        esac
    done
}

# Load configuration from JSON file
load_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        log "INFO" "Loading configuration from: $CONFIG_FILE"
        
        # Use jq to parse JSON config (if available)
        if command -v jq >/dev/null 2>&1; then
            SUBSCRIPTION_ID=${SUBSCRIPTION_ID:-$(jq -r '.subscription_id // empty' "$CONFIG_FILE")}
            RESOURCE_GROUP_NAME=${RESOURCE_GROUP_NAME:-$(jq -r '.resource_group_name // empty' "$CONFIG_FILE")}
            WORKSPACE_NAME=${WORKSPACE_NAME:-$(jq -r '.workspace_name // empty' "$CONFIG_FILE")}
            LOCATION=${LOCATION:-$(jq -r '.location // "East US 2"' "$CONFIG_FILE")}
            RETENTION_DAYS=${RETENTION_DAYS:-$(jq -r '.retention_days // 730' "$CONFIG_FILE")}
            DAILY_QUOTA_GB=${DAILY_QUOTA_GB:-$(jq -r '.daily_quota_gb // 500' "$CONFIG_FILE")}
        else
            log "WARNING" "jq not found. JSON config file will be ignored."
        fi
    fi
}

# Validate prerequisites
validate_prerequisites() {
    log "INFO" "Validating prerequisites..."
    
    # Check if Azure CLI is installed
    if ! command -v az >/dev/null 2>&1; then
        log "ERROR" "Azure CLI is not installed. Please install it first."
        log "INFO" "Installation guide: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
        exit 1
    fi
    
    # Check Azure CLI version
    local az_version=$(az --version | head -n1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
    log "INFO" "Azure CLI version: $az_version"
    
    # Check if user is logged in
    if ! az account show >/dev/null 2>&1; then
        log "ERROR" "Not logged in to Azure. Please run 'az login' first."
        exit 1
    fi
    
    # Validate required parameters
    if [[ -z "$SUBSCRIPTION_ID" ]] || [[ -z "$RESOURCE_GROUP_NAME" ]] || [[ -z "$WORKSPACE_NAME" ]]; then
        log "ERROR" "Missing required parameters. Use --help for usage information."
        exit 1
    fi
    
    # Set subscription context
    log "INFO" "Setting subscription context: $SUBSCRIPTION_ID"
    az account set --subscription "$SUBSCRIPTION_ID"
    
    # Verify subscription access
    local current_sub=$(az account show --query id -o tsv)
    if [[ "$current_sub" != "$SUBSCRIPTION_ID" ]]; then
        log "ERROR" "Failed to set subscription context"
        exit 1
    fi
    
    log "SUCCESS" "Prerequisites validation completed"
}

# Create or verify resource group
create_resource_group() {
    log "INFO" "Creating or verifying resource group: $RESOURCE_GROUP_NAME"
    
    if az group show --name "$RESOURCE_GROUP_NAME" >/dev/null 2>&1; then
        log "INFO" "Resource group already exists: $RESOURCE_GROUP_NAME"
    else
        log "INFO" "Creating resource group: $RESOURCE_GROUP_NAME in $LOCATION"
        
        az group create \
            --name "$RESOURCE_GROUP_NAME" \
            --location "$LOCATION" \
            --tags Environment="Production" Solution="Azure Sentinel SIEM" CostCenter="Security Operations" \
            --output none
        
        if [[ $? -eq 0 ]]; then
            log "SUCCESS" "Resource group created: $RESOURCE_GROUP_NAME"
        else
            log "ERROR" "Failed to create resource group"
            exit 1
        fi
    fi
}

# Create Log Analytics workspace
create_workspace() {
    log "INFO" "Creating Log Analytics workspace: $WORKSPACE_NAME"
    
    if az monitor log-analytics workspace show \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --workspace-name "$WORKSPACE_NAME" >/dev/null 2>&1; then
        log "INFO" "Workspace already exists: $WORKSPACE_NAME"
    else
        log "INFO" "Creating new workspace: $WORKSPACE_NAME"
        
        az monitor log-analytics workspace create \
            --resource-group "$RESOURCE_GROUP_NAME" \
            --workspace-name "$WORKSPACE_NAME" \
            --location "$LOCATION" \
            --sku "PerGB2018" \
            --retention-time "$RETENTION_DAYS" \
            --daily-quota-gb "$DAILY_QUOTA_GB" \
            --tags Environment="Production" Solution="Azure Sentinel SIEM" \
            --output none
        
        if [[ $? -eq 0 ]]; then
            log "SUCCESS" "Log Analytics workspace created: $WORKSPACE_NAME"
            
            # Wait for workspace to be ready
            log "INFO" "Waiting for workspace provisioning to complete..."
            local max_attempts=20
            local attempt=1
            
            while [[ $attempt -le $max_attempts ]]; do
                local status=$(az monitor log-analytics workspace show \
                    --resource-group "$RESOURCE_GROUP_NAME" \
                    --workspace-name "$WORKSPACE_NAME" \
                    --query "provisioningState" -o tsv 2>/dev/null || echo "Unknown")
                
                if [[ "$status" == "Succeeded" ]]; then
                    log "SUCCESS" "Workspace provisioning completed"
                    break
                elif [[ "$status" == "Failed" ]]; then
                    log "ERROR" "Workspace provisioning failed"
                    exit 1
                else
                    log "INFO" "Workspace provisioning status: $status (attempt $attempt/$max_attempts)"
                    sleep 30
                    ((attempt++))
                fi
            done
            
            if [[ $attempt -gt $max_attempts ]]; then
                log "WARNING" "Workspace provisioning status check timed out"
            fi
        else
            log "ERROR" "Failed to create Log Analytics workspace"
            exit 1
        fi
    fi
}

# Enable Azure Sentinel
enable_sentinel() {
    log "INFO" "Enabling Azure Sentinel on workspace: $WORKSPACE_NAME"
    
    # Check if Sentinel is already enabled
    if az sentinel workspace show \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --workspace-name "$WORKSPACE_NAME" >/dev/null 2>&1; then
        log "INFO" "Azure Sentinel already enabled"
    else
        log "INFO" "Enabling Azure Sentinel..."
        
        az sentinel workspace create \
            --resource-group "$RESOURCE_GROUP_NAME" \
            --workspace-name "$WORKSPACE_NAME" \
            --output none
        
        if [[ $? -eq 0 ]]; then
            log "SUCCESS" "Azure Sentinel enabled successfully"
        else
            log "ERROR" "Failed to enable Azure Sentinel"
            exit 1
        fi
    fi
}

# Configure data connectors
configure_data_connectors() {
    if [[ "$ENABLE_DATA_CONNECTORS" != "true" ]]; then
        log "INFO" "Skipping data connectors configuration"
        return 0
    fi
    
    log "INFO" "Configuring data connectors..."
    
    local configured_connectors=0
    
    # Azure Activity connector
    log "INFO" "Configuring Azure Activity connector..."
    if az sentinel data-connector create \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --workspace-name "$WORKSPACE_NAME" \
        --name "azure-activity" \
        --kind "AzureActivity" \
        --subscription-id "$SUBSCRIPTION_ID" >/dev/null 2>&1; then
        log "SUCCESS" "Azure Activity connector configured"
        ((configured_connectors++))
    else
        log "WARNING" "Failed to configure Azure Activity connector"
    fi
    
    # Azure Security Center connector
    log "INFO" "Configuring Azure Security Center connector..."
    if az sentinel data-connector create \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --workspace-name "$WORKSPACE_NAME" \
        --name "azure-security-center" \
        --kind "AzureSecurityCenter" \
        --subscription-id "$SUBSCRIPTION_ID" >/dev/null 2>&1; then
        log "SUCCESS" "Azure Security Center connector configured"
        ((configured_connectors++))
    else
        log "WARNING" "Failed to configure Azure Security Center connector"
    fi
    
    # Azure Active Directory connector
    log "INFO" "Configuring Azure Active Directory connector..."
    if az sentinel data-connector create \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --workspace-name "$WORKSPACE_NAME" \
        --name "azure-active-directory" \
        --kind "AzureActiveDirectory" >/dev/null 2>&1; then
        log "SUCCESS" "Azure Active Directory connector configured"
        ((configured_connectors++))
    else
        log "WARNING" "Failed to configure Azure Active Directory connector"
    fi
    
    log "INFO" "Data connectors configuration completed. Configured: $configured_connectors"
}

# Create sample analytics rules
create_analytics_rules() {
    if [[ "$CREATE_SAMPLE_RULES" != "true" ]]; then
        log "INFO" "Skipping sample analytics rules creation"
        return 0
    fi
    
    log "INFO" "Creating sample analytics rules..."
    
    local created_rules=0
    local rules_dir="${SCRIPT_DIR}/analytics_rules"
    
    # Create rules directory if it doesn't exist
    mkdir -p "$rules_dir"
    
    # Brute Force Detection Rule
    cat > "${rules_dir}/brute_force_rule.json" << EOF
{
  "kind": "Scheduled",
  "properties": {
    "displayName": "Brute Force Attack Detection",
    "description": "Detects multiple failed login attempts from single source IP",
    "severity": "Medium",
    "enabled": true,
    "query": "SigninLogs\\n| where TimeGenerated >= ago(1h)\\n| where ResultType !in (\\"0\\", \\"50125\\", \\"50140\\")\\n| where UserPrincipalName != \\"\\"\\n| summarize FailedAttempts = count(), Users = make_set(UserPrincipalName) by IPAddress\\n| where FailedAttempts >= 10\\n| project IPAddress, FailedAttempts, Users",
    "queryFrequency": "PT1H",
    "queryPeriod": "PT1H",
    "triggerOperator": "GreaterThan",
    "triggerThreshold": 0,
    "tactics": ["CredentialAccess", "InitialAccess"],
    "techniques": ["T1110", "T1078"]
  }
}
EOF
    
    if az sentinel alert-rule create \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --workspace-name "$WORKSPACE_NAME" \
        --rule-id "brute-force-detection" \
        --rule "${rules_dir}/brute_force_rule.json" >/dev/null 2>&1; then
        log "SUCCESS" "Brute Force Detection rule created"
        ((created_rules++))
    else
        log "WARNING" "Failed to create Brute Force Detection rule"
    fi
    
    # Suspicious PowerShell Rule
    cat > "${rules_dir}/suspicious_powershell_rule.json" << EOF
{
  "kind": "Scheduled",
  "properties": {
    "displayName": "Suspicious PowerShell Activity",
    "description": "Detects potentially malicious PowerShell execution patterns",
    "severity": "High",
    "enabled": true,
    "query": "SecurityEvent\\n| where TimeGenerated >= ago(1h)\\n| where EventID == 4688\\n| where Process endswith \\"powershell.exe\\"\\n| where CommandLine contains \\"Download\\" or CommandLine contains \\"Invoke-\\" or CommandLine contains \\"IEX\\"\\n| project TimeGenerated, Computer, Account, CommandLine",
    "queryFrequency": "PT30M",
    "queryPeriod": "PT1H",
    "triggerOperator": "GreaterThan",
    "triggerThreshold": 0,
    "tactics": ["Execution", "CommandAndControl"],
    "techniques": ["T1059.001", "T1071.001"]
  }
}
EOF
    
    if az sentinel alert-rule create \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --workspace-name "$WORKSPACE_NAME" \
        --rule-id "suspicious-powershell" \
        --rule "${rules_dir}/suspicious_powershell_rule.json" >/dev/null 2>&1; then
        log "SUCCESS" "Suspicious PowerShell rule created"
        ((created_rules++))
    else
        log "WARNING" "Failed to create Suspicious PowerShell rule"
    fi
    
    log "INFO" "Analytics rules creation completed. Created: $created_rules"
}

# Configure monitoring and diagnostics
configure_monitoring() {
    log "INFO" "Configuring monitoring and diagnostics..."
    
    # Get workspace resource ID
    local workspace_id=$(az monitor log-analytics workspace show \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --workspace-name "$WORKSPACE_NAME" \
        --query "id" -o tsv)
    
    if [[ -n "$workspace_id" ]]; then
        # Configure diagnostic settings
        if az monitor diagnostic-settings create \
            --name "sentinel-diagnostics" \
            --resource "$workspace_id" \
            --workspace "$workspace_id" \
            --logs '[{"category":"Audit","enabled":true,"retentionPolicy":{"enabled":true,"days":90}}]' >/dev/null 2>&1; then
            log "SUCCESS" "Diagnostic settings configured"
        else
            log "WARNING" "Failed to configure diagnostic settings"
        fi
    else
        log "WARNING" "Could not retrieve workspace ID for monitoring configuration"
    fi
}

# Validate deployment
validate_deployment() {
    log "INFO" "Validating deployment..."
    
    local validation_passed=true
    
    # Check resource group
    if az group show --name "$RESOURCE_GROUP_NAME" >/dev/null 2>&1; then
        log "SUCCESS" "✅ Resource group exists"
    else
        log "ERROR" "❌ Resource group not found"
        validation_passed=false
    fi
    
    # Check Log Analytics workspace
    if az monitor log-analytics workspace show \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --workspace-name "$WORKSPACE_NAME" >/dev/null 2>&1; then
        log "SUCCESS" "✅ Log Analytics workspace exists"
        
        # Get workspace details
        local workspace_id=$(az monitor log-analytics workspace show \
            --resource-group "$RESOURCE_GROUP_NAME" \
            --workspace-name "$WORKSPACE_NAME" \
            --query "customerId" -o tsv)
        log "INFO" "Workspace Customer ID: $workspace_id"
    else
        log "ERROR" "❌ Log Analytics workspace not found"
        validation_passed=false
    fi
    
    # Check Sentinel workspace
    if az sentinel workspace show \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --workspace-name "$WORKSPACE_NAME" >/dev/null 2>&1; then
        log "SUCCESS" "✅ Azure Sentinel enabled"
    else
        log "ERROR" "❌ Azure Sentinel not enabled"
        validation_passed=false
    fi
    
    # Check data connectors
    local connector_count=$(az sentinel data-connector list \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --workspace-name "$WORKSPACE_NAME" \
        --query "length(@)" -o tsv 2>/dev/null || echo "0")
    
    if [[ "$connector_count" -gt 0 ]]; then
        log "SUCCESS" "✅ Data connectors configured ($connector_count found)"
    else
        log "INFO" "ℹ️  No data connectors found"
    fi
    
    # Check analytics rules
    local rules_count=$(az sentinel alert-rule list \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --workspace-name "$WORKSPACE_NAME" \
        --query "length(@)" -o tsv 2>/dev/null || echo "0")
    
    if [[ "$rules_count" -gt 0 ]]; then
        log "SUCCESS" "✅ Analytics rules configured ($rules_count found)"
    else
        log "INFO" "ℹ️  No analytics rules found"
    fi
    
    if [[ "$validation_passed" == "true" ]]; then
        log "SUCCESS" "All critical validations passed!"
        return 0
    else
        log "ERROR" "Some validations failed"
        return 1
    fi
}

# Create post-deployment summary
create_summary() {
    local summary_file="sentinel_deployment_summary_$(date +%Y%m%d_%H%M%S).json"
    
    log "INFO" "Creating deployment summary: $summary_file"
    
    # Get workspace details
    local workspace_details=$(az monitor log-analytics workspace show \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --workspace-name "$WORKSPACE_NAME" \
        --query "{customerID:customerId,location:location,provisioningState:provisioningState}" 2>/dev/null || echo "{}")
    
    cat > "$summary_file" << EOF
{
  "deploymentStatus": "Success",
  "deploymentTime": "$(date -Iseconds)",
  "configuration": {
    "subscriptionId": "$SUBSCRIPTION_ID",
    "resourceGroupName": "$RESOURCE_GROUP_NAME",
    "workspaceName": "$WORKSPACE_NAME",
    "location": "$LOCATION",
    "retentionDays": $RETENTION_DAYS,
    "dailyQuotaGB": $DAILY_QUOTA_GB
  },
  "workspace": $workspace_details,
  "features": {
    "dataConnectorsEnabled": $ENABLE_DATA_CONNECTORS,
    "sampleRulesCreated": $CREATE_SAMPLE_RULES
  },
  "portalUrl": "https://portal.azure.com/#asset/Microsoft_Azure_Security_Insights/MainMenuBlade/0/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_NAME/providers/Microsoft.OperationalInsights/workspaces/$WORKSPACE_NAME"
}
EOF
    
    log "SUCCESS" "Deployment summary created: $summary_file"
}

# Cleanup function
cleanup() {
    log "INFO" "Cleaning up temporary files..."
    rm -rf "${SCRIPT_DIR}/analytics_rules" 2>/dev/null || true
}

# Main execution function
main() {
    # Set trap for cleanup
    trap cleanup EXIT
    
    log "INFO" "Starting Azure Sentinel SIEM deployment..."
    log "INFO" "Script version: 1.0.0"
    log "INFO" "Log file: $LOG_FILE"
    
    # Parse arguments and load configuration
    parse_args "$@"
    load_config
    
    # Display configuration
    log "INFO" "Configuration:"
    log "INFO" "  Subscription ID: $SUBSCRIPTION_ID"
    log "INFO" "  Resource Group: $RESOURCE_GROUP_NAME"
    log "INFO" "  Workspace Name: $WORKSPACE_NAME"
    log "INFO" "  Location: $LOCATION"
    log "INFO" "  Retention Days: $RETENTION_DAYS"
    log "INFO" "  Daily Quota GB: $DAILY_QUOTA_GB"
    log "INFO" "  Enable Data Connectors: $ENABLE_DATA_CONNECTORS"
    log "INFO" "  Create Sample Rules: $CREATE_SAMPLE_RULES"
    log "INFO" "  Validate Only: $VALIDATE_ONLY"
    
    # Validate prerequisites
    validate_prerequisites
    
    if [[ "$VALIDATE_ONLY" == "true" ]]; then
        log "INFO" "Running validation only..."
        if validate_deployment; then
            log "SUCCESS" "Validation completed successfully!"
            exit 0
        else
            log "ERROR" "Validation failed!"
            exit 1
        fi
    fi
    
    # Execute deployment steps
    create_resource_group
    create_workspace
    enable_sentinel
    configure_data_connectors
    create_analytics_rules
    configure_monitoring
    
    # Validate deployment
    log "INFO" "Running post-deployment validation..."
    if validate_deployment; then
        log "SUCCESS" "Deployment and validation completed successfully!"
        
        # Create deployment summary
        create_summary
        
        # Display next steps
        log "INFO" "Next steps:"
        log "INFO" "  1. Access Azure Sentinel: https://portal.azure.com/#asset/Microsoft_Azure_Security_Insights/MainMenuBlade"
        log "INFO" "  2. Configure additional data connectors as needed"
        log "INFO" "  3. Import custom analytics rules and workbooks"
        log "INFO" "  4. Set up incident response playbooks"
        log "INFO" "  5. Train security team on Sentinel usage"
        
    else
        log "ERROR" "Deployment completed but validation failed. Please review the logs."
        exit 1
    fi
}

# Execute main function with all arguments
main "$@"