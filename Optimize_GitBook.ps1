# GitBook Optimizer - Simplified Version
# Runs 5 core optimization phases safely

$ErrorActionPreference = "Stop"
$RepoPath = "C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis"

Push-Location $RepoPath

Write-Host "`n================================" -ForegroundColor Cyan
Write-Host "GITBOOK OPTIMIZER" -ForegroundColor Cyan
Write-Host "================================`n" -ForegroundColor Cyan

# Backup timestamp
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backupDir = "backups/optimization_$timestamp"

# Create backup
Write-Host "Creating backup..." -ForegroundColor Yellow
New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
Copy-Item "SUMMARY.md" "$backupDir/SUMMARY.md" -Force
Copy-Item "README.md" "$backupDir/README.md" -Force
Write-Host "✓ Backup created: $backupDir`n" -ForegroundColor Green

# Phase 1: Create .gitbook.yaml
Write-Host "Phase 1: Creating .gitbook.yaml..." -ForegroundColor Cyan

$config = "# GitBook Configuration
root: ./

structure:
  readme: README.md
  summary: SUMMARY.md

exclude:
  - .git/
  - backups/
  - archive/
  - automation/
  - '*.ps1'
  - '*.log'
"

$config | Out-File ".gitbook.yaml" -Encoding UTF8
Write-Host "✓ Created .gitbook.yaml`n" -ForegroundColor Green

# Phase 2: Restructure SUMMARY.md
Write-Host "Phase 2: Restructuring SUMMARY.md..." -ForegroundColor Cyan

$summary = "# Table of Contents

* [Pair Bonding, Reproduction and Jungian Archetypes](README.md)

## Front Matter

* [Abstract](front_matter/abstract.md)
* [Acknowledgements](front_matter/acknowledgements.md)

## Dissertation Chapters

* [Chapter 1: Introduction](chapters/01_introduction/chapter_01_introduction.md)
* [Chapter 2: Evolutionary Foundations](chapters/02_evolutionary_foundations/chapter_02_evolutionary_foundations.md)
* [Chapter 3: Archetypal Dimensions](chapters/03_archetypal_dimensions/chapter_03_archetypal_dimensions.md)
* [Chapter 4: Synchronicity](chapters/04_synchronicity/chapter_04_synchronicity.md)
* [Chapter 5: Transpersonal Dimensions](chapters/05_transpersonal_dimensions/chapter_05_transpersonal_dimensions.md)
* [Chapter 6: Contemporary Crisis](chapters/06_contemporary_crisis/chapter_06_contemporary_crisis.md)
* [Chapter 7: Synthesis](chapters/07_synthesis/chapter_07_synthesis.md)
* [Chapter 8: Implications](chapters/08_implications/chapter_08_implications.md)
* [Chapter 9: Applications](chapters/09_implications/chapter_09_implications.md)
* [Chapter 10: Conclusion](chapters/10_conclusion/chapter_10_conclusion.md)

## Research Sources

### Academic Sources

* [Firman & Simmons (2011)](sources/summaries/Firman_2011_Source_Summary.md)
  * [Quotes (35)](sources/quotes/Firman_2011_Quotes_Database.md)
  * [Integration Guide](sources/integration_guides/Firman_2011_Chapter_Integration_Guide.md)
  * [Comparative Analysis](sources/comparative_analyses/Firman_Larsen_Comparative_Analysis.md)
  * [Bibliography](sources/bibliography/Firman_2011_Bibliography.bib)
* [Gangestad & Simpson (2000)](notes/reading_notes/by_source/gangestad_simpson_2000_source_summary.md)
  * [Quotes](quotes/by_source/gangestad_simpson_quotes.md)
* [Larsen (2023)](notes/reading_notes/by_source/larsen_2023_polygyny_demographic_collapse_summary.md)
  * [Quotes](quotes/by_source/larsen_2023_polygyny_quotes.md)
* [Buss (2023)](notes/reading_notes/by_source/buss_2023_mating_strategies_summary.md)
* [Bertrand et al.](notes/reading_notes/by_source/bertrand_et_al_hypergamy_summary.md)
* [Limar (2011)](notes/reading_notes/by_source/limar_2011_summary.md)

## Quote Collections

### Quotes by Chapter

* [Chapter 1: Introduction](quotes/by_chapter/chapter_01_Introduction.md)
* [Chapter 2: Literature Review](quotes/by_chapter/chapter_02_Literature_Review.md)
* [Chapter 3: Mating Strategies](quotes/by_chapter/chapter_03_Mating_Strategies.md)
* [Chapter 4: Economic Dimensions](quotes/by_chapter/chapter_04_Economic_Dimensions.md)
* [Chapter 5: Psychological Dimensions](quotes/by_chapter/chapter_05_Psychological_Dimensions.md)
* [Chapter 6: Cultural Evolution](quotes/by_chapter/chapter_06_Cultural_Evolution.md)
* [Chapter 7: Sex Ratio Dynamics](quotes/by_chapter/chapter_07_Sex_Ratio_Dynamics.md)
* [Chapter 8: Synthesis](quotes/by_chapter/chapter_08_Synthesis.md)
* [Chapter 9: Implications](quotes/by_chapter/chapter_09_Implications.md)
* [Chapter 10: Conclusion](quotes/by_chapter/chapter_10_Conclusion.md)

### Quotes by Theme

* [Cultural Influences](quotes/by_theme/Cultural_Influences.md)
* [Economic Factors](quotes/by_theme/Economic_Factors.md)
* [Hypergamy](quotes/by_theme/Hypergamy.md)
* [Mating Market](quotes/by_theme/Mating_Market.md)
* [Polygyny](quotes/by_theme/Polygyny.md)
* [Sexual Selection](quotes/by_theme/Sexual_Selection.md)

