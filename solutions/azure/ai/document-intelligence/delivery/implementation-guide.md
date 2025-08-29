# Azure AI Document Intelligence Implementation Guide

## Overview

This comprehensive implementation guide provides step-by-step instructions for deploying the Azure AI Document Intelligence solution. The guide covers multiple deployment scenarios from simple proof-of-concept to enterprise-scale implementations.

## Implementation Phases

### Phase 1: Environment Preparation (1-2 hours)
- Azure subscription setup and access configuration
- Resource group creation and naming conventions
- Service principal and authentication setup
- Required tools installation and configuration

### Phase 2: Core Infrastructure (2-4 hours)
- Azure Cognitive Services deployment
- Storage account and container configuration
- Key Vault setup for secrets management
- Network security and access controls

### Phase 3: AI Services Configuration (2-6 hours)
- Form Recognizer service configuration
- Custom model training (if required)
- Computer Vision service setup
- Language services integration

### Phase 4: Workflow Orchestration (4-8 hours)
- Logic Apps workflow design and deployment
- Azure Functions custom processing logic
- Event Grid event routing configuration
- Service Bus message handling

### Phase 5: Integration and Testing (8-16 hours)
- API integration and testing
- End-to-end workflow validation
- Performance testing and optimization
- Security validation and compliance checks

### Phase 6: Production Deployment (4-8 hours)
- Production environment deployment
- Monitoring and alerting configuration
- Backup and disaster recovery setup
- Documentation and knowledge transfer

## Phase 1: Environment Preparation

### 1.1 Azure Subscription Setup

**Prerequisites Verification:**
```bash
# Verify Azure CLI installation and version
az --version

# Login to Azure
az login

# List available subscriptions
az account list --output table

# Set the target subscription
az account set --subscription "your-subscription-id"

# Verify current subscription context
az account show --output table
```

**Resource Providers Registration:**
```bash
# Register required resource providers
az provider register --namespace Microsoft.CognitiveServices
az provider register --namespace Microsoft.Logic
az provider register --namespace Microsoft.Storage
az provider register --namespace Microsoft.KeyVault
az provider register --namespace Microsoft.EventGrid
az provider register --namespace Microsoft.ServiceBus
az provider register --namespace Microsoft.Web
az provider register --namespace Microsoft.Insights

# Verify registration status
az provider list --query "[?namespace=='Microsoft.CognitiveServices']" --output table
```

### 1.2 Resource Naming and Conventions

**Naming Convention Standards:**
```
Resource Type: [prefix]-[solution]-[environment]-[region]-[instance]

Examples:
- Resource Group: rg-docintel-prod-eus2-001
- Form Recognizer: fr-docintel-prod-eus2-001
- Storage Account: stdocintelprodeus2001
- Key Vault: kv-docintel-prod-eus2-001
- Logic App: la-docintel-prod-eus2-001
- Function App: func-docintel-prod-eus2-001
```

### 1.3 Service Principal Creation

```bash
# Create service principal for automation
az ad sp create-for-rbac \
  --name "sp-document-intelligence-prod" \
  --role "Contributor" \
  --scopes "/subscriptions/your-subscription-id"

# Output will include:
# - appId (Application ID)
# - displayName
# - password (Client Secret)
# - tenant (Tenant ID)

# Save these credentials securely for later use
```

### 1.4 Resource Group Creation

```bash
# Create primary resource group
az group create \
  --name "rg-docintel-prod-eus2-001" \
  --location "East US 2" \
  --tags "Environment=Production" "Solution=DocumentIntelligence" "Owner=ITTeam"

# Create secondary resource group for monitoring
az group create \
  --name "rg-docintel-monitoring-eus2-001" \
  --location "East US 2" \
  --tags "Environment=Production" "Solution=DocumentIntelligence" "Purpose=Monitoring"
```

## Phase 2: Core Infrastructure Deployment

### 2.1 Azure Storage Account

