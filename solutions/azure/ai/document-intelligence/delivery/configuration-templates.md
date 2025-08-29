# Azure AI Document Intelligence Configuration Templates

## Overview

This document provides comprehensive configuration templates for all components of the Azure AI Document Intelligence solution. These templates serve as starting points for different deployment scenarios and can be customized based on specific requirements.

## ARM Template Configurations

### 1. Core Infrastructure ARM Template

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "environmentName": {
      "type": "string",
      "defaultValue": "prod",
      "allowedValues": ["dev", "test", "prod"],
      "metadata": {
        "description": "Environment designation"
      }
    },
    "location": {
      "type": "string",
      "defaultValue": "[resourceGroup().location]",
      "metadata": {
        "description": "Location for all resources"
      }
    },
    "solutionPrefix": {
      "type": "string",
      "defaultValue": "docintel",
      "maxLength": 8,
      "metadata": {
        "description": "Prefix for resource naming"
      }
    }
  },
  "variables": {
    "storageAccountName": "[concat('st', parameters('solutionPrefix'), parameters('environmentName'), substring(uniqueString(resourceGroup().id), 0, 4))]",
    "formRecognizerName": "[concat('fr-', parameters('solutionPrefix'), '-', parameters('environmentName'), '-001')]",
    "keyVaultName": "[concat('kv-', parameters('solutionPrefix'), '-', parameters('environmentName'), '-001')]",
    "logAnalyticsName": "[concat('log-', parameters('solutionPrefix'), '-', parameters('environmentName'), '-001')]"
  },
  "resources": [
    {
      "type": "Microsoft.Storage/storageAccounts",
      "apiVersion": "2023-01-01",
      "name": "[variables('storageAccountName')]",
      "location": "[parameters('location')]",
      "sku": {
        "name": "Standard_GRS"
      },
      "kind": "StorageV2",
      "properties": {
        "accessTier": "Hot",
        "supportsHttpsTrafficOnly": true,
        "minimumTlsVersion": "TLS1_2",
        "allowBlobPublicAccess": false,
        "networkAcls": {
          "defaultAction": "Allow",
          "bypass": "AzureServices"
        },
        "encryption": {
          "services": {
            "blob": {
              "enabled": true
            },
            "file": {
              "enabled": true
            }
          },
          "keySource": "Microsoft.Storage"
        }
      },
      "resources": [
        {
          "type": "blobServices/containers",
          "apiVersion": "2023-01-01",
          "name": "[concat('default/input-documents')]",
          "dependsOn": [
            "[variables('storageAccountName')]"
          ],
          "properties": {
            "publicAccess": "None"
          }
        },
        {
          "type": "blobServices/containers",
          "apiVersion": "2023-01-01",
          "name": "[concat('default/processed-documents')]",
          "dependsOn": [
            "[variables('storageAccountName')]"
          ],
          "properties": {
            "publicAccess": "None"
          }
        },
        {
          "type": "blobServices/containers",
          "apiVersion": "2023-01-01",
          "name": "[concat('default/failed-documents')]",
          "dependsOn": [
            "[variables('storageAccountName')]"
          ],
          "properties": {
            "publicAccess": "None"
          }
        }
      ]
    },
    {
      "type": "Microsoft.CognitiveServices/accounts",
      "apiVersion": "2023-05-01",
      "name": "[variables('formRecognizerName')]",
      "location": "[parameters('location')]",
      "sku": {
        "name": "S0"
      },
      "kind": "FormRecognizer",
      "properties": {
        "customSubDomainName": "[variables('formRecognizerName')]",
        "networkAcls": {
          "defaultAction": "Allow",
          "ipRules": [],
          "virtualNetworkRules": []
        },
        "publicNetworkAccess": "Enabled"
      }
    },
    {
      "type": "Microsoft.KeyVault/vaults",
      "apiVersion": "2023-02-01",
      "name": "[variables('keyVaultName')]",
      "location": "[parameters('location')]",
      "properties": {
        "sku": {
          "family": "A",
          "name": "standard"
        },
        "tenantId": "[subscription().tenantId]",
        "enabledForDeployment": false,
        "enabledForTemplateDeployment": true,
        "enabledForDiskEncryption": false,
        "enableSoftDelete": true,
        "softDeleteRetentionInDays": 90,
        "enablePurgeProtection": true,
        "accessPolicies": [
          {
            "tenantId": "[subscription().tenantId]",
            "objectId": "[reference(resourceId('Microsoft.Web/sites', variables('functionAppName')), '2022-03-01', 'Full').identity.principalId]",
            "permissions": {
              "secrets": [
                "get",
                "list"
              ]
            }
          }
        ],
        "networkAcls": {
          "defaultAction": "Allow",
          "bypass": "AzureServices"
        }
      }
    },
    {
      "type": "Microsoft.OperationalInsights/workspaces",
      "apiVersion": "2022-10-01",
      "name": "[variables('logAnalyticsName')]",
      "location": "[parameters('location')]",
      "properties": {
        "sku": {
          "name": "PerGB2018"
        },
        "retentionInDays": 30,
        "features": {
          "enableLogAccessUsingOnlyResourcePermissions": true
        },
        "workspaceCapping": {
          "dailyQuotaGb": -1
        },
        "publicNetworkAccessForIngestion": "Enabled",
        "publicNetworkAccessForQuery": "Enabled"
      }
    }
  ],
  "outputs": {
    "storageAccountName": {
      "type": "string",
      "value": "[variables('storageAccountName')]"
    },
    "formRecognizerEndpoint": {
      "type": "string",
      "value": "[reference(resourceId('Microsoft.CognitiveServices/accounts', variables('formRecognizerName'))).endpoint]"
    },
    "keyVaultUri": {
      "type": "string",
      "value": "[reference(resourceId('Microsoft.KeyVault/vaults', variables('keyVaultName'))).vaultUri]"
    }
  }
}
```

### 2. Function App ARM Template

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "functionAppName": {
      "type": "string"
    },
    "storageAccountName": {
      "type": "string"
    },
    "appInsightsInstrumentationKey": {
      "type": "string"
    },
    "keyVaultUri": {
      "type": "string"
    }
  },
  "variables": {
    "hostingPlanName": "[concat('plan-', parameters('functionAppName'))]"
  },
  "resources": [
    {
      "type": "Microsoft.Web/serverfarms",
      "apiVersion": "2022-03-01",
      "name": "[variables('hostingPlanName')]",
      "location": "[resourceGroup().location]",
      "sku": {
        "name": "P1v3",
        "tier": "PremiumV3",
        "size": "P1v3",
        "family": "Pv3",
        "capacity": 1
      },
      "kind": "app",
      "properties": {
        "perSiteScaling": false,
        "elasticScaleEnabled": false,
        "maximumElasticWorkerCount": 1,
        "isSpot": false,
        "reserved": false,
        "isXenon": false,
        "hyperV": false,
        "targetWorkerCount": 0,
        "targetWorkerSizeId": 0,
        "zoneRedundant": false
      }
    },
    {
      "type": "Microsoft.Web/sites",
      "apiVersion": "2022-03-01",
      "name": "[parameters('functionAppName')]",
      "location": "[resourceGroup().location]",
      "kind": "functionapp",
      "identity": {
        "type": "SystemAssigned"
      },
      "dependsOn": [
        "[resourceId('Microsoft.Web/serverfarms', variables('hostingPlanName'))]"
      ],
      "properties": {
        "enabled": true,
        "hostNameSslStates": [
          {
            "name": "[concat(parameters('functionAppName'), '.azurewebsites.net')]",
            "sslState": "Disabled",
            "hostType": "Standard"
          },
          {
            "name": "[concat(parameters('functionAppName'), '.scm.azurewebsites.net')]",
            "sslState": "Disabled",
            "hostType": "Repository"
          }
        ],
        "serverFarmId": "[resourceId('Microsoft.Web/serverfarms', variables('hostingPlanName'))]",
        "reserved": false,
        "isXenon": false,
        "hyperV": false,
        "siteConfig": {
          "numberOfWorkers": 1,
          "acrUseManagedIdentityCreds": false,
          "alwaysOn": true,
          "http20Enabled": false,
          "functionAppScaleLimit": 200,
          "minimumElasticInstanceCount": 1,
          "appSettings": [
            {
              "name": "AzureWebJobsStorage",
              "value": "[concat('DefaultEndpointsProtocol=https;AccountName=', parameters('storageAccountName'), ';AccountKey=', listKeys(resourceId('Microsoft.Storage/storageAccounts', parameters('storageAccountName')), '2023-01-01').keys[0].value)]"
            },
            {
              "name": "WEBSITE_CONTENTAZUREFILECONNECTIONSTRING",
              "value": "[concat('DefaultEndpointsProtocol=https;AccountName=', parameters('storageAccountName'), ';AccountKey=', listKeys(resourceId('Microsoft.Storage/storageAccounts', parameters('storageAccountName')), '2023-01-01').keys[0].value)]"
            },
            {
              "name": "WEBSITE_CONTENTSHARE",
              "value": "[toLower(parameters('functionAppName'))]"
            },
            {
              "name": "FUNCTIONS_EXTENSION_VERSION",
              "value": "~4"
            },
            {
              "name": "FUNCTIONS_WORKER_RUNTIME",
              "value": "python"
            },
            {
              "name": "APPINSIGHTS_INSTRUMENTATIONKEY",
              "value": "[parameters('appInsightsInstrumentationKey')]"
            },
            {
              "name": "AZURE_KEYVAULT_URL",
              "value": "[parameters('keyVaultUri')]"
            }
          ]
        },
        "scmSiteAlsoStopped": false,
        "clientAffinityEnabled": false,
        "clientCertEnabled": false,
        "hostNamesDisabled": false,
        "httpsOnly": true
      }
    }
  ]
}
```

