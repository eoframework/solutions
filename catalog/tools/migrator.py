#!/usr/bin/env python3
"""
Catalog Migration Tool
Migrates from single CATALOG.yml to distributed catalog structure
"""

import yaml
import json
import os
from datetime import datetime
from pathlib import Path

class CatalogMigrator:
    def __init__(self, source_catalog_path, target_catalog_dir):
        self.source_catalog_path = source_catalog_path
        self.target_catalog_dir = Path(target_catalog_dir)
        self.source_data = None
        
    def load_source_catalog(self):
        """Load the existing CATALOG.yml file"""
        with open(self.source_catalog_path, 'r') as f:
            self.source_data = yaml.safe_load(f)
        print(f"✓ Loaded source catalog with {len(self.source_data.get('providers', {}))} providers")
        
    def create_provider_catalogs(self):
        """Create individual provider catalog files"""
        providers_dir = self.target_catalog_dir / 'providers'
        providers_dir.mkdir(exist_ok=True)
        
        for provider_name, provider_data in self.source_data.get('providers', {}).items():
            provider_catalog = {
                'version': '2.0',
                'provider': provider_name,
                'generated_at': datetime.now().isoformat(),
                'catalog_type': 'provider',
                'metadata': {
                    'provider_name': self.get_provider_display_name(provider_name),
                    'total_solutions': self.count_provider_solutions(provider_data),
                    'last_updated': datetime.now().isoformat()
                },
                'categories': {}
            }
            
            # Process each category for this provider
            for category_name, category_data in provider_data.get('categories', {}).items():
                if category_data.get('solutions'):
                    provider_catalog['categories'][category_name] = {
                        'solutions': {}
                    }
                    
                    for solution_name, solution_data in category_data['solutions'].items():
                        # Add solution_path to each solution
                        solution_data['solution_path'] = f"../../providers/{provider_name}/{category_name}/{solution_name}/"
                        provider_catalog['categories'][category_name]['solutions'][solution_name] = solution_data
            
            # Write provider catalog file
            provider_file = providers_dir / f"{provider_name}.yml"
            with open(provider_file, 'w') as f:
                yaml.dump(provider_catalog, f, default_flow_style=False, indent=2, sort_keys=False)
            
            print(f"✓ Created provider catalog: {provider_file}")
            
    def create_category_catalogs(self):
        """Create category-based catalog files"""
        categories_dir = self.target_catalog_dir / 'categories'
        categories_dir.mkdir(exist_ok=True)
        
        # Build category index from all providers
        category_index = {}
        
        for provider_name, provider_data in self.source_data.get('providers', {}).items():
            for category_name, category_data in provider_data.get('categories', {}).items():
                if category_data.get('solutions'):
                    if category_name not in category_index:
                        category_index[category_name] = {
                            'version': '2.0',
                            'category': category_name,
                            'generated_at': datetime.now().isoformat(),
                            'catalog_type': 'category',
                            'metadata': {
                                'category_name': self.get_category_display_name(category_name),
                                'description': self.get_category_description(category_name),
                                'total_solutions': 0,
                                'last_updated': datetime.now().isoformat()
                            },
                            'providers': {}
                        }
                    
                    category_index[category_name]['providers'][provider_name] = {
                        'solutions': []
                    }
                    
                    for solution_name, solution_data in category_data['solutions'].items():
                        category_index[category_name]['providers'][provider_name]['solutions'].append({
                            'name': solution_name,
                            'title': solution_data.get('title', solution_name),
                            'provider_catalog': f"../providers/{provider_name}.yml",
                            'solution_path': f"../../providers/{provider_name}/{category_name}/{solution_name}/"
                        })
                        category_index[category_name]['metadata']['total_solutions'] += 1
        
        # Write category catalog files
        for category_name, category_data in category_index.items():
            category_file = categories_dir / f"{category_name}.yml"
            with open(category_file, 'w') as f:
                yaml.dump(category_data, f, default_flow_style=False, indent=2, sort_keys=False)
            
            print(f"✓ Created category catalog: {category_file}")
    
    def create_master_catalog(self):
        """Create the new master catalog (index only)"""
        # Calculate statistics
        total_solutions = 0
        provider_stats = {}
        category_stats = {}
        
        for provider_name, provider_data in self.source_data.get('providers', {}).items():
            provider_solution_count = self.count_provider_solutions(provider_data)
            provider_stats[provider_name] = provider_solution_count
            total_solutions += provider_solution_count
            
            for category_name, category_data in provider_data.get('categories', {}).items():
                if category_data.get('solutions'):
                    if category_name not in category_stats:
                        category_stats[category_name] = 0
                    category_stats[category_name] += len(category_data['solutions'])
        
        master_catalog = {
            'version': '2.0',
            'generated_at': datetime.now().isoformat(),
            'catalog_type': 'master',
            'metadata': {
                'total_providers': len(self.source_data.get('providers', {})),
                'total_categories': len(self.source_data.get('categories_list', [])),
                'total_solutions': total_solutions,
                'last_updated': datetime.now().isoformat()
            },
            'provider_catalogs': {
                provider: f"./providers/{provider}.yml" 
                for provider in self.source_data.get('providers_list', [])
            },
            'category_catalogs': {
                category: f"./categories/{category}.yml" 
                for category in self.source_data.get('categories_list', [])
            },
            'quick_stats': {
                'providers_list': self.source_data.get('providers_list', []),
                'categories_list': self.source_data.get('categories_list', []),
                'provider_solution_counts': provider_stats,
                'category_solution_counts': category_stats,
                'complexity_distribution': self.calculate_complexity_distribution(),
                'deployment_time_distribution': self.calculate_deployment_time_distribution()
            }
        }
        
        master_file = self.target_catalog_dir / 'CATALOG.yml'
        with open(master_file, 'w') as f:
            yaml.dump(master_catalog, f, default_flow_style=False, indent=2, sort_keys=False)
        
        print(f"✓ Created master catalog: {master_file}")
    
    def create_schemas(self):
        """Create JSON schemas for catalog validation"""
        schemas_dir = self.target_catalog_dir / 'schemas'
        schemas_dir.mkdir(exist_ok=True)
        
        # Master catalog schema
        master_schema = {
            "$schema": "http://json-schema.org/draft-07/schema#",
            "type": "object",
            "title": "Master Catalog Schema",
            "required": ["version", "catalog_type", "metadata"],
            "properties": {
                "version": {"type": "string", "pattern": "^2\\.\\d+$"},
                "catalog_type": {"type": "string", "enum": ["master"]},
                "generated_at": {"type": "string", "format": "date-time"},
                "metadata": {
                    "type": "object",
                    "required": ["total_providers", "total_categories", "total_solutions"],
                    "properties": {
                        "total_providers": {"type": "integer", "minimum": 0},
                        "total_categories": {"type": "integer", "minimum": 0},
                        "total_solutions": {"type": "integer", "minimum": 0},
                        "last_updated": {"type": "string", "format": "date-time"}
                    }
                },
                "provider_catalogs": {
                    "type": "object",
                    "patternProperties": {
                        "^[a-z]+$": {"type": "string", "pattern": "^\\./providers/[a-z]+\\.yml$"}
                    }
                },
                "category_catalogs": {
                    "type": "object",
                    "patternProperties": {
                        "^[a-z-]+$": {"type": "string", "pattern": "^\\./categories/[a-z-]+\\.yml$"}
                    }
                }
            }
        }
        
        with open(schemas_dir / 'master-catalog.schema.json', 'w') as f:
            json.dump(master_schema, f, indent=2)
        
        # Provider catalog schema
        provider_schema = {
            "$schema": "http://json-schema.org/draft-07/schema#",
            "type": "object",
            "title": "Provider Catalog Schema",
            "required": ["version", "provider", "catalog_type"],
            "properties": {
                "version": {"type": "string", "pattern": "^2\\.\\d+$"},
                "provider": {"type": "string", "pattern": "^[a-z]+$"},
                "catalog_type": {"type": "string", "enum": ["provider"]},
                "generated_at": {"type": "string", "format": "date-time"},
                "categories": {
                    "type": "object",
                    "patternProperties": {
                        "^[a-z-]+$": {
                            "type": "object",
                            "properties": {
                                "solutions": {
                                    "type": "object",
                                    "patternProperties": {
                                        "^[a-z-]+$": {
                                            "type": "object",
                                            "required": ["title", "description"],
                                            "properties": {
                                                "title": {"type": "string"},
                                                "description": {"type": "string"},
                                                "version": {"type": "string"},
                                                "complexity": {"type": "string", "enum": ["basic", "intermediate", "advanced", "enterprise"]},
                                                "deployment_time": {"type": "string"},
                                                "tags": {"type": "array", "items": {"type": "string"}},
                                                "solution_path": {"type": "string"}
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        with open(schemas_dir / 'provider-catalog.schema.json', 'w') as f:
            json.dump(provider_schema, f, indent=2)
        
        print("✓ Created JSON validation schemas")
    
    def count_provider_solutions(self, provider_data):
        """Count total solutions for a provider"""
        total = 0
        for category_data in provider_data.get('categories', {}).values():
            if category_data.get('solutions'):
                total += len(category_data['solutions'])
        return total
    
    def get_provider_display_name(self, provider_name):
        """Get display name for provider"""
        names = {
            'aws': 'Amazon Web Services',
            'azure': 'Microsoft Azure',
            'cisco': 'Cisco Systems',
            'dell': 'Dell Technologies',
            'github': 'GitHub',
            'google': 'Google Cloud',
            'hashicorp': 'HashiCorp',
            'ibm': 'IBM',
            'juniper': 'Juniper Networks',
            'microsoft': 'Microsoft',
            'nvidia': 'NVIDIA'
        }
        return names.get(provider_name, provider_name.title())
    
    def get_category_display_name(self, category_name):
        """Get display name for category"""
        names = {
            'ai': 'Artificial Intelligence',
            'cloud': 'Cloud Infrastructure',
            'cyber-security': 'Cyber Security',
            'devops': 'DevOps & Automation',
            'modern-workspace': 'Modern Workspace',
            'network': 'Network Infrastructure'
        }
        return names.get(category_name, category_name.title())
    
    def get_category_description(self, category_name):
        """Get description for category"""
        descriptions = {
            'ai': 'Artificial Intelligence and Machine Learning solutions',
            'cloud': 'Cloud infrastructure and platform solutions',
            'cyber-security': 'Security, compliance, and threat protection solutions',
            'devops': 'DevOps automation and CI/CD solutions',
            'modern-workspace': 'Digital workplace and collaboration solutions',
            'network': 'Network infrastructure and connectivity solutions'
        }
        return descriptions.get(category_name, f"{category_name.title()} solutions")
    
    def calculate_complexity_distribution(self):
        """Calculate complexity distribution across all solutions"""
        distribution = {'basic': 0, 'intermediate': 0, 'advanced': 0, 'enterprise': 0}
        
        for provider_data in self.source_data.get('providers', {}).values():
            for category_data in provider_data.get('categories', {}).values():
                for solution_data in category_data.get('solutions', {}).values():
                    complexity = solution_data.get('complexity', 'unknown')
                    if complexity in distribution:
                        distribution[complexity] += 1
        
        return distribution
    
    def calculate_deployment_time_distribution(self):
        """Calculate deployment time distribution"""
        distribution = {}
        
        for provider_data in self.source_data.get('providers', {}).values():
            for category_data in provider_data.get('categories', {}).values():
                for solution_data in category_data.get('solutions', {}).values():
                    time = solution_data.get('deployment_time', 'unknown')
                    if time in distribution:
                        distribution[time] += 1
                    else:
                        distribution[time] = 1
        
        return distribution
    
    def migrate(self):
        """Execute complete migration"""
        print("🚀 Starting catalog migration...")
        
        # Load source data
        self.load_source_catalog()
        
        # Create target directory structure
        self.target_catalog_dir.mkdir(exist_ok=True)
        
        # Create all catalog components
        self.create_provider_catalogs()
        self.create_category_catalogs()
        self.create_master_catalog()
        self.create_schemas()
        
        print("✅ Migration completed successfully!")
        print(f"📁 New catalog structure created in: {self.target_catalog_dir}")

if __name__ == "__main__":
    migrator = CatalogMigrator(
        source_catalog_path="/mnt/c/projects/wsl/templates/CATALOG.yml",
        target_catalog_dir="/mnt/c/projects/wsl/templates/catalog"
    )
    migrator.migrate()