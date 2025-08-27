# Scripts - Azure Document Intelligence

## Overview

This directory contains automation scripts and utilities for Azure Document Intelligence solution deployment, testing, and operations. Leveraging Azure AI services including Azure Form Recognizer, Azure Cognitive Services, and Azure OpenAI for comprehensive document analysis and intelligent processing.

---

## Script Categories

### Infrastructure Scripts
- **arm-template-deploy.ps1** - ARM template deployment for Azure resources
- **infrastructure-setup.ps1** - Complete Azure infrastructure automation
- **resource-group-setup.py** - Resource group and RBAC configuration
- **key-vault-setup.py** - Azure Key Vault configuration for secrets management
- **storage-account-setup.py** - Azure Storage configuration for document processing

### AI Service Configuration
- **form-recognizer-setup.py** - Azure Form Recognizer service configuration
- **cognitive-services-config.py** - Cognitive Services multi-service setup
- **openai-integration.py** - Azure OpenAI service integration and model deployment
- **custom-model-training.py** - Custom form model training and deployment
- **computer-vision-setup.py** - Computer Vision API configuration

### Document Processing Scripts
- **batch-document-processor.py** - Batch document processing automation
- **real-time-processor.py** - Real-time document processing pipeline
- **form-extraction-pipeline.py** - Structured form data extraction
- **invoice-processing.py** - Specialized invoice processing workflow
- **contract-analyzer.py** - Contract document analysis and extraction

### Testing Scripts
- **document-intelligence-tests.py** - Comprehensive AI model testing
- **performance-benchmarking.ps1** - Performance testing and benchmarking
- **accuracy-validation.py** - Model accuracy testing and reporting
- **integration-tests.py** - End-to-end integration testing
- **load-testing.py** - Concurrent processing load testing

### Operations Scripts
- **health-monitoring.ps1** - Azure service health monitoring
- **cost-optimization.py** - Cost analysis and optimization recommendations
- **backup-management.ps1** - Backup and disaster recovery procedures
- **log-analytics.py** - Azure Monitor logs analysis and alerting

---

## Prerequisites

### Required Tools
- **Azure CLI v2.50+** - Azure command line interface
- **Azure PowerShell v9.0+** - PowerShell modules for Azure
- **Python 3.9+** - Python runtime environment
- **Azure SDK for Python** - Azure service integration libraries
- **jq** - JSON processor for script automation

### Azure Services Required
- Azure Form Recognizer (document analysis and OCR)
- Azure Cognitive Services (text analytics, computer vision)
- Azure OpenAI Service (GPT models for document understanding)
- Azure Storage Account (document storage and queuing)
- Azure Key Vault (secrets and API key management)
- Azure Monitor (logging and monitoring)
- Azure Logic Apps (workflow orchestration)
- Azure Functions (serverless processing)

### Python Dependencies
```bash
pip install azure-ai-formrecognizer azure-cognitiveservices-vision-computervision
pip install azure-storage-blob azure-keyvault-secrets azure-monitor-query
pip install azure-identity requests pandas numpy openpyxl
```

### PowerShell Modules
```powershell
Install-Module -Name Az -Force -AllowClobber
Install-Module -Name Az.CognitiveServices -Force
Install-Module -Name Az.Storage -Force
Install-Module -Name Az.KeyVault -Force
```

### Configuration
```bash
# Azure CLI login and subscription setup
az login
az account set --subscription "your-subscription-id"

# Set environment variables
export AZURE_SUBSCRIPTION_ID="your-subscription-id"
export AZURE_RESOURCE_GROUP="document-intelligence-rg"
export AZURE_LOCATION="eastus"
export FORM_RECOGNIZER_ENDPOINT="https://your-form-recognizer.cognitiveservices.azure.com/"
export STORAGE_ACCOUNT_NAME="documentstorageaccount"
export KEY_VAULT_NAME="document-intelligence-kv"
```

```powershell
# PowerShell Azure authentication
Connect-AzAccount
Set-AzContext -SubscriptionId "your-subscription-id"

# Environment variables
$env:AZURE_SUBSCRIPTION_ID = "your-subscription-id"
$env:AZURE_RESOURCE_GROUP = "document-intelligence-rg"
$env:AZURE_LOCATION = "eastus"
```

---

## Usage Instructions

