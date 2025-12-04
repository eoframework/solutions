#!/bin/bash
#------------------------------------------------------------------------------
# Dell PowerSwitch Datacenter - Backup Script
# EO Framework - Dell Network Solutions
#
# Usage: ./backup.sh <environment>
#------------------------------------------------------------------------------

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ANSIBLE_DIR="$(dirname "$SCRIPT_DIR")"
BACKUP_DIR="$ANSIBLE_DIR/backups/$(date +%Y%m%d_%H%M%S)"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $(date '+%Y-%m-%d %H:%M:%S') $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $(date '+%Y-%m-%d %H:%M:%S') $*" >&2
}

usage() {
    cat << EOF
Usage: $(basename "$0") <environment>

Arguments:
    environment    Target environment (production|test|dr)

Examples:
    $(basename "$0") production
    $(basename "$0") test
EOF
    exit 1
}

# Parse arguments
if [ $# -lt 1 ]; then
    usage
fi

ENVIRONMENT="$1"

case "$ENVIRONMENT" in
    production|test|dr) ;;
    *) log_error "Invalid environment: $ENVIRONMENT"; usage ;;
esac

echo ""
echo "================================================================"
echo "  Dell PowerSwitch Datacenter Configuration Backup"
echo "  Environment: $ENVIRONMENT"
echo "================================================================"
echo ""

# Create backup directory
mkdir -p "$BACKUP_DIR"
log_info "Backup directory: $BACKUP_DIR"

# Create backup playbook
cat > "$BACKUP_DIR/backup_playbook.yml" << 'PLAYBOOK'
---
- name: Backup Switch Configurations
  hosts: powerswitch
  gather_facts: false

  tasks:
    - name: Get running configuration
      dellemc.os10.os10_command:
        commands:
          - show running-config
      register: config_output

    - name: Save configuration to file
      ansible.builtin.copy:
        content: "{{ config_output.stdout[0] }}"
        dest: "{{ backup_dir }}/{{ inventory_hostname }}.cfg"
        mode: '0644'
      delegate_to: localhost

    - name: Display backup status
      ansible.builtin.debug:
        msg: "Backed up {{ inventory_hostname }} to {{ backup_dir }}/{{ inventory_hostname }}.cfg"
PLAYBOOK

log_info "Running backup..."

cd "$ANSIBLE_DIR"
ansible-playbook \
    -i "inventory/$ENVIRONMENT" \
    "$BACKUP_DIR/backup_playbook.yml" \
    -e "backup_dir=$BACKUP_DIR"

# Cleanup temp playbook
rm -f "$BACKUP_DIR/backup_playbook.yml"

# Create backup manifest
cat > "$BACKUP_DIR/manifest.txt" << EOF
Dell PowerSwitch Datacenter Configuration Backup
================================================
Environment: $ENVIRONMENT
Timestamp: $(date -Iseconds)
Backup Directory: $BACKUP_DIR

Files:
$(ls -la "$BACKUP_DIR"/*.cfg 2>/dev/null || echo "No configuration files found")
EOF

echo ""
log_info "Backup complete!"
log_info "Backup location: $BACKUP_DIR"
log_info "Files backed up: $(ls "$BACKUP_DIR"/*.cfg 2>/dev/null | wc -l)"
