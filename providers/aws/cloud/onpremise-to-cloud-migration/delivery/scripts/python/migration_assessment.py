#!/usr/bin/env python3
"""
AWS Migration Assessment Tool
Analyzes on-premise infrastructure and provides migration recommendations
"""

import boto3
import json
import csv
import logging
import argparse
import datetime
from typing import Dict, List, Any
from dataclasses import dataclass
from enum import Enum

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

class MigrationPattern(Enum):
    """Migration patterns (6 R's)"""
    REHOST = "rehost"
    REPLATFORM = "replatform"
    REFACTOR = "refactor"
    REPURCHASE = "repurchase"
    RETIRE = "retire"
    RETAIN = "retain"

class Priority(Enum):
    """Migration priority levels"""
    CRITICAL = "critical"
    HIGH = "high"
    MEDIUM = "medium"
    LOW = "low"

@dataclass
class Server:
    """Server information"""
    hostname: str
    ip_address: str
    os_type: str
    os_version: str
    cpu_cores: int
    memory_gb: int
    disk_gb: int
    applications: List[str]
    dependencies: List[str]
    utilization: Dict[str, float]

@dataclass
class Application:
    """Application information"""
    name: str
    description: str
    business_owner: str
    technical_owner: str
    servers: List[str]
    databases: List[str]
    dependencies: List[str]
    complexity: str
    criticality: Priority

@dataclass
class MigrationRecommendation:
    """Migration recommendation"""
    asset_name: str
    current_pattern: MigrationPattern
    recommended_pattern: MigrationPattern
    reasoning: str
    estimated_effort: str
    cost_savings: float
    risks: List[str]
    prerequisites: List[str]

