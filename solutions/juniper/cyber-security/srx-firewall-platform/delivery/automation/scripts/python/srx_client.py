#!/usr/bin/env python3
"""
SRX PyEZ Client - Juniper SRX automation using PyEZ
Provides advanced operations not available via Ansible modules
"""

import sys
import argparse
import json
import logging
from datetime import datetime
from pathlib import Path
from typing import Optional, Dict, Any

try:
    from jnpr.junos import Device
    from jnpr.junos.utils.config import Config
    from jnpr.junos.utils.sw import SW
    from jnpr.junos.exception import ConnectError, ConfigLoadError, CommitError
except ImportError:
    print("Error: junos-eznc not installed. Run: pip install junos-eznc")
    sys.exit(1)

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


class SRXClient:
    """PyEZ client for Juniper SRX operations"""

    def __init__(self, host: str, user: str, password: str, port: int = 830):
        self.host = host
        self.user = user
        self.password = password
        self.port = port
        self.device: Optional[Device] = None

    def connect(self) -> bool:
        """Connect to SRX device via NETCONF"""
        try:
            self.device = Device(
                host=self.host,
                user=self.user,
                password=self.password,
                port=self.port
            )
            self.device.open()
            logger.info(f"Connected to {self.host}")
            return True
        except ConnectError as e:
            logger.error(f"Connection failed: {e}")
            return False

    def disconnect(self):
        """Close device connection"""
        if self.device:
            self.device.close()
            logger.info(f"Disconnected from {self.host}")

    def get_facts(self) -> Dict[str, Any]:
        """Get device facts"""
        if not self.device:
            raise RuntimeError("Not connected")
        return dict(self.device.facts)

    def backup_config(self, backup_dir: str) -> str:
        """Backup current configuration"""
        if not self.device:
            raise RuntimeError("Not connected")

        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        hostname = self.device.facts.get('hostname', 'unknown')
        filename = f"{hostname}_{timestamp}.conf"
        filepath = Path(backup_dir) / filename

        # Get configuration in text format
        config = self.device.rpc.get_config(options={'format': 'text'})
        config_text = config.text

        # Save to file
        Path(backup_dir).mkdir(parents=True, exist_ok=True)
        with open(filepath, 'w') as f:
            f.write(config_text)

        logger.info(f"Configuration backed up to {filepath}")
        return str(filepath)

    def load_config(self, config_file: str, format: str = 'set') -> bool:
        """Load configuration from file"""
        if not self.device:
            raise RuntimeError("Not connected")

        try:
            with Config(self.device, mode='exclusive') as cu:
                cu.load(path=config_file, format=format)
                cu.pdiff()

                # Commit check
                if cu.commit_check():
                    cu.commit(comment="Loaded via PyEZ")
                    logger.info("Configuration committed successfully")
                    return True
                else:
                    logger.error("Commit check failed")
                    cu.rollback()
                    return False

        except (ConfigLoadError, CommitError) as e:
            logger.error(f"Configuration error: {e}")
            return False

    def get_security_zones(self) -> Dict[str, Any]:
        """Get security zone information"""
        if not self.device:
            raise RuntimeError("Not connected")

        zones = self.device.rpc.get_zones_information()
        return zones

    def get_cluster_status(self) -> Dict[str, Any]:
        """Get chassis cluster status"""
        if not self.device:
            raise RuntimeError("Not connected")

        try:
            status = self.device.rpc.get_chassis_cluster_status()
            return {'cluster_enabled': True, 'status': status}
        except Exception:
            return {'cluster_enabled': False}

    def get_ipsec_status(self) -> Dict[str, Any]:
        """Get IPSec VPN tunnel status"""
        if not self.device:
            raise RuntimeError("Not connected")

        tunnels = self.device.rpc.get_ipsec_security_associations_information()
        return tunnels

    def run_rpc(self, rpc_command: str) -> Any:
        """Run arbitrary RPC command"""
        if not self.device:
            raise RuntimeError("Not connected")

        rpc_func = getattr(self.device.rpc, rpc_command.replace('-', '_'))
        return rpc_func()


def main():
    parser = argparse.ArgumentParser(description='SRX PyEZ Client')
    parser.add_argument('--host', required=True, help='SRX hostname or IP')
    parser.add_argument('--user', required=True, help='Username')
    parser.add_argument('--password', required=True, help='Password')
    parser.add_argument('--port', type=int, default=830, help='NETCONF port')
    parser.add_argument('--action', required=True,
                       choices=['facts', 'backup', 'zones', 'cluster', 'ipsec'],
                       help='Action to perform')
    parser.add_argument('--backup-dir', default='./backups',
                       help='Backup directory')
    parser.add_argument('--output', choices=['json', 'text'], default='json',
                       help='Output format')

    args = parser.parse_args()

    client = SRXClient(args.host, args.user, args.password, args.port)

    if not client.connect():
        sys.exit(1)

    try:
        result = None

        if args.action == 'facts':
            result = client.get_facts()
        elif args.action == 'backup':
            result = {'backup_file': client.backup_config(args.backup_dir)}
        elif args.action == 'zones':
            result = {'zones': str(client.get_security_zones())}
        elif args.action == 'cluster':
            result = client.get_cluster_status()
        elif args.action == 'ipsec':
            result = {'ipsec': str(client.get_ipsec_status())}

        if args.output == 'json':
            print(json.dumps(result, indent=2, default=str))
        else:
            print(result)

    finally:
        client.disconnect()


if __name__ == '__main__':
    main()
