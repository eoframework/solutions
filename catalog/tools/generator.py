#!/usr/bin/env python3
"""
Catalog Generator Tool
Auto-generates catalog entries from solution metadata.yml files
"""

import yaml
import os
from pathlib import Path
from datetime import datetime

class CatalogGenerator:
    def __init__(self, providers_dir, catalog_dir):
        self.providers_dir = Path(providers_dir)
        self.catalog_dir = Path(catalog_dir)
        self.discovered_solutions = {}
        
    def scan_solutions(self):
        """Scan providers directory for solution metadata"""
        print("🔍 Scanning for solution metadata files...")
        
        for provider_dir in self.providers_dir.iterdir():
            if not provider_dir.is_dir() or provider_dir.name.startswith('.'):
                continue
                
            provider_name = provider_dir.name
            self.discovered_solutions[provider_name] = {}
            
            for category_dir in provider_dir.iterdir():
                if not category_dir.is_dir() or category_dir.name.startswith('.'):
                    continue
                    
                category_name = category_dir.name
                self.discovered_solutions[provider_name][category_name] = {}
                
                for solution_dir in category_dir.iterdir():
                    if not solution_dir.is_dir() or solution_dir.name.startswith('.'):
                        continue
                        
                    solution_name = solution_dir.name
                    metadata_file = solution_dir / 'metadata.yml'
                    
                    if metadata_file.exists():
                        try:
                            with open(metadata_file, 'r') as f:
                                metadata = yaml.safe_load(f)
                            
                            # Add solution path
                            metadata['solution_path'] = f"../../providers/{provider_name}/{category_name}/{solution_name}/"
                            
                            self.discovered_solutions[provider_name][category_name][solution_name] = metadata
                            print(f"✓ Found: {provider_name}/{category_name}/{solution_name}")
                            
                        except Exception as e:
                            print(f"✗ Error reading {metadata_file}: {e}")
        
        total_solutions = sum(
            len(categories.get(cat, {}))
            for categories in self.discovered_solutions.values()
            for cat in categories
        )
        print(f"📊 Discovered {total_solutions} solutions across {len(self.discovered_solutions)} providers")
    
    def generate_provider_catalog(self, provider_name, provider_data):
        """Generate catalog for a single provider"""
        provider_catalog = {
            'version': '2.0',
            'provider': provider_name,
            'generated_at': datetime.now().isoformat(),
            'catalog_type': 'provider',
            'metadata': {
                'provider_name': self.get_provider_display_name(provider_name),
                'total_solutions': sum(len(cat_data) for cat_data in provider_data.values()),
                'last_updated': datetime.now().isoformat(),
                'auto_generated': True
            },
            'categories': {}
        }
        
        for category_name, solutions in provider_data.items():
            if solutions:  # Only include categories with solutions
                provider_catalog['categories'][category_name] = {
                    'solutions': solutions
                }
        
        return provider_catalog
    
    def generate_category_catalog(self, category_name, category_solutions):
        """Generate catalog for a single category"""
        category_catalog = {
            'version': '2.0',
            'category': category_name,
            'generated_at': datetime.now().isoformat(),
            'catalog_type': 'category',
            'metadata': {
                'category_name': self.get_category_display_name(category_name),
                'description': self.get_category_description(category_name),
                'total_solutions': len(category_solutions),
                'last_updated': datetime.now().isoformat(),
                'auto_generated': True
            },
            'providers': {}
        }
        
        for provider_name, solutions in category_solutions.items():
            if solutions:  # Only include providers with solutions in this category
                category_catalog['providers'][provider_name] = {
                    'solutions': [
                        {
                            'name': solution_name,
                            'title': solution_data.get('title', solution_name),
                            'provider_catalog': f"../providers/{provider_name}.yml",
                            'solution_path': solution_data.get('solution_path', f"../../providers/{provider_name}/{category_name}/{solution_name}/")
                        }
                        for solution_name, solution_data in solutions.items()
                    ]
                }
        
        return category_catalog
    
    def generate_master_catalog(self):
        """Generate master catalog from discovered solutions"""
        # Calculate statistics
        total_solutions = sum(
            len(cat_data)
            for provider_data in self.discovered_solutions.values()
            for cat_data in provider_data.values()
        )
        
        provider_stats = {}
        for provider_name, provider_data in self.discovered_solutions.items():
            provider_stats[provider_name] = sum(len(cat_data) for cat_data in provider_data.values())
        
        category_stats = {}
        for provider_data in self.discovered_solutions.values():
            for category_name, solutions in provider_data.items():
                if category_name not in category_stats:
                    category_stats[category_name] = 0
                category_stats[category_name] += len(solutions)
        
        master_catalog = {
            'version': '2.0',
            'generated_at': datetime.now().isoformat(),
            'catalog_type': 'master',
            'metadata': {
                'total_providers': len(self.discovered_solutions),
                'total_categories': len(category_stats),
                'total_solutions': total_solutions,
                'last_updated': datetime.now().isoformat(),
                'auto_generated': True
            },
            'provider_catalogs': {
                provider: f"./providers/{provider}.yml"
                for provider in self.discovered_solutions.keys()
            },
            'category_catalogs': {
                category: f"./categories/{category}.yml"
                for category in category_stats.keys()
            },
            'quick_stats': {
                'providers_list': list(self.discovered_solutions.keys()),
                'categories_list': list(category_stats.keys()),
                'provider_solution_counts': provider_stats,
                'category_solution_counts': category_stats,
                'complexity_distribution': self.calculate_complexity_distribution(),
                'deployment_time_distribution': self.calculate_deployment_time_distribution()
            }
        }
        
        return master_catalog
    
    def calculate_complexity_distribution(self):
        """Calculate complexity distribution across all solutions"""
        distribution = {'basic': 0, 'intermediate': 0, 'advanced': 0, 'enterprise': 0}
        
        for provider_data in self.discovered_solutions.values():
            for solutions in provider_data.values():
                for solution_data in solutions.values():
                    complexity = solution_data.get('complexity', 'unknown')
                    if complexity in distribution:
                        distribution[complexity] += 1
        
        return distribution
    
    def calculate_deployment_time_distribution(self):
        """Calculate deployment time distribution"""
        distribution = {}
        
        for provider_data in self.discovered_solutions.values():
            for solutions in provider_data.values():
                for solution_data in solutions.values():
                    time = solution_data.get('deployment_time', 'unknown')
                    if time in distribution:
                        distribution[time] += 1
                    else:
                        distribution[time] = 1
        
        return distribution
    
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
    
    def write_catalogs(self):
        """Write all generated catalogs to files"""
        # Ensure directories exist
        (self.catalog_dir / 'providers').mkdir(parents=True, exist_ok=True)
        (self.catalog_dir / 'categories').mkdir(parents=True, exist_ok=True)
        
        # Generate and write provider catalogs
        print("\n📝 Writing provider catalogs:")
        for provider_name, provider_data in self.discovered_solutions.items():
            provider_catalog = self.generate_provider_catalog(provider_name, provider_data)
            provider_file = self.catalog_dir / 'providers' / f"{provider_name}.yml"
            
            with open(provider_file, 'w') as f:
                yaml.dump(provider_catalog, f, default_flow_style=False, indent=2, sort_keys=False)
            
            print(f"✓ {provider_file}")
        
        # Reorganize data by category for category catalogs
        category_data = {}
        for provider_name, provider_data in self.discovered_solutions.items():
            for category_name, solutions in provider_data.items():
                if category_name not in category_data:
                    category_data[category_name] = {}
                if solutions:  # Only include if there are solutions
                    category_data[category_name][provider_name] = solutions
        
        # Generate and write category catalogs
        print("\n📝 Writing category catalogs:")
        for category_name, category_solutions in category_data.items():
            category_catalog = self.generate_category_catalog(category_name, category_solutions)
            category_file = self.catalog_dir / 'categories' / f"{category_name}.yml"
            
            with open(category_file, 'w') as f:
                yaml.dump(category_catalog, f, default_flow_style=False, indent=2, sort_keys=False)
            
            print(f"✓ {category_file}")
        
        # Generate and write master catalog
        print("\n📝 Writing master catalog:")
        master_catalog = self.generate_master_catalog()
        master_file = self.catalog_dir / 'CATALOG.yml'
        
        with open(master_file, 'w') as f:
            yaml.dump(master_catalog, f, default_flow_style=False, indent=2, sort_keys=False)
        
        print(f"✓ {master_file}")
    
    def generate_all_catalogs(self):
        """Generate complete catalog structure from solution metadata"""
        print("🚀 Starting catalog generation from solution metadata...")
        
        # Scan for solutions
        self.scan_solutions()
        
        # Write all catalogs
        self.write_catalogs()
        
        print("\n✅ Catalog generation completed successfully!")
        
        # Display summary
        total_solutions = sum(
            len(cat_data)
            for provider_data in self.discovered_solutions.values()
            for cat_data in provider_data.values()
        )
        print(f"📊 Generated catalogs for {total_solutions} solutions")
        print(f"📊 Across {len(self.discovered_solutions)} providers")
        
        categories = set()
        for provider_data in self.discovered_solutions.values():
            categories.update(provider_data.keys())
        print(f"📊 In {len(categories)} categories")

if __name__ == "__main__":
    generator = CatalogGenerator(
        providers_dir="/mnt/c/projects/wsl/templates/providers",
        catalog_dir="/mnt/c/projects/wsl/templates/catalog"
    )
    generator.generate_all_catalogs()