#!/bin/bash

# Microsoft 365 Enterprise Deployment - Bash Automation Script
# 
# This script provides cross-platform deployment automation for Microsoft 365
# environments, focusing on system preparation, network configuration, and
# infrastructure setup tasks.
#
# Author: Microsoft 365 Deployment Team
# Version: 1.0
# Requires: bash 4.0+, curl, openssl, dig/nslookup
#
# Usage:
#   ./deploy.sh --domain company.onmicrosoft.com --phase preparation
#   ./deploy.sh --domain company.onmicrosoft.com --phase network-test
#   ./deploy.sh --domain company.onmicrosoft.com --phase certificate-check
#   ./deploy.sh --help

set -euo pipefail

# Global variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="M365_Deployment_$(date +%Y%m%d_%H%M%S).log"
TENANT_DOMAIN=""
DEPLOYMENT_PHASE=""
DRY_RUN=false
VERBOSE=false

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Microsoft 365 endpoints for connectivity testing
declare -A M365_ENDPOINTS=(
    ["outlook.office365.com"]="443"
    ["outlook.office.com"]="443"
    ["teams.microsoft.com"]="443"
    ["graph.microsoft.com"]="443"
    ["login.microsoftonline.com"]="443"
    ["*.sharepoint.com"]="443"
    ["*.onedrive.live.com"]="443"
)

# Teams UDP ports for media
TEAMS_UDP_PORTS="3478-3481,50000-59999"

# Logging function
log() {
    local level=$1
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case $level in
        "ERROR")
            echo -e "${RED}[$timestamp] [ERROR] $message${NC}" | tee -a "$LOG_FILE" >&2
            ;;
        "WARN")
            echo -e "${YELLOW}[$timestamp] [WARN] $message${NC}" | tee -a "$LOG_FILE"
            ;;
        "SUCCESS")
            echo -e "${GREEN}[$timestamp] [SUCCESS] $message${NC}" | tee -a "$LOG_FILE"
            ;;
        "INFO")
            echo -e "${BLUE}[$timestamp] [INFO] $message${NC}" | tee -a "$LOG_FILE"
            ;;
        *)
            echo "[$timestamp] $message" | tee -a "$LOG_FILE"
            ;;
    esac
}

# Usage function
usage() {
    cat << EOF
Microsoft 365 Enterprise Deployment - Bash Automation Script

Usage: $0 [OPTIONS]

OPTIONS:
    -d, --domain DOMAIN     Microsoft 365 tenant domain (required)
    -p, --phase PHASE       Deployment phase to execute
    -n, --dry-run          Perform dry run without making changes
    -v, --verbose          Enable verbose output
    -h, --help             Show this help message

PHASES:
    preparation            System preparation and prerequisites check
    network-test           Network connectivity and endpoint testing
    certificate-check      SSL certificate validation
    dns-validation         DNS configuration validation
    firewall-rules         Generate firewall rule recommendations
    bandwidth-test         Network bandwidth assessment
    all                    Execute all phases

EXAMPLES:
    $0 --domain contoso.onmicrosoft.com --phase preparation
    $0 --domain contoso.onmicrosoft.com --phase network-test --verbose
    $0 --domain contoso.onmicrosoft.com --phase all --dry-run

EOF
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -d|--domain)
                TENANT_DOMAIN="$2"
                shift 2
                ;;
            -p|--phase)
                DEPLOYMENT_PHASE="$2"
                shift 2
                ;;
            -n|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                log "ERROR" "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done
    
    if [[ -z "$TENANT_DOMAIN" ]]; then
        log "ERROR" "Tenant domain is required"
        usage
        exit 1
    fi
    
    if [[ -z "$DEPLOYMENT_PHASE" ]]; then
        log "ERROR" "Deployment phase is required"
        usage
        exit 1
    fi
}

