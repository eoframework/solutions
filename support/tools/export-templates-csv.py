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

def sync_to_csv():
    """Generate CSV file for website integration"""
    repo_root = Path(__file__).parent.parent.parent  # Go up to repository root
    csv_data = []
    
    # CSV headers matching website format
    headers = ['Provider', 'Category', 'Solution Name', 'Description', 'Templates', 'Status']
    
    # Special capitalization mappings
    def format_name(name):
        """Apply special capitalization rules"""
        # Handle special cases
        special_cases = {
            'ai': 'AI',
            'aws': 'AWS', 
            'ibm': 'IBM',
            'devops': 'DevOps',
            'cicd': 'CI/CD',
            'ci': 'CI',
            'api': 'API',
            'ui': 'UI',
            'siem': 'SIEM',
            'wan': 'WAN',
            'm365': 'M365'
        }
        
        # Split on common separators and process each part
        parts = name.lower().replace('-', ' ').replace('_', ' ').split()
        formatted_parts = []
        
        for part in parts:
            if part in special_cases:
                formatted_parts.append(special_cases[part])
            else:
                formatted_parts.append(part.title())
        
        return ' '.join(formatted_parts)
    
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
                                        
                                        csv_row = [
                                            format_name(metadata.get('provider', provider_name)),
                                            format_name(metadata.get('category', category_name)),
                                            format_name(metadata.get('solution_name', solution_name)),
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