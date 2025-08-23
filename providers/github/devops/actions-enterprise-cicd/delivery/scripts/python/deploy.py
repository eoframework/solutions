#!/usr/bin/env python3
"""
GitHub Actions Enterprise CI/CD Platform - Deployment Script
This script automates the deployment and configuration of the GitHub Actions platform.
"""

import os
import json
import logging
import subprocess
import argparse
import time
from typing import Dict, List, Optional

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

class GitHubActionsDeployer:
    """
    GitHub Actions Enterprise CI/CD Platform deployment automation
    """
    
    def __init__(self, config_file: str):
        """
        Initialize deployer with configuration
        
        Args:
            config_file: Path to configuration file
        """
        self.config = self.load_config(config_file)
        self.github_token = os.getenv('GITHUB_TOKEN')
        self.aws_region = self.config.get('aws_region', 'us-east-1')
        
        if not self.github_token:
            raise ValueError("GITHUB_TOKEN environment variable is required")
    
    def load_config(self, config_file: str) -> Dict:
        """
        Load configuration from JSON file
        
        Args:
            config_file: Path to configuration file
            
        Returns:
            Configuration dictionary
        """
        try:
            with open(config_file, 'r') as f:
                config = json.load(f)
            logger.info(f"Loaded configuration from {config_file}")
            return config
        except FileNotFoundError:
            logger.error(f"Configuration file not found: {config_file}")
            raise
        except json.JSONDecodeError as e:
            logger.error(f"Invalid JSON in configuration file: {e}")
            raise
    
    def run_command(self, command: List[str], capture_output: bool = True) -> subprocess.CompletedProcess:
        """
        Run shell command with error handling
        
        Args:
            command: Command to execute as list
            capture_output: Whether to capture output
            
        Returns:
            CompletedProcess result
        """
        logger.info(f"Running command: {' '.join(command)}")
        
        try:
            result = subprocess.run(
                command,
                capture_output=capture_output,
                text=True,
                check=True
            )
            return result
        except subprocess.CalledProcessError as e:
            logger.error(f"Command failed: {e}")
            if e.stdout:
                logger.error(f"STDOUT: {e.stdout}")
            if e.stderr:
                logger.error(f"STDERR: {e.stderr}")
            raise
    
    def check_prerequisites(self) -> bool:
        """
        Check if required tools and permissions are available
        
        Returns:
            True if all prerequisites are met
        """
        logger.info("Checking prerequisites...")
        
        required_tools = ['gh', 'terraform', 'aws']
        for tool in required_tools:
            try:
                self.run_command(['which', tool])
                logger.info(f"✓ {tool} is available")
            except subprocess.CalledProcessError:
                logger.error(f"✗ {tool} is not available")
                return False
        
        # Check GitHub authentication
        try:
            result = self.run_command(['gh', 'auth', 'status'])
            logger.info("✓ GitHub authentication is valid")
        except subprocess.CalledProcessError:
            logger.error("✗ GitHub authentication failed")
            return False
        
        # Check AWS authentication
        try:
            self.run_command(['aws', 'sts', 'get-caller-identity'])
            logger.info("✓ AWS authentication is valid")
        except subprocess.CalledProcessError:
            logger.error("✗ AWS authentication failed")
            return False
        
        return True
    
    def deploy_infrastructure(self) -> bool:
        """
        Deploy infrastructure using Terraform
        
        Returns:
            True if deployment succeeds
        """
        logger.info("Deploying infrastructure with Terraform...")
        
        terraform_dir = self.config.get('terraform_dir', './terraform')
        
        try:
            # Change to Terraform directory
            original_dir = os.getcwd()
            os.chdir(terraform_dir)
            
            # Initialize Terraform
            self.run_command(['terraform', 'init'])
            
            # Plan deployment
            self.run_command(['terraform', 'plan', '-out=tfplan'])
            
            # Apply deployment
            self.run_command(['terraform', 'apply', '-auto-approve', 'tfplan'])
            
            logger.info("✓ Infrastructure deployment completed")
            return True
            
        except subprocess.CalledProcessError:
            logger.error("✗ Infrastructure deployment failed")
            return False
        finally:
            os.chdir(original_dir)
    
    def configure_github_organization(self) -> bool:
        """
        Configure GitHub organization settings
        
        Returns:
            True if configuration succeeds
        """
        logger.info("Configuring GitHub organization...")
        
        org = self.config['github_organization']
        
        try:
            # Enable GitHub Actions
            self.run_command([
                'gh', 'api', '-X', 'PUT',
                f'/orgs/{org}/actions/permissions',
                '-f', 'enabled=true',
                '-f', 'allowed_actions=selected',
                '-f', 'github_owned_allowed=true',
                '-f', 'verified_allowed=true'
            ])
            
            # Configure default workflow permissions
            self.run_command([
                'gh', 'api', '-X', 'PUT',
                f'/orgs/{org}/actions/permissions/workflow',
                '-f', 'default_workflow_permissions=read',
                '-f', 'can_approve_pull_request_reviews=false'
            ])
            
            logger.info("✓ GitHub organization configured")
            return True
            
        except subprocess.CalledProcessError:
            logger.error("✗ GitHub organization configuration failed")
            return False
    
    def setup_runner_groups(self) -> bool:
        """
        Set up runner groups
        
        Returns:
            True if setup succeeds
        """
        logger.info("Setting up runner groups...")
        
        org = self.config['github_organization']
        runner_groups = self.config.get('runner_groups', [])
        
        try:
            for group in runner_groups:
                # Create runner group
                self.run_command([
                    'gh', 'api', '-X', 'POST',
                    f'/orgs/{org}/actions/runner-groups',
                    '-f', f'name={group["name"]}',
                    '-f', f'visibility={group.get("visibility", "all")}',
                    '-f', f'allows_public_repositories={group.get("allows_public_repositories", False)}'
                ])
                
                logger.info(f"✓ Created runner group: {group['name']}")
            
            return True
            
        except subprocess.CalledProcessError:
            logger.error("✗ Runner group setup failed")
            return False
    
    def deploy_workflow_templates(self) -> bool:
        """
        Deploy organization workflow templates
        
        Returns:
            True if deployment succeeds
        """
        logger.info("Deploying workflow templates...")
        
        org = self.config['github_organization']
        templates_dir = self.config.get('templates_dir', './templates')
        
        try:
            # Check if .github repository exists
            try:
                self.run_command(['gh', 'repo', 'view', f'{org}/.github'])
            except subprocess.CalledProcessError:
                # Create .github repository
                self.run_command([
                    'gh', 'repo', 'create', f'{org}/.github',
                    '--public',
                    '--description', 'Organization workflow templates and configuration'
                ])
            
            # Clone .github repository
            self.run_command(['gh', 'repo', 'clone', f'{org}/.github', '.github-repo'])
            
            # Copy templates
            if os.path.exists(templates_dir):
                self.run_command(['cp', '-r', f'{templates_dir}/*', '.github-repo/'])
            
            # Commit and push templates
            os.chdir('.github-repo')
            self.run_command(['git', 'add', '.'])
            self.run_command(['git', 'commit', '-m', 'Add organization workflow templates'])
            self.run_command(['git', 'push'])
            
            logger.info("✓ Workflow templates deployed")
            return True
            
        except subprocess.CalledProcessError:
            logger.error("✗ Workflow template deployment failed")
            return False
    
    def configure_secrets(self) -> bool:
        """
        Configure organization secrets
        
        Returns:
            True if configuration succeeds
        """
        logger.info("Configuring organization secrets...")
        
        org = self.config['github_organization']
        secrets = self.config.get('secrets', {})
        
        try:
            for secret_name, secret_value in secrets.items():
                if secret_value.startswith('env:'):
                    # Get value from environment variable
                    env_var = secret_value[4:]
                    secret_value = os.getenv(env_var)
                    if not secret_value:
                        logger.warning(f"Environment variable {env_var} not found")
                        continue
                
                self.run_command([
                    'gh', 'secret', 'set', secret_name,
                    '--org', org,
                    '--body', secret_value
                ])
                
                logger.info(f"✓ Configured secret: {secret_name}")
            
            return True
            
        except subprocess.CalledProcessError:
            logger.error("✗ Secret configuration failed")
            return False
    
    def validate_deployment(self) -> bool:
        """
        Validate the deployment
        
        Returns:
            True if validation succeeds
        """
        logger.info("Validating deployment...")
        
        org = self.config['github_organization']
        
        try:
            # Check organization settings
            result = self.run_command(['gh', 'api', f'/orgs/{org}/actions/permissions'])
            permissions = json.loads(result.stdout)
            
            if not permissions.get('enabled'):
                logger.error("✗ GitHub Actions not enabled")
                return False
            
            # Check runner availability
            result = self.run_command(['gh', 'api', f'/orgs/{org}/actions/runners'])
            runners = json.loads(result.stdout)
            
            online_runners = [r for r in runners['runners'] if r['status'] == 'online']
            if len(online_runners) == 0:
                logger.warning("⚠ No online runners found")
            else:
                logger.info(f"✓ {len(online_runners)} runners online")
            
            logger.info("✓ Deployment validation completed")
            return True
            
        except (subprocess.CalledProcessError, json.JSONDecodeError):
            logger.error("✗ Deployment validation failed")
            return False
    
    def deploy(self) -> bool:
        """
        Execute full deployment process
        
        Returns:
            True if deployment succeeds
        """
        logger.info("Starting GitHub Actions Enterprise CI/CD Platform deployment...")
        
        steps = [
            ("Prerequisites check", self.check_prerequisites),
            ("Infrastructure deployment", self.deploy_infrastructure),
            ("GitHub organization configuration", self.configure_github_organization),
            ("Runner groups setup", self.setup_runner_groups),
            ("Workflow templates deployment", self.deploy_workflow_templates),
            ("Secrets configuration", self.configure_secrets),
            ("Deployment validation", self.validate_deployment)
        ]
        
        for step_name, step_func in steps:
            logger.info(f"Executing: {step_name}")
            
            if not step_func():
                logger.error(f"Deployment failed at step: {step_name}")
                return False
            
            logger.info(f"Completed: {step_name}")
            time.sleep(2)  # Brief pause between steps
        
        logger.info("🎉 GitHub Actions Enterprise CI/CD Platform deployment completed successfully!")
        return True

def main():
    """
    Main function
    """
    parser = argparse.ArgumentParser(
        description="Deploy GitHub Actions Enterprise CI/CD Platform"
    )
    parser.add_argument(
        '--config',
        required=True,
        help='Path to configuration file'
    )
    parser.add_argument(
        '--dry-run',
        action='store_true',
        help='Perform a dry run without making changes'
    )
    
    args = parser.parse_args()
    
    try:
        deployer = GitHubActionsDeployer(args.config)
        
        if args.dry_run:
            logger.info("Dry run mode - no changes will be made")
            if deployer.check_prerequisites():
                logger.info("✓ All prerequisites met - ready for deployment")
            else:
                logger.error("✗ Prerequisites not met")
                return 1
        else:
            if deployer.deploy():
                logger.info("Deployment completed successfully")
                return 0
            else:
                logger.error("Deployment failed")
                return 1
                
    except Exception as e:
        logger.error(f"Deployment error: {e}")
        return 1

if __name__ == "__main__":
    exit(main())