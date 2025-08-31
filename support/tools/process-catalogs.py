#!/usr/bin/env python3
"""
Catalog Processing Tool
Processes distributed catalogs into unified exports and reports
"""

import yaml
import json
import os
from pathlib import Path
from datetime import datetime

class CatalogProcessor:
    def __init__(self, catalog_dir):
        self.catalog_dir = Path(catalog_dir)
        self.master_catalog = None
        self.provider_catalogs = {}
        self.category_catalogs = {}
        
    def load_master_catalog(self):
        """Load the master catalog"""
        master_file = self.catalog_dir / 'catalog.yml'
        if master_file.exists():
            with open(master_file, 'r') as f:
                self.master_catalog = yaml.safe_load(f)
            print(f"✓ Loaded master catalog")
        else:
            raise FileNotFoundError("Master catalog not found")
    
    def load_provider_catalogs(self):
        """Load all provider catalogs"""
        providers_dir = self.catalog_dir / 'providers'
        if not providers_dir.exists():
            return
            
        for provider_file in providers_dir.glob('*.yml'):
            provider_name = provider_file.stem
            with open(provider_file, 'r') as f:
                self.provider_catalogs[provider_name] = yaml.safe_load(f)
        
        print(f"✓ Loaded {len(self.provider_catalogs)} provider catalogs")
    
    def load_category_catalogs(self):
        """Load all category catalogs"""
        categories_dir = self.catalog_dir / 'categories'
        if not categories_dir.exists():
            return
            
        for category_file in categories_dir.glob('*.yml'):
            category_name = category_file.stem
            with open(category_file, 'r') as f:
                self.category_catalogs[category_name] = yaml.safe_load(f)
        
        print(f"✓ Loaded {len(self.category_catalogs)} category catalogs")
    
    def aggregate_all_solutions(self):
        """Aggregate all solutions from provider catalogs"""
        all_solutions = []
        
        for provider_name, provider_data in self.provider_catalogs.items():
            for category_name, category_data in provider_data.get('categories', {}).items():
                for solution_name, solution_data in category_data.get('solutions', {}).items():
                    solution = {
                        'id': f"{provider_name}-{category_name}-{solution_name}",
                        'provider': provider_name,
                        'category': category_name,
                        'solution_name': solution_name,
                        **solution_data
                    }
                    all_solutions.append(solution)
        
        return all_solutions
    
    def search_solutions(self, query=None, provider=None, category=None, complexity=None, tags=None):
        """Search solutions with various filters"""
        all_solutions = self.aggregate_all_solutions()
        filtered_solutions = []
        
        for solution in all_solutions:
            # Apply filters
            if provider and solution['provider'] != provider:
                continue
            if category and solution['category'] != category:
                continue
            if complexity and solution.get('complexity') != complexity:
                continue
            if tags:
                solution_tags = solution.get('tags', [])
                if not any(tag in solution_tags for tag in tags):
                    continue
            
            # Apply text search
            if query:
                searchable_text = ' '.join([
                    solution.get('title', ''),
                    solution.get('description', ''),
                    ' '.join(solution.get('tags', []))
                ]).lower()
                
                if query.lower() not in searchable_text:
                    continue
            
            filtered_solutions.append(solution)
        
        return filtered_solutions
    
    def get_statistics(self):
        """Generate comprehensive statistics"""
        all_solutions = self.aggregate_all_solutions()
        
        stats = {
            'total_solutions': len(all_solutions),
            'by_provider': {},
            'by_category': {},
            'by_complexity': {},
            'by_deployment_time': {},
            'top_tags': {}
        }
        
        # Count by provider
        for solution in all_solutions:
            provider = solution['provider']
            if provider not in stats['by_provider']:
                stats['by_provider'][provider] = 0
            stats['by_provider'][provider] += 1
        
        # Count by category
        for solution in all_solutions:
            category = solution['category']
            if category not in stats['by_category']:
                stats['by_category'][category] = 0
            stats['by_category'][category] += 1
        
        # Count by complexity
        for solution in all_solutions:
            complexity = solution.get('complexity', 'unknown')
            if complexity not in stats['by_complexity']:
                stats['by_complexity'][complexity] = 0
            stats['by_complexity'][complexity] += 1
        
        # Count by deployment time
        for solution in all_solutions:
            time = solution.get('deployment_time', 'unknown')
            if time not in stats['by_deployment_time']:
                stats['by_deployment_time'][time] = 0
            stats['by_deployment_time'][time] += 1
        
        # Count tags
        tag_counts = {}
        for solution in all_solutions:
            for tag in solution.get('tags', []):
                if tag not in tag_counts:
                    tag_counts[tag] = 0
                tag_counts[tag] += 1
        
        # Get top 20 tags
        stats['top_tags'] = dict(sorted(tag_counts.items(), key=lambda x: x[1], reverse=True)[:20])
        
        return stats
    
    
    def export_solutions_json(self, output_file):
        """Export all solutions as JSON for API consumption"""
        all_solutions = self.aggregate_all_solutions()
        
        export_data = {
            'generated_at': datetime.now().isoformat(),
            'total_solutions': len(all_solutions),
            'statistics': self.get_statistics(),
            'solutions': all_solutions
        }
        
        with open(output_file, 'w') as f:
            json.dump(export_data, f, indent=2, default=str)
        
        print(f"✓ Exported solutions as JSON: {output_file}")
        return export_data
    
    def run_full_processing(self):
        """Run complete catalog processing"""
        print("🔄 Starting catalog processing...")
        
        # Load all catalogs
        self.load_master_catalog()
        self.load_provider_catalogs()
        self.load_category_catalogs()
        
        # Generate outputs
        stats = self.get_statistics()
        
        
        # Export JSON for API consumption
        exports_dir = self.catalog_dir.parent / 'exports'
        json_file = exports_dir / 'solutions.json'
        self.export_solutions_json(json_file)
        
        print("✅ Catalog processing completed successfully!")
        print(f"📊 Total solutions: {stats['total_solutions']}")
        print(f"📊 Providers: {len(stats['by_provider'])}")
        print(f"📊 Categories: {len(stats['by_category'])}")
        
        return stats

if __name__ == "__main__":
    # Auto-detect paths relative to script location
    script_dir = Path(__file__).parent
    catalog_dir = script_dir.parent / "catalog"
    
    processor = CatalogProcessor(catalog_dir)
    stats = processor.run_full_processing()
    
    # Display some statistics
    print("\n📈 Solution Statistics:")
    print("By Provider:")
    for provider, count in sorted(stats['by_provider'].items()):
        print(f"  {provider}: {count}")
    
    print("\nBy Category:")
    for category, count in sorted(stats['by_category'].items()):
        print(f"  {category}: {count}")