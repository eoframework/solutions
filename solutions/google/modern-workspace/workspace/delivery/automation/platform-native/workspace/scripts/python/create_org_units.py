#!/usr/bin/env python3
"""
Create Organizational Units
EO Framework - Google Workspace Solution

Creates OU structure from configuration.
"""

import argparse
import logging

import yaml
from google.oauth2 import service_account
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError
from rich.console import Console

logger = logging.getLogger("workspace-setup")
console = Console()

# Required scopes for Admin SDK Directory API
SCOPES = [
    'https://www.googleapis.com/auth/admin.directory.orgunit',
]


def get_directory_service(config: dict):
    """Initialize the Admin SDK Directory service."""
    credentials = service_account.Credentials.from_service_account_file(
        config.get('credentials_path', 'config/credentials.json'),
        scopes=SCOPES
    )

    # Delegate to admin user
    delegated_credentials = credentials.with_subject(
        config['workspace']['admin_email']
    )

    return build('admin', 'directory_v1', credentials=delegated_credentials)


def create_org_unit(service, customer_id: str, name: str, parent_path: str,
                    dry_run: bool = False) -> bool:
    """Create a single organizational unit."""
    org_unit_body = {
        'name': name,
        'parentOrgUnitPath': parent_path,
    }

    if dry_run:
        console.print(f"  [yellow]DRY RUN: Would create OU {parent_path}/{name}[/yellow]")
        return True

    try:
        service.orgunits().insert(
            customerId=customer_id,
            body=org_unit_body
        ).execute()
        console.print(f"  [green]Created OU: {parent_path}/{name}[/green]")
        return True
    except HttpError as e:
        if e.resp.status == 409:
            console.print(f"  [yellow]OU already exists: {parent_path}/{name}[/yellow]")
            return True
        else:
            console.print(f"  [red]Error creating OU {name}: {e}[/red]")
            return False


def create_org_units(config: dict) -> bool:
    """Create all organizational units from configuration."""
    dry_run = config.get('dry_run', False)

    if dry_run:
        console.print("[yellow]DRY RUN MODE - No changes will be made[/yellow]")
        # In dry run, just simulate success
        org_units = config.get('org_units', {})
        for key, path in org_units.items():
            if key != 'root' and path:
                console.print(f"  [yellow]Would create: {path}[/yellow]")
        return True

    service = get_directory_service(config)
    customer_id = config['workspace']['customer_id']

    # Get OU configuration
    org_units = config.get('org_units', {})

    success = True
    for key, path in org_units.items():
        if key == 'root' or not path:
            continue

        # Parse path to get parent and name
        parts = path.strip('/').split('/')
        name = parts[-1]
        parent_path = '/' + '/'.join(parts[:-1]) if len(parts) > 1 else '/'

        if not create_org_unit(service, customer_id, name, parent_path, dry_run):
            success = False

    return success


def main():
    parser = argparse.ArgumentParser(
        description="Create Google Workspace Organizational Units"
    )
    parser.add_argument(
        "--config", "-c",
        required=True,
        help="Path to configuration YAML file"
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Preview changes without applying"
    )

    args = parser.parse_args()

    with open(args.config, 'r') as f:
        config = yaml.safe_load(f)

    config['dry_run'] = args.dry_run

    success = create_org_units(config)
    exit(0 if success else 1)


if __name__ == "__main__":
    main()