### Infrastructure Deployment
```bash
# Deploy Azure infrastructure using ARM templates
az deployment group create \
  --resource-group $AZURE_RESOURCE_GROUP \
  --template-file ./templates/document-intelligence-infrastructure.json \
  --parameters location=$AZURE_LOCATION

# Setup resource group with proper RBAC
python resource-group-setup.py \
  --resource-group $AZURE_RESOURCE_GROUP \
  --location $AZURE_LOCATION \
  --enable-rbac

# Configure Azure Key Vault
python key-vault-setup.py \
  --key-vault-name $KEY_VAULT_NAME \
  --resource-group $AZURE_RESOURCE_GROUP \
  --enable-soft-delete \
  --retention-days 90

# Setup Azure Storage Account
python storage-account-setup.py \
  --account-name $STORAGE_ACCOUNT_NAME \
  --resource-group $AZURE_RESOURCE_GROUP \
  --enable-hierarchical-namespace \
  --create-containers documents,processed,failed
```

```powershell
# PowerShell infrastructure deployment
.\arm-template-deploy.ps1 -ResourceGroupName $env:AZURE_RESOURCE_GROUP -Location $env:AZURE_LOCATION

# Setup infrastructure components
.\infrastructure-setup.ps1 -SubscriptionId $env:AZURE_SUBSCRIPTION_ID -ResourceGroup $env:AZURE_RESOURCE_GROUP
```

### AI Services Configuration
```bash
# Configure Azure Form Recognizer
python form-recognizer-setup.py \
  --resource-group $AZURE_RESOURCE_GROUP \
  --form-recognizer-name document-form-recognizer \
  --pricing-tier S0 \
  --enable-custom-models

# Setup Cognitive Services multi-service account
python cognitive-services-config.py \
  --resource-group $AZURE_RESOURCE_GROUP \
  --account-name document-cognitive-services \
  --kind CognitiveServices \
  --enable-computer-vision \
  --enable-text-analytics

# Configure Azure OpenAI integration
python openai-integration.py \
  --resource-group $AZURE_RESOURCE_GROUP \
  --openai-name document-openai \
  --deploy-model gpt-35-turbo \
  --model-version "0613"

# Train custom form models
python custom-model-training.py \
  --training-data-url "https://$STORAGE_ACCOUNT_NAME.blob.core.windows.net/training-data" \
  --model-name invoice-model \
  --model-description "Custom invoice processing model"
```

### Document Processing
```bash
# Process documents in batch
python batch-document-processor.py \
  --input-container documents \
  --output-container processed \
  --document-types pdf,jpg,png \
  --max-concurrent-requests 10 \
  --enable-ocr

# Start real-time processing pipeline
python real-time-processor.py \
  --storage-queue document-queue \
  --form-recognizer-endpoint $FORM_RECOGNIZER_ENDPOINT \
  --enable-confidence-scoring \
  --confidence-threshold 0.85

# Extract structured form data
python form-extraction-pipeline.py \
  --model-id invoice-model \
  --input-documents ./sample-documents/ \
  --output-format json \
  --include-confidence-scores

# Process invoices specifically
python invoice-processing.py \
  --input-container invoices \
  --extract-fields vendor,amount,date,items \
  --validation-rules ./invoice-validation.json \
  --export-format excel

# Analyze contracts
python contract-analyzer.py \
  --input-documents ./contracts/ \
  --extract-clauses \
  --identify-key-terms \
  --compliance-check ./compliance-rules.json
```

### Testing and Validation
```bash
# Run comprehensive test suite
python document-intelligence-tests.py \
  --test-suite full \
  --test-documents ./test-data/ \
  --models invoice-model,contract-model,form-model \
  --generate-report ./test-results.html

# Performance benchmarking
python performance-benchmarking.py \
  --concurrent-requests 50 \
  --duration 600 \
  --document-sizes small,medium,large \
  --test-scenarios ./benchmark-scenarios.json

# Validate model accuracy
python accuracy-validation.py \
  --test-dataset ./validation-dataset/ \
  --ground-truth ./ground-truth.json \
  --metrics precision,recall,f1-score,accuracy \
  --confidence-thresholds 0.7,0.8,0.9

# Load testing
python load-testing.py \
  --endpoint $FORM_RECOGNIZER_ENDPOINT \
  --concurrent-users 100 \
  --ramp-up-time 300 \
  --test-duration 1800
```

```powershell
# PowerShell performance benchmarking
.\performance-benchmarking.ps1 -EndpointUrl $env:FORM_RECOGNIZER_ENDPOINT -ConcurrentRequests 25 -Duration 300
```

