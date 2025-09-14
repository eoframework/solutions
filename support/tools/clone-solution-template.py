#!/usr/bin/env python3
"""
EO Framework™ Template Cloner
Creates a new solution template from the master template.

Copyright (c) 2025 EO Framework™
Licensed under BSL 1.1 - see LICENSE file for details
"""

import os
import shutil
import argparse
import yaml
from pathlib import Path
from datetime import datetime

def normalize_name(name):
    """Convert name to lowercase with hyphens"""
    return name.lower().replace(' ', '-').replace('_', '-')

def validate_inputs(provider, category, solution):
    """Validate input parameters"""
    valid_providers = [
        'aws', 'azure', 'google', 'microsoft', 'ibm', 
        'hashicorp', 'github', 'nvidia', 'dell', 'juniper', 'cisco'
    ]
    valid_categories = ['ai', 'cloud', 'cyber-security', 'devops', 'modern-workspace', 'network']
    
    if provider not in valid_providers:
        print(f"Warning: '{provider}' is not in standard providers list: {valid_providers}")
    
    if category not in valid_categories:
        print(f"Warning: '{category}' is not in standard categories list: {valid_categories}")
    
    return True

def clone_template(provider, category, solution, author_name, author_email):
    """Clone the master template to create a new solution"""
    
    # Normalize names
    provider = normalize_name(provider)
    category = normalize_name(category)
    solution = normalize_name(solution)
    
    # Validate inputs
    validate_inputs(provider, category, solution)
    
    # Define paths
    repo_root = Path(__file__).parent.parent.parent
    sample_path = repo_root / "solution-template" / "sample-provider" / "sample-category" / "sample-solution"
    target_path = repo_root / "solutions" / provider / category / solution
    
    # Check if solution template exists
    if not sample_path.exists():
        raise FileNotFoundError(f"Sample template not found at {sample_path}")
    
    # Check if target already exists
    if target_path.exists():
        raise FileExistsError(f"Template already exists at {target_path}")
    
    # Create provider and category directories if they don't exist
    target_path.parent.mkdir(parents=True, exist_ok=True)
    
    # Copy solution template
    print(f"Cloning template to {target_path}")
    shutil.copytree(sample_path, target_path)
    
    # Update metadata.yml
    metadata_path = target_path / "metadata.yml"
    if metadata_path.exists():
        with open(metadata_path, 'r') as f:
            metadata = yaml.safe_load(f)
        
        # Update metadata fields
        metadata['provider'] = provider.title()
        metadata['category'] = category.title().replace('-', ' ')
        metadata['solution_name'] = solution.title().replace('-', ' ')
        metadata['description'] = f"Brief description of {solution.replace('-', ' ')} solution"
        metadata['maintainers'][0]['name'] = author_name
        metadata['maintainers'][0]['email'] = author_email
        metadata['changelog'][0]['date'] = datetime.now().strftime('%Y-%m-%d')
        metadata['changelog'][0]['author'] = author_name
        
        # Write updated metadata
        with open(metadata_path, 'w') as f:
            yaml.dump(metadata, f, default_flow_style=False, sort_keys=False)
    
    # Update README.md
    readme_path = target_path / "README.md"
    if readme_path.exists():
        with open(readme_path, 'r') as f:
            content = f.read()
        
        content = content.replace("Sample Solution Template", f"{solution.title().replace('-', ' ')} Solution")
        content = content.replace("sample solution", f"{solution.replace('-', ' ')} solution")
        
        with open(readme_path, 'w') as f:
            f.write(content)
    
    print(f"✅ Successfully created new template: solutions/{provider}/{category}/{solution}")
    print(f"📝 Next steps:")
    print(f"   1. Review and update {target_path}/metadata.yml")
    print(f"   2. Update {target_path}/README.md with solution details")
    print(f"   3. Add presales materials to {target_path}/presales/")
    print(f"   4. Add delivery materials to {target_path}/delivery/")
    print(f"   5. Test all automation scripts")
    print(f"   6. Submit pull request for review")
    
    return target_path

def main():
    parser = argparse.ArgumentParser(description='Create a new EO Framework™ solution template')
    parser.add_argument('--provider', required=True, help='Provider name (e.g., AWS, Microsoft)')
    parser.add_argument('--category', required=True, help='Category name (e.g., Cloud, DevOps)')
    parser.add_argument('--solution', required=True, help='Solution name (e.g., EC2 Compute)')
    parser.add_argument('--author-name', required=True, help='Template author name')
    parser.add_argument('--author-email', required=True, help='Template author email')
    
    args = parser.parse_args()
    
    try:
        clone_template(
            args.provider, 
            args.category, 
            args.solution,
            args.author_name,
            args.author_email
        )
    except Exception as e:
        print(f"❌ Error: {e}")
        return 1
    
    return 0

if __name__ == "__main__":
    exit(main())