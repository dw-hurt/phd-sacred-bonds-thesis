#!/usr/bin/env pwsh
#Requires -Version 7.0

<#
.SYNOPSIS
    Clean Up Repository Root - Remove Temporary Files
    
.DESCRIPTION
    Removes temporary files left in repository root after deployment
#>

$ErrorActionPreference = "Stop"

function Write-Header {
    param([string]$Message)
    Write-Host "`n$('=' * 80)" -ForegroundColor Cyan
    Write-Host "  $Message" -ForegroundColor Cyan
    Write-Host "$('=' * 80)`n" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "  ✓ $Message" -ForegroundColor Green
}

function Write-Info {
    param([string]$Message)
    Write-Host "  ℹ $Message" -ForegroundColor Blue
}

function Write-Warning {
    param([string]$Message)
    Write-Host "  ⚠ $Message" -ForegroundColor Yellow
}

Write-Header "REPOSITORY CLEANUP"

Write-Info "This script will remove temporary files from repository root"
Write-Host ""

# Files to remove
$filesToRemove = @(
    # Source analysis files (already in sources/comparative_analyses/)
    "Buss_2023_Comparative_Analysis.md",
    "Larsen_2023_Comparative_Analysis.md",
    "Gangestad_Simpson_2000_Comparative_Analysis.md",
    
    # Deployment scripts (already in scripts/ or no longer needed)
    "Complete_Deployment_Final.ps1",
    "Deploy_Dashboard_System.ps1",
    "Deploy_Remaining_Comparative_Analyses.ps1",
    
    # Documentation (already in project_management/)
    "Dashboard_Update_Commands.md",
    
    # Duplicate scripts (already in scripts/)
    "Update_All_Dashboards.ps1",
    "Update_Chapter_Progress.ps1",
    "Update_ToDo_List.ps1",
    
    # Backup files (redundant - Git has history)
    "SUMMARY.md.backup_20251125_182532",
    "SUMMARY.md.backup_20251125_190557",
    "SUMMARY.md.backup_20251125_190857",
    "SUMMARY.md.backup_20251125_192129"
)

Write-Header "FILES TO REMOVE"

$existingFiles = @()
foreach ($file in $filesToRemove) {
    if (Test-Path $file) {
        $fileInfo = Get-Item $file
        $sizeKB = [math]::Round($fileInfo.Length / 1KB, 1)
        Write-Host "  • $file ($sizeKB KB)" -ForegroundColor Yellow
        $existingFiles += $file
    }
}

if ($existingFiles.Count -eq 0) {
    Write-Success "No files to remove - repository is clean!"
    exit 0
}

Write-Host ""
Write-Info "Total files to remove: $($existingFiles.Count)"
Write-Host ""

# Confirm deletion
$confirmation = Read-Host "Remove these files? (yes/no)"
if ($confirmation -ne "yes") {
    Write-Warning "Cleanup cancelled"
    exit 0
}

Write-Header "REMOVING FILES"

$removedCount = 0
foreach ($file in $existingFiles) {
    try {
        Remove-Item -Path $file -Force
        Write-Success "Removed: $file"
        $removedCount++
    } catch {
        $errorMsg = $_.Exception.Message
        Write-Warning "Failed to remove ${file}: $errorMsg"
    }
}

Write-Header "CLEANUP COMPLETE"

Write-Success "Removed $removedCount files"
Write-Host ""

# Verify repository is clean
Write-Info "Verifying repository status..."
$gitStatus = git status --porcelain 2>&1

if ([string]::IsNullOrWhiteSpace($gitStatus)) {
    Write-Success "Repository is clean - no untracked files"
} else {
    Write-Host ""
    Write-Info "Remaining untracked files:"
    git status --short
}

Write-Host ""
Write-Info "Note: All removed files were temporary copies"
Write-Info "Original files are safely stored in:"
Write-Host "  • sources/comparative_analyses/ (analysis files)" -ForegroundColor Gray
Write-Host "  • scripts/ (PowerShell scripts)" -ForegroundColor Gray
Write-Host "  • project_management/ (documentation)" -ForegroundColor Gray
Write-Host "  • Git history (backup files)" -ForegroundColor Gray

Write-Host ""
