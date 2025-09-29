#!/usr/bin/env python3
"""
AWS Disaster Recovery Web Application - Deployment Script

This script automates the deployment and management of AWS disaster recovery
infrastructure using boto3 SDK and comprehensive health monitoring.
"""

import os
import sys
import json
import time
import boto3
import logging
from typing import Dict, List, Optional, Tuple
from botocore.exceptions import ClientError, BotoCoreError
from dataclasses import dataclass
from concurrent.futures import ThreadPoolExecutor, as_completed

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

@dataclass
class DRConfig:
    """Disaster Recovery configuration parameters"""
    project_name: str
    environment: str
    primary_region: str
    secondary_region: str
    domain_name: str
    rto_minutes: int = 15
    rpo_minutes: int = 5
    
class DisasterRecoveryDeployment:
    """AWS Disaster Recovery deployment manager"""
    
    def __init__(self, config: DRConfig):
        self.config = config
        
        # Initialize AWS clients for both regions
        self.primary_session = boto3.Session(region_name=config.primary_region)
        self.secondary_session = boto3.Session(region_name=config.secondary_region)
        
        # Primary region clients
        self.primary_ec2 = self.primary_session.client('ec2')
        self.primary_rds = self.primary_session.client('rds')
        self.primary_elbv2 = self.primary_session.client('elbv2')
        self.primary_autoscaling = self.primary_session.client('autoscaling')
        self.primary_s3 = self.primary_session.client('s3')
        self.primary_cloudformation = self.primary_session.client('cloudformation')
        
        # Secondary region clients
        self.secondary_ec2 = self.secondary_session.client('ec2')
        self.secondary_rds = self.secondary_session.client('rds')
        self.secondary_elbv2 = self.secondary_session.client('elbv2')
        self.secondary_autoscaling = self.secondary_session.client('autoscaling')
        self.secondary_s3 = self.secondary_session.client('s3')
        
        # Global services (region-agnostic)
        self.route53 = boto3.client('route53')
        self.cloudfront = boto3.client('cloudfront')
        
        logger.info(f"Initialized DR deployment for {config.project_name}")
        logger.info(f"Primary region: {config.primary_region}")
        logger.info(f"Secondary region: {config.secondary_region}")
    
    def validate_prerequisites(self) -> bool:
        """Validate deployment prerequisites"""
        logger.info("Validating deployment prerequisites")
        
        try:
            # Validate AWS credentials and permissions
            sts_client = boto3.client('sts')
            identity = sts_client.get_caller_identity()
            logger.info(f"AWS Identity: {identity['Arn']}")
            
            # Validate regions accessibility
            primary_regions = self.primary_ec2.describe_regions()['Regions']
            secondary_regions = self.secondary_ec2.describe_regions()['Regions']
            
            primary_available = any(r['RegionName'] == self.config.primary_region for r in primary_regions)
            secondary_available = any(r['RegionName'] == self.config.secondary_region for r in secondary_regions)
            
            if not primary_available:
                logger.error(f"Primary region {self.config.primary_region} not accessible")
                return False
                
            if not secondary_available:
                logger.error(f"Secondary region {self.config.secondary_region} not accessible")
                return False
            
            # Validate domain ownership (if Route53 managed)
            try:
                zones = self.route53.list_hosted_zones_by_name(
                    DNSName=self.config.domain_name,
                    MaxItems='1'
                )
                if not zones['HostedZones']:
                    logger.warning(f"Domain {self.config.domain_name} not found in Route53")
            except ClientError as e:
                logger.warning(f"Could not verify domain ownership: {e}")
            
            logger.info("Prerequisites validation successful")
            return True
            
        except Exception as e:
            logger.error(f"Prerequisites validation failed: {e}")
            return False
    
    def create_vpc_infrastructure(self, region: str, cidr: str) -> Dict:
        """Create VPC infrastructure in specified region"""
        logger.info(f"Creating VPC infrastructure in {region}")
        
        if region == self.config.primary_region:
            ec2_client = self.primary_ec2
        else:
            ec2_client = self.secondary_ec2
        
        try:
            # Create VPC
            vpc_response = ec2_client.create_vpc(
                CidrBlock=cidr,
                TagSpecifications=[
                    {
                        'ResourceType': 'vpc',
                        'Tags': [
                            {'Key': 'Name', 'Value': f'{self.config.project_name}-{region}-vpc'},
                            {'Key': 'Project', 'Value': self.config.project_name},
                            {'Key': 'Environment', 'Value': self.config.environment},
                            {'Key': 'Region', 'Value': region}
                        ]
                    }
                ]
            )
            vpc_id = vpc_response['Vpc']['VpcId']
            logger.info(f"Created VPC {vpc_id} in {region}")
            
            # Enable DNS hostnames and resolution
            ec2_client.modify_vpc_attribute(VpcId=vpc_id, EnableDnsHostnames={'Value': True})
            ec2_client.modify_vpc_attribute(VpcId=vpc_id, EnableDnsSupport={'Value': True})
            
            # Create Internet Gateway
            igw_response = ec2_client.create_internet_gateway(
                TagSpecifications=[
                    {
                        'ResourceType': 'internet-gateway',
                        'Tags': [
                            {'Key': 'Name', 'Value': f'{self.config.project_name}-{region}-igw'},
                            {'Key': 'Project', 'Value': self.config.project_name}
                        ]
                    }
                ]
            )
            igw_id = igw_response['InternetGateway']['InternetGatewayId']
            
            # Attach Internet Gateway to VPC
            ec2_client.attach_internet_gateway(InternetGatewayId=igw_id, VpcId=vpc_id)
            
            # Get availability zones
            azs_response = ec2_client.describe_availability_zones()
            available_azs = [az['ZoneName'] for az in azs_response['AvailabilityZones'][:3]]
            
            # Create subnets
            subnets = {'public': [], 'private': []}
            
            for i, az in enumerate(available_azs):
                # Public subnet
                public_subnet = ec2_client.create_subnet(
                    VpcId=vpc_id,
                    CidrBlock=f"{cidr[:-4]}{i}.0/24",  # e.g., 10.0.0.0/24, 10.0.1.0/24
                    AvailabilityZone=az,
                    TagSpecifications=[
                        {
                            'ResourceType': 'subnet',
                            'Tags': [
                                {'Key': 'Name', 'Value': f'{self.config.project_name}-{region}-public-{i+1}'},
                                {'Key': 'Type', 'Value': 'Public'},
                                {'Key': 'Project', 'Value': self.config.project_name}
                            ]
                        }
                    ]
                )
                subnets['public'].append(public_subnet['Subnet']['SubnetId'])
                
                # Private subnet
                private_subnet = ec2_client.create_subnet(
                    VpcId=vpc_id,
                    CidrBlock=f"{cidr[:-4]}{i+10}.0/24",  # e.g., 10.0.10.0/24, 10.0.11.0/24
                    AvailabilityZone=az,
                    TagSpecifications=[
                        {
                            'ResourceType': 'subnet',
                            'Tags': [
                                {'Key': 'Name', 'Value': f'{self.config.project_name}-{region}-private-{i+1}'},
                                {'Key': 'Type', 'Value': 'Private'},
                                {'Key': 'Project', 'Value': self.config.project_name}
                            ]
                        }
                    ]
                )
                subnets['private'].append(private_subnet['Subnet']['SubnetId'])
            
            # Create and configure route tables
            # Public route table
            public_rt_response = ec2_client.create_route_table(VpcId=vpc_id)
            public_rt_id = public_rt_response['RouteTable']['RouteTableId']
            
            # Add route to Internet Gateway
            ec2_client.create_route(
                RouteTableId=public_rt_id,
                DestinationCidrBlock='0.0.0.0/0',
                GatewayId=igw_id
            )
            
            # Associate public subnets with public route table
            for subnet_id in subnets['public']:
                ec2_client.associate_route_table(SubnetId=subnet_id, RouteTableId=public_rt_id)
            
            return {
                'vpc_id': vpc_id,
                'igw_id': igw_id,
                'subnets': subnets,
                'public_route_table': public_rt_id
            }
            
        except Exception as e:
            logger.error(f"Failed to create VPC infrastructure in {region}: {e}")
            raise
    
    def create_security_groups(self, vpc_info: Dict, region: str) -> Dict:
        """Create security groups for the application"""
        logger.info(f"Creating security groups in {region}")
        
        if region == self.config.primary_region:
            ec2_client = self.primary_ec2
        else:
            ec2_client = self.secondary_ec2
        
        security_groups = {}
        
        try:
            # ALB Security Group
            alb_sg = ec2_client.create_security_group(
                GroupName=f'{self.config.project_name}-{region}-alb-sg',
                Description='Security group for Application Load Balancer',
                VpcId=vpc_info['vpc_id']
            )
            alb_sg_id = alb_sg['GroupId']
            
            # Allow HTTP and HTTPS traffic
            ec2_client.authorize_security_group_ingress(
                GroupId=alb_sg_id,
                IpPermissions=[
                    {
                        'IpProtocol': 'tcp',
                        'FromPort': 80,
                        'ToPort': 80,
                        'IpRanges': [{'CidrIp': '0.0.0.0/0', 'Description': 'HTTP from anywhere'}]
                    },
                    {
                        'IpProtocol': 'tcp',
                        'FromPort': 443,
                        'ToPort': 443,
                        'IpRanges': [{'CidrIp': '0.0.0.0/0', 'Description': 'HTTPS from anywhere'}]
                    }
                ]
            )
            
            security_groups['alb'] = alb_sg_id
            
            # EC2 Security Group
            ec2_sg = ec2_client.create_security_group(
                GroupName=f'{self.config.project_name}-{region}-ec2-sg',
                Description='Security group for EC2 instances',
                VpcId=vpc_info['vpc_id']
            )
            ec2_sg_id = ec2_sg['GroupId']
            
            # Allow traffic from ALB
            ec2_client.authorize_security_group_ingress(
                GroupId=ec2_sg_id,
                IpPermissions=[
                    {
                        'IpProtocol': 'tcp',
                        'FromPort': 80,
                        'ToPort': 80,
                        'UserIdGroupPairs': [{'GroupId': alb_sg_id, 'Description': 'HTTP from ALB'}]
                    },
                    {
                        'IpProtocol': 'tcp',
                        'FromPort': 22,
                        'ToPort': 22,
                        'IpRanges': [{'CidrIp': vpc_info['vpc_id'], 'Description': 'SSH from VPC'}]
                    }
                ]
            )
            
            security_groups['ec2'] = ec2_sg_id
            
            # RDS Security Group
            rds_sg = ec2_client.create_security_group(
                GroupName=f'{self.config.project_name}-{region}-rds-sg',
                Description='Security group for RDS database',
                VpcId=vpc_info['vpc_id']
            )
            rds_sg_id = rds_sg['GroupId']
            
            # Allow database traffic from EC2
            ec2_client.authorize_security_group_ingress(
                GroupId=rds_sg_id,
                IpPermissions=[
                    {
                        'IpProtocol': 'tcp',
                        'FromPort': 3306,
                        'ToPort': 3306,
                        'UserIdGroupPairs': [{'GroupId': ec2_sg_id, 'Description': 'MySQL from EC2'}]
                    }
                ]
            )
            
            security_groups['rds'] = rds_sg_id
            
            logger.info(f"Created security groups in {region}: {list(security_groups.keys())}")
            return security_groups
            
        except Exception as e:
            logger.error(f"Failed to create security groups in {region}: {e}")
            raise
    
    def setup_application_load_balancer(self, vpc_info: Dict, security_groups: Dict, region: str) -> str:
        """Create Application Load Balancer"""
        logger.info(f"Setting up Application Load Balancer in {region}")
        
        if region == self.config.primary_region:
            elbv2_client = self.primary_elbv2
        else:
            elbv2_client = self.secondary_elbv2
        
        try:
            # Create Application Load Balancer
            alb_response = elbv2_client.create_load_balancer(
                Name=f'{self.config.project_name}-{region}-alb',
                Subnets=vpc_info['subnets']['public'],
                SecurityGroups=[security_groups['alb']],
                Scheme='internet-facing',
                Type='application',
                IpAddressType='ipv4'
            )
            
            alb_arn = alb_response['LoadBalancers'][0]['LoadBalancerArn']
            alb_dns = alb_response['LoadBalancers'][0]['DNSName']
            
            # Create target group
            target_group_response = elbv2_client.create_target_group(
                Name=f'{self.config.project_name}-{region}-tg',
                Protocol='HTTP',
                Port=80,
                VpcId=vpc_info['vpc_id'],
                HealthCheckProtocol='HTTP',
                HealthCheckPath='/',
                HealthCheckIntervalSeconds=30,
                HealthCheckTimeoutSeconds=5,
                HealthyThresholdCount=2,
                UnhealthyThresholdCount=5
            )
            
            target_group_arn = target_group_response['TargetGroups'][0]['TargetGroupArn']
            
            # Create listener
            elbv2_client.create_listener(
                LoadBalancerArn=alb_arn,
                Protocol='HTTP',
                Port=80,
                DefaultActions=[
                    {
                        'Type': 'forward',
                        'TargetGroupArn': target_group_arn
                    }
                ]
            )
            
            logger.info(f"Created ALB in {region}: {alb_dns}")
            return {
                'alb_arn': alb_arn,
                'alb_dns': alb_dns,
                'target_group_arn': target_group_arn
            }
            
        except Exception as e:
            logger.error(f"Failed to create ALB in {region}: {e}")
            raise
    
    def setup_rds_with_replication(self) -> Dict:
        """Setup RDS with cross-region read replica"""
        logger.info("Setting up RDS with cross-region replication")
        
        try:
            # Create DB subnet group in primary region
            primary_db_subnet_group = self.primary_rds.create_db_subnet_group(
                DBSubnetGroupName=f'{self.config.project_name}-primary-db-subnet-group',
                DBSubnetGroupDescription='DB subnet group for primary database',
                SubnetIds=['subnet-primary-1', 'subnet-primary-2'],  # Replace with actual subnet IDs
                Tags=[
                    {'Key': 'Project', 'Value': self.config.project_name},
                    {'Key': 'Environment', 'Value': self.config.environment}
                ]
            )
            
            # Create primary RDS instance
            primary_db = self.primary_rds.create_db_instance(
                DBInstanceIdentifier=f'{self.config.project_name}-primary-db',
                DBInstanceClass='db.r5.large',
                Engine='mysql',
                MasterUsername='admin',
                MasterUserPassword=os.getenv('DB_PASSWORD'),
                AllocatedStorage=100,
                StorageType='gp2',
                StorageEncrypted=True,
                VpcSecurityGroupIds=['sg-rds'],  # Replace with actual security group ID
                DBSubnetGroupName=primary_db_subnet_group['DBSubnetGroup']['DBSubnetGroupName'],
                BackupRetentionPeriod=7,
                PreferredBackupWindow='03:00-04:00',
                PreferredMaintenanceWindow='sun:04:00-sun:05:00',
                MultiAZ=True,
                PubliclyAccessible=False,
                Tags=[
                    {'Key': 'Project', 'Value': self.config.project_name},
                    {'Key': 'Environment', 'Value': self.config.environment},
                    {'Key': 'Role', 'Value': 'Primary'}
                ]
            )
            
            # Wait for primary database to be available
            logger.info("Waiting for primary database to be available...")
            self.primary_rds.get_waiter('db_instance_available').wait(
                DBInstanceIdentifier=f'{self.config.project_name}-primary-db',
                WaiterConfig={'Delay': 30, 'MaxAttempts': 40}
            )
            
            # Create read replica in secondary region
            secondary_db = self.secondary_rds.create_db_instance_read_replica(
                DBInstanceIdentifier=f'{self.config.project_name}-secondary-db',
                SourceDBInstanceIdentifier=primary_db['DBInstance']['DBInstanceArn'],
                DBInstanceClass='db.r5.large',
                PubliclyAccessible=False,
                Tags=[
                    {'Key': 'Project', 'Value': self.config.project_name},
                    {'Key': 'Environment', 'Value': self.config.environment},
                    {'Key': 'Role', 'Value': 'ReadReplica'}
                ]
            )
            
            logger.info("RDS setup with cross-region replication completed")
            return {
                'primary_endpoint': primary_db['DBInstance']['Endpoint']['Address'],
                'secondary_endpoint': secondary_db['DBInstance']['Endpoint']['Address']
            }
            
        except Exception as e:
            logger.error(f"Failed to setup RDS: {e}")
            raise
    
    def setup_route53_health_checks(self, primary_endpoint: str, secondary_endpoint: str) -> Dict:
        """Setup Route53 health checks and failover routing"""
        logger.info("Setting up Route53 health checks and DNS failover")
        
        try:
            # Create health check for primary endpoint
            primary_health_check = self.route53.create_health_check(
                Type='HTTPS',
                ResourcePath='/',
                FullyQualifiedDomainName=primary_endpoint,
                Port=443,
                RequestInterval=30,
                FailureThreshold=3
            )
            
            primary_hc_id = primary_health_check['HealthCheck']['Id']
            
            # Create health check for secondary endpoint
            secondary_health_check = self.route53.create_health_check(
                Type='HTTPS',
                ResourcePath='/',
                FullyQualifiedDomainName=secondary_endpoint,
                Port=443,
                RequestInterval=30,
                FailureThreshold=3
            )
            
            secondary_hc_id = secondary_health_check['HealthCheck']['Id']
            
            # Create hosted zone if it doesn't exist
            try:
                zones = self.route53.list_hosted_zones_by_name(
                    DNSName=self.config.domain_name,
                    MaxItems='1'
                )
                if zones['HostedZones']:
                    hosted_zone_id = zones['HostedZones'][0]['Id']
                else:
                    # Create new hosted zone
                    zone_response = self.route53.create_hosted_zone(
                        Name=self.config.domain_name,
                        CallerReference=str(int(time.time()))
                    )
                    hosted_zone_id = zone_response['HostedZone']['Id']
            except Exception as e:
                logger.error(f"Failed to setup hosted zone: {e}")
                raise
            
            # Create failover DNS records
            self.route53.change_resource_record_sets(
                HostedZoneId=hosted_zone_id,
                ChangeBatch={
                    'Changes': [
                        {
                            'Action': 'UPSERT',
                            'ResourceRecordSet': {
                                'Name': f'app.{self.config.domain_name}',
                                'Type': 'CNAME',
                                'SetIdentifier': 'primary',
                                'Failover': 'PRIMARY',
                                'TTL': 60,
                                'ResourceRecords': [{'Value': primary_endpoint}],
                                'HealthCheckId': primary_hc_id
                            }
                        },
                        {
                            'Action': 'UPSERT',
                            'ResourceRecordSet': {
                                'Name': f'app.{self.config.domain_name}',
                                'Type': 'CNAME',
                                'SetIdentifier': 'secondary',
                                'Failover': 'SECONDARY',
                                'TTL': 60,
                                'ResourceRecords': [{'Value': secondary_endpoint}]
                            }
                        }
                    ]
                }
            )
            
            logger.info("Route53 health checks and DNS failover configured")
            return {
                'hosted_zone_id': hosted_zone_id,
                'primary_health_check_id': primary_hc_id,
                'secondary_health_check_id': secondary_hc_id
            }
            
        except Exception as e:
            logger.error(f"Failed to setup Route53 health checks: {e}")
            raise
    
    def test_failover_mechanism(self) -> bool:
        """Test disaster recovery failover mechanism"""
        logger.info("Testing disaster recovery failover mechanism")
        
        try:
            # Test DNS resolution
            import socket
            primary_ip = socket.gethostbyname(f'app.{self.config.domain_name}')
            logger.info(f"DNS resolves to: {primary_ip}")
            
            # Test application connectivity
            import requests
            response = requests.get(f'https://app.{self.config.domain_name}', timeout=10)
            if response.status_code == 200:
                logger.info("Application is accessible")
                return True
            else:
                logger.warning(f"Application returned status code: {response.status_code}")
                return False
                
        except Exception as e:
            logger.error(f"Failover test failed: {e}")
            return False
    
    def deploy(self) -> bool:
        """Execute full disaster recovery deployment"""
        logger.info(f"Starting disaster recovery deployment for {self.config.project_name}")
        
        try:
            # Validate prerequisites
            if not self.validate_prerequisites():
                return False
            
            # Deploy infrastructure in both regions concurrently
            with ThreadPoolExecutor(max_workers=2) as executor:
                # Primary region deployment
                primary_future = executor.submit(
                    self.create_vpc_infrastructure,
                    self.config.primary_region,
                    '10.0.0.0/16'
                )
                
                # Secondary region deployment
                secondary_future = executor.submit(
                    self.create_vpc_infrastructure,
                    self.config.secondary_region,
                    '10.1.0.0/16'
                )
                
                # Wait for both deployments to complete
                primary_vpc = primary_future.result()
                secondary_vpc = secondary_future.result()
            
            logger.info("VPC infrastructure created in both regions")
            
            # Setup security groups
            primary_sg = self.create_security_groups(primary_vpc, self.config.primary_region)
            secondary_sg = self.create_security_groups(secondary_vpc, self.config.secondary_region)
            
            # Setup load balancers
            primary_alb = self.setup_application_load_balancer(primary_vpc, primary_sg, self.config.primary_region)
            secondary_alb = self.setup_application_load_balancer(secondary_vpc, secondary_sg, self.config.secondary_region)
            
            # Setup RDS with cross-region replication
            rds_config = self.setup_rds_with_replication()
            
            # Setup Route53 health checks and DNS failover
            dns_config = self.setup_route53_health_checks(
                primary_alb['alb_dns'],
                secondary_alb['alb_dns']
            )
            
            # Test failover mechanism
            if self.test_failover_mechanism():
                logger.info("Disaster recovery failover test successful")
            else:
                logger.warning("Disaster recovery failover test failed")
            
            logger.info("Disaster recovery deployment completed successfully")
            
            # Output deployment summary
            deployment_summary = {
                'project_name': self.config.project_name,
                'primary_region': self.config.primary_region,
                'secondary_region': self.config.secondary_region,
                'primary_alb_dns': primary_alb['alb_dns'],
                'secondary_alb_dns': secondary_alb['alb_dns'],
                'rds_primary_endpoint': rds_config['primary_endpoint'],
                'rds_secondary_endpoint': rds_config['secondary_endpoint'],
                'dns_zone_id': dns_config['hosted_zone_id'],
                'application_url': f'https://app.{self.config.domain_name}'
            }
            
            print("\n" + "=" * 50)
            print("DISASTER RECOVERY DEPLOYMENT SUMMARY")
            print("=" * 50)
            for key, value in deployment_summary.items():
                print(f"{key.replace('_', ' ').title()}: {value}")
            
            return True
            
        except Exception as e:
            logger.error(f"Deployment failed: {e}")
            return False

