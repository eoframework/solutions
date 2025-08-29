#!/usr/bin/env python3
"""
Azure Sentinel SIEM - Python Deployment Script
Automated deployment and configuration of Azure Sentinel SIEM solution
"""

import os
import sys
import json
import time
import logging
import argparse
from typing import Dict, List, Optional
from dataclasses import dataclass, asdict
from azure.identity import DefaultAzureCredential, ClientSecretCredential
from azure.mgmt.resource import ResourceManagementClient
from azure.mgmt.loganalytics import LogAnalyticsManagementClient
from azure.mgmt.securityinsight import SecurityInsights
from azure.mgmt.monitor import MonitorManagementClient
from azure.core.exceptions import ResourceExistsError, ResourceNotFoundError

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('sentinel_deployment.log'),
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger(__name__)

@dataclass
class SentinelConfig:
    """Configuration for Azure Sentinel deployment"""
    subscription_id: str
    resource_group_name: str
    location: str
    workspace_name: str
    retention_days: int = 730
    daily_quota_gb: int = 500
    enable_data_connectors: bool = True
    create_sample_rules: bool = False
    tags: Dict[str, str] = None

    def __post_init__(self):
        if self.tags is None:
            self.tags = {
                "Environment": "Production",
                "Solution": "Azure Sentinel SIEM",
                "CostCenter": "Security Operations"
            }

