#!/usr/bin/env python3
"""
EO Framework™ Solution Packager
Creates distributable ZIP packages for public release.

Copyright (c) 2025 EO Framework™
Licensed under BSL 1.1 - see LICENSE file for details
"""

import os
import sys
import yaml
import json
import zipfile
import hashlib
import argparse
import shutil
from pathlib import Path
from datetime import datetime

# Excluded files/directories from packages
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
    'private-*',
    '*.swp',
    '*.swo',
    '.vscode',
    '.idea'
]

def should_exclude(path):
    """Check if file/directory should be excluded from package"""
    path_str = str(path)
    for pattern in EXCLUDE_PATTERNS:
        if pattern.startswith('*'):
            if path_str.endswith(pattern[1:]):
                return True
        elif pattern.endswith('*'):
            if pattern[:-1] in path_str:
                return True
        else:
            if pattern in path_str:
                return True
    return False

def sanitize_metadata(metadata):
    """Remove private fields and add public URLs"""
    # Remove private fields
    private_fields = ['document_path', 'internal_notes', 'private_notes']
    for field in private_fields:
        metadata.pop(field, None)

    # Add public URLs
    provider = metadata.get('provider')
    category = metadata.get('category')
    solution = metadata.get('solution_name')

    base_url = 'https://github.com/eoframework/public-assets/raw/main'
    solution_path = f'solutions/{provider}/{category}/{solution}'

    metadata['repository'] = 'https://github.com/eoframework/public-assets'
    metadata['download_latest'] = f'{base_url}/{solution_path}/latest/{solution}.zip'
    metadata['website'] = 'https://eoframework.com/solutions'
    metadata['support_email'] = 'support@eoframework.com'

    # Sanitize maintainers - use generic public contact
    if 'maintainers' in metadata:
        metadata['maintainers'] = [{
            'name': 'EO Framework Solutions Team',
            'email': 'support@eoframework.com'
        }]

    return metadata

def calculate_sha256(file_path):
    """Calculate SHA256 checksum of file"""
    sha256_hash = hashlib.sha256()
    with open(file_path, "rb") as f:
        for byte_block in iter(lambda: f.read(4096), b""):
            sha256_hash.update(byte_block)
    return sha256_hash.hexdigest()

def get_file_size_mb(file_path):
    """Get file size in MB"""
    size_bytes = os.path.getsize(file_path)
    size_mb = size_bytes / (1024 * 1024)
    return round(size_mb, 2)

def read_current_version(manifest_path):
    """Read current version from manifest.json"""
    if manifest_path.exists():
        try:
            with open(manifest_path, 'r') as f:
                manifest = json.load(f)
                return manifest.get('current_version', '1.0.0')
        except:
            pass
    return '1.0.0'

def bump_version(current_version, bump_type='patch'):
    """Bump version based on type (major, minor, patch)"""
    major, minor, patch = map(int, current_version.split('.'))

    if bump_type == 'major':
        return f'{major + 1}.0.0'
    elif bump_type == 'minor':
        return f'{major}.{minor + 1}.0'
    elif bump_type == 'patch':
        return f'{major}.{minor}.{patch + 1}'
    else:
        return current_version