## Terraform Configurations

### 3. Main Terraform Configuration

```hcl
# main.tf
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# Data sources
data "azurerm_client_config" "current" {}
data "azuread_client_config" "current" {}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "rg-${var.solution_prefix}-${var.environment}-${var.location_short}-001"
  location = var.location

  tags = var.default_tags
}

# Storage Account
resource "azurerm_storage_account" "documents" {
  name                     = "st${var.solution_prefix}${var.environment}${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = var.environment == "prod" ? "GRS" : "LRS"
  account_kind             = "StorageV2"
  access_tier              = "Hot"

  min_tls_version                 = "TLS1_2"
  https_traffic_only_enabled      = true
  allow_nested_items_to_be_public = false

  blob_properties {
    cors_rule {
      allowed_headers    = ["*"]
      allowed_methods    = ["GET", "POST", "PUT"]
      allowed_origins    = ["https://*.azurewebsites.net"]
      exposed_headers    = ["*"]
      max_age_in_seconds = 3600
    }

    delete_retention_policy {
      days = var.environment == "prod" ? 30 : 7
    }

    container_delete_retention_policy {
      days = var.environment == "prod" ? 30 : 7
    }

    versioning_enabled = var.environment == "prod" ? true : false
  }

  tags = var.default_tags
}

# Storage Containers
resource "azurerm_storage_container" "input_documents" {
  name                  = "input-documents"
  storage_account_name  = azurerm_storage_account.documents.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "processed_documents" {
  name                  = "processed-documents"
  storage_account_name  = azurerm_storage_account.documents.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "failed_documents" {
  name                  = "failed-documents"
  storage_account_name  = azurerm_storage_account.documents.name
  container_access_type = "private"
}

# Form Recognizer Service
resource "azurerm_cognitive_account" "form_recognizer" {
  name                = "fr-${var.solution_prefix}-${var.environment}-${var.location_short}-001"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  kind                = "FormRecognizer"
  sku_name            = var.form_recognizer_sku

  custom_subdomain_name = "fr-${var.solution_prefix}-${var.environment}-${var.location_short}-001"

  network_acls {
    default_action = "Allow"
  }

  tags = var.default_tags
}

# Computer Vision Service
resource "azurerm_cognitive_account" "computer_vision" {
  name                = "cv-${var.solution_prefix}-${var.environment}-${var.location_short}-001"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  kind                = "ComputerVision"
  sku_name            = var.computer_vision_sku

  tags = var.default_tags
}

# Key Vault
resource "azurerm_key_vault" "main" {
  name                = "kv-${var.solution_prefix}-${var.environment}-${var.location_short}-001"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  enabled_for_disk_encryption     = false
  enabled_for_deployment          = false
  enabled_for_template_deployment = true
  enable_rbac_authorization       = false
  purge_protection_enabled        = var.environment == "prod" ? true : false
  soft_delete_retention_days      = 90

  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }

  tags = var.default_tags
}

# Key Vault Access Policy for Current User
resource "azurerm_key_vault_access_policy" "current_user" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = [
    "Get", "List", "Set", "Delete", "Recover", "Backup", "Restore"
  ]

  key_permissions = [
    "Get", "List", "Create", "Delete", "Recover", "Backup", "Restore"
  ]

  certificate_permissions = [
    "Get", "List", "Create", "Delete", "Recover", "Backup", "Restore"
  ]
}

# Store secrets in Key Vault
resource "azurerm_key_vault_secret" "form_recognizer_endpoint" {
  name         = "FormRecognizerEndpoint"
  value        = azurerm_cognitive_account.form_recognizer.endpoint
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [azurerm_key_vault_access_policy.current_user]

  tags = var.default_tags
}

resource "azurerm_key_vault_secret" "form_recognizer_key" {
  name         = "FormRecognizerKey"
  value        = azurerm_cognitive_account.form_recognizer.primary_access_key
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [azurerm_key_vault_access_policy.current_user]

  tags = var.default_tags
}

# Random string for unique naming
resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}
```

