# ══════════════════════════════════════════════════════════════════════════════
# Organize Untracked Files - PhD Thesis Repository Cleanup
# ══════════════════════════════════════════════════════════════════════════════
# Purpose: Clean up and organize all untracked files from Thompson integration
# Usage: .\Organize_Untracked_Files.ps1 [-Preview] [-Apply] [-Archive]
# ══════════════════════════════════════════════════════════════════════════════

param(
    [switch]$Preview,
    [switch]$Apply,
    [switch]$Archive
)

# Define file categories and their destinations
$fileActions = @{
    # KEEP - These are useful automation scripts
    "THOMPSON_INTEGRATION_GUIDE.md" = @{
        Action = "Keep"
        Destination = "docs/integration_guides/"
        Reason = "Documentation for Thompson integration process"
    }
    "Thompson_2020_Complete_Integration.ps1" = @{
        Action = "Archive"
        Destination = "archive/integration_scripts/"
        Reason = "Completed integration script - keep for reference"
    }
    "Thompson_Complete_Integration.ps1" = @{
        Action = "Archive"
        Destination = "archive/integration_scripts/"
        Reason = "Duplicate integration script"
    }
    "Weekly_Dissertation_Update.ps1" = @{
        Action = "Keep"
        Destination = "scripts/"
        Reason = "Active automation script for weekly updates"
    }
    "Diagnose_Progress_Summary.ps1" = @{
        Action = "Keep"
        Destination = "scripts/"
        Reason = "Diagnostic tool for GitBook sync issues"
    }
    "Extract_And_Update_Progress_Summary.ps1" = @{
        Action = "Keep"
        Destination = "scripts/"
        Reason = "Progress summary generation tool"
    }
    "Add_Future_Research_To_GitBook.ps1" = @{
        Action = "Keep"
        Destination = "scripts/"
        Reason = "Future research integration tool"
    }
    
    # ARCHIVE - Source files already integrated into GitBook
    "Thompson_2020_Quotes.md" = @{
        Action = "Archive"
        Destination = "archive/source_materials/"
        Reason = "Source file - content now in quotes/by_source/Thompson_InPress_Quotes.md"
    }
    "Thompson_2020_Research_Summary.md" = @{
        Action = "Archive"
        Destination = "archive/source_materials/"
        Reason = "Source file - content now in notes/reading_notes/by_source/Thompson_InPress_Summary.md"
    }
    "Thompson_Bibliography.md" = @{
        Action = "Archive"
        Destination = "archive/source_materials/"
        Reason = "Source file - content now in bibliography/Thompson_InPress.md"
    }
    "Thompson_Comparative_Analysis.md" = @{
        Action = "Archive"
        Destination = "archive/source_materials/"
        Reason = "Source file - content now in comparative-analyses/Thompson_Comparative_Analysis.md"
    }
    "Future_Research_Directions.md" = @{
        Action = "Archive"
        Destination = "archive/source_materials/"
        Reason = "Source file - content now in research_materials/future_research/future_research_directions.md"
    }
    
    # ARCHIVE - Backup files
    "SUMMARY.md.backup_thompson_fix" = @{
        Action = "Archive"
        Destination = "archive/backups/"
        Reason = "Backup from SUMMARY.md fix process"
    }
    "chapters/01_introduction/chapter_01_introduction_backup_20251127_231539.md" = @{
        Action = "Archive"
        Destination = "archive/backups/"
        Reason = "Chapter 1 backup - older version"
    }
    "chapters/01_introduction/chapter_01_introduction_backup_20251127_231825.md" = @{
        Action = "Archive"
        Destination = "archive/backups/"
        Reason = "Chapter 1 backup - older version"
    }
}

