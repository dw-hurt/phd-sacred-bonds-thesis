<#
.SYNOPSIS
    PhD Workflow Launcher - Quick access to automation scripts
.DESCRIPTION
    Launches the main PhD automation menu from any directory
#>

$scriptsPath = Join-Path $PSScriptRoot "project_management\scripts"
$masterScript = Join-Path $scriptsPath "phd-master.ps1"

if (Test-Path $masterScript) {
    Write-Host "`nLaunching PhD Automation Suite...`n" -ForegroundColor Cyan
    Set-Location $scriptsPath
    & $masterScript
} else {
    Write-Host "Error: Cannot find phd-master.ps1" -ForegroundColor Red
    Write-Host "Expected location: $masterScript" -ForegroundColor Yellow
    Write-Host "`nPlease run from repository root or navigate to:" -ForegroundColor Yellow
    Write-Host "  cd project_management\scripts" -ForegroundColor White
    Write-Host "  .\phd-master.ps1" -ForegroundColor White
}
