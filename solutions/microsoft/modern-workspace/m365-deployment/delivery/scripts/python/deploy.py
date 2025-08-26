#!/usr/bin/env python3
"""
Microsoft 365 Enterprise Deployment - Python Automation Script

This script provides Python-based automation for Microsoft 365 deployment tasks,
particularly focused on data migration, reporting, and integration scenarios.

Author: Microsoft 365 Deployment Team
Version: 1.0
Python Version: 3.8+

Required packages listed in requirements.txt:
- msal
- requests
- pandas
- openpyxl
- azure-identity
- msgraph-core
"""

import os
import sys
import json
import logging
import argparse
import datetime
from typing import Dict, List, Optional, Any
from dataclasses import dataclass
from pathlib import Path

try:
    import requests
    import pandas as pd
    from msal import ConfidentialClientApplication
    from azure.identity import ClientSecretCredential
    from msgraph.core import GraphSession
except ImportError as e:
    print(f"Required module not installed: {e}")
    print("Please run: pip install -r requirements.txt")
    sys.exit(1)

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(f'M365_Deployment_{datetime.datetime.now().strftime("%Y%m%d_%H%M%S")}.log'),
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger(__name__)

@dataclass
class M365Config:
    """Configuration settings for Microsoft 365 deployment"""
    tenant_id: str
    client_id: str
    client_secret: str
    tenant_domain: str
    admin_user: str
    
    @classmethod
    def from_file(cls, config_path: str) -> 'M365Config':
        """Load configuration from JSON file"""
        try:
            with open(config_path, 'r') as f:
                config_data = json.load(f)
            return cls(**config_data['authentication'])
        except (FileNotFoundError, KeyError, json.JSONDecodeError) as e:
            logger.error(f"Failed to load configuration: {e}")
            raise

    @classmethod
    def from_env(cls) -> 'M365Config':
        """Load configuration from environment variables"""
        return cls(
            tenant_id=os.getenv('M365_TENANT_ID', ''),
            client_id=os.getenv('M365_CLIENT_ID', ''),
            client_secret=os.getenv('M365_CLIENT_SECRET', ''),
            tenant_domain=os.getenv('M365_TENANT_DOMAIN', ''),
            admin_user=os.getenv('M365_ADMIN_USER', '')
        )

class GraphAPIClient:
    """Microsoft Graph API client for Microsoft 365 operations"""
    
    def __init__(self, config: M365Config):
        self.config = config
        self.session = None
        self._authenticate()
    
    def _authenticate(self):
        """Authenticate with Microsoft Graph API"""
        try:
            credential = ClientSecretCredential(
                tenant_id=self.config.tenant_id,
                client_id=self.config.client_id,
                client_secret=self.config.client_secret
            )
            
            self.session = GraphSession(
                credential=credential,
                scopes=['https://graph.microsoft.com/.default']
            )
            logger.info("Successfully authenticated with Microsoft Graph API")
            
        except Exception as e:
            logger.error(f"Authentication failed: {e}")
            raise
    
    def get_users(self, filter_query: Optional[str] = None) -> List[Dict]:
        """Retrieve users from Azure AD"""
        try:
            endpoint = "/users"
            if filter_query:
                endpoint += f"?$filter={filter_query}"
            
            response = self.session.get(endpoint)
            response.raise_for_status()
            
            users = response.json().get('value', [])
            logger.info(f"Retrieved {len(users)} users from Azure AD")
            return users
            
        except Exception as e:
            logger.error(f"Failed to retrieve users: {e}")
            raise
    
    def get_groups(self) -> List[Dict]:
        """Retrieve groups from Azure AD"""
        try:
            response = self.session.get("/groups")
            response.raise_for_status()
            
            groups = response.json().get('value', [])
            logger.info(f"Retrieved {len(groups)} groups from Azure AD")
            return groups
            
        except Exception as e:
            logger.error(f"Failed to retrieve groups: {e}")
            raise
    
    def get_licenses(self) -> List[Dict]:
        """Retrieve available licenses"""
        try:
            response = self.session.get("/subscribedSkus")
            response.raise_for_status()
            
            licenses = response.json().get('value', [])
            logger.info(f"Retrieved {len(licenses)} license types")
            return licenses
            
        except Exception as e:
            logger.error(f"Failed to retrieve licenses: {e}")
            raise
    
    def create_user(self, user_data: Dict) -> Dict:
        """Create a new user in Azure AD"""
        try:
            response = self.session.post("/users", json=user_data)
            response.raise_for_status()
            
            user = response.json()
            logger.info(f"Created user: {user.get('userPrincipalName')}")
            return user
            
        except Exception as e:
            logger.error(f"Failed to create user: {e}")
            raise
    
    def assign_license(self, user_id: str, license_sku_id: str) -> bool:
        """Assign license to user"""
        try:
            license_data = {
                "addLicenses": [
                    {
                        "skuId": license_sku_id,
                        "disabledPlans": []
                    }
                ],
                "removeLicenses": []
            }
            
            response = self.session.post(f"/users/{user_id}/assignLicense", json=license_data)
            response.raise_for_status()
            
            logger.info(f"Assigned license {license_sku_id} to user {user_id}")
            return True
            
        except Exception as e:
            logger.error(f"Failed to assign license: {e}")
            return False

