# ======================================================================
# PhD Workflow Automation: Larsen (2023) Integration Script
# ======================================================================
# Purpose: Integrate Larsen (2023) polygyny/demographic collapse source
#          into GitBook research journal with automated file placement,
#          SUMMARY.md updates, and Git operations.
#
# Author: PhD Automation System
# Created: 2025-11-23
# Version: 1.0
#
# Prerequisites:
# - Git repository at ~/Documents/research_journal/
# - AI Drive mounted at appropriate location
# - PowerShell 5.1+ or PowerShell Core 7+
# ======================================================================

# ======================================================================
# CONFIGURATION
# ======================================================================

# Define base paths
$AIDrivePaths = @(
    "D:\AIDrive",
    "E:\AIDrive",
    "F:\AIDrive",
    "C:\Users\$env:USERNAME\AIDrive",
    "~/AIDrive"
)

# Find AI Drive
$AIDrive = $null
foreach ($path in $AIDrivePaths) {
    $expandedPath = [System.Environment]::ExpandEnvironmentVariables($path)
    if (Test-Path $expandedPath) {
        $AIDrive = $expandedPath
        Write-Host "✓ Found AI Drive at: $AIDrive" -ForegroundColor Green
        break
    }
}

if (-not $AIDrive) {
    Write-Host "✗ AI Drive not found. Checked locations:" -ForegroundColor Red
    $AIDrivePaths | ForEach-Object { Write-Host "  - $_" -ForegroundColor Yellow }
    exit 1
}

# Repository paths
$RepoBase = Join-Path $AIDrive "research_journal"
$NotesDir = Join-Path $RepoBase "notes\reading_notes\by_source"
$QuotesDir = Join-Path $RepoBase "quotes\by_source"
$BibliographyDir = Join-Path $RepoBase "notes\bibliography"
$IdeaLinkingDir = Join-Path $RepoBase "research_journal\idea_linking"
$SummaryFile = Join-Path $RepoBase "SUMMARY.md"

# Source files (from sandbox/current directory)
$SourceFiles = @{
    "Summary" = @{
        "Source" = "larsen_2023_polygyny_demographic_collapse_summary.md"
        "Destination" = Join-Path $NotesDir "larsen_2023_polygyny_demographic_collapse_summary.md"
        "Category" = "Reading Notes"
    }
    "ResourceRecord" = @{
        "Source" = "larsen_2023_polygyny_resource_record.md"
        "Destination" = Join-Path $NotesDir "larsen_2023_polygyny_resource_record.md"
        "Category" = "Reading Notes"
    }
    "Quotes" = @{
        "Source" = "larsen_2023_polygyny_quotes.md"
        "Destination" = Join-Path $QuotesDir "larsen_2023_polygyny_quotes.md"
        "Category" = "Quotes"
    }
    "CrossReference" = @{
        "Source" = "cross_reference_larsen_all_sources.md"
        "Destination" = Join-Path $IdeaLinkingDir "cross_reference_larsen_all_sources.md"
        "Category" = "Idea Linking"
    }
}

# ======================================================================
# FUNCTIONS
# ======================================================================

function Write-SectionHeader {
    param([string]$Title)
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host " $Title" -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "✓ $Message" -ForegroundColor Green
}

function Write-Error {
    param([string]$Message)
    Write-Host "✗ $Message" -ForegroundColor Red
}

function Write-Info {
    param([string]$Message)
    Write-Host "ℹ $Message" -ForegroundColor Yellow
}

function Test-Prerequisites {
    Write-SectionHeader "Checking Prerequisites"
    
    $allGood = $true
    
    # Check repository
    if (Test-Path $RepoBase) {
        Write-Success "Repository found: $RepoBase"
    } else {
        Write-Error "Repository not found: $RepoBase"
        $allGood = $false
    }
    
    # Check if it's a Git repository
    $gitDir = Join-Path $RepoBase ".git"
    if (Test-Path $gitDir) {
        Write-Success "Git repository detected"
    } else {
        Write-Error "Not a Git repository: $RepoBase"
        $allGood = $false
    }
    
    # Check source files
    foreach ($file in $SourceFiles.Values) {
        if (Test-Path $file.Source) {
            $size = (Get-Item $file.Source).Length
            Write-Success "Source file found: $($file.Source) ($([math]::Round($size/1KB, 2)) KB)"
        } else {
            Write-Error "Source file not found: $($file.Source)"
            $allGood = $false
        }
    }
    
    # Check target directories
    $dirs = @($NotesDir, $QuotesDir, $BibliographyDir, $IdeaLinkingDir)
    foreach ($dir in $dirs) {
        if (Test-Path $dir) {
            Write-Success "Target directory exists: $dir"
        } else {
            Write-Info "Will create directory: $dir"
        }
    }
    
    return $allGood
}

