#!/usr/bin/env python3
"""
Catalog Validator Tool
Validates catalog files against JSON schemas
"""

import yaml
import json
import jsonschema
from pathlib import Path
from jsonschema import validate, ValidationError

class CatalogValidator:
    def __init__(self, catalog_dir):
        self.catalog_dir = Path(catalog_dir)
        self.schemas_dir = self.catalog_dir / 'schemas'
        self.schemas = {}
        self.validation_results = []
        
    def load_schemas(self):
        """Load JSON schemas for validation"""
        schema_files = {
            'master': 'master-catalog.schema.json',
            'provider': 'provider-catalog.schema.json',
            'category': 'category-catalog.schema.json'
        }
        
        for schema_name, filename in schema_files.items():
            schema_file = self.schemas_dir / filename
            if schema_file.exists():
                with open(schema_file, 'r') as f:
                    self.schemas[schema_name] = json.load(f)
                print(f"✓ Loaded {schema_name} schema")
            else:
                print(f"⚠️ Schema not found: {filename}")
    
    def validate_file(self, file_path, schema_name):
        """Validate a single file against schema"""
        try:
            with open(file_path, 'r') as f:
                data = yaml.safe_load(f)
            
            if schema_name in self.schemas:
                validate(instance=data, schema=self.schemas[schema_name])
                result = {
                    'file': str(file_path),
                    'schema': schema_name,
                    'status': 'PASS',
                    'errors': []
                }
            else:
                result = {
                    'file': str(file_path),
                    'schema': schema_name,
                    'status': 'SKIP',
                    'errors': [f"Schema {schema_name} not available"]
                }
            
        except ValidationError as e:
            result = {
                'file': str(file_path),
                'schema': schema_name,
                'status': 'FAIL',
                'errors': [str(e)]
            }
        except Exception as e:
            result = {
                'file': str(file_path),
                'schema': schema_name,
                'status': 'ERROR',
                'errors': [f"File error: {str(e)}"]
            }
        
        self.validation_results.append(result)
        return result
    
    def validate_master_catalog(self):
        """Validate master catalog"""
        master_file = self.catalog_dir / 'catalog.yml'
        if master_file.exists():
            result = self.validate_file(master_file, 'master')
            status_icon = "✓" if result['status'] == 'PASS' else "✗"
            print(f"{status_icon} Master catalog: {result['status']}")
            if result['errors']:
                for error in result['errors']:
                    print(f"    Error: {error}")
        else:
            print("⚠️ Master catalog not found")
    
    def validate_provider_catalogs(self):
        """Validate all provider catalogs"""
        providers_dir = self.catalog_dir / 'providers'
        if not providers_dir.exists():
            print("⚠️ Providers directory not found")
            return
        
        print("\nValidating provider catalogs:")
        for provider_file in providers_dir.glob('*.yml'):
            result = self.validate_file(provider_file, 'provider')
            status_icon = "✓" if result['status'] == 'PASS' else "✗"
            print(f"{status_icon} {provider_file.name}: {result['status']}")
            if result['errors']:
                for error in result['errors']:
                    print(f"    Error: {error}")
    
    def validate_category_catalogs(self):
        """Validate all category catalogs"""
        categories_dir = self.catalog_dir / 'categories'
        if not categories_dir.exists():
            print("⚠️ Categories directory not found")
            return
        
        print("\nValidating category catalogs:")
        for category_file in categories_dir.glob('*.yml'):
            result = self.validate_file(category_file, 'category')
            status_icon = "✓" if result['status'] == 'PASS' else "✗"
            print(f"{status_icon} {category_file.name}: {result['status']}")
            if result['errors']:
                for error in result['errors']:
                    print(f"    Error: {error}")
    
    def validate_cross_references(self):
        """Validate cross-references between catalogs"""
        print("\nValidating cross-references:")
        
        # Load master catalog
        master_file = self.catalog_dir / 'catalog.yml'
        if not master_file.exists():
            print("✗ Cannot validate cross-references: master catalog missing")
            return
        
        with open(master_file, 'r') as f:
            master_data = yaml.safe_load(f)
        
        # Check provider catalog references
        provider_catalogs = master_data.get('provider_catalogs', {})
        for provider, catalog_path in provider_catalogs.items():
            full_path = self.catalog_dir / catalog_path.lstrip('./')
            if full_path.exists():
                print(f"✓ Provider catalog reference valid: {provider}")
            else:
                print(f"✗ Provider catalog reference broken: {provider} -> {catalog_path}")
        
        # Check category catalog references
        category_catalogs = master_data.get('category_catalogs', {})
        for category, catalog_path in category_catalogs.items():
            full_path = self.catalog_dir / catalog_path.lstrip('./')
            if full_path.exists():
                print(f"✓ Category catalog reference valid: {category}")
            else:
                print(f"✗ Category catalog reference broken: {category} -> {catalog_path}")
    
    def validate_solution_paths(self):
        """Validate solution paths in provider catalogs"""
        print("\nValidating solution paths:")
        
        providers_dir = self.catalog_dir / 'providers'
        if not providers_dir.exists():
            return
        
        base_providers_dir = self.catalog_dir.parent / 'providers'
        
        for provider_file in providers_dir.glob('*.yml'):
            with open(provider_file, 'r') as f:
                provider_data = yaml.safe_load(f)
            
            provider_name = provider_data.get('provider')
            for category_name, category_data in provider_data.get('categories', {}).items():
                for solution_name, solution_data in category_data.get('solutions', {}).items():
                    solution_path = solution_data.get('solution_path', '')
                    if solution_path:
                        # Convert relative path to absolute
                        full_path = (self.catalog_dir / solution_path.lstrip('./')).resolve()
                        if full_path.exists():
                            print(f"✓ Solution path valid: {provider_name}/{category_name}/{solution_name}")
                        else:
                            print(f"✗ Solution path broken: {provider_name}/{category_name}/{solution_name} -> {solution_path}")
    
    def generate_validation_report(self):
        """Generate comprehensive validation report"""
        total_files = len(self.validation_results)
        passed_files = len([r for r in self.validation_results if r['status'] == 'PASS'])
        failed_files = len([r for r in self.validation_results if r['status'] == 'FAIL'])
        error_files = len([r for r in self.validation_results if r['status'] == 'ERROR'])
        
        report = {
            'summary': {
                'total_files': total_files,
                'passed': passed_files,
                'failed': failed_files,
                'errors': error_files,
                'success_rate': f"{(passed_files / max(total_files, 1)) * 100:.1f}%"
            },
            'results': self.validation_results
        }
        
        # Write report to file
        report_file = self.catalog_dir / 'validation-report.json'
        with open(report_file, 'w') as f:
            json.dump(report, f, indent=2)
        
        print(f"\n📊 Validation Summary:")
        print(f"  Total files: {total_files}")
        print(f"  Passed: {passed_files}")
        print(f"  Failed: {failed_files}")
        print(f"  Errors: {error_files}")
        print(f"  Success rate: {report['summary']['success_rate']}")
        print(f"📄 Detailed report: {report_file}")
        
        return report
    
    def run_full_validation(self):
        """Run complete validation process"""
        print("🔍 Starting catalog validation...")
        
        # Load schemas
        self.load_schemas()
        
        # Validate all catalog types
        self.validate_master_catalog()
        self.validate_provider_catalogs()
        self.validate_category_catalogs()
        
        # Validate cross-references
        self.validate_cross_references()
        self.validate_solution_paths()
        
        # Generate report
        report = self.generate_validation_report()
        
        print("✅ Validation completed!")
        return report

if __name__ == "__main__":
    validator = CatalogValidator("/mnt/c/projects/wsl/templates/catalog")
    report = validator.run_full_validation()