class SentinelDeployment:
    """Azure Sentinel deployment automation"""
    
    def __init__(self, config: SentinelConfig, credential=None):
        self.config = config
        self.credential = credential or DefaultAzureCredential()
        
        # Initialize Azure clients
        self.resource_client = ResourceManagementClient(
            self.credential, config.subscription_id
        )
        self.loganalytics_client = LogAnalyticsManagementClient(
            self.credential, config.subscription_id
        )
        self.security_client = SecurityInsights(
            self.credential, config.subscription_id
        )
        self.monitor_client = MonitorManagementClient(
            self.credential, config.subscription_id
        )

    def deploy(self) -> Dict[str, str]:
        """Execute complete Sentinel deployment"""
        logger.info("Starting Azure Sentinel deployment...")
        
        try:
            # Step 1: Create or verify resource group
            rg_result = self._create_resource_group()
            logger.info(f"Resource group: {rg_result['name']}")
            
            # Step 2: Create Log Analytics workspace
            workspace_result = self._create_workspace()
            logger.info(f"Workspace: {workspace_result['name']}")
            
            # Step 3: Enable Sentinel on workspace
            sentinel_result = self._enable_sentinel()
            logger.info("Azure Sentinel enabled")
            
            # Step 4: Configure data connectors
            if self.config.enable_data_connectors:
                connectors_result = self._configure_data_connectors()
                logger.info(f"Data connectors configured: {len(connectors_result)}")
            
            # Step 5: Create analytics rules
            if self.config.create_sample_rules:
                rules_result = self._create_analytics_rules()
                logger.info(f"Analytics rules created: {len(rules_result)}")
            
            # Step 6: Configure monitoring
            monitoring_result = self._configure_monitoring()
            logger.info("Monitoring configured")
            
            deployment_result = {
                "status": "success",
                "resource_group": rg_result['name'],
                "workspace_name": workspace_result['name'],
                "workspace_id": workspace_result['customer_id'],
                "sentinel_enabled": True
            }
            
            logger.info("Azure Sentinel deployment completed successfully!")
            return deployment_result
            
        except Exception as e:
            logger.error(f"Deployment failed: {str(e)}")
            raise

    def _create_resource_group(self) -> Dict[str, str]:
        """Create or verify resource group exists"""
        logger.info(f"Creating resource group: {self.config.resource_group_name}")
        
        try:
            rg_params = {
                'location': self.config.location,
                'tags': self.config.tags
            }
            
            result = self.resource_client.resource_groups.create_or_update(
                self.config.resource_group_name, rg_params
            )
            
            return {
                'name': result.name,
                'location': result.location,
                'id': result.id
            }
            
        except Exception as e:
            logger.error(f"Failed to create resource group: {str(e)}")
            raise

    def _create_workspace(self) -> Dict[str, str]:
        """Create Log Analytics workspace"""
        logger.info(f"Creating Log Analytics workspace: {self.config.workspace_name}")
        
        try:
            workspace_params = {
                'location': self.config.location,
                'tags': self.config.tags,
                'sku': {'name': 'PerGB2018'},
                'retention_in_days': self.config.retention_days,
                'workspace_capping': {
                    'daily_quota_gb': self.config.daily_quota_gb
                },
                'features': {
                    'enable_log_access_using_only_resource_permissions': False,
                    'enable_data_export': True
                }
            }
            
            # Create workspace
            operation = self.loganalytics_client.workspaces.begin_create_or_update(
                self.config.resource_group_name,
                self.config.workspace_name,
                workspace_params
            )
            
            result = operation.result()
            
            return {
                'name': result.name,
                'location': result.location,
                'customer_id': result.customer_id,
                'id': result.id
            }
            
        except Exception as e:
            logger.error(f"Failed to create workspace: {str(e)}")
            raise

    def _enable_sentinel(self) -> bool:
        """Enable Azure Sentinel on the workspace"""
        logger.info("Enabling Azure Sentinel...")
        
        try:
            # Construct workspace resource ID
            workspace_id = (
                f"/subscriptions/{self.config.subscription_id}"
                f"/resourceGroups/{self.config.resource_group_name}"
                f"/providers/Microsoft.OperationalInsights/workspaces/{self.config.workspace_name}"
            )
            
            # Enable Sentinel workspace onboarding
            sentinel_params = {
                'workspace_id': workspace_id,
                'customer_managed_key_enabled': False
            }
            
            self.security_client.workspace_manager_assignments.create_or_update(
                self.config.resource_group_name,
                self.config.workspace_name,
                sentinel_params
            )
            
            return True
            
        except Exception as e:
            logger.error(f"Failed to enable Sentinel: {str(e)}")
            raise

    def _configure_data_connectors(self) -> List[str]:
        """Configure data connectors"""
        logger.info("Configuring data connectors...")
        
        configured_connectors = []
        
        # Azure Active Directory connector
        try:
            aad_connector_params = {
                'data_types': {
                    'sign_in_logs': {'state': 'Enabled'},
                    'audit_logs': {'state': 'Enabled'}
                },
                'tenant_id': os.getenv('AZURE_TENANT_ID')
            }
            
            self.security_client.data_connectors.create_or_update(
                self.config.resource_group_name,
                self.config.workspace_name,
                'azure-active-directory',
                {
                    'kind': 'AzureActiveDirectory',
                    'properties': aad_connector_params
                }
            )
            
            configured_connectors.append('AzureActiveDirectory')
            logger.info("Azure AD connector configured")
            
        except Exception as e:
            logger.warning(f"Failed to configure Azure AD connector: {str(e)}")

        # Azure Security Center connector
        try:
            asc_connector_params = {
                'subscription_id': self.config.subscription_id,
                'data_types': {
                    'alerts': {'state': 'Enabled'}
                }
            }
            
            self.security_client.data_connectors.create_or_update(
                self.config.resource_group_name,
                self.config.workspace_name,
                'azure-security-center',
                {
                    'kind': 'AzureSecurityCenter',
                    'properties': asc_connector_params
                }
            )
            
            configured_connectors.append('AzureSecurityCenter')
            logger.info("Azure Security Center connector configured")
            
        except Exception as e:
            logger.warning(f"Failed to configure ASC connector: {str(e)}")

        return configured_connectors

    def _create_analytics_rules(self) -> List[str]:
        """Create sample analytics rules"""
        logger.info("Creating analytics rules...")
        
        created_rules = []
        
        # Brute force detection rule
        brute_force_rule = {
            'kind': 'Scheduled',
            'properties': {
                'display_name': 'Brute Force Attack Detection',
                'description': 'Detects multiple failed login attempts from single source',
                'severity': 'Medium',
                'enabled': True,
                'query': '''
                    SigninLogs
                    | where TimeGenerated >= ago(1h)
                    | where ResultType !in ("0", "50125", "50140")
                    | summarize FailedAttempts = count(), Users = make_set(UserPrincipalName) by IPAddress
                    | where FailedAttempts >= 10
                    | project IPAddress, FailedAttempts, Users
                ''',
                'query_frequency': 'PT1H',
                'query_period': 'PT1H',
                'trigger_operator': 'GreaterThan',
                'trigger_threshold': 0,
                'tactics': ['CredentialAccess', 'InitialAccess'],
                'techniques': ['T1110', 'T1078']
            }
        }
        
        try:
            self.security_client.alert_rules.create_or_update(
                self.config.resource_group_name,
                self.config.workspace_name,
                'brute-force-detection',
                brute_force_rule
            )
            created_rules.append('BruteForceDetection')
            logger.info("Brute force detection rule created")
            
        except Exception as e:
            logger.warning(f"Failed to create brute force rule: {str(e)}")

        # Suspicious PowerShell rule
        powershell_rule = {
            'kind': 'Scheduled',
            'properties': {
                'display_name': 'Suspicious PowerShell Activity',
                'description': 'Detects potentially malicious PowerShell execution',
                'severity': 'High',
                'enabled': True,
                'query': '''
                    SecurityEvent
                    | where TimeGenerated >= ago(1h)
                    | where EventID == 4688
                    | where Process endswith "powershell.exe"
                    | where CommandLine contains "Download" or CommandLine contains "Invoke-" or CommandLine contains "IEX"
                    | project TimeGenerated, Computer, Account, CommandLine
                ''',
                'query_frequency': 'PT30M',
                'query_period': 'PT1H',
                'trigger_operator': 'GreaterThan',
                'trigger_threshold': 0,
                'tactics': ['Execution', 'CommandAndControl'],
                'techniques': ['T1059.001', 'T1071.001']
            }
        }
        
        try:
            self.security_client.alert_rules.create_or_update(
                self.config.resource_group_name,
                self.config.workspace_name,
                'suspicious-powershell',
                powershell_rule
            )
            created_rules.append('SuspiciousPowerShell')
            logger.info("Suspicious PowerShell rule created")
            
        except Exception as e:
            logger.warning(f"Failed to create PowerShell rule: {str(e)}")

        return created_rules

    def _configure_monitoring(self) -> bool:
        """Configure monitoring and alerting"""
        logger.info("Configuring monitoring...")
        
        try:
            # Create diagnostic settings for audit logging
            workspace_id = (
                f"/subscriptions/{self.config.subscription_id}"
                f"/resourceGroups/{self.config.resource_group_name}"
                f"/providers/Microsoft.OperationalInsights/workspaces/{self.config.workspace_name}"
            )
            
            diagnostic_settings = {
                'workspace_id': workspace_id,
                'logs': [
                    {
                        'category': 'Audit',
                        'enabled': True,
                        'retention_policy': {
                            'enabled': True,
                            'days': 90
                        }
                    }
                ]
            }
            
            self.monitor_client.diagnostic_settings.create_or_update(
                workspace_id,
                'sentinel-diagnostics',
                diagnostic_settings
            )
            
            logger.info("Diagnostic settings configured")
            return True
            
        except Exception as e:
            logger.warning(f"Failed to configure monitoring: {str(e)}")
            return False

    def validate_deployment(self) -> Dict[str, bool]:
        """Validate the deployment"""
        logger.info("Validating deployment...")
        
        validation_results = {
            'resource_group_exists': False,
            'workspace_exists': False,
            'sentinel_enabled': False,
            'data_connectors_configured': False
        }
        
        try:
            # Check resource group
            rg = self.resource_client.resource_groups.get(self.config.resource_group_name)
            validation_results['resource_group_exists'] = True
            
            # Check workspace
            workspace = self.loganalytics_client.workspaces.get(
                self.config.resource_group_name, self.config.workspace_name
            )
            validation_results['workspace_exists'] = True
            
            # Check Sentinel
            sentinel_workspaces = self.security_client.workspace_manager_assignments.list(
                self.config.resource_group_name, self.config.workspace_name
            )
            validation_results['sentinel_enabled'] = len(list(sentinel_workspaces)) > 0
            
            # Check data connectors
            connectors = self.security_client.data_connectors.list(
                self.config.resource_group_name, self.config.workspace_name
            )
            validation_results['data_connectors_configured'] = len(list(connectors)) > 0
            
        except Exception as e:
            logger.error(f"Validation failed: {str(e)}")
        
        return validation_results