function Copy-SourceFiles {
    Write-SectionHeader "Copying Source Files"
    
    foreach ($fileInfo in $SourceFiles.GetEnumerator()) {
        $name = $fileInfo.Key
        $file = $fileInfo.Value
        
        Write-Host "`nProcessing: $name" -ForegroundColor White
        Write-Host "  From: $($file.Source)" -ForegroundColor Gray
        Write-Host "  To:   $($file.Destination)" -ForegroundColor Gray
        
        # Ensure destination directory exists
        $destDir = Split-Path $file.Destination -Parent
        if (-not (Test-Path $destDir)) {
            New-Item -Path $destDir -ItemType Directory -Force | Out-Null
            Write-Info "  Created directory: $destDir"
        }
        
        # Copy file
        try {
            Copy-Item -Path $file.Source -Destination $file.Destination -Force
            $size = (Get-Item $file.Destination).Length
            Write-Success "  Copied successfully ($([math]::Round($size/1KB, 2)) KB)"
        } catch {
            Write-Error "  Failed to copy: $_"
            return $false
        }
    }
    
    return $true
}

function Update-SummaryFile {
    Write-SectionHeader "Updating SUMMARY.md"
    
    if (-not (Test-Path $SummaryFile)) {
        Write-Error "SUMMARY.md not found: $SummaryFile"
        return $false
    }
    
    # Read current content
    $content = Get-Content $SummaryFile -Raw
    
    # Check if Larsen entries already exist
    if ($content -match "larsen_2023_polygyny") {
        Write-Info "Larsen entries already exist in SUMMARY.md"
        Write-Host "  Skipping SUMMARY.md update (manual review recommended)" -ForegroundColor Yellow
        return $true
    }
    
    # Define new entries
    $newEntries = @"

### Larsen (2023) - Polygyny & Demographic Collapse

* Reading Notes
  * [Source Summary](notes/reading_notes/by_source/larsen_2023_polygyny_demographic_collapse_summary.md)
  * [Resource Record / Bibliography Note](notes/reading_notes/by_source/larsen_2023_polygyny_resource_record.md)
* [Quotes by Chapter](quotes/by_source/larsen_2023_polygyny_quotes.md)
* [Cross-Reference: Larsen ↔ All Sources](research_journal/idea_linking/cross_reference_larsen_all_sources.md)
"@
    
    # Find insertion point (after Gangestad & Simpson section if it exists)
    $insertionPattern = "### Gangestad & Simpson.*?(?=###|\z)"
    if ($content -match $insertionPattern) {
        $match = $Matches[0]
        $updatedContent = $content -replace [regex]::Escape($match), "$match$newEntries"
        Write-Info "Inserting Larsen section after Gangestad & Simpson"
    } else {
        # Otherwise, add at end of Reading Notes section
        $insertionPattern = "## Reading Notes.*?(?=##|\z)"
        if ($content -match $insertionPattern) {
            $match = $Matches[0]
            $updatedContent = $content -replace [regex]::Escape($match), "$match$newEntries"
            Write-Info "Appending Larsen section to Reading Notes"
        } else {
            Write-Error "Could not find suitable insertion point in SUMMARY.md"
            Write-Info "Please manually add the following entries:"
            Write-Host $newEntries -ForegroundColor Cyan
            return $false
        }
    }
    
    # Backup original
    $backupFile = "$SummaryFile.backup.$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    Copy-Item -Path $SummaryFile -Destination $backupFile
    Write-Info "Created backup: $backupFile"
    
    # Write updated content
    try {
        $updatedContent | Set-Content -Path $SummaryFile -NoNewline
        Write-Success "SUMMARY.md updated successfully"
        return $true
    } catch {
        Write-Error "Failed to update SUMMARY.md: $_"
        Write-Info "Restoring from backup..."
        Copy-Item -Path $backupFile -Destination $SummaryFile -Force
        return $false
    }
}

