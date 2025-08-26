#!/bin/bash
# Juniper SRX Firewall Platform Deployment Script
# Automates the deployment and configuration of SRX security platform

set -euo pipefail

# Global Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="/var/log/srx-deployment"
LOG_FILE="$LOG_DIR/deployment_$(date +%Y%m%d_%H%M%S).log"
CONFIG_FILE="${SCRIPT_DIR}/../config/deployment.conf"

# Default Values
DEVICE_IP=""
USERNAME="admin"
PASSWORD=""
SECURITY_ZONES="trust,untrust"
HA_MODE="standalone"
PRIMARY_IP=""
SECONDARY_IP=""
DRY_RUN=false
VERBOSE=false

# Function to display usage
usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Juniper SRX Firewall Platform Deployment Script

OPTIONS:
    --device-ip IP          Primary SRX device IP address
    --username USER         Administrative username (default: admin)
    --password PASS         Administrative password
    --security-zones ZONES  Security zones (comma-separated)
    --ha-mode MODE          HA mode: standalone, active-passive, active-active
    --primary-ip IP         Primary device IP for HA
    --secondary-ip IP       Secondary device IP for HA
    --config FILE           Configuration file path
    --dry-run              Perform dry run without making changes
    --verbose              Enable verbose logging
    --check-prerequisites   Check system prerequisites
    --help                 Display this help message

EXAMPLES:
    $0 --device-ip "192.168.1.1" --password "secret123"
    $0 --ha-mode active-passive --primary-ip "192.168.1.1" --secondary-ip "192.168.1.2"
    $0 --config /path/to/config.conf --dry-run

EOF
}

# Function to log messages
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
    
    if [[ "$VERBOSE" == "true" ]] || [[ "$level" == "ERROR" ]]; then
        echo "[$level] $message" >&2
    fi
}

# Function to check prerequisites
check_prerequisites() {
    log_message "INFO" "Checking deployment prerequisites..."
    
    local prereq_ok=true
    
    # Check required tools
    local required_tools=("ssh" "sshpass" "expect" "python3" "ansible")
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            log_message "ERROR" "Required tool not found: $tool"
            prereq_ok=false
        else
            log_message "INFO" "Found required tool: $tool"
        fi
    done
    
    # Check Python modules
    local python_modules=("paramiko" "jnpr.junos" "yaml")
    for module in "${python_modules[@]}"; do
        if ! python3 -c "import $module" &> /dev/null; then
            log_message "WARN" "Python module not found: $module (will install)"
        else
            log_message "INFO" "Found Python module: $module"
        fi
    done
    
    if [[ "$prereq_ok" == "true" ]]; then
        log_message "INFO" "All prerequisites satisfied"
        return 0
    else
        log_message "ERROR" "Prerequisites check failed"
        return 1
    fi
}

# Function to test device connectivity
test_connectivity() {
    log_message "INFO" "Testing connectivity to SRX device: $DEVICE_IP"
    
    if ping -c 3 -W 5 "$DEVICE_IP" &> /dev/null; then
        log_message "INFO" "Device ping successful: $DEVICE_IP"
    else
        log_message "ERROR" "Cannot reach device: $DEVICE_IP"
        return 1
    fi
    
    # Test SSH connectivity
    if nc -z -w5 "$DEVICE_IP" 22 &> /dev/null; then
        log_message "INFO" "SSH port accessible: $DEVICE_IP:22"
        return 0
    else
        log_message "ERROR" "SSH port not accessible: $DEVICE_IP:22"
        return 1
    fi
}

# Function to backup current configuration
backup_configuration() {
    log_message "INFO" "Backing up current SRX configuration..."
    
    local backup_dir="/tmp/srx-backups/$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_message "INFO" "[DRY RUN] Would backup configuration to: $backup_dir"
        return 0
    fi
    
    # Use Python script for configuration backup
    python3 "${SCRIPT_DIR}/../python/deploy.py" \
        --action backup \
        --device "$DEVICE_IP" \
        --username "$USERNAME" \
        --password "$PASSWORD" \
        --backup-dir "$backup_dir" || {
        log_message "ERROR" "Failed to backup configuration"
        return 1
    }
    
    log_message "INFO" "Configuration backed up to: $backup_dir"
}

# Function to configure basic security zones
configure_security_zones() {
    log_message "INFO" "Configuring security zones: $SECURITY_ZONES"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_message "INFO" "[DRY RUN] Would configure security zones"
        return 0
    fi
    
    python3 "${SCRIPT_DIR}/../python/deploy.py" \
        --action configure_zones \
        --device "$DEVICE_IP" \
        --username "$USERNAME" \
        --password "$PASSWORD" \
        --zones "$SECURITY_ZONES" || {
        log_message "ERROR" "Failed to configure security zones"
        return 1
    }
    
    log_message "INFO" "Security zones configured successfully"
}

