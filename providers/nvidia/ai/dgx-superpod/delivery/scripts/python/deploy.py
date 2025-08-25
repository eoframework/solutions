#!/usr/bin/env python3
"""
NVIDIA DGX SuperPOD Deployment and Management Tool

This script provides comprehensive deployment automation and ongoing management
capabilities for NVIDIA DGX SuperPOD AI infrastructure.

Version: 1.0
Author: DGX SuperPOD Engineering Team
"""

import argparse
import json
import logging
import os
import subprocess
import sys
import time
import yaml
from concurrent.futures import ThreadPoolExecutor, as_completed
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional, Tuple

import requests
import paramiko
from kubernetes import client, config
from prometheus_client.parser import text_string_to_metric_families

class DGXSuperPODManager:
    """Main class for DGX SuperPOD management operations"""
    
    def __init__(self, config_file: str = None):
        self.config_file = config_file or '/opt/dgx/config/cluster.conf'
        self.config = self.load_configuration()
        self.setup_logging()
        self.ssh_clients = {}
        
    def setup_logging(self):
        """Setup logging configuration"""
        log_level = self.config.get('log_level', 'INFO').upper()
        log_format = '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
        
        logging.basicConfig(
            level=getattr(logging, log_level),
            format=log_format,
            handlers=[
                logging.FileHandler('/var/log/dgx-superpod/python-manager.log'),
                logging.StreamHandler(sys.stdout)
            ]
        )
        
        self.logger = logging.getLogger('DGXSuperPODManager')
        
    def load_configuration(self) -> Dict:
        """Load configuration from file"""
        try:
            if os.path.exists(self.config_file):
                with open(self.config_file, 'r') as f:
                    if self.config_file.endswith('.yaml') or self.config_file.endswith('.yml'):
                        return yaml.safe_load(f)
                    else:
                        # Simple key=value format
                        config = {}
                        for line in f:
                            if line.strip() and not line.startswith('#'):
                                key, value = line.strip().split('=', 1)
                                config[key] = value
                        return config
            else:
                self.logger.warning(f"Configuration file {self.config_file} not found, using defaults")
                return self.get_default_config()
        except Exception as e:
            self.logger.error(f"Error loading configuration: {e}")
            return self.get_default_config()
    
    def get_default_config(self) -> Dict:
        """Return default configuration"""
        return {
            'cluster_name': 'dgx-superpod',
            'node_count': '20',
            'domain_name': 'local',
            'monitoring_enabled': 'true',
            'backup_enabled': 'true',
            'prometheus_url': 'http://prometheus:9090',
            'grafana_url': 'http://grafana:3000',
            'slurm_controller': 'mgmt-node'
        }
    
    def get_ssh_client(self, hostname: str) -> paramiko.SSHClient:
        """Get or create SSH client for a host"""
        if hostname not in self.ssh_clients:
            client = paramiko.SSHClient()
            client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            try:
                client.connect(hostname, username='root', timeout=10)
                self.ssh_clients[hostname] = client
            except Exception as e:
                self.logger.error(f"Failed to connect to {hostname}: {e}")
                raise
        
        return self.ssh_clients[hostname]
    
    def execute_remote_command(self, hostname: str, command: str, timeout: int = 30) -> Tuple[int, str, str]:
        """Execute command on remote host"""
        try:
            client = self.get_ssh_client(hostname)
            stdin, stdout, stderr = client.exec_command(command, timeout=timeout)
            
            exit_code = stdout.channel.recv_exit_status()
            stdout_data = stdout.read().decode('utf-8')
            stderr_data = stderr.read().decode('utf-8')
            
            return exit_code, stdout_data, stderr_data
        
        except Exception as e:
            self.logger.error(f"Failed to execute command on {hostname}: {e}")
            return -1, "", str(e)
    
    def health_check(self) -> Dict:
        """Perform comprehensive cluster health check"""
        self.logger.info("Starting cluster health check")
        
        health_status = {
            'timestamp': datetime.now().isoformat(),
            'cluster_name': self.config['cluster_name'],
            'overall_status': 'unknown',
            'nodes': {},
            'services': {},
            'storage': {},
            'network': {},
            'summary': {}
        }
        
        # Check node health
        self.check_node_health(health_status)
        
        # Check service health
        self.check_service_health(health_status)
        
        # Check storage health
        self.check_storage_health(health_status)
        
        # Check network health
        self.check_network_health(health_status)
        
        # Generate summary
        self.generate_health_summary(health_status)
        
        self.logger.info(f"Health check completed. Overall status: {health_status['overall_status']}")
        return health_status
    
    def check_node_health(self, health_status: Dict):
        """Check individual node health"""
        self.logger.info("Checking node health")
        
        node_count = int(self.config['node_count'])
        node_list = [f"dgx-{i:03d}" for i in range(1, node_count + 1)]
        
        def check_single_node(hostname):
            node_status = {
                'hostname': hostname,
                'status': 'unknown',
                'gpus': 0,
                'gpu_temp_avg': 0,
                'memory_usage': 0,
                'cpu_usage': 0,
                'uptime': 0,
                'issues': []
            }
            
            try:
                # Check SSH connectivity
                exit_code, stdout, stderr = self.execute_remote_command(hostname, 'echo "alive"')
                if exit_code != 0:
                    node_status['status'] = 'unreachable'
                    node_status['issues'].append('SSH connectivity failed')
                    return hostname, node_status
                
                # Check GPU status
                exit_code, stdout, stderr = self.execute_remote_command(
                    hostname, 
                    "nvidia-smi --query-gpu=count,temperature.gpu --format=csv,noheader,nounits"
                )
                
                if exit_code == 0 and stdout:
                    lines = stdout.strip().split('\n')
                    node_status['gpus'] = len(lines)
                    temperatures = [float(line.split(',')[1]) for line in lines if line.strip()]
                    node_status['gpu_temp_avg'] = sum(temperatures) / len(temperatures) if temperatures else 0
                    
                    # Check for temperature issues
                    if any(temp > 85 for temp in temperatures):
                        node_status['issues'].append('High GPU temperature detected')
                else:
                    node_status['issues'].append('GPU status check failed')
                
                # Check memory usage
                exit_code, stdout, stderr = self.execute_remote_command(
                    hostname, 
                    "free | grep Mem | awk '{printf \"%.1f\", $3/$2 * 100.0}'"
                )
                
                if exit_code == 0 and stdout:
                    node_status['memory_usage'] = float(stdout.strip())
                
                # Check CPU usage
                exit_code, stdout, stderr = self.execute_remote_command(
                    hostname,
                    "top -bn1 | grep 'Cpu(s)' | awk '{print $2}' | cut -d'%' -f1"
                )
                
                if exit_code == 0 and stdout:
                    node_status['cpu_usage'] = float(stdout.strip())
                
                # Check uptime
                exit_code, stdout, stderr = self.execute_remote_command(
                    hostname,
                    "uptime -p"
                )
                
                if exit_code == 0 and stdout:
                    node_status['uptime'] = stdout.strip()
                
                # Determine overall node status
                if len(node_status['issues']) == 0:
                    node_status['status'] = 'healthy'
                else:
                    node_status['status'] = 'warning'
                
            except Exception as e:
                node_status['status'] = 'error'
                node_status['issues'].append(f'Health check error: {str(e)}')
            
            return hostname, node_status
        
        # Check nodes in parallel
        with ThreadPoolExecutor(max_workers=10) as executor:
            future_to_node = {executor.submit(check_single_node, node): node for node in node_list}
            
            for future in as_completed(future_to_node):
                hostname, node_status = future.result()
                health_status['nodes'][hostname] = node_status
    
    def check_service_health(self, health_status: Dict):
        """Check critical service health"""
        self.logger.info("Checking service health")
        
        services_to_check = [
            ('slurm', 'squeue --version'),
            ('kubernetes', 'kubectl version --client --short'),
            ('docker', 'docker version --format "{{.Server.Version}}"'),
            ('nvidia-dcgm', 'dcgmi discovery -l'),
            ('prometheus', f'curl -s {self.config["prometheus_url"]}/api/v1/query?query=up'),
            ('grafana', f'curl -s {self.config["grafana_url"]}/api/health')
        ]
        
        for service_name, check_command in services_to_check:
            service_status = {
                'name': service_name,
                'status': 'unknown',
                'version': '',
                'response_time': 0,
                'issues': []
            }
            
            try:
                start_time = time.time()
                
                if service_name in ['prometheus', 'grafana']:
                    # HTTP-based checks
                    response = requests.get(check_command, timeout=10)
                    response_time = time.time() - start_time
                    
                    if response.status_code == 200:
                        service_status['status'] = 'healthy'
                        service_status['response_time'] = response_time
                    else:
                        service_status['status'] = 'unhealthy'
                        service_status['issues'].append(f'HTTP {response.status_code}')
                else:
                    # Command-based checks
                    result = subprocess.run(
                        check_command, 
                        shell=True, 
                        capture_output=True, 
                        text=True, 
                        timeout=30
                    )
                    
                    response_time = time.time() - start_time
                    service_status['response_time'] = response_time
                    
                    if result.returncode == 0:
                        service_status['status'] = 'healthy'
                        service_status['version'] = result.stdout.strip()[:50]  # First 50 chars
                    else:
                        service_status['status'] = 'unhealthy'
                        service_status['issues'].append(result.stderr.strip()[:100])
                
            except Exception as e:
                service_status['status'] = 'error'
                service_status['issues'].append(str(e))
            
            health_status['services'][service_name] = service_status
    
    def check_storage_health(self, health_status: Dict):
        """Check storage system health"""
        self.logger.info("Checking storage health")
        
        mount_points = ['/mnt/datasets', '/mnt/models', '/mnt/results', '/mnt/scratch']
        
        for mount_point in mount_points:
            mount_status = {
                'path': mount_point,
                'status': 'unknown',
                'total_size': 0,
                'used_size': 0,
                'available_size': 0,
                'usage_percent': 0,
                'mount_type': '',
                'issues': []
            }
            
            try:
                # Check if mount point exists and is accessible
                if not os.path.exists(mount_point):
                    mount_status['status'] = 'missing'
                    mount_status['issues'].append('Mount point does not exist')
                    continue
                
                # Get filesystem statistics
                stat = os.statvfs(mount_point)
                total_size = stat.f_frsize * stat.f_blocks
                available_size = stat.f_frsize * stat.f_bavail
                used_size = total_size - available_size
                
                mount_status['total_size'] = total_size
                mount_status['used_size'] = used_size
                mount_status['available_size'] = available_size
                mount_status['usage_percent'] = (used_size / total_size * 100) if total_size > 0 else 0
                
                # Get mount type
                result = subprocess.run(
                    f"df -T {mount_point} | tail -1 | awk '{{print $2}}'",
                    shell=True,
                    capture_output=True,
                    text=True
                )
                
                if result.returncode == 0:
                    mount_status['mount_type'] = result.stdout.strip()
                
                # Check for issues
                if mount_status['usage_percent'] > 90:
                    mount_status['issues'].append('Storage usage > 90%')
                    mount_status['status'] = 'warning'
                elif mount_status['usage_percent'] > 95:
                    mount_status['issues'].append('Storage usage > 95%')
                    mount_status['status'] = 'critical'
                else:
                    mount_status['status'] = 'healthy'
                
            except Exception as e:
                mount_status['status'] = 'error'
                mount_status['issues'].append(str(e))
            
            health_status['storage'][mount_point] = mount_status
    
    def check_network_health(self, health_status: Dict):
        """Check network infrastructure health"""
        self.logger.info("Checking network health")
        
        network_status = {
            'infiniband': {
                'status': 'unknown',
                'active_ports': 0,
                'total_ports': 0,
                'bandwidth_test': {},
                'issues': []
            }
        }
        
        try:
            # Check InfiniBand status
            result = subprocess.run(
                "ibstat | grep -E '(State|Rate)' | wc -l",
                shell=True,
                capture_output=True,
                text=True
            )
            
            if result.returncode == 0:
                port_info_lines = int(result.stdout.strip())
                network_status['infiniband']['total_ports'] = port_info_lines // 2
                
                # Count active ports
                result = subprocess.run(
                    "ibstat | grep 'State: Active' | wc -l",
                    shell=True,
                    capture_output=True,
                    text=True
                )
                
                if result.returncode == 0:
                    network_status['infiniband']['active_ports'] = int(result.stdout.strip())
                    
                    if network_status['infiniband']['active_ports'] == network_status['infiniband']['total_ports']:
                        network_status['infiniband']['status'] = 'healthy'
                    else:
                        network_status['infiniband']['status'] = 'degraded'
                        network_status['infiniband']['issues'].append('Some InfiniBand ports are down')
            
            # Quick bandwidth test between first two nodes
            node_count = int(self.config['node_count'])
            if node_count >= 2:
                try:
                    result = subprocess.run(
                        "ib_send_bw dgx-002 -D 5",
                        shell=True,
                        capture_output=True,
                        text=True,
                        timeout=30
                    )
                    
                    if result.returncode == 0:
                        # Parse bandwidth result
                        for line in result.stdout.split('\n'):
                            if 'BW average' in line:
                                bandwidth = line.split()[-2]
                                network_status['infiniband']['bandwidth_test'] = {
                                    'status': 'success',
                                    'bandwidth': bandwidth
                                }
                                break
                    else:
                        network_status['infiniband']['bandwidth_test'] = {
                            'status': 'failed',
                            'error': result.stderr.strip()
                        }
                        
                except subprocess.TimeoutExpired:
                    network_status['infiniband']['bandwidth_test'] = {
                        'status': 'timeout',
                        'error': 'Bandwidth test timed out'
                    }
                    
        except Exception as e:
            network_status['infiniband']['status'] = 'error'
            network_status['infiniband']['issues'].append(str(e))
        
        health_status['network'] = network_status
    
    def generate_health_summary(self, health_status: Dict):
        """Generate overall health summary"""
        summary = {
            'total_nodes': len(health_status['nodes']),
            'healthy_nodes': 0,
            'warning_nodes': 0,
            'error_nodes': 0,
            'services_healthy': 0,
            'services_total': len(health_status['services']),
            'storage_issues': 0,
            'network_status': 'unknown'
        }
        
        # Count node statuses
        for node_info in health_status['nodes'].values():
            if node_info['status'] == 'healthy':
                summary['healthy_nodes'] += 1
            elif node_info['status'] == 'warning':
                summary['warning_nodes'] += 1
            else:
                summary['error_nodes'] += 1
        
        # Count healthy services
        for service_info in health_status['services'].values():
            if service_info['status'] == 'healthy':
                summary['services_healthy'] += 1
        
        # Count storage issues
        for storage_info in health_status['storage'].values():
            if storage_info['status'] in ['warning', 'critical', 'error']:
                summary['storage_issues'] += 1
        
        # Network status
        summary['network_status'] = health_status['network']['infiniband']['status']
        
        # Overall status determination
        if (summary['error_nodes'] == 0 and 
            summary['services_healthy'] == summary['services_total'] and 
            summary['storage_issues'] == 0 and 
            summary['network_status'] == 'healthy'):
            health_status['overall_status'] = 'healthy'
        elif summary['error_nodes'] > summary['total_nodes'] * 0.5:
            health_status['overall_status'] = 'critical'
        else:
            health_status['overall_status'] = 'warning'
        
        health_status['summary'] = summary
    
    def monitor_performance(self, duration: int = 3600) -> Dict:
        """Monitor system performance for specified duration"""
        self.logger.info(f"Starting performance monitoring for {duration} seconds")
        
        monitoring_data = {
            'start_time': datetime.now().isoformat(),
            'duration': duration,
            'metrics': {
                'gpu_utilization': [],
                'gpu_temperature': [],
                'memory_usage': [],
                'network_throughput': [],
                'job_queue_length': []
            }
        }
        
        start_time = time.time()
        
        while time.time() - start_time < duration:
            timestamp = datetime.now().isoformat()
            
            # Collect GPU metrics
            self.collect_gpu_metrics(monitoring_data['metrics'], timestamp)
            
            # Collect system metrics
            self.collect_system_metrics(monitoring_data['metrics'], timestamp)
            
            # Collect job queue metrics
            self.collect_job_metrics(monitoring_data['metrics'], timestamp)
            
            # Sleep before next collection
            time.sleep(60)  # Collect every minute
        
        monitoring_data['end_time'] = datetime.now().isoformat()
        self.logger.info("Performance monitoring completed")
        
        return monitoring_data
    
    def collect_gpu_metrics(self, metrics: Dict, timestamp: str):
        """Collect GPU performance metrics"""
        try:
            node_count = int(self.config['node_count'])
            
            total_utilization = 0
            total_temperature = 0
            gpu_count = 0
            
            for i in range(1, min(node_count + 1, 6)):  # Sample first 5 nodes
                hostname = f"dgx-{i:03d}"
                
                exit_code, stdout, stderr = self.execute_remote_command(
                    hostname,
                    "nvidia-smi --query-gpu=utilization.gpu,temperature.gpu --format=csv,noheader,nounits"
                )
                
                if exit_code == 0 and stdout:
                    for line in stdout.strip().split('\n'):
                        if line.strip():
                            util, temp = line.split(',')
                            total_utilization += float(util.strip())
                            total_temperature += float(temp.strip())
                            gpu_count += 1
            
            if gpu_count > 0:
                avg_utilization = total_utilization / gpu_count
                avg_temperature = total_temperature / gpu_count
                
                metrics['gpu_utilization'].append({
                    'timestamp': timestamp,
                    'value': avg_utilization
                })
                
                metrics['gpu_temperature'].append({
                    'timestamp': timestamp,
                    'value': avg_temperature
                })
        
        except Exception as e:
            self.logger.error(f"Error collecting GPU metrics: {e}")
    
    def collect_system_metrics(self, metrics: Dict, timestamp: str):
        """Collect system performance metrics"""
        try:
            # Collect memory usage from first node as sample
            exit_code, stdout, stderr = self.execute_remote_command(
                "dgx-001",
                "free | grep Mem | awk '{printf \"%.1f\", $3/$2 * 100.0}'"
            )
            
            if exit_code == 0 and stdout:
                memory_usage = float(stdout.strip())
                metrics['memory_usage'].append({
                    'timestamp': timestamp,
                    'value': memory_usage
                })
        
        except Exception as e:
            self.logger.error(f"Error collecting system metrics: {e}")
    
    def collect_job_metrics(self, metrics: Dict, timestamp: str):
        """Collect SLURM job queue metrics"""
        try:
            result = subprocess.run(
                "squeue -h | wc -l",
                shell=True,
                capture_output=True,
                text=True
            )
            
            if result.returncode == 0:
                queue_length = int(result.stdout.strip())
                metrics['job_queue_length'].append({
                    'timestamp': timestamp,
                    'value': queue_length
                })
        
        except Exception as e:
            self.logger.error(f"Error collecting job metrics: {e}")
    
    def add_user(self, username: str, email: str = None, groups: List[str] = None) -> bool:
        """Add a new user to the cluster"""
        self.logger.info(f"Adding user: {username}")
        
        try:
            # Create user on all nodes
            node_count = int(self.config['node_count'])
            
            for i in range(1, node_count + 1):
                hostname = f"dgx-{i:03d}"
                
                # Create user
                exit_code, stdout, stderr = self.execute_remote_command(
                    hostname,
                    f"useradd -m -s /bin/bash {username}"
                )
                
                if exit_code != 0 and "already exists" not in stderr:
                    self.logger.error(f"Failed to create user on {hostname}: {stderr}")
                    return False
                
                # Add to groups if specified
                if groups:
                    for group in groups:
                        self.execute_remote_command(hostname, f"usermod -a -G {group} {username}")
            
            # Add to SLURM
            result = subprocess.run(
                f"sacctmgr -i create user name={username}",
                shell=True,
                capture_output=True,
                text=True
            )
            
            if result.returncode != 0:
                self.logger.warning(f"Failed to add user to SLURM: {result.stderr}")
            
            self.logger.info(f"User {username} added successfully")
            return True
        
        except Exception as e:
            self.logger.error(f"Error adding user {username}: {e}")
            return False
    
    def generate_report(self, report_type: str = 'health', output_file: str = None) -> str:
        """Generate comprehensive system report"""
        self.logger.info(f"Generating {report_type} report")
        
        if report_type == 'health':
            data = self.health_check()
        elif report_type == 'performance':
            data = self.monitor_performance(duration=300)  # 5 minute sample
        else:
            raise ValueError(f"Unknown report type: {report_type}")
        
        # Generate HTML report
        report_html = self.generate_html_report(data, report_type)
        
        if output_file:
            with open(output_file, 'w') as f:
                f.write(report_html)
            self.logger.info(f"Report saved to {output_file}")
            return output_file
        else:
            return report_html
    
    def generate_html_report(self, data: Dict, report_type: str) -> str:
        """Generate HTML report from data"""
        timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        
        html = f"""
<!DOCTYPE html>
<html>
<head>
    <title>DGX SuperPOD {report_type.capitalize()} Report</title>
    <style>
        body {{ font-family: Arial, sans-serif; margin: 20px; }}
        .header {{ background-color: #76B900; color: white; padding: 20px; border-radius: 5px; }}
        .status-healthy {{ color: #28a745; }}
        .status-warning {{ color: #ffc107; }}
        .status-critical {{ color: #dc3545; }}
        .metric-box {{ border: 1px solid #ddd; padding: 15px; margin: 10px 0; border-radius: 5px; }}
        table {{ border-collapse: collapse; width: 100%; }}
        th, td {{ border: 1px solid #ddd; padding: 8px; text-align: left; }}
        th {{ background-color: #f2f2f2; }}
    </style>
</head>
<body>
    <div class="header">
        <h1>NVIDIA DGX SuperPOD {report_type.capitalize()} Report</h1>
        <p>Generated: {timestamp}</p>
        <p>Cluster: {self.config['cluster_name']}</p>
    </div>
"""
        
        if report_type == 'health':
            html += self.generate_health_report_html(data)
        elif report_type == 'performance':
            html += self.generate_performance_report_html(data)
        
        html += """
</body>
</html>
"""
        return html
    
    def generate_health_report_html(self, data: Dict) -> str:
        """Generate HTML content for health report"""
        summary = data.get('summary', {})
        
        overall_status_class = f"status-{data['overall_status']}"
        
        html = f"""
    <div class="metric-box">
        <h2>Overall Status: <span class="{overall_status_class}">{data['overall_status'].upper()}</span></h2>
        <p>Total Nodes: {summary.get('total_nodes', 0)}</p>
        <p>Healthy Nodes: {summary.get('healthy_nodes', 0)}</p>
        <p>Warning Nodes: {summary.get('warning_nodes', 0)}</p>
        <p>Error Nodes: {summary.get('error_nodes', 0)}</p>
    </div>
    
    <div class="metric-box">
        <h2>Node Status</h2>
        <table>
            <tr>
                <th>Node</th>
                <th>Status</th>
                <th>GPUs</th>
                <th>Avg GPU Temp</th>
                <th>Memory Usage %</th>
                <th>Issues</th>
            </tr>
"""
        
        for node, info in data.get('nodes', {}).items():
            status_class = f"status-{info['status']}"
            issues = ', '.join(info.get('issues', []))
            
            html += f"""
            <tr>
                <td>{node}</td>
                <td class="{status_class}">{info['status']}</td>
                <td>{info.get('gpus', 0)}</td>
                <td>{info.get('gpu_temp_avg', 0):.1f}°C</td>
                <td>{info.get('memory_usage', 0):.1f}%</td>
                <td>{issues}</td>
            </tr>
"""
        
        html += """
        </table>
    </div>
"""
        
        return html
    
    def generate_performance_report_html(self, data: Dict) -> str:
        """Generate HTML content for performance report"""
        html = f"""
    <div class="metric-box">
        <h2>Performance Summary</h2>
        <p>Monitoring Duration: {data['duration']} seconds</p>
        <p>Start Time: {data['start_time']}</p>
        <p>End Time: {data['end_time']}</p>
    </div>
"""
        return html
    
    def cleanup(self):
        """Cleanup resources"""
        for client in self.ssh_clients.values():
            client.close()
        self.ssh_clients.clear()

