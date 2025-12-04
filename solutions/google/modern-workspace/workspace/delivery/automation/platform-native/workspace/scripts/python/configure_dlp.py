#!/usr/bin/env python3
"""
Configure Data Loss Prevention (DLP)
EO Framework - Google Workspace Solution

Configures DLP rules for data protection:
- PII detection (SSN, credit cards)
- Financial data detection
- Custom pattern rules
- Action policies (warn, block)
"""

import argparse
import logging

import yaml
from google.oauth2 import service_account
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError
from rich.console import Console
from rich.table import Table

logger = logging.getLogger("workspace-setup")
console = Console()

# Required scopes
SCOPES = [
    'https://www.googleapis.com/auth/cloud-platform',
]


def get_dlp_service(config: dict):
    """Initialize the Cloud DLP service."""
    credentials = service_account.Credentials.from_service_account_file(
        config.get('credentials_path', 'config/credentials.json'),
        scopes=SCOPES
    )

    return build('dlp', 'v2', credentials=credentials)


def get_predefined_detectors() -> dict:
    """Return predefined DLP detector configurations."""
    return {
        'pii': {
            'name': 'PII Detection',
            'info_types': [
                'US_SOCIAL_SECURITY_NUMBER',
                'US_DRIVERS_LICENSE_NUMBER',
                'US_PASSPORT',
                'DATE_OF_BIRTH',
                'EMAIL_ADDRESS',
                'PHONE_NUMBER',
            ],
            'description': 'Detect personally identifiable information',
        },
        'financial': {
            'name': 'Financial Data Detection',
            'info_types': [
                'CREDIT_CARD_NUMBER',
                'CREDIT_CARD_TRACK_NUMBER',
                'US_BANK_ROUTING_MICR',
                'IBAN_CODE',
                'SWIFT_CODE',
            ],
            'description': 'Detect financial and payment card data',
        },
        'healthcare': {
            'name': 'Healthcare Data Detection',
            'info_types': [
                'US_DEA_NUMBER',
                'US_HEALTHCARE_NPI',
                'MEDICAL_RECORD_NUMBER',
            ],
            'description': 'Detect healthcare-related information',
        },
        'credentials': {
            'name': 'Credential Detection',
            'info_types': [
                'BASIC_AUTH_HEADER',
                'AUTH_TOKEN',
                'AWS_CREDENTIALS',
                'GCP_CREDENTIALS',
                'ENCRYPTION_KEY',
                'JSON_WEB_TOKEN',
            ],
            'description': 'Detect credentials and API keys',
        },
    }


def build_dlp_rules(config: dict) -> list:
    """Build DLP rules based on configuration."""
    security = config.get('security', {})
    rules = []

    predefined = get_predefined_detectors()

    # PII Detection Rule
    if security.get('dlp_pii_detection', False):
        rules.append({
            'name': 'pii-detection',
            'display_name': predefined['pii']['name'],
            'description': predefined['pii']['description'],
            'info_types': predefined['pii']['info_types'],
            'likelihood': 'LIKELY',
            'action': security.get('dlp_action', 'Warn'),
        })

    # Financial Data Detection
    if security.get('dlp_financial_detection', False):
        rules.append({
            'name': 'financial-detection',
            'display_name': predefined['financial']['name'],
            'description': predefined['financial']['description'],
            'info_types': predefined['financial']['info_types'],
            'likelihood': 'POSSIBLE',
            'action': security.get('dlp_action', 'Warn'),
        })

    # Credential Detection (recommended for all deployments)
    rules.append({
        'name': 'credential-detection',
        'display_name': predefined['credentials']['name'],
        'description': predefined['credentials']['description'],
        'info_types': predefined['credentials']['info_types'],
        'likelihood': 'LIKELY',
        'action': 'Warn and Block',  # Always block credential exposure
    })

    return rules


