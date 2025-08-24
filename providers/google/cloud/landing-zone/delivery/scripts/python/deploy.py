#!/usr/bin/env python3
"""
Google Cloud Landing Zone Deployment Script

This script automates the deployment of Google Cloud Landing Zone infrastructure
using Terraform and Google Cloud APIs.

Requirements:
    - Google Cloud SDK (gcloud)
    - Terraform >= 1.5.0
    - Python 3.8+
    - Required Python packages (see requirements.txt)

Usage:
    python deploy.py --project-id my-project --organization-id 123456789 --billing-account ABCD-1234
"""

import argparse
import json
import logging
import os
import subprocess
import sys
import time
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional, Tuple

import yaml
from google.cloud import resource_manager_v3
from google.cloud import billing_v1
from google.cloud import compute_v1
from google.cloud.exceptions import NotFound, GoogleCloudError

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler(sys.stdout),
        logging.FileHandler(f'deployment_{datetime.now().strftime("%Y%m%d_%H%M%S")}.log')
    ]
)
logger = logging.getLogger(__name__)

class DeploymentError(Exception):
    """Custom exception for deployment errors"""
    pass

class GoogleCloudLandingZoneDeployment:
    """Main deployment class for Google Cloud Landing Zone"""
    
    def __init__(self, project_id: str, organization_id: str, billing_account_id: str,
                 region: str = "us-central1", environment: str = "prod",
                 config_file: str = "terraform.tfvars", auto_approve: bool = False):
        """
        Initialize deployment configuration
        
        Args:
            project_id: Google Cloud project ID
            organization_id: Google Cloud organization ID
            billing_account_id: Billing account ID
            region: Deployment region
            environment: Environment name (dev, staging, prod)
            config_file: Terraform configuration file
            auto_approve: Auto-approve Terraform changes
        """
        self.project_id = project_id
        self.organization_id = organization_id
        self.billing_account_id = billing_account_id
        self.region = region
        self.environment = environment
        self.config_file = config_file
        self.auto_approve = auto_approve
        
        # Setup paths
        self.script_dir = Path(__file__).parent.absolute()
        self.terraform_dir = self.script_dir.parent / "terraform"
        self.config_path = self.terraform_dir / config_file
        
        # Initialize Google Cloud clients
        self._init_gcp_clients()
        
        # Deployment state
        self.deployment_start_time = datetime.now()
        self.deployment_report = {
            "timestamp": self.deployment_start_time.isoformat(),
            "project_id": project_id,
            "organization_id": organization_id,
            "region": region,
            "environment": environment,
            "status": "started"
        }
    
    def _init_gcp_clients(self):
        """Initialize Google Cloud API clients"""
        try:
            self.resource_manager_client = resource_manager_v3.ProjectsClient()
            self.billing_client = billing_v1.CloudBillingClient()
            self.compute_client = compute_v1.NetworksClient()
            logger.info("Initialized Google Cloud API clients")
        except Exception as e:
            logger.error(f"Failed to initialize Google Cloud clients: {e}")
            raise DeploymentError(f"Client initialization failed: {e}")
    
    def check_prerequisites(self) -> bool:
        """
        Check all prerequisites for deployment
        
        Returns:
            bool: True if all prerequisites are met
        """
        logger.info("Checking deployment prerequisites...")
        
        # Check Google Cloud SDK
        try:
            result = subprocess.run(['gcloud', '--version'], capture_output=True, text=True)
            if result.returncode != 0:
                raise DeploymentError("Google Cloud SDK not found")
            logger.info("Google Cloud SDK is available")
        except FileNotFoundError:
            raise DeploymentError("Google Cloud SDK not installed")
        
        # Check Terraform
        try:
            result = subprocess.run(['terraform', '--version'], capture_output=True, text=True)
            if result.returncode != 0:
                raise DeploymentError("Terraform not found")
            version_info = result.stdout.strip().split('\n')[0]
            logger.info(f"Terraform is available: {version_info}")
        except FileNotFoundError:
            raise DeploymentError("Terraform not installed")
        
        # Check authentication
        try:
            result = subprocess.run(['gcloud', 'auth', 'list', '--format=json'], 
                                  capture_output=True, text=True)
            auth_accounts = json.loads(result.stdout)
            if not auth_accounts:
                raise DeploymentError("No authenticated Google Cloud accounts found")
            logger.info(f"Authenticated as: {auth_accounts[0]['account']}")
        except (json.JSONDecodeError, KeyError, IndexError):
            raise DeploymentError("Failed to check Google Cloud authentication")
        
        # Check configuration file
        if not self.config_path.exists():
            raise DeploymentError(f"Configuration file not found: {self.config_path}")
        
        # Check Terraform directory
        if not self.terraform_dir.exists():
            raise DeploymentError(f"Terraform directory not found: {self.terraform_dir}")
        
        logger.info("All prerequisites check passed")
        return True
    
    def validate_configuration(self) -> bool:
        """
        Validate Terraform configuration file
        
        Returns:
            bool: True if configuration is valid
        """
        logger.info("Validating Terraform configuration...")
        
        try:
            # Read configuration file
            with open(self.config_path, 'r') as f:
                config_content = f.read()
            
            # Check required variables
            required_vars = [
                'project_id', 'organization_id', 'billing_account_id', 'region'
            ]
            
            for var in required_vars:
                if f'{var} =' not in config_content:
                    raise DeploymentError(f"Required variable '{var}' not found in configuration")
            
            # Validate project ID format
            import re
            project_id_pattern = r'^[a-z][-a-z0-9]{5,29}$'
            if not re.match(project_id_pattern, self.project_id):
                raise DeploymentError(f"Invalid project ID format: {self.project_id}")
            
            logger.info("Configuration validation passed")
            return True
            
        except Exception as e:
            raise DeploymentError(f"Configuration validation failed: {e}")
    
    def setup_google_cloud_project(self) -> bool:
        """
        Setup Google Cloud project and enable required APIs
        
        Returns:
            bool: True if setup successful
        """
        logger.info("Setting up Google Cloud project...")
        
        try:
            # Set active project
            subprocess.run(['gcloud', 'config', 'set', 'project', self.project_id], 
                          check=True, capture_output=True)
            logger.info(f"Set active project to: {self.project_id}")
            
            # Check if project exists
            try:
                project_resource_name = f"projects/{self.project_id}"
                project = self.resource_manager_client.get_project(
                    name=project_resource_name
                )
                logger.info(f"Project already exists: {project.display_name}")
            except NotFound:
                logger.info(f"Creating project: {self.project_id}")
                self._create_project()
            
            # Link billing account
            self._link_billing_account()
            
            # Enable required APIs
            self._enable_required_apis()
            
            logger.info("Google Cloud project setup completed")
            return True
            
        except Exception as e:
            raise DeploymentError(f"Project setup failed: {e}")
    
    def _create_project(self):
        """Create a new Google Cloud project"""
        try:
            result = subprocess.run([
                'gcloud', 'projects', 'create', self.project_id,
                '--organization', self.organization_id
            ], check=True, capture_output=True, text=True)
            logger.info(f"Project created successfully: {self.project_id}")
        except subprocess.CalledProcessError as e:
            raise DeploymentError(f"Failed to create project: {e.stderr}")
    
    def _link_billing_account(self):
        """Link billing account to the project"""
        try:
            result = subprocess.run([
                'gcloud', 'billing', 'projects', 'link', self.project_id,
                '--billing-account', self.billing_account_id
            ], check=True, capture_output=True, text=True)
            logger.info(f"Linked billing account: {self.billing_account_id}")
        except subprocess.CalledProcessError as e:
            logger.warning(f"Failed to link billing account: {e.stderr}")
    
    def _enable_required_apis(self):
        """Enable required Google Cloud APIs"""
        required_apis = [
            'cloudresourcemanager.googleapis.com',
            'compute.googleapis.com',
            'iam.googleapis.com',
            'logging.googleapis.com',
            'monitoring.googleapis.com',
            'storage.googleapis.com',
            'cloudkms.googleapis.com',
            'dns.googleapis.com',
            'servicenetworking.googleapis.com',
            'cloudtrace.googleapis.com'
        ]
        
        logger.info("Enabling required APIs...")
        for api in required_apis:
            try:
                result = subprocess.run([
                    'gcloud', 'services', 'enable', api,
                    '--project', self.project_id
                ], check=True, capture_output=True, text=True)
                logger.info(f"Enabled API: {api}")
            except subprocess.CalledProcessError as e:
                logger.warning(f"Failed to enable API {api}: {e.stderr}")
    
    def setup_terraform_backend(self) -> bool:
        """
        Setup Terraform state backend (Google Cloud Storage)
        
        Returns:
            bool: True if setup successful
        """
        logger.info("Setting up Terraform backend...")
        
        try:
            state_bucket = f"{self.project_id}-terraform-state"
            
            # Check if bucket exists
            result = subprocess.run([
                'gsutil', 'ls', '-b', f'gs://{state_bucket}'
            ], capture_output=True, text=True)
            
            if result.returncode != 0:
                # Create bucket
                logger.info(f"Creating Terraform state bucket: {state_bucket}")
                subprocess.run([
                    'gsutil', 'mb', f'gs://{state_bucket}'
                ], check=True, capture_output=True)
                
                # Enable versioning
                subprocess.run([
                    'gsutil', 'versioning', 'set', 'on', f'gs://{state_bucket}'
                ], check=True, capture_output=True)
                logger.info("Enabled versioning on state bucket")
                
                # Set lifecycle policy
                lifecycle_config = {
                    "lifecycle": {
                        "rule": [
                            {
                                "action": {"type": "Delete"},
                                "condition": {
                                    "age": 365,
                                    "isLive": False
                                }
                            }
                        ]
                    }
                }
                
                lifecycle_file = self.script_dir / "lifecycle.json"
                with open(lifecycle_file, 'w') as f:
                    json.dump(lifecycle_config, f, indent=2)
                
                subprocess.run([
                    'gsutil', 'lifecycle', 'set', str(lifecycle_file), f'gs://{state_bucket}'
                ], check=True, capture_output=True)
                
                lifecycle_file.unlink()  # Clean up
                logger.info("Applied lifecycle policy to state bucket")
            else:
                logger.info(f"Terraform state bucket already exists: {state_bucket}")
            
            logger.info("Terraform backend setup completed")
            return True
            
        except Exception as e:
            raise DeploymentError(f"Terraform backend setup failed: {e}")
    
    def initialize_terraform(self) -> bool:
        """
        Initialize Terraform workspace
        
        Returns:
            bool: True if initialization successful
        """
        logger.info("Initializing Terraform...")
        
        try:
            os.chdir(self.terraform_dir)
            
            # Initialize Terraform
            result = subprocess.run(['terraform', 'init'], 
                                  check=True, capture_output=True, text=True)
            logger.info("Terraform initialized successfully")
            
            # Create or select workspace
            workspace_name = f"{self.environment}-{self.region}"
            
            # List existing workspaces
            result = subprocess.run(['terraform', 'workspace', 'list'], 
                                  capture_output=True, text=True)
            
            if workspace_name not in result.stdout:
                # Create new workspace
                subprocess.run(['terraform', 'workspace', 'new', workspace_name], 
                              check=True, capture_output=True)
                logger.info(f"Created Terraform workspace: {workspace_name}")
            else:
                # Select existing workspace
                subprocess.run(['terraform', 'workspace', 'select', workspace_name], 
                              check=True, capture_output=True)
                logger.info(f"Selected Terraform workspace: {workspace_name}")
            
            # Validate configuration
            subprocess.run(['terraform', 'validate'], 
                          check=True, capture_output=True)
            logger.info("Terraform configuration validated")
            
            return True
            
        except subprocess.CalledProcessError as e:
            raise DeploymentError(f"Terraform initialization failed: {e.stderr}")
        except Exception as e:
            raise DeploymentError(f"Terraform initialization failed: {e}")
    
    def plan_deployment(self) -> str:
        """
        Create Terraform deployment plan
        
        Returns:
            str: Path to the plan file
        """
        logger.info("Creating Terraform deployment plan...")
        
        try:
            os.chdir(self.terraform_dir)
            
            plan_file = f"tfplan_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
            
            # Run terraform plan
            result = subprocess.run([
                'terraform', 'plan',
                f'-var-file={self.config_file}',
                f'-out={plan_file}'
            ], check=True, capture_output=True, text=True)
            
            logger.info("Terraform plan created successfully")
            logger.info("Plan summary:")
            
            # Extract plan summary
            plan_output = result.stdout
            if "Plan:" in plan_output:
                plan_summary = plan_output.split("Plan:")[1].split("\n")[0]
                logger.info(f"Plan: {plan_summary}")
            
            return plan_file
            
        except subprocess.CalledProcessError as e:
            raise DeploymentError(f"Terraform plan failed: {e.stderr}")
    
    def apply_deployment(self, plan_file: str) -> bool:
        """
        Apply Terraform deployment
        
        Args:
            plan_file: Path to the Terraform plan file
            
        Returns:
            bool: True if deployment successful
        """
        logger.info("Applying Terraform deployment...")
        
        try:
            os.chdir(self.terraform_dir)
            
            if self.auto_approve:
                # Auto-approve deployment
                result = subprocess.run([
                    'terraform', 'apply', '-auto-approve', plan_file
                ], check=True, capture_output=True, text=True)
            else:
                # Interactive approval
                print("\nReview the plan above. Do you want to continue with the deployment? (y/N): ", end="")
                response = input().strip().lower()
                if response in ['y', 'yes']:
                    result = subprocess.run([
                        'terraform', 'apply', plan_file
                    ], check=True)
                else:
                    logger.info("Deployment cancelled by user")
                    return False
            
            logger.info("Terraform deployment completed successfully")
            
            # Get and log outputs
            try:
                result = subprocess.run(['terraform', 'output', '-json'], 
                                      capture_output=True, text=True)
                if result.returncode == 0:
                    outputs = json.loads(result.stdout)
                    self.deployment_report['outputs'] = outputs
                    logger.info("Deployment outputs captured")
            except (json.JSONDecodeError, subprocess.CalledProcessError):
                logger.warning("Failed to capture Terraform outputs")
            
            return True
            
        except subprocess.CalledProcessError as e:
            raise DeploymentError(f"Terraform apply failed: {e.stderr}")
    
    def validate_deployment(self) -> bool:
        """
        Validate the deployed infrastructure
        
        Returns:
            bool: True if validation successful
        """
        logger.info("Validating deployed infrastructure...")
        
        try:
            validation_results = {}
            
            # Check VPC networks
            logger.info("Validating VPC networks...")
            result = subprocess.run([
                'gcloud', 'compute', 'networks', 'list',
                '--format=json', '--filter=name:*vpc'
            ], capture_output=True, text=True, check=True)
            
            networks = json.loads(result.stdout)
            validation_results['vpc_networks'] = len(networks)
            logger.info(f"Found {len(networks)} VPC networks")
            
            # Check firewall rules
            logger.info("Validating firewall rules...")
            result = subprocess.run([
                'gcloud', 'compute', 'firewall-rules', 'list',
                '--format=json'
            ], capture_output=True, text=True, check=True)
            
            firewall_rules = json.loads(result.stdout)
            validation_results['firewall_rules'] = len(firewall_rules)
            logger.info(f"Found {len(firewall_rules)} firewall rules")
            
            # Check IAM policies
            logger.info("Validating IAM policies...")
            result = subprocess.run([
                'gcloud', 'projects', 'get-iam-policy', self.project_id,
                '--format=json'
            ], capture_output=True, text=True, check=True)
            
            iam_policy = json.loads(result.stdout)
            bindings_count = len(iam_policy.get('bindings', []))
            validation_results['iam_bindings'] = bindings_count
            logger.info(f"Found {bindings_count} IAM policy bindings")
            
            # Check enabled APIs
            result = subprocess.run([
                'gcloud', 'services', 'list', '--enabled',
                '--format=json'
            ], capture_output=True, text=True, check=True)
            
            enabled_apis = json.loads(result.stdout)
            validation_results['enabled_apis'] = len(enabled_apis)
            logger.info(f"Found {len(enabled_apis)} enabled APIs")
            
            self.deployment_report['validation_results'] = validation_results
            logger.info("Infrastructure validation completed successfully")
            return True
            
        except Exception as e:
            logger.warning(f"Infrastructure validation failed: {e}")
            return False
    
    def generate_deployment_report(self):
        """Generate comprehensive deployment report"""
        logger.info("Generating deployment report...")
        
        try:
            # Update deployment report
            deployment_end_time = datetime.now()
            self.deployment_report.update({
                "end_time": deployment_end_time.isoformat(),
                "duration_minutes": (deployment_end_time - self.deployment_start_time).total_seconds() / 60,
                "status": "completed"
            })
            
            # Add Terraform state information
            try:
                os.chdir(self.terraform_dir)
                result = subprocess.run(['terraform', 'show', '-json'], 
                                      capture_output=True, text=True)
                if result.returncode == 0:
                    state_data = json.loads(result.stdout)
                    resources = state_data.get('values', {}).get('root_module', {}).get('resources', [])
                    
                    # Count resources by type
                    resource_counts = {}
                    for resource in resources:
                        resource_type = resource.get('type', 'unknown')
                        resource_counts[resource_type] = resource_counts.get(resource_type, 0) + 1
                    
                    self.deployment_report.update({
                        'total_resources': len(resources),
                        'resource_summary': resource_counts
                    })
            except (json.JSONDecodeError, subprocess.CalledProcessError):
                logger.warning("Failed to capture Terraform state information")
            
            # Save report to file
            report_file = self.script_dir / f"deployment_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
            with open(report_file, 'w') as f:
                json.dump(self.deployment_report, f, indent=2, default=str)
            
            logger.info(f"Deployment report saved to: {report_file}")
            
        except Exception as e:
            logger.error(f"Failed to generate deployment report: {e}")
    
    def cleanup(self):
        """Cleanup temporary files and resources"""
        logger.info("Performing cleanup...")
        
        try:
            os.chdir(self.script_dir)
            
            # Remove temporary files
            temp_files = [
                "lifecycle.json",
                "*.tfplan*",
                "*.backup"
            ]
            
            for pattern in temp_files:
                for file_path in Path(".").glob(pattern):
                    try:
                        file_path.unlink()
                        logger.info(f"Removed temporary file: {file_path}")
                    except Exception:
                        pass
            
            logger.info("Cleanup completed")
            
        except Exception as e:
            logger.warning(f"Cleanup failed: {e}")
    
    def deploy(self) -> bool:
        """
        Main deployment orchestration method
        
        Returns:
            bool: True if deployment successful
        """
        try:
            logger.info("Starting Google Cloud Landing Zone deployment")
            logger.info(f"Project: {self.project_id}")
            logger.info(f"Organization: {self.organization_id}")
            logger.info(f"Region: {self.region}")
            logger.info(f"Environment: {self.environment}")
            
            # Execute deployment steps
            self.check_prerequisites()
            self.validate_configuration()
            self.setup_google_cloud_project()
            self.setup_terraform_backend()
            self.initialize_terraform()
            
            plan_file = self.plan_deployment()
            
            if self.apply_deployment(plan_file):
                self.validate_deployment()
                self.deployment_report['status'] = 'success'
                logger.info("Deployment completed successfully")
                return True
            else:
                self.deployment_report['status'] = 'cancelled'
                logger.info("Deployment was cancelled")
                return False
            
        except DeploymentError as e:
            logger.error(f"Deployment failed: {e}")
            self.deployment_report['status'] = 'failed'
            self.deployment_report['error'] = str(e)
            return False
        except Exception as e:
            logger.error(f"Unexpected error during deployment: {e}")
            self.deployment_report['status'] = 'error'
            self.deployment_report['error'] = str(e)
            return False
        finally:
            self.generate_deployment_report()
            self.cleanup()

