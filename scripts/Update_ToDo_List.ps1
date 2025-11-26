#!/usr/bin/env pwsh
#Requires -Version 7.0

<#
.SYNOPSIS
    Update To-Do List Dashboard
    
.DESCRIPTION
    Updates the dissertation to-do list with current timestamp and status
#>

$ErrorActionPreference = "Stop"

$todoDir = "project_management"
if (-not (Test-Path $todoDir)) {
    New-Item -Path $todoDir -ItemType Directory -Force | Out-Null
}

$todoPath = "$todoDir/todo.md"

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
- [ ] Begin Chapter 3 draft

## 🟡 Medium Priority

- [ ] Create integration guides for Buss (2023)
- [ ] Create integration guides for Larsen (2023)
- [ ] Create integration guides for Gangestad & Simpson (2000)
- [ ] Process Jung source material

## 🟢 Low Priority

- [ ] Process additional quantum biology papers
- [ ] Create cross-chapter integration document
- [ ] Develop methodology chapter outline

## ✅ Recently Completed

- [x] Update abstract with new research (2024-11-25)
- [x] Create Buss (2023) comparative analysis (~4,200 words) (2024-11-25)
- [x] Create Larsen (2023) comparative analysis (~6,800 words) (2024-11-25)
- [x] Create Gangestad & Simpson (2000) comparative analysis (~7,400 words) (2024-11-25)
- [x] Deploy all 5 comparative analyses to GitBook (2024-11-25)
- [x] Update GitBook navigation with comparative analyses (2024-11-25)
- [x] Optimize GitBook structure (90% success rate) (2024-11-25)
- [x] Create Firman materials (summary, quotes, integration guide, bibliography) (2024-11-24)
- [x] Create Firman & Larsen comparative analysis (2024-11-24)

---

## 📊 Progress Statistics

- **Total Tasks:** 12
- **Completed:** 9 (75%)
- **Remaining:** 3 (25%)
- **High Priority Remaining:** 3
- **Medium Priority Remaining:** 4
- **Low Priority Remaining:** 3

---

## 🎯 This Week's Goals

**Week of $(Get-Date -Format "MMM dd, yyyy"):**

1. Expand Chapter 1 from 1,306 → 3,000 words (50% milestone)
2. Draft Chapter 2 outline → 2,000 words (25% milestone)
3. Create integration guide for one additional source

---

## 📅 Upcoming Milestones

- **End of Week:** Chapter 1 at 50% completion
- **End of Month:** 3 chapters at draft stage
- **Q1 2025:** All 10 chapters outlined, 5 at draft stage
- **Q2 2025:** 8 chapters at draft stage
- **Q3 2025:** All chapters drafted, begin revision
- **Q4 2025:** Complete dissertation

---

## 💡 Notes

- Focus on expanding Chapter 1 with Firman data integration
- Use comparative analyses to inform chapter content
- Aim for 500-1000 words per writing session
- Update dashboards after each session

"@
    Set-Content -Path $todoPath -Value $initialContent -Encoding UTF8
    Write-Host "✓ Created initial to-do list: $todoPath" -ForegroundColor Green
} else {
    # Update timestamp in existing file
    $content = Get-Content $todoPath -Raw
    
    # Update last updated timestamp
    if ($content -match "\*\*Last Updated:\*\* .*") {
        $updatedContent = $content -replace "\*\*Last Updated:\*\* .*", "**Last Updated:** $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    } else {
        # Add timestamp if missing
        $updatedContent = "# Dissertation To-Do List`n`n**Last Updated:** $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n`n" + $content
    }
    
    # Update week in "This Week's Goals" if present
    if ($updatedContent -match "\*\*Week of .*:") {
        $updatedContent = $updatedContent -replace "\*\*Week of .*:", "**Week of $(Get-Date -Format 'MMM dd, yyyy'):"
    }
    
    Set-Content -Path $todoPath -Value $updatedContent -Encoding UTF8
    Write-Host "✓ Updated to-do list timestamp: $todoPath" -ForegroundColor Green
}
