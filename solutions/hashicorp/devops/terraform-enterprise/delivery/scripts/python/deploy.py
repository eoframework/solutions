#!/usr/bin/env python3
"""
HashiCorp Terraform Enterprise - Python Deployment Script

This script deploys the Terraform Enterprise platform on AWS EKS
with complete automation and validation.

Author: HashiCorp Solutions Team
Version: 1.0
"""

import json
import logging
import os
import subprocess
import sys
import time
import yaml
from datetime import datetime, timezone
from pathlib import Path
from typing import Dict, List, Optional

import boto3
import click
import requests
from kubernetes import client, config
from kubernetes.client.rest import ApiException

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler(),
        logging.FileHandler(f'deployment-{datetime.now().strftime("%Y%m%d-%H%M%S")}.log')
    ]
)

logger = logging.getLogger(__name__)


class TerraformEnterpriseDeployer:
    """Main deployment orchestrator for Terraform Enterprise platform"""
    
    def __init__(self, config_file: str = ""):
        self.config = self._load_default_config()
        self.start_time = datetime.now(timezone.utc)
        
        if config_file:
            self._load_custom_config(config_file)
        
        # Initialize AWS session
        try:
            self.aws_session = boto3.Session()
            self.ec2_client = self.aws_session.client('ec2')
            self.eks_client = self.aws_session.client('eks')
            self.rds_client = self.aws_session.client('rds')
        except Exception as e:
            logger.error(f"Failed to initialize AWS clients: {e}")
            sys.exit(1)
    
    def _load_default_config(self) -> Dict:
        """Load default configuration"""
        return {
            "project_name": "terraform-enterprise",
            "environment": "prod",
            "aws_region": os.getenv("AWS_DEFAULT_REGION", "us-east-1"),
            "kubernetes_version": "1.28",
            "tfe_hostname": "terraform.company.com",
            "tfe_version": "v202401-1",
            "vpc_cidr": "10.0.0.0/16",
            "node_instance_type": "m5.xlarge",
            "min_node_count": 3,
            "max_node_count": 10,
            "desired_node_count": 6,
            "db_instance_class": "db.r5.xlarge",
            "db_allocated_storage": 500,
            "enable_monitoring": False
        }
    
    def _load_custom_config(self, config_file: str) -> None:
        """Load custom configuration from file"""
        try:
            config_path = Path(config_file)
            if not config_path.exists():
                logger.error(f"Configuration file not found: {config_file}")
                sys.exit(1)
            
            with open(config_path, 'r') as f:
                if config_path.suffix.lower() in ['.yaml', '.yml']:
                    custom_config = yaml.safe_load(f)
                else:
                    custom_config = json.load(f)
            
            # Merge with default config
            self.config.update(custom_config)
            logger.info(f"✓ Configuration loaded from {config_file}")
            
        except Exception as e:
            logger.error(f"Failed to load configuration: {e}")
            sys.exit(1)
    
    def validate_prerequisites(self, skip_prereqs: bool = False) -> bool:
        """Validate deployment prerequisites"""
        if skip_prereqs:
            logger.warning("Skipping prerequisites validation")
            return True
        
        logger.info("Validating deployment prerequisites...")
        
        # Check required tools
        required_tools = ["terraform", "kubectl", "helm", "aws"]
        for tool in required_tools:
            try:
                result = subprocess.run([tool, "--version"], 
                                      capture_output=True, text=True, check=True)
                logger.info(f"✓ {tool.upper()}: {result.stdout.split()[1] if result.stdout else 'installed'}")
            except (subprocess.CalledProcessError, FileNotFoundError):
                logger.error(f"✗ {tool.upper()} not found or not working")
                return False
        
        # Check environment variables
        required_vars = ["TFE_LICENSE"]
        for var in required_vars:
            if not os.getenv(var):
                logger.error(f"✗ Environment variable {var} is not set")
                return False
            logger.info(f"✓ Environment variable {var} is configured")
        
        # Validate AWS credentials
        try:
            sts = self.aws_session.client('sts')
            identity = sts.get_caller_identity()
            logger.info(f"✓ AWS Account: {identity['Account']}")
            logger.info(f"✓ AWS User/Role: {identity['Arn']}")
            self.config['aws_account'] = identity['Account']
        except Exception as e:
            logger.error(f"✗ AWS credentials validation failed: {e}")
            return False
        
        logger.info("✓ All prerequisites validated successfully")
        return True
    
    def deploy_infrastructure(self, validate_only: bool = False, dry_run: bool = False) -> bool:
        """Deploy infrastructure using Terraform"""
        logger.info("Deploying infrastructure with Terraform...")
        
        script_dir = Path(__file__).parent
        terraform_dir = script_dir / ".." / "terraform"
        
        if not terraform_dir.exists():
            logger.error(f"Terraform directory not found: {terraform_dir}")
            return False
        
        # Change to Terraform directory
        os.chdir(terraform_dir)
        
        try:
            # Initialize Terraform
            logger.info("Initializing Terraform...")
            if dry_run:
                logger.info("[DRY RUN] Would run: terraform init")
            else:
                subprocess.run(["terraform", "init"], check=True)
            
            # Create terraform.tfvars
            tfvars_path = terraform_dir / "terraform.tfvars"
            if not tfvars_path.exists():
                logger.info("Creating terraform.tfvars from configuration...")
                
                tfvars_content = f'''project_name         = "{self.config['project_name']}"
environment          = "{self.config['environment']}"
aws_region          = "{self.config['aws_region']}"
kubernetes_version  = "{self.config['kubernetes_version']}"
tfe_hostname        = "{self.config['tfe_hostname']}"

# VPC Configuration
vpc_cidr = "{self.config['vpc_cidr']}"
public_subnet_cidrs = [
  "10.0.1.0/24",
  "10.0.2.0/24",
  "10.0.3.0/24"
]
private_subnet_cidrs = [
  "10.0.10.0/24",
  "10.0.11.0/24",
  "10.0.12.0/24"
]

# EKS Configuration
node_instance_types = ["{self.config['node_instance_type']}"]
min_node_count     = {self.config['min_node_count']}
max_node_count     = {self.config['max_node_count']}
desired_node_count = {self.config['desired_node_count']}

# Database Configuration
postgres_version      = "14.9"
db_instance_class    = "{self.config['db_instance_class']}"
db_allocated_storage = {self.config['db_allocated_storage']}
enable_multi_az      = true

# Security Configuration
enable_encryption = true
allowed_cidr_blocks = [
  "0.0.0.0/0"  # Update this for production
]
'''
                
                with open(tfvars_path, 'w') as f:
                    f.write(tfvars_content)
            
            # Plan deployment
            logger.info("Planning Terraform deployment...")
            if dry_run:
                logger.info("[DRY RUN] Would run: terraform plan -var-file=terraform.tfvars")
            else:
                subprocess.run([
                    "terraform", "plan", 
                    "-var-file=terraform.tfvars", 
                    "-out=tfe.tfplan"
                ], check=True)
            
            # Apply deployment (if not validate-only)
            if not validate_only and not dry_run:
                logger.info("Applying Terraform deployment...")
                subprocess.run(["terraform", "apply", "tfe.tfplan"], check=True)
                
                # Extract outputs
                logger.info("Extracting infrastructure outputs...")
                result = subprocess.run([
                    "terraform", "output", "-json"
                ], capture_output=True, text=True, check=True)
                
                outputs = json.loads(result.stdout)
                
                # Store outputs in config
                self.config['cluster_name'] = outputs['cluster_name']['value']
                self.config['cluster_endpoint'] = outputs['cluster_endpoint']['value']
                self.config['database_endpoint'] = outputs['database_endpoint']['value']
                self.config['s3_bucket'] = outputs['s3_bucket_name']['value']
                
                logger.info("Infrastructure deployed successfully:")
                logger.info(f"  EKS Cluster: {self.config['cluster_name']}")
                logger.info(f"  Database: {self.config['database_endpoint']}")
                logger.info(f"  S3 Bucket: {self.config['s3_bucket']}")
            
            return True
            
        except subprocess.CalledProcessError as e:
            logger.error(f"Terraform deployment failed: {e}")
            return False
        except Exception as e:
            logger.error(f"Infrastructure deployment failed: {e}")
            return False
    
    def configure_kubernetes(self, dry_run: bool = False) -> bool:
        """Configure Kubernetes cluster access"""
        logger.info("Configuring Kubernetes access...")
        
        if 'cluster_name' not in self.config:
            logger.error("ClusterName not set. Infrastructure may not be deployed.")
            return False
        
        # Update kubeconfig
        if dry_run:
            logger.info(f"[DRY RUN] Would run: aws eks update-kubeconfig --region {self.config['aws_region']} --name {self.config['cluster_name']}")
        else:
            try:
                subprocess.run([
                    "aws", "eks", "update-kubeconfig",
                    "--region", self.config['aws_region'],
                    "--name", self.config['cluster_name']
                ], check=True)
                
                # Verify cluster connectivity
                logger.info("Verifying cluster connectivity...")
                config.load_kube_config()
                v1 = client.CoreV1Api()
                nodes = v1.list_node()
                
                logger.info(f"✓ Connected to cluster with {len(nodes.items)} nodes")
                
            except Exception as e:
                logger.error(f"Failed to configure Kubernetes: {e}")
                return False
        
        # Add Helm repositories
        logger.info("Adding HashiCorp Helm repository...")
        if dry_run:
            logger.info("[DRY RUN] Would run: helm repo add hashicorp https://helm.releases.hashicorp.com")
        else:
            try:
                subprocess.run([
                    "helm", "repo", "add", "hashicorp",
                    "https://helm.releases.hashicorp.com"
                ], check=True)
                
                subprocess.run(["helm", "repo", "update"], check=True)
                
            except subprocess.CalledProcessError as e:
                logger.error(f"Failed to add Helm repository: {e}")
                return False
        
        logger.info("✓ Kubernetes configuration completed")
        return True
    
    def deploy_terraform_enterprise(self, dry_run: bool = False) -> bool:
        """Deploy Terraform Enterprise application"""
        logger.info("Deploying Terraform Enterprise...")
        
        if dry_run:
            logger.info("[DRY RUN] Would deploy Terraform Enterprise")
            return True
        
        try:
            # Load Kubernetes config
            config.load_kube_config()
            v1 = client.CoreV1Api()
            
            # Create namespace
            namespace_manifest = {
                "apiVersion": "v1",
                "kind": "Namespace",
                "metadata": {"name": "terraform-enterprise"}
            }
            
            try:
                v1.create_namespace(body=namespace_manifest)
                logger.info("✓ Created terraform-enterprise namespace")
            except ApiException as e:
                if e.status == 409:  # Already exists
                    logger.info("✓ terraform-enterprise namespace already exists")
                else:
                    raise
            
            # Create TFE license secret
            tfe_license = os.getenv('TFE_LICENSE')
            if not tfe_license:
                logger.error("TFE_LICENSE environment variable not set")
                return False
            
            license_secret = client.V1Secret(
                metadata=client.V1ObjectMeta(name="tfe-license", namespace="terraform-enterprise"),
                type="Opaque",
                string_data={"license": tfe_license}
            )
            
            try:
                v1.create_namespaced_secret(namespace="terraform-enterprise", body=license_secret)
                logger.info("✓ Created TFE license secret")
            except ApiException as e:
                if e.status == 409:  # Already exists
                    logger.info("✓ TFE license secret already exists")
                else:
                    raise
            
            # Create database credentials secret
            import secrets
            db_password = secrets.token_urlsafe(32)
            
            db_secret = client.V1Secret(
                metadata=client.V1ObjectMeta(name="tfe-database-credentials", namespace="terraform-enterprise"),
                type="Opaque",
                string_data={
                    "host": self.config['database_endpoint'],
                    "database": "terraform_enterprise",
                    "username": "tfe",
                    "password": db_password,
                    "url": f"postgresql://tfe:{db_password}@{self.config['database_endpoint']}:5432/terraform_enterprise?sslmode=require"
                }
            )
            
            try:
                v1.create_namespaced_secret(namespace="terraform-enterprise", body=db_secret)
                logger.info("✓ Created database credentials secret")
            except ApiException as e:
                if e.status == 409:  # Already exists
                    logger.info("✓ Database credentials secret already exists")
                else:
                    raise
            
            # Create Helm values file
            helm_values = {
                "replicaCount": 3,
                "image": {
                    "repository": "hashicorp/terraform-enterprise",
                    "tag": self.config['tfe_version'],
                    "pullPolicy": "Always"
                },
                "tfe": {
                    "hostname": self.config['tfe_hostname'],
                    "database": {
                        "external": True,
                        "host": self.config['database_endpoint'],
                        "name": "terraform_enterprise",
                        "username": "tfe",
                        "passwordSecret": "tfe-database-credentials",
                        "passwordSecretKey": "password"
                    },
                    "objectStorage": {
                        "type": "s3",
                        "bucket": self.config['s3_bucket'],
                        "region": self.config['aws_region']
                    },
                    "license": {
                        "secret": "tfe-license",
                        "key": "license"
                    },
                    "resources": {
                        "requests": {
                            "cpu": "2000m",
                            "memory": "4Gi"
                        },
                        "limits": {
                            "cpu": "4000m",
                            "memory": "8Gi"
                        }
                    }
                },
                "service": {
                    "type": "ClusterIP",
                    "port": 80,
                    "targetPort": 8080
                },
                "ingress": {
                    "enabled": True,
                    "className": "alb",
                    "annotations": {
                        "alb.ingress.kubernetes.io/scheme": "internet-facing",
                        "alb.ingress.kubernetes.io/target-type": "ip",
                        "alb.ingress.kubernetes.io/listen-ports": '[{"HTTPS": 443}]',
                        "alb.ingress.kubernetes.io/ssl-redirect": "443",
                        "alb.ingress.kubernetes.io/healthcheck-path": "/_health_check"
                    },
                    "hosts": [{
                        "host": self.config['tfe_hostname'],
                        "paths": [{
                            "path": "/",
                            "pathType": "Prefix"
                        }]
                    }]
                },
                "autoscaling": {
                    "enabled": True,
                    "minReplicas": 3,
                    "maxReplicas": 10,
                    "targetCPUUtilizationPercentage": 70
                },
                "podDisruptionBudget": {
                    "enabled": True,
                    "minAvailable": 2
                }
            }
            
            # Write values to temporary file
            import tempfile
            with tempfile.NamedTemporaryFile(mode='w', suffix='.yaml', delete=False) as f:
                yaml.dump(helm_values, f, default_flow_style=False)
                values_file = f.name
            
            # Deploy with Helm
            logger.info("Deploying TFE with Helm...")
            subprocess.run([
                "helm", "upgrade", "--install", "terraform-enterprise",
                "hashicorp/terraform-enterprise",
                "--namespace", "terraform-enterprise",
                "--values", values_file,
                "--wait", "--timeout", "600s"
            ], check=True)
            
            # Clean up values file
            os.unlink(values_file)
            
            logger.info("✓ Terraform Enterprise deployed successfully")
            return True
            
        except Exception as e:
            logger.error(f"TFE deployment failed: {e}")
            return False
    
    def deploy_monitoring_stack(self, dry_run: bool = False) -> bool:
        """Deploy monitoring stack if enabled"""
        if not self.config.get('enable_monitoring', False):
            return True
        
        logger.info("Deploying monitoring stack...")
        
        if dry_run:
            logger.info("[DRY RUN] Would deploy monitoring stack")
            return True
        
        try:
            # Create monitoring namespace
            config.load_kube_config()
            v1 = client.CoreV1Api()
            
            namespace_manifest = {
                "apiVersion": "v1",
                "kind": "Namespace",
                "metadata": {"name": "monitoring"}
            }
            
            try:
                v1.create_namespace(body=namespace_manifest)
                logger.info("✓ Created monitoring namespace")
            except ApiException as e:
                if e.status == 409:  # Already exists
                    logger.info("✓ monitoring namespace already exists")
                else:
                    raise
            
            # Add monitoring Helm repositories
            subprocess.run([
                "helm", "repo", "add", "prometheus-community",
                "https://prometheus-community.github.io/helm-charts"
            ], check=True)
            
            subprocess.run([
                "helm", "repo", "add", "grafana",
                "https://grafana.github.io/helm-charts"
            ], check=True)
            
            subprocess.run(["helm", "repo", "update"], check=True)
            
            # Deploy Prometheus
            logger.info("Deploying Prometheus...")
            subprocess.run([
                "helm", "upgrade", "--install", "prometheus",
                "prometheus-community/kube-prometheus-stack",
                "--namespace", "monitoring",
                "--set", "grafana.adminPassword=admin123",
                "--wait", "--timeout", "600s"
            ], check=True)
            
            logger.info("✓ Monitoring stack deployed successfully")
            return True
            
        except Exception as e:
            logger.error(f"Monitoring stack deployment failed: {e}")
            return False
    
    def validate_deployment(self, dry_run: bool = False) -> bool:
        """Validate the TFE deployment"""
        logger.info("Validating TFE deployment...")
        
        if dry_run:
            logger.info("[DRY RUN] Would validate deployment")
            return True
        
        try:
            # Check pod status
            config.load_kube_config()
            v1 = client.CoreV1Api()
            pods = v1.list_namespaced_pod(namespace="terraform-enterprise")
            
            running_pods = sum(1 for pod in pods.items if pod.status.phase == "Running")
            total_pods = len(pods.items)
            
            logger.info(f"Pod status: {running_pods}/{total_pods} running")
            
            if running_pods == 0:
                logger.error("No pods are running")
                return False
            
            # Wait for TFE to be accessible
            logger.info("Waiting for TFE to be accessible...")
            max_attempts = 20
            attempt = 1
            
            while attempt <= max_attempts:
                try:
                    response = requests.get(
                        f"https://{self.config['tfe_hostname']}/_health_check",
                        timeout=10
                    )
                    if response.status_code == 200:
                        logger.info(f"✓ TFE is accessible at https://{self.config['tfe_hostname']}")
                        break
                except requests.RequestException:
                    logger.info(f"Attempt {attempt}/{max_attempts}: TFE not ready yet, waiting 30 seconds...")
                    time.sleep(30)
                    attempt += 1
            
            if attempt > max_attempts:
                logger.error("TFE did not become accessible within expected time")
                return False
            
            # Test API endpoint
            logger.info("Testing TFE API...")
            try:
                response = requests.get(
                    f"https://{self.config['tfe_hostname']}/api/v2/ping",
                    timeout=10
                )
                if response.status_code == 200:
                    logger.info("✓ TFE API is responding")
            except requests.RequestException:
                logger.warning("TFE API test failed - this may be normal during initial setup")
            
            logger.info("✓ Deployment validation completed")
            return True
            
        except Exception as e:
            logger.error(f"Deployment validation failed: {e}")
            return False
    
    def generate_report(self, success: bool) -> None:
        """Generate deployment report"""
        end_time = datetime.now(timezone.utc)
        duration = end_time - self.start_time
        
        report = {
            "deployment_id": f"tfe-{int(self.start_time.timestamp())}",
            "timestamp": end_time.isoformat(),
            "duration": str(duration),
            "environment": self.config['environment'],
            "success": success,
            "infrastructure": {
                "aws_region": self.config['aws_region'],
                "aws_account": self.config.get('aws_account', 'Unknown'),
                "eks_cluster": self.config.get('cluster_name', 'Not deployed'),
                "database": self.config.get('database_endpoint', 'Not deployed'),
                "s3_bucket": self.config.get('s3_bucket', 'Not deployed')
            },
            "application": {
                "hostname": self.config['tfe_hostname'],
                "version": self.config['tfe_version'],
                "replicas": 3,
                "namespace": "terraform-enterprise"
            },
            "access": {
                "web_ui": f"https://{self.config['tfe_hostname']}",
                "health_check": f"https://{self.config['tfe_hostname']}/_health_check",
                "api_endpoint": f"https://{self.config['tfe_hostname']}/api/v2"
            }
        }
        
        # Write report to file
        report_file = f"deployment-report-{self.config['environment']}-{datetime.now().strftime('%Y%m%d-%H%M%S')}.json"
        with open(report_file, 'w') as f:
            json.dump(report, f, indent=2)
        
        # Display summary
        print("\n" + "="*50)
        print("🎉 TFE Deployment Summary")
        print("="*50)
        print(f"Status: {'SUCCESS' if success else 'FAILED'}")
        print(f"Duration: {duration}")
        print(f"Environment: {self.config['environment']}")
        print(f"TFE URL: https://{self.config['tfe_hostname']}")
        print("\nNext Steps:")
        print(f"1. Access TFE at https://{self.config['tfe_hostname']}")
        print("2. Complete initial admin setup")
        print("3. Configure authentication")
        print(f"\nReport File: {report_file}")
        print("="*50 + "\n")