def main():
    """Main function for command-line interface"""
    parser = argparse.ArgumentParser(description='DGX SuperPOD Management Tool')
    parser.add_argument('--action', required=True, 
                       choices=['health-check', 'monitor', 'add-user', 'generate-report'],
                       help='Action to perform')
    parser.add_argument('--config', help='Configuration file path')
    parser.add_argument('--duration', type=int, default=3600, help='Monitoring duration in seconds')
    parser.add_argument('--username', help='Username for user operations')
    parser.add_argument('--email', help='Email for user operations')
    parser.add_argument('--groups', nargs='+', help='Groups for user operations')
    parser.add_argument('--report-type', choices=['health', 'performance'], default='health')
    parser.add_argument('--output', help='Output file for reports')
    parser.add_argument('--verbose', '-v', action='store_true', help='Enable verbose logging')
    
    args = parser.parse_args()
    
    # Initialize manager
    manager = DGXSuperPODManager(args.config)
    
    if args.verbose:
        logging.getLogger().setLevel(logging.DEBUG)
    
    try:
        if args.action == 'health-check':
            result = manager.health_check()
            print(json.dumps(result, indent=2))
            
        elif args.action == 'monitor':
            result = manager.monitor_performance(args.duration)
            print(json.dumps(result, indent=2))
            
        elif args.action == 'add-user':
            if not args.username:
                print("Error: --username is required for add-user action")
                sys.exit(1)
            
            success = manager.add_user(args.username, args.email, args.groups)
            print(f"User addition {'successful' if success else 'failed'}")
            
        elif args.action == 'generate-report':
            output_file = args.output or f'dgx_report_{datetime.now().strftime("%Y%m%d_%H%M%S")}.html'
            manager.generate_report(args.report_type, output_file)
            print(f"Report generated: {output_file}")
    
    finally:
        manager.cleanup()

if __name__ == '__main__':
    main()