### 4. Terraform Variables

```hcl
# variables.tf
variable "solution_prefix" {
  description = "Prefix for resource naming"
  type        = string
  default     = "docintel"
  
  validation {
    condition     = can(regex("^[a-z0-9]{3,8}$", var.solution_prefix))
    error_message = "Solution prefix must be 3-8 characters, lowercase letters and numbers only."
  }
}

variable "environment" {
  description = "Environment designation"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "test", "stage", "prod"], var.environment)
    error_message = "Environment must be one of: dev, test, stage, prod."
  }
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US 2"
}

variable "location_short" {
  description = "Short code for Azure region"
  type        = string
  default     = "eus2"
}

variable "form_recognizer_sku" {
  description = "SKU for Form Recognizer service"
  type        = string
  default     = "S0"
  
  validation {
    condition     = contains(["F0", "S0"], var.form_recognizer_sku)
    error_message = "Form Recognizer SKU must be F0 or S0."
  }
}

variable "computer_vision_sku" {
  description = "SKU for Computer Vision service"
  type        = string
  default     = "S1"
  
  validation {
    condition     = contains(["F0", "S0", "S1"], var.computer_vision_sku)
    error_message = "Computer Vision SKU must be F0, S0, or S1."
  }
}

variable "default_tags" {
  description = "Default tags for all resources"
  type        = map(string)
  default = {
    Solution    = "DocumentIntelligence"
    ManagedBy   = "Terraform"
    Environment = "dev"
  }
}
```

