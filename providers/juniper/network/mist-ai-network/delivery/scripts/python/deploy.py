#!/usr/bin/env python3
"""
Juniper Mist AI Network Platform Deployment Script

This script automates the deployment and configuration of Juniper Mist AI Network Platform
components including access points, switches, and network policies.

Requirements:
    - Python 3.7+
    - requests library
    - PyYAML library
    - Valid Mist Cloud API token

Usage:
    python deploy.py --config config.yaml --token YOUR_API_TOKEN
    python deploy.py --site "Site Name" --template "Standard Office"
    python deploy.py --validate-only --config config.yaml
"""

import argparse
import json
import logging
import sys
import time
import yaml
from datetime import datetime
from typing import Dict, List, Optional, Any
import requests
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry


class MistAPIClient:
    """Mist Cloud API client for deployment operations."""
    
    def __init__(self, api_token: str, base_url: str = "https://api.mist.com"):
        """Initialize Mist API client.
        
        Args:
            api_token: Mist API token for authentication
            base_url: Base URL for Mist API (default: https://api.mist.com)
        """
        self.api_token = api_token
        self.base_url = base_url.rstrip('/')
        self.session = requests.Session()
        
        # Configure retry strategy
        retry_strategy = Retry(
            total=3,
            backoff_factor=1,
            status_forcelist=[429, 500, 502, 503, 504],
        )
        adapter = HTTPAdapter(max_retries=retry_strategy)
        self.session.mount("http://", adapter)
        self.session.mount("https://", adapter)
        
        # Set headers
        self.session.headers.update({
            'Authorization': f'Token {self.api_token}',
            'Content-Type': 'application/json',
            'User-Agent': 'Mist-Deploy-Script/1.0'
        })
        
        # Validate API token
        self._validate_token()
    
    def _validate_token(self):
        """Validate API token and get organization info."""
        try:
            response = self.session.get(f"{self.base_url}/api/v1/self")
            response.raise_for_status()
            self.privileges = response.json().get('privileges', [])
            logging.info("API token validated successfully")
        except requests.exceptions.RequestException as e:
            logging.error(f"Failed to validate API token: {e}")
            sys.exit(1)
    
    def get_organizations(self) -> List[Dict]:
        """Get list of organizations."""
        response = self.session.get(f"{self.base_url}/api/v1/orgs")
        response.raise_for_status()
        return response.json()
    
    def get_sites(self, org_id: str) -> List[Dict]:
        """Get list of sites for an organization."""
        response = self.session.get(f"{self.base_url}/api/v1/orgs/{org_id}/sites")
        response.raise_for_status()
        return response.json()
    
    def create_site(self, org_id: str, site_config: Dict) -> Dict:
        """Create a new site."""
        response = self.session.post(
            f"{self.base_url}/api/v1/orgs/{org_id}/sites",
            json=site_config
        )
        response.raise_for_status()
        return response.json()
    
    def update_site(self, site_id: str, site_config: Dict) -> Dict:
        """Update site configuration."""
        response = self.session.put(
            f"{self.base_url}/api/v1/sites/{site_id}",
            json=site_config
        )
        response.raise_for_status()
        return response.json()
    
    def get_wlans(self, site_id: str) -> List[Dict]:
        """Get WLANs for a site."""
        response = self.session.get(f"{self.base_url}/api/v1/sites/{site_id}/wlans")
        response.raise_for_status()
        return response.json()
    
    def create_wlan(self, site_id: str, wlan_config: Dict) -> Dict:
        """Create WLAN configuration."""
        response = self.session.post(
            f"{self.base_url}/api/v1/sites/{site_id}/wlans",
            json=wlan_config
        )
        response.raise_for_status()
        return response.json()
    
    def get_access_points(self, site_id: str) -> List[Dict]:
        """Get access points for a site."""
        response = self.session.get(f"{self.base_url}/api/v1/sites/{site_id}/devices")
        response.raise_for_status()
        return [device for device in response.json() if device.get('type') == 'ap']
    
    def claim_device(self, org_id: str, claim_codes: List[str]) -> Dict:
        """Claim devices using claim codes."""
        response = self.session.post(
            f"{self.base_url}/api/v1/orgs/{org_id}/inventory",
            json=claim_codes
        )
        response.raise_for_status()
        return response.json()
    
    def assign_device_to_site(self, org_id: str, device_id: str, site_id: str) -> Dict:
        """Assign device to a site."""
        response = self.session.put(
            f"{self.base_url}/api/v1/orgs/{org_id}/inventory/{device_id}",
            json={'site_id': site_id}
        )
        response.raise_for_status()
        return response.json()
    
    def update_device_config(self, site_id: str, device_id: str, config: Dict) -> Dict:
        """Update device configuration."""
        response = self.session.put(
            f"{self.base_url}/api/v1/sites/{site_id}/devices/{device_id}",
            json=config
        )
        response.raise_for_status()
        return response.json()
    
    def get_device_status(self, site_id: str, device_id: str) -> Dict:
        """Get device status and statistics."""
        response = self.session.get(
            f"{self.base_url}/api/v1/sites/{site_id}/stats/devices/{device_id}"
        )
        response.raise_for_status()
        return response.json()


