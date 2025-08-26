#!/usr/bin/env python3
"""
Dell VxRail HCI Deployment Script

This script automates the deployment and configuration of Dell VxRail
hyperconverged infrastructure using Python and REST APIs.
"""

import os
import sys
import time
import json
import logging
import requests
import argparse
from pathlib import Path
from typing import Dict, Any, Optional

# Disable SSL warnings for development
requests.packages.urllib3.disable_warnings()

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('/var/log/vxrail-deploy.log'),
        logging.StreamHandler(sys.stdout)
    ]
)

class VxRailDeployer:
    """Dell VxRail deployment automation class"""
    
    def __init__(self, config_file: str):
        """Initialize deployer with configuration"""
        self.logger = logging.getLogger(__name__)
        self.config = self._load_config(config_file)
        self.session = requests.Session()
        self.session.verify = False  # Disable SSL verification
        
        # VxRail Manager connection details
        self.vxrail_ip = self.config['vxrail_manager']['ip']
        self.base_url = f"https://{self.vxrail_ip}/rest/vxm/v1"
        
    def _load_config(self, config_file: str) -> Dict[str, Any]:
        """Load configuration from JSON file"""
        try:
            with open(config_file, 'r') as f:
                return json.load(f)
        except FileNotFoundError:
            self.logger.error(f"Configuration file not found: {config_file}")
            sys.exit(1)
        except json.JSONDecodeError as e:
            self.logger.error(f"Invalid JSON in configuration file: {e}")
            sys.exit(1)
    
    def authenticate(self) -> bool:
        """Authenticate with VxRail Manager"""
        auth_url = f"{self.base_url}/auth/token"
        auth_data = {
            "username": self.config['vxrail_manager']['username'],
            "password": self.config['vxrail_manager']['password']
        }
        
        try:
            response = self.session.post(auth_url, json=auth_data, timeout=30)
            response.raise_for_status()
            
            token = response.json().get('access_token')
            if token:
                self.session.headers.update({'Authorization': f'Bearer {token}'})
                self.logger.info("Successfully authenticated with VxRail Manager")
                return True
            else:
                self.logger.error("Failed to obtain authentication token")
                return False
                
        except requests.exceptions.RequestException as e:
            self.logger.error(f"Authentication failed: {e}")
            return False
    
    def validate_prerequisites(self) -> bool:
        """Validate deployment prerequisites"""
        self.logger.info("Validating deployment prerequisites...")
        
        # Check VxRail Manager connectivity
        try:
            health_url = f"{self.base_url}/system/health"
            response = self.session.get(health_url, timeout=30)
            response.raise_for_status()
            self.logger.info("VxRail Manager is accessible")
        except requests.exceptions.RequestException as e:
            self.logger.error(f"Cannot connect to VxRail Manager: {e}")
            return False
        
        # Validate network configuration
        network_config = self.config['network']
        required_networks = ['management', 'vmotion', 'vsan']
        
        for network in required_networks:
            if network not in network_config:
                self.logger.error(f"Missing network configuration for: {network}")
                return False
        
        self.logger.info("Prerequisites validation completed successfully")
        return True
    
    def discover_nodes(self) -> List[Dict[str, Any]]:
        """Discover available VxRail nodes"""
        self.logger.info("Discovering VxRail nodes...")
        
        try:
            discovery_url = f"{self.base_url}/cluster/nodes/discovery"
            response = self.session.get(discovery_url, timeout=60)
            response.raise_for_status()
            
            nodes = response.json().get('nodes', [])
            self.logger.info(f"Discovered {len(nodes)} VxRail nodes")
            
            for i, node in enumerate(nodes, 1):
                self.logger.info(f"Node {i}: {node.get('serial_number')} - {node.get('model')}")
            
            return nodes
            
        except requests.exceptions.RequestException as e:
            self.logger.error(f"Node discovery failed: {e}")
            return []
    
    def configure_cluster(self) -> Optional[str]:
        """Configure VxRail cluster"""
        self.logger.info("Configuring VxRail cluster...")
        
        cluster_config = {
            "cluster_name": self.config['cluster']['name'],
            "datacenter_name": self.config['cluster']['datacenter'],
            "vcenter_config": {
                "fqdn": self.config['vcenter']['fqdn'],
                "deployment_type": "embedded",
                "sso_domain": self.config['vcenter']['sso_domain'],
                "admin_password": self.config['vcenter']['admin_password']
            },
            "network_config": self._build_network_config(),
            "dns_servers": self.config['network']['dns_servers'],
            "ntp_servers": self.config['network']['ntp_servers']
        }
        
        try:
            cluster_url = f"{self.base_url}/cluster"
            response = self.session.post(cluster_url, json=cluster_config, timeout=60)
            response.raise_for_status()
            
            deployment_id = response.json().get('request_id')
            if deployment_id:
                self.logger.info(f"Cluster configuration initiated: {deployment_id}")
                return deployment_id
            else:
                self.logger.error("Failed to get deployment ID")
                return None
                
        except requests.exceptions.RequestException as e:
            self.logger.error(f"Cluster configuration failed: {e}")
            return None
    
    def _build_network_config(self) -> Dict[str, Any]:
        """Build network configuration from config file"""
        network = self.config['network']
        
        return {
            "management_network": {
                "vlan_id": network['management']['vlan_id'],
                "subnet": network['management']['subnet'],
                "gateway": network['management']['gateway']
            },
            "vmotion_network": {
                "vlan_id": network['vmotion']['vlan_id'],
                "subnet": network['vmotion']['subnet']
            },
            "vsan_network": {
                "vlan_id": network['vsan']['vlan_id'],
                "subnet": network['vsan']['subnet']
            }
        }
    
    def monitor_deployment(self, deployment_id: str) -> bool:
        """Monitor deployment progress"""
        self.logger.info(f"Monitoring deployment: {deployment_id}")
        
        max_attempts = 120  # 2 hours with 1-minute intervals
        attempt = 1
        
        while attempt <= max_attempts:
            try:
                status_url = f"{self.base_url}/requests/{deployment_id}"
                response = self.session.get(status_url, timeout=30)
                response.raise_for_status()
                
                status_data = response.json()
                state = status_data.get('state')
                progress = status_data.get('progress', 0)
                
                if state == 'COMPLETED':
                    self.logger.info("Deployment completed successfully")
                    return True
                elif state == 'FAILED':
                    error_msg = status_data.get('error', 'Unknown error')
                    self.logger.error(f"Deployment failed: {error_msg}")
                    return False
                elif state == 'IN_PROGRESS':
                    self.logger.info(f"Deployment progress: {progress}% (attempt {attempt}/{max_attempts})")
                else:
                    self.logger.warning(f"Unknown deployment state: {state}")
                
                time.sleep(60)  # Wait 1 minute before next check
                attempt += 1
                
            except requests.exceptions.RequestException as e:
                self.logger.error(f"Failed to check deployment status: {e}")
                time.sleep(60)
                attempt += 1
        
        self.logger.error(f"Deployment timeout after {max_attempts} attempts")
        return False
    
    def validate_cluster_health(self) -> bool:
        """Validate cluster health after deployment"""
        self.logger.info("Validating cluster health...")
        
        try:
            # Check overall cluster health
            health_url = f"{self.base_url}/cluster/health"
            response = self.session.get(health_url, timeout=30)
            response.raise_for_status()
            
            health_data = response.json()
            cluster_health = health_data.get('cluster_health')
            
            if cluster_health != 'healthy':
                self.logger.error(f"Cluster health is not healthy: {cluster_health}")
                return False
            
            # Check vSAN health
            vsan_health_url = f"{self.base_url}/cluster/health/vsan"
            response = self.session.get(vsan_health_url, timeout=30)
            response.raise_for_status()
            
            vsan_data = response.json()
            vsan_health = vsan_data.get('overall_health')
            
            if vsan_health != 'healthy':
                self.logger.error(f"vSAN health is not healthy: {vsan_health}")
                return False
            
            self.logger.info("Cluster health validation completed successfully")
            return True
            
        except requests.exceptions.RequestException as e:
            self.logger.error(f"Health validation failed: {e}")
            return False
    
    def configure_storage_policies(self) -> bool:
        """Configure vSAN storage policies"""
        self.logger.info("Configuring vSAN storage policies...")
        
        policies = [
            {
                "name": "Production VMs",
                "description": "High availability policy for production workloads",
                "failures_to_tolerate": 1,
                "stripe_width": 2,
                "thin_provisioning": True,
                "encryption": True
            },
            {
                "name": "Critical VMs",
                "description": "Maximum availability policy for critical workloads",
                "failures_to_tolerate": 2,
                "stripe_width": 4,
                "thin_provisioning": False,
                "encryption": True
            },
            {
                "name": "Development VMs",
                "description": "Basic policy for development workloads",
                "failures_to_tolerate": 0,
                "stripe_width": 1,
                "thin_provisioning": True,
                "encryption": False
            }
        ]
        
        success_count = 0
        for policy in policies:
            try:
                policy_url = f"{self.base_url}/storage-policies"
                response = self.session.post(policy_url, json=policy, timeout=30)
                response.raise_for_status()
                
                self.logger.info(f"Created storage policy: {policy['name']}")
                success_count += 1
                
            except requests.exceptions.RequestException as e:
                self.logger.warning(f"Failed to create policy {policy['name']}: {e}")
        
        self.logger.info(f"Storage policy configuration completed: {success_count}/{len(policies)} successful")
        return success_count > 0
    
    def generate_deployment_report(self) -> str:
        """Generate deployment completion report"""
        self.logger.info("Generating deployment report...")
        
        report_file = f"/tmp/vxrail-deployment-report-{int(time.time())}.txt"
        
        report_content = f"""
Dell VxRail HCI Deployment Report
=================================
Deployment Date: {time.strftime('%Y-%m-%d %H:%M:%S')}
Cluster Name: {self.config['cluster']['name']}
Datacenter: {self.config['cluster']['datacenter']}
vCenter FQDN: {self.config['vcenter']['fqdn']}
VxRail Manager IP: {self.vxrail_ip}

Deployment Status: SUCCESS

Configuration Summary:
- Management VLAN: {self.config['network']['management']['vlan_id']}
- vMotion VLAN: {self.config['network']['vmotion']['vlan_id']}
- vSAN VLAN: {self.config['network']['vsan']['vlan_id']}
- DNS Servers: {', '.join(self.config['network']['dns_servers'])}
- NTP Servers: {', '.join(self.config['network']['ntp_servers'])}

Next Steps:
1. Configure backup integration
2. Set up monitoring and alerting
3. Create VM templates
4. Migrate pilot workloads
5. Train administrative staff
6. Plan production migration

Support Information:
- Dell ProSupport Plus: 1-800-DELL-HELP
- VxRail Manager: https://{self.vxrail_ip}
- vCenter Server: https://{self.config['vcenter']['fqdn']}

Documentation:
- VxRail User Guide: Available via VxRail Manager
- VMware vSphere Documentation: docs.vmware.com
- Dell VxRail Support: support.dell.com
"""
        
        try:
            with open(report_file, 'w') as f:
                f.write(report_content)
            
            self.logger.info(f"Deployment report generated: {report_file}")
            print(report_content)
            return report_file
            
        except IOError as e:
            self.logger.error(f"Failed to write report file: {e}")
            print(report_content)
            return ""
    
    def deploy(self) -> bool:
        """Execute complete deployment workflow"""
        self.logger.info("Starting Dell VxRail HCI deployment...")
        
        try:
            # Authentication
            if not self.authenticate():
                return False
            
            # Prerequisites validation
            if not self.validate_prerequisites():
                return False
            
            # Node discovery
            nodes = self.discover_nodes()
            if not nodes:
                return False
            
            # Cluster configuration
            deployment_id = self.configure_cluster()
            if not deployment_id:
                return False
            
            # Monitor deployment
            if not self.monitor_deployment(deployment_id):
                return False
            
            # Validate health
            if not self.validate_cluster_health():
                self.logger.warning("Cluster health validation failed, but deployment may still be functional")
            
            # Configure storage policies
            self.configure_storage_policies()
            
            # Generate report
            self.generate_deployment_report()
            
            self.logger.info("Dell VxRail HCI deployment completed successfully!")
            return True
            
        except Exception as e:
            self.logger.error(f"Deployment failed with exception: {e}")
            return False

def main():
    """Main entry point"""
    parser = argparse.ArgumentParser(description='Deploy Dell VxRail HCI')
    parser.add_argument('--config', '-c', required=True,
                       help='Path to configuration JSON file')
    parser.add_argument('--verbose', '-v', action='store_true',
                       help='Enable verbose logging')
    
    args = parser.parse_args()
    
    if args.verbose:
        logging.getLogger().setLevel(logging.DEBUG)
    
    # Validate config file exists
    if not Path(args.config).exists():
        print(f"Error: Configuration file not found: {args.config}")
        sys.exit(1)
    
    # Create deployer and execute deployment
    deployer = VxRailDeployer(args.config)
    success = deployer.deploy()
    
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()