### 5. Terraform Outputs

```hcl
# outputs.tf
output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = azurerm_storage_account.documents.name
}

output "storage_account_primary_connection_string" {
  description = "Primary connection string for storage account"
  value       = azurerm_storage_account.documents.primary_connection_string
  sensitive   = true
}

output "form_recognizer_endpoint" {
  description = "Endpoint URL for Form Recognizer service"
  value       = azurerm_cognitive_account.form_recognizer.endpoint
}

output "form_recognizer_key" {
  description = "Primary access key for Form Recognizer service"
  value       = azurerm_cognitive_account.form_recognizer.primary_access_key
  sensitive   = true
}

output "computer_vision_endpoint" {
  description = "Endpoint URL for Computer Vision service"
  value       = azurerm_cognitive_account.computer_vision.endpoint
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = azurerm_key_vault.main.vault_uri
}

output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = azurerm_key_vault.main.name
}
```

## Application Configurations

### 6. Function App Configuration

```python
# config.py - Function App configuration
import os
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient

class Config:
    """Configuration class for Document Intelligence Function App"""
    
    def __init__(self):
        # Key Vault configuration
        self.key_vault_url = os.getenv('AZURE_KEYVAULT_URL')
        self.credential = DefaultAzureCredential()
        
        if self.key_vault_url:
            self.secret_client = SecretClient(
                vault_url=self.key_vault_url,
                credential=self.credential
            )
        
        # Form Recognizer configuration
        self.form_recognizer_endpoint = self._get_secret_or_env('FormRecognizerEndpoint', 'FORM_RECOGNIZER_ENDPOINT')
        self.form_recognizer_key = self._get_secret_or_env('FormRecognizerKey', 'FORM_RECOGNIZER_KEY')
        
        # Computer Vision configuration
        self.computer_vision_endpoint = self._get_secret_or_env('ComputerVisionEndpoint', 'COMPUTER_VISION_ENDPOINT')
        self.computer_vision_key = self._get_secret_or_env('ComputerVisionKey', 'COMPUTER_VISION_KEY')
        
        # Storage configuration
        self.storage_connection_string = os.getenv('AzureWebJobsStorage')
        
        # Processing configuration
        self.max_pages_per_document = int(os.getenv('MAX_PAGES_PER_DOCUMENT', '10'))
        self.processing_timeout = int(os.getenv('PROCESSING_TIMEOUT', '300'))
        self.retry_attempts = int(os.getenv('RETRY_ATTEMPTS', '3'))
        
        # Logging configuration
        self.log_level = os.getenv('LOG_LEVEL', 'INFO')
        
    def _get_secret_or_env(self, secret_name, env_name):
        """Get value from Key Vault secret or environment variable"""
        try:
            if self.secret_client:
                secret = self.secret_client.get_secret(secret_name)
                return secret.value
        except Exception:
            pass
        
        return os.getenv(env_name)

# Application settings
config = Config()
```

