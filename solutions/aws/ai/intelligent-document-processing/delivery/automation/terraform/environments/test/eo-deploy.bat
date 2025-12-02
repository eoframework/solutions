@echo off
setlocal enabledelayedexpansion

REM Test Environment - Terraform Deployment Script
REM Uses config\*.tfvars files for configuration

REM Colors using ANSI (Windows 10+)
set "GREEN=[32m"
set "YELLOW=[33m"
set "BLUE=[34m"
set "CYAN=[36m"
set "RED=[31m"
set "NC=[0m"

REM Script info
set "SCRIPT_DIR=%~dp0"
for %%I in ("%SCRIPT_DIR:~0,-1%") do set "ENVIRONMENT=%%~nxI"

echo %BLUE%===============================================%NC%
echo %BLUE%  EO Framework - Terraform Deployment%NC%
echo %BLUE%  Environment: %ENVIRONMENT%%NC%
echo %BLUE%===============================================%NC%
echo.

REM Check if command provided
if "%~1"=="" (
    call :show_usage
    exit /b 1
)

set "COMMAND=%~1"
shift

REM Build remaining arguments
set "EXTRA_ARGS="
:parse_args
if "%~1"=="" goto :end_parse_args
set "EXTRA_ARGS=%EXTRA_ARGS% %~1"
shift
goto :parse_args
:end_parse_args

REM Handle commands
if /i "%COMMAND%"=="init" goto :cmd_init
if /i "%COMMAND%"=="plan" goto :cmd_plan
if /i "%COMMAND%"=="apply" goto :cmd_apply
if /i "%COMMAND%"=="destroy" goto :cmd_destroy
if /i "%COMMAND%"=="validate" goto :cmd_validate
if /i "%COMMAND%"=="fmt" goto :cmd_fmt
if /i "%COMMAND%"=="output" goto :cmd_output
if /i "%COMMAND%"=="show" goto :cmd_show
if /i "%COMMAND%"=="state" goto :cmd_state
if /i "%COMMAND%"=="refresh" goto :cmd_refresh
if /i "%COMMAND%"=="version" goto :cmd_version
if /i "%COMMAND%"=="help" goto :show_usage
if /i "%COMMAND%"=="-h" goto :show_usage
if /i "%COMMAND%"=="--help" goto :show_usage

echo %RED%Unknown command: %COMMAND%%NC%
echo.
call :show_usage
exit /b 1

:cmd_init
echo %BLUE%Initializing Terraform...%NC%
terraform init %EXTRA_ARGS%
goto :success

:cmd_plan
echo %BLUE%Creating execution plan...%NC%
call :build_var_files
terraform plan %VAR_FILES% %EXTRA_ARGS%
goto :success

:cmd_apply
echo %BLUE%Applying Terraform configuration...%NC%
call :build_var_files
terraform apply %VAR_FILES% %EXTRA_ARGS%
goto :success

:cmd_destroy
echo %RED%Destroying infrastructure...%NC%
echo %YELLOW%WARNING: This will destroy all resources in %ENVIRONMENT% environment!%NC%
call :build_var_files
terraform destroy %VAR_FILES% %EXTRA_ARGS%
goto :success

:cmd_validate
echo %BLUE%Validating Terraform configuration...%NC%
terraform validate %EXTRA_ARGS%
goto :success

:cmd_fmt
echo %BLUE%Formatting Terraform files...%NC%
terraform fmt %EXTRA_ARGS%
goto :success

:cmd_output
echo %BLUE%Showing output values...%NC%
terraform output %EXTRA_ARGS%
goto :success

:cmd_show
echo %BLUE%Showing current state...%NC%
terraform show %EXTRA_ARGS%
goto :success

:cmd_state
echo %BLUE%State management...%NC%
terraform state %EXTRA_ARGS%
goto :success

:cmd_refresh
echo %BLUE%Refreshing state...%NC%
call :build_var_files
terraform refresh %VAR_FILES% %EXTRA_ARGS%
goto :success

:cmd_version
echo %BLUE%Terraform version information:%NC%
terraform version
goto :success

:build_var_files
set "VAR_FILES="
echo %YELLOW%Loading configuration files:%NC%

REM Load all tfvars files from config\ directory
if exist "config" (
    for %%f in (config\*.tfvars) do (
        if exist "%%f" (
            set "VAR_FILES=!VAR_FILES! -var-file=%%f"
            echo %GREEN%   + %%f%NC%
        )
    )
)

REM Fallback: Load main.tfvars if config\ not present
if not exist "config" (
    if exist "main.tfvars" (
        set "VAR_FILES=-var-file=main.tfvars"
        echo %GREEN%   + main.tfvars (legacy)%NC%
    )
)
echo.
goto :eof

:show_usage
echo %CYAN%Usage: %~nx0 ^<command^> [options]%NC%
echo.
echo %YELLOW%Available Commands:%NC%
echo %GREEN%  init%NC%           Initialize Terraform working directory
echo %GREEN%  plan%NC%           Create an execution plan
echo %GREEN%  apply%NC%          Apply the Terraform plan
echo %GREEN%  destroy%NC%        Destroy Terraform-managed infrastructure
echo %GREEN%  validate%NC%       Validate the Terraform configuration
echo %GREEN%  fmt%NC%            Format Terraform configuration files
echo %GREEN%  output%NC%         Show output values
echo %GREEN%  show%NC%           Show current state or saved plan
echo %GREEN%  state%NC%          Advanced state management
echo %GREEN%  refresh%NC%        Update state to match remote systems
echo %GREEN%  version%NC%        Show Terraform version
echo.
echo %YELLOW%Examples:%NC%
echo %CYAN%  %~nx0 init%NC%
echo %CYAN%  %~nx0 plan%NC%
echo %CYAN%  %~nx0 apply -auto-approve%NC%
echo %CYAN%  %~nx0 destroy%NC%
echo.
goto :eof

:success
echo.
echo %BLUE%===============================================%NC%
echo %GREEN%  Command completed successfully!%NC%
echo %BLUE%===============================================%NC%
exit /b 0
