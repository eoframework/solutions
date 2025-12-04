# Python Helper Scripts for Cisco HyperFlex

This directory contains Python helper scripts for interacting with Cisco Intersight REST API.

## Prerequisites

- Python 3.9 or higher
- pip package manager

## Installation

```bash
# Create virtual environment (recommended)
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt
```

## Scripts

### intersight_client.py

Cisco Intersight REST API client for HyperFlex cluster management.

**Usage:**

```bash
# Validate API connectivity
python intersight_client.py \
  --api-key YOUR_API_KEY_ID \
  --secret-file /path/to/secret.txt \
  --action validate

# List all HyperFlex clusters
python intersight_client.py \
  --api-key YOUR_API_KEY_ID \
  --secret-file /path/to/secret.txt \
  --action list

# Get cluster health
python intersight_client.py \
  --api-key YOUR_API_KEY_ID \
  --secret-file /path/to/secret.txt \
  --cluster-name hx-cluster-prod \
  --action health

# Get active alarms
python intersight_client.py \
  --api-key YOUR_API_KEY_ID \
  --secret-file /path/to/secret.txt \
  --cluster-name hx-cluster-prod \
  --action alarms
```

**As Python Module:**

```python
from intersight_client import IntersightClient

# Initialize client
client = IntersightClient(
    api_key_id='your-api-key',
    api_secret_file='path/to/secret.txt'
)

# Get cluster health
cluster = client.get_hyperflex_cluster_by_name('hx-cluster-prod')
health = client.get_hyperflex_cluster_health(cluster['Moid'])
print(f"Health: {health['HealthState']}")

# Get alarms
alarms = client.get_hyperflex_alarms(cluster['Moid'], severity='Critical')
for alarm in alarms:
    print(f"[{alarm['Severity']}] {alarm['Description']}")
```

## API Key Setup

1. Log into Cisco Intersight: https://intersight.com
2. Navigate to Settings > API Keys
3. Click "Generate API Key"
4. Save the key ID and download the secret key file (SecretKey.txt)
5. Store the secret key securely (do not commit to git)

## Environment Variables

You can also use environment variables for API credentials:

```bash
export INTERSIGHT_API_KEY="your-api-key-id"
export INTERSIGHT_SECRET_FILE="/path/to/SecretKey.txt"
```

## Integration with Ansible

These scripts can be called from Ansible playbooks using the `command` or `shell` module:

```yaml
- name: Validate Intersight connectivity
  command: >
    python3 {{ playbook_dir }}/../scripts/python/intersight_client.py
    --api-key {{ intersight.api_key }}
    --secret-file {{ intersight.secret_file }}
    --action validate
  register: validation_result
```

## Troubleshooting

### ModuleNotFoundError: intersight_auth

```bash
pip install intersight-auth
```

### SSL Certificate Errors

If you encounter SSL certificate validation errors:

```python
import requests
requests.packages.urllib3.disable_warnings()
```

### API Authentication Errors

- Verify API key ID is correct
- Ensure secret key file path is valid
- Check that API key has appropriate permissions in Intersight
- Verify clock sync (authentication uses timestamps)

## References

- [Cisco Intersight API Documentation](https://intersight.com/apidocs)
- [intersight-auth Python Package](https://pypi.org/project/intersight-auth/)
- [Intersight REST API Guide](https://www.cisco.com/c/en/us/td/docs/unified_computing/Intersight/b_Cisco_Intersight_API_Overview.html)
