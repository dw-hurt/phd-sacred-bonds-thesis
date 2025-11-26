# Project Management Dashboard - Update Commands

## Overview

This page contains all PowerShell commands needed to update and maintain your dissertation project dashboards. Run these commands regularly to keep your progress tracking current.

---

## 🚀 Quick Update - All Dashboards

Run this single command to update everything at once:

```powershell
# Quick update all dashboards
.\scripts\Update_All_Dashboards.ps1
```

**What it updates:**
- ✅ Chapter progress (word counts, completion percentages)
- ✅ Overall dissertation progress
- ✅ Source material status
- ✅ Comparative analyses completion
- ✅ To-do list status
- ✅ Timeline milestones

---

## 📈 Individual Dashboard Updates

### 1. Chapter Progress Dashboard

**Update all chapter word counts and progress percentages:**

```powershell
# Update chapter progress dashboard
.\scripts\Update_Chapter_Progress.ps1
```

**What it tracks:**
- Word count per chapter
- Target word count
- Completion percentage
- Status (Outline/Draft/Revision/Complete)
- Last updated timestamp

**Manual verification:**
```powershell
# View current chapter progress
Get-Content project_management\dashboard.md
```

---

### 2. Overall Dissertation Progress

**Update overall dissertation statistics:**

```powershell
# Update overall progress metrics
.\scripts\Update_Dissertation_Progress.ps1
```

**What it tracks:**
- Total words written vs. target (80,000-100,000)
- Chapters completed (10 total)
- Sources processed (6 major sources)
- Comparative analyses complete (5/5)
- Research materials word count
- Overall completion percentage

**Quick stats check:**
```powershell
# Get quick statistics
Get-ChildItem -Path chapters -Recurse -Include *.md | 
    ForEach-Object { (Get-Content $_.FullName | Measure-Object -Word).Words } | 
    Measure-Object -Sum | 
    Select-Object @{Name="TotalWords";Expression={$_.Sum}}
```

---

### 3. To-Do List Management

**Update and manage dissertation to-do items:**

```powershell
# Update to-do list with current status
.\scripts\Update_ToDo_List.ps1
```

**View current to-dos:**
```powershell
# Display active to-do items
Get-Content project_management\todo.md
```

**Add new to-do item:**
```powershell
# Add new task
.\scripts\Add_ToDo.ps1 -Task "Complete Chapter 3 draft" -Priority High -DueDate "2024-12-15"
```

**Mark task complete:**
```powershell
# Complete a task
.\scripts\Complete_ToDo.ps1 -TaskNumber 5
```

---

### 4. Source Material Tracking

**Update source processing status:**

```powershell
# Update source material dashboard
.\scripts\Update_Source_Status.ps1
```

**What it tracks:**
- Sources read and summarized
- Quotes extracted
- Integration guides created
- Comparative analyses completed
- Bibliography entries added

**Check source status:**
```powershell
# List all processed sources
Get-ChildItem -Path sources\summaries -Filter *.md | Select-Object Name, Length, LastWriteTime
```

---

## 🔄 Automated Update Scripts

### Master Update Script

Create a master script that updates everything:

```powershell
# File: scripts/Update_All_Dashboards.ps1

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
    - Timeline tracking
#>

param(
    [switch]$Commit,
    [switch]$Verbose
)

$ErrorActionPreference = "Stop"

function Write-Status {
    param([string]$Message)
    Write-Host "  ✓ $Message" -ForegroundColor Green
}

Write-Host "`n=== UPDATING ALL DASHBOARDS ===" -ForegroundColor Cyan
Write-Host ""

# 1. Update chapter progress
Write-Host "Updating chapter progress..." -ForegroundColor Yellow
& "$PSScriptRoot\Update_Chapter_Progress.ps1"
Write-Status "Chapter progress updated"

# 2. Update overall progress
Write-Host "`nUpdating overall dissertation progress..." -ForegroundColor Yellow
& "$PSScriptRoot\Update_Dissertation_Progress.ps1"
Write-Status "Overall progress updated"

# 3. Update source status
Write-Host "`nUpdating source material status..." -ForegroundColor Yellow
& "$PSScriptRoot\Update_Source_Status.ps1"
Write-Status "Source status updated"

# 4. Update to-do list
Write-Host "`nUpdating to-do list..." -ForegroundColor Yellow
& "$PSScriptRoot\Update_ToDo_List.ps1"
Write-Status "To-do list updated"

Write-Host "`n=== ALL DASHBOARDS UPDATED ===" -ForegroundColor Green

