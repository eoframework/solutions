#!/usr/bin/env python3
"""
Mist API Client - Juniper Mist Cloud automation
Provides Mist Cloud REST API operations
"""

import sys
import argparse
import json
import logging
import os
from typing import Optional, Dict, Any, List

import requests

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


class MistClient:
    """Client for Mist Cloud REST API"""

    def __init__(self, api_token: str, org_id: str,
                 base_url: str = "https://api.mist.com/api/v1"):
        self.api_token = api_token
        self.org_id = org_id
        self.base_url = base_url
        self.session = requests.Session()
        self.session.headers.update({
            "Authorization": f"Token {api_token}",
            "Content-Type": "application/json"
        })

    def _request(self, method: str, endpoint: str,
                 data: Optional[Dict] = None) -> Dict[str, Any]:
        """Make API request"""
        url = f"{self.base_url}/{endpoint}"
        try:
            response = self.session.request(method, url, json=data)
            response.raise_for_status()
            return response.json() if response.text else {}
        except requests.HTTPError as e:
            logger.error(f"API error: {e}")
            logger.error(f"Response: {e.response.text}")
            raise

    def test_connection(self) -> Dict[str, Any]:
        """Test API connectivity"""
        return self._request("GET", "self")

    def get_org(self) -> Dict[str, Any]:
        """Get organization info"""
        return self._request("GET", f"orgs/{self.org_id}")

    def list_sites(self) -> List[Dict[str, Any]]:
        """List all sites"""
        return self._request("GET", f"orgs/{self.org_id}/sites")

    def get_site(self, site_id: str) -> Dict[str, Any]:
        """Get site details"""
        return self._request("GET", f"sites/{site_id}")

    def create_site(self, name: str, timezone: str = "America/New_York",
                    country_code: str = "US") -> Dict[str, Any]:
        """Create new site"""
        data = {
            "name": name,
            "timezone": timezone,
            "country_code": country_code
        }
        return self._request("POST", f"orgs/{self.org_id}/sites", data)

    def list_wlans(self, site_id: str) -> List[Dict[str, Any]]:
        """List WLANs for site"""
        return self._request("GET", f"sites/{site_id}/wlans")

    def create_wlan(self, site_id: str, ssid: str, vlan_id: int,
                    auth_type: str = "psk", psk: Optional[str] = None,
                    enabled: bool = True) -> Dict[str, Any]:
        """Create WLAN"""
        data = {
            "ssid": ssid,
            "enabled": enabled,
            "vlan_enabled": True,
            "vlan_id": vlan_id,
            "auth": {"type": auth_type}
        }
        if psk:
            data["auth"]["psk"] = psk
        return self._request("POST", f"sites/{site_id}/wlans", data)

    def list_devices(self, site_id: str) -> List[Dict[str, Any]]:
        """List devices (APs) for site"""
        return self._request("GET", f"sites/{site_id}/devices")

    def get_device_stats(self, site_id: str) -> List[Dict[str, Any]]:
        """Get device statistics"""
        return self._request("GET", f"sites/{site_id}/stats/devices")

    def get_site_sle(self, site_id: str) -> Dict[str, Any]:
        """Get site SLE metrics"""
        return self._request("GET", f"sites/{site_id}/sle")

    def list_clients(self, site_id: str) -> List[Dict[str, Any]]:
        """List wireless clients"""
        return self._request("GET", f"sites/{site_id}/stats/clients")


def main():
    parser = argparse.ArgumentParser(description='Mist API Client')
    parser.add_argument('--token', default=os.getenv('MIST_API_TOKEN'),
                       help='Mist API token (or set MIST_API_TOKEN)')
    parser.add_argument('--org-id', default=os.getenv('MIST_ORG_ID'),
                       help='Mist organization ID (or set MIST_ORG_ID)')
    parser.add_argument('--action', required=True,
                       choices=['test', 'org', 'sites', 'wlans', 'devices',
                               'clients', 'sle', 'create-site', 'create-wlan'],
                       help='Action to perform')
    parser.add_argument('--site-id', help='Site ID for site-specific actions')
    parser.add_argument('--name', help='Name for create actions')
    parser.add_argument('--ssid', help='SSID for WLAN creation')
    parser.add_argument('--vlan', type=int, help='VLAN ID for WLAN creation')
    parser.add_argument('--output', choices=['json', 'text'], default='json')

    args = parser.parse_args()

    if not args.token or not args.org_id:
        logger.error("API token and org ID required")
        sys.exit(1)

    client = MistClient(args.token, args.org_id)

    try:
        result = None

        if args.action == 'test':
            result = client.test_connection()
        elif args.action == 'org':
            result = client.get_org()
        elif args.action == 'sites':
            result = client.list_sites()
        elif args.action == 'wlans':
            if not args.site_id:
                logger.error("--site-id required")
                sys.exit(1)
            result = client.list_wlans(args.site_id)
        elif args.action == 'devices':
            if not args.site_id:
                logger.error("--site-id required")
                sys.exit(1)
            result = client.list_devices(args.site_id)
        elif args.action == 'clients':
            if not args.site_id:
                logger.error("--site-id required")
                sys.exit(1)
            result = client.list_clients(args.site_id)
        elif args.action == 'sle':
            if not args.site_id:
                logger.error("--site-id required")
                sys.exit(1)
            result = client.get_site_sle(args.site_id)
        elif args.action == 'create-site':
            if not args.name:
                logger.error("--name required")
                sys.exit(1)
            result = client.create_site(args.name)
        elif args.action == 'create-wlan':
            if not all([args.site_id, args.ssid, args.vlan]):
                logger.error("--site-id, --ssid, and --vlan required")
                sys.exit(1)
            result = client.create_wlan(args.site_id, args.ssid, args.vlan)

        if args.output == 'json':
            print(json.dumps(result, indent=2))
        else:
            print(result)

    except Exception as e:
        logger.error(f"Error: {e}")
        sys.exit(1)


if __name__ == '__main__':
    main()
