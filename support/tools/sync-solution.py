#!/usr/bin/env python3
"""
EO Framework™ Solution Sync Tool
Syncs solution folders from private repo to public-assets repo (folder-based publishing).

Copyright (c) 2025 EO Framework™
Licensed under BSL 1.1 - see LICENSE file for details
"""

import os
import sys
import yaml
import shutil
import argparse
from pathlib import Path
from datetime import datetime

# Excluded files/directories from public release
EXCLUDE_PATTERNS = [
    '.git',
    '.gitignore',
    '__pycache__',
    '*.pyc',
    '.DS_Store',
    'Thumbs.db',
    '.env',
    '.env.*',
    'INTERNAL_*',
    'internal-*',
    'private-*',
    '*.swp',
    '*.swo',
    '.vscode',
    '.idea',
    'node_modules'
]

# Valid status values for publishing
PUBLISHABLE_STATUSES = ["In Review", "Active", "Beta", "Deprecated"]
NON_PUBLISHABLE_STATUSES = ["Draft"]
ALL_STATUSES = ["Draft", "In Review", "Active", "Beta", "Deprecated"]

def should_exclude(path):
    """Check if file/directory should be excluded from public release"""
    path_str = str(path)
    name = os.path.basename(path_str)

    for pattern in EXCLUDE_PATTERNS:
        if pattern.startswith('*'):
            if name.endswith(pattern[1:]):
                return True
        elif pattern.endswith('*'):
            if pattern[:-1] in path_str:
                return True
        else:
            if pattern == name or pattern in path_str:
                return True
    return False

def load_display_names(repo_root):
    """Load provider and category display names from catalog files"""
    provider_names = {}
    category_names = {}

    # Load provider display names
    providers_path = repo_root / "support" / "catalog" / "providers"
    if providers_path.exists():
        for provider_file in providers_path.glob("*.yml"):
            try:
                with open(provider_file, 'r') as f:
                    catalog = yaml.safe_load(f)
                    provider_id = catalog.get('provider')
                    provider_name = catalog.get('metadata', {}).get('provider_name')
                    if provider_id and provider_name:
                        provider_names[provider_id] = provider_name
            except Exception:
                pass  # Skip invalid catalog files

    # Load category display names
    categories_path = repo_root / "support" / "catalog" / "categories"
    if categories_path.exists():
        for category_file in categories_path.glob("*.yml"):
            try:
                with open(category_file, 'r') as f:
                    catalog = yaml.safe_load(f)
                    category_id = catalog.get('category')
                    category_name = catalog.get('metadata', {}).get('category_name')
                    if category_id and category_name:
                        category_names[category_id] = category_name
            except Exception:
                pass  # Skip invalid catalog files

    return provider_names, category_names

def sanitize_metadata(metadata):
    """Remove private fields and add public information"""
    # Remove private/internal fields
    private_fields = [
        'document_path',
        'internal_notes',
        'private_notes',
        'internal_contacts',
        'development_status'
    ]

    for field in private_fields:
        metadata.pop(field, None)

    # Get solution info
    provider = metadata.get('provider', '').lower()
    category = metadata.get('category', '').lower()
    solution_name = metadata.get('solution_name', '').lower()
    version = metadata.get('version', '1.0.0')

    # Add public repository information
    base_url = 'https://github.com/eoframework/public-assets'
    solution_path = f'solutions/{provider}/{category}/{solution_name}'

    metadata['repository'] = {
        'url': base_url,
        'type': 'git',
        'path': solution_path,
        'clone_url': f'{base_url}.git'
    }

    metadata['access'] = {
        'browse_url': f'{base_url}/tree/main/{solution_path}',
        'raw_url': f'https://raw.githubusercontent.com/eoframework/public-assets/main/{solution_path}',
        'latest_tag': f'{provider}/{category}/{solution_name}-v{version}'
    }

    metadata['support'] = {
        'website': 'https://eoframework.com/solutions',
        'email': 'support@eoframework.com',
        'documentation': f'https://docs.eoframework.com/solutions/{provider}/{category}/{solution_name}'
    }

    # Sanitize maintainers - use generic public contact
    metadata['maintainers'] = [{
        'name': 'EO Framework Solutions Team',
        'email': 'support@eoframework.com',
        'role': 'Solutions Architect'
    }]

    return metadata

def read_metadata(solution_path):
    """Read and validate solution metadata"""
    metadata_file = solution_path / 'metadata.yml'

    if not metadata_file.exists():
        raise FileNotFoundError(f"metadata.yml not found in {solution_path}")

    with open(metadata_file, 'r') as f:
        metadata = yaml.safe_load(f)

    # Validate required fields
    required_fields = ['provider', 'category', 'solution_name', 'version', 'status']
    missing_fields = [f for f in required_fields if f not in metadata]

    if missing_fields:
        raise ValueError(f"Missing required fields in metadata.yml: {', '.join(missing_fields)}")

    # Validate status
    status = metadata.get('status')
    if status not in ALL_STATUSES:
        raise ValueError(f"Invalid status '{status}'. Must be one of: {', '.join(ALL_STATUSES)}")

    return metadata

