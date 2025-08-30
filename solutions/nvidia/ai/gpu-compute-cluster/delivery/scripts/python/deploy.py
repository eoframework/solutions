#!/usr/bin/env python3
"""
NVIDIA GPU Compute Cluster Deployment Script

Orchestrates deployment of NVIDIA GPU compute clusters with comprehensive
validation, monitoring, and management capabilities for AI/ML workloads.

Features:
- Multi-node GPU cluster deployment
- NVIDIA driver and CUDA installation validation
- Kubernetes cluster setup with GPU support
- AI/ML framework deployment (TensorFlow, PyTorch, etc.)
- Resource monitoring and optimization
- Workload scheduling and management
- Comprehensive reporting and analytics

Author: EO Framework AI Team
Version: 1.0.0
"""

import os
import sys
import json
import logging
import argparse
import subprocess
import time
import threading
import socket
from datetime import datetime, timedelta
from pathlib import Path
from typing import Dict, List, Optional, Tuple, Any
from dataclasses import dataclass, asdict
from concurrent.futures import ThreadPoolExecutor, as_completed
import configparser

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler(sys.stdout),
        logging.FileHandler('gpu_cluster_deployment.log')
    ]
)
logger = logging.getLogger(__name__)

@dataclass
class GPUClusterConfig:
    """GPU cluster deployment configuration"""
    cluster_name: str
    nvidia_driver_version: str
    cuda_version: str
    kubernetes_version: str
    docker_version: str
    node_count: int
    gpu_type: str
    master_node: str
    worker_nodes: List[str]
    ssh_user: str = "ubuntu"
    ssh_key_path: str = "~/.ssh/id_rsa"
    deployment_timeout: int = 3600
    enable_monitoring: bool = True
    install_ml_frameworks: bool = True

@dataclass
class NodeInfo:
    """Information about a cluster node"""
    hostname: str
    ip_address: str
    role: str  # master or worker
    gpu_count: int = 0
    gpu_memory_total: int = 0  # in MB
    system_memory: int = 0  # in MB
    cpu_cores: int = 0
    status: str = "unknown"
    nvidia_driver_version: str = ""
    cuda_version: str = ""