### 7. Logic Apps Workflow Configuration

```json
{
  "definition": {
    "$schema": "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
      "$connections": {
        "defaultValue": {},
        "type": "Object"
      },
      "StorageAccountName": {
        "defaultValue": "stdocinteldev001",
        "type": "String"
      },
      "FunctionAppUrl": {
        "defaultValue": "https://func-docintel-dev-001.azurewebsites.net",
        "type": "String"
      }
    },
    "triggers": {
      "When_a_blob_is_added_or_modified_(properties_only)": {
        "recurrence": {
          "frequency": "Second",
          "interval": 30
        },
        "evaluatedRecurrence": {
          "frequency": "Second",
          "interval": 30
        },
        "splitOn": "@triggerBody()",
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
            "checkBothCreatedAndModifiedDateTime": false,
            "folderId": "L2lucHV0LWRvY3VtZW50cw==",
            "maxFileCount": 10
          }
        }
      }
    },
    "actions": {
      "Condition_-_Check_File_Type": {
        "actions": {
          "HTTP_-_Process_Document": {
            "runAfter": {},
            "type": "Http",
            "inputs": {
              "body": {
                "blobName": "@triggerBody()?['Name']",
                "blobUri": "@triggerBody()?['Path']",
                "containerName": "input-documents"
              },
              "headers": {
                "Content-Type": "application/json"
              },
              "method": "POST",
              "uri": "@{parameters('FunctionAppUrl')}/api/ProcessDocument"
            }
          },
          "Condition_-_Processing_Success": {
            "actions": {
              "Copy_blob_to_processed": {
                "runAfter": {},
                "type": "ApiConnection",
                "inputs": {
                  "host": {
                    "connection": {
                      "name": "@parameters('$connections')['azureblob']['connectionId']"
                    }
                  },
                  "method": "post",
                  "path": "/datasets/default/copyFile",
                  "queries": {
                    "destination": "/processed-documents/@{triggerBody()?['Name']}",
                    "overwrite": true,
                    "source": "@triggerBody()?['Path']"
                  }
                }
              },
              "Delete_original_blob": {
                "runAfter": {
                  "Copy_blob_to_processed": [
                    "Succeeded"
                  ]
                },
                "type": "ApiConnection",
                "inputs": {
                  "host": {
                    "connection": {
                      "name": "@parameters('$connections')['azureblob']['connectionId']"
                    }
                  },
                  "method": "delete",
                  "path": "/datasets/default/files/@{encodeURIComponent(encodeURIComponent(triggerBody()?['Id']))}"
                }
              },
              "Send_success_notification": {
                "runAfter": {
                  "Delete_original_blob": [
                    "Succeeded"
                  ]
                },
                "type": "Http",
                "inputs": {
                  "body": {
                    "message": "Document processed successfully: @{triggerBody()?['Name']}",
                    "status": "success",
                    "timestamp": "@utcnow()"
                  },
                  "headers": {
                    "Content-Type": "application/json"
                  },
                  "method": "POST",
                  "uri": "@parameters('NotificationWebhookUrl')"
                }
              }
            },
            "runAfter": {
              "HTTP_-_Process_Document": [
                "Succeeded"
              ]
            },
            "else": {
              "actions": {
                "Copy_blob_to_failed": {
                  "runAfter": {},
                  "type": "ApiConnection",
                  "inputs": {
                    "host": {
                      "connection": {
                        "name": "@parameters('$connections')['azureblob']['connectionId']"
                      }
                    },
                    "method": "post",
                    "path": "/datasets/default/copyFile",
                    "queries": {
                      "destination": "/failed-documents/@{triggerBody()?['Name']}",
                      "overwrite": true,
                      "source": "@triggerBody()?['Path']"
                    }
                  }
                },
                "Send_failure_notification": {
                  "runAfter": {
                    "Copy_blob_to_failed": [
                      "Succeeded"
                    ]
                  },
                  "type": "Http",
                  "inputs": {
                    "body": {
                      "error": "@body('HTTP_-_Process_Document')?['error']",
                      "message": "Document processing failed: @{triggerBody()?['Name']}",
                      "status": "failed",
                      "timestamp": "@utcnow()"
                    },
                    "headers": {
                      "Content-Type": "application/json"
                    },
                    "method": "POST",
                    "uri": "@parameters('NotificationWebhookUrl')"
                  }
                }
              }
            },
            "expression": {
              "and": [
                {
                  "equals": [
                    "@outputs('HTTP_-_Process_Document')['statusCode']",
                    200
                  ]
                }
              ]
            },
            "type": "If"
          }
        },
        "runAfter": {},
        "else": {
          "actions": {
            "Terminate_-_Unsupported_File_Type": {
              "runAfter": {},
              "type": "Terminate",
              "inputs": {
                "runError": {
                  "code": "UnsupportedFileType",
                  "message": "File type not supported for processing"
                },
                "runStatus": "Failed"
              }
            }
          }
        },
        "expression": {
          "or": [
            {
              "endsWith": [
                "@triggerBody()?['Name']",
                ".pdf"
              ]
            },
            {
              "endsWith": [
                "@triggerBody()?['Name']",
                ".jpg"
              ]
            },
            {
              "endsWith": [
                "@triggerBody()?['Name']",
                ".jpeg"
              ]
            },
            {
              "endsWith": [
                "@triggerBody()?['Name']",
                ".png"
              ]
            },
            {
              "endsWith": [
                "@triggerBody()?['Name']",
                ".tiff"
              ]
            }
          ]
        },
        "type": "If"
      }
    },
    "outputs": {}
  },
  "parameters": {
    "$connections": {
      "value": {
        "azureblob": {
          "connectionId": "/subscriptions/{subscription-id}/resourceGroups/{resource-group}/providers/Microsoft.Web/connections/azureblob",
          "connectionName": "azureblob",
          "id": "/subscriptions/{subscription-id}/providers/Microsoft.Web/locations/eastus2/managedApis/azureblob"
        }
      }
    }
  }
}
```

