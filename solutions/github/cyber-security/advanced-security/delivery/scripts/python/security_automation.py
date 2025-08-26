#!/usr/bin/env python3
"""
GitHub Advanced Security Platform - Security Automation Script
This script provides automated security management and monitoring capabilities
for GitHub Advanced Security features.
"""

import os
import json
import logging
import requests
from datetime import datetime, timedelta
from typing import Dict, List, Optional
import argparse

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

class GitHubSecurityManager:
    """
    GitHub Advanced Security management and automation class
    """
    
    def __init__(self, token: str, organization: str):
        """
        Initialize GitHub Security Manager
        
        Args:
            token: GitHub personal access token with security permissions
            organization: GitHub organization name
        """
        self.token = token
        self.organization = organization
        self.base_url = "https://api.github.com"
        self.headers = {
            "Authorization": f"token {token}",
            "Accept": "application/vnd.github+json",
            "X-GitHub-Api-Version": "2022-11-28"
        }
    
    def get_repositories(self) -> List[Dict]:
        """
        Get all repositories in the organization
        
        Returns:
            List of repository dictionaries
        """
        url = f"{self.base_url}/orgs/{self.organization}/repos"
        repos = []
        page = 1
        
        while True:
            response = requests.get(
                url,
                headers=self.headers,
                params={"per_page": 100, "page": page}
            )
            response.raise_for_status()
            
            page_repos = response.json()
            if not page_repos:
                break
                
            repos.extend(page_repos)
            page += 1
        
        logger.info(f"Found {len(repos)} repositories in organization")
        return repos
    
    def get_security_alerts(self, repo_name: str) -> Dict:
        """
        Get security alerts for a repository
        
        Args:
            repo_name: Repository name
            
        Returns:
            Dictionary containing different types of security alerts
        """
        alerts = {}
        
        # Get code scanning alerts
        try:
            url = f"{self.base_url}/repos/{self.organization}/{repo_name}/code-scanning/alerts"
            response = requests.get(url, headers=self.headers)
            response.raise_for_status()
            alerts['code_scanning'] = response.json()
        except requests.exceptions.RequestException as e:
            logger.warning(f"Could not fetch code scanning alerts for {repo_name}: {e}")
            alerts['code_scanning'] = []
        
        # Get secret scanning alerts
        try:
            url = f"{self.base_url}/repos/{self.organization}/{repo_name}/secret-scanning/alerts"
            response = requests.get(url, headers=self.headers)
            response.raise_for_status()
            alerts['secret_scanning'] = response.json()
        except requests.exceptions.RequestException as e:
            logger.warning(f"Could not fetch secret scanning alerts for {repo_name}: {e}")
            alerts['secret_scanning'] = []
        
        # Get Dependabot alerts
        try:
            url = f"{self.base_url}/repos/{self.organization}/{repo_name}/dependabot/alerts"
            response = requests.get(url, headers=self.headers)
            response.raise_for_status()
            alerts['dependabot'] = response.json()
        except requests.exceptions.RequestException as e:
            logger.warning(f"Could not fetch Dependabot alerts for {repo_name}: {e}")
            alerts['dependabot'] = []
        
        return alerts
    
    def generate_security_report(self) -> Dict:
        """
        Generate comprehensive security report for the organization
        
        Returns:
            Security report dictionary
        """
        logger.info("Generating security report...")
        
        repos = self.get_repositories()
        report = {
            "generated_at": datetime.now().isoformat(),
            "organization": self.organization,
            "summary": {
                "total_repositories": len(repos),
                "repositories_with_alerts": 0,
                "total_code_scanning_alerts": 0,
                "total_secret_scanning_alerts": 0,
                "total_dependabot_alerts": 0,
                "critical_alerts": 0,
                "high_alerts": 0
            },
            "repositories": []
        }
        
        for repo in repos:
            repo_name = repo['name']
            logger.info(f"Processing repository: {repo_name}")
            
            alerts = self.get_security_alerts(repo_name)
            
            repo_data = {
                "name": repo_name,
                "private": repo['private'],
                "alerts": alerts,
                "alert_counts": {
                    "code_scanning": len(alerts['code_scanning']),
                    "secret_scanning": len(alerts['secret_scanning']),
                    "dependabot": len(alerts['dependabot'])
                }
            }
            
            # Count severity levels
            critical_count = 0
            high_count = 0
            
            for alert in alerts['code_scanning']:
                if alert.get('rule', {}).get('security_severity_level') == 'critical':
                    critical_count += 1
                elif alert.get('rule', {}).get('security_severity_level') == 'high':
                    high_count += 1
            
            for alert in alerts['dependabot']:
                severity = alert.get('security_advisory', {}).get('severity', '').lower()
                if severity == 'critical':
                    critical_count += 1
                elif severity == 'high':
                    high_count += 1
            
            repo_data['severity_counts'] = {
                "critical": critical_count,
                "high": high_count
            }
            
            # Update summary
            if any(alerts.values()):
                report['summary']['repositories_with_alerts'] += 1
            
            report['summary']['total_code_scanning_alerts'] += len(alerts['code_scanning'])
            report['summary']['total_secret_scanning_alerts'] += len(alerts['secret_scanning'])
            report['summary']['total_dependabot_alerts'] += len(alerts['dependabot'])
            report['summary']['critical_alerts'] += critical_count
            report['summary']['high_alerts'] += high_count
            
            report['repositories'].append(repo_data)
        
        return report
    
    def enable_security_features(self, repo_name: str) -> Dict:
        """
        Enable security features for a repository
        
        Args:
            repo_name: Repository name
            
        Returns:
            Dictionary with enablement status
        """
        logger.info(f"Enabling security features for {repo_name}")
        
        results = {}
        
        # Enable vulnerability alerts
        try:
            url = f"{self.base_url}/repos/{self.organization}/{repo_name}/vulnerability-alerts"
            response = requests.put(url, headers=self.headers)
            response.raise_for_status()
            results['vulnerability_alerts'] = 'enabled'
        except requests.exceptions.RequestException as e:
            logger.error(f"Failed to enable vulnerability alerts: {e}")
            results['vulnerability_alerts'] = 'failed'
        
        # Enable automated security fixes
        try:
            url = f"{self.base_url}/repos/{self.organization}/{repo_name}/automated-security-fixes"
            response = requests.put(url, headers=self.headers)
            response.raise_for_status()
            results['automated_security_fixes'] = 'enabled'
        except requests.exceptions.RequestException as e:
            logger.error(f"Failed to enable automated security fixes: {e}")
            results['automated_security_fixes'] = 'failed'
        
        return results
    
    def create_security_policy(self, repo_name: str) -> bool:
        """
        Create a security policy file for a repository
        
        Args:
            repo_name: Repository name
            
        Returns:
            True if successful, False otherwise
        """
        security_policy_content = """# Security Policy

## Supported Versions

Use this section to tell people about which versions of your project are
currently being supported with security updates.

| Version | Supported          |
| ------- | ------------------ |
| 5.1.x   | :white_check_mark: |
| 5.0.x   | :x:                |
| 4.0.x   | :white_check_mark: |
| < 4.0   | :x:                |

## Reporting a Vulnerability

Use this section to tell people how to report a vulnerability.

Tell them where to go, how often they can expect to get an update on a
reported vulnerability, what to expect if the vulnerability is accepted or
declined, etc.
"""
        
        try:
            url = f"{self.base_url}/repos/{self.organization}/{repo_name}/contents/SECURITY.md"
            
            # Check if file already exists
            response = requests.get(url, headers=self.headers)
            if response.status_code == 200:
                logger.info(f"Security policy already exists for {repo_name}")
                return True
            
            # Create the file
            data = {
                "message": "Add security policy",
                "content": requests.utils.quote(security_policy_content.encode('utf-8'))
            }
            
            response = requests.put(url, headers=self.headers, json=data)
            response.raise_for_status()
            
            logger.info(f"Created security policy for {repo_name}")
            return True
            
        except requests.exceptions.RequestException as e:
            logger.error(f"Failed to create security policy for {repo_name}: {e}")
            return False

