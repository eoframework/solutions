#!/usr/bin/env python3

"""
IBM Ansible Automation Platform - Python Deployment Script
This script automates the deployment of IBM Ansible Automation Platform on Red Hat OpenShift
"""

import argparse
import base64
import json
import logging
import os
import subprocess
import sys
import tempfile
import time
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional


class AAPDeployer:
    """Main class for deploying IBM Ansible Automation Platform"""
    
    def __init__(self, namespace: str = "ansible-automation", 
                 domain: str = "automation.company.com", 
                 version: str = "2.4"):
        self.namespace = namespace
        self.domain = domain
        self.version = version
        self.temp_dir = None
        
        # Setup logging
        log_file = f"/tmp/aap-deployment-{datetime.now().strftime('%Y%m%d-%H%M%S')}.log"
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(levelname)s - %(message)s',
            handlers=[
                logging.FileHandler(log_file),
                logging.StreamHandler(sys.stdout)
            ]
        )
        self.logger = logging.getLogger(__name__)
        self.logger.info(f"Log file: {log_file}")
        
    def run_command(self, cmd: List[str], check: bool = True, capture_output: bool = True) -> subprocess.CompletedProcess:
        """Execute a shell command and return the result"""
        self.logger.debug(f"Executing: {' '.join(cmd)}")
        try:
            result = subprocess.run(
                cmd, 
                check=check, 
                capture_output=capture_output, 
                text=True, 
                timeout=300
            )
            return result
        except subprocess.CalledProcessError as e:
            self.logger.error(f"Command failed: {' '.join(cmd)}")
            self.logger.error(f"Error: {e.stderr}")
            raise
        except subprocess.TimeoutExpired:
            self.logger.error(f"Command timed out: {' '.join(cmd)}")
            raise
    
    def check_prerequisites(self) -> None:
        """Check all prerequisites for deployment"""
        self.logger.info("Checking prerequisites...")
        
        # Check required tools
        required_tools = ["oc", "ansible-playbook", "jq"]
        for tool in required_tools:
            try:
                self.run_command(["which", tool])
                self.logger.info(f"Found required tool: {tool}")
            except subprocess.CalledProcessError:
                raise RuntimeError(f"{tool} is required but not found in PATH")
        
        # Check environment variables
        required_env_vars = ["AAP_ADMIN_PASSWORD", "OPENSHIFT_TOKEN", "AAP_LICENSE_MANIFEST"]
        for env_var in required_env_vars:
            if not os.getenv(env_var):
                raise RuntimeError(f"Environment variable {env_var} is required")
        
        # Check OpenShift connectivity
        try:
            result = self.run_command(["oc", "whoami"])
            self.logger.info(f"Connected to OpenShift as: {result.stdout.strip()}")
        except subprocess.CalledProcessError:
            raise RuntimeError("Not logged into OpenShift. Please run 'oc login' first")
        
        # Verify cluster permissions
        try:
            result = self.run_command(["oc", "auth", "can-i", "create", "namespace"])
            if result.stdout.strip() != "yes":
                raise RuntimeError("Insufficient permissions. Cluster admin access required")
        except subprocess.CalledProcessError:
            raise RuntimeError("Failed to verify cluster permissions")
        
        self.logger.info("✅ All prerequisites validated")
    
    def setup_environment(self) -> None:
        """Setup deployment environment"""
        self.logger.info("Setting up deployment environment...")
        
        # Create temporary directory
        self.temp_dir = tempfile.mkdtemp(prefix="aap-deployment-")
        self.logger.info(f"Created temporary directory: {self.temp_dir}")
        
        # Login to OpenShift with token
        openshift_token = os.getenv("OPENSHIFT_TOKEN")
        try:
            self.run_command(["oc", "login", f"--token={openshift_token}"])
        except subprocess.CalledProcessError:
            raise RuntimeError("Failed to login to OpenShift with provided token")
        
        # Display cluster information
        current_context = self.run_command(["oc", "config", "current-context"]).stdout.strip()
        current_user = self.run_command(["oc", "whoami"]).stdout.strip()
        self.logger.info(f"Connected to cluster: {current_context}")
        self.logger.info(f"Current user: {current_user}")
        
        self.logger.info("✅ Environment setup complete")
    
    def validate_resources(self) -> None:
        """Validate cluster resources"""
        self.logger.info("Validating cluster resources...")
        
        # Get cluster resource information
        try:
            nodes_result = self.run_command(["oc", "get", "nodes", "--no-headers"])
            node_count = len(nodes_result.stdout.strip().split('\n')) if nodes_result.stdout.strip() else 0
            self.logger.info(f"Available nodes: {node_count}")
            
            # Check storage classes
            sc_result = self.run_command(["oc", "get", "storageclass", "--no-headers"])
            sc_count = len(sc_result.stdout.strip().split('\n')) if sc_result.stdout.strip() else 0
            if sc_count == 0:
                raise RuntimeError("No storage classes available. Storage classes are required for persistent volumes")
            self.logger.info(f"Available storage classes: {sc_count}")
            
            # Check if namespace already exists
            try:
                self.run_command(["oc", "get", "namespace", self.namespace])
                self.logger.warning(f"Namespace {self.namespace} already exists")
                response = input("Continue with existing namespace? (y/N): ")
                if response.lower() != 'y':
                    raise RuntimeError("Deployment cancelled by user")
            except subprocess.CalledProcessError:
                # Namespace doesn't exist, which is fine
                pass
                
        except subprocess.CalledProcessError as e:
            raise RuntimeError(f"Failed to validate cluster resources: {e}")
        
        self.logger.info("✅ Resource validation complete")
    
    def install_operator(self) -> None:
        """Install the Ansible Automation Platform Operator"""
        self.logger.info("Installing Ansible Automation Platform Operator...")
        
        # Create operator namespace
        operator_namespace = {
            "apiVersion": "v1",
            "kind": "Namespace",
            "metadata": {"name": "ansible-automation-platform-operator"}
        }
        self._apply_yaml(operator_namespace)
        
        # Create operator group
        operator_group = {
            "apiVersion": "operators.coreos.com/v1",
            "kind": "OperatorGroup",
            "metadata": {
                "name": "ansible-automation-platform-operator",
                "namespace": "ansible-automation-platform-operator"
            },
            "spec": {
                "targetNamespaces": ["ansible-automation-platform-operator"]
            }
        }
        self._apply_yaml(operator_group)
        
        # Create subscription
        subscription = {
            "apiVersion": "operators.coreos.com/v1alpha1",
            "kind": "Subscription",
            "metadata": {
                "name": "ansible-automation-platform-operator",
                "namespace": "ansible-automation-platform-operator"
            },
            "spec": {
                "channel": "stable-2.4-cluster-scoped",
                "name": "ansible-automation-platform-operator",
                "source": "redhat-operators",
                "sourceNamespace": "openshift-marketplace"
            }
        }
        self._apply_yaml(subscription)
        
        # Wait for operator installation
        self.logger.info("Waiting for operator installation (this may take a few minutes)...")
        timeout = 600
        elapsed = 0
        
        while elapsed < timeout:
            try:
                result = self.run_command([
                    "oc", "get", "csv", "-n", "ansible-automation-platform-operator",
                    "-o", "jsonpath={.items[*].status.phase}"
                ])
                if "Succeeded" in result.stdout:
                    break
            except subprocess.CalledProcessError:
                pass
            
            time.sleep(10)
            elapsed += 10
            self.logger.info(f"Waiting... ({elapsed}/{timeout} seconds)")
        
        if elapsed >= timeout:
            raise RuntimeError("Operator installation timed out")
        
        self.logger.info("✅ Operator installed successfully")
    
    def create_namespace_and_secrets(self) -> None:
        """Create namespace and required secrets"""
        self.logger.info("Creating namespace and secrets...")
        
        # Create namespace
        namespace = {
            "apiVersion": "v1",
            "kind": "Namespace",
            "metadata": {"name": self.namespace}
        }
        self._apply_yaml(namespace)
        
        # Create admin password secret
        admin_password = os.getenv("AAP_ADMIN_PASSWORD")
        admin_secret = {
            "apiVersion": "v1",
            "kind": "Secret",
            "metadata": {
                "name": "automation-controller-admin-password",
                "namespace": self.namespace
            },
            "type": "Opaque",
            "stringData": {
                "password": admin_password
            }
        }
        self._apply_yaml(admin_secret)
        
        # Create license manifest secret
        license_manifest = os.getenv("AAP_LICENSE_MANIFEST")
        manifest_path = os.path.join(self.temp_dir, "manifest.zip")
        with open(manifest_path, "wb") as f:
            f.write(base64.b64decode(license_manifest))
        
        self.run_command([
            "oc", "create", "secret", "generic", "automation-controller-license",
            f"--from-file=manifest.zip={manifest_path}",
            "-n", self.namespace, "--dry-run=client", "-o", "yaml"
        ], capture_output=False)
        
        # Generate and create database password secret
        import secrets
        import string
        db_password = ''.join(secrets.choice(string.ascii_letters + string.digits) for _ in range(16))
        
        db_secret = {
            "apiVersion": "v1",
            "kind": "Secret",
            "metadata": {
                "name": "postgres-admin-password",
                "namespace": self.namespace
            },
            "type": "Opaque",
            "stringData": {
                "password": db_password
            }
        }
        self._apply_yaml(db_secret)
        
        self.logger.info("✅ Namespace and secrets created")
    
    def deploy_platform(self) -> None:
        """Deploy platform components using Ansible playbook"""
        self.logger.info("Deploying Ansible Automation Platform components...")
        
        # Find the project root directory (assuming script is in delivery/scripts/python)
        script_dir = Path(__file__).parent
        project_root = script_dir.parent.parent.parent
        playbook_path = project_root / "delivery" / "scripts" / "ansible" / "playbook.yml"
        
        if not playbook_path.exists():
            raise RuntimeError(f"Ansible playbook not found at: {playbook_path}")
        
        # Run the Ansible playbook
        original_dir = os.getcwd()
        try:
            os.chdir(project_root)
            self.run_command([
                "ansible-playbook", str(playbook_path),
                "-e", f"openshift_namespace={self.namespace}",
                "-e", f"domain_name={self.domain}",
                "-e", f"aap_version={self.version}",
                "--tags", "operator,namespace,secrets,database,controller,hub,eda,monitoring",
                "-v"
            ], capture_output=False)
        finally:
            os.chdir(original_dir)
        
        self.logger.info("✅ Platform components deployed")
    
    def validate_deployment(self) -> None:
        """Validate the deployment"""
        self.logger.info("Validating deployment...")
        
        try:
            # Check pod status
            result = self.run_command([
                "oc", "get", "pods", "-n", self.namespace,
                "--field-selector=status.phase=Running", "--no-headers"
            ])
            pod_count = len(result.stdout.strip().split('\n')) if result.stdout.strip() else 0
            self.logger.info(f"Running pods: {pod_count}")
            
            # Check routes
            try:
                result = self.run_command([
                    "oc", "get", "route", "-n", self.namespace,
                    "-l", "app.kubernetes.io/name=automation-controller",
                    "-o", "jsonpath={.items[0].spec.host}"
                ])
                controller_route = result.stdout.strip()
                
                if controller_route:
                    self.logger.info(f"Controller URL: https://{controller_route}")
                    
                    # Test connectivity
                    try:
                        import requests
                        response = requests.get(f"https://{controller_route}/api/v2/ping/", 
                                              verify=False, timeout=10)
                        if response.status_code == 200:
                            self.logger.info("✅ Controller is accessible and responding")
                        else:
                            self.logger.warning("Controller may not be fully ready yet")
                    except Exception:
                        self.logger.warning("Controller may not be fully ready yet")
                else:
                    self.logger.warning("Controller route not found")
                    
            except subprocess.CalledProcessError:
                self.logger.warning("Controller route not found")
        
        except Exception as e:
            self.logger.warning(f"Some validation checks failed: {e}")
        
        self.logger.info("✅ Deployment validation complete")
    
    def display_summary(self) -> None:
        """Display deployment summary"""
        self.logger.info("Deployment Summary")
        print("=" * 60)
        print("🎉 IBM Ansible Automation Platform Deployment Complete!")
        print()
        
        try:
            # Get routes
            controller_route = self._get_route("automation-controller")
            hub_route = self._get_route("automation-hub")  
            eda_route = self._get_route("eda")
            
            print(f"📊 Controller: https://{controller_route or 'Not available'}")
            print(f"🏪 Hub: https://{hub_route or 'Not available'}")
            print(f"⚡ EDA: https://{eda_route or 'Not available'}")
            print()
            print("👤 Admin User: admin")
            print("🔐 Admin Password: [Set via AAP_ADMIN_PASSWORD]")
            print()
            print(f"📋 Namespace: {self.namespace}")
            print(f"🏗️ Platform Version: {self.version}")
            print()
            print("Next Steps:")
            print("1. Access the Controller UI to complete initial setup")
            print("2. Configure organizations and teams")
            print("3. Set up credential types and credentials")
            print("4. Upload automation content to Private Automation Hub")
            print("5. Configure event-driven automation rules")
            
        except Exception as e:
            self.logger.warning(f"Failed to retrieve some deployment information: {e}")
        
        print("=" * 60)
    
    def cleanup_deployment(self) -> None:
        """Remove the deployment"""
        self.logger.info("Removing IBM Ansible Automation Platform deployment...")
        
        response = input("Are you sure you want to remove the deployment? This cannot be undone. (y/N): ")
        if response.lower() != 'y':
            self.logger.info("Cleanup cancelled")
            return
        
        try:
            # Find the project root directory
            script_dir = Path(__file__).parent
            project_root = script_dir.parent.parent.parent
            playbook_path = project_root / "delivery" / "scripts" / "ansible" / "playbook.yml"
            
            # Run cleanup playbook
            original_dir = os.getcwd()
            try:
                os.chdir(project_root)
                self.run_command([
                    "ansible-playbook", str(playbook_path),
                    "-e", f"openshift_namespace={self.namespace}",
                    "--tags", "cleanup",
                    "-v"
                ], capture_output=False)
            finally:
                os.chdir(original_dir)
            
            # Remove operator if no other instances exist
            try:
                result = self.run_command([
                    "oc", "get", "automationcontroller", "--all-namespaces", "--no-headers"
                ])
                if not result.stdout.strip():
                    self.logger.info("Removing operator (no other instances found)...")
                    self.run_command([
                        "oc", "delete", "subscription", "ansible-automation-platform-operator",
                        "-n", "ansible-automation-platform-operator", "--ignore-not-found=true"
                    ])
                    self.run_command([
                        "oc", "delete", "csv", "-n", "ansible-automation-platform-operator",
                        "-l", "operators.coreos.com/ansible-automation-platform-operator.ansible-automation-platform-operator",
                        "--ignore-not-found=true"
                    ])
                    self.run_command([
                        "oc", "delete", "namespace", "ansible-automation-platform-operator", 
                        "--ignore-not-found=true"
                    ])
            except subprocess.CalledProcessError:
                pass
                
        except Exception as e:
            raise RuntimeError(f"Failed to cleanup deployment: {e}")
        
        self.logger.info("✅ Cleanup complete")
    
    def _apply_yaml(self, yaml_content: Dict) -> None:
        """Apply YAML content to OpenShift"""
        yaml_file = os.path.join(self.temp_dir, f"resource-{int(time.time())}.yaml")
        with open(yaml_file, 'w') as f:
            json.dump(yaml_content, f)
        
        self.run_command(["oc", "apply", "-f", yaml_file])
    
    def _get_route(self, app_name: str) -> Optional[str]:
        """Get route for an application"""
        try:
            result = self.run_command([
                "oc", "get", "route", "-n", self.namespace,
                "-l", f"app.kubernetes.io/name={app_name}",
                "-o", "jsonpath={.items[0].spec.host}"
            ])
            return result.stdout.strip() or None
        except subprocess.CalledProcessError:
            return None
    
    def cleanup_temp_files(self) -> None:
        """Clean up temporary files"""
        if self.temp_dir:
            try:
                import shutil
                shutil.rmtree(self.temp_dir)
            except Exception as e:
                self.logger.warning(f"Failed to cleanup temporary directory: {e}")


