@echo off
REM ==============================================================================
REM Terraform S3 Backend Setup Script (Windows)
REM ==============================================================================
REM Creates AWS resources required for Terraform remote state storage:
REM - S3 bucket with versioning, encryption, and public access blocking
REM - DynamoDB table for state locking
REM
REM This script is idempotent - safe to run multiple times.
REM
REM Usage:
REM   state-backend.bat [environment]
REM
REM Arguments:
REM   environment - Required: prod, test, or dr
REM
REM Prerequisites:
REM   - AWS CLI configured with appropriate credentials
REM
REM Naming Convention:
REM   S3 Bucket:      {org_prefix}-{solution_abbr}-{environment}-terraform-state
REM   DynamoDB Table: {org_prefix}-{solution_abbr}-{environment}-terraform-locks
REM ==============================================================================

setlocal EnableDelayedExpansion

REM Get script directory
set "SCRIPT_DIR=%~dp0"
set "ENVIRONMENTS_DIR=%SCRIPT_DIR%..\environments"

REM Check for environment argument
if "%~1"=="" (
    echo [ERROR] Environment required. Usage: %~nx0 [prod^|test^|dr]
    exit /b 1
)

set "ENVIRONMENT=%~1"

REM Validate environment
if /i not "%ENVIRONMENT%"=="prod" if /i not "%ENVIRONMENT%"=="test" if /i not "%ENVIRONMENT%"=="dr" (
    echo [ERROR] Invalid environment: %ENVIRONMENT%. Must be: prod, test, or dr
    exit /b 1
)

set "ENV_DIR=%ENVIRONMENTS_DIR%\%ENVIRONMENT%"
set "CONFIG_DIR=%ENV_DIR%\config"
set "TFVARS_FILE=%CONFIG_DIR%\project.tfvars"

REM Check for legacy main.tfvars
if not exist "%TFVARS_FILE%" (
    if exist "%ENV_DIR%\main.tfvars" (
        set "TFVARS_FILE=%ENV_DIR%\main.tfvars"
        echo [WARN] Using legacy main.tfvars
    )
)

echo [INFO] Environment: %ENVIRONMENT%
echo [INFO] Config file: %TFVARS_FILE%

REM Check if config file exists
if not exist "%TFVARS_FILE%" (
    echo [ERROR] Configuration file not found: %TFVARS_FILE%
    echo [ERROR] Please create config\project.tfvars with required values.
    exit /b 1
)

REM Parse tfvars file
for /f "tokens=1,* delims==" %%a in ('findstr /r "^solution_abbr" "%TFVARS_FILE%"') do (
    set "SOLUTION_ABBR=%%b"
)
for /f "tokens=1,* delims==" %%a in ('findstr /r "^org_prefix" "%TFVARS_FILE%"') do (
    set "ORG_PREFIX=%%b"
)
for /f "tokens=1,* delims==" %%a in ('findstr /r "^aws_region" "%TFVARS_FILE%"') do (
    set "AWS_REGION=%%b"
)
for /f "tokens=1,* delims==" %%a in ('findstr /r "^aws_profile" "%TFVARS_FILE%"') do (
    set "AWS_PROFILE_VAR=%%b"
)

REM Clean up parsed values (remove quotes and spaces)
set "SOLUTION_ABBR=!SOLUTION_ABBR: =!"
set "SOLUTION_ABBR=!SOLUTION_ABBR:"=!"
set "ORG_PREFIX=!ORG_PREFIX: =!"
set "ORG_PREFIX=!ORG_PREFIX:"=!"
set "AWS_REGION=!AWS_REGION: =!"
set "AWS_REGION=!AWS_REGION:"=!"
set "AWS_PROFILE_VAR=!AWS_PROFILE_VAR: =!"
set "AWS_PROFILE_VAR=!AWS_PROFILE_VAR:"=!"

REM Validate required values
if "!SOLUTION_ABBR!"=="" (
    echo [ERROR] solution_abbr not found in %TFVARS_FILE%
    exit /b 1
)
if "!ORG_PREFIX!"=="" (
    echo [ERROR] org_prefix not found in %TFVARS_FILE%
    echo [ERROR] Please set org_prefix for globally unique S3 bucket names.
    exit /b 1
)
if "!AWS_REGION!"=="" (
    echo [ERROR] aws_region not found in %TFVARS_FILE%
    exit /b 1
)

REM Set AWS profile if specified
if not "!AWS_PROFILE_VAR!"=="" (
    set "AWS_PROFILE=!AWS_PROFILE_VAR!"
    echo [INFO] Using AWS profile: !AWS_PROFILE!
)

REM Generate resource names
set "S3_BUCKET=!ORG_PREFIX!-!SOLUTION_ABBR!-%ENVIRONMENT%-terraform-state"
set "DYNAMODB_TABLE=!ORG_PREFIX!-!SOLUTION_ABBR!-%ENVIRONMENT%-terraform-locks"

