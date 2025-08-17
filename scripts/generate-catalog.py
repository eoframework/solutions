#!/usr/bin/env python3
"""
EO Framework Catalog Generator
Generates CATALOG.yml from all templates in the repository.
"""

import yaml
from pathlib import Path
from datetime import datetime

def generate_catalog():
    """Generate catalog from all templates"""
    repo_root = Path(__file__).parent.parent
    catalog = {
        'generated_at': datetime.now().isoformat(),
        'version': '1.0',
        'providers': {}
    }
    
    # Scan all provider directories
    providers_path = repo_root / "providers"
    if providers_path.exists():
        for provider_path in providers_path.iterdir():
            if provider_path.is_dir():
                provider_name = provider_path.name
                catalog['providers'][provider_name] = {'categories': {}}
                
                # Scan categories
                for category_path in provider_path.iterdir():
                    if category_path.is_dir():
                        category_name = category_path.name
                        catalog['providers'][provider_name]['categories'][category_name] = {'solutions': {}}
                        
                        # Scan solutions
                        for solution_path in category_path.iterdir():
                            if solution_path.is_dir():
                                solution_name = solution_path.name
                                metadata_path = solution_path / 'metadata.yml'
                                
                                if metadata_path.exists():
                                    try:
                                        with open(metadata_path, 'r') as f:
                                            metadata = yaml.safe_load(f)
                                        
                                        catalog['providers'][provider_name]['categories'][category_name]['solutions'][solution_name] = {
                                            'name': metadata.get('solution_name', solution_name),
                                            'description': metadata.get('description', ''),
                                            'version': metadata.get('version', '1.0.0'),
                                            'status': metadata.get('status', 'Active'),
                                            'tags': metadata.get('tags', []),
                                            'maintainers': metadata.get('maintainers', []),
                                            'path': f"providers/{provider_name}/{category_name}/{solution_name}"
                                        }
                                    except Exception as e:
                                        print(f"Warning: Could not read metadata for {solution_path}: {e}")
    
    # Write catalog
    catalog_path = repo_root / 'CATALOG.yml'
    with open(catalog_path, 'w') as f:
        yaml.dump(catalog, f, default_flow_style=False, sort_keys=True)
    
    print(f"✅ Generated catalog with {count_templates(catalog)} templates")
    return catalog_path

def count_templates(catalog):
    """Count total templates in catalog"""
    count = 0
    for provider in catalog['providers'].values():
        for category in provider['categories'].values():
            count += len(category['solutions'])
    return count

if __name__ == "__main__":
    generate_catalog()