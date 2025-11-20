#!/usr/bin/env python3
"""
Catalog Generator Tool
Auto-generates catalog entries from solution metadata.yml files

Copyright (c) 2025 EO Framework™
Licensed under BSL 1.1 - see LICENSE file for details
"""

import yaml
import os
import argparse
from pathlib import Path
from datetime import datetime

class CatalogGenerator:
    def __init__(self, providers_dir, catalog_dir):
        self.providers_dir = Path(providers_dir)
        self.catalog_dir = Path(catalog_dir)
        self.discovered_solutions = {}
        self.existing_provider_names = {}
        self.existing_category_names = {}
        self.existing_category_descriptions = {}
        
    def load_existing_display_names(self):
        """Load existing display names from catalog files"""
        print("📖 Loading existing display names from catalogs...")
        
        # Load provider display names
        providers_path = self.catalog_dir / "providers"
        if providers_path.exists():
            for provider_file in providers_path.glob("*.yml"):
                try:
                    with open(provider_file, 'r') as f:
                        catalog = yaml.safe_load(f)
                        provider_id = catalog.get('provider')
                        provider_name = catalog.get('metadata', {}).get('provider_name')
                        if provider_id and provider_name:
                            self.existing_provider_names[provider_id] = provider_name
                except Exception as e:
                    print(f"Warning: Could not load provider catalog {provider_file}: {e}")
        
        # Load category display names
        categories_path = self.catalog_dir / "categories"
        if categories_path.exists():
            for category_file in categories_path.glob("*.yml"):
                try:
                    with open(category_file, 'r') as f:
                        catalog = yaml.safe_load(f)
                        category_id = catalog.get('category')
                        category_name = catalog.get('metadata', {}).get('category_name')
                        category_description = catalog.get('metadata', {}).get('description')
                        if category_id and category_name:
                            self.existing_category_names[category_id] = category_name
                        if category_id and category_description:
                            self.existing_category_descriptions[category_id] = category_description
                except Exception as e:
                    print(f"Warning: Could not load category catalog {category_file}: {e}")
        
        print(f"✓ Loaded {len(self.existing_provider_names)} provider names")
        print(f"✓ Loaded {len(self.existing_category_names)} category names")
        print(f"✓ Loaded {len(self.existing_category_descriptions)} category descriptions")

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
                            
                            # Add solution path and title if missing
                            metadata['solution_path'] = f"../../solutions/{provider_name}/{category_name}/{solution_name}/"
                            if 'title' not in metadata:
                                metadata['title'] = metadata.get('solution_name', solution_name.replace('-', ' ').title())
                            
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

    def scan_specific_solutions(self, solution_paths):
        """Scan only specific solutions from provided paths

        Args:
            solution_paths: List of solution paths in format "provider/category/solution"
        """
        print(f"🔍 Scanning {len(solution_paths)} specific solution(s)...")

        for solution_path in solution_paths:
            parts = solution_path.strip().split('/')
            if len(parts) != 3:
                print(f"⚠️ Skipping invalid path format: {solution_path}")
                continue

            provider_name, category_name, solution_name = parts

            # Initialize nested dict structure if needed
            if provider_name not in self.discovered_solutions:
                self.discovered_solutions[provider_name] = {}
            if category_name not in self.discovered_solutions[provider_name]:
                self.discovered_solutions[provider_name][category_name] = {}

            # Build path to metadata file
            solution_dir = self.providers_dir / provider_name / category_name / solution_name
            metadata_file = solution_dir / 'metadata.yml'

            if not metadata_file.exists():
                print(f"⚠️ Metadata not found: {solution_path}")
                continue

            try:
                with open(metadata_file, 'r') as f:
                    metadata = yaml.safe_load(f)

                # Add solution path and title if missing
                metadata['solution_path'] = f"../../solutions/{provider_name}/{category_name}/{solution_name}/"
                if 'title' not in metadata:
                    metadata['title'] = metadata.get('solution_name', solution_name.replace('-', ' ').title())

                self.discovered_solutions[provider_name][category_name][solution_name] = metadata
                print(f"✓ Scanned: {provider_name}/{category_name}/{solution_name}")

            except Exception as e:
                print(f"✗ Error reading {metadata_file}: {e}")

        total_solutions = sum(
            len(cat_data)
            for provider_data in self.discovered_solutions.values()
            for cat_data in provider_data.values()
        )
        print(f"📊 Scanned {total_solutions} specific solution(s)")

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
                            'solution_path': solution_data.get('solution_path', f"../../solutions/{provider_name}/{category_name}/{solution_name}/")
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
        """Get display name for provider from existing catalog or fallback to title case"""
        return self.existing_provider_names.get(provider_name, provider_name.title())
    
    def get_category_display_name(self, category_name):
        """Get display name for category from existing catalog or fallback to title case"""
        return self.existing_category_names.get(category_name, category_name.title())
    
    def get_category_description(self, category_name):
        """Get description for category from existing catalog or fallback to generated description"""
        return self.existing_category_descriptions.get(category_name, f"{category_name.title()} solutions")
    
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
        master_file = self.catalog_dir / 'catalog.yml'
        
        with open(master_file, 'w') as f:
            yaml.dump(master_catalog, f, default_flow_style=False, indent=2, sort_keys=False)
        
        print(f"✓ {master_file}")
    
    def generate_catalogs(self):
        """Generate catalog files from discovered solutions"""
        print("\n🚀 Generating catalog files...")

        # Load existing display names first
        self.load_existing_display_names()

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
    # Parse command line arguments
    parser = argparse.ArgumentParser(description='Generate solution catalogs')
    parser.add_argument('--solutions', type=str, help='Space-separated list of solution paths (provider/category/solution)')
    parser.add_argument('--all', action='store_true', help='Process all solutions (default if --solutions not provided)')
    args = parser.parse_args()

    # Auto-detect paths relative to script location
    script_dir = Path(__file__).parent
    repo_root = script_dir.parent.parent

    generator = CatalogGenerator(
        providers_dir=repo_root / "solutions",
        catalog_dir=repo_root / "support" / "catalog"
    )

    # Display which solutions triggered this run
    if args.solutions:
        solution_paths = args.solutions.strip().split()
        print(f"🎯 Triggered by {len(solution_paths)} changed solution(s):")
        for path in solution_paths:
            print(f"   - {path}")
        print()

    # Always scan all solutions to maintain complete catalogs
    print("🌐 Scanning all solutions to generate complete catalogs...")
    generator.scan_solutions()

    # Generate catalogs from discovered solutions
    generator.generate_catalogs()