def replace_readme_placeholders(readme_path, metadata, provider_display, category_display):
    """Replace placeholder variables in README files"""
    if not readme_path.exists():
        return

    with open(readme_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Define placeholder replacements
    replacements = {
        '{SOLUTION_NAME}': metadata.get('solution_display_name', metadata.get('solution_name', 'Solution')),
        '{PROVIDER_NAME}': provider_display,
        '{CATEGORY_NAME}': category_display,
        '{VERSION}': metadata.get('version', '1.0.0'),
        '{DESCRIPTION}': metadata.get('description', ''),
        '{SOLUTION_ID}': metadata.get('solution_name', '').lower()
    }

    # Perform replacements
    original_content = content
    for placeholder, value in replacements.items():
        content = content.replace(placeholder, str(value))

    # Only write if changes were made
    if content != original_content:
        with open(readme_path, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"   ✅ Replaced placeholders in {readme_path.name}")

def generate_clean_readme(metadata, provider_display, category_display):
    """Generate a clean, simple README from metadata"""
    provider = metadata.get('provider', '').lower()
    category = metadata.get('category', '').lower()
    solution_name = metadata.get('solution_name', '').lower()
    solution_display = metadata.get('solution_display_name', solution_name.replace('-', ' ').title())
    description = metadata.get('description', '')
    version = metadata.get('version', '1.0.0')
    status = metadata.get('status', 'In Review')
    solution_path = f"solutions/{provider}/{category}/{solution_name}"

    readme_content = f"""# {solution_display}

**Provider:** {provider_display}
**Category:** {category_display}
**Version:** {version}
**Status:** {status}

## Overview

{description}

## 📥 Access This Solution

### Quick Download

**Option 1: Using Helper Script**
```bash
curl -O https://raw.githubusercontent.com/eoframework/public-assets/main/download-solution.sh
chmod +x download-solution.sh
./download-solution.sh {provider}/{category}/{solution_name}
```

**Option 2: Git Sparse Checkout (Recommended)**
```bash
# Clone with sparse checkout
git clone --filter=blob:none --sparse https://github.com/eoframework/public-assets.git
cd public-assets

# Checkout this specific solution
git sparse-checkout set {solution_path}

# View the solution
cd {solution_path}
ls -la
```

**Option 3: Browse on GitHub**
- View online: https://github.com/eoframework/public-assets/tree/main/{solution_path}

## 📁 Solution Structure

This solution includes:

- **`presales/`** - Business case materials, ROI calculators, presentations
- **`delivery/`** - Implementation guides, configuration templates, automation scripts
  - `implementation-guide.md` - Step-by-step implementation instructions
  - `scripts/` - Deployment automation (Bash, Python, Terraform, PowerShell)
  - `scripts/README.md` - Detailed script usage and prerequisites
- **`metadata.yml`** - Solution metadata and requirements
- **`CHANGELOG.md`** - Version history and updates

## 🚀 Getting Started

1. **Review the business case**: See `presales/` for ROI analysis and presentations
2. **Check prerequisites**: Review `delivery/implementation-guide.md` for requirements
3. **Deploy the solution**: Follow instructions in `delivery/scripts/README.md`

For detailed deployment steps, see [`delivery/scripts/README.md`](delivery/scripts/README.md).

## 📄 License

This solution is licensed under the Business Source License 1.1 (BSL 1.1).

---

**EO Framework™** - Enterprise Optimization Solutions
"""

    return readme_content

def create_changelog(solution_path, metadata):
    """Create or update CHANGELOG.md if it doesn't exist"""
    changelog_path = solution_path / 'CHANGELOG.md'

    if changelog_path.exists():
        return  # Don't overwrite existing changelog

    version = metadata.get('version', '1.0.0')
    solution_name = metadata.get('solution_display_name', metadata.get('solution_name'))

    changelog_content = f"""# Changelog - {solution_name}

All notable changes to this solution will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [{version}] - {datetime.now().strftime('%Y-%m-%d')}

### Initial Release
- Complete presales materials (business case, ROI calculator, presentations)
- Full delivery documentation (implementation guide, configuration templates)
- Automation scripts (Terraform, Python, PowerShell, Bash)
- Testing and validation procedures
- Training and operations materials

---

**Note:** This solution follows semantic versioning (MAJOR.MINOR.PATCH)
- MAJOR: Breaking changes or major feature additions
- MINOR: New features, backward compatible
- PATCH: Bug fixes, documentation updates
"""

    with open(changelog_path, 'w') as f:
        f.write(changelog_content)

    print(f"   ✅ Created CHANGELOG.md")

def sync_solution(solution_path, target_repo, create_tag=False):
    """Sync solution folder to public-assets repository"""

    solution_path = Path(solution_path)
    target_repo = Path(target_repo)

    if not solution_path.exists():
        print(f"❌ Error: Solution path does not exist: {solution_path}")
        return False

    # Read and validate metadata
    try:
        metadata = read_metadata(solution_path)
    except Exception as e:
        print(f"❌ Error reading metadata: {e}")
        return False

    provider = metadata['provider'].lower()
    category = metadata['category'].lower()
    solution_name = metadata['solution_name'].lower()
    version = metadata['version']
    status = metadata['status']

    # Load display names from catalog
    repo_root = solution_path.parent.parent.parent.parent  # Go up to repo root
    provider_names, category_names = load_display_names(repo_root)
    provider_display = provider_names.get(provider, provider.title())
    category_display = category_names.get(category, category.replace('-', ' ').title())

    print(f"\n📦 Syncing Solution: {provider}/{category}/{solution_name}")
    print(f"   Version: {version}")
    print(f"   Status: {status}")

    # Check if solution should be published
    if status in NON_PUBLISHABLE_STATUSES:
        print(f"⚠️  Solution status '{status}' is not publishable (Draft solutions are excluded)")
        print(f"   Skipping sync for this solution")
        return False

    if status not in PUBLISHABLE_STATUSES:
        print(f"⚠️  Unknown status '{status}' - proceeding with caution")
        print(f"   Valid statuses: {', '.join(ALL_STATUSES)}")

    # Target directory in public-assets
    target_dir = target_repo / 'solutions' / provider / category / solution_name

    # Remove existing directory if it exists
    if target_dir.exists():
        print(f"   🗑️  Removing existing directory...")
        shutil.rmtree(target_dir)

    # Create target directory
    target_dir.mkdir(parents=True, exist_ok=True)
    print(f"   📁 Created: {target_dir}")

    # Copy solution files, excluding private/internal files
    print(f"   📋 Copying files...")
    copied_count = 0

    for item in solution_path.iterdir():
        if should_exclude(item):
            print(f"      ⊘ Excluded: {item.name}")
            continue

        target_item = target_dir / item.name

        if item.is_file():
            shutil.copy2(item, target_item)
            copied_count += 1
        elif item.is_dir():
            shutil.copytree(
                item,
                target_item,
                ignore=lambda d, files: [f for f in files if should_exclude(Path(d) / f)]
            )
            # Count files in copied directory
            copied_count += sum(1 for _ in target_item.rglob('*') if _.is_file())

    print(f"   ✅ Copied {copied_count} files")

    # Generate clean README for main solution
    print(f"   📝 Generating clean README...")
    main_readme = target_dir / 'README.md'
    clean_readme_content = generate_clean_readme(metadata, provider_display, category_display)
    with open(main_readme, 'w', encoding='utf-8') as f:
        f.write(clean_readme_content)
    print(f"   ✅ Created clean README.md")

    # Sanitize and update metadata.yml
    metadata_target = target_dir / 'metadata.yml'
    if metadata_target.exists():
        print(f"   🔧 Sanitizing metadata.yml...")
        sanitized_metadata = sanitize_metadata(metadata.copy())

        with open(metadata_target, 'w') as f:
            yaml.dump(sanitized_metadata, f, default_flow_style=False, sort_keys=False)

    # Create CHANGELOG.md if it doesn't exist
    create_changelog(target_dir, metadata)

    # Create tag information file for the workflow
    if create_tag:
        tag_name = f"{provider}/{category}/{solution_name}-v{version}"
        tag_file = target_repo / '.tag-info'
        with open(tag_file, 'w') as f:
            f.write(tag_name)
        print(f"   🏷️  Tag prepared: {tag_name}")

    print(f"✅ Sync complete for {solution_name}")
    print(f"   Target: {target_dir}")

    return True

def main():
    parser = argparse.ArgumentParser(
        description='Sync EO Framework solution to public-assets repository'
    )
    parser.add_argument(
        '--solution',
        required=True,
        help='Path to solution directory (e.g., solutions/aws/ai/intelligent-document-processing)'
    )
    parser.add_argument(
        '--target',
        required=True,
        help='Path to public-assets repository root'
    )
    parser.add_argument(
        '--create-tag',
        action='store_true',
        help='Create tag info file for git tagging'
    )

    args = parser.parse_args()

    success = sync_solution(
        solution_path=args.solution,
        target_repo=args.target,
        create_tag=args.create_tag
    )

    if success:
        print(f"\n🎉 Solution sync successful!")
        return 0
    else:
        print(f"\n❌ Solution sync failed!")
        return 1

if __name__ == '__main__':
    sys.exit(main())
