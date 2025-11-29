#Requires -Version 5.1

<#
.SYNOPSIS
    Adds Integration Roadmap document to GitBook under 'Idea Linking & Cross-Reference' section.

.DESCRIPTION
    This script:
    1. Verifies the thesis repository location
    2. Creates/verifies the idea_linking_and_cross_reference directory
    3. Copies the Integration Roadmap document (dated 2025-11-29)
    4. Updates SUMMARY.md to include the new document in navigation
    5. Commits and pushes changes to GitHub
    6. GitBook will auto-sync within 2-5 minutes

.PARAMETER RepoPath
    Path to thesis repository. Default: C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis

.PARAMETER AutoCommit
    If specified, automatically commits and pushes to GitHub. Default: $true

.EXAMPLE
    .\Add_Integration_Roadmap_To_GitBook.ps1
    # Runs with default settings

.EXAMPLE
    .\Add_Integration_Roadmap_To_GitBook.ps1 -RepoPath "D:\PhD\thesis" -AutoCommit:$false
    # Custom path, manual commit

.NOTES
    Author: PhD Automation Assistant
    Date: November 29, 2025
    Purpose: Add Integration Roadmap to GitBook navigation
    Impact: New comprehensive guide visible in GitBook
    
    Expected Changes:
    - New directory: idea_linking_and_cross_reference/ (if not exists)
    - New file: Integration_Roadmap_2025-11-29.md
    - Updated: SUMMARY.md (new navigation entry)
    - Git: 1-2 files changed, ~34KB new content
    
    GitBook Sync: 2-5 minutes
    Verify at: https://app.gitbook.com/o/cyZpWhV7KomErB6BnmVk/s/hRoSpCiTUrfuH62swMvH/
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$RepoPath = "C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis",
    
    [Parameter(Mandatory=$false)]
    [bool]$AutoCommit = $true
)

# Color output functions
function Write-Step {
    param([string]$Message)
    Write-Host "`n=== $Message ===" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "✓ $Message" -ForegroundColor Green
}

function Write-Info {
    param([string]$Message)
    Write-Host "ℹ $Message" -ForegroundColor Yellow
}

function Write-Fail {
    param([string]$Message)
    Write-Host "✗ $Message" -ForegroundColor Red
}

# Main script
$ErrorActionPreference = "Stop"
$startTime = Get-Date

Write-Host @"

╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║     INTEGRATION ROADMAP DEPLOYMENT TO GITBOOK               ║
║                                                              ║
║     Add comprehensive integration guide to                   ║
║     'Idea Linking & Cross-Reference' section                ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝

"@ -ForegroundColor Cyan

# ============================================================
# STEP 1: Verify Repository Location
# ============================================================
Write-Step "Step 1/6: Verifying repository location"

if (-not (Test-Path $RepoPath)) {
    Write-Fail "Repository not found at: $RepoPath"
    Write-Info "Please provide correct path using -RepoPath parameter"
    exit 1
}

Set-Location $RepoPath
Write-Success "Repository found: $RepoPath"

# Verify this is a git repository
if (-not (Test-Path ".git")) {
    Write-Fail "Not a git repository: $RepoPath"
    Write-Info "Please ensure this is the correct thesis repository"
    exit 1
}

Write-Success "Git repository confirmed"

# ============================================================
# STEP 2: Create/Verify Directory Structure
# ============================================================
Write-Step "Step 2/6: Setting up directory structure"

$targetDir = "idea_linking_and_cross_reference"
$targetPath = Join-Path $RepoPath $targetDir

if (Test-Path $targetPath) {
    Write-Info "Directory already exists: $targetDir"
    $existingFiles = Get-ChildItem $targetPath -Filter "*.md"
    Write-Info "Found $($existingFiles.Count) existing files in directory"
} else {
    New-Item -Path $targetPath -ItemType Directory -Force | Out-Null
    Write-Success "Created directory: $targetDir"
}

# ============================================================
# STEP 3: Locate and Copy Integration Roadmap
# ============================================================
Write-Step "Step 3/6: Deploying Integration Roadmap document"

$sourceFile = "COMPLETE_Integration_Roadmap_2025-11-29.md"
$targetFileName = "Integration_Roadmap_2025-11-29.md"
$targetFilePath = Join-Path $targetPath $targetFileName

# Check if source file exists in current directory
if (-not (Test-Path $sourceFile)) {
    Write-Fail "Source file not found: $sourceFile"
    Write-Info "Please ensure the Integration Roadmap file is in the current directory"
    Write-Info "Expected: $sourceFile"
    exit 1
}

# Copy file
Copy-Item -Path $sourceFile -Destination $targetFilePath -Force
Write-Success "Deployed: $targetFileName"

# Verify file
$fileSize = (Get-Item $targetFilePath).Length
$fileSizeKB = [math]::Round($fileSize / 1KB, 1)
Write-Info "File size: $fileSizeKB KB"

# Count sections in the file
$content = Get-Content $targetFilePath -Raw
$sectionCount = ([regex]::Matches($content, "^## ", [System.Text.RegularExpressions.RegexOptions]::Multiline)).Count
Write-Info "Document sections: $sectionCount"

# ============================================================
# STEP 4: Update SUMMARY.md Navigation
# ============================================================
Write-Step "Step 4/6: Updating SUMMARY.md navigation"

$summaryFile = Join-Path $RepoPath "SUMMARY.md"

if (-not (Test-Path $summaryFile)) {
    Write-Fail "SUMMARY.md not found at: $summaryFile"
    Write-Info "Cannot update navigation without SUMMARY.md"
    exit 1
}

$summaryContent = Get-Content $summaryFile -Raw