if ($Commit) {
    Write-Host "`nCommitting changes..." -ForegroundColor Yellow
    git add project_management/*
    git commit -m "Update project management dashboards - $(Get-Date -Format 'yyyy-MM-dd')"
    Write-Status "Changes committed"
}

Write-Host ""
```

**Usage:**
```powershell
# Update all dashboards
.\scripts\Update_All_Dashboards.ps1

# Update and auto-commit
.\scripts\Update_All_Dashboards.ps1 -Commit

# Verbose output
.\scripts\Update_All_Dashboards.ps1 -Verbose
```

---

## 📊 Chapter Progress Tracking Script

### Update Chapter Progress Dashboard

```powershell
# File: scripts/Update_Chapter_Progress.ps1

#!/usr/bin/env pwsh
#Requires -Version 7.0

<#
.SYNOPSIS
    Update Chapter Progress Dashboard
#>

$ErrorActionPreference = "Stop"

# Chapter configuration
$chapters = @(
    @{Number=1; Name="Introduction"; Target=5000; Path="chapters/01_introduction/chapter_01_introduction.md"},
    @{Number=2; Name="Evolutionary Foundations"; Target=8000; Path="chapters/02_evolutionary_foundations/chapter_02_evolutionary_foundations.md"},
    @{Number=3; Name="Archetypal Dimensions"; Target=8000; Path="chapters/03_archetypal_dimensions/chapter_03_archetypal_dimensions.md"},
    @{Number=4; Name="Synchronicity"; Target=7000; Path="chapters/04_synchronicity/chapter_04_synchronicity.md"},
    @{Number=5; Name="Transpersonal Dimensions"; Target=8000; Path="chapters/05_transpersonal_dimensions/chapter_05_transpersonal_dimensions.md"},
    @{Number=6; Name="Contemporary Crisis"; Target=10000; Path="chapters/06_contemporary_crisis/chapter_06_contemporary_crisis.md"},
    @{Number=7; Name="Synthesis"; Target=10000; Path="chapters/07_synthesis/chapter_07_synthesis.md"},
    @{Number=8; Name="Implications"; Target=8000; Path="chapters/08_implications/chapter_08_implications.md"},
    @{Number=9; Name="Applications"; Target=8000; Path="chapters/09_implications/chapter_09_implications.md"},
    @{Number=10; Name="Conclusion"; Target=5000; Path="chapters/10_conclusion/chapter_10_conclusion.md"}
)

Write-Host "Analyzing chapter progress..." -ForegroundColor Cyan

# Calculate progress for each chapter
$chapterData = @()
$totalWords = 0
$totalTarget = 0

foreach ($chapter in $chapters) {
    $path = $chapter.Path
    
    if (Test-Path $path) {
        $content = Get-Content $path -Raw
        $wordCount = ($content | Measure-Object -Word).Words
    } else {
        $wordCount = 0
    }
    
    $totalWords += $wordCount
    $totalTarget += $chapter.Target
    
    $percentage = if ($chapter.Target -gt 0) { 
        [math]::Round(($wordCount / $chapter.Target) * 100, 1) 
    } else { 0 }
    
    # Determine status
    $status = if ($percentage -ge 100) { "Complete" }
              elseif ($percentage -ge 80) { "Revision" }
              elseif ($percentage -ge 25) { "Draft" }
              else { "Outline" }
    
    # Progress bar
    $barLength = 20
    $filledLength = [math]::Floor(($percentage / 100) * $barLength)
    $bar = ("█" * $filledLength) + ("░" * ($barLength - $filledLength))
    
    $chapterData += @{
        Number = $chapter.Number
        Name = $chapter.Name
        Words = $wordCount
        Target = $chapter.Target
        Percentage = $percentage
        Status = $status
        Bar = $bar
    }
}

# Generate dashboard markdown
$dashboardContent = @"
# Chapter Progress Dashboard

**Last Updated:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

---

## Overall Progress

**Total Words:** $totalWords / $totalTarget ($(([math]::Round(($totalWords / $totalTarget) * 100, 1)))%)

---

## Chapter Status

| Chapter | Title | Progress | Words | Target | Status |
|---------|-------|----------|-------|--------|--------|
"@

foreach ($data in $chapterData) {
    $dashboardContent += "`n| Ch $($data.Number) | $($data.Name) | $($data.Bar) $($data.Percentage)% | $($data.Words) | $($data.Target) | $($data.Status) |"
}

$dashboardContent += @"


---

## Progress Details

"@

foreach ($data in $chapterData) {
    $remaining = $data.Target - $data.Words
    $dashboardContent += @"

### Chapter $($data.Number): $($data.Name)
- **Current:** $($data.Words) words
- **Target:** $($data.Target) words
- **Remaining:** $remaining words
- **Status:** $($data.Status)
- **Progress:** $($data.Percentage)%

"@
}

# Write dashboard
$dashboardPath = "project_management/dashboard.md"
Set-Content -Path $dashboardPath -Value $dashboardContent -Encoding UTF8

Write-Host "✓ Chapter progress dashboard updated: $dashboardPath" -ForegroundColor Green
Write-Host "  Total: $totalWords / $totalTarget words ($(([math]::Round(($totalWords / $totalTarget) * 100, 1)))%)" -ForegroundColor Cyan
```

---

## 📝 To-Do List Management Script

### Update To-Do List

```powershell
# File: scripts/Update_ToDo_List.ps1

#!/usr/bin/env pwsh
#Requires -Version 7.0

<#
.SYNOPSIS
    Update To-Do List Dashboard
#>

$ErrorActionPreference = "Stop"

$todoPath = "project_management/todo.md"

# Check if todo file exists
if (-not (Test-Path $todoPath)) {
    # Create initial todo list
    $initialContent = @"
# Dissertation To-Do List

**Last Updated:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

---

## 🔴 High Priority

- [ ] Complete Chapter 1 draft (current: 26%, target: 100%)
- [ ] Expand Chapter 2 from outline to draft

## 🟡 Medium Priority

- [ ] Create integration guides for Buss (2023)
- [ ] Create integration guides for Larsen (2023)
- [ ] Create integration guides for Gangestad & Simpson (2000)

## 🟢 Low Priority

- [ ] Process Jung source material
- [ ] Process additional quantum biology papers
- [ ] Create cross-chapter integration document

## ✅ Recently Completed

- [x] Update abstract with new research (2024-11-25)
- [x] Create Buss (2023) comparative analysis (2024-11-25)
- [x] Create Larsen (2023) comparative analysis (2024-11-25)
- [x] Create Gangestad & Simpson (2000) comparative analysis (2024-11-25)
- [x] Deploy all 5 comparative analyses to GitBook (2024-11-25)
- [x] Update GitBook navigation (2024-11-25)
- [x] Optimize GitBook structure (2024-11-25)
- [x] Create Firman materials (summary, quotes, integration guide, bibliography) (2024-11-24)

---

## 📊 Statistics

- **Total Tasks:** 11
- **Completed:** 8 (73%)
- **Remaining:** 3 (27%)
- **High Priority:** 2
- **Medium Priority:** 3
- **Low Priority:** 3

"@
    Set-Content -Path $todoPath -Value $initialContent -Encoding UTF8
    Write-Host "✓ Created initial to-do list: $todoPath" -ForegroundColor Green
} else {
    # Update timestamp in existing file
    $content = Get-Content $todoPath -Raw
    $updatedContent = $content -replace "\*\*Last Updated:\*\* .*", "**Last Updated:** $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    Set-Content -Path $todoPath -Value $updatedContent -Encoding UTF8
    Write-Host "✓ Updated to-do list timestamp: $todoPath" -ForegroundColor Green
}
```

---

## 🎯 Quick Reference Commands

### Daily Update Routine

```powershell
# Morning: Check current status
Get-Content project_management\dashboard.md
Get-Content project_management\todo.md

# After writing session: Update all dashboards
.\scripts\Update_All_Dashboards.ps1 -Commit

# View git log of progress
git log --oneline --since="1 week ago" -- project_management/
```

### Weekly Review Commands

```powershell
# Calculate total dissertation words
$totalWords = 0
Get-ChildItem -Path chapters -Recurse -Filter *.md | ForEach-Object {
    $words = (Get-Content $_.FullName -Raw | Measure-Object -Word).Words
    $totalWords += $words
    Write-Host "$($_.Name): $words words"
}
Write-Host "Total Chapter Words: $totalWords" -ForegroundColor Green

# Calculate research materials words
$researchWords = 0
Get-ChildItem -Path sources -Recurse -Filter *.md | ForEach-Object {
    $words = (Get-Content $_.FullName -Raw | Measure-Object -Word).Words
    $researchWords += $words
}
Write-Host "Total Research Words: $researchWords" -ForegroundColor Cyan

# Total project words
Write-Host "TOTAL PROJECT WORDS: $($totalWords + $researchWords)" -ForegroundColor Yellow
```

### Progress Visualization

```powershell
# Create visual progress report
Write-Host "`n=== DISSERTATION PROGRESS REPORT ===" -ForegroundColor Cyan
Write-Host "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
Write-Host ""

# Chapters
$chapterWords = (Get-ChildItem -Path chapters -Recurse -Filter *.md | 
    ForEach-Object { (Get-Content $_.FullName -Raw | Measure-Object -Word).Words } | 
    Measure-Object -Sum).Sum
$chapterTarget = 80000
$chapterPercent = [math]::Round(($chapterWords / $chapterTarget) * 100, 1)
Write-Host "Chapters: $chapterWords / $chapterTarget words ($chapterPercent%)" -ForegroundColor Yellow

# Sources
$sourceCount = (Get-ChildItem -Path sources\summaries -Filter *.md).Count
Write-Host "Sources Processed: $sourceCount / 6" -ForegroundColor Green

# Comparative Analyses
$analysisCount = (Get-ChildItem -Path sources\comparative_analyses -Filter *.md).Count
Write-Host "Comparative Analyses: $analysisCount / 5 (Complete)" -ForegroundColor Green

Write-Host "`n=== END REPORT ===" -ForegroundColor Cyan
```

---

## 🔧 Setup Instructions

### First-Time Setup

1. **Create scripts directory:**
```powershell
mkdir scripts -Force
```

2. **Download all scripts to scripts/ directory:**
   - Update_All_Dashboards.ps1
   - Update_Chapter_Progress.ps1
   - Update_Dissertation_Progress.ps1
   - Update_Source_Status.ps1
   - Update_ToDo_List.ps1

3. **Make scripts executable:**
```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
```

4. **Run initial update:**
```powershell
.\scripts\Update_All_Dashboards.ps1 -Commit
```

---

## 📅 Recommended Update Schedule

| Frequency | Action | Command |
|-----------|--------|---------|
| **After each writing session** | Update chapter progress | `.\scripts\Update_Chapter_Progress.ps1` |
| **Daily** | Update all dashboards | `.\scripts\Update_All_Dashboards.ps1` |
| **Weekly** | Full review + commit | `.\scripts\Update_All_Dashboards.ps1 -Commit` |
| **Monthly** | Generate progress report | Run visualization commands |

---

## 🎓 Advanced Usage

### Custom Progress Reports

```powershell
# Generate detailed progress report
function Get-DissertationReport {
    $report = @{
        Chapters = (Get-ChildItem chapters -Recurse -Filter *.md).Count
        ChapterWords = (Get-ChildItem chapters -Recurse -Filter *.md | 
            ForEach-Object { (Get-Content $_.FullName -Raw | Measure-Object -Word).Words } | 
            Measure-Object -Sum).Sum
        Sources = (Get-ChildItem sources\summaries -Filter *.md).Count
        Analyses = (Get-ChildItem sources\comparative_analyses -Filter *.md).Count
        LastCommit = (git log -1 --format="%cd" --date=short)
        TotalCommits = (git rev-list --count HEAD)
    }
    return $report
}

# Usage
$report = Get-DissertationReport
$report | Format-Table -AutoSize
```

### Backup Before Updates

```powershell
# Backup dashboards before updating
$backupDir = "project_management/backups/$(Get-Date -Format 'yyyyMMdd')"
mkdir $backupDir -Force
Copy-Item project_management/*.md $backupDir
Write-Host "✓ Backed up to: $backupDir" -ForegroundColor Green

# Then update
.\scripts\Update_All_Dashboards.ps1
```

---

## 🆘 Troubleshooting

### Script Not Found

```powershell
# Verify script exists
Test-Path .\scripts\Update_All_Dashboards.ps1

# If false, check current directory
Get-Location

# Navigate to repository root
cd C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis
```

### Permission Errors

```powershell
# Set execution policy for current session
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

# Re-run script
.\scripts\Update_All_Dashboards.ps1
```

### Git Commit Fails

```powershell
# Check git status
git status

# Manual commit
git add project_management/*
git commit -m "Update dashboards - $(Get-Date -Format 'yyyy-MM-dd')"
git push
```

---

## 📚 Additional Resources

- **GitBook Dashboard**: View live progress in your GitBook editor
- **GitHub Repository**: Track commits and changes over time
- **Project Management Folder**: `project_management/` contains all dashboard files

---

**Last Updated:** 2024-11-25
