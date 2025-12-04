#!/bin/bash
#------------------------------------------------------------------------------
# EO Framework Deployment Script - Terraform Enterprise Production
#------------------------------------------------------------------------------
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_NAME="prod"

# Load all tfvars files
TFVARS_FILES=$(find "${SCRIPT_DIR}/config" -name "*.tfvars" -type f | sort | xargs -I {} echo "-var-file={}" | tr '\n' ' ')

usage() {
    echo "Usage: $0 {init|plan|apply|destroy|output}"
    echo ""
    echo "Commands:"
    echo "  init     Initialize Terraform backend and modules"
    echo "  plan     Generate and show execution plan"
    echo "  apply    Apply the changes"
    echo "  destroy  Destroy the infrastructure"
    echo "  output   Show outputs"
    exit 1
}

init() {
    echo "Initializing Terraform for ${ENV_NAME}..."
    terraform init \
        -backend-config="bucket=tfe-${ENV_NAME}-tfstate" \
        -backend-config="key=terraform.tfstate" \
        -backend-config="region=us-east-1" \
        -backend-config="encrypt=true"
}

plan() {
    echo "Planning Terraform for ${ENV_NAME}..."
    eval terraform plan ${TFVARS_FILES} -out=tfplan
}

apply() {
    echo "Applying Terraform for ${ENV_NAME}..."
    if [ -f "tfplan" ]; then
        terraform apply tfplan
    else
        eval terraform apply ${TFVARS_FILES} -auto-approve
    fi
}

destroy() {
    echo "WARNING: This will destroy all ${ENV_NAME} infrastructure!"
    read -p "Are you sure? (yes/no): " confirm
    if [ "$confirm" = "yes" ]; then
        eval terraform destroy ${TFVARS_FILES} -auto-approve
    else
        echo "Destroy cancelled."
    fi
}

output() {
    terraform output
}

case "$1" in
    init)
        init
        ;;
    plan)
        plan
        ;;
    apply)
        apply
        ;;
    destroy)
        destroy
        ;;
    output)
        output
        ;;
    *)
        usage
        ;;
esac