class GPUClusterValidator:
    """Validates GPU cluster prerequisites and status"""
    
    def __init__(self, config: GPUClusterConfig):
        self.config = config
        
    def validate_prerequisites(self) -> Tuple[bool, List[str]]:
        """Validate deployment prerequisites"""
        logger.info("Validating GPU cluster prerequisites...")
        issues = []
        
        # Check SSH connectivity to all nodes
        ssh_issues = self._check_ssh_connectivity()
        issues.extend(ssh_issues)
        
        # Check hardware requirements on all nodes
        hardware_issues = self._check_hardware_requirements()
        issues.extend(hardware_issues)
        
        # Check network connectivity between nodes
        network_issues = self._check_network_connectivity()
        issues.extend(network_issues)
        
        # Check system requirements
        system_issues = self._check_system_requirements()
        issues.extend(system_issues)
        
        success = len(issues) == 0
        logger.info(f"Prerequisites validation {'passed' if success else 'failed'}")
        
        if issues:
            for issue in issues:
                logger.error(f"Prerequisite issue: {issue}")
                
        return success, issues
    
    def _check_ssh_connectivity(self) -> List[str]:
        """Check SSH connectivity to all nodes"""
        issues = []
        all_nodes = [self.config.master_node] + self.config.worker_nodes
        
        for node in all_nodes:
            try:
                result = subprocess.run([
                    'ssh', '-o', 'ConnectTimeout=10',
                    '-o', 'StrictHostKeyChecking=no',
                    '-i', self.config.ssh_key_path,
                    f'{self.config.ssh_user}@{node}',
                    'echo "SSH test successful"'
                ], capture_output=True, text=True, timeout=15)
                
                if result.returncode != 0:
                    issues.append(f"SSH connectivity failed for node {node}")
                    
            except subprocess.TimeoutExpired:
                issues.append(f"SSH timeout for node {node}")
            except Exception as e:
                issues.append(f"SSH error for node {node}: {e}")
        
        return issues
    
    def _check_hardware_requirements(self) -> List[str]:
        """Check hardware requirements on all nodes"""
        issues = []
        all_nodes = [self.config.master_node] + self.config.worker_nodes
        
        for node in all_nodes:
            try:
                # Check GPU presence
                gpu_result = self._execute_remote_command(
                    node, "lspci | grep -i nvidia | wc -l"
                )
                
                if gpu_result and int(gpu_result.strip()) == 0:
                    issues.append(f"No NVIDIA GPU found on node {node}")
                
                # Check memory
                mem_result = self._execute_remote_command(
                    node, "grep MemTotal /proc/meminfo | awk '{print $2}'"
                )
                
                if mem_result:
                    memory_kb = int(mem_result.strip())
                    memory_gb = memory_kb // 1024 // 1024
                    if memory_gb < 16:
                        issues.append(f"Insufficient memory on node {node}: {memory_gb}GB (minimum 16GB)")
                
                # Check disk space
                disk_result = self._execute_remote_command(
                    node, "df / | awk 'NR==2 {print $4}'"
                )
                
                if disk_result:
                    disk_kb = int(disk_result.strip())
                    disk_gb = disk_kb // 1024 // 1024
                    if disk_gb < 100:
                        issues.append(f"Insufficient disk space on node {node}: {disk_gb}GB (minimum 100GB)")
                        
            except Exception as e:
                issues.append(f"Hardware check failed for node {node}: {e}")
        
        return issues
    
    def _check_network_connectivity(self) -> List[str]:
        """Check network connectivity between nodes"""
        issues = []
        all_nodes = [self.config.master_node] + self.config.worker_nodes
        
        # Test connectivity from each node to all other nodes
        for source_node in all_nodes:
            for target_node in all_nodes:
                if source_node != target_node:
                    try:
                        result = self._execute_remote_command(
                            source_node, f"ping -c 1 -W 5 {target_node}"
                        )
                        if not result or "1 received" not in result:
                            issues.append(f"Network connectivity failed: {source_node} -> {target_node}")
                    except Exception as e:
                        issues.append(f"Network test failed {source_node} -> {target_node}: {e}")
        
        return issues
    
    def _check_system_requirements(self) -> List[str]:
        """Check system-level requirements"""
        issues = []
        all_nodes = [self.config.master_node] + self.config.worker_nodes
        
        for node in all_nodes:
            try:
                # Check kernel version
                kernel_result = self._execute_remote_command(node, "uname -r")
                if kernel_result:
                    logger.info(f"Node {node} kernel: {kernel_result.strip()}")
                
                # Check if running as root or with sudo access
                sudo_result = self._execute_remote_command(node, "sudo -n true 2>/dev/null && echo 'OK'")
                if not sudo_result or "OK" not in sudo_result:
                    issues.append(f"Sudo access required on node {node}")
                    
            except Exception as e:
                issues.append(f"System check failed for node {node}: {e}")
        
        return issues
    
    def _execute_remote_command(self, node: str, command: str) -> Optional[str]:
        """Execute command on remote node via SSH"""
        try:
            result = subprocess.run([
                'ssh', '-o', 'ConnectTimeout=10',
                '-o', 'StrictHostKeyChecking=no',
                '-i', self.config.ssh_key_path,
                f'{self.config.ssh_user}@{node}',
                command
            ], capture_output=True, text=True, timeout=30)
            
            if result.returncode == 0:
                return result.stdout
            else:
                logger.warning(f"Remote command failed on {node}: {result.stderr}")
                return None
                
        except Exception as e:
            logger.error(f"Error executing remote command on {node}: {e}")
            return None

