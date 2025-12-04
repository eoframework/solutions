#!/usr/bin/env python3
"""
Generate Ansible Variables from configuration.csv
Converts EO Framework configuration.csv to Ansible group_vars format
"""

import sys
import csv
import yaml
from pathlib import Path
from typing import Dict, Any, List

# Map CSV categories to Ansible variable structure
CATEGORY_MAPPING = {
    'Cluster': 'cluster',
    'Network': 'network',
    'Security': 'security',
    'VPN': 'vpn',
    'Integration': 'integration',
    'System': 'system',
    'Management': 'management',
    'Branch': 'branch'
}


def load_configuration_csv(csv_path: str) -> List[Dict[str, str]]:
    """Load configuration.csv file"""
    rows = []
    with open(csv_path, 'r') as f:
        # Skip comment lines
        lines = [line for line in f if not line.startswith('#')]
        reader = csv.DictReader(lines)
        for row in reader:
            rows.append(row)
    return rows


def get_environment_column(environment: str) -> str:
    """Map environment name to CSV column"""
    env_map = {
        'prod': 'Production',
        'production': 'Production',
        'test': 'Test',
        'dr': 'DR'
    }
    return env_map.get(environment.lower(), 'Production')


def convert_value(value: str, data_type: str) -> Any:
    """Convert string value to appropriate Python type"""
    if not value or value in ['[DATE]', '']:
        return None

    data_type = data_type.lower()

    if data_type == 'boolean':
        return value.lower() in ('true', 'yes', '1')
    elif data_type == 'integer':
        try:
            return int(value)
        except ValueError:
            return value
    elif data_type.startswith('ip'):
        return value
    elif data_type == 'url':
        return value
    else:
        return value


def build_vars_structure(rows: List[Dict[str, str]], environment: str) -> Dict[str, Any]:
    """Build Ansible vars structure from CSV rows"""
    env_column = get_environment_column(environment)
    vars_dict: Dict[str, Any] = {}

    for row in rows:
        param_name = row.get('Parameter Name', '')
        category = row.get('Category', '')
        value = row.get(env_column) or row.get('Default Value', '')
        data_type = row.get('Data Type', 'String')

        if not param_name:
            continue

        # Convert value
        converted_value = convert_value(value, data_type)
        if converted_value is None:
            continue

        # Get category key
        category_key = CATEGORY_MAPPING.get(category, category.lower())

        # Initialize category if needed
        if category_key not in vars_dict:
            vars_dict[category_key] = {}

        # Convert parameter name to nested structure
        # e.g., SRX_NODE0_MGMT_IP -> node0.mgmt_ip
        param_lower = param_name.lower()
        parts = param_lower.split('_')

        # Handle special prefixes
        if parts[0] in ['srx', 'ha', 'zone', 'wan', 'vpn', 'ips', 'atp']:
            parts = parts[1:]

        # Build nested structure
        current = vars_dict[category_key]
        for i, part in enumerate(parts[:-1]):
            if part not in current:
                current[part] = {}
            if isinstance(current[part], dict):
                current = current[part]
            else:
                break

        # Set final value
        final_key = parts[-1] if parts else param_lower
        if isinstance(current, dict):
            current[final_key] = converted_value

    return vars_dict


def generate_vars_file(vars_dict: Dict[str, Any], output_path: str, environment: str):
    """Generate Ansible vars YAML file"""

    header = f"""---
# {environment.upper()} Environment Variables - SRX Firewall Platform
# Generated from configuration.csv
# Do not edit manually - regenerate with generate_ansible_vars.py

"""

    with open(output_path, 'w') as f:
        f.write(header)
        yaml.dump(vars_dict, f, default_flow_style=False, sort_keys=False, indent=2)

    print(f"Generated: {output_path}")


def main():
    if len(sys.argv) < 2:
        print("Usage: generate_ansible_vars.py <environment> [csv_path]")
        print("  environment: prod, test, or dr")
        print("  csv_path: path to configuration.csv (default: ../../raw/configuration.csv)")
        sys.exit(1)

    environment = sys.argv[1]
    csv_path = sys.argv[2] if len(sys.argv) > 2 else '../../raw/configuration.csv'

    # Resolve paths
    script_dir = Path(__file__).parent
    csv_path = (script_dir / csv_path).resolve()

    if not csv_path.exists():
        # Try delivery/raw path
        csv_path = script_dir.parent.parent.parent / 'raw' / 'configuration.csv'

    if not csv_path.exists():
        print(f"Error: configuration.csv not found at {csv_path}")
        sys.exit(1)

    # Load and process CSV
    rows = load_configuration_csv(str(csv_path))
    vars_dict = build_vars_structure(rows, environment)

    # Add solution identification
    vars_dict['solution'] = {
        'name': 'srx-firewall-platform',
        'abbr': 'srx',
        'environment': environment
    }

    # Output path
    output_dir = script_dir.parent.parent / 'ansible' / 'inventory' / environment / 'group_vars'
    output_dir.mkdir(parents=True, exist_ok=True)
    output_path = output_dir / 'all.yml'

    generate_vars_file(vars_dict, str(output_path), environment)


if __name__ == '__main__':
    main()