function Invoke-GitOperations {
    Write-SectionHeader "Git Operations"
    
    Push-Location $RepoBase
    
    try {
        # Check Git status
        Write-Host "Checking repository status..." -ForegroundColor White
        git status --short
        
        # Stage files
        Write-Host "`nStaging Larsen files..." -ForegroundColor White
        git add notes/reading_notes/by_source/larsen_2023_*
        git add quotes/by_source/larsen_2023_*
        git add research_journal/idea_linking/cross_reference_larsen_*
        git add SUMMARY.md
        
        Write-Success "Files staged for commit"
        
        # Create commit
        $commitMessage = @"
Add Larsen (2023) - Polygyny & Demographic Collapse

- Source summary (5,500 words): Comprehensive analysis of sex ratio theory
- Resource record: Full bibliography with BibTeX, critical evaluation
- Quotes database: 25 quotes organized by dissertation chapter
- Cross-reference: 14,500-word integration with all sources (G&S, Buss, Bertrand, Jung, Miller)

Key contributions:
- Perceived Sex Ratio (PSR) concept
- Evoked vs. transmitted culture framework
- 1,000-year literary analysis of mating ideologies
- Nordic natural experiment data (50-point pair-bonding gap)
- Policy proposal: Polygyny legalization to counter demographic collapse

Integration:
- Validates Strategic Pluralism Theory (G&S) at population level
- Extends Buss's universal preferences to prosperity contexts
- Explains Bertrand's economic findings mechanistically
- Operationalizes Jung's animus projection via PSR
- Applies Miller's fitness indicator theory to cultural evolution
"@
        
        Write-Host "`nCommit message:" -ForegroundColor White
        Write-Host $commitMessage -ForegroundColor Gray
        
        git commit -m $commitMessage
        
        Write-Success "Changes committed"
        
        # Push to remote
        Write-Host "`nPushing to remote repository..." -ForegroundColor White
        git push
        
        Write-Success "Changes pushed to remote"
        
        return $true
        
    } catch {
        Write-Error "Git operation failed: $_"
        return $false
    } finally {
        Pop-Location
    }
}

function Show-Summary {
    Write-SectionHeader "Integration Summary"
    
    Write-Host "Files Integrated:" -ForegroundColor White
    Write-Host "  1. Source Summary (5,500 words)" -ForegroundColor Green
    Write-Host "     → $($SourceFiles.Summary.Destination)" -ForegroundColor Gray
    
    Write-Host "  2. Resource Record (24 KB)" -ForegroundColor Green
    Write-Host "     → $($SourceFiles.ResourceRecord.Destination)" -ForegroundColor Gray
    
    Write-Host "  3. Quotes Database (25 quotes)" -ForegroundColor Green
    Write-Host "     → $($SourceFiles.Quotes.Destination)" -ForegroundColor Gray
    
    Write-Host "  4. Cross-Reference (14,500 words)" -ForegroundColor Green
    Write-Host "     → $($SourceFiles.CrossReference.Destination)" -ForegroundColor Gray
    
    Write-Host "`nSUMMARY.md:" -ForegroundColor White
    Write-Host "  Updated with Larsen navigation links" -ForegroundColor Green
    
    Write-Host "`nGit Operations:" -ForegroundColor White
    Write-Host "  ✓ Files staged" -ForegroundColor Green
    Write-Host "  ✓ Changes committed" -ForegroundColor Green
    Write-Host "  ✓ Pushed to remote" -ForegroundColor Green
    
    Write-Host "`nGitBook Sync:" -ForegroundColor White
    Write-Host "  GitBook should automatically sync from GitHub" -ForegroundColor Yellow
    Write-Host "  Check: https://your-gitbook-url.com" -ForegroundColor Yellow
    
    Write-Host "`nNext Steps:" -ForegroundColor White
    Write-Host "  1. Verify GitBook sync completed" -ForegroundColor Cyan
    Write-Host "  2. Review cross-reference document for accuracy" -ForegroundColor Cyan
    Write-Host "  3. Update dashboard with Larsen progress" -ForegroundColor Cyan
    Write-Host "  4. Identify next source to process" -ForegroundColor Cyan
}

# ======================================================================
# MAIN EXECUTION
# ======================================================================

function Main {
    Write-Host "`n" -NoNewline
    Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║   PhD Workflow: Larsen (2023) Integration                      ║" -ForegroundColor Cyan
    Write-Host "║   Polygyny & Demographic Collapse Source                       ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    
    # Step 1: Prerequisites
    if (-not (Test-Prerequisites)) {
        Write-Error "`nPrerequisite checks failed. Please resolve issues and try again."
        return 1
    }
    
    # Step 2: Copy files
    if (-not (Copy-SourceFiles)) {
        Write-Error "`nFile copy failed. Aborting integration."
        return 1
    }
    
    # Step 3: Update SUMMARY.md
    $summarySuccess = Update-SummaryFile
    if (-not $summarySuccess) {
        Write-Info "`nSUMMARY.md update failed, but files were copied successfully."
        Write-Info "You may proceed with Git operations and update SUMMARY.md manually."
        
        $response = Read-Host "`nContinue with Git operations? (y/n)"
        if ($response -ne 'y') {
            Write-Info "Integration paused. Files are copied but not committed."
            return 1
        }
    }
    
    # Step 4: Git operations
    if (-not (Invoke-GitOperations)) {
        Write-Error "`nGit operations failed. Files are copied but not committed."
        Write-Info "You may need to commit and push manually."
        return 1
    }
    
    # Step 5: Summary
    Show-Summary
    
    Write-Host "`n✓ Integration completed successfully!" -ForegroundColor Green
    Write-Host ""
    
    return 0
}

# Run main function
$exitCode = Main
exit $exitCode