def load_config(config_file: str) -> SentinelConfig:
    """Load configuration from JSON file"""
    try:
        with open(config_file, 'r') as f:
            config_data = json.load(f)
        return SentinelConfig(**config_data)
    except Exception as e:
        logger.error(f"Failed to load config: {str(e)}")
        raise

def main():
    """Main execution function"""
    parser = argparse.ArgumentParser(description='Deploy Azure Sentinel SIEM')
    parser.add_argument('--config', required=True, help='Configuration file path')
    parser.add_argument('--validate-only', action='store_true', help='Only validate existing deployment')
    parser.add_argument('--subscription-id', help='Azure subscription ID')
    parser.add_argument('--tenant-id', help='Azure tenant ID')
    parser.add_argument('--client-id', help='Service principal client ID')
    parser.add_argument('--client-secret', help='Service principal client secret')
    
    args = parser.parse_args()
    
    # Load configuration
    config = load_config(args.config)
    
    # Override subscription ID if provided
    if args.subscription_id:
        config.subscription_id = args.subscription_id
    
    # Setup authentication
    credential = None
    if args.client_id and args.client_secret and args.tenant_id:
        credential = ClientSecretCredential(
            tenant_id=args.tenant_id,
            client_id=args.client_id,
            client_secret=args.client_secret
        )
    
    # Initialize deployment
    deployment = SentinelDeployment(config, credential)
    
    if args.validate_only:
        # Validation only
        results = deployment.validate_deployment()
        logger.info(f"Validation results: {results}")
        
        if all(results.values()):
            logger.info("✅ All validations passed")
            sys.exit(0)
        else:
            logger.error("❌ Some validations failed")
            sys.exit(1)
    else:
        # Full deployment
        try:
            result = deployment.deploy()
            logger.info("Deployment completed successfully!")
            
            # Save deployment results
            with open('deployment_result.json', 'w') as f:
                json.dump(result, f, indent=2)
                
            # Run validation
            validation = deployment.validate_deployment()
            logger.info(f"Post-deployment validation: {validation}")
            
        except Exception as e:
            logger.error(f"Deployment failed: {str(e)}")
            sys.exit(1)

if __name__ == '__main__':
    main()