function Show-Preview {
    Write-Host "`n══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  PREVIEW: Untracked Files Organization Plan" -ForegroundColor Cyan
    Write-Host "══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    
    $keepFiles = $fileActions.GetEnumerator() | Where-Object { $_.Value.Action -eq "Keep" }
    $archiveFiles = $fileActions.GetEnumerator() | Where-Object { $_.Value.Action -eq "Archive" }
    
    Write-Host "`n📁 KEEP & ORGANIZE (will be added to Git):" -ForegroundColor Green
    Write-Host "   These files will be moved to appropriate directories and committed" -ForegroundColor Gray
    foreach ($file in $keepFiles) {
        Write-Host "   ✓ $($file.Key)" -ForegroundColor White
        Write-Host "     → $($file.Value.Destination)" -ForegroundColor DarkGray
        Write-Host "     Reason: $($file.Value.Reason)" -ForegroundColor DarkGray
    }
    
    Write-Host "`n📦 ARCHIVE (will be moved to archive/):" -ForegroundColor Yellow
    Write-Host "   These files will be archived - source content already in GitBook" -ForegroundColor Gray
    foreach ($file in $archiveFiles) {
        Write-Host "   ✓ $($file.Key)" -ForegroundColor White
        Write-Host "     → $($file.Value.Destination)" -ForegroundColor DarkGray
        Write-Host "     Reason: $($file.Value.Reason)" -ForegroundColor DarkGray
    }
    
    Write-Host "`n═══════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  Summary" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  Files to Keep & Organize: $($keepFiles.Count)" -ForegroundColor Green
    Write-Host "  Files to Archive: $($archiveFiles.Count)" -ForegroundColor Yellow
    Write-Host "  Total Files: $($fileActions.Count)" -ForegroundColor White
    
    Write-Host "`n📋 Next Steps:" -ForegroundColor Cyan
    Write-Host "   1. Run with -Apply to execute this plan" -ForegroundColor White
    Write-Host "   2. Script will create directories if needed" -ForegroundColor White
    Write-Host "   3. Files will be moved to appropriate locations" -ForegroundColor White
    Write-Host "   4. Changes will be committed to Git" -ForegroundColor White
    Write-Host "   5. Push to GitHub for GitBook sync" -ForegroundColor White
    
    Write-Host "`n💡 Command: .\Organize_Untracked_Files.ps1 -Apply" -ForegroundColor Yellow
}

function Move-FilesToDestination {
    param([string]$Action)
    
    $files = $fileActions.GetEnumerator() | Where-Object { $_.Value.Action -eq $Action }
    
    foreach ($file in $files) {
        $sourcePath = $file.Key
        $destDir = $file.Value.Destination
        $destPath = Join-Path $destDir (Split-Path $sourcePath -Leaf)
        
        # Create destination directory
        if (-not (Test-Path $destDir)) {
            Write-Host "   Creating directory: $destDir" -ForegroundColor DarkGray
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        }
        
        # Check if source file exists
        if (Test-Path $sourcePath) {
            # Move file
            Write-Host "   Moving: $sourcePath → $destPath" -ForegroundColor White
            Move-Item -Path $sourcePath -Destination $destPath -Force
            
            # Add to Git if keeping
            if ($Action -eq "Keep") {
                git add $destPath
            }
        } else {
            Write-Host "   ⚠ File not found: $sourcePath" -ForegroundColor Yellow
        }
    }
}

