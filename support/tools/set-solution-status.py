#!/usr/bin/env python3
"""
Set solution status in metadata.yml

Usage:
    ./set-solution-status.py --solution SOLUTION_PATH --status STATUS
    ./set-solution-status.py --all --status STATUS
"""

import sys
import yaml
import argparse
from pathlib import Path

VALID_STATUSES = ["Draft", "In Review", "Active", "Beta", "Deprecated"]

def update_solution_status(solution_path, new_status):
    """Update status in solution's metadata.yml"""

    solution_path = Path(solution_path)
    metadata_file = solution_path / 'metadata.yml'

    if not metadata_file.exists():
        print(f"❌ Error: metadata.yml not found in {solution_path}")
        return False

    try:
        with open(metadata_file, 'r') as f:
            metadata = yaml.safe_load(f)

        old_status = metadata.get('status', 'Unknown')
        metadata['status'] = new_status

        with open(metadata_file, 'w') as f:
            yaml.dump(metadata, f, default_flow_style=False, sort_keys=False)

        solution_name = metadata.get('solution_display_name', solution_path.name)
        print(f"✅ {solution_name}: {old_status} → {new_status}")
        return True

    except Exception as e:
        print(f"❌ Error updating {solution_path}: {e}")
        return False

def main():
    parser = argparse.ArgumentParser(description='Update solution status in metadata.yml')
    parser.add_argument('--solution', help='Path to specific solution (e.g., solutions/aws/ai/intelligent-document-processing)')
    parser.add_argument('--all', action='store_true', help='Update all solutions')
    parser.add_argument('--provider', help='Update all solutions for specific provider')
    parser.add_argument('--status', required=True, choices=VALID_STATUSES, help='New status')

    args = parser.parse_args()

    if not args.solution and not args.all and not args.provider:
        print("❌ Error: Must specify --solution, --provider, or --all")
        parser.print_help()
        return 1

    print(f"\n🔄 Updating solution status to: {args.status}")
    print("=" * 50)

    success_count = 0
    total_count = 0

    if args.solution:
        # Update single solution
        total_count = 1
        if update_solution_status(args.solution, args.status):
            success_count = 1

    elif args.provider:
        # Update all solutions for a provider
        repo_root = Path(__file__).parent.parent.parent
        provider_path = repo_root / 'solutions' / args.provider

        if not provider_path.exists():
            print(f"❌ Error: Provider not found: {args.provider}")
            return 1

        for category_path in provider_path.iterdir():
            if category_path.is_dir():
                for solution_path in category_path.iterdir():
                    if solution_path.is_dir() and (solution_path / 'metadata.yml').exists():
                        total_count += 1
                        if update_solution_status(solution_path, args.status):
                            success_count += 1

    else:
        # Update all solutions
        repo_root = Path(__file__).parent.parent.parent
        solutions_path = repo_root / 'solutions'

        for provider_path in solutions_path.iterdir():
            if provider_path.is_dir():
                for category_path in provider_path.iterdir():
                    if category_path.is_dir():
                        for solution_path in category_path.iterdir():
                            if solution_path.is_dir() and (solution_path / 'metadata.yml').exists():
                                total_count += 1
                                if update_solution_status(solution_path, args.status):
                                    success_count += 1

    print("=" * 50)
    print(f"\n📊 Summary: {success_count}/{total_count} solutions updated")

    if success_count < total_count:
        print(f"⚠️  {total_count - success_count} solutions failed to update")
        return 1

    return 0

if __name__ == '__main__':
    sys.exit(main())
