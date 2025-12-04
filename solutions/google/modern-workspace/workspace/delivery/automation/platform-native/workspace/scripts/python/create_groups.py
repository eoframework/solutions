#!/usr/bin/env python3
"""
Create Groups
EO Framework - Google Workspace Solution

Creates default security groups from configuration.
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

# Required scopes
SCOPES = [
    'https://www.googleapis.com/auth/admin.directory.group',
]


def get_directory_service(config: dict):
    """Initialize the Admin SDK Directory service."""
    credentials = service_account.Credentials.from_service_account_file(
        config.get('credentials_path', 'config/credentials.json'),
        scopes=SCOPES
    )

    delegated_credentials = credentials.with_subject(
        config['workspace']['admin_email']
    )

    return build('admin', 'directory_v1', credentials=delegated_credentials)


def create_group(service, domain: str, name: str, dry_run: bool = False) -> bool:
    """Create a single group."""
    email = f"{name}@{domain}"

    group_body = {
        'email': email,
        'name': name.replace('-', ' ').title(),
        'description': f"EO Framework created group: {name}",
    }

    if dry_run:
        console.print(f"  [yellow]DRY RUN: Would create group {email}[/yellow]")
        return True

    try:
        service.groups().insert(body=group_body).execute()
        console.print(f"  [green]Created group: {email}[/green]")
        return True
    except HttpError as e:
        if e.resp.status == 409:
            console.print(f"  [yellow]Group already exists: {email}[/yellow]")
            return True
        else:
            console.print(f"  [red]Error creating group {name}: {e}[/red]")
            return False


def create_groups(config: dict) -> bool:
    """Create all default groups from configuration."""
    dry_run = config.get('dry_run', False)

    groups_config = config.get('groups', {})
    if not groups_config.get('create_default_groups', False):
        console.print("[yellow]Group creation disabled in config[/yellow]")
        return True

    if dry_run:
        console.print("[yellow]DRY RUN MODE - No changes will be made[/yellow]")
        default_groups = groups_config.get('default_groups', [])
        for group_name in default_groups:
            console.print(f"  [yellow]Would create: {group_name}[/yellow]")
        return True

    service = get_directory_service(config)
    domain = config['workspace']['domain']

    default_groups = groups_config.get('default_groups', [])

    success = True
    for group_name in default_groups:
        if not create_group(service, domain, group_name, dry_run):
            success = False

    return success


def main():
    parser = argparse.ArgumentParser(
        description="Create Google Workspace Groups"
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

    success = create_groups(config)
    exit(0 if success else 1)


if __name__ == "__main__":
    main()
