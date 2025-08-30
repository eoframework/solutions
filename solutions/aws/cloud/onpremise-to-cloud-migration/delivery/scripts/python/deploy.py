#!/usr/bin/env python3
"""
AWS On-Premise to Cloud Migration - Deployment Script

This script automates the setup and orchestration of AWS migration services
including DMS, DataSync, Application Migration Service, and Migration Hub.
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
class MigrationConfig:
    """Migration configuration parameters"""
    project_name: str
    environment: str
    aws_region: str
    vpc_id: str
    subnet_ids: List[str]
    migration_bucket: str
    enable_database_migration: bool = True
    enable_file_migration: bool = True
    enable_server_migration: bool = True
    notification_email: str = ""

class CloudMigrationDeployment:
    """AWS Cloud Migration deployment manager"""
    
    def __init__(self, config: MigrationConfig):
        self.config = config
        self.session = boto3.Session(region_name=config.aws_region)
        
        # Initialize AWS clients
        self.dms_client = self.session.client('dms')
        self.datasync_client = self.session.client('datasync')
        self.mgn_client = self.session.client('mgn')
        self.mgh_client = self.session.client('mgh')
        self.s3_client = self.session.client('s3')
        self.ec2_client = self.session.client('ec2')
        self.iam_client = self.session.client('iam')
        self.sns_client = self.session.client('sns')
        self.cloudwatch_client = self.session.client('cloudwatch')
        self.lambda_client = self.session.client('lambda')
        
        logger.info(f"Initialized migration deployment for {config.project_name}")
    
    def validate_prerequisites(self) -> bool:
        """Validate migration prerequisites"""
        logger.info("Validating migration prerequisites")
        
        try:
            # Validate AWS credentials
            sts_client = self.session.client('sts')
            identity = sts_client.get_caller_identity()
            logger.info(f"AWS Identity: {identity['Arn']}")
            
            # Validate VPC and subnets
            try:
                vpc_response = self.ec2_client.describe_vpcs(VpcIds=[self.config.vpc_id])
                if not vpc_response['Vpcs']:
                    logger.error(f"VPC {self.config.vpc_id} not found")
                    return False
                logger.info(f"VPC {self.config.vpc_id} validated")
            except ClientError as e:
                logger.error(f"VPC validation failed: {e}")
                return False
            
            # Validate subnets
            try:
                subnet_response = self.ec2_client.describe_subnets(SubnetIds=self.config.subnet_ids)
                if len(subnet_response['Subnets']) != len(self.config.subnet_ids):
                    logger.error("Some subnets not found")
                    return False
                logger.info(f"All {len(self.config.subnet_ids)} subnets validated")
            except ClientError as e:
                logger.error(f"Subnet validation failed: {e}")
                return False
            
            # Check service limits
            try:
                # Check DMS limits
                replication_instances = self.dms_client.describe_replication_instances()
                logger.info(f"Current DMS instances: {len(replication_instances['ReplicationInstances'])}")
                
                # Check DataSync limits
                datasync_tasks = self.datasync_client.list_tasks()
                logger.info(f"Current DataSync tasks: {len(datasync_tasks['Tasks'])}")
                
            except ClientError as e:
                logger.warning(f"Could not check service limits: {e}")
            
            logger.info("Prerequisites validation successful")
            return True
            
        except Exception as e:
            logger.error(f"Prerequisites validation failed: {e}")
            return False
    
    def setup_migration_hub(self) -> bool:
        """Setup AWS Migration Hub for tracking"""
        logger.info("Setting up Migration Hub")
        
        try:
            # Set Migration Hub home region
            home_region = self.mgh_client.create_home_region_control(
                HomeRegion=self.config.aws_region,
                Target={
                    'Type': 'ACCOUNT'
                }
            )
            logger.info(f"Migration Hub home region set to {self.config.aws_region}")
            
            # Create migration task
            migration_task = self.mgh_client.put_resource_attributes(
                ProgressUpdateStream=self.config.project_name,
                MigrationTaskName=f"{self.config.project_name}-migration-task",
                ResourceAttributeList=[
                    {
                        'Type': 'STRING',
                        'Value': 'OnPremiseToCloud'
                    }
                ]
            )
            
            logger.info("Migration Hub setup completed")
            return True
            
        except ClientError as e:
            if 'HomeRegionNotSetException' in str(e) or 'AlreadyExistsException' in str(e):
                logger.info("Migration Hub already configured")
                return True
            logger.error(f"Migration Hub setup failed: {e}")
            return False
    
    def create_s3_migration_bucket(self) -> bool:
        """Create S3 bucket for migration data"""
        logger.info(f"Creating S3 bucket: {self.config.migration_bucket}")
        
        try:
            # Check if bucket already exists
            try:
                self.s3_client.head_bucket(Bucket=self.config.migration_bucket)
                logger.info(f"S3 bucket {self.config.migration_bucket} already exists")
                return True
            except ClientError as e:
                if e.response['Error']['Code'] != '404':
                    raise e
            
            # Create bucket
            if self.config.aws_region == 'us-east-1':
                self.s3_client.create_bucket(Bucket=self.config.migration_bucket)
            else:
                self.s3_client.create_bucket(
                    Bucket=self.config.migration_bucket,
                    CreateBucketConfiguration={
                        'LocationConstraint': self.config.aws_region
                    }
                )
            
            # Enable versioning
            self.s3_client.put_bucket_versioning(
                Bucket=self.config.migration_bucket,
                VersioningConfiguration={'Status': 'Enabled'}
            )
            
            # Enable encryption
            self.s3_client.put_bucket_encryption(
                Bucket=self.config.migration_bucket,
                ServerSideEncryptionConfiguration={
                    'Rules': [{
                        'ApplyServerSideEncryptionByDefault': {
                            'SSEAlgorithm': 'AES256'
                        }
                    }]
                }
            )
            
            # Set lifecycle policy
            self.s3_client.put_bucket_lifecycle_configuration(
                Bucket=self.config.migration_bucket,
                LifecycleConfiguration={
                    'Rules': [
                        {
                            'ID': 'migration-data-lifecycle',
                            'Status': 'Enabled',
                            'Filter': {'Prefix': 'migration-data/'},
                            'Transitions': [
                                {
                                    'Days': 30,
                                    'StorageClass': 'STANDARD_IA'
                                },
                                {
                                    'Days': 90,
                                    'StorageClass': 'GLACIER'
                                }
                            ]
                        }
                    ]
                }
            )
            
            logger.info(f"S3 bucket {self.config.migration_bucket} created and configured")
            return True
            
        except Exception as e:
            logger.error(f"Failed to create S3 bucket: {e}")
            return False
    
    def setup_database_migration_service(self) -> Optional[Dict]:
        """Setup AWS Database Migration Service"""
        if not self.config.enable_database_migration:
            logger.info("Database migration disabled, skipping DMS setup")
            return None
            
        logger.info("Setting up Database Migration Service (DMS)")
        
        try:
            # Create DMS subnet group
            subnet_group_name = f"{self.config.project_name}-dms-subnet-group"
            
            try:
                subnet_group = self.dms_client.create_replication_subnet_group(
                    ReplicationSubnetGroupIdentifier=subnet_group_name,
                    ReplicationSubnetGroupDescription=f"DMS subnet group for {self.config.project_name}",
                    SubnetIds=self.config.subnet_ids,
                    Tags=[
                        {'Key': 'Project', 'Value': self.config.project_name},
                        {'Key': 'Environment', 'Value': self.config.environment}
                    ]
                )
                logger.info(f"Created DMS subnet group: {subnet_group_name}")
            except ClientError as e:
                if 'ReplicationSubnetGroupAlreadyExistsFault' in str(e):
                    logger.info(f"DMS subnet group {subnet_group_name} already exists")
                else:
                    raise e
            
            # Create replication instance
            replication_instance_id = f"{self.config.project_name}-replication-instance"
            
            try:
                replication_instance = self.dms_client.create_replication_instance(
                    ReplicationInstanceIdentifier=replication_instance_id,
                    ReplicationInstanceClass='dms.r5.large',
                    AllocatedStorage=100,
                    VpcSecurityGroupIds=[],  # Will be populated with security group
                    ReplicationSubnetGroupIdentifier=subnet_group_name,
                    PreferredMaintenanceWindow='sun:05:00-sun:06:00',
                    MultiAZ=True,
                    EngineVersion='3.4.7',
                    AutoMinorVersionUpgrade=True,
                    Tags=[
                        {'Key': 'Project', 'Value': self.config.project_name},
                        {'Key': 'Environment', 'Value': self.config.environment}
                    ]
                )
                logger.info(f"Created DMS replication instance: {replication_instance_id}")
            except ClientError as e:
                if 'ReplicationInstanceAlreadyExistsFault' in str(e):
                    logger.info(f"DMS replication instance {replication_instance_id} already exists")
                else:
                    raise e
            
            # Wait for replication instance to be available
            logger.info("Waiting for replication instance to be available...")
            waiter = self.dms_client.get_waiter('replication_instance_available')
            waiter.wait(
                ReplicationInstanceIdentifier=replication_instance_id,
                WaiterConfig={'Delay': 30, 'MaxAttempts': 40}
            )
            
            return {
                'replication_instance_id': replication_instance_id,
                'subnet_group_name': subnet_group_name
            }
            
        except Exception as e:
            logger.error(f"Failed to setup DMS: {e}")
            return None
    
    def setup_datasync_service(self) -> Optional[Dict]:
        """Setup AWS DataSync for file migration"""
        if not self.config.enable_file_migration:
            logger.info("File migration disabled, skipping DataSync setup")
            return None
            
        logger.info("Setting up DataSync service")
        
        try:
            # Create DataSync S3 location
            s3_location = self.datasync_client.create_location_s3(
                S3BucketArn=f"arn:aws:s3:::{self.config.migration_bucket}",
                Subdirectory='/file-migration',
                S3Config={
                    'BucketAccessRoleArn': self.create_datasync_role()
                },
                Tags=[
                    {'Key': 'Project', 'Value': self.config.project_name},
                    {'Key': 'Environment', 'Value': self.config.environment}
                ]
            )
            
            s3_location_arn = s3_location['LocationArn']
            logger.info(f"Created DataSync S3 location: {s3_location_arn}")
            
            return {
                's3_location_arn': s3_location_arn
            }
            
        except Exception as e:
            logger.error(f"Failed to setup DataSync: {e}")
            return None
    
    def create_datasync_role(self) -> str:
        """Create IAM role for DataSync S3 access"""
        role_name = f"{self.config.project_name}-datasync-s3-role"
        
        try:
            # Check if role exists
            try:
                role = self.iam_client.get_role(RoleName=role_name)
                return role['Role']['Arn']
            except ClientError as e:
                if e.response['Error']['Code'] != 'NoSuchEntity':
                    raise e
            
            # Create trust policy
            trust_policy = {
                "Version": "2012-10-17",
                "Statement": [
                    {
                        "Effect": "Allow",
                        "Principal": {
                            "Service": "datasync.amazonaws.com"
                        },
                        "Action": "sts:AssumeRole"
                    }
                ]
            }
            
            # Create role
            role = self.iam_client.create_role(
                RoleName=role_name,
                AssumeRolePolicyDocument=json.dumps(trust_policy),
                Description=f"DataSync S3 access role for {self.config.project_name}",
                Tags=[
                    {'Key': 'Project', 'Value': self.config.project_name},
                    {'Key': 'Environment', 'Value': self.config.environment}
                ]
            )
            
            # Create and attach policy
            policy_document = {
                "Version": "2012-10-17",
                "Statement": [
                    {
                        "Effect": "Allow",
                        "Action": [
                            "s3:GetBucketLocation",
                            "s3:ListBucket",
                            "s3:ListBucketMultipartUploads",
                            "s3:GetObject",
                            "s3:GetObjectTagging",
                            "s3:PutObject",
                            "s3:PutObjectTagging",
                            "s3:DeleteObject",
                            "s3:AbortMultipartUpload",
                            "s3:ListMultipartUploadParts"
                        ],
                        "Resource": [
                            f"arn:aws:s3:::{self.config.migration_bucket}",
                            f"arn:aws:s3:::{self.config.migration_bucket}/*"
                        ]
                    }
                ]
            }
            
            policy_name = f"{self.config.project_name}-datasync-s3-policy"
            self.iam_client.put_role_policy(
                RoleName=role_name,
                PolicyName=policy_name,
                PolicyDocument=json.dumps(policy_document)
            )
            
            logger.info(f"Created DataSync IAM role: {role_name}")
            return role['Role']['Arn']
            
        except Exception as e:
            logger.error(f"Failed to create DataSync role: {e}")
            raise
    
    def setup_application_migration_service(self) -> Optional[Dict]:
        """Setup AWS Application Migration Service (MGN)"""
        if not self.config.enable_server_migration:
            logger.info("Server migration disabled, skipping MGN setup")
            return None
            
        logger.info("Setting up Application Migration Service (MGN)")
        
        try:
            # Initialize MGN
            try:
                mgn_init = self.mgn_client.initialize_service()
                logger.info("MGN service initialized")
            except ClientError as e:
                if 'ConflictException' in str(e):
                    logger.info("MGN service already initialized")
                else:
                    raise e
            
            # Create replication configuration template
            template_response = self.mgn_client.create_replication_configuration_template(
                associateDefaultSecurityGroup=True,
                bandwidthThrottling=0,
                createPublicIP=False,
                dataPlaneRouting='PRIVATE_IP',
                defaultLargeStagingDiskType='GP2',
                ebsEncryption='DEFAULT',
                replicationServerInstanceType='m5.large',
                replicationServersSecurityGroupsIDs=[],
                stagingAreaSubnetId=self.config.subnet_ids[0],
                stagingAreaTags={
                    'Project': self.config.project_name,
                    'Environment': self.config.environment
                },
                useDedicatedReplicationServer=False
            )
            
            template_id = template_response['replicationConfigurationTemplateID']
            logger.info(f"Created MGN replication configuration template: {template_id}")
            
            return {
                'replication_template_id': template_id
            }
            
        except Exception as e:
            logger.error(f"Failed to setup MGN: {e}")
            return None
    
    def setup_monitoring_and_alerting(self) -> bool:
        """Setup CloudWatch monitoring and SNS alerts"""
        logger.info("Setting up monitoring and alerting")
        
        try:
            # Create SNS topic if email provided
            if self.config.notification_email:
                topic_response = self.sns_client.create_topic(
                    Name=f"{self.config.project_name}-migration-alerts"
                )
                topic_arn = topic_response['TopicArn']
                
                # Subscribe email to topic
                self.sns_client.subscribe(
                    TopicArn=topic_arn,
                    Protocol='email',
                    Endpoint=self.config.notification_email
                )
                
                logger.info(f"Created SNS topic and email subscription: {topic_arn}")
            
            # Create CloudWatch log group
            log_group_name = f"/aws/migration/{self.config.project_name}"
            
            try:
                self.cloudwatch_client.create_log_group(
                    logGroupName=log_group_name,
                    retentionInDays=30
                )
                logger.info(f"Created CloudWatch log group: {log_group_name}")
            except ClientError as e:
                if 'ResourceAlreadyExistsException' in str(e):
                    logger.info(f"CloudWatch log group {log_group_name} already exists")
                else:
                    raise e
            
            return True
            
        except Exception as e:
            logger.error(f"Failed to setup monitoring: {e}")
            return False
    
    def create_migration_dashboard(self) -> bool:
        """Create CloudWatch dashboard for migration monitoring"""
        logger.info("Creating migration monitoring dashboard")
        
        try:
            dashboard_body = {
                "widgets": [
                    {
                        "type": "metric",
                        "properties": {
                            "metrics": [
                                ["AWS/DMS", "CDCLatencySource"],
                                ["AWS/DMS", "CDCLatencyTarget"]
                            ],
                            "period": 300,
                            "stat": "Average",
                            "region": self.config.aws_region,
                            "title": "DMS Replication Latency"
                        }
                    },
                    {
                        "type": "metric",
                        "properties": {
                            "metrics": [
                                ["AWS/DataSync", "BytesTransferred"],
                                ["AWS/DataSync", "FilesTransferred"]
                            ],
                            "period": 300,
                            "stat": "Sum",
                            "region": self.config.aws_region,
                            "title": "DataSync Transfer Progress"
                        }
                    }
                ]
            }
            
            self.cloudwatch_client.put_dashboard(
                DashboardName=f"{self.config.project_name}-migration-dashboard",
                DashboardBody=json.dumps(dashboard_body)
            )
            
            logger.info("Migration dashboard created")
            return True
            
        except Exception as e:
            logger.error(f"Failed to create dashboard: {e}")
            return False
    
    def generate_migration_report(self, dms_config: Dict, datasync_config: Dict, mgn_config: Dict) -> Dict:
        """Generate migration deployment report"""
        report = {
            'project_name': self.config.project_name,
            'environment': self.config.environment,
            'aws_region': self.config.aws_region,
            'deployment_time': time.strftime('%Y-%m-%d %H:%M:%S UTC', time.gmtime()),
            'migration_services': {
                'database_migration': {
                    'enabled': self.config.enable_database_migration,
                    'dms_instance': dms_config.get('replication_instance_id') if dms_config else None
                },
                'file_migration': {
                    'enabled': self.config.enable_file_migration,
                    's3_location': datasync_config.get('s3_location_arn') if datasync_config else None
                },
                'server_migration': {
                    'enabled': self.config.enable_server_migration,
                    'mgn_template': mgn_config.get('replication_template_id') if mgn_config else None
                }
            },
            'infrastructure': {
                'vpc_id': self.config.vpc_id,
                'subnet_ids': self.config.subnet_ids,
                'migration_bucket': self.config.migration_bucket
            },
            'monitoring': {
                'cloudwatch_logs': f"/aws/migration/{self.config.project_name}",
                'dashboard': f"{self.config.project_name}-migration-dashboard",
                'notifications': bool(self.config.notification_email)
            }
        }
        
        return report
    
    def deploy(self) -> bool:
        """Execute full migration infrastructure deployment"""
        logger.info(f"Starting migration infrastructure deployment for {self.config.project_name}")
        
        try:
            # Validate prerequisites
            if not self.validate_prerequisites():
                return False
            
            # Setup Migration Hub
            if not self.setup_migration_hub():
                logger.warning("Migration Hub setup failed, continuing...")
            
            # Create S3 bucket for migration data
            if not self.create_s3_migration_bucket():
                return False
            
            # Setup migration services in parallel
            with ThreadPoolExecutor(max_workers=3) as executor:
                # Submit migration service setup tasks
                dms_future = executor.submit(self.setup_database_migration_service)
                datasync_future = executor.submit(self.setup_datasync_service)
                mgn_future = executor.submit(self.setup_application_migration_service)
                
                # Wait for all services to complete
                dms_config = dms_future.result()
                datasync_config = datasync_future.result()
                mgn_config = mgn_future.result()
            
            # Setup monitoring and alerting
            if not self.setup_monitoring_and_alerting():
                logger.warning("Monitoring setup failed, continuing...")
            
            # Create migration dashboard
            if not self.create_migration_dashboard():
                logger.warning("Dashboard creation failed, continuing...")
            
            # Generate deployment report
            report = self.generate_migration_report(dms_config, datasync_config, mgn_config)
            
            logger.info("Migration infrastructure deployment completed successfully")
            
            # Output deployment summary
            print("\n" + "=" * 60)
            print("MIGRATION INFRASTRUCTURE DEPLOYMENT SUMMARY")
            print("=" * 60)
            print(f"Project: {report['project_name']}")
            print(f"Environment: {report['environment']}")
            print(f"Region: {report['aws_region']}")
            print(f"Deployment Time: {report['deployment_time']}")
            print("\nMigration Services:")
            for service, config in report['migration_services'].items():
                status = "✅ Enabled" if config['enabled'] else "❌ Disabled"
                print(f"  {service.replace('_', ' ').title()}: {status}")
            
            print(f"\nMigration Bucket: {report['infrastructure']['migration_bucket']}")
            print(f"CloudWatch Dashboard: {report['monitoring']['dashboard']}")
            
            return True
            
        except Exception as e:
            logger.error(f"Deployment failed: {e}")
            return False

def main():
    """Main deployment function"""
    
    # Load configuration from environment variables
    config = MigrationConfig(
        project_name=os.getenv('PROJECT_NAME', 'onpremise-cloud-migration'),
        environment=os.getenv('ENVIRONMENT', 'prod'),
        aws_region=os.getenv('AWS_REGION', 'us-east-1'),
        vpc_id=os.getenv('VPC_ID'),
        subnet_ids=os.getenv('SUBNET_IDS', '').split(','),
        migration_bucket=os.getenv('MIGRATION_BUCKET'),
        enable_database_migration=os.getenv('ENABLE_DATABASE_MIGRATION', 'true').lower() == 'true',
        enable_file_migration=os.getenv('ENABLE_FILE_MIGRATION', 'true').lower() == 'true',
        enable_server_migration=os.getenv('ENABLE_SERVER_MIGRATION', 'true').lower() == 'true',
        notification_email=os.getenv('NOTIFICATION_EMAIL', '')
    )
    
    # Validate required environment variables
    if not config.vpc_id:
        logger.error("VPC_ID environment variable is required")
        sys.exit(1)
    
    if not config.subnet_ids or config.subnet_ids == ['']:
        logger.error("SUBNET_IDS environment variable is required (comma-separated list)")
        sys.exit(1)
    
    if not config.migration_bucket:
        logger.error("MIGRATION_BUCKET environment variable is required")
        sys.exit(1)
    
    # Initialize deployment
    deployment = CloudMigrationDeployment(config)
    
    # Execute deployment
    if deployment.deploy():
        logger.info("Migration infrastructure deployment completed successfully")
        sys.exit(0)
    else:
        logger.error("Migration infrastructure deployment failed")
        sys.exit(1)

if __name__ == '__main__':
    main()