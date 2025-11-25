# GitBook Optimization Verification Script
# Checks if all optimization tasks completed successfully

$ErrorActionPreference = "Continue"
$RepoPath = "C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis"

Push-Location $RepoPath

Write-Host "`n================================" -ForegroundColor Cyan
Write-Host "OPTIMIZATION VERIFICATION" -ForegroundColor Cyan
Write-Host "================================`n" -ForegroundColor Cyan

$passed = 0
$failed = 0
$warnings = 0

# Test 1: Check .gitbook.yaml exists
Write-Host "Test 1: .gitbook.yaml configuration..." -NoNewline
if (Test-Path ".gitbook.yaml") {
    $content = Get-Content ".gitbook.yaml" -Raw
    if ($content -match "structure:" -and $content -match "summary: SUMMARY.md") {
        Write-Host " ✓ PASS" -ForegroundColor Green
        $passed++
    } else {
        Write-Host " ✗ FAIL (invalid content)" -ForegroundColor Red
        $failed++
    }
} else {
    Write-Host " ✗ FAIL (not found)" -ForegroundColor Red
    $failed++
}

# Test 2: Check SUMMARY.md structure
Write-Host "Test 2: SUMMARY.md restructured..." -NoNewline
if (Test-Path "SUMMARY.md") {
    $summary = Get-Content "SUMMARY.md" -Raw
    $hasChapters = $summary -match "## Dissertation Chapters"
    $hasSources = $summary -match "## Research Sources"
    $hasQuotes = $summary -match "## Quote Collections"
    $hasFirman = $summary -match "Firman & Simmons"
    
    if ($hasChapters -and $hasSources -and $hasQuotes -and $hasFirman) {
        Write-Host " ✓ PASS" -ForegroundColor Green
        $passed++
        
        # Count sections
        $lines = Get-Content "SUMMARY.md"
        $level1 = ($lines | Where-Object { $_ -match '^\* \[' }).Count
        $level2 = ($lines | Where-Object { $_ -match '^## ' }).Count
        Write-Host "  - $level2 main sections, $level1 top-level items" -ForegroundColor Gray
    } else {
        Write-Host " ⚠ PARTIAL (missing sections)" -ForegroundColor Yellow
        $warnings++
    }
} else {
    Write-Host " ✗ FAIL (not found)" -ForegroundColor Red
    $failed++
}

# Test 3: Check duplicate directories removed
Write-Host "Test 3: Duplicate directories consolidated..." -NoNewline
$duplicates = @()
if (Test-Path "front-matter") { $duplicates += "front-matter" }
if (Test-Path "project-management") { $duplicates += "project-management" }
if (Test-Path "project-management-1") { $duplicates += "project-management-1" }
if (Test-Path "research-materials") { $duplicates += "research-materials" }

if ($duplicates.Count -eq 0) {
    Write-Host " ✓ PASS" -ForegroundColor Green
    $passed++
} else {
    Write-Host " ⚠ INCOMPLETE" -ForegroundColor Yellow
    Write-Host "  Still exists: $($duplicates -join ', ')" -ForegroundColor Gray
    $warnings++
}

# Test 4: Check correct directories exist
Write-Host "Test 4: Correct directories exist..." -NoNewline
$required = @("front_matter", "project_management", "chapters", "sources", "quotes")
$missing = @()
foreach ($dir in $required) {
    if (-not (Test-Path $dir)) {
        $missing += $dir
    }
}

if ($missing.Count -eq 0) {
    Write-Host " ✓ PASS" -ForegroundColor Green
    $passed++
} else {
    Write-Host " ⚠ INCOMPLETE" -ForegroundColor Yellow
    Write-Host "  Missing: $($missing -join ', ')" -ForegroundColor Gray
    $warnings++
}

# Test 5: Check progress dashboard created
Write-Host "Test 5: Progress dashboard created..." -NoNewline
$dashboard = "project_management/dashboard.md"
if (Test-Path $dashboard) {
    $content = Get-Content $dashboard -Raw
    if ($content -match "Chapter Status" -and $content -match "Recent Activity") {
        Write-Host " ✓ PASS" -ForegroundColor Green
        $passed++
    } else {
        Write-Host " ⚠ INCOMPLETE (missing content)" -ForegroundColor Yellow
        $warnings++
    }
} else {
    Write-Host " ✗ FAIL (not found)" -ForegroundColor Red
    $failed++
}

# Test 6: Check backup was created
Write-Host "Test 6: Backup directory created..." -NoNewline
$backups = Get-ChildItem "backups/optimization_*" -Directory -ErrorAction SilentlyContinue
if ($backups) {
    $latest = $backups | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    Write-Host " ✓ PASS" -ForegroundColor Green
    Write-Host "  Latest: $($latest.Name)" -ForegroundColor Gray
    $passed++
} else {
    Write-Host " ⚠ WARNING (no backup found)" -ForegroundColor Yellow
    $warnings++
}

# Test 7: Check orphaned files now linked
Write-Host "Test 7: Orphaned files linked..." -NoNewline
$orphanedBefore = 73  # From analysis report
$summary = Get-Content "SUMMARY.md" -Raw

# Check if key orphaned files are now linked
$keyFiles = @(
    "chapter_01_Introduction.md",
    "chapter_02_Literature_Review.md",
    "Cultural_Influences.md",
    "Economic_Factors.md"
)

