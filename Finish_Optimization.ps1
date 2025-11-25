# Complete remaining optimization tasks
# Fixes the 2 warnings from verification

$ErrorActionPreference = "Stop"
Push-Location "C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis"

Write-Host "`nFinishing optimization tasks...`n" -ForegroundColor Cyan

# Task 1: Remove research-materials duplicate
Write-Host "Task 1: Removing research-materials/ duplicate..." -ForegroundColor Yellow

if (Test-Path "research-materials") {
    # Ensure research_materials exists
    if (-not (Test-Path "research_materials")) {
        New-Item -ItemType Directory -Path "research_materials" -Force | Out-Null
    }
    
    # Move any unique files
    Get-ChildItem "research-materials" -Recurse -File | ForEach-Object {
        $relativePath = $_.FullName.Replace((Resolve-Path "research-materials").Path, "").TrimStart('\')
        $dest = Join-Path "research_materials" $relativePath
        $destDir = Split-Path $dest -Parent
        
        if (-not (Test-Path $destDir)) {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        }
        
        if (-not (Test-Path $dest)) {
            Copy-Item $_.FullName $dest -Force
            Write-Host "  Copied: $relativePath" -ForegroundColor Gray
        }
    }
    
    # Remove the duplicate
    Remove-Item "research-materials" -Recurse -Force
    Write-Host "✓ Removed research-materials/ directory`n" -ForegroundColor Green
} else {
    Write-Host "✓ Already removed`n" -ForegroundColor Green
}

# Task 2: Add front matter to Chapter 1
Write-Host "Task 2: Adding metadata to Chapter 1..." -ForegroundColor Yellow

$ch1 = "chapters/01_introduction/chapter_01_introduction.md"
if (Test-Path $ch1) {
    $content = Get-Content $ch1 -Raw
    
    if ($content -notmatch '^---') {
        # Calculate actual word count
        $words = ($content -split '\s+' | Where-Object { $_ }).Count
        $target = 5000
        $progress = [math]::Round(($words / $target) * 100, 1)
        
        $frontMatter = @"
---
title: Chapter 1 - Introduction
chapter: 01
status: draft
wordcount: $words
target_words: $target
progress: ${progress}%
last_updated: $(Get-Date -Format 'yyyy-MM-dd')
keywords:
  - introduction
  - research questions
  - theoretical framework
  - evolutionary psychology
---

"@
        
        ($frontMatter + $content) | Out-File $ch1 -Encoding UTF8
        Write-Host "✓ Added metadata to Chapter 1" -ForegroundColor Green
        Write-Host "  - $words words (${progress}% of target)" -ForegroundColor Gray
    } else {
        Write-Host "✓ Already has metadata" -ForegroundColor Green
    }
} else {
    Write-Host "⚠ Chapter 1 file not found" -ForegroundColor Yellow
}

Write-Host ""

# Check if changes need to be committed
$status = git status --porcelain 2>$null
if ($status) {
    Write-Host "Changes made. Commit now? (yes/no): " -ForegroundColor Cyan -NoNewline
    $answer = Read-Host
    
    if ($answer -eq "yes") {
        git add -A
        git commit -m "Complete optimization: Remove duplicates and add chapter metadata"
        git push origin main
        Write-Host "`n✓ Changes committed and pushed!`n" -ForegroundColor Green
    } else {
        Write-Host "`nRun when ready:" -ForegroundColor Yellow
        Write-Host "  git add -A && git commit -m 'Complete optimization' && git push`n" -ForegroundColor Gray
    }
} else {
    Write-Host "✓ No changes needed - already complete!`n" -ForegroundColor Green
}

Write-Host "All optimization tasks complete! 🎉`n" -ForegroundColor Green

Pop-Location
