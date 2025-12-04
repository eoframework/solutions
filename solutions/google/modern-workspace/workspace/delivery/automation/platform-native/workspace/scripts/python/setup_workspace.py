#!/usr/bin/env python3
"""
Google Workspace Setup Script
EO Framework - Google Workspace Solution

Main deployment orchestrator that calls individual configuration scripts.
"""

import argparse
import logging
import sys
from pathlib import Path

import yaml
from rich.console import Console
from rich.logging import RichHandler

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(message)s",
    handlers=[RichHandler(rich_tracebacks=True)]
)
logger = logging.getLogger("workspace-setup")
console = Console()


def load_config(config_path: str) -> dict:
    """Load configuration from YAML file."""
    with open(config_path, 'r') as f:
        return yaml.safe_load(f)


def run_org_units(config: dict) -> bool:
    """Create organizational unit structure."""
    console.print("[bold blue]Creating Organizational Units...[/bold blue]")
    from create_org_units import create_org_units
    return create_org_units(config)


def run_groups(config: dict) -> bool:
    """Create default groups."""
    if not config.get('groups', {}).get('create_default_groups', False):
        console.print("[yellow]Skipping group creation (disabled)[/yellow]")
        return True

    console.print("[bold blue]Creating Groups...[/bold blue]")
    from create_groups import create_groups
    return create_groups(config)


def run_sso(config: dict) -> bool:
    """Configure SSO if enabled."""
    if not config.get('identity', {}).get('sso_enabled', False):
        console.print("[yellow]Skipping SSO configuration (disabled)[/yellow]")
        return True

    console.print("[bold blue]Configuring SSO...[/bold blue]")
    from configure_sso import configure_sso
    return configure_sso(config)


def run_security(config: dict) -> bool:
    """Configure security policies."""
    console.print("[bold blue]Configuring Security Policies...[/bold blue]")
    from configure_security import configure_security
    return configure_security(config)


def run_dlp(config: dict) -> bool:
    """Configure DLP if enabled."""
    if not config.get('security', {}).get('dlp_enabled', False):
        console.print("[yellow]Skipping DLP configuration (disabled)[/yellow]")
        return True

    console.print("[bold blue]Configuring DLP...[/bold blue]")
    from configure_dlp import configure_dlp
    return configure_dlp(config)


def main():
    parser = argparse.ArgumentParser(
        description="Google Workspace Setup - EO Framework"
    )
    parser.add_argument(
        "--config", "-c",
        required=True,
        help="Path to configuration YAML file"
    )
    parser.add_argument(
        "--step", "-s",
        choices=["all", "org-units", "groups", "sso", "security", "dlp"],
        default="all",
        help="Specific step to run (default: all)"
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Preview changes without applying"
    )

    args = parser.parse_args()

    # Load configuration
    try:
        config = load_config(args.config)
        config['dry_run'] = args.dry_run
    except Exception as e:
        console.print(f"[red]Error loading config: {e}[/red]")
        sys.exit(1)

    console.print("[bold green]========================================[/bold green]")
    console.print("[bold green]EO Framework - Google Workspace Setup[/bold green]")
    console.print("[bold green]========================================[/bold green]")
    console.print(f"Domain: {config.get('workspace', {}).get('domain', 'N/A')}")
    console.print(f"Edition: {config.get('workspace', {}).get('edition', 'N/A')}")
    console.print(f"Dry Run: {args.dry_run}")
    console.print()

    # Define steps
    steps = {
        "org-units": run_org_units,
        "groups": run_groups,
        "sso": run_sso,
        "security": run_security,
        "dlp": run_dlp,
    }

    # Run selected steps
    if args.step == "all":
        for name, func in steps.items():
            try:
                success = func(config)
                if not success:
                    console.print(f"[red]Step {name} failed[/red]")
                    sys.exit(1)
                console.print(f"[green]✓ {name} complete[/green]")
            except Exception as e:
                console.print(f"[red]Error in {name}: {e}[/red]")
                sys.exit(1)
    else:
        func = steps.get(args.step)
        if func:
            try:
                success = func(config)
                if not success:
                    sys.exit(1)
            except Exception as e:
                console.print(f"[red]Error: {e}[/red]")
                sys.exit(1)

    console.print()
    console.print("[bold green]========================================[/bold green]")
    console.print("[bold green]Setup Complete![/bold green]")
    console.print("[bold green]========================================[/bold green]")


if __name__ == "__main__":
    main()
