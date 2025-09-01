#!/usr/bin/env python3
"""
EO Framework™ CSV Sync
Syncs repository templates with website CSV format.

Copyright (c) 2025 EO Framework™
Licensed under BSL 1.1 - see LICENSE file for details
"""

import csv
import yaml
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

def sync_to_csv():
    """Generate CSV file for website integration"""
    repo_root = Path(__file__).parent.parent.parent  # Go up to repository root
    csv_data = []
    
    # Load display names from catalog files
    provider_names, category_names = load_display_names(repo_root)
    
    # CSV headers matching website format
    headers = ['Provider', 'Category', 'Solution Name', 'Description', 'Templates', 'Status']
    
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
                                        
                                        # Build URLs for templates - combine into single Templates column
                                        base_url = "https://github.com/eoframework/templates/tree/main"
                                        solution_url = f"{base_url}/solutions/{provider_name}/{category_name}/{solution_name}"
                                        
                                        # Get display names, fall back to raw names if not found
                                        provider_display = provider_names.get(provider_name, provider_name)
                                        category_display = category_names.get(category_name, category_name)
                                        
                                        csv_row = [
                                            provider_display,
                                            category_display,
                                            metadata.get('solution_name', solution_name),
                                            metadata.get('description', ''),
                                            solution_url,
                                            metadata.get('status', 'Active')
                                        ]
                                        csv_data.append(csv_row)
                                        
                                    except Exception as e:
                                        print(f"Warning: Could not process {solution_path}: {e}")
    
    # Write CSV file to exports directory
    csv_path = repo_root / 'support' / 'exports' / 'templates.csv'
    with open(csv_path, 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(headers)
        writer.writerows(csv_data)
    
    print(f"✅ Generated CSV with {len(csv_data)} templates")
    print(f"📁 Created: {csv_path}")
    return csv_path

if __name__ == "__main__":
    sync_to_csv()