function Apply-Organization {
    Write-Host "`n══════════════════════════════════════════════════════════════" -ForegroundColor Green
    Write-Host "  APPLYING: Organizing Untracked Files" -ForegroundColor Green
    Write-Host "══════════════════════════════════════════════════════════════" -ForegroundColor Green
    
    # Phase 1: Organize files to keep
    Write-Host "`n📁 Phase 1: Organizing active scripts and documentation..." -ForegroundColor Cyan
    Move-FilesToDestination -Action "Keep"
    
    # Phase 2: Archive source materials
    Write-Host "`n📦 Phase 2: Archiving source materials..." -ForegroundColor Cyan
    Move-FilesToDestination -Action "Archive"
    
    # Phase 3: Create .gitkeep in archive directories
    Write-Host "`n📋 Phase 3: Setting up archive structure..." -ForegroundColor Cyan
    $archiveDirs = @(
        "archive/source_materials",
        "archive/integration_scripts",
        "archive/backups"
    )
    foreach ($dir in $archiveDirs) {
        if (Test-Path $dir) {
            $gitkeep = Join-Path $dir ".gitkeep"
            if (-not (Test-Path $gitkeep)) {
                "# This directory contains archived files" | Set-Content $gitkeep
                git add $gitkeep
                Write-Host "   Created .gitkeep in: $dir" -ForegroundColor DarkGray
            }
        }
    }
    
    # Phase 4: Create README files
    Write-Host "`n📝 Phase 4: Creating documentation..." -ForegroundColor Cyan
    
    # Scripts README
    $scriptsReadme = @"
# PhD Thesis Automation Scripts

This directory contains PowerShell scripts for automating thesis management and GitBook integration.

## Active Scripts

### Weekly_Dissertation_Update.ps1
**Purpose**: Automated weekly progress summary generation and GitBook sync
**Usage**: 
``````powershell
.\Weekly_Dissertation_Update.ps1 -Preview  # Preview changes
.\Weekly_Dissertation_Update.ps1 -Apply    # Apply changes
``````
**Schedule**: Run weekly to update progress summary

### Diagnose_Progress_Summary.ps1
**Purpose**: Diagnose GitBook sync issues and validate SUMMARY.md links
**Usage**: 
``````powershell
.\Diagnose_Progress_Summary.ps1
``````
**When to use**: When content doesn't appear in GitBook

### Extract_And_Update_Progress_Summary.ps1
**Purpose**: Generate undated progress summaries from repository analysis
**Usage**: 
``````powershell
.\Extract_And_Update_Progress_Summary.ps1
``````

### Add_Future_Research_To_GitBook.ps1
**Purpose**: Integrate future research directions into GitBook
**Usage**: 
``````powershell
.\Add_Future_Research_To_GitBook.ps1
``````

## Integration Guides

See \`docs/integration_guides/THOMPSON_INTEGRATION_GUIDE.md\` for detailed integration workflows.

## Maintenance

- Keep scripts in this directory for easy access
- Archive completed integration scripts to \`archive/integration_scripts/\`
- Document new scripts in this README
"@
    
    if (-not (Test-Path "scripts/README.md")) {
        $scriptsReadme | Set-Content "scripts/README.md"
        git add "scripts/README.md"
        Write-Host "   Created scripts/README.md" -ForegroundColor DarkGray
    }
    
    # Archive README
    $archiveReadme = @"
# Archive Directory

This directory contains archived source materials, integration scripts, and backups.

## Structure

### source_materials/
Raw source files used for generating GitBook content. The final integrated content is in:
- \`notes/reading_notes/by_source/\`
- \`quotes/by_source/\`
- \`comparative-analyses/\`
- \`bibliography/\`
- \`research_materials/future_research/\`

### integration_scripts/
Completed integration scripts kept for reference and future similar integrations.

### backups/
Backup files from various update processes.

## Retention Policy

- Source materials: Keep indefinitely for reference
- Integration scripts: Keep for at least 6 months
- Backups: Review quarterly, delete if no longer needed

## Last Updated

November 28, 2024 - Thompson integration and future research materials
"@
    
    if (-not (Test-Path "archive/README.md")) {
        $archiveReadme | Set-Content "archive/README.md"
        git add "archive/README.md"
        Write-Host "   Created archive/README.md" -ForegroundColor DarkGray
    }
    
    # Phase 5: Commit changes
    Write-Host "`n✅ Phase 5: Committing organized files to Git..." -ForegroundColor Cyan
    git add -A
    git status --short
    
    Write-Host "`n📊 Git Status:" -ForegroundColor Cyan
    git status --short | ForEach-Object { Write-Host "   $_" -ForegroundColor White }
    
    Write-Host "`n💾 Committing changes..." -ForegroundColor Cyan
    git commit -m "Organize untracked files: scripts, documentation, and archives

- Moved active automation scripts to scripts/
- Archived source materials (already integrated into GitBook)
- Archived backup files
- Created documentation READMEs
- Organized integration guides

Files organized:
- 7 automation scripts → scripts/
- 5 source materials → archive/source_materials/
- 3 backup files → archive/backups/
- 1 integration guide → docs/integration_guides/"
    
    Write-Host "`n🚀 Pushing to GitHub..." -ForegroundColor Cyan
    git push origin main
    
    Write-Host "`n══════════════════════════════════════════════════════════════" -ForegroundColor Green
    Write-Host "  ✅ Organization Complete!" -ForegroundColor Green
    Write-Host "══════════════════════════════════════════════════════════════" -ForegroundColor Green
    
    Write-Host "`n📁 Repository Structure:" -ForegroundColor Cyan
    Write-Host "   scripts/                     - Active automation scripts" -ForegroundColor White
    Write-Host "   docs/integration_guides/     - Integration documentation" -ForegroundColor White
    Write-Host "   archive/source_materials/    - Archived source files" -ForegroundColor White
    Write-Host "   archive/integration_scripts/ - Archived automation" -ForegroundColor White
    Write-Host "   archive/backups/             - Backup files" -ForegroundColor White
    
    Write-Host "`n✨ All untracked files organized!" -ForegroundColor Green
    Write-Host "   Wait 2-3 minutes for GitBook sync" -ForegroundColor Gray
    Write-Host "   Check: https://app.gitbook.com/o/cyZpWhV7KomErB6BnmVk/s/hRoSpCiTUrfuH62swMvH/" -ForegroundColor Gray
}

# Main execution
if ($Apply) {
    Apply-Organization
} elseif ($Preview -or $true) {
    # Default to preview if no flags provided
    Show-Preview
}
