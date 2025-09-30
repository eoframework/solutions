#!/usr/bin/env python3
"""
EO Framework™ Template Validator - Enhanced Version
Validates template structure against solution-template and metadata compliance.

Copyright (c) 2025 EO Framework™
Licensed under BSL 1.1 - see LICENSE file for details
"""

import os
import yaml
import json
from pathlib import Path
import argparse

class EnhancedTemplateValidator:
    def __init__(self):
        self.repo_root = Path(__file__).parent.parent.parent
        self.solution_template_path = self.repo_root / "solution-template" / "sample-provider" / "sample-category" / "sample-solution"
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

                print(f"📋 Loaded {len(self.authorized_providers)} authorized providers: {', '.join(self.authorized_providers)}")
                print(f"📋 Loaded {len(self.authorized_categories)} authorized categories: {', '.join(self.authorized_categories)}")
            else:
                self.errors.append("catalog.yml not found - cannot validate authorization")
        except Exception as e:
            self.errors.append(f"Could not load authorization lists: {e}")

    def _get_template_file_structure(self):
        """Get the complete file structure from solution-template"""
        if not self.solution_template_path.exists():
            self.errors.append(f"Solution template not found at: {self.solution_template_path}")
            return {}, {}

        template_files = {}
        template_dirs = {}

        # Walk through solution-template to get structure
        for root, dirs, files in os.walk(self.solution_template_path):
            rel_root = Path(root).relative_to(self.solution_template_path)

            # Skip .git and other hidden directories
            dirs[:] = [d for d in dirs if not d.startswith('.')]

            # Record directories
            if rel_root != Path('.'):
                template_dirs[str(rel_root)] = True

            # Record files (excluding .pptx as specified)
            for file in files:
                if not file.startswith('.') and not file.endswith('.pptx'):
                    if rel_root == Path('.'):
                        file_path = file
                    else:
                        file_path = str(rel_root / file)
                    template_files[file_path] = True

        return template_files, template_dirs

    def validate_folder_structure(self, template_path):
        """Validate that solution matches solution-template folder structure"""
        template_files, template_dirs = self._get_template_file_structure()

        if not template_files:
            return  # Error already recorded in _get_template_file_structure

        print(f"🔍 Checking folder structure against solution-template...")
        print(f"   Expected {len(template_files)} files and {len(template_dirs)} directories")

        # Check directories
        missing_dirs = []
        for expected_dir in template_dirs:
            dir_path = template_path / expected_dir
            if not dir_path.exists() or not dir_path.is_dir():
                missing_dirs.append(expected_dir)

        if missing_dirs:
            self.errors.append(f"Missing required directories: {', '.join(missing_dirs)}")

        # Check files
        missing_files = []
        extra_files = []

        for expected_file in template_files:
            file_path = template_path / expected_file
            if not file_path.exists() or not file_path.is_file():
                missing_files.append(expected_file)

        if missing_files:
            self.errors.append(f"Missing required files: {', '.join(missing_files)}")

        # Check for extra files (optional warning)
        solution_files = set()
        for root, dirs, files in os.walk(template_path):
            rel_root = Path(root).relative_to(template_path)
            dirs[:] = [d for d in dirs if not d.startswith('.')]

            for file in files:
                if not file.startswith('.') and not file.endswith('.pptx'):
                    if rel_root == Path('.'):
                        file_path = file
                    else:
                        file_path = str(rel_root / file)
                    solution_files.add(file_path)

        extra_files = solution_files - set(template_files.keys())
        if extra_files:
            self.warnings.append(f"Extra files not in solution-template: {', '.join(sorted(extra_files))}")

        print(f"   ✅ Structure validation completed")

    def validate_provider_category_authorization(self, template_path):
        """Validate provider and category against authorized lists"""
        # Extract provider and category from path
        path_parts = template_path.parts
        solutions_index = None

        for i, part in enumerate(path_parts):
            if part == 'solutions':
                solutions_index = i
                break

        if solutions_index is None or len(path_parts) < solutions_index + 4:
            self.errors.append(f"Invalid solution path structure: {template_path}")
            return

        provider = path_parts[solutions_index + 1]
        category = path_parts[solutions_index + 2]
        solution = path_parts[solutions_index + 3]

        print(f"🔍 Validating authorization for {provider}/{category}/{solution}")

        # Validate provider
        if self.authorized_providers:
            if provider not in self.authorized_providers:
                self.errors.append(f"Unauthorized provider: '{provider}'. Must be one of: {', '.join(self.authorized_providers)}")
            else:
                print(f"   ✅ Provider '{provider}' is authorized")

        # Validate category
        if self.authorized_categories:
            if category not in self.authorized_categories:
                self.errors.append(f"Unauthorized category: '{category}'. Must be one of: {', '.join(self.authorized_categories)}")
            else:
                print(f"   ✅ Category '{category}' is authorized")

    def validate_metadata(self, template_path):
        """Validate metadata.yml content with enhanced checks"""
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

        print(f"🔍 Validating metadata.yml content...")

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

        # Cross-validate metadata with path structure
        path_parts = template_path.parts
        solutions_index = None

        for i, part in enumerate(path_parts):
            if part == 'solutions':
                solutions_index = i
                break

        if solutions_index is not None and len(path_parts) >= solutions_index + 4:
            path_provider = path_parts[solutions_index + 1]
            path_category = path_parts[solutions_index + 2]
            path_solution = path_parts[solutions_index + 3]

            if 'provider' in metadata and metadata['provider'] != path_provider:
                self.errors.append(f"Metadata provider '{metadata['provider']}' doesn't match path provider '{path_provider}'")

            if 'category' in metadata and metadata['category'] != path_category:
                self.errors.append(f"Metadata category '{metadata['category']}' doesn't match path category '{path_category}'")

            if 'solution_name' in metadata and metadata['solution_name'] != path_solution:
                self.errors.append(f"Metadata solution_name '{metadata['solution_name']}' doesn't match path solution '{path_solution}'")

        # Validate metadata provider/category against authorized lists
        if 'provider' in metadata and self.authorized_providers:
            if metadata['provider'] not in self.authorized_providers:
                self.errors.append(f"Metadata provider '{metadata['provider']}' not in authorized list: {', '.join(self.authorized_providers)}")

        if 'category' in metadata and self.authorized_categories:
            if metadata['category'] not in self.authorized_categories:
                self.errors.append(f"Metadata category '{metadata['category']}' not in authorized list: {', '.join(self.authorized_categories)}")

        print(f"   ✅ Metadata validation completed")

    def validate_security(self, template_path):
        """Scan for potential security issues"""
        print(f"🔍 Scanning for security issues...")

        # List of patterns that might indicate secrets
        secret_patterns = [
            'password=', 'secret=', 'key=', 'token=', 'credential=',
            'aws_access_key=', 'aws_secret_key=', 'api_key='
        ]

        security_issues = 0
        for root, dirs, files in os.walk(template_path):
            dirs[:] = [d for d in dirs if not d.startswith('.')]
            for file in files:
                if file.endswith(('.py', '.sh', '.ps1', '.yml', '.yaml', '.json', '.tf')):
                    file_path = Path(root) / file
                    try:
                        with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                            content = f.read().lower()
                            for pattern in secret_patterns:
                                if pattern in content:
                                    rel_path = file_path.relative_to(template_path)
                                    self.warnings.append(f"Potential secret in {rel_path}: contains '{pattern}'")
                                    security_issues += 1
                    except Exception:
                        continue

        print(f"   ✅ Security scan completed ({security_issues} potential issues found)")

    def validate_template(self, template_path):
        """Validate a single template with enhanced checks"""
        self.errors = []
        self.warnings = []

        print(f"\n🔍 Validating template: {template_path}")
        print("=" * 80)

        if not template_path.exists():
            self.errors.append(f"Template path does not exist: {template_path}")
            return False

        # Enhanced validation steps
        self.validate_folder_structure(template_path)
        self.validate_provider_category_authorization(template_path)
        self.validate_metadata(template_path)
        self.validate_security(template_path)

        # Report results
        print("\n📊 VALIDATION RESULTS:")
        print("=" * 40)

        if self.errors:
            print("❌ Validation FAILED")
            for error in self.errors:
                print(f"   ERROR: {error}")

        if self.warnings:
            print("⚠️  Warnings:")
            for warning in self.warnings:
                print(f"   WARNING: {warning}")

        if not self.errors and not self.warnings:
            print("✅ Validation PASSED - Template fully compliant")
        elif not self.errors:
            print("⚠️  Validation PASSED with warnings")

        return len(self.errors) == 0

    def validate_all_templates(self):
        """Validate all templates in repository"""
        print("🚀 Enhanced Template Validation Starting...")
        print("=" * 80)

        success_count = 0
        total_count = 0
        failed_solutions = []

        # Find all template directories in solutions folder
        solutions_path = self.repo_root / "solutions"
        if not solutions_path.exists():
            print(f"❌ Solutions directory not found: {solutions_path}")
            return False

        for provider_path in sorted(solutions_path.iterdir()):
            if provider_path.is_dir() and not provider_path.name.startswith('.'):
                for category_path in sorted(provider_path.iterdir()):
                    if category_path.is_dir() and not category_path.name.startswith('.'):
                        for solution_path in sorted(category_path.iterdir()):
                            if solution_path.is_dir() and not solution_path.name.startswith('.'):
                                total_count += 1
                                if self.validate_template(solution_path):
                                    success_count += 1
                                    print("✅ PASSED")
                                else:
                                    failed_solutions.append(str(solution_path.relative_to(self.repo_root)))
                                    print("❌ FAILED")
                                print()

        # Final summary
        print("🎯 FINAL VALIDATION SUMMARY:")
        print("=" * 80)
        print(f"📊 Results: {success_count}/{total_count} templates passed validation")
        print(f"📈 Success Rate: {(success_count/total_count*100):.1f}%" if total_count > 0 else "No templates found")

        if failed_solutions:
            print(f"\n❌ Failed Solutions ({len(failed_solutions)}):")
            for solution in failed_solutions:
                print(f"   • {solution}")

        if success_count == total_count:
            print("\n🎉 ALL TEMPLATES PASSED VALIDATION!")

        return success_count == total_count

def main():
    parser = argparse.ArgumentParser(description='Enhanced EO Framework™ Template Validator')
    parser.add_argument('--path', help='Specific template path to validate')
    parser.add_argument('--all', action='store_true', help='Validate all templates')

    args = parser.parse_args()
    validator = EnhancedTemplateValidator()

    if args.path:
        path = Path(args.path)
        if not path.is_absolute():
            path = validator.repo_root / path
        success = validator.validate_template(path)
    elif args.all:
        success = validator.validate_all_templates()
    else:
        print("Please specify --path or --all")
        print("Example: python validate-template-improved.py --all")
        print("Example: python validate-template-improved.py --path solutions/aws/ai/intelligent-document-processing")
        return 1

    return 0 if success else 1

if __name__ == "__main__":
    exit(main())