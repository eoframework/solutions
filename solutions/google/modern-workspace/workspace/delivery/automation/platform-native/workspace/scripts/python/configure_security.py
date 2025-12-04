#!/usr/bin/env python3
"""
Configure Security Settings
EO Framework - Google Workspace Solution

Configures security policies including:
- 2-Step Verification (MFA)
- Mobile Device Management
- Context-Aware Access
- Session controls
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
    'https://www.googleapis.com/auth/admin.directory.user.security',
    'https://www.googleapis.com/auth/admin.directory.device.mobile',
]


def get_admin_service(config: dict, api_name: str = 'admin', api_version: str = 'directory_v1'):
    """Initialize the Admin SDK service."""
    credentials = service_account.Credentials.from_service_account_file(
        config.get('credentials_path', 'config/credentials.json'),
        scopes=SCOPES
    )

    delegated_credentials = credentials.with_subject(
        config['workspace']['admin_email']
    )

    return build(api_name, api_version, credentials=delegated_credentials)


def configure_2sv_policy(config: dict) -> bool:
    """Configure 2-Step Verification (MFA) policy."""
    dry_run = config.get('dry_run', False)
    identity = config.get('identity', {})

    mfa_enabled = identity.get('mfa_enabled', False)
    mfa_enforcement = identity.get('mfa_enforcement', 'OPTIONAL')
    mfa_methods = identity.get('mfa_methods', 'Any')

    console.print("[blue]Configuring 2-Step Verification Policy[/blue]")
    console.print(f"  Enabled: {mfa_enabled}")
    console.print(f"  Enforcement: {mfa_enforcement}")
    console.print(f"  Methods: {mfa_methods}")

    if dry_run:
        console.print("[yellow]DRY RUN: 2SV settings would be applied[/yellow]")
        return True

    # Note: 2SV enforcement is typically configured via Admin Console or
    # Security APIs which require specific organizational unit targeting
    console.print("[yellow]Note: 2SV enforcement must be configured in Admin Console[/yellow]")
    console.print("[yellow]Navigate to: Security > Authentication > 2-Step Verification[/yellow]")

    policy_summary = {
        'enforcement_level': mfa_enforcement,
        'allowed_methods': mfa_methods,
        'new_user_enrollment_period': '7 days' if mfa_enforcement == 'ENFORCED' else 'N/A',
        'grace_period': '7 days',
    }

    console.print("[green]Recommended 2SV Policy:[/green]")
    for key, value in policy_summary.items():
        console.print(f"  {key}: {value}")

    return True


def configure_mobile_management(config: dict) -> bool:
    """Configure Mobile Device Management (MDM) settings."""
    dry_run = config.get('dry_run', False)
    security = config.get('security', {})

    mdm_level = security.get('mobile_management', 'Basic')
    require_passcode = security.get('mdm_require_passcode', True)
    passcode_length = security.get('mdm_passcode_length', 6)
    remote_wipe = security.get('mdm_remote_wipe', True)

    console.print("[blue]Configuring Mobile Device Management[/blue]")
    console.print(f"  Management Level: {mdm_level}")
    console.print(f"  Require Passcode: {require_passcode}")
    console.print(f"  Passcode Length: {passcode_length}")
    console.print(f"  Remote Wipe: {remote_wipe}")

    if dry_run:
        console.print("[yellow]DRY RUN: MDM settings would be applied[/yellow]")
        return True

    # MDM configuration via API
    console.print("[yellow]Note: MDM policies configured in Admin Console[/yellow]")
    console.print("[yellow]Navigate to: Devices > Mobile & endpoints > Settings[/yellow]")

    mdm_policy = {
        'require_screen_lock': require_passcode,
        'min_passcode_length': passcode_length,
        'allow_camera': True,
        'allow_screen_capture': True,
        'require_encryption': True,
        'remote_wipe_enabled': remote_wipe,
        'inactivity_wipe_days': 90 if mdm_level == 'Advanced' else None,
        'block_rooted_devices': mdm_level == 'Advanced',
    }

    console.print("[green]Recommended MDM Policy:[/green]")
    for key, value in mdm_policy.items():
        if value is not None:
            console.print(f"  {key}: {value}")

    return True


def configure_context_aware_access(config: dict) -> bool:
    """Configure Context-Aware Access policies."""
    dry_run = config.get('dry_run', False)
    security = config.get('security', {})

    caa_enabled = security.get('context_aware_access', False)

    console.print("[blue]Configuring Context-Aware Access[/blue]")
    console.print(f"  Enabled: {caa_enabled}")

    if not caa_enabled:
        console.print("[yellow]Context-Aware Access is disabled[/yellow]")
        return True

    if dry_run:
        console.print("[yellow]DRY RUN: CAA settings would be applied[/yellow]")
        return True

    console.print("[yellow]Note: Context-Aware Access configured in Admin Console[/yellow]")
    console.print("[yellow]Navigate to: Security > Access and data control > Context-Aware Access[/yellow]")

    # Recommended CAA policies
    caa_policies = [
        {
            'name': 'Corporate Network Only',
            'description': 'Allow access only from corporate IP ranges',
            'conditions': ['IP address in corporate range'],
            'apps': ['All Google Apps'],
        },
        {
            'name': 'Managed Devices Only',
            'description': 'Require managed device for sensitive apps',
            'conditions': ['Device is company-owned or managed'],
            'apps': ['Drive', 'Gmail', 'Calendar'],
        },
        {
            'name': 'Require 2SV',
            'description': 'Require 2-Step Verification for access',
            'conditions': ['2SV is enrolled'],
            'apps': ['Admin console'],
        },
    ]

    console.print("[green]Recommended CAA Policies:[/green]")
    for policy in caa_policies:
        console.print(f"  - {policy['name']}: {policy['description']}")

    return True


def configure_sharing_settings(config: dict) -> bool:
    """Configure external sharing policies."""
    dry_run = config.get('dry_run', False)
    sharing = config.get('sharing', {})

    external_sharing = sharing.get('external_sharing', 'Disabled')
    allow_domains = sharing.get('allow_domains', [])
    link_default = sharing.get('link_sharing_default', 'Private')

    console.print("[blue]Configuring Sharing Settings[/blue]")
    console.print(f"  External Sharing: {external_sharing}")
    console.print(f"  Allowed Domains: {allow_domains}")
    console.print(f"  Link Default: {link_default}")

    if dry_run:
        console.print("[yellow]DRY RUN: Sharing settings would be applied[/yellow]")
        return True

    console.print("[yellow]Note: Sharing settings configured in Admin Console[/yellow]")
    console.print("[yellow]Navigate to: Apps > Google Workspace > Drive and Docs > Sharing settings[/yellow]")

    sharing_policy = {
        'sharing_outside_domain': external_sharing,
        'allowed_external_domains': allow_domains if external_sharing == 'Whitelist' else [],
        'default_link_sharing': link_default,
        'warn_on_external_sharing': True,
        'require_domain_for_external_invites': external_sharing == 'Whitelist',
    }

    console.print("[green]Sharing Policy Configuration:[/green]")
    for key, value in sharing_policy.items():
        console.print(f"  {key}: {value}")

    return True


def configure_security(config: dict) -> bool:
    """Main security configuration function."""
    success = True

    console.print("")
    if not configure_2sv_policy(config):
        success = False

    console.print("")
    if not configure_mobile_management(config):
        success = False

    console.print("")
    if not configure_context_aware_access(config):
        success = False

    console.print("")
    if not configure_sharing_settings(config):
        success = False

    return success


def main():
    parser = argparse.ArgumentParser(
        description="Configure Google Workspace Security Settings"
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

    success = configure_security(config)
    exit(0 if success else 1)


if __name__ == "__main__":
    main()
