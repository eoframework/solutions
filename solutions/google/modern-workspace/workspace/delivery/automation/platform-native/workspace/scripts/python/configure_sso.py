#!/usr/bin/env python3
"""
Configure SSO (SAML)
EO Framework - Google Workspace Solution

Configures SAML SSO integration with identity providers (Azure AD, Okta, ADFS).
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

# Required scopes for Admin SDK
SCOPES = [
    'https://www.googleapis.com/auth/admin.directory.domain',
]


def get_admin_service(config: dict):
    """Initialize the Admin SDK service."""
    credentials = service_account.Credentials.from_service_account_file(
        config.get('credentials_path', 'config/credentials.json'),
        scopes=SCOPES
    )

    delegated_credentials = credentials.with_subject(
        config['workspace']['admin_email']
    )

    return build('admin', 'directory_v1', credentials=delegated_credentials)


def configure_saml_sso(config: dict) -> bool:
    """Configure SAML SSO based on IdP type."""
    dry_run = config.get('dry_run', False)
    identity = config.get('identity', {})

    if not identity.get('sso_enabled', False):
        console.print("[yellow]SSO is disabled in configuration[/yellow]")
        return True

    idp_type = identity.get('idp_type', 'None')
    if idp_type == 'None':
        console.print("[yellow]No IdP type configured, skipping SSO[/yellow]")
        return True

    console.print(f"[blue]Configuring SSO for IdP: {idp_type}[/blue]")

    # Validate required SSO configuration
    required_fields = ['idp_entity_id', 'idp_sso_url', 'idp_certificate']
    missing_fields = [f for f in required_fields if not identity.get(f) or identity.get(f).startswith('[')]

    if missing_fields:
        console.print(f"[yellow]Missing SSO configuration fields: {missing_fields}[/yellow]")
        console.print("[yellow]Please update the configuration with actual values[/yellow]")
        if dry_run:
            return True
        return False

    sso_config = {
        'entity_id': identity.get('idp_entity_id'),
        'sso_url': identity.get('idp_sso_url'),
        'certificate': identity.get('idp_certificate'),
        'idp_type': idp_type,
    }

    if dry_run:
        console.print("[yellow]DRY RUN MODE - No changes will be made[/yellow]")
        console.print(f"  [yellow]Would configure SSO with {idp_type}[/yellow]")
        console.print(f"  [yellow]Entity ID: {sso_config['entity_id']}[/yellow]")
        console.print(f"  [yellow]SSO URL: {sso_config['sso_url']}[/yellow]")
        return True

    # Note: Google Workspace SSO configuration is done through the Admin Console
    # The Admin SDK doesn't directly support SSO configuration
    # This script generates the configuration for manual or API-based setup

    console.print("[blue]SSO Configuration Summary:[/blue]")
    console.print(f"  IdP Type: {idp_type}")
    console.print(f"  Entity ID: {sso_config['entity_id']}")
    console.print(f"  SSO URL: {sso_config['sso_url']}")
    console.print("")
    console.print("[yellow]Note: SAML SSO must be configured in Google Admin Console[/yellow]")
    console.print("[yellow]Navigate to: Security > Authentication > SSO with third party IdP[/yellow]")
    console.print("")

    # Generate SAML configuration instructions
    generate_sso_instructions(config, sso_config)

    return True


def generate_sso_instructions(config: dict, sso_config: dict):
    """Generate SSO setup instructions."""
    domain = config['workspace']['domain']
    idp_type = sso_config['idp_type']

    console.print("[bold]SSO Setup Instructions:[/bold]")
    console.print("")

    if idp_type == 'Azure AD':
        console.print("1. In Azure AD:")
        console.print("   - Create Enterprise Application for Google Workspace")
        console.print("   - Configure SAML with Google Workspace ACS URL")
        console.print(f"   - Set Entity ID to: google.com/{domain}")
        console.print("   - Map user attributes (email, name)")
        console.print("")
        console.print("2. In Google Admin Console:")
        console.print("   - Go to Security > Authentication > SSO with third party IdP")
        console.print("   - Enable 'Set up SSO with third party identity provider'")
        console.print(f"   - Sign-in page URL: {sso_config['sso_url']}")
        console.print(f"   - Sign-out page URL: (Azure AD logout URL)")
        console.print("   - Upload verification certificate")

    elif idp_type == 'Okta':
        console.print("1. In Okta:")
        console.print("   - Add Google Workspace application from catalog")
        console.print(f"   - Configure domain: {domain}")
        console.print("   - Enable SAML 2.0")
        console.print("")
        console.print("2. In Google Admin Console:")
        console.print("   - Go to Security > Authentication > SSO with third party IdP")
        console.print("   - Use Okta-provided SSO URL and certificate")

    elif idp_type == 'ADFS':
        console.print("1. In ADFS:")
        console.print("   - Add Relying Party Trust for Google Workspace")
        console.print(f"   - Configure identifier: google.com/{domain}")
        console.print("   - Add claim rules for email and name")
        console.print("")
        console.print("2. In Google Admin Console:")
        console.print("   - Go to Security > Authentication > SSO with third party IdP")
        console.print("   - Enter ADFS federation service URL")
        console.print("   - Upload ADFS token-signing certificate")

    console.print("")
    console.print("[green]Google Workspace SAML Configuration Values:[/green]")
    console.print(f"  ACS URL: https://www.google.com/a/{domain}/acs")
    console.print(f"  Entity ID: google.com/{domain}")
    console.print(f"  Start URL: https://www.google.com/a/{domain}")


def configure_sso(config: dict) -> bool:
    """Main SSO configuration function."""
    return configure_saml_sso(config)


def main():
    parser = argparse.ArgumentParser(
        description="Configure Google Workspace SAML SSO"
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

    success = configure_sso(config)
    exit(0 if success else 1)


if __name__ == "__main__":
    main()