```bash
# Create storage account for document processing
az storage account create \
  --name "stdocintelprodeus2001" \
  --resource-group "rg-docintel-prod-eus2-001" \
  --location "East US 2" \
  --sku "Standard_GRS" \
  --kind "StorageV2" \
  --access-tier "Hot" \
  --https-only true \
  --min-tls-version "TLS1_2" \
  --allow-blob-public-access false \
  --tags "Environment=Production" "Solution=DocumentIntelligence"

# Create blob containers
az storage container create \
  --name "input-documents" \
  --account-name "stdocintelprodeus2001" \
  --auth-mode login

az storage container create \
  --name "processed-documents" \
  --account-name "stdocintelprodeus2001" \
  --auth-mode login

az storage container create \
  --name "failed-documents" \
  --account-name "stdocintelprodeus2001" \
  --auth-mode login

# Configure lifecycle management
cat > lifecycle-policy.json << EOF
{
  "rules": [
    {
      "enabled": true,
      "name": "ArchiveOldDocuments",
      "type": "Lifecycle",
      "definition": {
        "filters": {
          "blobTypes": ["blockBlob"],
          "prefixMatch": ["processed-documents/"]
        },
        "actions": {
          "baseBlob": {
            "tierToCool": {
              "daysAfterModificationGreaterThan": 30
            },
            "tierToArchive": {
              "daysAfterModificationGreaterThan": 90
            }
          }
        }
      }
    }
  ]
}
EOF

az storage account management-policy create \
  --account-name "stdocintelprodeus2001" \
  --policy @lifecycle-policy.json
```

### 2.2 Azure Key Vault

```bash
# Create Key Vault
az keyvault create \
  --name "kv-docintel-prod-eus2-001" \
  --resource-group "rg-docintel-prod-eus2-001" \
  --location "East US 2" \
  --sku "Standard" \
  --enable-soft-delete true \
  --retention-days 90 \
  --tags "Environment=Production" "Solution=DocumentIntelligence"

# Set access policies for current user
az keyvault set-policy \
  --name "kv-docintel-prod-eus2-001" \
  --upn "your-email@domain.com" \
  --secret-permissions get list set delete recover backup restore \
  --key-permissions get list create delete recover backup restore \
  --certificate-permissions get list create delete recover backup restore

# Create network access rules (optional - for enhanced security)
az keyvault network-rule add \
  --name "kv-docintel-prod-eus2-001" \
  --subnet "/subscriptions/your-subscription-id/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-prod/subnets/subnet-services"
```

### 2.3 Log Analytics Workspace

```bash
# Create Log Analytics workspace for monitoring
az monitor log-analytics workspace create \
  --workspace-name "log-docintel-prod-eus2-001" \
  --resource-group "rg-docintel-monitoring-eus2-001" \
  --location "East US 2" \
  --sku "PerGB2018" \
  --retention-time 30 \
  --tags "Environment=Production" "Solution=DocumentIntelligence"

# Get workspace ID and key for later use
WORKSPACE_ID=$(az monitor log-analytics workspace show \
  --workspace-name "log-docintel-prod-eus2-001" \
  --resource-group "rg-docintel-monitoring-eus2-001" \
  --query customerId -o tsv)

WORKSPACE_KEY=$(az monitor log-analytics workspace get-shared-keys \
  --workspace-name "log-docintel-prod-eus2-001" \
  --resource-group "rg-docintel-monitoring-eus2-001" \
  --query primarySharedKey -o tsv)
```

## Phase 3: AI Services Configuration

### 3.1 Azure Form Recognizer Service

```bash
# Create Form Recognizer service
az cognitiveservices account create \
  --name "fr-docintel-prod-eus2-001" \
  --resource-group "rg-docintel-prod-eus2-001" \
  --kind "FormRecognizer" \
  --sku "S0" \
  --location "East US 2" \
  --custom-domain "fr-docintel-prod-eus2-001" \
  --tags "Environment=Production" "Solution=DocumentIntelligence"

# Get service endpoint and key
FR_ENDPOINT=$(az cognitiveservices account show \
  --name "fr-docintel-prod-eus2-001" \
  --resource-group "rg-docintel-prod-eus2-001" \
  --query "properties.endpoint" -o tsv)

FR_KEY=$(az cognitiveservices account keys list \
  --name "fr-docintel-prod-eus2-001" \
  --resource-group "rg-docintel-prod-eus2-001" \
  --query "key1" -o tsv)

# Store secrets in Key Vault
az keyvault secret set \
  --vault-name "kv-docintel-prod-eus2-001" \
  --name "FormRecognizerEndpoint" \
  --value "$FR_ENDPOINT"

az keyvault secret set \
  --vault-name "kv-docintel-prod-eus2-001" \
  --name "FormRecognizerKey" \
  --value "$FR_KEY"
```