### 8. API Management Policy Configuration

```xml
<!-- API Management Policy for Document Processing API -->
<policies>
    <inbound>
        <base />
        <!-- Rate limiting -->
        <rate-limit-by-key calls="100" renewal-period="60" counter-key="@(context.Request.IpAddress)" />
        
        <!-- Authentication -->
        <validate-jwt header-name="Authorization" failed-validation-httpcode="401" failed-validation-error-message="Unauthorized">
            <openid-config url="https://login.microsoftonline.com/{tenant-id}/v2.0/.well-known/openid-configuration" />
            <required-claims>
                <claim name="aud" match="any">
                    <value>api://document-intelligence</value>
                </claim>
            </required-claims>
        </validate-jwt>
        
        <!-- Request validation -->
        <validate-content unspecified-content-type-action="prevent" max-size="52428800" size-exceeded-action="prevent">
            <content type="application/json" validate-as="json" action="prevent" />
        </validate-content>
        
        <!-- CORS -->
        <cors allow-credentials="false">
            <allowed-origins>
                <origin>https://*.yourdomain.com</origin>
            </allowed-origins>
            <allowed-methods preflight-result-max-age="300">
                <method>GET</method>
                <method>POST</method>
                <method>OPTIONS</method>
            </allowed-methods>
            <allowed-headers>
                <header>*</header>
            </allowed-headers>
        </cors>
        
        <!-- Request logging -->
        <log-to-eventhub logger-id="eh-logger" partition-id="0">
            @{
                return new JObject(
                    new JProperty("timestamp", DateTime.UtcNow.ToString()),
                    new JProperty("requestId", context.RequestId),
                    new JProperty("method", context.Request.Method),
                    new JProperty("url", context.Request.Url.ToString()),
                    new JProperty("clientIP", context.Request.IpAddress),
                    new JProperty("userAgent", context.Request.Headers.GetValueOrDefault("User-Agent", ""))
                ).ToString();
            }
        </log-to-eventhub>
    </inbound>
    
    <backend>
        <base />
        <!-- Retry policy for transient failures -->
        <retry condition="@(context.Response.StatusCode >= 500)" count="3" interval="2" max-interval="10" delta="1">
            <forward-request />
        </retry>
    </backend>
    
    <outbound>
        <base />
        <!-- Security headers -->
        <set-header name="X-Content-Type-Options" exists-action="override">
            <value>nosniff</value>
        </set-header>
        <set-header name="X-Frame-Options" exists-action="override">
            <value>DENY</value>
        </set-header>
        <set-header name="X-XSS-Protection" exists-action="override">
            <value>1; mode=block</value>
        </set-header>
        
        <!-- Response caching -->
        <cache-store duration="300" />
        
        <!-- Response logging -->
        <log-to-eventhub logger-id="eh-logger" partition-id="1">
            @{
                return new JObject(
                    new JProperty("timestamp", DateTime.UtcNow.ToString()),
                    new JProperty("requestId", context.RequestId),
                    new JProperty("statusCode", context.Response.StatusCode),
                    new JProperty("responseTime", (DateTime.UtcNow - context.Timestamp).TotalMilliseconds)
                ).ToString();
            }
        </log-to-eventhub>
    </outbound>
    
    <on-error>
        <base />
        <!-- Error logging -->
        <log-to-eventhub logger-id="eh-logger" partition-id="2">
            @{
                return new JObject(
                    new JProperty("timestamp", DateTime.UtcNow.ToString()),
                    new JProperty("requestId", context.RequestId),
                    new JProperty("error", context.LastError.Message),
                    new JProperty("source", context.LastError.Source)
                ).ToString();
            }
        </log-to-eventhub>
    </on-error>
</policies>
```