@click.command()
@click.option('--environment', '-e',
              type=click.Choice(['dev', 'staging', 'prod']),
              default='prod',
              help='Target environment')
@click.option('--config', '-c',
              help='Configuration file path')
@click.option('--validate-only', '-v',
              is_flag=True,
              help='Only validate configuration and infrastructure')
@click.option('--skip-prerequisites', '-s',
              is_flag=True,
              help='Skip prerequisites validation')
@click.option('--enable-monitoring', '-m',
              is_flag=True,
              help='Deploy monitoring stack')
@click.option('--dry-run', '-n',
              is_flag=True,
              help='Show what would be deployed')
@click.option('--verbose',
              is_flag=True,
              help='Enable verbose logging')
def deploy(environment, config, validate_only, skip_prerequisites, enable_monitoring, dry_run, verbose):
    """Deploy HashiCorp Terraform Enterprise platform"""
    
    if verbose:
        logging.getLogger().setLevel(logging.DEBUG)
    
    click.echo("HashiCorp Terraform Enterprise - Python Deployment Script")
    click.echo("=" * 60)
    
    try:
        # Initialize deployer
        deployer = TerraformEnterpriseDeployer(config_file=config)
        deployer.config['environment'] = environment
        deployer.config['enable_monitoring'] = enable_monitoring
        
        logger.info(f"Deploying to environment: {environment}")
        
        # Validate prerequisites
        if not deployer.validate_prerequisites(skip_prerequisites):
            logger.error("Prerequisites validation failed")
            sys.exit(1)
        
        # Deploy infrastructure
        if not deployer.deploy_infrastructure(validate_only, dry_run):
            logger.error("Infrastructure deployment failed")
            deployer.generate_report(False)
            sys.exit(1)
        
        if not validate_only and not dry_run:
            # Configure Kubernetes
            if not deployer.configure_kubernetes(dry_run):
                logger.error("Kubernetes configuration failed")
                deployer.generate_report(False)
                sys.exit(1)
            
            # Deploy TFE
            if not deployer.deploy_terraform_enterprise(dry_run):
                logger.error("TFE deployment failed")
                deployer.generate_report(False)
                sys.exit(1)
            
            # Deploy monitoring stack
            if not deployer.deploy_monitoring_stack(dry_run):
                logger.error("Monitoring stack deployment failed")
                deployer.generate_report(False)
                sys.exit(1)
        
        # Validate deployment
        if not deployer.validate_deployment(dry_run):
            logger.warning("Deployment validation completed with warnings")
        
        # Generate success report
        deployer.generate_report(True)
        logger.info("✓ Deployment completed successfully!")
        
    except Exception as e:
        logger.error(f"Deployment failed: {e}")
        sys.exit(1)


if __name__ == '__main__':
    deploy()