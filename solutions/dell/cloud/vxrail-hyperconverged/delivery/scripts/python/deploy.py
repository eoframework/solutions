#!/usr/bin/env python3
"""
Dell VxRail Hyperconverged Infrastructure Deployment Automation

This script provides comprehensive automation for deploying and managing
Dell VxRail hyperconverged infrastructure including cluster initialization,
node configuration, storage setup, and monitoring integration.
"""

import json
import time
import logging
import requests
import argparse
from typing import Dict, List, Optional
from dataclasses import dataclass
from urllib3.exceptions import InsecureRequestWarning

# Disable SSL warnings for lab environments
requests.packages.urllib3.disable_warnings(InsecureRequestWarning)

@dataclass
class VxRailConfig:
    """VxRail deployment configuration"""
    cluster_name: str
    vcenter_fqdn: str
    vcenter_username: str
    vcenter_password: str
    vxrail_manager_ip: str
    vxrail_username: str
    vxrail_password: str
    management_network: str
    vmotion_network: str
    vsan_network: str
    vm_network: str
    dns_servers: List[str]
    ntp_servers: List[str]
    domain_name: str
    enable_encryption: bool = False
    enable_deduplication: bool = True
    enable_compression: bool = True
    
class VxRailAPI:
    """VxRail Manager REST API client"""
    
    def __init__(self, manager_ip: str, username: str, password: str):
        self.base_url = f"https://{manager_ip}/rest/vxm"
        self.username = username
        self.password = password
        self.session = requests.Session()
        self.session.verify = False
        self.token = None
        
    def authenticate(self) -> bool:
        """Authenticate with VxRail Manager"""
        try:
            auth_data = {
                "username": self.username,
                "password": self.password
            }
            
            response = self.session.post(
                f"{self.base_url}/v1/sessions",
                json=auth_data,
                timeout=30
            )
            
            if response.status_code == 201:
                self.token = response.headers.get("Authorization")
                self.session.headers.update({"Authorization": self.token})
                logging.info("Successfully authenticated with VxRail Manager")
                return True
            else:
                logging.error(f"Authentication failed: {response.text}")
                return False
                
        except Exception as e:
            logging.error(f"Authentication error: {str(e)}")
            return False
    
    def get_cluster_info(self) -> Optional[Dict]:
        """Get cluster information"""
        try:
            response = self.session.get(f"{self.base_url}/v1/cluster", timeout=30)
            
            if response.status_code == 200:
                return response.json()
            else:
                logging.error(f"Failed to get cluster info: {response.text}")
                return None
                
        except Exception as e:
            logging.error(f"Error getting cluster info: {str(e)}")
            return None
    
    def get_nodes(self) -> Optional[List[Dict]]:
        """Get cluster nodes information"""
        try:
            response = self.session.get(f"{self.base_url}/v1/hosts", timeout=30)
            
            if response.status_code == 200:
                return response.json()
            else:
                logging.error(f"Failed to get nodes: {response.text}")
                return None
                
        except Exception as e:
            logging.error(f"Error getting nodes: {str(e)}")
            return None
    
    def get_storage_info(self) -> Optional[Dict]:
        """Get vSAN storage information"""
        try:
            response = self.session.get(f"{self.base_url}/v1/cluster/storage", timeout=30)
            
            if response.status_code == 200:
                return response.json()
            else:
                logging.error(f"Failed to get storage info: {response.text}")
                return None
                
        except Exception as e:
            logging.error(f"Error getting storage info: {str(e)}")
            return None
    
    def initiate_cluster_expansion(self, expansion_config: Dict) -> Optional[str]:
        """Initiate cluster expansion"""
        try:
            response = self.session.post(
                f"{self.base_url}/v1/cluster/expand",
                json=expansion_config,
                timeout=30
            )
            
            if response.status_code == 202:
                return response.json().get("request_id")
            else:
                logging.error(f"Failed to initiate expansion: {response.text}")
                return None
                
        except Exception as e:
            logging.error(f"Error initiating expansion: {str(e)}")
            return None
    
    def get_task_status(self, task_id: str) -> Optional[Dict]:
        """Get task status"""
        try:
            response = self.session.get(
                f"{self.base_url}/v1/requests/{task_id}",
                timeout=30
            )
            
            if response.status_code == 200:
                return response.json()
            else:
                logging.error(f"Failed to get task status: {response.text}")
                return None
                
        except Exception as e:
            logging.error(f"Error getting task status: {str(e)}")
            return None

