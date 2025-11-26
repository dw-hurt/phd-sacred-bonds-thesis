#!/usr/bin/env pwsh
#Requires -Version 7.0

<#
.SYNOPSIS
    Update All Project Management Dashboards
    
.DESCRIPTION
    Runs all dashboard update scripts in sequence:
    - Chapter progress
    - Overall dissertation progress  
    - Source material status
    - To-do list
    
.PARAMETER Commit
    Automatically commit changes to Git
    
.PARAMETER Verbose
    Show detailed output
    
.EXAMPLE
    .\Update_All_Dashboards.ps1
    
.EXAMPLE
    .\Update_All_Dashboards.ps1 -Commit
#>

param(
    [switch]$Commit,
    [switch]$Verbose
)

$ErrorActionPreference = "Stop"

function Write-Status {
    param([string]$Message, [string]$Color = "Green")
    Write-Host "  ✓ $Message" -ForegroundColor $Color
}

function Write-Header {
    param([string]$Message)
    Write-Host "`n=== $Message ===" -ForegroundColor Cyan
}

Write-Header "UPDATING ALL DASHBOARDS"
Write-Host ""

$scriptDir = $PSScriptRoot
if ([string]::IsNullOrEmpty($scriptDir)) {
    $scriptDir = Get-Location
}

# 1. Update chapter progress
Write-Host "Updating chapter progress..." -ForegroundColor Yellow
try {
    & "$scriptDir\Update_Chapter_Progress.ps1"
    Write-Status "Chapter progress updated"
} catch {
    Write-Host "  ⚠ Chapter progress update failed: $_" -ForegroundColor Yellow
}

# 2. Update to-do list
Write-Host "`nUpdating to-do list..." -ForegroundColor Yellow
try {
    & "$scriptDir\Update_ToDo_List.ps1"
    Write-Status "To-do list updated"
} catch {
    Write-Host "  ⚠ To-do list update failed: $_" -ForegroundColor Yellow
}

# 3. Generate summary statistics
Write-Host "`nGenerating summary statistics..." -ForegroundColor Yellow

$stats = @{}

# Calculate chapter words
if (Test-Path "chapters") {
    $chapterWords = 0
    Get-ChildItem -Path chapters -Recurse -Filter *.md -ErrorAction SilentlyContinue | ForEach-Object {
        try {
            $words = (Get-Content $_.FullName -Raw -ErrorAction SilentlyContinue | Measure-Object -Word).Words
            $chapterWords += $words
        } catch {}
    }
    $stats["ChapterWords"] = $chapterWords
}

# Calculate research materials
if (Test-Path "sources") {
    $sourceWords = 0
    Get-ChildItem -Path sources -Recurse -Filter *.md -ErrorAction SilentlyContinue | ForEach-Object {
        try {
            $words = (Get-Content $_.FullName -Raw -ErrorAction SilentlyContinue | Measure-Object -Word).Words
            $sourceWords += $words
        } catch {}
    }
    $stats["SourceWords"] = $sourceWords
}

# Count files
$stats["Sources"] = (Get-ChildItem -Path sources\summaries -Filter *.md -ErrorAction SilentlyContinue).Count
$stats["Analyses"] = (Get-ChildItem -Path sources\comparative_analyses -Filter *.md -ErrorAction SilentlyContinue).Count

Write-Status "Summary statistics generated"

Write-Header "ALL DASHBOARDS UPDATED"
Write-Host ""
Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "  • Chapter Words: $($stats.ChapterWords)" -ForegroundColor Gray
Write-Host "  • Research Words: $($stats.SourceWords)" -ForegroundColor Gray
Write-Host "  • Sources Processed: $($stats.Sources)" -ForegroundColor Gray
Write-Host "  • Comparative Analyses: $($stats.Analyses)" -ForegroundColor Gray

if ($Commit) {
    Write-Host "`nCommitting changes..." -ForegroundColor Yellow
    try {
        git add project_management/* 2>&1 | Out-Null
        git commit -m "Update project management dashboards - $(Get-Date -Format 'yyyy-MM-dd')" 2>&1 | Out-Null
        Write-Status "Changes committed to Git"
    } catch {
        Write-Host "  ⚠ Git commit failed: $_" -ForegroundColor Yellow
    }
}

Write-Host ""