def create_package(solution_path, output_dir, version=None, bump_type='patch', changelog=''):
    """Create ZIP package for solution"""

    solution_path = Path(solution_path)
    output_dir = Path(output_dir)

    if not solution_path.exists():
        print(f"❌ Error: Solution path does not exist: {solution_path}")
        return None

    # Read metadata
    metadata_path = solution_path / 'metadata.yml'
    if not metadata_path.exists():
        print(f"❌ Error: metadata.yml not found in {solution_path}")
        return None

    with open(metadata_path, 'r') as f:
        metadata = yaml.safe_load(f)

    provider = metadata.get('provider')
    category = metadata.get('category')
    solution_name = metadata.get('solution_name')

    print(f"📦 Packaging: {provider}/{category}/{solution_name}")

    # Determine version
    manifest_path = output_dir / provider / category / solution_name / 'manifest.json'
    if version:
        new_version = version
    else:
        current_version = read_current_version(manifest_path)
        new_version = bump_version(current_version, bump_type)

    print(f"   Version: {new_version} (bump type: {bump_type})")

    # Create output directories
    solution_output = output_dir / provider / category / solution_name
    version_dir = solution_output / f'v{new_version}'
    latest_dir = solution_output / 'latest'

    version_dir.mkdir(parents=True, exist_ok=True)
    latest_dir.mkdir(parents=True, exist_ok=True)

    # Create temporary directory for package contents
    temp_dir = Path('/tmp') / f'package-{solution_name}'
    if temp_dir.exists():
        shutil.rmtree(temp_dir)
    temp_dir.mkdir(parents=True, exist_ok=True)

    package_root = temp_dir / solution_name
    package_root.mkdir()

    # Copy solution files to temp directory
    print(f"   Copying files...")
    for item in solution_path.iterdir():
        if not should_exclude(item):
            if item.is_file():
                shutil.copy2(item, package_root / item.name)
            elif item.is_dir():
                shutil.copytree(item, package_root / item.name,
                              ignore=lambda d, files: [f for f in files if should_exclude(Path(d) / f)])

    # Sanitize metadata.yml in package
    package_metadata_path = package_root / 'metadata.yml'
    if package_metadata_path.exists():
        with open(package_metadata_path, 'r') as f:
            pkg_metadata = yaml.safe_load(f)

        # Update version in metadata
        pkg_metadata['version'] = new_version
        pkg_metadata = sanitize_metadata(pkg_metadata)

        with open(package_metadata_path, 'w') as f:
            yaml.dump(pkg_metadata, f, default_flow_style=False, sort_keys=False)

    # Create ZIP files
    zip_filename = f'{solution_name}-v{new_version}.zip'
    zip_path_versioned = version_dir / zip_filename
    zip_path_latest = latest_dir / f'{solution_name}.zip'

    print(f"   Creating ZIP...")

    def create_zip(zip_path):
        with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
            for root, dirs, files in os.walk(temp_dir):
                for file in files:
                    file_path = Path(root) / file
                    arcname = file_path.relative_to(temp_dir)
                    zipf.write(file_path, arcname)

    create_zip(zip_path_versioned)
    create_zip(zip_path_latest)

    # Calculate checksums
    sha256 = calculate_sha256(zip_path_versioned)
    size_mb = get_file_size_mb(zip_path_versioned)

    print(f"   SHA256: {sha256[:16]}...")
    print(f"   Size: {size_mb} MB")

    # Update manifest.json
    base_url = 'https://github.com/eoframework/public-assets/raw/main'
    solution_path_url = f'solutions/{provider}/{category}/{solution_name}'

    manifest_data = {
        'solution': solution_name,
        'provider': provider,
        'category': category,
        'current_version': new_version,
        'last_updated': datetime.now().strftime('%Y-%m-%d'),
        'versions': []
    }

    # Load existing manifest if it exists
    if manifest_path.exists():
        with open(manifest_path, 'r') as f:
            existing = json.load(f)
            manifest_data['versions'] = existing.get('versions', [])

    # Add new version entry
    new_version_entry = {
        'version': new_version,
        'release_date': datetime.now().strftime('%Y-%m-%d'),
        'download_url': f'{base_url}/{solution_path_url}/v{new_version}/{zip_filename}',
        'size_mb': size_mb,
        'sha256': sha256,
        'changelog': changelog if changelog else f'Release version {new_version}',
        'change_type': bump_type
    }

    # Check if version already exists, update if so
    version_exists = False
    for i, v in enumerate(manifest_data['versions']):
        if v['version'] == new_version:
            manifest_data['versions'][i] = new_version_entry
            version_exists = True
            break

    if not version_exists:
        manifest_data['versions'].insert(0, new_version_entry)

    # Save manifest
    manifest_path.parent.mkdir(parents=True, exist_ok=True)
    with open(manifest_path, 'w') as f:
        json.dump(manifest_data, f, indent=2)

    print(f"   Updated manifest.json")

    # Cleanup temp directory
    shutil.rmtree(temp_dir)

    print(f"✅ Package created successfully!")
    print(f"   Versioned: {zip_path_versioned}")
    print(f"   Latest: {zip_path_latest}")
    print(f"   Manifest: {manifest_path}")

    return {
        'version': new_version,
        'zip_versioned': str(zip_path_versioned),
        'zip_latest': str(zip_path_latest),
        'manifest': str(manifest_path),
        'sha256': sha256,
        'size_mb': size_mb
    }

def main():
    parser = argparse.ArgumentParser(description='Package EO Framework solutions for public release')
    parser.add_argument('--solution', required=True, help='Path to solution directory')
    parser.add_argument('--output', required=True, help='Output directory (public-assets/solutions/)')
    parser.add_argument('--version', help='Specific version (default: auto-bump)')
    parser.add_argument('--bump', choices=['major', 'minor', 'patch'], default='patch',
                       help='Version bump type (default: patch)')
    parser.add_argument('--changelog', default='', help='Changelog entry for this version')

    args = parser.parse_args()

    result = create_package(
        solution_path=args.solution,
        output_dir=args.output,
        version=args.version,
        bump_type=args.bump,
        changelog=args.changelog
    )

    if result:
        print(f"\n🎉 Packaging complete!")
        return 0
    else:
        print(f"\n❌ Packaging failed!")
        return 1

if __name__ == '__main__':
    sys.exit(main())