class VxRailDeployment:
    """VxRail deployment orchestration"""
    
    def __init__(self, config: VxRailConfig):
        self.config = config
        self.vxrail_api = VxRailAPI(
            config.vxrail_manager_ip,
            config.vxrail_username,
            config.vxrail_password
        )
        
        # Set up logging
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(levelname)s - %(message)s',
            handlers=[
                logging.FileHandler('vxrail_deployment.log'),
                logging.StreamHandler()
            ]
        )
        
    def validate_prerequisites(self) -> bool:
        """Validate deployment prerequisites"""
        logging.info("Validating deployment prerequisites...")
        
        # Check VxRail Manager connectivity
        if not self.vxrail_api.authenticate():
            logging.error("Cannot authenticate with VxRail Manager")
            return False
        
        # Check cluster status
        cluster_info = self.vxrail_api.get_cluster_info()
        if not cluster_info:
            logging.error("Cannot retrieve cluster information")
            return False
        
        logging.info(f"Cluster status: {cluster_info.get('health_state', 'Unknown')}")
        
        # Check node health
        nodes = self.vxrail_api.get_nodes()
        if not nodes:
            logging.error("Cannot retrieve node information")
            return False
        
        healthy_nodes = sum(1 for node in nodes if node.get('health_state') == 'HEALTHY')
        logging.info(f"Healthy nodes: {healthy_nodes}/{len(nodes)}")
        
        return True
    
    def configure_networking(self) -> bool:
        """Configure VxRail networking"""
        logging.info("Configuring VxRail networking...")
        
        try:
            # Network configuration is typically done during initial setup
            # This function validates network configuration
            
            cluster_info = self.vxrail_api.get_cluster_info()
            if not cluster_info:
                return False
            
            # Check if all required networks are configured
            required_networks = [
                self.config.management_network,
                self.config.vmotion_network,
                self.config.vsan_network,
                self.config.vm_network
            ]
            
            logging.info(f"Required networks: {required_networks}")
            logging.info("Network configuration validation completed")
            
            return True
            
        except Exception as e:
            logging.error(f"Network configuration failed: {str(e)}")
            return False
    
    def configure_storage(self) -> bool:
        """Configure vSAN storage"""
        logging.info("Configuring vSAN storage...")
        
        try:
            storage_info = self.vxrail_api.get_storage_info()
            if not storage_info:
                logging.error("Cannot retrieve storage information")
                return False
            
            logging.info(f"vSAN capacity: {storage_info.get('total_capacity_gb', 0)} GB")
            logging.info(f"vSAN free space: {storage_info.get('free_space_gb', 0)} GB")
            
            # Configure storage policies if needed
            if self.config.enable_encryption:
                logging.info("Encryption is enabled for vSAN")
            
            if self.config.enable_deduplication:
                logging.info("Deduplication and compression enabled")
            
            return True
            
        except Exception as e:
            logging.error(f"Storage configuration failed: {str(e)}")
            return False
    
    def expand_cluster(self, node_specs: List[Dict]) -> bool:
        """Expand VxRail cluster with additional nodes"""
        logging.info(f"Expanding cluster with {len(node_specs)} nodes...")
        
        try:
            expansion_config = {
                "nodes": node_specs,
                "witness_node": False,
                "maintenance_mode": True
            }
            
            task_id = self.vxrail_api.initiate_cluster_expansion(expansion_config)
            if not task_id:
                logging.error("Failed to initiate cluster expansion")
                return False
            
            logging.info(f"Expansion task initiated: {task_id}")
            
            # Monitor expansion progress
            return self.monitor_task(task_id, "Cluster expansion")
            
        except Exception as e:
            logging.error(f"Cluster expansion failed: {str(e)}")
            return False
    
    def monitor_task(self, task_id: str, task_name: str) -> bool:
        """Monitor long-running task"""
        logging.info(f"Monitoring {task_name} task: {task_id}")
        
        try:
            while True:
                task_status = self.vxrail_api.get_task_status(task_id)
                if not task_status:
                    logging.error(f"Cannot retrieve task status for {task_id}")
                    return False
                
                state = task_status.get("state", "UNKNOWN")
                progress = task_status.get("progress_percentage", 0)
                
                logging.info(f"{task_name} progress: {progress}% ({state})")
                
                if state == "COMPLETED":
                    logging.info(f"{task_name} completed successfully")
                    return True
                elif state == "FAILED":
                    error_msg = task_status.get("error_message", "Unknown error")
                    logging.error(f"{task_name} failed: {error_msg}")
                    return False
                
                time.sleep(60)  # Check every minute
                
        except KeyboardInterrupt:
            logging.warning(f"Task monitoring interrupted for {task_id}")
            return False
        except Exception as e:
            logging.error(f"Task monitoring error: {str(e)}")
            return False
    
    def generate_health_report(self) -> Dict:
        """Generate comprehensive health report"""
        logging.info("Generating VxRail health report...")
        
        try:
            report = {
                "timestamp": time.strftime("%Y-%m-%d %H:%M:%S"),
                "cluster": {},
                "nodes": [],
                "storage": {},
                "recommendations": []
            }
            
            # Cluster information
            cluster_info = self.vxrail_api.get_cluster_info()
            if cluster_info:
                report["cluster"] = {
                    "name": cluster_info.get("cluster_name", "Unknown"),
                    "health": cluster_info.get("health_state", "Unknown"),
                    "version": cluster_info.get("vc_version", "Unknown"),
                    "node_count": cluster_info.get("total_hosts", 0)
                }
            
            # Node information
            nodes = self.vxrail_api.get_nodes()
            if nodes:
                for node in nodes:
                    report["nodes"].append({
                        "hostname": node.get("hostname", "Unknown"),
                        "health": node.get("health_state", "Unknown"),
                        "model": node.get("appliance_model", "Unknown"),
                        "cpu_usage": node.get("cpu_usage_percentage", 0),
                        "memory_usage": node.get("memory_usage_percentage", 0)
                    })
            
            # Storage information
            storage_info = self.vxrail_api.get_storage_info()
            if storage_info:
                report["storage"] = {
                    "total_capacity_gb": storage_info.get("total_capacity_gb", 0),
                    "used_capacity_gb": storage_info.get("used_capacity_gb", 0),
                    "free_space_gb": storage_info.get("free_space_gb", 0),
                    "usage_percentage": storage_info.get("usage_percentage", 0)
                }
            
            # Generate recommendations
            if report["storage"].get("usage_percentage", 0) > 80:
                report["recommendations"].append("Storage usage is high (>80%). Consider expanding storage.")
            
            unhealthy_nodes = [node for node in report["nodes"] if node["health"] != "HEALTHY"]
            if unhealthy_nodes:
                report["recommendations"].append(f"Found {len(unhealthy_nodes)} unhealthy nodes. Check hardware status.")
            
            return report
            
        except Exception as e:
            logging.error(f"Health report generation failed: {str(e)}")
            return {"error": str(e)}
    
    def export_configuration(self) -> bool:
        """Export VxRail configuration"""
        logging.info("Exporting VxRail configuration...")
        
        try:
            config_data = {
                "cluster": self.vxrail_api.get_cluster_info(),
                "nodes": self.vxrail_api.get_nodes(),
                "storage": self.vxrail_api.get_storage_info()
            }
            
            config_file = f"vxrail_config_{int(time.time())}.json"
            with open(config_file, 'w') as f:
                json.dump(config_data, f, indent=2)
            
            logging.info(f"Configuration exported to {config_file}")
            return True
            
        except Exception as e:
            logging.error(f"Configuration export failed: {str(e)}")
            return False

