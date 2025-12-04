#!/bin/bash
#------------------------------------------------------------------------------
# EO Framework Deployment Script - Azure Document Intelligence
# Environment: Production
#------------------------------------------------------------------------------

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Build var-file arguments from config/*.tfvars
# Files are loaded alphabetically which determines override order
VAR_FILES=""
for file in config/*.tfvars; do
    [ -f "$file" ] && VAR_FILES="$VAR_FILES -var-file=$file"
done

echo "Loading tfvars files:"
echo "$VAR_FILES" | tr ' ' '\n' | grep -v '^$'
echo ""

case $1 in
    "init")
        echo "Initializing Terraform..."
        terraform init "${@:2}"
        ;;
    "plan")
        echo "Planning infrastructure changes..."
        terraform plan $VAR_FILES "${@:2}"
        ;;
    "apply")
        echo "Applying infrastructure changes..."
        terraform apply $VAR_FILES "${@:2}"
        ;;
    "destroy")
        echo "Destroying infrastructure..."
        terraform destroy $VAR_FILES "${@:2}"
        ;;
    "validate")
        echo "Validating configuration..."
        terraform validate
        ;;
    "output")
        echo "Showing outputs..."
        terraform output "${@:2}"
        ;;
    *)
        echo "Usage: $0 {init|plan|apply|destroy|validate|output}"
        echo ""
        echo "Commands:"
        echo "  init     - Initialize Terraform and download providers"
        echo "  plan     - Show planned infrastructure changes"
        echo "  apply    - Apply infrastructure changes"
        echo "  destroy  - Destroy infrastructure"
        echo "  validate - Validate Terraform configuration"
        echo "  output   - Show Terraform outputs"
        exit 1
        ;;
esac
