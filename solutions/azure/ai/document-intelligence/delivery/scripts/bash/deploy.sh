#!/bin/bash
# Azure AI Document Intelligence - Bash Deployment Script

set -euo pipefail

RESOURCE_GROUP_NAME="${1:-rg-doc-intelligence-prod-001}"
LOCATION="${2:-East US 2}"
COGNITIVE_SERVICES_NAME="${3:-cs-doc-intelligence-prod-001}"

echo "Deploying Azure AI Document Intelligence..."

# Create Cognitive Services account
az cognitiveservices account create \
    --name "$COGNITIVE_SERVICES_NAME" \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --kind FormRecognizer \
    --sku S0 \
    --location "$LOCATION"

echo "Azure AI Document Intelligence deployment completed!"