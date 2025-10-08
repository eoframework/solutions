#!/usr/bin/env python3
"""
EO Framework™ CSV Sync
Syncs repository templates with website CSV format.
Supports both private (internal) and public (distribution) output modes.

Copyright (c) 2025 EO Framework™
Licensed under BSL 1.1 - see LICENSE file for details
"""

import csv
import yaml
import argparse
from pathlib import Path

def load_display_names(repo_root):
    """Load provider and category display names from catalog files"""
    provider_names = {}
    category_names = {}
    
    # Load provider display names
    providers_path = repo_root / "support" / "catalog" / "providers"
    if providers_path.exists():
        for provider_file in providers_path.glob("*.yml"):
            try:
                with open(provider_file, 'r') as f:
                    catalog = yaml.safe_load(f)
                    provider_id = catalog.get('provider')
                    provider_name = catalog.get('metadata', {}).get('provider_name')
                    if provider_id and provider_name:
                        provider_names[provider_id] = provider_name
            except Exception as e:
                print(f"Warning: Could not load provider catalog {provider_file}: {e}")
    
    # Load category display names
    categories_path = repo_root / "support" / "catalog" / "categories"
    if categories_path.exists():
        for category_file in categories_path.glob("*.yml"):
            try:
                with open(category_file, 'r') as f:
                    catalog = yaml.safe_load(f)
                    category_id = catalog.get('category')
                    category_name = catalog.get('metadata', {}).get('category_name')
                    if category_id and category_name:
                        category_names[category_id] = category_name
            except Exception as e:
                print(f"Warning: Could not load category catalog {category_file}: {e}")
    
    return provider_names, category_names

def sync_to_csv(output_type='private'):
    """Generate CSV file for website integration

    Args:
        output_type: 'private' for internal paths or 'public' for distribution URLs
    """
    repo_root = Path(__file__).parent.parent.parent  # Go up to repository root
    csv_data = []

    # Load display names from catalog files
    provider_names, category_names = load_display_names(repo_root)

    # CSV headers based on output type
    if output_type == 'private':
        headers = ['Provider', 'Category', 'SolutionName', 'Description', 'Templates', 'Status']
    else:  # public
        headers = ['Provider', 'Category', 'SolutionName', 'Description', 'Version', 'DownloadUrl', 'ManifestUrl', 'Website', 'SupportEmail', 'Status']
    
    # Scan all templates
    solutions_path = repo_root / "solutions"
    if solutions_path.exists():
        for provider_path in solutions_path.iterdir():
            if provider_path.is_dir():
                provider_name = provider_path.name
                
                for category_path in provider_path.iterdir():
                    if category_path.is_dir():
                        category_name = category_path.name
                        
                        for solution_path in category_path.iterdir():
                            if solution_path.is_dir():
                                solution_name = solution_path.name
                                metadata_path = solution_path / 'metadata.yml'
                                
                                if metadata_path.exists():
                                    try:
                                        with open(metadata_path, 'r') as f:
                                            metadata = yaml.safe_load(f)
                                        
                                        # Get display names, fall back to raw names if not found
                                        provider_display = provider_names.get(provider_name, provider_name)
                                        category_display = category_names.get(category_name, category_name)
                                        solution_display = metadata.get('solution_display_name', metadata.get('solution_name', solution_name))
                                        description = metadata.get('description', '')
                                        version = metadata.get('version', '1.0.0')
                                        status = metadata.get('status', 'Active')

                                        if output_type == 'private':
                                            # Build URLs for templates - internal repo
                                            base_url = "https://github.com/eoframework/solutions/tree/main"
                                            solution_url = f"{base_url}/solutions/{provider_name}/{category_name}/{solution_name}"

                                            csv_row = [
                                                provider_display,
                                                category_display,
                                                solution_display,
                                                description,
                                                solution_url,
                                                status
                                            ]
                                        else:  # public
                                            # Build URLs for public distribution
                                            base_url = "https://github.com/eoframework/public-assets/raw/main"
                                            solution_path = f"solutions/{provider_name}/{category_name}/{solution_name}"
                                            download_url = f"{base_url}/{solution_path}/latest/{solution_name}.zip"
                                            manifest_url = f"{base_url}/{solution_path}/manifest.json"
                                            website = "https://eoframework.com/solutions"
                                            support_email = "support@eoframework.com"

                                            csv_row = [
                                                provider_display,
                                                category_display,
                                                solution_display,
                                                description,
                                                version,
                                                download_url,
                                                manifest_url,
                                                website,
                                                support_email,
                                                status
                                            ]

                                        csv_data.append(csv_row)
                                        
                                    except Exception as e:
                                        print(f"Warning: Could not process {solution_path}: {e}")
    
    # Write CSV file to exports directory
    if output_type == 'private':
        csv_path = repo_root / 'support' / 'exports' / 'solutions.csv'
    else:  # public
        csv_path = repo_root / 'support' / 'exports' / 'solutions-public.csv'

    csv_path.parent.mkdir(parents=True, exist_ok=True)

    with open(csv_path, 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(headers)
        writer.writerows(csv_data)

    print(f"✅ Generated {output_type} CSV with {len(csv_data)} templates")
    print(f"📁 Created: {csv_path}")
    return csv_path

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Export EO Framework solutions to CSV')
    parser.add_argument('--output-type', choices=['private', 'public'], default='private',
                       help='Output type: private (internal) or public (distribution)')
    args = parser.parse_args()

    sync_to_csv(output_type=args.output_type)