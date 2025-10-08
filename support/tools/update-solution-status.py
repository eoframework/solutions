#!/usr/bin/env python3
"""
EO Framework™ Solution Status Updater
Updates the status field in all solution metadata.yml files.

Copyright (c) 2025 EO Framework™
Licensed under BSL 1.1 - see LICENSE file for details
"""

import yaml
import argparse
from pathlib import Path

# Valid status values
VALID_STATUSES = ["Draft", "In Review", "Active", "Beta", "Deprecated"]

def update_status(metadata_path, new_status):
    """Update the status in a metadata.yml file"""
    if new_status not in VALID_STATUSES:
        raise ValueError(f"Invalid status '{new_status}'. Must be one of: {', '.join(VALID_STATUSES)}")

    try:
        with open(metadata_path, 'r') as f:
            metadata = yaml.safe_load(f)

        old_status = metadata.get('status', 'Not Set')
        metadata['status'] = new_status

        with open(metadata_path, 'w') as f:
            yaml.dump(metadata, f, default_flow_style=False, sort_keys=False)

        return True, old_status
    except Exception as e:
        return False, str(e)

def update_all_solutions(new_status):
    """Update status for all solutions"""
    repo_root = Path(__file__).parent.parent.parent
    solutions_path = repo_root / "solutions"

    updated = []
    failed = []

    for metadata_file in solutions_path.rglob("metadata.yml"):
        # Get solution path relative to solutions directory
        solution_path = metadata_file.parent.relative_to(solutions_path)

        success, old_status = update_status(metadata_file, new_status)

        if success:
            updated.append((str(solution_path), old_status, new_status))
            print(f"✅ {solution_path}: {old_status} → {new_status}")
        else:
            failed.append((str(solution_path), old_status))
            print(f"❌ {solution_path}: Failed - {old_status}")

    print(f"\n📊 Summary:")
    print(f"   Updated: {len(updated)} solutions")
    print(f"   Failed: {len(failed)} solutions")

    return updated, failed

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Update solution status in metadata.yml files')
    parser.add_argument('--status',
                       choices=VALID_STATUSES,
                       required=True,
                       help='New status value')
    parser.add_argument('--solution',
                       help='Update specific solution only (e.g., aws/ai/intelligent-document-processing)')

    args = parser.parse_args()

    if args.solution:
        repo_root = Path(__file__).parent.parent.parent
        metadata_path = repo_root / "solutions" / args.solution / "metadata.yml"

        if not metadata_path.exists():
            print(f"❌ Solution not found: {args.solution}")
            exit(1)

        success, old_status = update_status(metadata_path, args.status)
        if success:
            print(f"✅ Updated {args.solution}: {old_status} → {args.status}")
        else:
            print(f"❌ Failed to update {args.solution}: {old_status}")
            exit(1)
    else:
        update_all_solutions(args.status)