def main():
    """Main function"""
    parser = argparse.ArgumentParser(
        description="Deploy IBM Ansible Automation Platform on Red Hat OpenShift"
    )
    parser.add_argument(
        "-n", "--namespace", 
        default="ansible-automation",
        help="OpenShift namespace (default: ansible-automation)"
    )
    parser.add_argument(
        "-d", "--domain", 
        default="automation.company.com",
        help="Base domain name (default: automation.company.com)"
    )
    parser.add_argument(
        "-v", "--version", 
        default="2.4",
        help="AAP version (default: 2.4)"
    )
    parser.add_argument(
        "--cleanup", 
        action="store_true",
        help="Remove existing deployment"
    )
    parser.add_argument(
        "--validate-only", 
        action="store_true",
        help="Only validate prerequisites"
    )
    parser.add_argument(
        "--dry-run", 
        action="store_true",
        help="Show what would be deployed without making changes"
    )
    
    args = parser.parse_args()
    
    deployer = AAPDeployer(
        namespace=args.namespace,
        domain=args.domain, 
        version=args.version
    )
    
    try:
        deployer.logger.info("Starting IBM Ansible Automation Platform deployment")
        
        # Handle cleanup mode
        if args.cleanup:
            deployer.check_prerequisites()
            deployer.setup_environment()
            deployer.cleanup_deployment()
            return
        
        # Run deployment steps
        deployer.check_prerequisites()
        
        if args.validate_only:
            deployer.logger.info("✅ Prerequisites validation complete")
            return
        
        deployer.setup_environment()
        deployer.validate_resources()
        
        if args.dry_run:
            deployer.logger.info("Dry run complete. Would proceed with deployment using:")
            deployer.logger.info(f"  Namespace: {args.namespace}")
            deployer.logger.info(f"  Domain: {args.domain}")
            deployer.logger.info(f"  Version: {args.version}")
            return
        
        deployer.install_operator()
        deployer.create_namespace_and_secrets()
        deployer.deploy_platform()
        deployer.validate_deployment()
        deployer.display_summary()
        
        deployer.logger.info("✅ IBM Ansible Automation Platform deployment completed successfully")
        
    except Exception as e:
        deployer.logger.error(f"Deployment failed: {e}")
        sys.exit(1)
    finally:
        deployer.cleanup_temp_files()


if __name__ == "__main__":
    main()