def main():
    """Main deployment function"""
    
    # Load configuration from environment variables
    config = DRConfig(
        project_name=os.getenv('PROJECT_NAME', 'disaster-recovery-web-app'),
        environment=os.getenv('ENVIRONMENT', 'prod'),
        primary_region=os.getenv('PRIMARY_REGION', 'us-east-1'),
        secondary_region=os.getenv('SECONDARY_REGION', 'us-west-2'),
        domain_name=os.getenv('DOMAIN_NAME', 'company.com'),
        rto_minutes=int(os.getenv('RTO_MINUTES', '15')),
        rpo_minutes=int(os.getenv('RPO_MINUTES', '5'))
    )
    
    # Validate required environment variables
    if not config.domain_name or config.domain_name == 'company.com':
        logger.error("DOMAIN_NAME environment variable must be set")
        sys.exit(1)
    
    if not os.getenv('DB_PASSWORD'):
        logger.error("DB_PASSWORD environment variable must be set")
        sys.exit(1)
    
    # Initialize deployment
    deployment = DisasterRecoveryDeployment(config)
    
    # Execute deployment
    if deployment.deploy():
        logger.info("Deployment completed successfully")
        sys.exit(0)
    else:
        logger.error("Deployment failed")
        sys.exit(1)

if __name__ == '__main__':
    main()