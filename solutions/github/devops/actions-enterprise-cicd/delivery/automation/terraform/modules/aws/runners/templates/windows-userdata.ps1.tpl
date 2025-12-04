<powershell>
#------------------------------------------------------------------------------
# GitHub Actions Self-Hosted Runner Setup Script - Windows
#------------------------------------------------------------------------------
# This script:
# 1. Installs required dependencies
# 2. Retrieves GitHub token from Secrets Manager
# 3. Downloads and configures the GitHub Actions runner
# 4. Registers as an organization runner
#------------------------------------------------------------------------------

# Variables from Terraform
$GitHubOrg = "${github_organization}"
$RunnerNamePrefix = "${runner_name_prefix}"
$RunnerLabels = "${runner_labels}"
$SecretArn = "${secret_arn}"
$AwsRegion = "${aws_region}"

# Error handling
$ErrorActionPreference = "Stop"

# Generate unique runner name
$InstanceId = (Invoke-RestMethod -Uri http://169.254.169.254/latest/meta-data/instance-id)
$RunnerName = "$RunnerNamePrefix-$InstanceId"

# Install Chocolatey
Write-Host "Installing Chocolatey..."
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install dependencies
Write-Host "Installing dependencies..."
choco install -y git docker-desktop awscli jq

# Create runner directory
$RunnerDir = "C:\actions-runner"
New-Item -ItemType Directory -Force -Path $RunnerDir
Set-Location $RunnerDir

# Get GitHub token from Secrets Manager
Write-Host "Retrieving GitHub token from Secrets Manager..."
$SecretValue = aws secretsmanager get-secret-value `
    --secret-id $SecretArn `
    --region $AwsRegion `
    --query SecretString `
    --output text
$GitHubToken = $SecretValue

# Get runner registration token
Write-Host "Getting runner registration token..."
$Headers = @{
    "Authorization" = "token $GitHubToken"
    "Accept" = "application/vnd.github.v3+json"
}
$RegTokenResponse = Invoke-RestMethod `
    -Uri "https://api.github.com/orgs/$GitHubOrg/actions/runners/registration-token" `
    -Method Post `
    -Headers $Headers
$RegToken = $RegTokenResponse.token

# Download latest runner
Write-Host "Downloading GitHub Actions runner..."
$RunnerRelease = Invoke-RestMethod -Uri "https://api.github.com/repos/actions/runner/releases/latest"
$RunnerVersion = $RunnerRelease.tag_name -replace "v", ""
$RunnerUrl = "https://github.com/actions/runner/releases/download/v$RunnerVersion/actions-runner-win-x64-$RunnerVersion.zip"
Invoke-WebRequest -Uri $RunnerUrl -OutFile "actions-runner-win-x64-$RunnerVersion.zip"

# Extract runner
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory("$RunnerDir\actions-runner-win-x64-$RunnerVersion.zip", $RunnerDir)
Remove-Item "actions-runner-win-x64-$RunnerVersion.zip"

# Configure runner
Write-Host "Configuring runner..."
.\config.cmd `
    --url "https://github.com/$GitHubOrg" `
    --token $RegToken `
    --name $RunnerName `
    --labels $RunnerLabels `
    --unattended `
    --replace `
    --runasservice

Write-Host "GitHub Actions runner setup complete!"
</powershell>