def main():
    """
    Main function to run security automation
    """
    parser = argparse.ArgumentParser(description="GitHub Advanced Security Automation")
    parser.add_argument("--token", required=True, help="GitHub personal access token")
    parser.add_argument("--org", required=True, help="GitHub organization name")
    parser.add_argument("--action", choices=["report", "enable", "policy"], 
                       required=True, help="Action to perform")
    parser.add_argument("--repo", help="Specific repository name (for enable/policy actions)")
    parser.add_argument("--output", help="Output file for report")
    
    args = parser.parse_args()
    
    # Initialize security manager
    manager = GitHubSecurityManager(args.token, args.org)
    
    if args.action == "report":
        # Generate security report
        report = manager.generate_security_report()
        
        if args.output:
            with open(args.output, 'w') as f:
                json.dump(report, f, indent=2)
            logger.info(f"Report saved to {args.output}")
        else:
            print(json.dumps(report, indent=2))
    
    elif args.action == "enable":
        if not args.repo:
            logger.error("Repository name required for enable action")
            return
        
        results = manager.enable_security_features(args.repo)
        print(json.dumps(results, indent=2))
    
    elif args.action == "policy":
        if not args.repo:
            logger.error("Repository name required for policy action")
            return
        
        success = manager.create_security_policy(args.repo)
        if success:
            print(f"Security policy created for {args.repo}")
        else:
            print(f"Failed to create security policy for {args.repo}")

if __name__ == "__main__":
    main()