## Bibliography

* [Bibliography](bibliography/README.md)
* [Source Inventory](bibliography/source_inventory.md)

## Project Management

* [Progress Dashboard](project_management/dashboard.md)
* [Chapter Tracker](project_management/chapter_tracker.md)
* [ToDo List](project_management/todo.md)

## Archive

* [Archive Index](archive/archive_index.md)
"

$summary | Out-File "SUMMARY.md" -Encoding UTF8
Write-Host "✓ Restructured SUMMARY.md`n" -ForegroundColor Green

# Phase 3: Consolidate directories
Write-Host "Phase 3: Consolidating directories..." -ForegroundColor Cyan

if (Test-Path "front-matter") {
    if (Test-Path "front_matter") {
        Get-ChildItem "front-matter" -File | ForEach-Object {
            $dest = Join-Path "front_matter" $_.Name
            if (-not (Test-Path $dest)) {
                Move-Item $_.FullName $dest
            }
        }
        Remove-Item "front-matter" -Recurse -Force
        Write-Host "  ✓ Merged front-matter/ into front_matter/" -ForegroundColor Green
    } else {
        Rename-Item "front-matter" "front_matter"
        Write-Host "  ✓ Renamed front-matter/ to front_matter/" -ForegroundColor Green
    }
}

if (Test-Path "project-management") {
    Get-ChildItem "project-management" -File | ForEach-Object {
        $dest = Join-Path "project_management" $_.Name
        if (-not (Test-Path $dest)) {
            Move-Item $_.FullName $dest
        }
    }
    Remove-Item "project-management" -Recurse -Force
    Write-Host "  ✓ Merged project-management/" -ForegroundColor Green
}

if (Test-Path "project-management-1") {
    Get-ChildItem "project-management-1" -File | ForEach-Object {
        $dest = Join-Path "project_management" $_.Name
        if (-not (Test-Path $dest)) {
            Move-Item $_.FullName $dest
        }
    }
    Remove-Item "project-management-1" -Recurse -Force
    Write-Host "  ✓ Merged project-management-1/" -ForegroundColor Green
}

Write-Host ""

# Phase 4: Create dashboard
Write-Host "Phase 4: Creating progress dashboard..." -ForegroundColor Cyan

$dashboard = "# Progress Dashboard

**Last Updated:** $(Get-Date -Format 'yyyy-MM-dd HH:mm')

## Chapter Status

| Chapter | Status | Words | Target | Progress |
|---------|--------|-------|--------|----------|
| 1 | Draft | 1,306 | 5,000 | 26% |
| 2 | Outline | 253 | 8,000 | 3% |
| 3 | Outline | 90 | 7,000 | 1% |
| 4-10 | Outline | ~400 | 48,000 | <1% |

**Total:** ~2,400 / 80,000 words (3%)

## Recent Activity

- 2025-11-25: GitBook optimization completed
- 2025-11-25: Added Firman & Simmons (2011) materials
- 2025-11-23: Repository cleanup

## Next Actions

1. Chapter 2: Integrate Firman (2011) findings
2. Chapter 1: Expand from 1,300 to 5,000 words
3. Apply chapter-specific quotes from databases
"

$dashboard | Out-File "project_management/dashboard.md" -Encoding UTF8
Write-Host "✓ Created dashboard`n" -ForegroundColor Green

# Phase 5: Add front matter to Chapter 1
Write-Host "Phase 5: Adding metadata to chapters..." -ForegroundColor Cyan

$ch1 = "chapters/01_introduction/chapter_01_introduction.md"
if (Test-Path $ch1) {
    $content = Get-Content $ch1 -Raw
    if ($content -notmatch '^---') {
        $frontMatter = "---
title: Chapter 1 - Introduction
status: draft
wordcount: 1306
target: 5000
progress: 26%
updated: $(Get-Date -Format 'yyyy-MM-dd')
---

"
        ($frontMatter + $content) | Out-File $ch1 -Encoding UTF8
        Write-Host "  ✓ Added metadata to Chapter 1" -ForegroundColor Green
    }
}

Write-Host ""

# Summary
Write-Host "================================" -ForegroundColor Green
Write-Host "OPTIMIZATION COMPLETE!" -ForegroundColor Green
Write-Host "================================`n" -ForegroundColor Green

Write-Host "Changes made:" -ForegroundColor White
Write-Host "  ✓ Created .gitbook.yaml" -ForegroundColor Green
Write-Host "  ✓ Restructured SUMMARY.md" -ForegroundColor Green
Write-Host "  ✓ Consolidated duplicate directories" -ForegroundColor Green
Write-Host "  ✓ Created progress dashboard" -ForegroundColor Green
Write-Host "  ✓ Added chapter metadata" -ForegroundColor Green

Write-Host "`nBackup saved to: $backupDir" -ForegroundColor Yellow

Write-Host "`nCommit these changes? (yes/no): " -ForegroundColor Cyan -NoNewline
$answer = Read-Host

if ($answer -eq "yes") {
    Write-Host "`nCommitting..." -ForegroundColor Cyan
    git add -A
    git commit -m "GitBook optimization: Clean navigation and progress tracking"
    git push origin main
    Write-Host "✓ Changes committed and pushed!`n" -ForegroundColor Green
} else {
    Write-Host "`nRun these commands when ready:" -ForegroundColor Yellow
    Write-Host "  git add -A" -ForegroundColor Gray
    Write-Host "  git commit -m 'GitBook optimization'" -ForegroundColor Gray
    Write-Host "  git push origin main`n" -ForegroundColor Gray
}

Pop-Location