class MigrationAssessment:
    """Migration assessment and recommendation engine"""
    
    def __init__(self, region_name: str = 'us-east-1'):
        """Initialize the assessment tool"""
        self.session = boto3.Session()
        self.region = region_name
        
        # Initialize AWS clients
        self.discovery_client = boto3.client('discovery', region_name=region_name)
        self.pricing_client = boto3.client('pricing', region_name='us-east-1')
        self.ec2_client = boto3.client('ec2', region_name=region_name)
        
        # Assessment data
        self.servers: List[Server] = []
        self.applications: List[Application] = []
        self.recommendations: List[MigrationRecommendation] = []
        
    def discover_infrastructure(self) -> Dict[str, Any]:
        """Discover on-premise infrastructure using AWS Application Discovery Service"""
        logger.info("Starting infrastructure discovery...")
        
        try:
            # Get discovered servers
            response = self.discovery_client.describe_configurations(
                configurationIds=[]
            )
            
            discovered_servers = []
            for config in response.get('configurations', []):
                if config.get('configurationType') == 'Server':
                    server_info = self._parse_server_config(config)
                    discovered_servers.append(server_info)
                    
            logger.info(f"Discovered {len(discovered_servers)} servers")
            return {
                'servers': discovered_servers,
                'discovery_timestamp': datetime.datetime.now().isoformat()
            }
            
        except Exception as e:
            logger.error(f"Error during discovery: {str(e)}")
            return {'servers': [], 'error': str(e)}
    
    def _parse_server_config(self, config: Dict[str, Any]) -> Server:
        """Parse server configuration from discovery service"""
        attributes = config.get('attributes', {})
        
        # Extract server information
        hostname = attributes.get('hostName', 'unknown')
        ip_address = attributes.get('ipAddress', 'unknown')
        os_type = attributes.get('osName', 'unknown')
        os_version = attributes.get('osVersion', 'unknown')
        cpu_cores = int(attributes.get('cpuType', '0').split()[0]) if attributes.get('cpuType') else 0
        memory_gb = int(attributes.get('totalRamInMB', 0)) / 1024
        disk_gb = int(attributes.get('totalDiskSizeInGB', 0))
        
        # Parse applications and dependencies
        applications = attributes.get('applications', '').split(',') if attributes.get('applications') else []
        dependencies = attributes.get('networkDependencies', '').split(',') if attributes.get('networkDependencies') else []
        
        # Calculate utilization (mock data for demonstration)
        utilization = {
            'cpu': float(attributes.get('cpuUtilization', 30.0)),
            'memory': float(attributes.get('memoryUtilization', 50.0)),
            'disk': float(attributes.get('diskUtilization', 40.0))
        }
        
        return Server(
            hostname=hostname,
            ip_address=ip_address,
            os_type=os_type,
            os_version=os_version,
            cpu_cores=cpu_cores,
            memory_gb=memory_gb,
            disk_gb=disk_gb,
            applications=applications,
            dependencies=dependencies,
            utilization=utilization
        )
    
    def load_inventory_from_csv(self, csv_file: str) -> None:
        """Load server inventory from CSV file"""
        logger.info(f"Loading inventory from {csv_file}")
        
        try:
            with open(csv_file, 'r') as file:
                reader = csv.DictReader(file)
                for row in reader:
                    server = Server(
                        hostname=row['hostname'],
                        ip_address=row['ip_address'],
                        os_type=row['os_type'],
                        os_version=row['os_version'],
                        cpu_cores=int(row['cpu_cores']),
                        memory_gb=float(row['memory_gb']),
                        disk_gb=float(row['disk_gb']),
                        applications=row['applications'].split(';') if row['applications'] else [],
                        dependencies=row['dependencies'].split(';') if row['dependencies'] else [],
                        utilization={
                            'cpu': float(row.get('cpu_utilization', 30.0)),
                            'memory': float(row.get('memory_utilization', 50.0)),
                            'disk': float(row.get('disk_utilization', 40.0))
                        }
                    )
                    self.servers.append(server)
                    
            logger.info(f"Loaded {len(self.servers)} servers from CSV")
            
        except Exception as e:
            logger.error(f"Error loading CSV: {str(e)}")
            raise
    
    def analyze_migration_patterns(self) -> List[MigrationRecommendation]:
        """Analyze servers and recommend migration patterns"""
        logger.info("Analyzing migration patterns...")
        
        recommendations = []
        
        for server in self.servers:
            recommendation = self._analyze_server_migration(server)
            recommendations.append(recommendation)
            
        self.recommendations = recommendations
        return recommendations
    
    def _analyze_server_migration(self, server: Server) -> MigrationRecommendation:
        """Analyze individual server for migration recommendation"""
        
        # Decision logic for migration pattern
        if self._is_legacy_os(server.os_type, server.os_version):
            if len(server.applications) == 0:
                pattern = MigrationPattern.RETIRE
                reasoning = "Legacy OS with no active applications"
            else:
                pattern = MigrationPattern.REPLATFORM
                reasoning = "Legacy OS requires platform update"
        elif self._is_high_utilization(server.utilization):
            pattern = MigrationPattern.REFACTOR
            reasoning = "High utilization suggests need for cloud-native optimization"
        elif self._has_complex_dependencies(server.dependencies):
            pattern = MigrationPattern.RETAIN
            reasoning = "Complex dependencies require further analysis"
        else:
            pattern = MigrationPattern.REHOST
            reasoning = "Standard server suitable for lift-and-shift"
        
        # Calculate effort and cost savings
        effort = self._estimate_effort(pattern, server)
        cost_savings = self._estimate_cost_savings(server, pattern)
        
        # Identify risks and prerequisites
        risks = self._identify_risks(server, pattern)
        prerequisites = self._identify_prerequisites(server, pattern)
        
        return MigrationRecommendation(
            asset_name=server.hostname,
            current_pattern=pattern,
            recommended_pattern=pattern,
            reasoning=reasoning,
            estimated_effort=effort,
            cost_savings=cost_savings,
            risks=risks,
            prerequisites=prerequisites
        )
    
    def _is_legacy_os(self, os_type: str, os_version: str) -> bool:
        """Check if OS is legacy and needs updating"""
        legacy_patterns = {
            'windows': ['2008', '2012'],
            'linux': ['centos 6', 'rhel 6', 'ubuntu 14']
        }
        
        os_lower = os_type.lower()
        version_lower = os_version.lower()
        
        for os_family, legacy_versions in legacy_patterns.items():
            if os_family in os_lower:
                return any(legacy in version_lower for legacy in legacy_versions)
        
        return False
    
    def _is_high_utilization(self, utilization: Dict[str, float]) -> bool:
        """Check if server has high resource utilization"""
        return (utilization.get('cpu', 0) > 70 or 
                utilization.get('memory', 0) > 80 or 
                utilization.get('disk', 0) > 85)
    
    def _has_complex_dependencies(self, dependencies: List[str]) -> bool:
        """Check if server has complex dependencies"""
        return len(dependencies) > 5
    
    def _estimate_effort(self, pattern: MigrationPattern, server: Server) -> str:
        """Estimate migration effort"""
        effort_map = {
            MigrationPattern.RETIRE: "1-2 weeks",
            MigrationPattern.REHOST: "2-4 weeks",
            MigrationPattern.REPLATFORM: "4-8 weeks",
            MigrationPattern.REFACTOR: "8-16 weeks",
            MigrationPattern.REPURCHASE: "4-12 weeks",
            MigrationPattern.RETAIN: "N/A"
        }
        
        base_effort = effort_map.get(pattern, "Unknown")
        
        # Adjust based on complexity
        if len(server.applications) > 3:
            base_effort += " (extended due to multiple applications)"
        
        return base_effort
    
    def _estimate_cost_savings(self, server: Server, pattern: MigrationPattern) -> float:
        """Estimate cost savings percentage"""
        base_savings = {
            MigrationPattern.RETIRE: 100.0,
            MigrationPattern.REHOST: 40.0,
            MigrationPattern.REPLATFORM: 60.0,
            MigrationPattern.REFACTOR: 80.0,
            MigrationPattern.REPURCHASE: 50.0,
            MigrationPattern.RETAIN: 0.0
        }
        
        savings = base_savings.get(pattern, 0.0)
        
        # Adjust based on utilization
        avg_utilization = sum(server.utilization.values()) / len(server.utilization)
        if avg_utilization < 30:
            savings += 20.0  # Additional savings from right-sizing
        
        return min(savings, 100.0)
    
    def _identify_risks(self, server: Server, pattern: MigrationPattern) -> List[str]:
        """Identify migration risks"""
        risks = []
        
        if pattern == MigrationPattern.REHOST:
            if self._is_legacy_os(server.os_type, server.os_version):
                risks.append("Legacy OS may have compatibility issues")
            if len(server.dependencies) > 3:
                risks.append("Multiple dependencies may cause integration issues")
        
        elif pattern == MigrationPattern.REPLATFORM:
            risks.append("Application compatibility testing required")
            risks.append("Potential configuration changes needed")
        
        elif pattern == MigrationPattern.REFACTOR:
            risks.append("Significant application changes required")
            risks.append("Extended testing and validation needed")
            risks.append("Potential skill gaps in cloud-native development")
        
        if server.memory_gb > 64:
            risks.append("Large memory requirements may increase costs")
        
        return risks
    
    def _identify_prerequisites(self, server: Server, pattern: MigrationPattern) -> List[str]:
        """Identify migration prerequisites"""
        prerequisites = []
        
        prerequisites.append("Network connectivity between source and target")
        prerequisites.append("AWS account with appropriate permissions")
        
        if pattern in [MigrationPattern.REHOST, MigrationPattern.REPLATFORM]:
            prerequisites.append("Install MGN replication agent")
            prerequisites.append("Configure security groups and IAM roles")
        
        if pattern == MigrationPattern.REPLATFORM:
            prerequisites.append("Database migration planning")
            prerequisites.append("Application configuration updates")
        
        if pattern == MigrationPattern.REFACTOR:
            prerequisites.append("Application architecture redesign")
            prerequisites.append("Development and testing environment setup")
            prerequisites.append("Team training on cloud-native technologies")
        
        if len(server.applications) > 0:
            prerequisites.append("Application dependency mapping")
            prerequisites.append("Business process validation")
        
        return prerequisites
    
    def generate_migration_waves(self, max_wave_size: int = 10) -> List[Dict[str, Any]]:
        """Generate migration waves based on dependencies and priorities"""
        logger.info("Generating migration waves...")
        
        waves = []
        remaining_servers = self.servers.copy()
        wave_number = 1
        
        while remaining_servers:
            current_wave = []
            servers_to_remove = []
            
            for server in remaining_servers:
                # Check if dependencies are satisfied
                if self._can_migrate_in_wave(server, waves):
                    current_wave.append({
                        'hostname': server.hostname,
                        'migration_pattern': self._get_recommendation_for_server(server.hostname).recommended_pattern.value,
                        'estimated_effort': self._get_recommendation_for_server(server.hostname).estimated_effort,
                        'dependencies': server.dependencies
                    })
                    servers_to_remove.append(server)
                    
                    if len(current_wave) >= max_wave_size:
                        break
            
            # Remove servers from remaining list
            for server in servers_to_remove:
                remaining_servers.remove(server)
            
            if current_wave:
                waves.append({
                    'wave_number': wave_number,
                    'servers': current_wave,
                    'total_servers': len(current_wave),
                    'estimated_duration': self._estimate_wave_duration(current_wave)
                })
                wave_number += 1
            else:
                # If no progress, add remaining servers to final wave
                if remaining_servers:
                    final_wave = []
                    for server in remaining_servers:
                        final_wave.append({
                            'hostname': server.hostname,
                            'migration_pattern': self._get_recommendation_for_server(server.hostname).recommended_pattern.value,
                            'estimated_effort': self._get_recommendation_for_server(server.hostname).estimated_effort,
                            'dependencies': server.dependencies,
                            'note': 'Complex dependencies - requires manual planning'
                        })
                    
                    waves.append({
                        'wave_number': wave_number,
                        'servers': final_wave,
                        'total_servers': len(final_wave),
                        'estimated_duration': 'TBD - Complex dependencies'
                    })
                break
        
        return waves
    
    def _can_migrate_in_wave(self, server: Server, previous_waves: List[Dict[str, Any]]) -> bool:
        """Check if server can be migrated in current wave"""
        if not server.dependencies:
            return True
        
        # Check if all dependencies have been migrated in previous waves
        migrated_servers = set()
        for wave in previous_waves:
            for server_info in wave['servers']:
                migrated_servers.add(server_info['hostname'])
        
        for dependency in server.dependencies:
            if dependency not in migrated_servers and dependency != server.hostname:
                # Check if dependency exists in our server list
                dependency_exists = any(s.hostname == dependency for s in self.servers)
                if dependency_exists:
                    return False
        
        return True
    
    def _get_recommendation_for_server(self, hostname: str) -> MigrationRecommendation:
        """Get migration recommendation for a specific server"""
        for rec in self.recommendations:
            if rec.asset_name == hostname:
                return rec
        
        # Return default recommendation if not found
        return MigrationRecommendation(
            asset_name=hostname,
            current_pattern=MigrationPattern.REHOST,
            recommended_pattern=MigrationPattern.REHOST,
            reasoning="Default recommendation",
            estimated_effort="4-6 weeks",
            cost_savings=40.0,
            risks=[],
            prerequisites=[]
        )
    
    def _estimate_wave_duration(self, wave_servers: List[Dict[str, Any]]) -> str:
        """Estimate duration for migration wave"""
        if not wave_servers:
            return "0 weeks"
        
        # Find the longest estimated effort
        max_weeks = 0
        for server in wave_servers:
            effort = server['estimated_effort']
            # Extract weeks from effort string (simple parsing)
            if 'week' in effort:
                try:
                    weeks_part = effort.split()[0]
                    if '-' in weeks_part:
                        weeks = int(weeks_part.split('-')[1])
                    else:
                        weeks = int(weeks_part)
                    max_weeks = max(max_weeks, weeks)
                except (ValueError, IndexError):
                    max_weeks = max(max_weeks, 6)  # Default
        
        return f"{max_weeks} weeks"
    
    def calculate_tco_analysis(self) -> Dict[str, Any]:
        """Calculate Total Cost of Ownership analysis"""
        logger.info("Calculating TCO analysis...")
        
        # Current on-premise costs (estimated)
        total_servers = len(self.servers)
        avg_server_cost_per_year = 5000  # Estimated annual cost per server
        current_annual_cost = total_servers * avg_server_cost_per_year
        
        # Projected AWS costs
        aws_cost_per_server = 2000  # Estimated annual AWS cost per equivalent server
        projected_aws_cost = total_servers * aws_cost_per_server
        
        # Migration costs
        migration_cost_per_server = 1000  # Estimated one-time migration cost
        total_migration_cost = total_servers * migration_cost_per_server
        
        # Calculate savings
        annual_savings = current_annual_cost - projected_aws_cost
        three_year_savings = (annual_savings * 3) - total_migration_cost
        
        # ROI calculation
        roi_percentage = (three_year_savings / total_migration_cost) * 100 if total_migration_cost > 0 else 0
        
        return {
            'current_annual_cost': current_annual_cost,
            'projected_aws_annual_cost': projected_aws_cost,
            'total_migration_cost': total_migration_cost,
            'annual_savings': annual_savings,
            'three_year_savings': three_year_savings,
            'roi_percentage': roi_percentage,
            'payback_period_months': (total_migration_cost / annual_savings * 12) if annual_savings > 0 else 0,
            'analysis_date': datetime.datetime.now().isoformat()
        }
    
    def export_assessment_report(self, output_file: str = 'migration_assessment_report.json') -> None:
        """Export comprehensive assessment report"""
        logger.info(f"Exporting assessment report to {output_file}")
        
        report = {
            'assessment_metadata': {
                'generated_date': datetime.datetime.now().isoformat(),
                'total_servers': len(self.servers),
                'total_recommendations': len(self.recommendations),
                'region': self.region
            },
            'server_inventory': [
                {
                    'hostname': server.hostname,
                    'ip_address': server.ip_address,
                    'os_type': server.os_type,
                    'os_version': server.os_version,
                    'cpu_cores': server.cpu_cores,
                    'memory_gb': server.memory_gb,
                    'disk_gb': server.disk_gb,
                    'applications': server.applications,
                    'dependencies': server.dependencies,
                    'utilization': server.utilization
                }
                for server in self.servers
            ],
            'migration_recommendations': [
                {
                    'asset_name': rec.asset_name,
                    'recommended_pattern': rec.recommended_pattern.value,
                    'reasoning': rec.reasoning,
                    'estimated_effort': rec.estimated_effort,
                    'cost_savings_percentage': rec.cost_savings,
                    'risks': rec.risks,
                    'prerequisites': rec.prerequisites
                }
                for rec in self.recommendations
            ],
            'migration_waves': self.generate_migration_waves(),
            'tco_analysis': self.calculate_tco_analysis(),
            'summary_statistics': self._generate_summary_statistics()
        }
        
        with open(output_file, 'w') as f:
            json.dump(report, f, indent=2)
        
        logger.info(f"Assessment report exported to {output_file}")
    
    def _generate_summary_statistics(self) -> Dict[str, Any]:
        """Generate summary statistics for the assessment"""
        pattern_counts = {}
        total_cost_savings = 0
        
        for rec in self.recommendations:
            pattern = rec.recommended_pattern.value
            pattern_counts[pattern] = pattern_counts.get(pattern, 0) + 1
            total_cost_savings += rec.cost_savings
        
        avg_cost_savings = total_cost_savings / len(self.recommendations) if self.recommendations else 0
        
        return {
            'migration_pattern_distribution': pattern_counts,
            'average_cost_savings_percentage': avg_cost_savings,
            'servers_by_os': self._count_servers_by_os(),
            'high_risk_migrations': len([r for r in self.recommendations if len(r.risks) > 2]),
            'complex_migrations': len([r for r in self.recommendations if 'refactor' in r.recommended_pattern.value])
        }
    
    def _count_servers_by_os(self) -> Dict[str, int]:
        """Count servers by operating system"""
        os_counts = {}
        for server in self.servers:
            os_type = server.os_type.lower()
            if 'windows' in os_type:
                os_family = 'Windows'
            elif 'linux' in os_type or 'ubuntu' in os_type or 'centos' in os_type or 'rhel' in os_type:
                os_family = 'Linux'
            else:
                os_family = 'Other'
            
            os_counts[os_family] = os_counts.get(os_family, 0) + 1
        
        return os_counts

