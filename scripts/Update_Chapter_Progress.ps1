#!/usr/bin/env pwsh
#Requires -Version 7.0

<#
.SYNOPSIS
    Update Chapter Progress Dashboard
    
.DESCRIPTION
    Scans all chapter files, calculates word counts, and updates the 
    chapter progress dashboard with current statistics
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
        try {
            $content = Get-Content $path -Raw -ErrorAction Stop
            $wordCount = ($content | Measure-Object -Word).Words
        } catch {
            $wordCount = 0
        }
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
    
    $chapterData += [PSCustomObject]@{
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
$overallPercent = [math]::Round(($totalWords / $totalTarget) * 100, 1)

$dashboardContent = @"
# Chapter Progress Dashboard

**Last Updated:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

---

## Overall Progress

**Total Words:** $totalWords / $totalTarget ($overallPercent%)

📊 Overall Progress Bar:
``````
$("█" * [math]::Floor(($overallPercent / 100) * 50))$("░" * (50 - [math]::Floor(($overallPercent / 100) * 50)))
``````
$overallPercent% Complete

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

$dashboardContent += @"

---

## Writing Velocity

- **Target Total:** $totalTarget words
- **Current Total:** $totalWords words
- **Remaining:** $($totalTarget - $totalWords) words
- **Average Chapter:** $([math]::Round($totalWords / 10, 0)) words (target: $([math]::Round($totalTarget / 10, 0)) words)

---

## Status Distribution

"@

$statusCounts = @{}
$chapterData | ForEach-Object { 
    if ($statusCounts.ContainsKey($_.Status)) {
        $statusCounts[$_.Status]++
    } else {
        $statusCounts[$_.Status] = 1
    }
}

foreach ($status in @("Outline", "Draft", "Revision", "Complete")) {
    $count = if ($statusCounts.ContainsKey($status)) { $statusCounts[$status] } else { 0 }
    $dashboardContent += "`n- **$status**: $count chapters"
}

# Write dashboard
$dashboardDir = "project_management"
if (-not (Test-Path $dashboardDir)) {
    New-Item -Path $dashboardDir -ItemType Directory -Force | Out-Null
}

$dashboardPath = "$dashboardDir/dashboard.md"
Set-Content -Path $dashboardPath -Value $dashboardContent -Encoding UTF8

Write-Host "✓ Chapter progress dashboard updated: $dashboardPath" -ForegroundColor Green
Write-Host "  Total: $totalWords / $totalTarget words ($overallPercent%)" -ForegroundColor Cyan