# Check prerequisites
check_prerequisites() {
    log "INFO" "Checking system prerequisites..."
    
    local required_commands=("curl" "openssl" "dig" "nc")
    local missing_commands=()
    
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_commands+=("$cmd")
        fi
    done
    
    if [[ ${#missing_commands[@]} -gt 0 ]]; then
        log "ERROR" "Missing required commands: ${missing_commands[*]}"
        log "INFO" "Please install the missing commands and try again"
        return 1
    fi
    
    # Check internet connectivity
    if ! curl -s --max-time 10 https://www.google.com > /dev/null; then
        log "ERROR" "No internet connectivity detected"
        return 1
    fi
    
    log "SUCCESS" "All prerequisites satisfied"
    return 0
}

# System preparation phase
phase_preparation() {
    log "INFO" "=== Starting System Preparation Phase ==="
    
    # Check operating system
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        log "INFO" "Operating System: Linux"
        
        # Check Linux distribution
        if [[ -f /etc/os-release ]]; then
            local os_info=$(grep PRETTY_NAME /etc/os-release | cut -d'"' -f2)
            log "INFO" "Distribution: $os_info"
        fi
        
        # Check package manager
        if command -v apt &> /dev/null; then
            log "INFO" "Package manager: APT (Debian/Ubuntu)"
            if [[ "$DRY_RUN" == false ]]; then
                log "INFO" "Updating package list..."
                sudo apt update >> "$LOG_FILE" 2>&1
            fi
        elif command -v yum &> /dev/null; then
            log "INFO" "Package manager: YUM (RHEL/CentOS)"
        elif command -v dnf &> /dev/null; then
            log "INFO" "Package manager: DNF (Fedora)"
        fi
        
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        log "INFO" "Operating System: macOS"
        local os_version=$(sw_vers -productVersion)
        log "INFO" "macOS Version: $os_version"
        
        # Check Homebrew
        if command -v brew &> /dev/null; then
            log "INFO" "Homebrew package manager available"
        else
            log "WARN" "Homebrew not installed - may be needed for additional tools"
        fi
        
    else
        log "WARN" "Unsupported operating system: $OSTYPE"
    fi
    
    # Check disk space
    local available_space=$(df -h . | awk 'NR==2 {print $4}')
    log "INFO" "Available disk space: $available_space"
    
    # Check memory
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        local total_mem=$(free -h | awk 'NR==2{print $2}')
        local available_mem=$(free -h | awk 'NR==2{print $7}')
        log "INFO" "Total memory: $total_mem, Available: $available_mem"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        local total_mem_kb=$(sysctl -n hw.memsize)
        local total_mem_gb=$((total_mem_kb / 1024 / 1024 / 1024))
        log "INFO" "Total memory: ${total_mem_gb}GB"
    fi
    
    # Create necessary directories
    local work_dir="$HOME/m365-deployment"
    if [[ ! -d "$work_dir" ]]; then
        if [[ "$DRY_RUN" == false ]]; then
            mkdir -p "$work_dir"
            log "SUCCESS" "Created working directory: $work_dir"
        else
            log "INFO" "DRY RUN: Would create working directory: $work_dir"
        fi
    else
        log "INFO" "Working directory already exists: $work_dir"
    fi
    
    log "SUCCESS" "System preparation phase completed"
}

# Network connectivity testing
phase_network_test() {
    log "INFO" "=== Starting Network Connectivity Test Phase ==="
    
    local failed_tests=0
    local total_tests=0
    
    # Test Microsoft 365 endpoints
    for endpoint in "${!M365_ENDPOINTS[@]}"; do
        local port="${M365_ENDPOINTS[$endpoint]}"
        total_tests=$((total_tests + 1))
        
        # Handle wildcard endpoints
        if [[ $endpoint == *"*"* ]]; then
            # Test a specific example for wildcard domains
            if [[ $endpoint == "*.sharepoint.com" ]]; then
                endpoint="microsoft.sharepoint.com"
            elif [[ $endpoint == "*.onedrive.live.com" ]]; then
                endpoint="onedrive.live.com"
            fi
        fi
        
        log "INFO" "Testing connectivity to $endpoint:$port..."
        
        if timeout 10 nc -z "$endpoint" "$port" &> /dev/null; then
            log "SUCCESS" "✓ $endpoint:$port - Connected"
        else
            log "ERROR" "✗ $endpoint:$port - Connection failed"
            failed_tests=$((failed_tests + 1))
        fi
    done
    
    # Test DNS resolution
    log "INFO" "Testing DNS resolution..."
    local dns_endpoints=("login.microsoftonline.com" "graph.microsoft.com" "outlook.office365.com")
    
    for dns_endpoint in "${dns_endpoints[@]}"; do
        total_tests=$((total_tests + 1))
        
        if dig +short "$dns_endpoint" &> /dev/null; then
            local ip_addresses=$(dig +short "$dns_endpoint" | head -3)
            log "SUCCESS" "✓ DNS resolution for $dns_endpoint: $ip_addresses"
        else
            log "ERROR" "✗ DNS resolution failed for $dns_endpoint"
            failed_tests=$((failed_tests + 1))
        fi
    done
    
    # Test HTTPS connectivity with specific Microsoft endpoints
    log "INFO" "Testing HTTPS connectivity..."
    local https_endpoints=("https://login.microsoftonline.com" "https://graph.microsoft.com")
    
    for https_endpoint in "${https_endpoints[@]}"; do
        total_tests=$((total_tests + 1))
        
        if curl -s --max-time 10 --head "$https_endpoint" | grep -q "200 OK\|302 Found\|301 Moved"; then
            log "SUCCESS" "✓ HTTPS connectivity to $https_endpoint"
        else
            log "ERROR" "✗ HTTPS connectivity failed to $https_endpoint"
            failed_tests=$((failed_tests + 1))
        fi
    done
    
    # Summary
    local success_rate=$(( (total_tests - failed_tests) * 100 / total_tests ))
    log "INFO" "Network test summary: $((total_tests - failed_tests))/$total_tests tests passed ($success_rate%)"
    
    if [[ $failed_tests -eq 0 ]]; then
        log "SUCCESS" "All network connectivity tests passed"
    else
        log "WARN" "$failed_tests network connectivity tests failed"
    fi
    
    log "SUCCESS" "Network connectivity test phase completed"
}

# SSL certificate validation
phase_certificate_check() {
    log "INFO" "=== Starting SSL Certificate Check Phase ==="
    
    local endpoints=("login.microsoftonline.com" "graph.microsoft.com" "outlook.office365.com" "teams.microsoft.com")
    
    for endpoint in "${endpoints[@]}"; do
        log "INFO" "Checking SSL certificate for $endpoint..."
        
        # Get certificate information
        local cert_info=$(echo | openssl s_client -servername "$endpoint" -connect "$endpoint:443" 2>/dev/null | openssl x509 -noout -dates -subject -issuer 2>/dev/null)
        
        if [[ -n "$cert_info" ]]; then
            log "SUCCESS" "✓ SSL certificate retrieved for $endpoint"
            
            if [[ "$VERBOSE" == true ]]; then
                echo "$cert_info" | while read -r line; do
                    log "INFO" "  $line"
                done
            fi
            
            # Check certificate expiration
            local not_after=$(echo "$cert_info" | grep "notAfter" | cut -d'=' -f2)
            if [[ -n "$not_after" ]]; then
                local expiry_date=$(date -d "$not_after" +%s 2>/dev/null || echo "0")
                local current_date=$(date +%s)
                local days_until_expiry=$(( (expiry_date - current_date) / 86400 ))
                
                if [[ $days_until_expiry -gt 30 ]]; then
                    log "SUCCESS" "  Certificate expires in $days_until_expiry days"
                elif [[ $days_until_expiry -gt 0 ]]; then
                    log "WARN" "  Certificate expires in $days_until_expiry days (soon)"
                else
                    log "ERROR" "  Certificate has expired or date parsing failed"
                fi
            fi
        else
            log "ERROR" "✗ Failed to retrieve SSL certificate for $endpoint"
        fi
    done
    
    log "SUCCESS" "SSL certificate check phase completed"
}

# DNS validation
phase_dns_validation() {
    log "INFO" "=== Starting DNS Validation Phase ==="
    
    # Extract base domain from tenant domain
    local base_domain
    if [[ $TENANT_DOMAIN == *.onmicrosoft.com ]]; then
        log "INFO" "Using default .onmicrosoft.com domain"
        base_domain=$TENANT_DOMAIN
    else
        base_domain=$TENANT_DOMAIN
    fi
    
    log "INFO" "Validating DNS configuration for domain: $base_domain"
    
    # Check MX record
    log "INFO" "Checking MX record for $base_domain..."
    local mx_record=$(dig +short MX "$base_domain" 2>/dev/null)
    if [[ -n "$mx_record" ]]; then
        log "SUCCESS" "✓ MX record found: $mx_record"
        
        # Check if it points to Office 365
        if echo "$mx_record" | grep -q "protection.outlook.com"; then
            log "SUCCESS" "✓ MX record points to Office 365"
        else
            log "WARN" "MX record does not point to Office 365"
        fi
    else
        log "WARN" "No MX record found for $base_domain"
    fi
    
    # Check SPF record
    log "INFO" "Checking SPF record for $base_domain..."
    local spf_record=$(dig +short TXT "$base_domain" 2>/dev/null | grep "v=spf1")
    if [[ -n "$spf_record" ]]; then
        log "SUCCESS" "✓ SPF record found: $spf_record"
        
        if echo "$spf_record" | grep -q "include:spf.protection.outlook.com"; then
            log "SUCCESS" "✓ SPF record includes Office 365"
        else
            log "WARN" "SPF record does not include Office 365"
        fi
    else
        log "WARN" "No SPF record found for $base_domain"
    fi
    
    # Check autodiscover record
    log "INFO" "Checking autodiscover record for $base_domain..."
    local autodiscover_record=$(dig +short CNAME "autodiscover.$base_domain" 2>/dev/null)
    if [[ -n "$autodiscover_record" ]]; then
        log "SUCCESS" "✓ Autodiscover CNAME found: $autodiscover_record"
    else
        log "WARN" "No autodiscover CNAME found for $base_domain"
    fi
    
    # Check SIP records for Teams
    log "INFO" "Checking SIP records for Teams..."
    local sip_record=$(dig +short CNAME "sip.$base_domain" 2>/dev/null)
    if [[ -n "$sip_record" ]]; then
        log "SUCCESS" "✓ SIP CNAME found: $sip_record"
    else
        log "WARN" "No SIP CNAME found for $base_domain"
    fi
    
    log "SUCCESS" "DNS validation phase completed"
}

# Generate firewall rules
phase_firewall_rules() {
    log "INFO" "=== Starting Firewall Rules Generation Phase ==="
    
    local firewall_rules_file="m365_firewall_rules_$(date +%Y%m%d_%H%M%S).txt"
    
    cat > "$firewall_rules_file" << EOF
# Microsoft 365 Enterprise Firewall Rules
# Generated on: $(date)
# Tenant Domain: $TENANT_DOMAIN

# HTTPS Outbound Rules (TCP/443)
# Allow outbound HTTPS to Microsoft 365 endpoints
EOF
    
    for endpoint in "${!M365_ENDPOINTS[@]}"; do
        local port="${M365_ENDPOINTS[$endpoint]}"
        echo "# Rule for $endpoint:$port" >> "$firewall_rules_file"
        
        # Generate different firewall rule formats
        echo "# iptables format:" >> "$firewall_rules_file"
        echo "iptables -A OUTPUT -p tcp -d $endpoint --dport $port -j ACCEPT" >> "$firewall_rules_file"
        
        echo "# UFW format:" >> "$firewall_rules_file"
        echo "ufw allow out $port" >> "$firewall_rules_file"
        
        echo "" >> "$firewall_rules_file"
    done
    
    cat >> "$firewall_rules_file" << EOF

# Microsoft Teams UDP Ports for Media
# Allow UDP ports: $TEAMS_UDP_PORTS
# iptables format:
iptables -A OUTPUT -p udp --dport 3478:3481 -j ACCEPT
iptables -A OUTPUT -p udp --dport 50000:59999 -j ACCEPT

# UFW format:
ufw allow out 3478:3481/udp
ufw allow out 50000:59999/udp

# DNS Rules (UDP/53 and TCP/53)
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 53 -j ACCEPT
ufw allow out 53

# NTP (UDP/123) - for time synchronization
iptables -A OUTPUT -p udp --dport 123 -j ACCEPT
ufw allow out 123/udp
EOF
    
    if [[ "$DRY_RUN" == false ]]; then
        log "SUCCESS" "Firewall rules generated: $firewall_rules_file"
    else
        log "INFO" "DRY RUN: Would generate firewall rules file: $firewall_rules_file"
        rm -f "$firewall_rules_file"
    fi
    
    log "SUCCESS" "Firewall rules generation phase completed"
}

# Bandwidth assessment
phase_bandwidth_test() {
    log "INFO" "=== Starting Bandwidth Assessment Phase ==="
    
    # Calculate bandwidth requirements
    local user_count=100  # Default assumption
    
    log "INFO" "Calculating bandwidth requirements for $user_count users..."
    
    # Microsoft 365 bandwidth requirements per user (in Mbps)
    local exchange_bw=0.5
    local teams_bw=1.2
    local sharepoint_bw=0.8
    local onedrive_bw=0.5
    
    local total_per_user=$(echo "$exchange_bw + $teams_bw + $sharepoint_bw + $onedrive_bw" | bc -l 2>/dev/null || echo "3.0")
    local total_required=$(echo "$total_per_user * $user_count" | bc -l 2>/dev/null || echo "300")
    local recommended=$(echo "$total_required * 1.5" | bc -l 2>/dev/null || echo "450")
    
    log "INFO" "Bandwidth Requirements Analysis:"
    log "INFO" "  Users: $user_count"
    log "INFO" "  Exchange Online: ${exchange_bw} Mbps per user"
    log "INFO" "  Microsoft Teams: ${teams_bw} Mbps per user"
    log "INFO" "  SharePoint Online: ${sharepoint_bw} Mbps per user"
    log "INFO" "  OneDrive: ${onedrive_bw} Mbps per user"
    log "INFO" "  Total per user: ${total_per_user} Mbps"
    log "INFO" "  Total required: ${total_required} Mbps"
    log "INFO" "  Recommended (150% overhead): ${recommended} Mbps"
    
    # Test download speed to a Microsoft endpoint
    log "INFO" "Testing download speed to Microsoft endpoint..."
    
    local test_url="https://download.microsoft.com/download/0/0/0/000215a4-46a0-40d9-8596-021c609b0766/AzureCopy.zip"
    local start_time=$(date +%s.%N)
    
    if curl -s -w "%{speed_download}" -o /dev/null --max-time 30 "$test_url" > /tmp/speed_test.txt 2>/dev/null; then
        local end_time=$(date +%s.%N)
        local bytes_per_second=$(cat /tmp/speed_test.txt)
        local mbps=$(echo "scale=2; $bytes_per_second * 8 / 1000000" | bc -l 2>/dev/null || echo "0")
        
        log "SUCCESS" "Download speed test: ${mbps} Mbps"
        
        if (( $(echo "$mbps > $recommended" | bc -l 2>/dev/null || echo "0") )); then
            log "SUCCESS" "✓ Bandwidth exceeds recommended requirements"
        elif (( $(echo "$mbps > $total_required" | bc -l 2>/dev/null || echo "0") )); then
            log "WARN" "⚠ Bandwidth meets minimum but below recommended"
        else
            log "ERROR" "✗ Bandwidth below minimum requirements"
        fi
        
        rm -f /tmp/speed_test.txt
    else
        log "WARN" "Could not perform download speed test"
    fi
    
    log "SUCCESS" "Bandwidth assessment phase completed"
}

# Execute all phases
execute_all_phases() {
    log "INFO" "=== Executing All Deployment Phases ==="
    
    phase_preparation
    phase_network_test
    phase_certificate_check
    phase_dns_validation
    phase_firewall_rules
    phase_bandwidth_test
    
    log "SUCCESS" "All deployment phases completed"
}

# Main execution function
main() {
    log "INFO" "Microsoft 365 Enterprise Deployment - Bash Automation Script"
    log "INFO" "Tenant Domain: $TENANT_DOMAIN"
    log "INFO" "Deployment Phase: $DEPLOYMENT_PHASE"
    log "INFO" "Dry Run: $DRY_RUN"
    log "INFO" "Verbose: $VERBOSE"
    log "INFO" "Log File: $LOG_FILE"
    
    # Check prerequisites
    if ! check_prerequisites; then
        log "ERROR" "Prerequisites check failed. Exiting."
        exit 1
    fi
    
    # Execute requested phase
    case $DEPLOYMENT_PHASE in
        "preparation")
            phase_preparation
            ;;
        "network-test")
            phase_network_test
            ;;
        "certificate-check")
            phase_certificate_check
            ;;
        "dns-validation")
            phase_dns_validation
            ;;
        "firewall-rules")
            phase_firewall_rules
            ;;
        "bandwidth-test")
            phase_bandwidth_test
            ;;
        "all")
            execute_all_phases
            ;;
        *)
            log "ERROR" "Unknown deployment phase: $DEPLOYMENT_PHASE"
            usage
            exit 1
            ;;
    esac
    
    log "SUCCESS" "Microsoft 365 deployment script completed successfully"
}

# Parse arguments and execute main function
parse_args "$@"
main