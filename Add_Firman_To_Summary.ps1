#Requires -Version 7.0

<#
.SYNOPSIS
    Adds Firman (2011) materials section to SUMMARY.md

.DESCRIPTION
    This script automatically inserts a well-formatted Firman materials section
    into your SUMMARY.md file, placing it in the appropriate location within
    the Research Materials section.

.PARAMETER SummaryPath
    Path to SUMMARY.md file
    Default: .\SUMMARY.md

.PARAMETER BackupFirst
    Create backup before modifying (recommended)
    Default: True

.EXAMPLE
    .\Add_Firman_To_Summary.ps1
    Adds Firman section with automatic backup

.EXAMPLE
    .\Add_Firman_To_Summary.ps1 -BackupFirst:$false
    Adds section without backup (not recommended)

#>

param(
    [string]$SummaryPath = ".\SUMMARY.md",
    [bool]$BackupFirst = $true
)

$ErrorActionPreference = "Stop"

# ============================================================================
# FIRMAN SECTION CONTENT
# ============================================================================

$firmanSection = @"

### Firman & Simmons (2011) - Postcopulatory Sexual Selection ⭐

* [📄 Source Summary](sources/summaries/Firman_2011_Source_Summary.md)
* [💬 Quotes Database (35 quotes)](sources/quotes/Firman_2011_Quotes_Database.md)
* [🔗 Chapter Integration Guide](sources/integration_guides/Firman_2011_Chapter_Integration_Guide.md)
* [📊 Firman-Larsen Comparative Analysis](sources/comparative_analyses/Firman_Larsen_Comparative_Analysis.md)
* [📚 Bibliography (BibTeX)](sources/bibliography/Firman_2011_Bibliography.bib)
"@

# ============================================================================
# FUNCTIONS
# ============================================================================

function Test-SummaryExists {
    if (-not (Test-Path $SummaryPath)) {
        Write-Host "❌ ERROR: SUMMARY.md not found at: $SummaryPath" -ForegroundColor Red
        Write-Host "   Current directory: $(Get-Location)" -ForegroundColor Yellow
        return $false
    }
    return $true
}

function Backup-Summary {
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $backupPath = "$SummaryPath.backup_$timestamp"
    
    try {
        Copy-Item -Path $SummaryPath -Destination $backupPath -Force
        Write-Host "✅ Backup created: $backupPath" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "⚠️ Warning: Could not create backup: $_" -ForegroundColor Yellow
        return $false
    }
}

function Test-FirmanAlreadyExists {
    param([string[]]$Content)
    
    # Check if Firman is already mentioned in SUMMARY.md
    $firmanMentions = $Content | Select-String -Pattern "Firman" -SimpleMatch
    
    if ($firmanMentions) {
        Write-Host "⚠️ Firman materials already referenced in SUMMARY.md:" -ForegroundColor Yellow
        foreach ($mention in $firmanMentions) {
            Write-Host "   Line $($mention.LineNumber): $($mention.Line.Trim())" -ForegroundColor Cyan
        }
        
        $response = Read-Host "   Continue and add new section anyway? (y/N)"
        return ($response -notmatch '^[Yy]')
    }
    
    return $false
}

function Find-InsertionPoint {
    param([string[]]$Content)
    
    # Strategy: Find the best insertion point in Research Materials section
    # Priority locations (in order):
    # 1. After "Limar (2011)" line
    # 2. After any source summary line
    # 3. After "## Research Materials" header
    # 4. Before "### Quotes Library" section
    # 5. At end of file (fallback)
    
    for ($i = 0; $i -lt $Content.Count; $i++) {
        $line = $Content[$i]
        
        # Priority 1: After Limar (best logical position - alphabetically before Firman)
        if ($line -match 'limar.*2011.*summary\.md') {
            Write-Host "📍 Insertion point: After Limar (2011) source (alphabetical order)" -ForegroundColor Cyan
            return $i + 1
        }
    }
    
    # Priority 2: After last source summary in by_source section
    $lastSourceIndex = -1
    for ($i = 0; $i -lt $Content.Count; $i++) {
        if ($Content[$i] -match 'by_source/.*summary\.md') {
            $lastSourceIndex = $i
        }
    }
    
    if ($lastSourceIndex -gt 0) {
        Write-Host "📍 Insertion point: After last source summary" -ForegroundColor Cyan
        return $lastSourceIndex + 1
    }
    
    # Priority 3: After "## Research Materials" header
    for ($i = 0; $i -lt $Content.Count; $i++) {
        if ($Content[$i] -match '^##\s+Research Materials') {
            # Find next empty line or next section
            for ($j = $i + 1; $j -lt $Content.Count; $j++) {
                if ($Content[$j].Trim() -eq "" -or $Content[$j] -match '^###') {
                    Write-Host "📍 Insertion point: Under Research Materials header" -ForegroundColor Cyan
                    return $j
                }
            }
        }
    }
    
    # Priority 4: Before "### Quotes Library" or similar section
    for ($i = 0; $i -lt $Content.Count; $i++) {
        if ($Content[$i] -match '^###\s+(Quotes|Cross-References|Integration)') {
            Write-Host "📍 Insertion point: Before '$($Content[$i].Trim())' section" -ForegroundColor Cyan
            return $i
        }
    }
    
    # Fallback: End of file
    Write-Host "📍 Insertion point: End of file (fallback)" -ForegroundColor Yellow
    return $Content.Count
}