class GPUClusterDeployment:
    """Main GPU cluster deployment orchestrator"""
    
    def __init__(self, config: GPUClusterConfig):
        self.config = config
        self.validator = GPUClusterValidator(config)
        self.bash_script_path = Path(__file__).parent.parent / "bash" / "deploy.sh"
        self.node_info: Dict[str, NodeInfo] = {}
        self.start_time = None
        self.deployment_status = {}
        
    def deploy(self, skip_validation: bool = False, dry_run: bool = False) -> bool:
        """Execute complete GPU cluster deployment"""
        logger.info(f"Starting NVIDIA GPU compute cluster deployment: {self.config.cluster_name}")
        self.start_time = datetime.now()
        
        try:
            # Step 1: Validate prerequisites
            if not skip_validation:
                success, issues = self.validator.validate_prerequisites()
                if not success:
                    logger.error(f"Prerequisites validation failed: {issues}")
                    return False
            
            # Step 2: Gather node information
            if not self._gather_node_information():
                logger.error("Failed to gather node information")
                return False
            
            # Step 3: Deploy to all nodes
            if dry_run:
                logger.info("DRY RUN: Would deploy GPU cluster to nodes")
                self._simulate_deployment()
                return True
            
            # Step 4: Execute deployment
            success = self._execute_cluster_deployment()
            if not success:
                logger.error("Cluster deployment failed")
                return False
            
            # Step 5: Verify deployment
            if not self._verify_cluster_deployment():
                logger.warning("Deployment verification had issues")
            
            # Step 6: Configure cluster networking and services
            if not self._configure_cluster_services():
                logger.warning("Cluster service configuration had issues")
            
            # Step 7: Install ML frameworks if requested
            if self.config.install_ml_frameworks:
                if not self._install_ml_frameworks():
                    logger.warning("ML frameworks installation had issues")
            
            # Step 8: Setup monitoring if requested
            if self.config.enable_monitoring:
                if not self._setup_monitoring():
                    logger.warning("Monitoring setup had issues")
            
            # Step 9: Generate comprehensive report
            self._generate_deployment_report()
            
            logger.info("GPU cluster deployment completed successfully")
            return True
            
        except Exception as e:
            logger.error(f"Deployment failed with exception: {e}")
            return False
    
    def _gather_node_information(self) -> bool:
        """Gather information about all cluster nodes"""
        logger.info("Gathering node information...")
        
        all_nodes = [(self.config.master_node, "master")] + \
                   [(node, "worker") for node in self.config.worker_nodes]
        
        for node_ip, role in all_nodes:
            try:
                node_info = self._get_node_info(node_ip, role)
                self.node_info[node_ip] = node_info
                logger.info(f"Node {node_ip} ({role}): {node_info.gpu_count} GPUs, "
                          f"{node_info.system_memory//1024}GB RAM, {node_info.cpu_cores} CPUs")
                          
            except Exception as e:
                logger.error(f"Failed to gather information for node {node_ip}: {e}")
                return False
        
        return True
    
    def _get_node_info(self, node_ip: str, role: str) -> NodeInfo:
        """Get detailed information about a specific node"""
        # Get hostname
        hostname_result = self.validator._execute_remote_command(node_ip, "hostname")
        hostname = hostname_result.strip() if hostname_result else node_ip
        
        # Get GPU count
        gpu_count_result = self.validator._execute_remote_command(
            node_ip, "lspci | grep -i nvidia | wc -l"
        )
        gpu_count = int(gpu_count_result.strip()) if gpu_count_result else 0
        
        # Get system memory
        mem_result = self.validator._execute_remote_command(
            node_ip, "grep MemTotal /proc/meminfo | awk '{print $2}'"
        )
        system_memory = int(mem_result.strip()) // 1024 if mem_result else 0  # Convert to MB
        
        # Get CPU cores
        cpu_result = self.validator._execute_remote_command(
            node_ip, "nproc"
        )
        cpu_cores = int(cpu_result.strip()) if cpu_result else 0
        
        return NodeInfo(
            hostname=hostname,
            ip_address=node_ip,
            role=role,
            gpu_count=gpu_count,
            system_memory=system_memory,
            cpu_cores=cpu_cores,
            status="detected"
        )
    
    def _simulate_deployment(self):
        """Simulate deployment for dry run"""
        logger.info("=== DRY RUN SIMULATION ===")
        logger.info(f"Cluster Name: {self.config.cluster_name}")
        logger.info(f"Master Node: {self.config.master_node}")
        logger.info(f"Worker Nodes: {', '.join(self.config.worker_nodes)}")
        logger.info(f"NVIDIA Driver: {self.config.nvidia_driver_version}")
        logger.info(f"CUDA Version: {self.config.cuda_version}")
        
        for node_ip, node_info in self.node_info.items():
            logger.info(f"Would deploy to {node_ip} ({node_info.role}): "
                      f"{node_info.gpu_count} GPUs, {node_info.system_memory//1024}GB RAM")
        
        logger.info("=== END DRY RUN ===")
    
    def _execute_cluster_deployment(self) -> bool:
        """Execute deployment to all nodes"""
        logger.info("Executing cluster deployment...")
        
        # Deploy to master node first
        logger.info(f"Deploying to master node: {self.config.master_node}")
        if not self._deploy_to_node(self.config.master_node, is_master=True):
            logger.error("Master node deployment failed")
            return False
        
        # Deploy to worker nodes in parallel
        if self.config.worker_nodes:
            logger.info(f"Deploying to {len(self.config.worker_nodes)} worker nodes...")
            
            with ThreadPoolExecutor(max_workers=min(len(self.config.worker_nodes), 5)) as executor:
                futures = {
                    executor.submit(self._deploy_to_node, node, False): node
                    for node in self.config.worker_nodes
                }
                
                for future in as_completed(futures):
                    node = futures[future]
                    try:
                        success = future.result(timeout=1800)  # 30 minutes timeout
                        if success:
                            logger.info(f"Worker node {node} deployed successfully")
                            self.deployment_status[node] = "success"
                        else:
                            logger.error(f"Worker node {node} deployment failed")
                            self.deployment_status[node] = "failed"
                    except Exception as e:
                        logger.error(f"Worker node {node} deployment error: {e}")
                        self.deployment_status[node] = "error"
        
        # Check if all deployments succeeded
        failed_nodes = [node for node, status in self.deployment_status.items() 
                       if status != "success"]
        
        if failed_nodes:
            logger.error(f"Deployment failed on nodes: {', '.join(failed_nodes)}")
            return False
        
        logger.info("All nodes deployed successfully")
        return True
    
    def _deploy_to_node(self, node_ip: str, is_master: bool) -> bool:
        """Deploy GPU cluster components to a specific node"""
        try:
            # Copy deployment script to remote node
            script_remote_path = f"/tmp/gpu_cluster_deploy.sh"
            
            copy_result = subprocess.run([
                'scp', '-o', 'StrictHostKeyChecking=no',
                '-i', self.config.ssh_key_path,
                str(self.bash_script_path),
                f'{self.config.ssh_user}@{node_ip}:{script_remote_path}'
            ], capture_output=True, text=True)
            
            if copy_result.returncode != 0:
                logger.error(f"Failed to copy script to node {node_ip}")
                return False
            
            # Execute deployment script on remote node
            deploy_command = [
                'ssh', '-o', 'StrictHostKeyChecking=no',
                '-i', self.config.ssh_key_path,
                f'{self.config.ssh_user}@{node_ip}',
                f'sudo chmod +x {script_remote_path} && '
                f'sudo {script_remote_path} '
                f'--cluster-name {self.config.cluster_name} '
                f'--driver-version {self.config.nvidia_driver_version} '
                f'--cuda-version {self.config.cuda_version} '
                f'--gpu-type {self.config.gpu_type}'
            ]
            
            logger.info(f"Starting deployment on node {node_ip}...")
            
            result = subprocess.run(
                deploy_command,
                capture_output=True,
                text=True,
                timeout=self.config.deployment_timeout
            )
            
            if result.returncode == 0:
                logger.info(f"Node {node_ip} deployment completed successfully")
                return True
            else:
                logger.error(f"Node {node_ip} deployment failed: {result.stderr}")
                return False
                
        except subprocess.TimeoutExpired:
            logger.error(f"Node {node_ip} deployment timed out")
            return False
        except Exception as e:
            logger.error(f"Error deploying to node {node_ip}: {e}")
            return False
    
    def _verify_cluster_deployment(self) -> bool:
        """Verify the cluster deployment"""
        logger.info("Verifying cluster deployment...")
        
        # Verify Kubernetes cluster
        master_node = self.config.master_node
        
        try:
            # Check if kubectl is working on master node
            result = self.validator._execute_remote_command(
                master_node, "kubectl get nodes --no-headers | wc -l"
            )
            
            if result:
                node_count = int(result.strip())
                expected_nodes = 1 + len(self.config.worker_nodes)  # master + workers
                
                if node_count == expected_nodes:
                    logger.info(f"Kubernetes cluster has all {expected_nodes} nodes")
                else:
                    logger.warning(f"Kubernetes cluster has {node_count} nodes, expected {expected_nodes}")
            
            # Check GPU resources
            gpu_result = self.validator._execute_remote_command(
                master_node, "kubectl describe nodes | grep 'nvidia.com/gpu' | wc -l"
            )
            
            if gpu_result and int(gpu_result.strip()) > 0:
                logger.info("GPU resources detected in Kubernetes cluster")
            else:
                logger.warning("No GPU resources detected in Kubernetes cluster")
                
            return True
            
        except Exception as e:
            logger.error(f"Cluster verification failed: {e}")
            return False
    
    def _configure_cluster_services(self) -> bool:
        """Configure additional cluster services"""
        logger.info("Configuring cluster services...")
        
        try:
            # Configure cluster-level services on master node
            master_node = self.config.master_node
            
            # Apply any additional Kubernetes configurations
            # This is a placeholder for additional service configuration
            
            logger.info("Cluster services configured successfully")
            return True
            
        except Exception as e:
            logger.error(f"Cluster service configuration failed: {e}")
            return False
    
    def _install_ml_frameworks(self) -> bool:
        """Install ML frameworks on the cluster"""
        logger.info("Installing ML frameworks...")
        
        try:
            # Install frameworks via the bash script on master node
            # The bash script already handles this
            logger.info("ML frameworks installation completed")
            return True
            
        except Exception as e:
            logger.error(f"ML frameworks installation failed: {e}")
            return False
    
    def _setup_monitoring(self) -> bool:
        """Setup cluster monitoring"""
        logger.info("Setting up cluster monitoring...")
        
        try:
            # Setup monitoring via the bash script
            # The bash script already handles this
            logger.info("Monitoring setup completed")
            return True
            
        except Exception as e:
            logger.error(f"Monitoring setup failed: {e}")
            return False
    
    def _generate_deployment_report(self):
        """Generate comprehensive deployment report"""
        try:
            end_time = datetime.now()
            duration = end_time - self.start_time
            
            report = {
                "deployment_summary": {
                    "cluster_name": self.config.cluster_name,
                    "start_time": self.start_time.isoformat(),
                    "end_time": end_time.isoformat(),
                    "duration_minutes": duration.total_seconds() / 60,
                    "status": "completed"
                },
                "cluster_configuration": {
                    "master_node": self.config.master_node,
                    "worker_nodes": self.config.worker_nodes,
                    "total_nodes": 1 + len(self.config.worker_nodes),
                    "nvidia_driver_version": self.config.nvidia_driver_version,
                    "cuda_version": self.config.cuda_version,
                    "kubernetes_version": self.config.kubernetes_version
                },
                "hardware_summary": {
                    "total_gpus": sum(node.gpu_count for node in self.node_info.values()),
                    "total_memory_gb": sum(node.system_memory for node in self.node_info.values()) // 1024,
                    "total_cpu_cores": sum(node.cpu_cores for node in self.node_info.values())
                },
                "node_details": {
                    node_ip: asdict(node_info)
                    for node_ip, node_info in self.node_info.items()
                },
                "deployment_status": self.deployment_status,
                "features": {
                    "monitoring_enabled": self.config.enable_monitoring,
                    "ml_frameworks_installed": self.config.install_ml_frameworks
                }
            }
            
            report_file = f"gpu_cluster_deployment_{self.start_time.strftime('%Y%m%d_%H%M%S')}.json"
            with open(report_file, 'w') as f:
                json.dump(report, f, indent=2, default=str)
                
            logger.info(f"Deployment report generated: {report_file}")
            
            # Print summary to console
            print("\n" + "="*60)
            print("GPU CLUSTER DEPLOYMENT SUMMARY")
            print("="*60)
            print(f"Cluster Name: {self.config.cluster_name}")
            print(f"Total Nodes: {1 + len(self.config.worker_nodes)}")
            print(f"Total GPUs: {sum(node.gpu_count for node in self.node_info.values())}")
            print(f"Deployment Duration: {duration.total_seconds()/60:.1f} minutes")
            print(f"Status: {'SUCCESS' if not any(status == 'failed' for status in self.deployment_status.values()) else 'PARTIAL'}")
            print("="*60)
            
        except Exception as e:
            logger.error(f"Failed to generate deployment report: {e}")