echo [INFO] S3 Bucket: !S3_BUCKET!
echo [INFO] DynamoDB Table: !DYNAMODB_TABLE!
echo [INFO] AWS Region: !AWS_REGION!

REM Verify AWS credentials
echo [INFO] Verifying AWS credentials...
aws sts get-caller-identity >nul 2>&1
if errorlevel 1 (
    echo [ERROR] AWS credentials not configured or invalid
    echo [ERROR] Please configure AWS CLI: aws configure
    exit /b 1
)

for /f "tokens=*" %%a in ('aws sts get-caller-identity --query Account --output text') do set "ACCOUNT_ID=%%a"
echo [SUCCESS] AWS Account: !ACCOUNT_ID!

REM Create S3 bucket
echo [INFO] Creating S3 bucket: !S3_BUCKET!...

aws s3api head-bucket --bucket "!S3_BUCKET!" >nul 2>&1
if not errorlevel 1 (
    echo [WARN] S3 bucket already exists: !S3_BUCKET!
) else (
    if "!AWS_REGION!"=="us-east-1" (
        aws s3api create-bucket --bucket "!S3_BUCKET!" --region "!AWS_REGION!"
    ) else (
        aws s3api create-bucket --bucket "!S3_BUCKET!" --region "!AWS_REGION!" --create-bucket-configuration LocationConstraint=!AWS_REGION!
    )
    echo [SUCCESS] S3 bucket created: !S3_BUCKET!
)

REM Enable versioning
echo [INFO] Enabling versioning on S3 bucket...
aws s3api put-bucket-versioning --bucket "!S3_BUCKET!" --versioning-configuration Status=Enabled
echo [SUCCESS] Versioning enabled

REM Enable encryption
echo [INFO] Enabling server-side encryption...
aws s3api put-bucket-encryption --bucket "!S3_BUCKET!" --server-side-encryption-configuration "{\"Rules\":[{\"ApplyServerSideEncryptionByDefault\":{\"SSEAlgorithm\":\"AES256\"},\"BucketKeyEnabled\":true}]}"
echo [SUCCESS] Encryption enabled (AES-256)

REM Block public access
echo [INFO] Blocking public access...
aws s3api put-public-access-block --bucket "!S3_BUCKET!" --public-access-block-configuration "{\"BlockPublicAcls\":true,\"IgnorePublicAcls\":true,\"BlockPublicPolicy\":true,\"RestrictPublicBuckets\":true}"
echo [SUCCESS] Public access blocked

REM Create DynamoDB table
echo [INFO] Creating DynamoDB table: !DYNAMODB_TABLE!...

aws dynamodb describe-table --table-name "!DYNAMODB_TABLE!" --region "!AWS_REGION!" >nul 2>&1
if not errorlevel 1 (
    echo [WARN] DynamoDB table already exists: !DYNAMODB_TABLE!
) else (
    aws dynamodb create-table --table-name "!DYNAMODB_TABLE!" --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --billing-mode PAY_PER_REQUEST --region "!AWS_REGION!"
    echo [INFO] Waiting for DynamoDB table to become active...
    aws dynamodb wait table-exists --table-name "!DYNAMODB_TABLE!" --region "!AWS_REGION!"
    echo [SUCCESS] DynamoDB table created: !DYNAMODB_TABLE!
)

REM Output backend configuration
echo.
echo ==============================================================================
echo [SUCCESS] Setup Complete!
echo ==============================================================================
echo.
echo Add to %ENV_DIR%\backend.tfvars:
echo.
echo bucket         = "!S3_BUCKET!"
echo key            = "terraform.tfstate"
echo region         = "!AWS_REGION!"
echo dynamodb_table = "!DYNAMODB_TABLE!"
echo encrypt        = true
echo.
echo Then initialize with: terraform init -backend-config=backend.tfvars
echo ==============================================================================

REM Create backend.tfvars file
set "BACKEND_FILE=%ENV_DIR%\backend.tfvars"
echo [INFO] Creating backend configuration file: !BACKEND_FILE!

(
echo #------------------------------------------------------------------------------
echo # Terraform Backend Configuration
echo #------------------------------------------------------------------------------
echo # Generated by state-backend.bat
echo # Use with: terraform init -backend-config=backend.tfvars
echo #------------------------------------------------------------------------------
echo.
echo bucket         = "!S3_BUCKET!"
echo key            = "terraform.tfstate"
echo region         = "!AWS_REGION!"
echo dynamodb_table = "!DYNAMODB_TABLE!"
echo encrypt        = true
) > "!BACKEND_FILE!"

echo [SUCCESS] Backend configuration saved to: !BACKEND_FILE!

endlocal