def main():
    """Main entry point"""
    parser = argparse.ArgumentParser(
        description='Deploy Google Cloud Landing Zone infrastructure'
    )
    
    parser.add_argument('--project-id', required=True,
                       help='Google Cloud project ID')
    parser.add_argument('--organization-id', required=True,
                       help='Google Cloud organization ID')
    parser.add_argument('--billing-account', required=True,
                       help='Billing account ID')
    parser.add_argument('--region', default='us-central1',
                       help='Deployment region (default: us-central1)')
    parser.add_argument('--environment', default='prod',
                       help='Environment name (default: prod)')
    parser.add_argument('--config-file', default='terraform.tfvars',
                       help='Terraform configuration file (default: terraform.tfvars)')
    parser.add_argument('--auto-approve', action='store_true',
                       help='Auto-approve Terraform changes')
    parser.add_argument('--plan-only', action='store_true',
                       help='Only create deployment plan, do not apply')
    parser.add_argument('--verbose', '-v', action='store_true',
                       help='Enable verbose logging')
    
    args = parser.parse_args()
    
    # Configure logging level
    if args.verbose:
        logging.getLogger().setLevel(logging.DEBUG)
    
    # Create deployment instance
    deployment = GoogleCloudLandingZoneDeployment(
        project_id=args.project_id,
        organization_id=args.organization_id,
        billing_account_id=args.billing_account,
        region=args.region,
        environment=args.environment,
        config_file=args.config_file,
        auto_approve=args.auto_approve
    )
    
    try:
        if args.plan_only:
            # Plan-only mode
            deployment.check_prerequisites()
            deployment.validate_configuration()
            deployment.setup_google_cloud_project()
            deployment.setup_terraform_backend()
            deployment.initialize_terraform()
            deployment.plan_deployment()
            logger.info("Plan-only mode completed")
        else:
            # Full deployment
            success = deployment.deploy()
            sys.exit(0 if success else 1)
    
    except KeyboardInterrupt:
        logger.info("Deployment interrupted by user")
        sys.exit(1)
    except Exception as e:
        logger.error(f"Unexpected error: {e}")
        sys.exit(1)

if __name__ == '__main__':
    main()