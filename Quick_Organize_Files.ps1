# Quick File Organization - Run directly without execution policy issues
# Copy and paste this entire script into PowerShell, then press Enter

# Create directories
Write-Host "Creating directories..." -ForegroundColor Cyan
New-Item -ItemType Directory -Force -Path "scripts" | Out-Null
New-Item -ItemType Directory -Force -Path "docs/integration_guides" | Out-Null
New-Item -ItemType Directory -Force -Path "archive/source_materials" | Out-Null
New-Item -ItemType Directory -Force -Path "archive/integration_scripts" | Out-Null
New-Item -ItemType Directory -Force -Path "archive/backups" | Out-Null

# Move active scripts
Write-Host "Organizing scripts..." -ForegroundColor Cyan
Move-Item "Add_Future_Research_To_GitBook.ps1" "scripts/" -Force
Move-Item "Diagnose_Progress_Summary.ps1" "scripts/" -Force
Move-Item "Extract_And_Update_Progress_Summary.ps1" "scripts/" -Force
Move-Item "Weekly_Dissertation_Update.ps1" "scripts/" -Force
Move-Item "Organize_Untracked_Files.ps1" "scripts/" -Force

# Move documentation
Write-Host "Organizing documentation..." -ForegroundColor Cyan
Move-Item "THOMPSON_INTEGRATION_GUIDE.md" "docs/integration_guides/" -Force

# Archive source materials
Write-Host "Archiving source materials..." -ForegroundColor Cyan
Move-Item "Thompson_2020_Quotes.md" "archive/source_materials/" -Force
Move-Item "Thompson_2020_Research_Summary.md" "archive/source_materials/" -Force
Move-Item "Thompson_Bibliography.md" "archive/source_materials/" -Force
Move-Item "Thompson_Comparative_Analysis.md" "archive/source_materials/" -Force
Move-Item "Future_Research_Directions.md" "archive/source_materials/" -Force

# Archive integration scripts
Write-Host "Archiving integration scripts..." -ForegroundColor Cyan
Move-Item "Thompson_2020_Complete_Integration.ps1" "archive/integration_scripts/" -Force
Move-Item "Thompson_Complete_Integration.ps1" "archive/integration_scripts/" -Force

# Archive backups
Write-Host "Archiving backups..." -ForegroundColor Cyan
Move-Item "SUMMARY.md.backup_thompson_fix" "archive/backups/" -Force
Move-Item "chapters/01_introduction/chapter_01_introduction_backup_20251127_231539.md" "archive/backups/" -Force
Move-Item "chapters/01_introduction/chapter_01_introduction_backup_20251127_231825.md" "archive/backups/" -Force

# Add to Git
Write-Host "Adding to Git..." -ForegroundColor Cyan
git add scripts/
git add docs/integration_guides/
git add archive/

# Commit
Write-Host "Committing..." -ForegroundColor Cyan
git commit -m "Organize untracked files: scripts, docs, and archives

- Moved 5 automation scripts to scripts/
- Moved integration guide to docs/integration_guides/
- Archived 5 source materials (content already in GitBook)
- Archived 2 integration scripts (completed)
- Archived 3 backup files

All untracked files now organized and tracked."

# Push
Write-Host "Pushing to GitHub..." -ForegroundColor Cyan
git push origin main

Write-Host "`n✅ Organization complete!" -ForegroundColor Green
Write-Host "Wait 2-3 minutes for GitBook sync" -ForegroundColor Gray