### 3.2 Custom Vision Service (Optional)

```bash
# Create Custom Vision service for document classification
az cognitiveservices account create \
  --name "cv-docintel-prod-eus2-001" \
  --resource-group "rg-docintel-prod-eus2-001" \
  --kind "CustomVision.Training" \
  --sku "S0" \
  --location "East US 2" \
  --tags "Environment=Production" "Solution=DocumentIntelligence"

az cognitiveservices account create \
  --name "cvp-docintel-prod-eus2-001" \
  --resource-group "rg-docintel-prod-eus2-001" \
  --kind "CustomVision.Prediction" \
  --sku "S0" \
  --location "East US 2" \
  --tags "Environment=Production" "Solution=DocumentIntelligence"
```

### 3.3 Computer Vision Service

```bash
# Create Computer Vision service for preprocessing
az cognitiveservices account create \
  --name "cs-docintel-prod-eus2-001" \
  --resource-group "rg-docintel-prod-eus2-001" \
  --kind "ComputerVision" \
  --sku "S1" \
  --location "East US 2" \
  --tags "Environment=Production" "Solution=DocumentIntelligence"

# Store endpoint and key in Key Vault
CV_ENDPOINT=$(az cognitiveservices account show \
  --name "cs-docintel-prod-eus2-001" \
  --resource-group "rg-docintel-prod-eus2-001" \
  --query "properties.endpoint" -o tsv)

CV_KEY=$(az cognitiveservices account keys list \
  --name "cs-docintel-prod-eus2-001" \
  --resource-group "rg-docintel-prod-eus2-001" \
  --query "key1" -o tsv)

az keyvault secret set \
  --vault-name "kv-docintel-prod-eus2-001" \
  --name "ComputerVisionEndpoint" \
  --value "$CV_ENDPOINT"

az keyvault secret set \
  --vault-name "kv-docintel-prod-eus2-001" \
  --name "ComputerVisionKey" \
  --value "$CV_KEY"
```

## Phase 4: Workflow Orchestration

### 4.1 Azure Functions App

```bash
# Create App Service Plan for Functions
az appservice plan create \
  --name "plan-docintel-prod-eus2-001" \
  --resource-group "rg-docintel-prod-eus2-001" \
  --location "East US 2" \
  --sku "P1v3" \
  --is-linux false \
  --tags "Environment=Production" "Solution=DocumentIntelligence"

# Create Function App
az functionapp create \
  --name "func-docintel-prod-eus2-001" \
  --resource-group "rg-docintel-prod-eus2-001" \
  --plan "plan-docintel-prod-eus2-001" \
  --storage-account "stdocintelprodeus2001" \
  --runtime "python" \
  --runtime-version "3.9" \
  --tags "Environment=Production" "Solution=DocumentIntelligence"

# Configure application settings
az functionapp config appsettings set \
  --name "func-docintel-prod-eus2-001" \
  --resource-group "rg-docintel-prod-eus2-001" \
  --settings \
    "APPINSIGHTS_INSTRUMENTATIONKEY=your-app-insights-key" \
    "AZURE_KEYVAULT_URL=https://kv-docintel-prod-eus2-001.vault.azure.net/" \
    "FUNCTIONS_WORKER_RUNTIME=python"
```

### 4.2 Logic Apps Workflow