### 9. Environment-Specific Configuration Files

**Development Environment (dev.json):**
```json
{
  "environment": "dev",
  "region": "East US 2",
  "resourcePrefix": "docintel-dev",
  "services": {
    "formRecognizer": {
      "sku": "F0",
      "customDomain": false
    },
    "computerVision": {
      "sku": "F0"
    },
    "storage": {
      "redundancy": "LRS",
      "accessTier": "Hot",
      "enableVersioning": false
    },
    "functionApp": {
      "sku": "Y1",
      "alwaysOn": false
    }
  },
  "monitoring": {
    "logRetentionDays": 7,
    "enableDetailedMetrics": false
  },
  "security": {
    "enablePrivateEndpoints": false,
    "requireHttps": true,
    "enableSoftDelete": false
  }
}
```

**Production Environment (prod.json):**
```json
{
  "environment": "prod",
  "region": "East US 2",
  "resourcePrefix": "docintel-prod",
  "services": {
    "formRecognizer": {
      "sku": "S0",
      "customDomain": true
    },
    "computerVision": {
      "sku": "S1"
    },
    "storage": {
      "redundancy": "GRS",
      "accessTier": "Hot",
      "enableVersioning": true
    },
    "functionApp": {
      "sku": "P1v3",
      "alwaysOn": true
    }
  },
  "monitoring": {
    "logRetentionDays": 90,
    "enableDetailedMetrics": true
  },
  "security": {
    "enablePrivateEndpoints": true,
    "requireHttps": true,
    "enableSoftDelete": true
  },
  "scaling": {
    "functionAppMaxInstances": 200,
    "enableAutoScale": true
  }
}
```

These configuration templates provide a comprehensive foundation for deploying the Azure AI Document Intelligence solution across different environments and use cases. Customize the templates based on your specific requirements, security policies, and operational procedures.