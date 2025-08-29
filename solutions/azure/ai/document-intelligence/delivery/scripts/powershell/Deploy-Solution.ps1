# Azure AI Document Intelligence - PowerShell Deployment Script

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName,
    
    [Parameter(Mandatory=$true)]
    [string]$Location,
    
    [Parameter(Mandatory=$true)]
    [string]$CognitiveServicesName
)

Write-Host "Deploying Azure AI Document Intelligence..." -ForegroundColor Green

# Create Cognitive Services account
New-AzCognitiveServicesAccount `
    -ResourceGroupName $ResourceGroupName `
    -Name $CognitiveServicesName `
    -Type "FormRecognizer" `
    -SkuName "S0" `
    -Location $Location

Write-Host "Azure AI Document Intelligence deployment completed!" -ForegroundColor Green