# Function to configure high availability
configure_high_availability() {
    if [[ "$HA_MODE" == "standalone" ]]; then
        log_message "INFO" "Standalone mode - skipping HA configuration"
        return 0
    fi
    
    log_message "INFO" "Configuring high availability mode: $HA_MODE"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_message "INFO" "[DRY RUN] Would configure HA mode: $HA_MODE"
        return 0
    fi
    
    python3 "${SCRIPT_DIR}/../python/deploy.py" \
        --action configure_ha \
        --primary "$PRIMARY_IP" \
        --secondary "$SECONDARY_IP" \
        --username "$USERNAME" \
        --password "$PASSWORD" \
        --ha-mode "$HA_MODE" || {
        log_message "ERROR" "Failed to configure high availability"
        return 1
    }
    
    log_message "INFO" "High availability configured successfully"
}

# Function to deploy security policies
deploy_security_policies() {
    log_message "INFO" "Deploying default security policies..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_message "INFO" "[DRY RUN] Would deploy security policies"
        return 0
    fi
    
    python3 "${SCRIPT_DIR}/../python/deploy.py" \
        --action deploy_policies \
        --device "$DEVICE_IP" \
        --username "$USERNAME" \
        --password "$PASSWORD" \
        --policy-file "${SCRIPT_DIR}/../config/default-policies.yaml" || {
        log_message "ERROR" "Failed to deploy security policies"
        return 1
    }
    
    log_message "INFO" "Security policies deployed successfully"
}

# Function to validate deployment
validate_deployment() {
    log_message "INFO" "Validating SRX deployment..."
    
    python3 "${SCRIPT_DIR}/../python/deploy.py" \
        --action validate \
        --device "$DEVICE_IP" \
        --username "$USERNAME" \
        --password "$PASSWORD" || {
        log_message "ERROR" "Deployment validation failed"
        return 1
    }
    
    log_message "INFO" "Deployment validation completed successfully"
}

# Function to load configuration file
load_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        log_message "INFO" "Loading configuration from: $CONFIG_FILE"
        source "$CONFIG_FILE"
    fi
}

# Main deployment function
main() {
    # Create log directory
    mkdir -p "$LOG_DIR"
    
    log_message "INFO" "Starting Juniper SRX Firewall deployment"
    log_message "INFO" "Log file: $LOG_FILE"
    
    # Load configuration
    load_config
    
    # Check prerequisites
    check_prerequisites || exit 1
    
    # Validate required parameters
    if [[ -z "$DEVICE_IP" ]] || [[ -z "$PASSWORD" ]]; then
        log_message "ERROR" "Missing required parameters: device-ip and password"
        usage
        exit 1
    fi
    
    # Test connectivity
    test_connectivity || exit 1
    
    # Execute deployment steps
    backup_configuration || exit 1
    configure_security_zones || exit 1
    configure_high_availability || exit 1
    deploy_security_policies || exit 1
    validate_deployment || exit 1
    
    log_message "INFO" "SRX Firewall deployment completed successfully"
    
    if [[ "$DRY_RUN" == "false" ]]; then
        echo ""
        echo "Deployment Summary:"
        echo "  Primary Device: $DEVICE_IP"
        echo "  HA Mode: $HA_MODE"
        echo "  Security Zones: $SECURITY_ZONES"
        echo "  Log File: $LOG_FILE"
        echo ""
        echo "Next Steps:"
        echo "  1. Access device via J-Web or CLI"
        echo "  2. Verify security policy operation"
        echo "  3. Test failover (if HA configured)"
        echo "  4. Configure additional security services"
    fi
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --device-ip)
            DEVICE_IP="$2"
            shift 2
            ;;
        --username)
            USERNAME="$2"
            shift 2
            ;;
        --password)
            PASSWORD="$2"
            shift 2
            ;;
        --security-zones)
            SECURITY_ZONES="$2"
            shift 2
            ;;
        --ha-mode)
            HA_MODE="$2"
            shift 2
            ;;
        --primary-ip)
            PRIMARY_IP="$2"
            shift 2
            ;;
        --secondary-ip)
            SECONDARY_IP="$2"
            shift 2
            ;;
        --config)
            CONFIG_FILE="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        --check-prerequisites)
            mkdir -p "$LOG_DIR"
            check_prerequisites
            exit $?
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            log_message "ERROR" "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Execute main function
main