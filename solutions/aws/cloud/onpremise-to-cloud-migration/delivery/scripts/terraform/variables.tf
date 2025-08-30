# AWS On-Premise to Cloud Migration - Variables

variable "aws_region" {
  description = "AWS region for migration resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "onpremise-cloud-migration"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "vpc_id" {
  description = "VPC ID for migration resources"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_ids" {
  description = "Subnet IDs for migration resources"
  type        = list(string)
}

variable "enable_database_migration" {
  description = "Enable AWS DMS for database migration"
  type        = bool
  default     = true
}

variable "enable_file_migration" {
  description = "Enable AWS DataSync for file migration"
  type        = bool
  default     = true
}

variable "enable_server_migration" {
  description = "Enable AWS SMS for server migration"
  type        = bool
  default     = true
}

variable "dms_instance_class" {
  description = "DMS replication instance class"
  type        = string
  default     = "dms.t3.micro"
}

variable "dms_allocated_storage" {
  description = "DMS allocated storage in GB"
  type        = number
  default     = 100
}

variable "dms_engine_version" {
  description = "DMS engine version"
  type        = string
  default     = "3.4.7"
}

variable "dms_multi_az" {
  description = "Enable Multi-AZ for DMS"
  type        = bool
  default     = false
}

variable "migration_data_bucket_name" {
  description = "S3 bucket name for migrated data"
  type        = string
}

variable "log_retention_days" {
  description = "CloudWatch log retention period in days"
  type        = number
  default     = 30
}

variable "on_premise_ip_ranges" {
  description = "IP ranges for on-premise networks"
  type        = list(string)
  default     = ["192.168.0.0/16", "10.0.0.0/8"]
}

variable "source_database_engine" {
  description = "Source database engine (oracle, sqlserver, mysql, postgresql)"
  type        = string
  default     = "mysql"
}

variable "target_database_engine" {
  description = "Target database engine (aurora-mysql, aurora-postgresql, rds-mysql, rds-postgresql)"
  type        = string
  default     = "aurora-mysql"
}

variable "migration_type" {
  description = "Migration type (full-load, cdc, full-load-and-cdc)"
  type        = string
  default     = "full-load-and-cdc"
}

variable "replication_instance_multi_az" {
  description = "Enable Multi-AZ for replication instance"
  type        = bool
  default     = true
}

variable "enable_cloudtrail" {
  description = "Enable CloudTrail for migration auditing"
  type        = bool
  default     = true
}

variable "enable_config" {
  description = "Enable AWS Config for compliance monitoring"
  type        = bool
  default     = true
}

variable "notification_email" {
  description = "Email address for migration notifications"
  type        = string
  default     = ""
}

variable "default_tags" {
  description = "Default tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "onpremise-cloud-migration"
    Environment = "prod"
    Owner       = "platform-team"
    ManagedBy   = "terraform"
  }
}