class MistDeployment:
    """Main deployment orchestration class."""
    
    def __init__(self, api_client: MistAPIClient, config: Dict):
        """Initialize deployment with API client and configuration.
        
        Args:
            api_client: Mist API client instance
            config: Deployment configuration dictionary
        """
        self.api = api_client
        self.config = config
        self.org_id = None
        self.deployment_results = {
            'sites_created': [],
            'sites_updated': [],
            'wlans_created': [],
            'devices_claimed': [],
            'devices_configured': [],
            'errors': []
        }
    
    def validate_config(self) -> bool:
        """Validate deployment configuration."""
        required_keys = ['organization', 'sites']
        
        for key in required_keys:
            if key not in self.config:
                logging.error(f"Missing required configuration key: {key}")
                return False
        
        # Validate organization
        org_config = self.config['organization']
        if 'name' not in org_config:
            logging.error("Organization name not specified in configuration")
            return False
        
        # Validate sites
        if not self.config['sites'] or len(self.config['sites']) == 0:
            logging.error("No sites specified in configuration")
            return False
        
        # Validate each site configuration
        for site_name, site_config in self.config['sites'].items():
            if not self._validate_site_config(site_name, site_config):
                return False
        
        logging.info("Configuration validation passed")
        return True
    
    def _validate_site_config(self, site_name: str, site_config: Dict) -> bool:
        """Validate individual site configuration."""
        required_site_keys = ['address', 'timezone']
        
        for key in required_site_keys:
            if key not in site_config:
                logging.error(f"Site '{site_name}' missing required key: {key}")
                return False
        
        # Validate WLANs if present
        if 'wlans' in site_config:
            for wlan_name, wlan_config in site_config['wlans'].items():
                if not self._validate_wlan_config(wlan_name, wlan_config):
                    return False
        
        return True
    
    def _validate_wlan_config(self, wlan_name: str, wlan_config: Dict) -> bool:
        """Validate WLAN configuration."""
        required_wlan_keys = ['ssid', 'auth']
        
        for key in required_wlan_keys:
            if key not in wlan_config:
                logging.error(f"WLAN '{wlan_name}' missing required key: {key}")
                return False
        
        # Validate authentication configuration
        auth_config = wlan_config['auth']
        if 'type' not in auth_config:
            logging.error(f"WLAN '{wlan_name}' auth type not specified")
            return False
        
        auth_type = auth_config['type']
        if auth_type == 'psk' and 'psk' not in auth_config:
            logging.error(f"WLAN '{wlan_name}' PSK not specified for PSK auth")
            return False
        
        return True
    
    def find_organization(self) -> Optional[str]:
        """Find organization ID by name."""
        org_name = self.config['organization']['name']
        
        try:
            orgs = self.api.get_organizations()
            for org in orgs:
                if org.get('name') == org_name:
                    self.org_id = org['id']
                    logging.info(f"Found organization: {org_name} (ID: {self.org_id})")
                    return self.org_id
            
            logging.error(f"Organization '{org_name}' not found")
            return None
            
        except Exception as e:
            logging.error(f"Failed to find organization: {e}")
            return None
    
    def deploy_sites(self) -> bool:
        """Deploy site configurations."""
        if not self.org_id:
            logging.error("Organization ID not set")
            return False
        
        # Get existing sites
        existing_sites = {}
        try:
            sites = self.api.get_sites(self.org_id)
            existing_sites = {site['name']: site for site in sites}
        except Exception as e:
            logging.error(f"Failed to get existing sites: {e}")
            return False
        
        # Process each site
        for site_name, site_config in self.config['sites'].items():
            try:
                if site_name in existing_sites:
                    # Update existing site
                    site_id = existing_sites[site_name]['id']
                    updated_site = self.api.update_site(site_id, site_config)
                    self.deployment_results['sites_updated'].append(updated_site)
                    logging.info(f"Updated site: {site_name}")
                else:
                    # Create new site
                    site_config['name'] = site_name
                    new_site = self.api.create_site(self.org_id, site_config)
                    self.deployment_results['sites_created'].append(new_site)
                    logging.info(f"Created site: {site_name}")
                
            except Exception as e:
                error_msg = f"Failed to deploy site '{site_name}': {e}"
                logging.error(error_msg)
                self.deployment_results['errors'].append(error_msg)
        
        return len(self.deployment_results['errors']) == 0
    
    def deploy_wlans(self) -> bool:
        """Deploy WLAN configurations."""
        for site_name, site_config in self.config['sites'].items():
            if 'wlans' not in site_config:
                continue
            
            # Find site ID
            site_id = self._get_site_id_by_name(site_name)
            if not site_id:
                continue
            
            # Get existing WLANs
            existing_wlans = {}
            try:
                wlans = self.api.get_wlans(site_id)
                existing_wlans = {wlan['ssid']: wlan for wlan in wlans}
            except Exception as e:
                logging.error(f"Failed to get WLANs for site '{site_name}': {e}")
                continue
            
            # Process each WLAN
            for wlan_name, wlan_config in site_config['wlans'].items():
                try:
                    ssid = wlan_config['ssid']
                    
                    if ssid in existing_wlans:
                        logging.info(f"WLAN '{ssid}' already exists in site '{site_name}'")
                        continue
                    
                    # Create new WLAN
                    new_wlan = self.api.create_wlan(site_id, wlan_config)
                    self.deployment_results['wlans_created'].append(new_wlan)
                    logging.info(f"Created WLAN '{ssid}' in site '{site_name}'")
                    
                except Exception as e:
                    error_msg = f"Failed to deploy WLAN '{wlan_name}' in site '{site_name}': {e}"
                    logging.error(error_msg)
                    self.deployment_results['errors'].append(error_msg)
        
        return True
    
    def claim_devices(self) -> bool:
        """Claim devices using claim codes."""
        if 'devices' not in self.config:
            logging.info("No devices to claim in configuration")
            return True
        
        devices_config = self.config['devices']
        
        # Process claim codes
        if 'claim_codes' in devices_config:
            claim_codes = devices_config['claim_codes']
            try:
                claimed_devices = self.api.claim_device(self.org_id, claim_codes)
                self.deployment_results['devices_claimed'].extend(claimed_devices)
                logging.info(f"Claimed {len(claim_codes)} devices")
            except Exception as e:
                error_msg = f"Failed to claim devices: {e}"
                logging.error(error_msg)
                self.deployment_results['errors'].append(error_msg)
                return False
        
        # Assign devices to sites
        if 'assignments' in devices_config:
            for assignment in devices_config['assignments']:
                try:
                    device_id = assignment['device_id']
                    site_name = assignment['site']
                    site_id = self._get_site_id_by_name(site_name)
                    
                    if not site_id:
                        logging.error(f"Site '{site_name}' not found for device assignment")
                        continue
                    
                    self.api.assign_device_to_site(self.org_id, device_id, site_id)
                    logging.info(f"Assigned device {device_id} to site '{site_name}'")
                    
                except Exception as e:
                    error_msg = f"Failed to assign device: {e}"
                    logging.error(error_msg)
                    self.deployment_results['errors'].append(error_msg)
        
        return True
    
    def configure_devices(self) -> bool:
        """Configure device-specific settings."""
        if 'device_configs' not in self.config:
            logging.info("No device configurations specified")
            return True
        
        device_configs = self.config['device_configs']
        
        for config in device_configs:
            try:
                site_name = config['site']
                device_id = config['device_id']
                device_config = config['config']
                
                site_id = self._get_site_id_by_name(site_name)
                if not site_id:
                    logging.error(f"Site '{site_name}' not found for device configuration")
                    continue
                
                updated_device = self.api.update_device_config(site_id, device_id, device_config)
                self.deployment_results['devices_configured'].append(updated_device)
                logging.info(f"Configured device {device_id} in site '{site_name}'")
                
            except Exception as e:
                error_msg = f"Failed to configure device: {e}"
                logging.error(error_msg)
                self.deployment_results['errors'].append(error_msg)
        
        return True
    
    def _get_site_id_by_name(self, site_name: str) -> Optional[str]:
        """Get site ID by site name."""
        try:
            sites = self.api.get_sites(self.org_id)
            for site in sites:
                if site['name'] == site_name:
                    return site['id']
            return None
        except Exception as e:
            logging.error(f"Failed to get site ID for '{site_name}': {e}")
            return None
    
    def verify_deployment(self) -> bool:
        """Verify deployment status."""
        logging.info("Verifying deployment...")
        
        verification_passed = True
        
        # Check site status
        for site in self.deployment_results['sites_created'] + self.deployment_results['sites_updated']:
            site_id = site['id']
            site_name = site['name']
            
            # Get access points for the site
            try:
                aps = self.api.get_access_points(site_id)
                logging.info(f"Site '{site_name}' has {len(aps)} access points")
                
                # Check AP status
                for ap in aps:
                    try:
                        status = self.api.get_device_status(site_id, ap['id'])
                        if status.get('status') != 'connected':
                            logging.warning(f"AP {ap['name']} not connected (Status: {status.get('status')})")
                            verification_passed = False
                    except Exception as e:
                        logging.warning(f"Could not check status for AP {ap.get('name', ap['id'])}: {e}")
                
            except Exception as e:
                logging.error(f"Failed to verify site '{site_name}': {e}")
                verification_passed = False
        
        return verification_passed
    
    def run_deployment(self, validate_only: bool = False) -> bool:
        """Run complete deployment process."""
        logging.info("Starting Mist AI Network deployment")
        
        # Validate configuration
        if not self.validate_config():
            logging.error("Configuration validation failed")
            return False
        
        if validate_only:
            logging.info("Validation-only mode: Configuration is valid")
            return True
        
        # Find organization
        if not self.find_organization():
            logging.error("Failed to find organization")
            return False
        
        # Deploy sites
        logging.info("Deploying sites...")
        if not self.deploy_sites():
            logging.error("Site deployment failed")
            return False
        
        # Deploy WLANs
        logging.info("Deploying WLANs...")
        if not self.deploy_wlans():
            logging.error("WLAN deployment failed")
            return False
        
        # Claim devices
        logging.info("Claiming devices...")
        if not self.claim_devices():
            logging.error("Device claiming failed")
            return False
        
        # Configure devices
        logging.info("Configuring devices...")
        if not self.configure_devices():
            logging.error("Device configuration failed")
            return False
        
        # Verify deployment
        logging.info("Verifying deployment...")
        verification_passed = self.verify_deployment()
        
        # Print summary
        self.print_summary()
        
        if len(self.deployment_results['errors']) > 0:
            logging.error(f"Deployment completed with {len(self.deployment_results['errors'])} errors")
            return False
        
        logging.info("Deployment completed successfully")
        return verification_passed
    
    def print_summary(self):
        """Print deployment summary."""
        print("\n" + "="*50)
        print("DEPLOYMENT SUMMARY")
        print("="*50)
        
        print(f"Sites Created: {len(self.deployment_results['sites_created'])}")
        for site in self.deployment_results['sites_created']:
            print(f"  - {site['name']} (ID: {site['id']})")
        
        print(f"Sites Updated: {len(self.deployment_results['sites_updated'])}")
        for site in self.deployment_results['sites_updated']:
            print(f"  - {site['name']} (ID: {site['id']})")
        
        print(f"WLANs Created: {len(self.deployment_results['wlans_created'])}")
        for wlan in self.deployment_results['wlans_created']:
            print(f"  - {wlan['ssid']} (ID: {wlan['id']})")
        
        print(f"Devices Claimed: {len(self.deployment_results['devices_claimed'])}")
        print(f"Devices Configured: {len(self.deployment_results['devices_configured'])}")
        
        if self.deployment_results['errors']:
            print(f"\nErrors ({len(self.deployment_results['errors'])}):")
            for error in self.deployment_results['errors']:
                print(f"  - {error}")
        
        print("="*50)


