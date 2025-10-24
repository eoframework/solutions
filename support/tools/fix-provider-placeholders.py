#!/usr/bin/env python3
# Copyright (c) 2025 EO Framework™
# Licensed under BSL 1.1 - see LICENSE file for details

"""
Replace {provider_name} placeholders with actual provider names in delivery/scripts/README.md files.
"""

import yaml
from pathlib import Path

# Provider name mapping (lowercase to display name)
PROVIDER_DISPLAY_NAMES = {
    'aws': 'AWS',
    'azure': 'Azure',
    'cisco': 'Cisco',
    'dell': 'Dell',
    'github': 'GitHub',
    'google': 'Google',
    'hashicorp': 'HashiCorp',
    'ibm': 'IBM',
    'juniper': 'Juniper',
    'microsoft': 'Microsoft',
    'nvidia': 'NVIDIA'
}

def main():
    repo_root = Path(__file__).parent.parent.parent
    solutions_dir = repo_root / 'solutions'

    # Find all delivery/scripts/README.md files
    script_readmes = list(solutions_dir.glob('*/*/*/delivery/scripts/README.md'))

    print(f"Found {len(script_readmes)} delivery/scripts/README.md files")

    updated_count = 0

    for readme_path in script_readmes:
        # Read the README content
        content = readme_path.read_text(encoding='utf-8')

        # Check if it has the placeholder
        if '{provider_name}' not in content:
            continue

        # Extract provider from path: solutions/{provider}/{category}/{solution}
        # Use relative path to avoid confusion with repo name
        relative_path = readme_path.relative_to(solutions_dir)
        provider_slug = relative_path.parts[0]

        # Get display name
        provider_display = PROVIDER_DISPLAY_NAMES.get(provider_slug, provider_slug.upper())

        # Replace placeholder
        new_content = content.replace('{provider_name}', provider_display)

        # Write back
        readme_path.write_text(new_content, encoding='utf-8')

        # Get solution path for display
        solution_path = str(relative_path.parent.parent.parent)
        print(f"✅ Updated: {solution_path} ({provider_display})")
        updated_count += 1

    print(f"\n✅ Updated {updated_count} files")

if __name__ == '__main__':
    main()
