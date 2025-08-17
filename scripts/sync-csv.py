#!/usr/bin/env python3
"""
EO Framework CSV Sync
Syncs repository templates with website CSV format.
"""

import csv
import yaml
from pathlib import Path

def sync_to_csv():
    """Generate CSV file for website integration"""
    repo_root = Path(__file__).parent.parent
    csv_data = []
    
    # CSV headers matching website format
    headers = ['Provider', 'Category', 'Solution Name', 'Description', 'Pre Sales Templates', 'Delivery Templates', 'Status']
    
    # Scan all templates
    providers_path = repo_root / "providers"
    if providers_path.exists():
        for provider_path in providers_path.iterdir():
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
                                        
                                        # Build URLs for templates
                                        base_url = "https://github.com/eoframework/templates/tree/main"
                                        presales_url = f"{base_url}/providers/{provider_name}/{category_name}/{solution_name}/presales"
                                        delivery_url = f"{base_url}/providers/{provider_name}/{category_name}/{solution_name}/delivery"
                                        
                                        csv_row = [
                                            metadata.get('provider', provider_name).title(),
                                            metadata.get('category', category_name).title().replace('-', ' '),
                                            metadata.get('solution_name', solution_name.title().replace('-', ' ')),
                                            metadata.get('description', ''),
                                            presales_url,
                                            delivery_url,
                                            metadata.get('status', 'Active')
                                        ]
                                        csv_data.append(csv_row)
                                        
                                    except Exception as e:
                                        print(f"Warning: Could not process {solution_path}: {e}")
    
    # Write CSV file
    csv_path = repo_root / 'templates.csv'
    with open(csv_path, 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(headers)
        writer.writerows(csv_data)
    
    print(f"✅ Generated CSV with {len(csv_data)} templates")
    return csv_path

if __name__ == "__main__":
    sync_to_csv()