class UserMigrationTool:
    """Tool for migrating users from CSV or other data sources"""
    
    def __init__(self, graph_client: GraphAPIClient):
        self.graph_client = graph_client
    
    def load_users_from_csv(self, csv_path: str) -> pd.DataFrame:
        """Load user data from CSV file"""
        try:
            df = pd.read_csv(csv_path)
            logger.info(f"Loaded {len(df)} users from CSV: {csv_path}")
            return df
        except Exception as e:
            logger.error(f"Failed to load CSV: {e}")
            raise
    
    def validate_user_data(self, user_df: pd.DataFrame) -> List[Dict]:
        """Validate user data and convert to Graph API format"""
        required_columns = ['displayName', 'userPrincipalName', 'givenName', 'surname']
        
        # Check required columns
        missing_columns = [col for col in required_columns if col not in user_df.columns]
        if missing_columns:
            raise ValueError(f"Missing required columns: {missing_columns}")
        
        users = []
        for _, row in user_df.iterrows():
            # Generate temporary password
            temp_password = self._generate_temp_password()
            
            user_data = {
                "displayName": row['displayName'],
                "userPrincipalName": row['userPrincipalName'],
                "givenName": row['givenName'],
                "surname": row['surname'],
                "accountEnabled": True,
                "passwordProfile": {
                    "password": temp_password,
                    "forceChangePasswordNextSignIn": True
                },
                "usageLocation": row.get('usageLocation', 'US'),
                "department": row.get('department', ''),
                "jobTitle": row.get('jobTitle', ''),
                "mail": row.get('mail', ''),
                "mobilePhone": row.get('mobilePhone', '')
            }
            users.append(user_data)
        
        logger.info(f"Validated {len(users)} user records")
        return users
    
    def _generate_temp_password(self) -> str:
        """Generate a temporary password"""
        import secrets
        import string
        
        # Generate a 12-character password with letters, numbers, and symbols
        alphabet = string.ascii_letters + string.digits + "!@#$%"
        password = ''.join(secrets.choice(alphabet) for _ in range(12))
        return password
    
    def bulk_create_users(self, users: List[Dict], batch_size: int = 20) -> List[Dict]:
        """Create users in batches"""
        results = []
        
        for i in range(0, len(users), batch_size):
            batch = users[i:i + batch_size]
            batch_results = []
            
            logger.info(f"Processing batch {i//batch_size + 1}: users {i+1} to {min(i+batch_size, len(users))}")
            
            for user_data in batch:
                try:
                    created_user = self.graph_client.create_user(user_data)
                    batch_results.append({
                        'status': 'success',
                        'user': created_user,
                        'temp_password': user_data['passwordProfile']['password']
                    })
                except Exception as e:
                    batch_results.append({
                        'status': 'error',
                        'user_data': user_data,
                        'error': str(e)
                    })
            
            results.extend(batch_results)
            
            # Add delay between batches to avoid throttling
            import time
            time.sleep(2)
        
        return results

class LicenseManager:
    """Tool for managing Microsoft 365 licenses"""
    
    def __init__(self, graph_client: GraphAPIClient):
        self.graph_client = graph_client
    
    def generate_license_report(self) -> pd.DataFrame:
        """Generate comprehensive license usage report"""
        try:
            licenses = self.graph_client.get_licenses()
            users = self.graph_client.get_users()
            
            license_data = []
            for license in licenses:
                sku_part_number = license.get('skuPartNumber', 'Unknown')
                enabled_units = license.get('prepaidUnits', {}).get('enabled', 0)
                consumed_units = license.get('consumedUnits', 0)
                available_units = enabled_units - consumed_units
                utilization_rate = (consumed_units / enabled_units * 100) if enabled_units > 0 else 0
                
                license_data.append({
                    'License_Type': sku_part_number,
                    'Total_Units': enabled_units,
                    'Consumed_Units': consumed_units,
                    'Available_Units': available_units,
                    'Utilization_Rate': round(utilization_rate, 2)
                })
            
            df = pd.DataFrame(license_data)
            logger.info(f"Generated license report with {len(df)} license types")
            return df
            
        except Exception as e:
            logger.error(f"Failed to generate license report: {e}")
            raise
    
    def assign_licenses_bulk(self, user_license_mapping: List[Dict]) -> List[Dict]:
        """Assign licenses to multiple users"""
        results = []
        
        for mapping in user_license_mapping:
            user_id = mapping['user_id']
            license_sku_id = mapping['license_sku_id']
            
            success = self.graph_client.assign_license(user_id, license_sku_id)
            results.append({
                'user_id': user_id,
                'license_sku_id': license_sku_id,
                'success': success
            })
        
        return results

