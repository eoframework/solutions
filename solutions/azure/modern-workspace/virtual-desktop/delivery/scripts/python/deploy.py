#!/usr/bin/env python3
"""
Azure Virtual Desktop Deployment Script

This script provides automated deployment and management of Azure Virtual Desktop
infrastructure using the Azure SDK for Python.
"""

import os
import sys
import json
import logging
import argparse
from datetime import datetime, timedelta
from typing import Dict, List, Optional

# Azure SDK imports
try:
    from azure.identity import DefaultAzureCredential, AzureCliCredential
    from azure.mgmt.resource import ResourceManagementClient
    from azure.mgmt.network import NetworkManagementClient
    from azure.mgmt.storage import StorageManagementClient
    from azure.mgmt.compute import ComputeManagementClient
    from azure.mgmt.desktopvirtualization import DesktopVirtualizationMgmtClient
    from azure.mgmt.loganalytics import LogAnalyticsManagementClient
    from azure.core.exceptions import AzureError
except ImportError as e:
    print(f"Error importing Azure SDK: {e}")
    print("Please install required packages: pip install -r requirements.txt")
    sys.exit(1)

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('avd_deployment.log'),
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger(__name__)

class AVDDeployment:
    """Azure Virtual Desktop deployment manager."""
    
    def __init__(self, subscription_id: str, config: Dict):
        """Initialize deployment manager with Azure credentials and configuration."""
        self.subscription_id = subscription_id
        self.config = config
        
        # Initialize Azure clients
        try:
            self.credential = DefaultAzureCredential()
            # Test credential by attempting to get a token
            self.credential.get_token("https://management.azure.com/.default")
        except Exception:
            # Fallback to Azure CLI credential
            self.credential = AzureCliCredential()
        
        self._init_clients()
    
    def _init_clients(self):
        """Initialize Azure management clients."""
        try:
            self.resource_client = ResourceManagementClient(self.credential, self.subscription_id)
            self.network_client = NetworkManagementClient(self.credential, self.subscription_id)
            self.storage_client = StorageManagementClient(self.credential, self.subscription_id)
            self.compute_client = ComputeManagementClient(self.credential, self.subscription_id)
            self.avd_client = DesktopVirtualizationMgmtClient(self.credential, self.subscription_id)
            self.analytics_client = LogAnalyticsManagementClient(self.credential, self.subscription_id)
            logger.info("Azure clients initialized successfully")
        except Exception as e:
            logger.error(f"Failed to initialize Azure clients: {e}")
            raise
    
    def create_resource_group(self) -> None:
        """Create Azure resource group for AVD resources."""
        rg_name = self.config['resource_group_name']
        location = self.config['location']
        
        logger.info(f"Creating resource group: {rg_name} in {location}")
        
        try:
            rg_params = {
                'location': location,
                'tags': self.config.get('tags', {})
            }
            
            result = self.resource_client.resource_groups.create_or_update(
                rg_name, rg_params
            )
            logger.info(f"Resource group created: {result.name}")
        except AzureError as e:
            logger.error(f"Failed to create resource group: {e}")
            raise
    
    def create_virtual_network(self) -> str:
        """Create virtual network and subnet for AVD."""
        rg_name = self.config['resource_group_name']
        vnet_name = self.config['vnet_name']
        subnet_name = self.config['subnet_name']
        location = self.config['location']
        
        logger.info(f"Creating virtual network: {vnet_name}")
        
        try:
            # Define virtual network parameters
            vnet_params = {
                'location': location,
                'address_space': {
                    'address_prefixes': ['10.0.0.0/16']
                },
                'subnets': [{
                    'name': subnet_name,
                    'address_prefix': '10.0.1.0/24'
                }],
                'tags': self.config.get('tags', {})
            }
            
            # Create virtual network
            async_vnet_creation = self.network_client.virtual_networks.begin_create_or_update(
                rg_name, vnet_name, vnet_params
            )
            vnet = async_vnet_creation.result()
            
            # Create Network Security Group
            self._create_network_security_group()
            
            logger.info(f"Virtual network created: {vnet.name}")
            return vnet.subnets[0].id
        except AzureError as e:
            logger.error(f"Failed to create virtual network: {e}")
            raise
    
    def _create_network_security_group(self) -> None:
        """Create Network Security Group with AVD-specific rules."""
        rg_name = self.config['resource_group_name']
        nsg_name = f"nsg-{self.config['prefix']}-hosts"
        location = self.config['location']
        
        logger.info(f"Creating Network Security Group: {nsg_name}")
        
        try:
            nsg_params = {
                'location': location,
                'security_rules': [{
                    'name': 'Allow-AVD-Traffic',
                    'protocol': 'Tcp',
                    'access': 'Allow',
                    'direction': 'Outbound',
                    'source_address_prefix': 'VirtualNetwork',
                    'source_port_range': '*',
                    'destination_address_prefix': 'WindowsVirtualDesktop',
                    'destination_port_range': '443',
                    'priority': 100
                }, {
                    'name': 'Allow-Azure-KMS',
                    'protocol': 'Tcp',
                    'access': 'Allow',
                    'direction': 'Outbound',
                    'source_address_prefix': '*',
                    'source_port_range': '*',
                    'destination_address_prefix': '23.102.135.246',
                    'destination_port_range': '1688',
                    'priority': 110
                }],
                'tags': self.config.get('tags', {})
            }
            
            async_nsg_creation = self.network_client.network_security_groups.begin_create_or_update(
                rg_name, nsg_name, nsg_params
            )
            nsg = async_nsg_creation.result()
            logger.info(f"Network Security Group created: {nsg.name}")
        except AzureError as e:
            logger.error(f"Failed to create NSG: {e}")
            raise
    
    def create_storage_account(self) -> str:
        """Create storage account for FSLogix profiles."""
        rg_name = self.config['resource_group_name']
        storage_name = self.config['storage_account_name']
        location = self.config['location']
        
        logger.info(f"Creating storage account: {storage_name}")
        
        try:
            storage_params = {
                'location': location,
                'sku': {'name': 'Premium_LRS'},
                'kind': 'FileStorage',
                'tags': self.config.get('tags', {}),
                'network_rule_set': {
                    'default_action': 'Deny',
                    'bypass': 'AzureServices'
                }
            }
            
            async_storage_creation = self.storage_client.storage_accounts.begin_create(
                rg_name, storage_name, storage_params
            )
            storage_account = async_storage_creation.result()
            
            # Create file share for profiles
            self._create_file_share(storage_name)
            
            logger.info(f"Storage account created: {storage_account.name}")
            return storage_account.name
        except AzureError as e:
            logger.error(f"Failed to create storage account: {e}")
            raise
    
    def _create_file_share(self, storage_account_name: str) -> None:
        """Create file share for FSLogix profiles."""
        rg_name = self.config['resource_group_name']
        share_name = 'profiles'
        
        logger.info(f"Creating file share: {share_name}")
        
        try:
            share_params = {
                'quota': self.config.get('profiles_share_quota', 1024)
            }
            
            self.storage_client.file_shares.create(
                rg_name, storage_account_name, share_name, share_params
            )
            logger.info(f"File share created: {share_name}")
        except AzureError as e:
            logger.error(f"Failed to create file share: {e}")
            raise
    
    def create_host_pool(self) -> str:
        """Create AVD host pool."""
        rg_name = self.config['resource_group_name']
        host_pool_name = self.config['host_pool_name']
        location = self.config['location']
        
        logger.info(f"Creating host pool: {host_pool_name}")
        
        try:
            host_pool_params = {
                'location': location,
                'host_pool_type': 'Pooled',
                'load_balancer_type': 'BreadthFirst',
                'max_session_limit': self.config.get('max_sessions_per_host', 10),
                'preferred_app_group_type': 'Desktop',
                'tags': self.config.get('tags', {})
            }
            
            host_pool = self.avd_client.host_pools.create_or_update(
                rg_name, host_pool_name, host_pool_params
            )
            
            # Generate registration token
            self._generate_registration_token(host_pool_name)
            
            logger.info(f"Host pool created: {host_pool.name}")
            return host_pool.name
        except AzureError as e:
            logger.error(f"Failed to create host pool: {e}")
            raise
    
    def _generate_registration_token(self, host_pool_name: str) -> str:
        """Generate registration token for host pool."""
        rg_name = self.config['resource_group_name']
        
        try:
            expiration_time = datetime.utcnow() + timedelta(hours=4)
            
            token_params = {
                'expiration_time': expiration_time.isoformat() + 'Z'
            }
            
            result = self.avd_client.host_pools.retrieve_registration_token(
                rg_name, host_pool_name, token_params
            )
            
            token = result.token
            logger.info("Registration token generated successfully")
            return token
        except AzureError as e:
            logger.error(f"Failed to generate registration token: {e}")
            raise
    
    def create_workspace_and_app_group(self, host_pool_name: str) -> tuple:
        """Create AVD workspace and application group."""
        rg_name = self.config['resource_group_name']
        workspace_name = self.config['workspace_name']
        app_group_name = f"{self.config['prefix']}-desktop-appgroup"
        location = self.config['location']
        
        logger.info(f"Creating workspace: {workspace_name}")
        logger.info(f"Creating application group: {app_group_name}")
        
        try:
            # Create workspace
            workspace_params = {
                'location': location,
                'tags': self.config.get('tags', {})
            }
            
            workspace = self.avd_client.workspaces.create_or_update(
                rg_name, workspace_name, workspace_params
            )
            
            # Create application group
            app_group_params = {
                'location': location,
                'application_group_type': 'Desktop',
                'host_pool_arm_path': f"/subscriptions/{self.subscription_id}/resourceGroups/{rg_name}/providers/Microsoft.DesktopVirtualization/hostPools/{host_pool_name}",
                'tags': self.config.get('tags', {})
            }
            
            app_group = self.avd_client.application_groups.create_or_update(
                rg_name, app_group_name, app_group_params
            )
            
            # Associate application group with workspace
            self._associate_app_group_to_workspace(workspace_name, app_group.name)
            
            logger.info("Workspace and application group created successfully")
            return workspace.name, app_group.name
        except AzureError as e:
            logger.error(f"Failed to create workspace/app group: {e}")
            raise
    
    def _associate_app_group_to_workspace(self, workspace_name: str, app_group_name: str) -> None:
        """Associate application group with workspace."""
        rg_name = self.config['resource_group_name']
        
        try:
            # Get current workspace
            workspace = self.avd_client.workspaces.get(rg_name, workspace_name)
            
            # Add application group reference
            app_group_ref = f"/subscriptions/{self.subscription_id}/resourceGroups/{rg_name}/providers/Microsoft.DesktopVirtualization/applicationGroups/{app_group_name}"
            
            if not workspace.application_group_references:
                workspace.application_group_references = []
            
            if app_group_ref not in workspace.application_group_references:
                workspace.application_group_references.append(app_group_ref)
            
            # Update workspace
            self.avd_client.workspaces.create_or_update(rg_name, workspace_name, workspace)
            logger.info("Application group associated with workspace")
        except AzureError as e:
            logger.error(f"Failed to associate app group to workspace: {e}")
            raise
    
    def create_session_hosts(self, subnet_id: str) -> List[str]:
        """Create session host virtual machines."""
        rg_name = self.config['resource_group_name']
        location = self.config['location']
        count = self.config['session_host_count']
        
        logger.info(f"Creating {count} session host VMs")
        
        session_host_names = []
        
        try:
            for i in range(1, count + 1):
                vm_name = f"vm-{self.config['prefix']}-sh-{i:02d}"
                nic_name = f"nic-{self.config['prefix']}-sh-{i:02d}"
                
                # Create network interface
                nic_params = {
                    'location': location,
                    'ip_configurations': [{
                        'name': 'ipconfig1',
                        'subnet': {'id': subnet_id},
                        'private_ip_allocation_method': 'Dynamic'
                    }],
                    'tags': self.config.get('tags', {})
                }
                
                async_nic_creation = self.network_client.network_interfaces.begin_create_or_update(
                    rg_name, nic_name, nic_params
                )
                nic = async_nic_creation.result()
                
                # Create virtual machine
                vm_params = {
                    'location': location,
                    'os_profile': {
                        'computer_name': vm_name,
                        'admin_username': self.config['admin_username'],
                        'admin_password': self.config['admin_password']
                    },
                    'hardware_profile': {
                        'vm_size': self.config.get('session_host_vm_size', 'Standard_D4s_v4')
                    },
                    'storage_profile': {
                        'image_reference': {
                            'publisher': 'MicrosoftWindowsDesktop',
                            'offer': 'Windows-11',
                            'sku': 'win11-21h2-ent',
                            'version': 'latest'
                        },
                        'os_disk': {
                            'name': f"{vm_name}-osdisk",
                            'caching': 'ReadWrite',
                            'create_option': 'FromImage',
                            'managed_disk': {'storage_account_type': 'Premium_LRS'}
                        }
                    },
                    'network_profile': {
                        'network_interfaces': [{'id': nic.id}]
                    },
                    'tags': self.config.get('tags', {})
                }
                
                async_vm_creation = self.compute_client.virtual_machines.begin_create_or_update(
                    rg_name, vm_name, vm_params
                )
                vm = async_vm_creation.result()
                
                session_host_names.append(vm_name)
                logger.info(f"Session host created: {vm_name}")
            
            return session_host_names
        except AzureError as e:
            logger.error(f"Failed to create session hosts: {e}")
            raise
    
    def create_log_analytics_workspace(self) -> str:
        """Create Log Analytics workspace for monitoring."""
        rg_name = self.config['resource_group_name']
        workspace_name = self.config['log_analytics_workspace_name']
        location = self.config['location']
        
        logger.info(f"Creating Log Analytics workspace: {workspace_name}")
        
        try:
            workspace_params = {
                'location': location,
                'sku': {'name': 'PerGB2018'},
                'retention_in_days': 30,
                'tags': self.config.get('tags', {})
            }
            
            async_workspace_creation = self.analytics_client.workspaces.begin_create_or_update(
                rg_name, workspace_name, workspace_params
            )
            workspace = async_workspace_creation.result()
            
            logger.info(f"Log Analytics workspace created: {workspace.name}")
            return workspace.name
        except AzureError as e:
            logger.error(f"Failed to create Log Analytics workspace: {e}")
            raise
    
    def deploy(self) -> Dict:
        """Execute complete AVD deployment."""
        logger.info("Starting Azure Virtual Desktop deployment")
        
        try:
            # Create foundational resources
            self.create_resource_group()
            subnet_id = self.create_virtual_network()
            storage_account = self.create_storage_account()
            
            # Create AVD resources
            host_pool_name = self.create_host_pool()
            workspace_name, app_group_name = self.create_workspace_and_app_group(host_pool_name)
            
            # Create session hosts
            session_hosts = self.create_session_hosts(subnet_id)
            
            # Enable monitoring
            analytics_workspace = self.create_log_analytics_workspace()
            
            # Deployment summary
            summary = {
                'status': 'SUCCESS',
                'resource_group': self.config['resource_group_name'],
                'location': self.config['location'],
                'host_pool': host_pool_name,
                'workspace': workspace_name,
                'session_hosts': len(session_hosts),
                'storage_account': storage_account,
                'web_client_url': 'https://rdweb.wvd.microsoft.com/arm/webclient'
            }
            
            logger.info("Azure Virtual Desktop deployment completed successfully!")
            return summary
        
        except Exception as e:
            logger.error(f"Deployment failed: {e}")
            return {
                'status': 'FAILED',
                'error': str(e)
            }