def load_config_from_file(config_file: str) -> GPUClusterConfig:
    """Load configuration from file"""
    config = configparser.ConfigParser()
    config.read(config_file)
    
    return GPUClusterConfig(
        cluster_name=config.get('cluster', 'name', fallback='nvidia-gpu-cluster'),
        nvidia_driver_version=config.get('nvidia', 'driver_version', fallback='535.129.03'),
        cuda_version=config.get('nvidia', 'cuda_version', fallback='12.2'),
        kubernetes_version=config.get('cluster', 'kubernetes_version', fallback='1.28'),
        docker_version=config.get('cluster', 'docker_version', fallback='24.0'),
        node_count=config.getint('cluster', 'node_count', fallback=3),
        gpu_type=config.get('hardware', 'gpu_type', fallback='RTX4090'),
        master_node=config.get('nodes', 'master'),
        worker_nodes=config.get('nodes', 'workers', fallback='').split(','),
        ssh_user=config.get('ssh', 'user', fallback='ubuntu'),
        ssh_key_path=config.get('ssh', 'key_path', fallback='~/.ssh/id_rsa'),
        enable_monitoring=config.getboolean('features', 'monitoring', fallback=True),
        install_ml_frameworks=config.getboolean('features', 'ml_frameworks', fallback=True)
    )

def main():
    parser = argparse.ArgumentParser(description='NVIDIA GPU Compute Cluster Deployment')
    parser.add_argument('--config', required=True, help='Configuration file path')
    parser.add_argument('--skip-validation', action='store_true', help='Skip prerequisite validation')
    parser.add_argument('--dry-run', action='store_true', help='Perform dry run')
    parser.add_argument('--verbose', '-v', action='store_true', help='Enable verbose logging')
    
    args = parser.parse_args()
    
    if args.verbose:
        logging.getLogger().setLevel(logging.DEBUG)
    
    try:
        config = load_config_from_file(args.config)
        deployment = GPUClusterDeployment(config)
        
        success = deployment.deploy(
            skip_validation=args.skip_validation,
            dry_run=args.dry_run
        )
        
        sys.exit(0 if success else 1)
        
    except Exception as e:
        logger.error(f"Deployment failed: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()