```json
// Create Logic App workflow definition
{
  "definition": {
    "$schema": "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {},
    "triggers": {
      "When_a_blob_is_added_or_modified": {
        "type": "ApiConnection",
        "inputs": {
          "host": {
            "connection": {
              "name": "@parameters('$connections')['azureblob']['connectionId']"
            }
          },
          "method": "get",
          "path": "/datasets/default/triggers/batch/onupdatedfile",
          "queries": {
            "folderId": "input-documents",
            "maxFileCount": 10
          }
        },
        "recurrence": {
          "frequency": "Minute",
          "interval": 1
        }
      }
    },
    "actions": {
      "Process_Document": {
        "type": "Function",
        "inputs": {
          "function": {
            "id": "/subscriptions/your-subscription-id/resourceGroups/rg-docintel-prod-eus2-001/providers/Microsoft.Web/sites/func-docintel-prod-eus2-001/functions/ProcessDocument"
          },
          "body": {
            "blobUri": "@triggerBody()?['Path']",
            "fileName": "@triggerBody()?['Name']"
          }
        }
      }
    }
  }
}
```

### 4.3 Event Grid Configuration

```bash
# Create custom Event Grid topic
az eventgrid topic create \
  --name "eg-docintel-prod-eus2-001" \
  --resource-group "rg-docintel-prod-eus2-001" \
  --location "East US 2" \
  --tags "Environment=Production" "Solution=DocumentIntelligence"

# Create event subscription for document processing
az eventgrid event-subscription create \
  --name "document-processed" \
  --source-resource-id "/subscriptions/your-subscription-id/resourceGroups/rg-docintel-prod-eus2-001/providers/Microsoft.EventGrid/topics/eg-docintel-prod-eus2-001" \
  --endpoint "https://func-docintel-prod-eus2-001.azurewebsites.net/api/DocumentProcessed" \
  --endpoint-type "webhook"
```

### 4.4 Service Bus Configuration

```bash
# Create Service Bus namespace
az servicebus namespace create \
  --name "sb-docintel-prod-eus2-001" \
  --resource-group "rg-docintel-prod-eus2-001" \
  --location "East US 2" \
  --sku "Standard" \
  --tags "Environment=Production" "Solution=DocumentIntelligence"

# Create queues for different document types
az servicebus queue create \
  --name "invoices" \
  --namespace-name "sb-docintel-prod-eus2-001" \
  --resource-group "rg-docintel-prod-eus2-001" \
  --max-size 5120 \
  --default-message-time-to-live "P14D"

az servicebus queue create \
  --name "receipts" \
  --namespace-name "sb-docintel-prod-eus2-001" \
  --resource-group "rg-docintel-prod-eus2-001" \
  --max-size 5120 \
  --default-message-time-to-live "P14D"

az servicebus queue create \
  --name "contracts" \
  --namespace-name "sb-docintel-prod-eus2-001" \
  --resource-group "rg-docintel-prod-eus2-001" \
  --max-size 5120 \
  --default-message-time-to-live "P14D"
```

## Phase 5: Application Development and Deployment

### 5.1 Function App Code Deployment

**Document Processing Function (Python):**
```python
import azure.functions as func
import json
import os
import logging
from azure.ai.formrecognizer import DocumentAnalysisClient
from azure.core.credentials import AzureKeyCredential
from azure.keyvault.secrets import SecretClient
from azure.identity import DefaultAzureCredential

def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Document processing function triggered.')
    
    try:
        # Get request data
        req_body = req.get_json()
        blob_uri = req_body.get('blobUri')
        file_name = req_body.get('fileName')
        
        # Get credentials from Key Vault
        credential = DefaultAzureCredential()
        secret_client = SecretClient(
            vault_url=os.getenv('AZURE_KEYVAULT_URL'),
            credential=credential
        )
        
        endpoint = secret_client.get_secret('FormRecognizerEndpoint').value
        key = secret_client.get_secret('FormRecognizerKey').value
        
        # Initialize Form Recognizer client
        document_client = DocumentAnalysisClient(
            endpoint=endpoint,
            credential=AzureKeyCredential(key)
        )
        
        # Process document
        with open(blob_uri, 'rb') as document:
            poller = document_client.begin_analyze_document(
                'prebuilt-document',
                document
            )
            result = poller.result()
        
        # Extract data
        extracted_data = {
            'fileName': file_name,
            'pages': len(result.pages),
            'tables': len(result.tables),
            'keyValuePairs': len(result.key_value_pairs),
            'content': result.content[:1000]  # First 1000 characters
        }
        
        # Return results
        return func.HttpResponse(
            json.dumps(extracted_data),
            status_code=200,
            mimetype='application/json'
        )
        
    except Exception as e:
        logging.error(f'Error processing document: {str(e)}')
        return func.HttpResponse(
            json.dumps({'error': str(e)}),
            status_code=500,
            mimetype='application/json'
        )
```