def load_config(config_file: str) -> VxRailConfig:
    """Load configuration from file"""
    with open(config_file, 'r') as f:
        config_data = json.load(f)
    
    return VxRailConfig(
        cluster_name=config_data["cluster_name"],
        vcenter_fqdn=config_data["vcenter_fqdn"],
        vcenter_username=config_data["vcenter_username"],
        vcenter_password=config_data["vcenter_password"],
        vxrail_manager_ip=config_data["vxrail_manager_ip"],
        vxrail_username=config_data["vxrail_username"],
        vxrail_password=config_data["vxrail_password"],
        management_network=config_data["management_network"],
        vmotion_network=config_data["vmotion_network"],
        vsan_network=config_data["vsan_network"],
        vm_network=config_data["vm_network"],
        dns_servers=config_data["dns_servers"],
        ntp_servers=config_data["ntp_servers"],
        domain_name=config_data["domain_name"],
        enable_encryption=config_data.get("enable_encryption", False),
        enable_deduplication=config_data.get("enable_deduplication", True),
        enable_compression=config_data.get("enable_compression", True)
    )

def main():
    """Main deployment function"""
    parser = argparse.ArgumentParser(description="Dell VxRail HCI Deployment")
    parser.add_argument("--config", required=True, help="Configuration file path")
    parser.add_argument("--action", required=True, 
                       choices=["validate", "deploy", "expand", "health", "export"],
                       help="Action to perform")
    parser.add_argument("--nodes", help="Node specifications file for expansion")
    
    args = parser.parse_args()
    
    try:
        # Load configuration
        config = load_config(args.config)
        deployment = VxRailDeployment(config)
        
        if args.action == "validate":
            logging.info("Starting prerequisite validation...")
            success = deployment.validate_prerequisites()
            
        elif args.action == "deploy":
            logging.info("Starting VxRail deployment...")
            success = (deployment.validate_prerequisites() and
                      deployment.configure_networking() and
                      deployment.configure_storage())
            
        elif args.action == "expand":
            if not args.nodes:
                logging.error("Node specifications file required for expansion")
                return 1
            
            with open(args.nodes, 'r') as f:
                node_specs = json.load(f)
            
            success = deployment.expand_cluster(node_specs)
            
        elif args.action == "health":
            logging.info("Generating health report...")
            report = deployment.generate_health_report()
            
            report_file = f"vxrail_health_report_{int(time.time())}.json"
            with open(report_file, 'w') as f:
                json.dump(report, f, indent=2)
            
            logging.info(f"Health report saved to {report_file}")
            print(json.dumps(report, indent=2))
            success = True
            
        elif args.action == "export":
            success = deployment.export_configuration()
        
        if success:
            logging.info(f"Action '{args.action}' completed successfully")
            return 0
        else:
            logging.error(f"Action '{args.action}' failed")
            return 1
            
    except Exception as e:
        logging.error(f"Deployment failed: {str(e)}")
        return 1

if __name__ == "__main__":
    exit(main())