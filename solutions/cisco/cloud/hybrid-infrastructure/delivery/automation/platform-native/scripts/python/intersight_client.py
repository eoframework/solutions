#!/usr/bin/env python3
"""
Cisco Intersight REST API Client Helper
========================================

This module provides helper functions for interacting with Cisco Intersight REST API
for HyperFlex cluster management and monitoring.

Requirements:
    - intersight-auth (pip install intersight-auth)
    - requests (pip install requests)

Usage:
    from intersight_client import IntersightClient

    client = IntersightClient(
        api_key_id='your-api-key',
        api_secret_file='path/to/secret.txt'
    )

    # Get HyperFlex cluster health
    clusters = client.get_hyperflex_clusters()
    for cluster in clusters:
        print(f"Cluster: {cluster['Name']}, Health: {cluster['HealthState']}")
"""

import base64
import datetime
import email
import hashlib
import json
import os
import sys
from pathlib import Path
from typing import Dict, List, Optional
from urllib.parse import urlparse, urlencode

import requests
from intersight_auth import IntersightAuth


class IntersightClient:
    """
    Cisco Intersight REST API client for HyperFlex management.

    Attributes:
        base_url: Intersight API endpoint (default: https://intersight.com/api/v1)
        api_key_id: Intersight API key identifier
        api_secret_file: Path to API secret key file
    """

    def __init__(
        self,
        api_key_id: str,
        api_secret_file: str,
        base_url: str = "https://intersight.com/api/v1"
    ):
        """
        Initialize Intersight API client.

        Args:
            api_key_id: Intersight API key ID
            api_secret_file: Path to API secret key file (PEM format)
            base_url: Intersight API base URL
        """
        self.base_url = base_url.rstrip('/')
        self.api_key_id = api_key_id
        self.api_secret_file = api_secret_file

        # Verify secret file exists
        if not Path(api_secret_file).exists():
            raise FileNotFoundError(f"API secret file not found: {api_secret_file}")

        # Initialize auth handler
        self.auth = IntersightAuth(
            secret_key_filename=api_secret_file,
            api_key_id=api_key_id
        )

    def _make_request(
        self,
        method: str,
        resource_path: str,
        query_params: Optional[Dict] = None,
        body: Optional[Dict] = None
    ) -> Dict:
        """
        Make authenticated request to Intersight API.

        Args:
            method: HTTP method (GET, POST, PATCH, DELETE)
            resource_path: API resource path (e.g., /hyperflex/Clusters)
            query_params: Optional query parameters
            body: Optional request body for POST/PATCH

        Returns:
            Response JSON as dictionary
        """
        # Build full URL
        url = f"{self.base_url}{resource_path}"
        if query_params:
            url = f"{url}?{urlencode(query_params)}"

        # Prepare headers
        headers = {
            "Content-Type": "application/json",
            "Accept": "application/json"
        }

        # Make request with authentication
        response = requests.request(
            method=method,
            url=url,
            auth=self.auth,
            headers=headers,
            json=body if body else None
        )

        # Check for errors
        response.raise_for_status()

        return response.json() if response.text else {}

    def get_hyperflex_clusters(
        self,
        filter: Optional[str] = None
    ) -> List[Dict]:
        """
        Get list of HyperFlex clusters.

        Args:
            filter: Optional OData filter expression

        Returns:
            List of HyperFlex cluster objects
        """
        params = {}
        if filter:
            params['$filter'] = filter

        response = self._make_request('GET', '/hyperflex/Clusters', query_params=params)
        return response.get('Results', [])

    def get_hyperflex_cluster_by_name(self, cluster_name: str) -> Optional[Dict]:
        """
        Get HyperFlex cluster by name.

        Args:
            cluster_name: Name of the cluster

        Returns:
            Cluster object or None if not found
        """
        filter_expr = f"Name eq '{cluster_name}'"
        clusters = self.get_hyperflex_clusters(filter=filter_expr)
        return clusters[0] if clusters else None

    def get_hyperflex_cluster_health(self, cluster_moid: str) -> Dict:
        """
        Get health status of HyperFlex cluster.

        Args:
            cluster_moid: Managed Object ID of the cluster

        Returns:
            Health status information
        """
        response = self._make_request('GET', f'/hyperflex/Clusters/{cluster_moid}')
        return {
            'Name': response.get('Name'),
            'HealthState': response.get('HealthState'),
            'Status': response.get('Status'),
            'NodeCount': response.get('NodeCount'),
            'StorageUtilization': response.get('StorageUtilization'),
            'Uptime': response.get('Uptime')
        }

    def get_hyperflex_nodes(self, cluster_moid: str) -> List[Dict]:
        """
        Get list of nodes in HyperFlex cluster.

        Args:
            cluster_moid: Managed Object ID of the cluster

        Returns:
            List of node objects
        """
        filter_expr = f"Cluster.Moid eq '{cluster_moid}'"
        response = self._make_request(
            'GET',
            '/hyperflex/Nodes',
            query_params={'$filter': filter_expr}
        )
        return response.get('Results', [])

    def get_hyperflex_alarms(
        self,
        cluster_moid: str,
        severity: Optional[str] = None
    ) -> List[Dict]:
        """
        Get active alarms for HyperFlex cluster.

        Args:
            cluster_moid: Managed Object ID of the cluster
            severity: Optional severity filter (Critical, Warning, Info)

        Returns:
            List of alarm objects
        """
        filter_parts = [f"AffectedMoId eq '{cluster_moid}'"]
        if severity:
            filter_parts.append(f"Severity eq '{severity}'")

        filter_expr = ' and '.join(filter_parts)
        response = self._make_request(
            'GET',
            '/cond/Alarms',
            query_params={'$filter': filter_expr}
        )
        return response.get('Results', [])

    def get_ucs_domain(self, domain_name: str) -> Optional[Dict]:
        """
        Get UCS domain (Fabric Interconnect) information.

        Args:
            domain_name: Name of the UCS domain

        Returns:
            UCS domain object or None if not found
        """
        filter_expr = f"Name eq '{domain_name}'"
        response = self._make_request(
            'GET',
            '/fabric/SwitchClusterProfiles',
            query_params={'$filter': filter_expr}
        )
        results = response.get('Results', [])
        return results[0] if results else None

    def create_hyperflex_cluster_profile(
        self,
        profile_name: str,
        cluster_config: Dict
    ) -> Dict:
        """
        Create HyperFlex cluster profile for deployment.

        Args:
            profile_name: Name for the cluster profile
            cluster_config: Cluster configuration parameters

        Returns:
            Created profile object
        """
        body = {
            "Name": profile_name,
            "ObjectType": "hyperflex.ClusterProfile",
            **cluster_config
        }

        return self._make_request('POST', '/hyperflex/ClusterProfiles', body=body)

    def validate_connectivity(self) -> bool:
        """
        Validate API connectivity and authentication.

        Returns:
            True if connection successful, False otherwise
        """
        try:
            # Test with a simple GET request
            self._make_request('GET', '/iam/Users', query_params={'$top': 1})
            return True
        except Exception as e:
            print(f"Connectivity validation failed: {e}")
            return False

    def get_deployment_status(self, profile_moid: str) -> Dict:
        """
        Get deployment status of HyperFlex cluster profile.

        Args:
            profile_moid: Managed Object ID of the cluster profile

        Returns:
            Deployment status information
        """
        response = self._make_request('GET', f'/hyperflex/ClusterProfiles/{profile_moid}')
        return {
            'Name': response.get('Name'),
            'ConfigState': response.get('ConfigState'),
            'DeploymentStatus': response.get('DeploymentStatus'),
            'Progress': response.get('Progress', 0)
        }