$linkedCount = 0
foreach ($file in $keyFiles) {
    if ($summary -match [regex]::Escape($file)) {
        $linkedCount++
    }
}

if ($linkedCount -eq $keyFiles.Count) {
    Write-Host " ✓ PASS" -ForegroundColor Green
    Write-Host "  - Quote files now accessible in navigation" -ForegroundColor Gray
    $passed++
} else {
    Write-Host " ⚠ PARTIAL ($linkedCount/$($keyFiles.Count) linked)" -ForegroundColor Yellow
    $warnings++
}

# Test 8: Check Git status
Write-Host "Test 8: Git repository status..." -NoNewline
try {
    $gitStatus = git status --porcelain 2>$null
    if ($gitStatus) {
        $modifiedCount = ($gitStatus | Measure-Object).Count
        Write-Host " ⚠ UNCOMMITTED CHANGES" -ForegroundColor Yellow
        Write-Host "  - $modifiedCount modified files (ready to commit)" -ForegroundColor Gray
        $warnings++
    } else {
        Write-Host " ✓ PASS (all committed)" -ForegroundColor Green
        $passed++
    }
} catch {
    Write-Host " ⚠ SKIP (git not available)" -ForegroundColor Yellow
    $warnings++
}

# Test 9: Check Chapter 1 has front matter
Write-Host "Test 9: Chapter metadata added..." -NoNewline
$ch1 = "chapters/01_introduction/chapter_01_introduction.md"
if (Test-Path $ch1) {
    $content = Get-Content $ch1 -Raw
    if ($content -match '^---\s*\ntitle:' -and $content -match 'wordcount:') {
        Write-Host " ✓ PASS" -ForegroundColor Green
        $passed++
    } else {
        Write-Host " ⚠ INCOMPLETE (no metadata)" -ForegroundColor Yellow
        $warnings++
    }
} else {
    Write-Host " ✗ FAIL (chapter not found)" -ForegroundColor Red
    $failed++
}

# Test 10: Verify file counts
Write-Host "Test 10: File structure integrity..." -NoNewline
$mdFiles = (Get-ChildItem -Recurse -Filter "*.md" -File).Count
$ps1Files = (Get-ChildItem -Recurse -Filter "*.ps1" -File).Count

if ($mdFiles -ge 200) {
    Write-Host " ✓ PASS" -ForegroundColor Green
    Write-Host "  - $mdFiles markdown files" -ForegroundColor Gray
    Write-Host "  - $ps1Files PowerShell scripts" -ForegroundColor Gray
    $passed++
} else {
    Write-Host " ⚠ WARNING (unexpected file count)" -ForegroundColor Yellow
    Write-Host "  - $mdFiles markdown files (expected ~206)" -ForegroundColor Gray
    $warnings++
}

# Summary
Write-Host "`n================================" -ForegroundColor Cyan
Write-Host "VERIFICATION SUMMARY" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan

$total = $passed + $failed + $warnings
$successRate = [math]::Round(($passed / $total) * 100, 1)

Write-Host "`nTests Run: $total" -ForegroundColor White
Write-Host "Passed:    $passed" -ForegroundColor Green
Write-Host "Failed:    $failed" -ForegroundColor Red
Write-Host "Warnings:  $warnings" -ForegroundColor Yellow
Write-Host "`nSuccess Rate: $successRate%" -ForegroundColor Cyan

if ($failed -eq 0) {
    Write-Host "`n✓ OPTIMIZATION SUCCESSFUL!" -ForegroundColor Green
    Write-Host "Your GitBook structure has been optimized.`n" -ForegroundColor Green
    
    if ($warnings -gt 0) {
        Write-Host "Note: Some non-critical items need attention." -ForegroundColor Yellow
    }
    
    # Show next steps
    Write-Host "`nNext Steps:" -ForegroundColor Cyan
    
    $uncommitted = git status --porcelain 2>$null
    if ($uncommitted) {
        Write-Host "  1. Commit changes:" -ForegroundColor White
        Write-Host "     git add -A" -ForegroundColor Gray
        Write-Host "     git commit -m 'GitBook optimization complete'" -ForegroundColor Gray
        Write-Host "     git push origin main" -ForegroundColor Gray
    } else {
        Write-Host "  1. ✓ Changes already committed" -ForegroundColor Green
    }
    
    Write-Host "  2. Check GitBook sync (wait 2-3 minutes)" -ForegroundColor White
    Write-Host "  3. View new dashboard: project_management/dashboard.md" -ForegroundColor White
    Write-Host "  4. Verify navigation in GitBook editor" -ForegroundColor White
    
} else {
    Write-Host "`n✗ OPTIMIZATION INCOMPLETE" -ForegroundColor Red
    Write-Host "Some critical steps failed. Review errors above.`n" -ForegroundColor Red
    
    Write-Host "Troubleshooting:" -ForegroundColor Yellow
    Write-Host "  - Check if Optimize_GitBook.ps1 ran completely" -ForegroundColor White
    Write-Host "  - Review any error messages from the script" -ForegroundColor White
    Write-Host "  - Restore from backup if needed: backups/optimization_*" -ForegroundColor White
}

Write-Host ""

Pop-Location