def load_config(config_file: str) -> Dict:
    """Load configuration from JSON file."""
    try:
        with open(config_file, 'r') as f:
            config = json.load(f)
        logger.info(f"Configuration loaded from {config_file}")
        return config
    except FileNotFoundError:
        logger.error(f"Configuration file not found: {config_file}")
        raise
    except json.JSONDecodeError as e:
        logger.error(f"Invalid JSON in configuration file: {e}")
        raise

def main():
    """Main deployment function."""
    parser = argparse.ArgumentParser(description='Deploy Azure Virtual Desktop infrastructure')
    parser.add_argument('--config', required=True, help='Configuration file path')
    parser.add_argument('--subscription-id', required=True, help='Azure subscription ID')
    parser.add_argument('--dry-run', action='store_true', help='Validate configuration without deploying')
    
    args = parser.parse_args()
    
    try:
        # Load configuration
        config = load_config(args.config)
        
        if args.dry_run:
            logger.info("Dry run mode - validating configuration")
            logger.info(f"Configuration: {json.dumps(config, indent=2)}")
            return
        
        # Initialize and run deployment
        deployment = AVDDeployment(args.subscription_id, config)
        result = deployment.deploy()
        
        # Output results
        print("\nDeployment Summary:")
        print(json.dumps(result, indent=2))
        
        if result['status'] == 'SUCCESS':
            sys.exit(0)
        else:
            sys.exit(1)
    
    except Exception as e:
        logger.error(f"Deployment error: {e}")
        sys.exit(1)

if __name__ == '__main__':
    main()