def main():
    """
    Example usage of IntersightClient.
    """
    import argparse

    parser = argparse.ArgumentParser(description='Cisco Intersight API Client')
    parser.add_argument('--api-key', required=True, help='Intersight API key ID')
    parser.add_argument('--secret-file', required=True, help='Path to API secret file')
    parser.add_argument('--cluster-name', help='HyperFlex cluster name')
    parser.add_argument('--action', choices=['list', 'health', 'alarms', 'validate'],
                        default='list', help='Action to perform')

    args = parser.parse_args()

    # Initialize client
    try:
        client = IntersightClient(
            api_key_id=args.api_key,
            api_secret_file=args.secret_file
        )
        print(f"✓ Connected to Intersight API")
    except Exception as e:
        print(f"✗ Failed to initialize client: {e}")
        sys.exit(1)

    # Perform action
    if args.action == 'validate':
        if client.validate_connectivity():
            print("✓ API connectivity validated")
        else:
            print("✗ API connectivity validation failed")
            sys.exit(1)

    elif args.action == 'list':
        clusters = client.get_hyperflex_clusters()
        print(f"\nFound {len(clusters)} HyperFlex cluster(s):")
        for cluster in clusters:
            print(f"  - {cluster['Name']}: {cluster.get('HealthState', 'Unknown')}")

    elif args.action == 'health':
        if not args.cluster_name:
            print("Error: --cluster-name required for health check")
            sys.exit(1)

        cluster = client.get_hyperflex_cluster_by_name(args.cluster_name)
        if not cluster:
            print(f"✗ Cluster '{args.cluster_name}' not found")
            sys.exit(1)

        health = client.get_hyperflex_cluster_health(cluster['Moid'])
        print(f"\nCluster Health: {args.cluster_name}")
        print(f"  Status: {health['Status']}")
        print(f"  Health State: {health['HealthState']}")
        print(f"  Node Count: {health['NodeCount']}")
        print(f"  Storage Utilization: {health.get('StorageUtilization', 'N/A')}%")

    elif args.action == 'alarms':
        if not args.cluster_name:
            print("Error: --cluster-name required for alarms")
            sys.exit(1)

        cluster = client.get_hyperflex_cluster_by_name(args.cluster_name)
        if not cluster:
            print(f"✗ Cluster '{args.cluster_name}' not found")
            sys.exit(1)

        alarms = client.get_hyperflex_alarms(cluster['Moid'])
        print(f"\nActive Alarms: {args.cluster_name}")
        if not alarms:
            print("  No active alarms")
        else:
            for alarm in alarms:
                print(f"  [{alarm['Severity']}] {alarm['Description']}")


if __name__ == '__main__':
    main()