def main():
    """Main function to run the migration assessment"""
    parser = argparse.ArgumentParser(description='AWS Migration Assessment Tool')
    parser.add_argument('--csv-file', help='CSV file with server inventory')
    parser.add_argument('--output', default='migration_assessment_report.json', 
                       help='Output file for assessment report')
    parser.add_argument('--region', default='us-east-1', 
                       help='AWS region for assessment')
    parser.add_argument('--discover', action='store_true', 
                       help='Use AWS Application Discovery Service')
    
    args = parser.parse_args()
    
    # Initialize assessment tool
    assessment = MigrationAssessment(region_name=args.region)
    
    try:
        if args.discover:
            # Use AWS Discovery Service
            discovery_results = assessment.discover_infrastructure()
            if discovery_results.get('error'):
                logger.error(f"Discovery failed: {discovery_results['error']}")
                return
        elif args.csv_file:
            # Load from CSV file
            assessment.load_inventory_from_csv(args.csv_file)
        else:
            logger.error("Please provide either --csv-file or --discover option")
            return
        
        # Perform analysis
        recommendations = assessment.analyze_migration_patterns()
        logger.info(f"Generated {len(recommendations)} migration recommendations")
        
        # Export report
        assessment.export_assessment_report(args.output)
        
        # Print summary
        tco = assessment.calculate_tco_analysis()
        print(f"\n=== Migration Assessment Summary ===")
        print(f"Total Servers: {len(assessment.servers)}")
        print(f"Annual Cost Savings: ${tco['annual_savings']:,.2f}")
        print(f"3-Year ROI: {tco['roi_percentage']:.1f}%")
        print(f"Payback Period: {tco['payback_period_months']:.1f} months")
        print(f"Full report saved to: {args.output}")
        
    except Exception as e:
        logger.error(f"Assessment failed: {str(e)}")
        raise

if __name__ == "__main__":
    main()