### 5.2 Deploy Function Code

```bash
# Create deployment package
zip -r function-app.zip . -x "*.git*" "*.vscode*" "__pycache__*"

# Deploy to Function App
az functionapp deployment source config-zip \
  --name "func-docintel-prod-eus2-001" \
  --resource-group "rg-docintel-prod-eus2-001" \
  --src function-app.zip
```

### 5.3 API Management Configuration

```bash
# Create API Management instance
az apim create \
  --name "apim-docintel-prod-eus2-001" \
  --resource-group "rg-docintel-prod-eus2-001" \
  --location "East US 2" \
  --publisher-email "admin@yourcompany.com" \
  --publisher-name "Document Intelligence Team" \
  --sku-name "Developer" \
  --tags "Environment=Production" "Solution=DocumentIntelligence"

# Import Function App API
az apim api import \
  --resource-group "rg-docintel-prod-eus2-001" \
  --service-name "apim-docintel-prod-eus2-001" \
  --path "/document-processing" \
  --specification-format "OpenApi" \
  --specification-url "https://func-docintel-prod-eus2-001.azurewebsites.net/api/openapi/v3.json"
```

## Phase 6: Testing and Validation

### 6.1 Unit Testing

```python
# test_document_processing.py
import unittest
import json
from unittest.mock import patch, Mock
from document_processing import main

class TestDocumentProcessing(unittest.TestCase):
    
    @patch('document_processing.DocumentAnalysisClient')
    @patch('document_processing.SecretClient')
    def test_successful_document_processing(self, mock_secret_client, mock_doc_client):
        # Mock setup
        mock_secret_client.return_value.get_secret.return_value.value = 'mock_value'
        mock_result = Mock()
        mock_result.pages = []
        mock_result.tables = []
        mock_result.key_value_pairs = []
        mock_result.content = 'Test content'
        
        mock_doc_client.return_value.begin_analyze_document.return_value.result.return_value = mock_result
        
        # Test data
        test_request = Mock()
        test_request.get_json.return_value = {
            'blobUri': '/path/to/test.pdf',
            'fileName': 'test.pdf'
        }
        
        # Execute test
        response = main(test_request)
        
        # Assertions
        self.assertEqual(response.status_code, 200)
        response_data = json.loads(response.get_body())
        self.assertEqual(response_data['fileName'], 'test.pdf')

if __name__ == '__main__':
    unittest.main()
```

### 6.2 Integration Testing

```bash
# Test document upload and processing
curl -X POST "https://apim-docintel-prod-eus2-001.azure-api.net/document-processing/api/ProcessDocument" \
  -H "Content-Type: application/json" \
  -H "Ocp-Apim-Subscription-Key: your-subscription-key" \
  -d '{
    "blobUri": "https://stdocintelprodeus2001.blob.core.windows.net/input-documents/test-invoice.pdf",
    "fileName": "test-invoice.pdf"
  }'
```

### 6.3 Load Testing

```bash
# Install Azure Load Testing CLI extension
az extension add --name load

# Create load test
az load test create \
  --name "docintel-load-test" \
  --resource-group "rg-docintel-prod-eus2-001" \
  --load-test-config-file "load-test-config.yaml"

# Run load test
az load test run \
  --name "docintel-load-test" \
  --resource-group "rg-docintel-prod-eus2-001"
```

## Phase 7: Production Deployment and Monitoring

### 7.1 Application Insights Configuration