# Check if section already exists
$sectionPattern = "## Idea Linking & Cross-Reference|## Idea Linking and Cross-Reference"
$hasSection = $summaryContent -match $sectionPattern

# Navigation entry to add
$navigationEntry = @"

## Idea Linking & Cross-Reference

* [Integration Roadmap (2025-11-29)](idea_linking_and_cross_reference/Integration_Roadmap_2025-11-29.md)
"@

if (-not $hasSection) {
    # Add new section
    $summaryContent += "`n$navigationEntry`n"
    Write-Success "Added new 'Idea Linking & Cross-Reference' section"
} else {
    # Section exists - check if roadmap already listed
    if ($summaryContent -match "Integration_Roadmap_2025-11-29\.md") {
        Write-Info "Integration Roadmap already listed in SUMMARY.md"
    } else {
        # Add to existing section
        $summaryContent = $summaryContent -replace "($sectionPattern)", "`$1`n`n* [Integration Roadmap (2025-11-29)](idea_linking_and_cross_reference/Integration_Roadmap_2025-11-29.md)"
        Write-Success "Added Integration Roadmap to existing section"
    }
}

# Save updated SUMMARY.md
Set-Content -Path $summaryFile -Value $summaryContent -NoNewline
Write-Success "SUMMARY.md updated"

# ============================================================
# STEP 5: Git Status Review
# ============================================================
Write-Step "Step 5/6: Reviewing changes"

$gitStatus = git status --short
Write-Host "`nFiles changed:"
Write-Host $gitStatus

$changedFiles = ($gitStatus -split "`n").Count
Write-Info "Total files changed: $changedFiles"

# ============================================================
# STEP 6: Commit and Push (if AutoCommit enabled)
# ============================================================
Write-Step "Step 6/6: Committing to GitHub"

if ($AutoCommit) {
    try {
        # Add all changes
        git add .
        Write-Success "Files staged for commit"
        
        # Commit with descriptive message
        $commitMessage = "Add Integration Roadmap (2025-11-29) to Idea Linking & Cross-Reference section"
        git commit -m $commitMessage
        Write-Success "Changes committed"
        
        # Push to GitHub
        git push origin main
        Write-Success "Changes pushed to GitHub"
        
        Write-Host "`n" -NoNewline
        Write-Host "GitBook will auto-sync within 2-5 minutes" -ForegroundColor Yellow
        Write-Host "Verify at: " -NoNewline
        Write-Host "https://app.gitbook.com/o/cyZpWhV7KomErB6BnmVk/s/hRoSpCiTUrfuH62swMvH/" -ForegroundColor Cyan
        
    } catch {
        Write-Fail "Git operation failed: $_"
        Write-Info "Please commit manually:"
        Write-Host "  git add ."
        Write-Host "  git commit -m 'Add Integration Roadmap to GitBook'"
        Write-Host "  git push origin main"
        exit 1
    }
} else {
    Write-Info "AutoCommit disabled - please commit manually:"
    Write-Host "  git add ."
    Write-Host "  git commit -m 'Add Integration Roadmap (2025-11-29) to GitBook'"
    Write-Host "  git push origin main"
}

# ============================================================
# COMPLETION SUMMARY
# ============================================================
$endTime = Get-Date
$duration = ($endTime - $startTime).TotalSeconds

Write-Host @"

╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║              ✓ DEPLOYMENT COMPLETE                          ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝

"@ -ForegroundColor Green

Write-Host "Summary of Changes:" -ForegroundColor Cyan
Write-Host "  • Directory: $targetDir" -ForegroundColor White
Write-Host "  • New file: Integration_Roadmap_2025-11-29.md ($fileSizeKB KB)" -ForegroundColor White
Write-Host "  • Updated: SUMMARY.md (navigation entry added)" -ForegroundColor White
Write-Host "  • Document sections: $sectionCount" -ForegroundColor White
Write-Host "  • Execution time: $([math]::Round($duration, 1)) seconds" -ForegroundColor White

Write-Host "`nWhat This Document Provides:" -ForegroundColor Cyan
Write-Host "  ✓ Complete record of all quality improvements" -ForegroundColor Green
Write-Host "  ✓ All 4 PowerShell automation scripts documented" -ForegroundColor Green
Write-Host "  ✓ Current project status (90-92% quality)" -ForegroundColor Green
Write-Host "  ✓ Strategic roadmap for thesis completion" -ForegroundColor Green
Write-Host "  ✓ Timeline: December 2025 - February 2025" -ForegroundColor Green
Write-Host "  ✓ Priority tasks and milestones" -ForegroundColor Green
Write-Host "  ✓ Maintenance workflows and best practices" -ForegroundColor Green

Write-Host "`nNext Steps:" -ForegroundColor Cyan
Write-Host "  1. Wait 2-5 minutes for GitBook to sync" -ForegroundColor White
Write-Host "  2. Visit GitBook and navigate to 'Idea Linking & Cross-Reference'" -ForegroundColor White
Write-Host "  3. Verify Integration Roadmap is visible and formatted correctly" -ForegroundColor White
Write-Host "  4. Review the roadmap for your next priorities" -ForegroundColor White
Write-Host "  5. Begin Chapter 4 drafting (highest priority!)" -ForegroundColor White

Write-Host "`nGitBook URL:" -ForegroundColor Cyan
Write-Host "  https://app.gitbook.com/o/cyZpWhV7KomErB6BnmVk/s/hRoSpCiTUrfuH62swMvH/" -ForegroundColor Yellow

Write-Host "`nLocal Document Location:" -ForegroundColor Cyan
Write-Host "  $targetFilePath" -ForegroundColor Yellow

Write-Host "`n" -NoNewline
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   Integration Roadmap successfully deployed to GitBook! 🚀    " -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
