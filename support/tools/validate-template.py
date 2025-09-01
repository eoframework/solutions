#!/usr/bin/env python3
"""
EO Framework™ Template Validator
Validates template structure and metadata compliance.

Copyright (c) 2025 EO Framework™
Licensed under BSL 1.1 - see LICENSE file for details
"""

import os
import yaml
import json
from pathlib import Path
import argparse

class TemplateValidator:
    def __init__(self):
        self.repo_root = Path(__file__).parent.parent.parent
        self.errors = []
        self.warnings = []
        self.authorized_providers = []
        self.authorized_categories = []
        self._load_authorized_lists()
        
    def _load_authorized_lists(self):
        """Load authorized providers and categories from catalog.yml"""
        try:
            catalog_path = self.repo_root / "support" / "catalog" / "catalog.yml"
            if catalog_path.exists():
                with open(catalog_path, 'r') as f:
                    catalog = yaml.safe_load(f)
                
                self.authorized_providers = catalog.get('quick_stats', {}).get('providers_list', [])
                self.authorized_categories = catalog.get('quick_stats', {}).get('categories_list', [])
            else:
                self.warnings.append("catalog.yml not found - skipping authorization validation")
        except Exception as e:
            self.warnings.append(f"Could not load authorization lists: {e}")
    
    def validate_structure(self, template_path):
        """Validate required folder structure"""
        required_files = [
            "README.md",
            "metadata.yml",
            "docs/architecture.md",
            "docs/prerequisites.md", 
            "docs/troubleshooting.md",
            "presales/README.md",
            "delivery/README.md",
            "delivery/scripts/README.md"
        ]
        
        required_dirs = [
            "docs",
            "presales", 
            "delivery",
            "delivery/scripts"
        ]
        
        # Check directories
        for dir_path in required_dirs:
            full_path = template_path / dir_path
            if not full_path.exists() or not full_path.is_dir():
                self.errors.append(f"Missing required directory: {dir_path}")
        
        # Check files
        for file_path in required_files:
            full_path = template_path / file_path
            if not full_path.exists() or not full_path.is_file():
                self.errors.append(f"Missing required file: {file_path}")
    
    def validate_metadata(self, template_path):
        """Validate metadata.yml content"""
        metadata_path = template_path / "metadata.yml"
        
        if not metadata_path.exists():
            self.errors.append("metadata.yml file not found")
            return
        
        try:
            with open(metadata_path, 'r') as f:
                metadata = yaml.safe_load(f)
        except yaml.YAMLError as e:
            self.errors.append(f"Invalid YAML in metadata.yml: {e}")
            return
        
        # Required fields
        required_fields = [
            'provider', 'category', 'solution_name', 'description',
            'version', 'status', 'maintainers', 'tags'
        ]
        
        for field in required_fields:
            if field not in metadata:
                self.errors.append(f"Missing required metadata field: {field}")
        
        # Validate status values
        if 'status' in metadata:
            valid_statuses = ['Active', 'Draft', 'Deprecated']
            if metadata['status'] not in valid_statuses:
                self.errors.append(f"Invalid status: {metadata['status']}. Must be one of {valid_statuses}")
        
        # Validate maintainers structure
        if 'maintainers' in metadata:
            if not isinstance(metadata['maintainers'], list) or len(metadata['maintainers']) == 0:
                self.errors.append("maintainers must be a non-empty list")
            else:
                for i, maintainer in enumerate(metadata['maintainers']):
                    if not isinstance(maintainer, dict):
                        self.errors.append(f"maintainer[{i}] must be an object")
                        continue
                    
                    required_maintainer_fields = ['name', 'email']
                    for field in required_maintainer_fields:
                        if field not in maintainer:
                            self.errors.append(f"maintainer[{i}] missing field: {field}")
        
        # Validate provider authorization (case-insensitive for backward compatibility)
        if 'provider' in metadata and self.authorized_providers:
            provider_lower = metadata['provider'].lower()
            authorized_lower = [prov.lower() for prov in self.authorized_providers]
            if provider_lower not in authorized_lower:
                self.errors.append(f"Unauthorized provider: '{metadata['provider']}'. Must be one of {self.authorized_providers}")
        
        # Validate category authorization (strict case matching)
        if 'category' in metadata and self.authorized_categories:
            if metadata['category'] not in self.authorized_categories:
                self.errors.append(f"Unauthorized category: '{metadata['category']}'. Must be one of {self.authorized_categories}")
    
    def validate_security(self, template_path):
        """Scan for potential security issues"""
        # List of patterns that might indicate secrets
        secret_patterns = [
            'password', 'secret', 'key', 'token', 'credential',
            'aws_access_key', 'aws_secret_key', 'api_key'
        ]
        
        for root, dirs, files in os.walk(template_path):
            for file in files:
                if file.endswith(('.py', '.sh', '.ps1', '.yml', '.yaml', '.json', '.tf')):
                    file_path = Path(root) / file
                    try:
                        with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                            content = f.read().lower()
                            for pattern in secret_patterns:
                                if f'{pattern}=' in content or f'{pattern}:' in content:
                                    rel_path = file_path.relative_to(template_path)
                                    self.warnings.append(f"Potential secret in {rel_path}: contains '{pattern}'")
                    except Exception:
                        continue
    
    def validate_template(self, template_path):
        """Validate a single template"""
        self.errors = []
        self.warnings = []
        
        print(f"Validating template: {template_path}")
        
        if not template_path.exists():
            self.errors.append(f"Template path does not exist: {template_path}")
            return False
        
        self.validate_structure(template_path)
        self.validate_metadata(template_path)
        self.validate_security(template_path)
        
        # Report results
        if self.errors:
            print("❌ Validation FAILED")
            for error in self.errors:
                print(f"   ERROR: {error}")
        
        if self.warnings:
            print("⚠️  Warnings:")
            for warning in self.warnings:
                print(f"   WARNING: {warning}")
        
        if not self.errors and not self.warnings:
            print("✅ Validation PASSED")
        elif not self.errors:
            print("⚠️  Validation PASSED with warnings")
        
        return len(self.errors) == 0
    
    def validate_all_templates(self):
        """Validate all templates in repository"""
        success_count = 0
        total_count = 0
        
        # Find all template directories in solutions folder
        solutions_path = self.repo_root / "solutions"
        if solutions_path.exists():
            for provider_path in solutions_path.iterdir():
                if provider_path.is_dir():
                    for category_path in provider_path.iterdir():
                        if category_path.is_dir():
                            for solution_path in category_path.iterdir():
                                if solution_path.is_dir():
                                    total_count += 1
                                    if self.validate_template(solution_path):
                                        success_count += 1
                                    print()  # Empty line between validations
        
        print(f"Validation Summary: {success_count}/{total_count} templates passed")
        return success_count == total_count

def main():
    parser = argparse.ArgumentParser(description='Validate EO Framework™ templates')
    parser.add_argument('--path', help='Specific template path to validate')
    parser.add_argument('--all', action='store_true', help='Validate all templates')
    
    args = parser.parse_args()
    validator = TemplateValidator()
    
    if args.path:
        path = Path(args.path)
        if not path.is_absolute():
            path = validator.repo_root / path
        success = validator.validate_template(path)
    elif args.all:
        success = validator.validate_all_templates()
    else:
        print("Please specify --path or --all")
        return 1
    
    return 0 if success else 1

if __name__ == "__main__":
    exit(main())