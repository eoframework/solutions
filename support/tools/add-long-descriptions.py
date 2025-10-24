#!/usr/bin/env python3
# Copyright (c) 2025 EO Framework™
# Licensed under BSL 1.1 - see LICENSE file for details

"""
Add long_description field to all solution metadata files.
"""

import yaml
from pathlib import Path

def main():
    repo_root = Path(__file__).parent.parent.parent

    # Load long descriptions
    long_desc_file = repo_root / "support" / "data" / "long-descriptions.yml"
    with open(long_desc_file, 'r') as f:
        long_descriptions = yaml.safe_load(f)

    updated_count = 0

    # Update all metadata files
    solutions_path = repo_root / "solutions"
    for provider_path in solutions_path.iterdir():
        if not provider_path.is_dir():
            continue

        for category_path in provider_path.iterdir():
            if not category_path.is_dir():
                continue

            for solution_path in category_path.iterdir():
                if not solution_path.is_dir():
                    continue

                metadata_file = solution_path / 'metadata.yml'
                if not metadata_file.exists():
                    continue

                # Read current metadata
                with open(metadata_file, 'r') as f:
                    metadata = yaml.safe_load(f)

                provider = metadata['provider']
                category = metadata['category']
                solution_name = metadata['solution_name']

                # Get long description
                key = f"{provider}/{category}/{solution_name}"
                if key in long_descriptions:
                    # Add long_description after description
                    metadata['long_description'] = long_descriptions[key]

                    # Write back to file with proper order
                    with open(metadata_file, 'w') as f:
                        # Write fields in specific order
                        ordered_fields = [
                            'provider', 'category', 'solution_name',
                            'solution_display_name', 'description', 'long_description',
                            'version', 'status', 'maintainers', 'tags', 'requirements'
                        ]

                        # Write ordered fields first
                        for field in ordered_fields:
                            if field in metadata:
                                yaml.dump({field: metadata[field]}, f, default_flow_style=False, sort_keys=False)

                        # Write any remaining fields
                        for field, value in metadata.items():
                            if field not in ordered_fields:
                                yaml.dump({field: value}, f, default_flow_style=False, sort_keys=False)

                    print(f"✅ Updated: {key}")
                    updated_count += 1
                else:
                    print(f"⚠️  No long description for: {key}")

    print(f"\n{'='*60}")
    print(f"✅ Updated {updated_count} metadata files with long descriptions")
    print(f"{'='*60}")

if __name__ == '__main__':
    main()