function Add-FirmanSection {
    param([string[]]$Content, [int]$InsertIndex)
    
    # Split content into before and after
    $before = $Content[0..($InsertIndex - 1)]
    $after = $Content[$InsertIndex..($Content.Count - 1)]
    
    # Combine with Firman section
    $newContent = @()
    $newContent += $before
    
    # Add blank line before Firman section if needed
    if ($before[-1].Trim() -ne "") {
        $newContent += ""
    }
    
    # Add Firman section (split by newlines)
    $newContent += $firmanSection.Split("`n")
    
    # Add blank line after Firman section if needed
    if ($after.Count -gt 0 -and $after[0].Trim() -ne "") {
        $newContent += ""
    }
    
    $newContent += $after
    
    return $newContent
}

function Show-Preview {
    param([string[]]$Content, [int]$InsertIndex)
    
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "PREVIEW: How it will look in SUMMARY.md" -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host ""
    
    # Show context: 3 lines before, Firman section, 3 lines after
    $startLine = [Math]::Max(0, $InsertIndex - 3)
    $endLine = [Math]::Min($Content.Count - 1, $InsertIndex + 3)
    
    # Lines before
    for ($i = $startLine; $i -lt $InsertIndex; $i++) {
        Write-Host "  $($Content[$i])" -ForegroundColor Gray
    }
    
    # Firman section (highlighted)
    Write-Host ""
    Write-Host "  ▼▼▼ NEW FIRMAN SECTION ▼▼▼" -ForegroundColor Green
    foreach ($line in $firmanSection.Split("`n")) {
        Write-Host "  $line" -ForegroundColor Green
    }
    Write-Host "  ▲▲▲ END NEW SECTION ▲▲▲" -ForegroundColor Green
    Write-Host ""
    
    # Lines after
    for ($i = $InsertIndex; $i -le $endLine; $i++) {
        Write-Host "  $($Content[$i])" -ForegroundColor Gray
    }
    
    Write-Host ""
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

function Main {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Add Firman Materials to SUMMARY.md" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    
    # Step 1: Check if SUMMARY.md exists
    Write-Host "[1/6] Checking for SUMMARY.md..." -ForegroundColor Yellow
    if (-not (Test-SummaryExists)) {
        return
    }
    Write-Host "✅ Found: $SummaryPath" -ForegroundColor Green
    Write-Host ""
    
    # Step 2: Read current content
    Write-Host "[2/6] Reading current content..." -ForegroundColor Yellow
    $content = Get-Content -Path $SummaryPath
    Write-Host "✅ Read $($content.Count) lines" -ForegroundColor Green
    Write-Host ""
    
    # Step 3: Check if Firman already exists
    Write-Host "[3/6] Checking for existing Firman references..." -ForegroundColor Yellow
    if (Test-FirmanAlreadyExists -Content $content) {
        Write-Host "❌ Aborted by user" -ForegroundColor Red
        return
    }
    Write-Host "✅ No existing Firman section found" -ForegroundColor Green
    Write-Host ""
    
    # Step 4: Create backup
    if ($BackupFirst) {
        Write-Host "[4/6] Creating backup..." -ForegroundColor Yellow
        Backup-Summary | Out-Null
        Write-Host ""
    }
    else {
        Write-Host "[4/6] Skipping backup (as requested)" -ForegroundColor Yellow
        Write-Host ""
    }
    
    # Step 5: Find insertion point
    Write-Host "[5/6] Finding optimal insertion point..." -ForegroundColor Yellow
    $insertIndex = Find-InsertionPoint -Content $content
    Write-Host ""
    
    # Show preview
    Show-Preview -Content $content -InsertIndex $insertIndex
    
    # Confirm
    $confirm = Read-Host "Proceed with adding Firman section? (Y/n)"
    if ($confirm -match '^[Nn]') {
        Write-Host "❌ Cancelled by user" -ForegroundColor Yellow
        return
    }
    
    # Step 6: Add section and save
    Write-Host ""
    Write-Host "[6/6] Adding Firman section and saving..." -ForegroundColor Yellow
    
    try {
        $newContent = Add-FirmanSection -Content $content -InsertIndex $insertIndex
        
        # Save with UTF-8 encoding (no BOM)
        $newContent | Out-File -FilePath $SummaryPath -Encoding UTF8 -Force
        
        Write-Host "✅ SUMMARY.md updated successfully!" -ForegroundColor Green
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Green
        Write-Host "SUCCESS!" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Green
        Write-Host "Added Firman materials section to SUMMARY.md" -ForegroundColor White
        Write-Host ""
        Write-Host "📄 File: $SummaryPath" -ForegroundColor Cyan
        Write-Host "📝 New line count: $($newContent.Count)" -ForegroundColor Cyan
        Write-Host "📍 Inserted at line: $insertIndex" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "NEXT STEPS:" -ForegroundColor Yellow
        Write-Host "1. Review changes: git diff SUMMARY.md" -ForegroundColor White
        Write-Host "2. Test locally: gitbook serve" -ForegroundColor White
        Write-Host "3. Commit changes: git add SUMMARY.md && git commit -m 'Add Firman materials to navigation'" -ForegroundColor White
        Write-Host "4. Push to GitHub: git push" -ForegroundColor White
        Write-Host ""
        
        # Ask if user wants to see git diff
        $showDiff = Read-Host "View git diff now? (Y/n)"
        if ($showDiff -notmatch '^[Nn]') {
            git diff SUMMARY.md
        }
    }
    catch {
        Write-Host "❌ ERROR: Failed to update SUMMARY.md: $_" -ForegroundColor Red
        Write-Host ""
        Write-Host "Your original file is safe." -ForegroundColor Yellow
        if ($BackupFirst) {
            Write-Host "Backup available at: $SummaryPath.backup_*" -ForegroundColor Yellow
        }
    }
}

# Run main function
Main
