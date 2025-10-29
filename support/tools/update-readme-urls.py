#!/usr/bin/env python3
# Copyright (c) 2025 EO Framework™
# Licensed under BSL 1.1 - see LICENSE file for details

"""
Update all solution READMEs to remove public-assets references and point to solutions repo.
"""

from pathlib import Path
import re

def update_readme(readme_path):
    """Update a single README file to replace public-assets with solutions repo"""
    content = readme_path.read_text(encoding='utf-8')
    original_content = content

    # Replace public-assets URLs with solutions repo URLs
    content = content.replace(
        'https://github.com/eoframework/public-assets',
        'https://github.com/eoframework/solutions'
    )
    content = content.replace(
        'https://raw.githubusercontent.com/eoframework/public-assets',
        'https://raw.githubusercontent.com/eoframework/solutions'
    )
    content = content.replace(
        'eoframework/public-assets',
        'eoframework/solutions'
    )

    # Update download script URL
    content = content.replace(
        'curl -O https://raw.githubusercontent.com/eoframework/solutions/main/download-solution.sh',
        'curl -O https://raw.githubusercontent.com/eoframework/solutions/main/support/tools/download-solution.sh'
    )

    # Return True if content changed
    if content != original_content:
        readme_path.write_text(content, encoding='utf-8')
        return True
    return False

def main():
    repo_root = Path(__file__).parent.parent.parent
    solutions_dir = repo_root / 'solutions'

    # Find all README.md files in solution directories
    solution_readmes = list(solutions_dir.glob('*/*/*/README.md'))

    print(f"Found {len(solution_readmes)} solution README files")

    updated_count = 0

    for readme_path in solution_readmes:
        if update_readme(readme_path):
            # Extract solution path from file path
            parts = readme_path.parts
            solutions_idx = parts.index('solutions')
            solution_path = '/'.join(parts[solutions_idx+1:solutions_idx+4])
            print(f"✅ Updated: {solution_path}")
            updated_count += 1

    print(f"\n✅ Updated {updated_count} files")
    print(f"ℹ️  {len(solution_readmes) - updated_count} files had no changes")

if __name__ == '__main__':
    main()
