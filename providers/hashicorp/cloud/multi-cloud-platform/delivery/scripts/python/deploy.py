#!/usr/bin/env python3
"""
HashiCorp Multi-Cloud Platform - Python Deployment Script

This script deploys the HashiCorp Multi-Cloud Infrastructure Management Platform
across AWS, Azure, and Google Cloud Platform using Infrastructure as Code.

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
from typing import Dict, List, Optional, Tuple

import boto3
import click
import requests
from azure.identity import DefaultAzureCredential
from azure.mgmt.containerservice import ContainerServiceClient
from google.auth import default
from google.cloud import container_v1
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


class CloudProvider:
    """Base class for cloud provider operations"""
    
    def __init__(self, name: str, config: Dict):
        self.name = name
        self.config = config
        self.logger = logging.getLogger(f"{__name__}.{name}")
    
    def authenticate(self) -> bool:
        """Authenticate with the cloud provider"""
        raise NotImplementedError
    
    def deploy_infrastructure(self) -> bool:
        """Deploy infrastructure using Terraform"""
        raise NotImplementedError
    
    def configure_kubernetes(self) -> bool:
        """Configure Kubernetes cluster access"""
        raise NotImplementedError


class AWSProvider(CloudProvider):
    """AWS cloud provider implementation"""
    
    def __init__(self, config: Dict):
        super().__init__("aws", config)
        self.session = None
    
    def authenticate(self) -> bool:
        """Authenticate with AWS"""
        try:
            self.session = boto3.Session()
            sts = self.session.client('sts')
            identity = sts.get_caller_identity()
            
            self.logger.info(f"✓ AWS authentication successful - Account: {identity['Account']}")
            return True
        except Exception as e:
            self.logger.error(f"✗ AWS authentication failed: {e}")
            return False
    
    def deploy_infrastructure(self) -> bool:
        """Deploy AWS infrastructure with Terraform"""
        try:
            terraform_dir = Path(__file__).parent / "terraform" / "aws"
            
            # Change to Terraform directory
            os.chdir(terraform_dir)
            
            # Initialize Terraform
            self.logger.info("Initializing Terraform for AWS...")
            subprocess.run([
                "terraform", "init",
                f"-backend-config=token={os.getenv('TERRAFORM_TOKEN')}"
            ], check=True)
            
            # Create terraform.tfvars
            tfvars = {
                "project_name": self.config["project_name"],
                "environment": self.config["environment"],
                "region": self.config["cloud_providers"]["aws"]["region"],
                "vpc_cidr": self.config["cloud_providers"]["aws"]["vpc_cidr"],
                "node_count": self.config["kubernetes"]["node_count"],
                "node_instance_type": self.config["cloud_providers"]["aws"]["node_instance_type"]
            }
            
            with open("terraform.tfvars.json", "w") as f:
                json.dump(tfvars, f, indent=2)
            
            # Plan deployment
            self.logger.info("Planning Terraform deployment for AWS...")
            subprocess.run([
                "terraform", "plan",
                "-var-file=terraform.tfvars.json",
                "-out=aws.tfplan"
            ], check=True)
            
            # Apply deployment
            self.logger.info("Applying Terraform deployment for AWS...")
            subprocess.run(["terraform", "apply", "aws.tfplan"], check=True)
            
            # Extract outputs
            result = subprocess.run(
                ["terraform", "output", "-json"],
                capture_output=True, text=True, check=True
            )
            
            outputs = json.loads(result.stdout)
            with open("../outputs/aws_outputs.json", "w") as f:
                json.dump(outputs, f, indent=2)
            
            self.logger.info("✓ AWS infrastructure deployment completed")
            return True
            
        except subprocess.CalledProcessError as e:
            self.logger.error(f"✗ Terraform deployment failed for AWS: {e}")
            return False
        except Exception as e:
            self.logger.error(f"✗ AWS infrastructure deployment failed: {e}")
            return False
    
    def configure_kubernetes(self) -> bool:
        """Configure EKS cluster access"""
        try:
            cluster_name = f"{self.config['project_name']}-eks-cluster"
            region = self.config["cloud_providers"]["aws"]["region"]
            
            # Update kubeconfig
            subprocess.run([
                "aws", "eks", "update-kubeconfig",
                "--region", region,
                "--name", cluster_name
            ], check=True)
            
            # Rename context for consistency
            account_id = self.session.client('sts').get_caller_identity()['Account']
            old_context = f"arn:aws:eks:{region}:{account_id}:cluster/{cluster_name}"
            
            subprocess.run([
                "kubectl", "config", "rename-context",
                old_context, "aws-prod"
            ], check=True)
            
            # Test connectivity
            subprocess.run([
                "kubectl", "--context=aws-prod", "get", "nodes"
            ], check=True)
            
            self.logger.info("✓ AWS EKS cluster configured successfully")
            return True
            
        except subprocess.CalledProcessError as e:
            self.logger.error(f"✗ EKS cluster configuration failed: {e}")
            return False
        except Exception as e:
            self.logger.error(f"✗ AWS Kubernetes configuration failed: {e}")
            return False


class AzureProvider(CloudProvider):
    """Azure cloud provider implementation"""
    
    def __init__(self, config: Dict):
        super().__init__("azure", config)
        self.credential = None
    
    def authenticate(self) -> bool:
        """Authenticate with Azure"""
        try:
            # Test Azure CLI authentication
            result = subprocess.run(
                ["az", "account", "show"],
                capture_output=True, text=True, check=True
            )
            
            account_info = json.loads(result.stdout)
            self.logger.info(f"✓ Azure authentication successful - Subscription: {account_info['name']}")
            return True
            
        except subprocess.CalledProcessError as e:
            self.logger.error(f"✗ Azure authentication failed: {e}")
            return False
        except Exception as e:
            self.logger.error(f"✗ Azure authentication failed: {e}")
            return False
    
    def deploy_infrastructure(self) -> bool:
        """Deploy Azure infrastructure with Terraform"""
        try:
            terraform_dir = Path(__file__).parent / "terraform" / "azure"
            os.chdir(terraform_dir)
            
            # Initialize Terraform
            self.logger.info("Initializing Terraform for Azure...")
            subprocess.run([
                "terraform", "init",
                f"-backend-config=token={os.getenv('TERRAFORM_TOKEN')}"
            ], check=True)
            
            # Create terraform.tfvars
            tfvars = {
                "project_name": self.config["project_name"],
                "environment": self.config["environment"],
                "location": self.config["cloud_providers"]["azure"]["region"],
                "vnet_cidr": self.config["cloud_providers"]["azure"]["vpc_cidr"],
                "node_count": self.config["kubernetes"]["node_count"],
                "node_vm_size": self.config["cloud_providers"]["azure"]["node_instance_type"]
            }
            
            with open("terraform.tfvars.json", "w") as f:
                json.dump(tfvars, f, indent=2)
            
            # Plan and apply
            subprocess.run([
                "terraform", "plan",
                "-var-file=terraform.tfvars.json",
                "-out=azure.tfplan"
            ], check=True)
            
            subprocess.run(["terraform", "apply", "azure.tfplan"], check=True)
            
            # Extract outputs
            result = subprocess.run(
                ["terraform", "output", "-json"],
                capture_output=True, text=True, check=True
            )
            
            outputs = json.loads(result.stdout)
            with open("../outputs/azure_outputs.json", "w") as f:
                json.dump(outputs, f, indent=2)
            
            self.logger.info("✓ Azure infrastructure deployment completed")
            return True
            
        except subprocess.CalledProcessError as e:
            self.logger.error(f"✗ Terraform deployment failed for Azure: {e}")
            return False
        except Exception as e:
            self.logger.error(f"✗ Azure infrastructure deployment failed: {e}")
            return False
    
    def configure_kubernetes(self) -> bool:
        """Configure AKS cluster access"""
        try:
            cluster_name = f"{self.config['project_name']}-aks-cluster"
            resource_group = f"{self.config['project_name']}-rg"
            
            # Get AKS credentials
            subprocess.run([
                "az", "aks", "get-credentials",
                "--resource-group", resource_group,
                "--name", cluster_name,
                "--overwrite-existing"
            ], check=True)
            
            # Rename context
            subprocess.run([
                "kubectl", "config", "rename-context",
                cluster_name, "azure-prod"
            ], check=True)
            
            # Test connectivity
            subprocess.run([
                "kubectl", "--context=azure-prod", "get", "nodes"
            ], check=True)
            
            self.logger.info("✓ Azure AKS cluster configured successfully")
            return True
            
        except subprocess.CalledProcessError as e:
            self.logger.error(f"✗ AKS cluster configuration failed: {e}")
            return False
        except Exception as e:
            self.logger.error(f"✗ Azure Kubernetes configuration failed: {e}")
            return False


class GCPProvider(CloudProvider):
    """Google Cloud Platform provider implementation"""
    
    def __init__(self, config: Dict):
        super().__init__("gcp", config)
        self.credentials = None
        self.project_id = None
    
    def authenticate(self) -> bool:
        """Authenticate with GCP"""
        try:
            # Get current project
            result = subprocess.run(
                ["gcloud", "config", "get-value", "project"],
                capture_output=True, text=True, check=True
            )
            
            self.project_id = result.stdout.strip()
            self.logger.info(f"✓ GCP authentication successful - Project: {self.project_id}")
            return True
            
        except subprocess.CalledProcessError as e:
            self.logger.error(f"✗ GCP authentication failed: {e}")
            return False
        except Exception as e:
            self.logger.error(f"✗ GCP authentication failed: {e}")
            return False
    
    def deploy_infrastructure(self) -> bool:
        """Deploy GCP infrastructure with Terraform"""
        try:
            terraform_dir = Path(__file__).parent / "terraform" / "gcp"
            os.chdir(terraform_dir)
            
            # Initialize Terraform
            self.logger.info("Initializing Terraform for GCP...")
            subprocess.run([
                "terraform", "init",
                f"-backend-config=token={os.getenv('TERRAFORM_TOKEN')}"
            ], check=True)
            
            # Create terraform.tfvars
            tfvars = {
                "project_name": self.config["project_name"],
                "environment": self.config["environment"],
                "project_id": self.project_id,
                "region": self.config["cloud_providers"]["gcp"]["region"],
                "vpc_cidr": self.config["cloud_providers"]["gcp"]["vpc_cidr"],
                "node_count": self.config["kubernetes"]["node_count"],
                "node_machine_type": self.config["cloud_providers"]["gcp"]["node_instance_type"]
            }
            
            with open("terraform.tfvars.json", "w") as f:
                json.dump(tfvars, f, indent=2)
            
            # Plan and apply
            subprocess.run([
                "terraform", "plan",
                "-var-file=terraform.tfvars.json",
                "-out=gcp.tfplan"
            ], check=True)
            
            subprocess.run(["terraform", "apply", "gcp.tfplan"], check=True)
            
            # Extract outputs
            result = subprocess.run(
                ["terraform", "output", "-json"],
                capture_output=True, text=True, check=True
            )
            
            outputs = json.loads(result.stdout)
            with open("../outputs/gcp_outputs.json", "w") as f:
                json.dump(outputs, f, indent=2)
            
            self.logger.info("✓ GCP infrastructure deployment completed")
            return True
            
        except subprocess.CalledProcessError as e:
            self.logger.error(f"✗ Terraform deployment failed for GCP: {e}")
            return False
        except Exception as e:
            self.logger.error(f"✗ GCP infrastructure deployment failed: {e}")
            return False
    
    def configure_kubernetes(self) -> bool:
        """Configure GKE cluster access"""
        try:
            cluster_name = f"{self.config['project_name']}-gke-cluster"
            region = self.config["cloud_providers"]["gcp"]["region"]
            
            # Get GKE credentials
            subprocess.run([
                "gcloud", "container", "clusters", "get-credentials",
                cluster_name, "--region", region
            ], check=True)
            
            # Rename context
            old_context = f"gke_{self.project_id}_{region}_{cluster_name}"
            subprocess.run([
                "kubectl", "config", "rename-context",
                old_context, "gcp-prod"
            ], check=True)
            
            # Test connectivity
            subprocess.run([
                "kubectl", "--context=gcp-prod", "get", "nodes"
            ], check=True)
            
            self.logger.info("✓ GCP GKE cluster configured successfully")
            return True
            
        except subprocess.CalledProcessError as e:
            self.logger.error(f"✗ GKE cluster configuration failed: {e}")
            return False
        except Exception as e:
            self.logger.error(f"✗ GCP Kubernetes configuration failed: {e}")
            return False


class HashiCorpDeployer:
    """Main deployment orchestrator for HashiCorp Multi-Cloud Platform"""
    
    def __init__(self, config_file: str):
        self.config = self._load_config(config_file)
        self.providers = {}
        self.start_time = datetime.now(timezone.utc)
        
        # Initialize cloud providers
        if "aws" in self.config["cloud_providers"]:
            self.providers["aws"] = AWSProvider(self.config)
        if "azure" in self.config["cloud_providers"]:
            self.providers["azure"] = AzureProvider(self.config)
        if "gcp" in self.config["cloud_providers"]:
            self.providers["gcp"] = GCPProvider(self.config)
    
    def _load_config(self, config_file: str) -> Dict:
        """Load deployment configuration"""
        try:
            with open(config_file, 'r') as f:
                if config_file.endswith('.yaml') or config_file.endswith('.yml'):
                    config = yaml.safe_load(f)
                else:
                    config = json.load(f)
            
            logger.info(f"✓ Configuration loaded from {config_file}")
            return config
            
        except Exception as e:
            logger.error(f"✗ Failed to load configuration: {e}")
            sys.exit(1)
    
    def validate_prerequisites(self) -> bool:
        """Validate deployment prerequisites"""
        logger.info("Validating deployment prerequisites...")
        
        # Check required tools
        required_tools = [
            "terraform", "kubectl", "helm",
            "aws", "az", "gcloud"
        ]
        
        for tool in required_tools:
            try:
                result = subprocess.run([tool, "--version"], 
                                      capture_output=True, check=True)
                logger.info(f"✓ {tool.upper()} CLI found")
            except (subprocess.CalledProcessError, FileNotFoundError):
                logger.error(f"✗ {tool.upper()} CLI not found or not working")
                return False
        
        # Check environment variables
        required_vars = [
            "TERRAFORM_TOKEN", "CONSUL_ENCRYPTION_KEY", "VAULT_ROOT_TOKEN",
            "AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY",
            "AZURE_CLIENT_ID", "AZURE_CLIENT_SECRET", "AZURE_TENANT_ID",
            "GOOGLE_CREDENTIALS"
        ]
        
        for var in required_vars:
            if not os.getenv(var):
                logger.error(f"✗ Environment variable {var} is not set")
                return False
            logger.info(f"✓ Environment variable {var} is configured")
        
        logger.info("✓ All prerequisites validated successfully")
        return True
    
    def authenticate_providers(self, provider_names: List[str]) -> bool:
        """Authenticate with specified cloud providers"""
        logger.info("Authenticating with cloud providers...")
        
        for name in provider_names:
            if name in self.providers:
                if not self.providers[name].authenticate():
                    return False
        
        return True
    
    def deploy_infrastructure(self, provider_names: List[str]) -> bool:
        """Deploy infrastructure to specified cloud providers"""
        logger.info("Deploying infrastructure with Terraform...")
        
        for name in provider_names:
            if name in self.providers:
                if not self.providers[name].deploy_infrastructure():
                    return False
        
        return True
    
    def configure_kubernetes(self, provider_names: List[str]) -> bool:
        """Configure Kubernetes clusters"""
        logger.info("Configuring Kubernetes clusters...")
        
        for name in provider_names:
            if name in self.providers:
                if not self.providers[name].configure_kubernetes():
                    return False
        
        return True
    
    def deploy_hashicorp_services(self, provider_names: List[str]) -> bool:
        """Deploy HashiCorp services to Kubernetes clusters"""
        logger.info("Deploying HashiCorp services...")
        
        # Add HashiCorp Helm repository
        try:
            subprocess.run([
                "helm", "repo", "add", "hashicorp",
                "https://helm.releases.hashicorp.com"
            ], check=True)
            
            subprocess.run(["helm", "repo", "update"], check=True)
            
        except subprocess.CalledProcessError as e:
            logger.error(f"Failed to add HashiCorp Helm repository: {e}")
            return False
        
        for provider_name in provider_names:
            if not self._deploy_services_to_provider(provider_name):
                return False
        
        return True
    
    def _deploy_services_to_provider(self, provider_name: str) -> bool:
        """Deploy HashiCorp services to a specific provider"""
        context = f"{provider_name}-prod"
        
        try:
            # Create namespace
            subprocess.run([
                "kubectl", f"--context={context}",
                "create", "namespace", "hashicorp-system",
                "--dry-run=client", "-o", "yaml"
            ], stdout=subprocess.PIPE, check=True)
            
            subprocess.run([
                "kubectl", f"--context={context}",
                "apply", "-f", "-"
            ], input=subprocess.run([
                "kubectl", f"--context={context}",
                "create", "namespace", "hashicorp-system",
                "--dry-run=client", "-o", "yaml"
            ], stdout=subprocess.PIPE, check=True).stdout, check=True)
            
            # Deploy services
            services = ["consul", "vault", "terraform-enterprise"]
            
            for service in services:
                if not self._deploy_service(service, provider_name, context):
                    return False
            
            logger.info(f"✓ HashiCorp services deployed to {provider_name}")
            return True
            
        except subprocess.CalledProcessError as e:
            logger.error(f"Failed to deploy services to {provider_name}: {e}")
            return False
    
    def _deploy_service(self, service: str, provider_name: str, context: str) -> bool:
        """Deploy a specific HashiCorp service"""
        logger.info(f"Deploying {service} to {provider_name}...")
        
        # Generate Helm values based on service and provider
        values = self._generate_helm_values(service, provider_name)
        values_file = f"/tmp/{service}-values-{provider_name}.yaml"
        
        with open(values_file, 'w') as f:
            yaml.dump(values, f)
        
        try:
            # Deploy with Helm
            subprocess.run([
                "helm", f"--kube-context={context}",
                "upgrade", "--install", service,
                f"hashicorp/{service}",
                "--namespace", "hashicorp-system",
                "--values", values_file
            ], check=True)
            
            logger.info(f"✓ {service} deployed to {provider_name}")
            return True
            
        except subprocess.CalledProcessError as e:
            logger.error(f"Failed to deploy {service} to {provider_name}: {e}")
            return False
        finally:
            # Clean up values file
            if os.path.exists(values_file):
                os.remove(values_file)
    
    def _generate_helm_values(self, service: str, provider_name: str) -> Dict:
        """Generate Helm values for a service and provider"""
        versions = self.config["versions"]
        
        if service == "consul":
            return {
                "global": {
                    "name": "consul",
                    "datacenter": f"{provider_name}-dc",
                    "image": f"hashicorp/consul-enterprise:{versions['consul']}"
                },
                "server": {
                    "replicas": 3,
                    "bootstrapExpect": 3,
                    "enterprise": {"enabled": True},
                    "connect": {"enabled": True}
                },
                "ui": {
                    "enabled": True,
                    "service": {"type": "LoadBalancer"}
                }
            }
        
        elif service == "vault":
            return {
                "global": {"enabled": True},
                "server": {
                    "image": {
                        "repository": "hashicorp/vault-enterprise",
                        "tag": versions["vault"]
                    },
                    "ha": {"enabled": True, "replicas": 3}
                },
                "ui": {
                    "enabled": True,
                    "serviceType": "LoadBalancer"
                }
            }
        
        elif service == "terraform-enterprise":
            return {
                "tfe": {
                    "image": {"tag": versions["terraform_enterprise"]},
                    "hostname": f"tfe-{provider_name}.company.com",
                    "resources": {
                        "requests": {"cpu": "2", "memory": "4Gi"},
                        "limits": {"cpu": "4", "memory": "8Gi"}
                    }
                },
                "service": {"type": "LoadBalancer"}
            }
        
        return {}
    
    def validate_deployment(self, provider_names: List[str]) -> bool:
        """Validate the deployment"""
        logger.info("Validating deployment...")
        
        for provider_name in provider_names:
            context = f"{provider_name}-prod"
            
            try:
                # Check pod status
                result = subprocess.run([
                    "kubectl", f"--context={context}",
                    "get", "pods", "-n", "hashicorp-system",
                    "-o", "json"
                ], capture_output=True, text=True, check=True)
                
                pods = json.loads(result.stdout)
                running_pods = sum(1 for pod in pods["items"] 
                                 if pod["status"]["phase"] == "Running")
                total_pods = len(pods["items"])
                
                logger.info(f"Pod status for {provider_name}: {running_pods}/{total_pods} running")
                
                # Test service endpoints
                tfe_url = f"https://tfe-{provider_name}.company.com/_health_check"
                try:
                    response = requests.get(tfe_url, timeout=30)
                    if response.status_code == 200:
                        logger.info(f"✓ TFE health check passed for {provider_name}")
                    else:
                        logger.warning(f"⚠ TFE health check failed for {provider_name}: {response.status_code}")
                except requests.RequestException as e:
                    logger.warning(f"⚠ TFE health check failed for {provider_name}: {e}")
                
            except subprocess.CalledProcessError as e:
                logger.error(f"Validation failed for {provider_name}: {e}")
                return False
        
        logger.info("✓ Deployment validation completed")
        return True
    
    def generate_report(self, provider_names: List[str], success: bool) -> None:
        """Generate deployment report"""
        end_time = datetime.now(timezone.utc)
        duration = end_time - self.start_time
        
        report = {
            "deployment_id": f"hcp-{int(self.start_time.timestamp())}",
            "timestamp": end_time.isoformat(),
            "duration": str(duration),
            "cloud_providers": provider_names,
            "environment": self.config["environment"],
            "success": success,
            "components": {
                "terraform_enterprise": {
                    "version": self.config["versions"]["terraform_enterprise"],
                    "endpoints": [f"https://tfe-{p}.company.com" for p in provider_names]
                },
                "consul": {
                    "version": self.config["versions"]["consul"],
                    "datacenters": [f"{p}-dc" for p in provider_names]
                },
                "vault": {
                    "version": self.config["versions"]["vault"],
                    "clusters": [f"{p}-vault" for p in provider_names]
                }
            }
        }
        
        report_file = f"deployment-report-{datetime.now().strftime('%Y%m%d-%H%M%S')}.json"
        with open(report_file, 'w') as f:
            json.dump(report, f, indent=2)
        
        # Display summary
        print("\n" + "="*60)
        print("HashiCorp Multi-Cloud Platform Deployment Summary")
        print("="*60)
        print(f"Status: {'SUCCESS' if success else 'FAILED'}")
        print(f"Duration: {duration}")
        print(f"Cloud Providers: {', '.join(provider_names)}")
        print(f"Environment: {self.config['environment']}")
        print("\nComponents Deployed:")
        for provider in provider_names:
            print(f"  {provider}: https://tfe-{provider}.company.com")
        print(f"\nReport File: {report_file}")
        print("="*60 + "\n")


@click.command()
@click.option('--provider', '-p', 
              type=click.Choice(['aws', 'azure', 'gcp', 'all']),
              default='all',
              help='Cloud provider to deploy to')
@click.option('--config', '-c',
              default='deployment-config.yaml',
              help='Configuration file path')
@click.option('--validate-only', '-v',
              is_flag=True,
              help='Only validate configuration and prerequisites')
@click.option('--skip-prerequisites', '-s',
              is_flag=True,
              help='Skip prerequisites validation')
def deploy(provider, config, validate_only, skip_prerequisites):
    """Deploy HashiCorp Multi-Cloud Infrastructure Management Platform"""
    
    click.echo("HashiCorp Multi-Cloud Platform - Python Deployment Script")
    click.echo("=" * 60)
    
    try:
        # Initialize deployer
        deployer = HashiCorpDeployer(config)
        
        # Determine providers to deploy
        if provider == 'all':
            provider_names = list(deployer.providers.keys())
        else:
            provider_names = [provider] if provider in deployer.providers else []
        
        if not provider_names:
            logger.error(f"No valid providers found for: {provider}")
            sys.exit(1)
        
        logger.info(f"Deploying to providers: {', '.join(provider_names)}")
        
        # Validate prerequisites
        if not skip_prerequisites:
            if not deployer.validate_prerequisites():
                logger.error("Prerequisites validation failed")
                sys.exit(1)
        
        # Authenticate with cloud providers
        if not deployer.authenticate_providers(provider_names):
            logger.error("Cloud provider authentication failed")
            sys.exit(1)
        
        # Deploy infrastructure
        if not deployer.deploy_infrastructure(provider_names):
            logger.error("Infrastructure deployment failed")
            deployer.generate_report(provider_names, False)
            sys.exit(1)
        
        if not validate_only:
            # Configure Kubernetes
            if not deployer.configure_kubernetes(provider_names):
                logger.error("Kubernetes configuration failed")
                deployer.generate_report(provider_names, False)
                sys.exit(1)
            
            # Deploy HashiCorp services
            if not deployer.deploy_hashicorp_services(provider_names):
                logger.error("HashiCorp services deployment failed")
                deployer.generate_report(provider_names, False)
                sys.exit(1)
            
            # Validate deployment
            deployer.validate_deployment(provider_names)
        
        # Generate success report
        deployer.generate_report(provider_names, True)
        logger.info("Deployment completed successfully!")
        
    except Exception as e:
        logger.error(f"Deployment failed: {e}")
        sys.exit(1)


if __name__ == '__main__':
    deploy()