### Operations and Monitoring
```bash
# Health monitoring
python health-monitoring.py \
  --services form-recognizer,cognitive-services,storage \
  --check-interval 60 \
  --alert-webhook https://alerts.company.com/webhook

# Cost optimization analysis
python cost-optimization.py \
  --subscription-id $AZURE_SUBSCRIPTION_ID \
  --resource-group $AZURE_RESOURCE_GROUP \
  --time-period 30-days \
  --include-recommendations \
  --export-report ./cost-analysis.xlsx

# Log analytics and alerting
python log-analytics.py \
  --workspace-id your-log-analytics-workspace-id \
  --query-timespan 24h \
  --error-patterns "HTTP 4xx,HTTP 5xx,Timeout" \
  --create-alerts
```

```powershell
# PowerShell health monitoring
.\health-monitoring.ps1 -ResourceGroupName $env:AZURE_RESOURCE_GROUP -CheckInterval 60

# Backup management
.\backup-management.ps1 -StorageAccountName $env:STORAGE_ACCOUNT_NAME -RetentionDays 30 -BackupType incremental
```

---

## Directory Structure

```
scripts/
├── ansible/              # Ansible playbooks for configuration management
├── bash/                 # Shell scripts for Linux environments
├── powershell/          # PowerShell scripts for Windows and Azure management
├── python/              # Python scripts for AI service integration
└── terraform/           # Terraform configurations for infrastructure as code
```

---

## Model Management

### Custom Model Training
```bash
# Prepare training data
python prepare-training-data.py \
  --input-documents ./raw-documents/ \
  --output-container training-data \
  --annotation-format fott \
  --validation-split 0.2

# Train custom model
python custom-model-training.py \
  --model-type custom \
  --training-data-url https://$STORAGE_ACCOUNT_NAME.blob.core.windows.net/training-data \
  --model-name custom-form-model \
  --wait-for-completion

# Evaluate model performance
python model-evaluation.py \
  --model-id custom-form-model \
  --test-data ./test-documents/ \
  --metrics accuracy,precision,recall \
  --generate-confusion-matrix
```

### Model Deployment and Versioning
```bash
# Deploy model to production
python model-deployment.py \
  --model-id custom-form-model \
  --deployment-name production \
  --enable-logging \
  --set-default

# Version management
python model-versioning.py \
  --model-name custom-form-model \
  --create-version v2.0 \
  --description "Updated model with improved accuracy"
```

---

## Error Handling and Troubleshooting

### Common Issues

#### Form Recognizer API Rate Limits
```bash
# Monitor and handle rate limits
python form-recognizer-setup.py --enable-retry-policy --max-retries 3 --backoff-factor 2
```

#### Document Processing Failures
```bash
# Reprocess failed documents
python batch-document-processor.py --reprocess-failed --error-log ./processing-errors.log --skip-processed
```

#### Model Performance Issues
```bash
# Retrain model with additional data
python custom-model-training.py --incremental-training --additional-data ./new-training-data/
```

### Monitoring Commands
```bash
# Check Form Recognizer service health
az cognitiveservices account show --name document-form-recognizer --resource-group $AZURE_RESOURCE_GROUP

# Monitor storage account metrics
az storage metrics show --account-name $STORAGE_ACCOUNT_NAME --services blob --interval PT1H

# Check Key Vault access logs
az monitor activity-log list --resource-group $AZURE_RESOURCE_GROUP --max-events 50
```

---

## Integration Patterns

### Azure Logic Apps Integration
```bash
# Deploy Logic App for document workflow
python logic-app-deployment.py \
  --workflow-name document-processing-workflow \
  --trigger-type blob-created \
  --form-recognizer-action analyze-form \
  --output-action store-results
```

### Azure Functions Integration
```bash
# Deploy Azure Functions for processing
python function-deployment.py \
  --function-app document-processor-functions \
  --runtime python \
  --functions form-analyzer,result-processor,error-handler
```

### Power Platform Integration
```bash
# Setup Power Automate connector
python power-platform-integration.py \
  --create-custom-connector \
  --api-definition ./form-recognizer-api.json \
  --enable-authentication
```

---

## Security Best Practices

- Use Azure Active Directory for authentication
- Store API keys and secrets in Azure Key Vault
- Implement Azure RBAC for fine-grained access control
- Enable Azure Private Link for secure network access
- Use Azure Policy for compliance and governance
- Enable Azure Security Center recommendations
- Implement data encryption at rest and in transit

---

## Performance Optimization

- Use batch processing for high-volume scenarios
- Implement caching strategies for frequently processed documents
- Optimize document image quality and size
- Use asynchronous processing patterns
- Monitor and tune API rate limits
- Implement circuit breaker patterns for resilience

---

**Directory Version**: 1.0  
**Last Updated**: January 2025  
**Maintained By**: Azure AI Solutions DevOps Team