#!/usr/bin/env python3
"""
Cisco Network Configuration Validator
Validates network device configurations for compliance and best practices
"""

import argparse
import json
import re
import sys
from typing import Dict, List, Tuple


class ConfigValidator:
    """Validates Cisco network configurations"""

    def __init__(self, config_file: str):
        self.config_file = config_file
        self.config_content = ""
        self.validation_results = {
            "passed": [],
            "failed": [],
            "warnings": []
        }

    def load_config(self) -> bool:
        """Load configuration file"""
        try:
            with open(self.config_file, 'r') as f:
                self.config_content = f.read()
            return True
        except FileNotFoundError:
            print(f"Error: Configuration file '{self.config_file}' not found")
            return False
        except Exception as e:
            print(f"Error loading configuration: {e}")
            return False

    def check_hostname(self) -> Tuple[bool, str]:
        """Check if hostname is configured"""
        pattern = r'^hostname\s+\S+'
        if re.search(pattern, self.config_content, re.MULTILINE):
            return True, "Hostname is configured"
        return False, "Hostname is not configured"

    def check_ntp(self) -> Tuple[bool, str]:
        """Check if NTP is configured"""
        pattern = r'^ntp server\s+\S+'
        if re.search(pattern, self.config_content, re.MULTILINE):
            return True, "NTP server is configured"
        return False, "NTP server is not configured"

    def check_logging(self) -> Tuple[bool, str]:
        """Check if syslog is configured"""
        pattern = r'^logging (host|server)\s+\S+'
        if re.search(pattern, self.config_content, re.MULTILINE):
            return True, "Syslog server is configured"
        return False, "Syslog server is not configured"

    def check_ssh(self) -> Tuple[bool, str]:
        """Check if SSH is enabled"""
        pattern = r'^(ip ssh version 2|crypto key generate rsa)'
        if re.search(pattern, self.config_content, re.MULTILINE):
            return True, "SSH is configured"
        return False, "SSH is not configured"

    def check_telnet(self) -> Tuple[bool, str]:
        """Check if telnet is disabled"""
        pattern = r'transport input telnet'
        if re.search(pattern, self.config_content, re.MULTILINE):
            return False, "WARNING: Telnet is enabled (insecure)"
        return True, "Telnet is properly disabled"

    def check_aaa(self) -> Tuple[bool, str]:
        """Check if AAA is configured"""
        pattern = r'^aaa new-model'
        if re.search(pattern, self.config_content, re.MULTILINE):
            return True, "AAA authentication is configured"
        return False, "AAA authentication is not configured"

    def check_snmp_v3(self) -> Tuple[bool, str]:
        """Check if SNMP v3 is used instead of v1/v2"""
        v1v2_pattern = r'^snmp-server community\s+\S+'
        v3_pattern = r'^snmp-server group\s+\S+\s+v3'

        has_v1v2 = re.search(v1v2_pattern, self.config_content, re.MULTILINE)
        has_v3 = re.search(v3_pattern, self.config_content, re.MULTILINE)

        if has_v1v2:
            return False, "WARNING: SNMP v1/v2 community strings found (insecure)"
        elif has_v3:
            return True, "SNMP v3 is configured"
        return True, "No SNMP configuration found"

    def run_validations(self) -> Dict:
        """Run all validation checks"""
        checks = [
            ("Hostname", self.check_hostname()),
            ("NTP", self.check_ntp()),
            ("Logging", self.check_logging()),
            ("SSH", self.check_ssh()),
            ("Telnet Security", self.check_telnet()),
            ("AAA", self.check_aaa()),
            ("SNMP Security", self.check_snmp_v3())
        ]

        for check_name, (passed, message) in checks:
            if passed:
                self.validation_results["passed"].append({
                    "check": check_name,
                    "message": message
                })
            elif "WARNING" in message:
                self.validation_results["warnings"].append({
                    "check": check_name,
                    "message": message
                })
            else:
                self.validation_results["failed"].append({
                    "check": check_name,
                    "message": message
                })

        return self.validation_results

    def print_results(self):
        """Print validation results"""
        print("\n" + "="*70)
        print("CISCO NETWORK CONFIGURATION VALIDATION RESULTS")
        print("="*70)
        print(f"\nConfiguration File: {self.config_file}\n")

        if self.validation_results["passed"]:
            print(f"\n✓ PASSED CHECKS ({len(self.validation_results['passed'])}):")
            for result in self.validation_results["passed"]:
                print(f"  ✓ {result['check']}: {result['message']}")

        if self.validation_results["warnings"]:
            print(f"\n⚠ WARNINGS ({len(self.validation_results['warnings'])}):")
            for result in self.validation_results["warnings"]:
                print(f"  ⚠ {result['check']}: {result['message']}")

        if self.validation_results["failed"]:
            print(f"\n✗ FAILED CHECKS ({len(self.validation_results['failed'])}):")
            for result in self.validation_results["failed"]:
                print(f"  ✗ {result['check']}: {result['message']}")

        print("\n" + "="*70)
        print(f"Summary: {len(self.validation_results['passed'])} passed, "
              f"{len(self.validation_results['failed'])} failed, "
              f"{len(self.validation_results['warnings'])} warnings")
        print("="*70 + "\n")


def main():
    """Main function"""
    parser = argparse.ArgumentParser(
        description="Validate Cisco network device configurations"
    )
    parser.add_argument(
        "config_file",
        help="Path to configuration file"
    )
    parser.add_argument(
        "--json",
        action="store_true",
        help="Output results in JSON format"
    )

    args = parser.parse_args()

    validator = ConfigValidator(args.config_file)

    if not validator.load_config():
        sys.exit(1)

    results = validator.run_validations()

    if args.json:
        print(json.dumps(results, indent=2))
    else:
        validator.print_results()

    # Exit with non-zero if there are failures
    if results["failed"]:
        sys.exit(1)


if __name__ == "__main__":
    main()