class ReportGenerator:
    """Generate deployment and usage reports"""
    
    def __init__(self, graph_client: GraphAPIClient):
        self.graph_client = graph_client
    
    def generate_deployment_summary(self, output_path: str = "deployment_summary.xlsx"):
        """Generate comprehensive deployment summary report"""
        try:
            # Get data
            users = self.graph_client.get_users()
            groups = self.graph_client.get_groups()
            licenses = self.graph_client.get_licenses()
            
            # Create summary statistics
            summary_data = {
                'Total_Users': len(users),
                'Enabled_Users': len([u for u in users if u.get('accountEnabled', False)]),
                'Licensed_Users': len([u for u in users if u.get('assignedLicenses')]),
                'Total_Groups': len(groups),
                'Security_Groups': len([g for g in groups if g.get('securityEnabled', False)]),
                'License_Types': len(licenses),
                'Report_Generated': datetime.datetime.now().isoformat()
            }
            
            # Create DataFrames
            users_df = pd.json_normalize(users)
            groups_df = pd.json_normalize(groups)
            licenses_df = pd.json_normalize(licenses)
            summary_df = pd.DataFrame([summary_data])
            
            # Write to Excel with multiple sheets
            with pd.ExcelWriter(output_path, engine='openpyxl') as writer:
                summary_df.to_excel(writer, sheet_name='Summary', index=False)
                users_df.to_excel(writer, sheet_name='Users', index=False)
                groups_df.to_excel(writer, sheet_name='Groups', index=False)
                licenses_df.to_excel(writer, sheet_name='Licenses', index=False)
            
            logger.info(f"Deployment summary report saved to: {output_path}")
            return output_path
            
        except Exception as e:
            logger.error(f"Failed to generate deployment summary: {e}")
            raise

def main():
    """Main execution function"""
    parser = argparse.ArgumentParser(description='Microsoft 365 Deployment Python Tools')
    parser.add_argument('--config', '-c', help='Configuration file path', default='config.json')
    parser.add_argument('--action', '-a', choices=['migrate-users', 'license-report', 'deployment-summary'], 
                       required=True, help='Action to perform')
    parser.add_argument('--input', '-i', help='Input file path (for migrations)')
    parser.add_argument('--output', '-o', help='Output file path', default='output.xlsx')
    parser.add_argument('--dry-run', action='store_true', help='Perform dry run without making changes')
    
    args = parser.parse_args()
    
    try:
        # Load configuration
        if os.path.exists(args.config):
            config = M365Config.from_file(args.config)
        else:
            logger.info("Config file not found, loading from environment variables")
            config = M365Config.from_env()
        
        # Validate configuration
        if not all([config.tenant_id, config.client_id, config.client_secret]):
            logger.error("Missing required configuration. Check config file or environment variables.")
            sys.exit(1)
        
        # Initialize Graph API client
        graph_client = GraphAPIClient(config)
        
        # Execute requested action
        if args.action == 'migrate-users':
            if not args.input:
                logger.error("Input file required for user migration")
                sys.exit(1)
            
            migration_tool = UserMigrationTool(graph_client)
            user_df = migration_tool.load_users_from_csv(args.input)
            users_to_create = migration_tool.validate_user_data(user_df)
            
            if args.dry_run:
                logger.info(f"DRY RUN: Would create {len(users_to_create)} users")
            else:
                results = migration_tool.bulk_create_users(users_to_create)
                
                # Save results
                results_df = pd.json_normalize(results)
                results_df.to_excel(args.output, index=False)
                logger.info(f"Migration results saved to: {args.output}")
        
        elif args.action == 'license-report':
            license_manager = LicenseManager(graph_client)
            report_df = license_manager.generate_license_report()
            report_df.to_excel(args.output, index=False)
            logger.info(f"License report saved to: {args.output}")
        
        elif args.action == 'deployment-summary':
            report_generator = ReportGenerator(graph_client)
            report_path = report_generator.generate_deployment_summary(args.output)
            logger.info(f"Deployment summary report generated: {report_path}")
        
        logger.info("Script execution completed successfully")
        
    except Exception as e:
        logger.error(f"Script execution failed: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()