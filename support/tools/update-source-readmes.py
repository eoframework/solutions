#!/usr/bin/env python3
"""
Update all source READMEs in solutions repository with clean versions.
This ensures single source of truth - solutions repo has the clean READMEs.
"""

import yaml
from pathlib import Path

def load_display_names(repo_root):
    """Load provider and category display names from catalog files"""
    provider_names = {}
    category_names = {}

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
                pass

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
                pass

    return provider_names, category_names

def generate_clean_readme(metadata, provider_display, category_display):
    """Generate a clean, simple README from metadata"""
    provider = metadata.get('provider', '').lower()
    category = metadata.get('category', '').lower()
    solution_name = metadata.get('solution_name', '').lower()
    solution_display = metadata.get('solution_display_name', solution_name.replace('-', ' ').title())
    description = metadata.get('description', '')
    long_description = metadata.get('long_description', description)
    version = metadata.get('version', '1.0.0')
    status = metadata.get('status', 'In Review')
    solution_path = f"solutions/{provider}/{category}/{solution_name}"

    readme_content = f"""# {solution_display}

**Provider:** {provider_display}
**Category:** {category_display}
**Version:** {version}
**Status:** {status}

## Solution Description

{long_description}

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

## 🚀 Getting Started

### 1. Download the Solution
Use one of the download options above to get the complete solution package.

### 2. Pre-Sales Activities
Navigate to **`presales/`** for business case development and stakeholder engagement:
- Business case materials and ROI calculators
- Executive presentations and solution briefs
- Level of Effort (LOE) estimates
- Statement of Work (SOW) templates

### 3. Delivery and Implementation
Navigate to **`delivery/`** for project execution:
- Project plan and communication plan
- Requirements documentation
- Implementation guides and configuration templates
- **`scripts/`** folder - Deployment automation (Bash, Python, Terraform, PowerShell)
  - See [`delivery/scripts/README.md`](delivery/scripts/README.md) for detailed deployment instructions

### 4. Customize for Your Needs
All templates and configuration files can be modified to meet your specific requirements.

## 📄 License

For license information see: <a href="https://www.eoframework.org/license/" target="_blank">https://www.eoframework.org/license/</a>

---

**<a href="https://eoframework.org" target="_blank">EO Framework™</a>** - Exceptional Outcome Framework
"""

    return readme_content

def main():
    repo_root = Path(__file__).parent.parent.parent
    solutions_path = repo_root / "solutions"

    # Load display names
    provider_names, category_names = load_display_names(repo_root)

    updated_count = 0
    error_count = 0

    # Find all solution directories
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
                readme_file = solution_path / 'README.md'

                if not metadata_file.exists():
                    print(f"⚠️  Skipping {solution_path.name}: No metadata.yml")
                    continue

                try:
                    # Read metadata
                    with open(metadata_file, 'r') as f:
                        metadata = yaml.safe_load(f)

                    provider = metadata['provider'].lower()
                    category = metadata['category'].lower()

                    # Get display names
                    provider_display = provider_names.get(provider, provider.title())
                    category_display = category_names.get(category, category.replace('-', ' ').title())

                    # Generate clean README
                    clean_readme = generate_clean_readme(metadata, provider_display, category_display)

                    # Write to source file
                    with open(readme_file, 'w', encoding='utf-8') as f:
                        f.write(clean_readme)

                    print(f"✅ Updated: {provider}/{category}/{solution_path.name}")
                    updated_count += 1

                except Exception as e:
                    print(f"❌ Error updating {solution_path.name}: {e}")
                    error_count += 1

    print(f"\n{'='*60}")
    print(f"✅ Updated {updated_count} solution READMEs")
    if error_count > 0:
        print(f"❌ {error_count} errors")
    print(f"{'='*60}")

if __name__ == '__main__':
    main()