```bash
# Create Application Insights
az monitor app-insights component create \
  --app "ai-docintel-prod-eus2-001" \
  --resource-group "rg-docintel-monitoring-eus2-001" \
  --location "East US 2" \
  --kind "web" \
  --workspace "/subscriptions/your-subscription-id/resourceGroups/rg-docintel-monitoring-eus2-001/providers/Microsoft.OperationalInsights/workspaces/log-docintel-prod-eus2-001"

# Get instrumentation key
APP_INSIGHTS_KEY=$(az monitor app-insights component show \
  --app "ai-docintel-prod-eus2-001" \
  --resource-group "rg-docintel-monitoring-eus2-001" \
  --query "instrumentationKey" -o tsv)

# Update Function App settings
az functionapp config appsettings set \
  --name "func-docintel-prod-eus2-001" \
  --resource-group "rg-docintel-prod-eus2-001" \
  --settings "APPINSIGHTS_INSTRUMENTATIONKEY=$APP_INSIGHTS_KEY"
```

### 7.2 Alerting Rules

```bash
# Create alert rule for high error rate
az monitor metrics alert create \
  --name "High Error Rate" \
  --resource-group "rg-docintel-monitoring-eus2-001" \
  --scopes "/subscriptions/your-subscription-id/resourceGroups/rg-docintel-prod-eus2-001/providers/Microsoft.Web/sites/func-docintel-prod-eus2-001" \
  --condition "count 'customEvents/FailedDocumentProcessing' aggregation Count > 10" \
  --window-size "5m" \
  --evaluation-frequency "1m" \
  --severity 2 \
  --description "Alert when document processing error rate is high"

# Create alert rule for service availability
az monitor metrics alert create \
  --name "Service Unavailable" \
  --resource-group "rg-docintel-monitoring-eus2-001" \
  --scopes "/subscriptions/your-subscription-id/resourceGroups/rg-docintel-prod-eus2-001/providers/Microsoft.CognitiveServices/accounts/fr-docintel-prod-eus2-001" \
  --condition "average 'TotalCalls' aggregation Average < 1" \
  --window-size "15m" \
  --evaluation-frequency "5m" \
  --severity 1 \
  --description "Alert when Form Recognizer service appears unavailable"
```

### 7.3 Backup and Disaster Recovery

```bash
# Configure geo-redundant backup for storage
az storage account update \
  --name "stdocintelprodeus2001" \
  --resource-group "rg-docintel-prod-eus2-001" \
  --sku "Standard_GRS"

# Create backup policies
az backup policy create \
  --policy backup-policy.json \
  --resource-group "rg-docintel-prod-eus2-001" \
  --vault-name "rsv-docintel-prod-eus2-001"
```

## Post-Deployment Checklist

### Security Validation
- [ ] All secrets stored in Key Vault
- [ ] RBAC permissions configured correctly
- [ ] Network security rules in place
- [ ] SSL/TLS certificates validated
- [ ] API authentication working
- [ ] Storage account access controls verified

### Functionality Testing
- [ ] Document upload functionality
- [ ] Form Recognizer processing
- [ ] Custom model accuracy (if applicable)
- [ ] Workflow orchestration
- [ ] Error handling and retry logic
- [ ] Integration with downstream systems

### Performance Verification
- [ ] Response time within SLA
- [ ] Throughput meets requirements
- [ ] Resource utilization optimized
- [ ] Scaling behavior validated
- [ ] Load testing completed
- [ ] Cost optimization implemented

### Monitoring and Alerting
- [ ] Application Insights configured
- [ ] Custom metrics collecting
- [ ] Alert rules active
- [ ] Dashboard accessible
- [ ] Log retention policies set
- [ ] Notification channels tested

### Documentation and Training
- [ ] Technical documentation complete
- [ ] User guides created
- [ ] Training materials prepared
- [ ] Support procedures documented
- [ ] Runbook validated
- [ ] Knowledge transfer completed

## Next Steps

1. **User Acceptance Testing**: Schedule UAT with business stakeholders
2. **Production Cutover**: Plan migration from existing systems
3. **Monitoring Setup**: Establish baseline metrics and thresholds  
4. **Support Handover**: Transfer knowledge to operations team
5. **Continuous Improvement**: Establish regular review and optimization cycles

For ongoing operations and maintenance procedures, see [operations-runbook.md](operations-runbook.md).