def display_dlp_rules(rules: list):
    """Display DLP rules in a formatted table."""
    table = Table(title="DLP Rules Configuration")
    table.add_column("Rule Name", style="cyan")
    table.add_column("Info Types", style="green")
    table.add_column("Action", style="yellow")

    for rule in rules:
        info_types_str = ", ".join(rule['info_types'][:3])
        if len(rule['info_types']) > 3:
            info_types_str += f" (+{len(rule['info_types']) - 3} more)"

        table.add_row(
            rule['display_name'],
            info_types_str,
            rule['action']
        )

    console.print(table)


def configure_workspace_dlp(config: dict) -> bool:
    """Configure DLP in Google Workspace."""
    dry_run = config.get('dry_run', False)
    security = config.get('security', {})

    if not security.get('dlp_enabled', False):
        console.print("[yellow]DLP is disabled in configuration[/yellow]")
        return True

    console.print("[blue]Configuring Data Loss Prevention (DLP)[/blue]")
    console.print(f"  Rules Count: {security.get('dlp_rules_count', 0)}")
    console.print(f"  PII Detection: {security.get('dlp_pii_detection', False)}")
    console.print(f"  Financial Detection: {security.get('dlp_financial_detection', False)}")
    console.print(f"  Default Action: {security.get('dlp_action', 'Warn')}")
    console.print("")

    # Build DLP rules
    rules = build_dlp_rules(config)

    if not rules:
        console.print("[yellow]No DLP rules configured[/yellow]")
        return True

    # Display rules
    display_dlp_rules(rules)

    if dry_run:
        console.print("")
        console.print("[yellow]DRY RUN: DLP rules would be applied[/yellow]")
        return True

    # Note: Workspace DLP is configured via Admin Console
    # Cloud DLP API is for scanning content, not policy management
    console.print("")
    console.print("[yellow]Note: Workspace DLP rules configured in Admin Console[/yellow]")
    console.print("[yellow]Navigate to: Security > Data protection > Manage rules[/yellow]")
    console.print("")

    # Generate configuration instructions
    generate_dlp_instructions(config, rules)

    return True


def generate_dlp_instructions(config: dict, rules: list):
    """Generate DLP setup instructions."""
    console.print("[bold]DLP Setup Instructions:[/bold]")
    console.print("")
    console.print("1. Navigate to Admin Console > Security > Data protection")
    console.print("2. Click 'Manage rules' to create new rules")
    console.print("")
    console.print("[green]For each rule listed above:[/green]")
    console.print("   a. Click 'Create rule'")
    console.print("   b. Select rule trigger: 'Content shared externally' or 'Content uploaded'")
    console.print("   c. Add condition: 'Content matches' with the info types")
    console.print("   d. Set action based on the 'Action' column:")
    console.print("      - Warn: Show warning to user")
    console.print("      - Block: Prevent sharing/sending")
    console.print("      - Warn and Block: Show warning and block")
    console.print("")

    # Action mapping
    action_map = {
        'Warn': ['Show warning to user', 'Log incident'],
        'Block': ['Block the action', 'Log incident', 'Send alert to admin'],
        'Warn and Block': ['Show warning to user', 'Block the action', 'Log incident', 'Send alert to admin'],
    }

    console.print("[green]Recommended Actions per Sensitivity:[/green]")
    for action, details in action_map.items():
        console.print(f"  {action}:")
        for detail in details:
            console.print(f"    - {detail}")

    # Vault integration
    security = config.get('security', {})
    if security.get('vault_enabled', False):
        console.print("")
        console.print("[blue]Google Vault Integration:[/blue]")
        console.print("  DLP incidents can be exported to Google Vault for:")
        console.print("  - eDiscovery searches")
        console.print("  - Legal hold on affected content")
        console.print("  - Compliance reporting")


def configure_dlp(config: dict) -> bool:
    """Main DLP configuration function."""
    return configure_workspace_dlp(config)


def main():
    parser = argparse.ArgumentParser(
        description="Configure Google Workspace DLP"
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

    success = configure_dlp(config)
    exit(0 if success else 1)


if __name__ == "__main__":
    main()