def load_config(config_path: str) -> Dict:
    """Load deployment configuration from YAML file."""
    try:
        with open(config_path, 'r') as file:
            config = yaml.safe_load(file)
        logging.info(f"Loaded configuration from {config_path}")
        return config
    except Exception as e:
        logging.error(f"Failed to load configuration: {e}")
        sys.exit(1)


def setup_logging(log_level: str = "INFO", log_file: Optional[str] = None):
    """Setup logging configuration."""
    level = getattr(logging, log_level.upper(), logging.INFO)
    
    # Create formatter
    formatter = logging.Formatter(
        '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    )
    
    # Setup handlers
    handlers = [logging.StreamHandler()]
    
    if log_file:
        handlers.append(logging.FileHandler(log_file))
    
    # Configure logging
    logging.basicConfig(
        level=level,
        handlers=handlers,
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    )


def main():
    """Main script execution."""
    parser = argparse.ArgumentParser(
        description="Deploy Juniper Mist AI Network Platform configuration"
    )
    
    parser.add_argument(
        '--config', '-c',
        required=True,
        help="Path to deployment configuration YAML file"
    )
    
    parser.add_argument(
        '--token', '-t',
        required=True,
        help="Mist API token for authentication"
    )
    
    parser.add_argument(
        '--validate-only',
        action='store_true',
        help="Validate configuration only, do not deploy"
    )
    
    parser.add_argument(
        '--log-level',
        choices=['DEBUG', 'INFO', 'WARNING', 'ERROR'],
        default='INFO',
        help="Logging level (default: INFO)"
    )
    
    parser.add_argument(
        '--log-file',
        help="Log file path (optional)"
    )
    
    parser.add_argument(
        '--base-url',
        default='https://api.mist.com',
        help="Mist API base URL (default: https://api.mist.com)"
    )
    
    args = parser.parse_args()
    
    # Setup logging
    setup_logging(args.log_level, args.log_file)
    
    # Load configuration
    config = load_config(args.config)
    
    # Initialize API client
    try:
        api_client = MistAPIClient(args.token, args.base_url)
    except Exception as e:
        logging.error(f"Failed to initialize API client: {e}")
        sys.exit(1)
    
    # Initialize deployment
    deployment = MistDeployment(api_client, config)
    
    # Run deployment
    success = deployment.run_deployment(args.validate_only)
    
    if success:
        sys.exit(0)
    else:
        sys.exit(1)


if __name__ == "__main__":
    main()