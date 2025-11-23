# ============================================================================
# update-dashboard.ps1
# PhD Project Dashboard Auto-Updater
# ============================================================================

param(
    [Parameter(Mandatory=$false)]
    [switch]$Commit
)

# Repository base path
$RepoPath = "C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis"
$DashboardFile = Join-Path $RepoPath "project_management\dashboard.md"
$TodoFile = Join-Path $RepoPath "project_management\todo.md"
$NotesPath = Join-Path $RepoPath "notes\reading_notes\by_source"
$QuotesPath = Join-Path $RepoPath "quotes\by_source"

Write-Host "`n" -NoNewline
Write-Host "Updating PhD Dissertation Dashboard..." -ForegroundColor Cyan
Write-Host ("=" * 60) -ForegroundColor Gray

# ============================================================================
# Collect Statistics
# ============================================================================

# Count source files (summary files in reading_notes)
$sourcesProcessed = 0
$sourceSummaries = @()
if (Test-Path $NotesPath) {
    $sourceSummaries = Get-ChildItem -Path $NotesPath -Filter "*_summary.md" -ErrorAction SilentlyContinue
    $sourcesProcessed = $sourceSummaries.Count
}

# Count quote files
$quotesCollected = 0
$quoteFiles = @()
if (Test-Path $QuotesPath) {
    $quoteFiles = Get-ChildItem -Path $QuotesPath -Filter "*_quotes.md" -ErrorAction SilentlyContinue
    $quotesCollected = $quoteFiles.Count
}

# Count tasks from todo.md - Using simpler pattern matching
$todoTotal = 0
$todoCompleted = 0
$todoHigh = 0
$todoMedium = 0
$todoLow = 0

if (Test-Path $TodoFile) {
    $todoContent = Get-Content $TodoFile -ErrorAction SilentlyContinue
    foreach ($line in $todoContent) {
        # Match using hex codes for emojis to avoid encoding issues
        if ($line -like "*`u{1F534}*") { $todoTotal++; $todoHigh++ }      # Red circle
        if ($line -like "*`u{1F7E1}*") { $todoTotal++; $todoMedium++ }   # Yellow circle
        if ($line -like "*`u{1F7E2}*") { $todoTotal++; $todoLow++ }      # Green circle
        if ($line -like "*`u{2705}*") { $todoCompleted++ }                # Check mark
    }
}

# Calculate percentages
$sourcesTarget = 15
$chaptersTarget = 10
$chaptersReady = 5

$sourceProgress = if ($sourcesTarget -gt 0) { [math]::Round(($sourcesProcessed / $sourcesTarget) * 100, 1) } else { 0 }
$chapterProgress = if ($chaptersTarget -gt 0) { [math]::Round(($chaptersReady / $chaptersTarget) * 100, 1) } else { 0 }
$todoProgress = if (($todoTotal + $todoCompleted) -gt 0) { [math]::Round(($todoCompleted / ($todoTotal + $todoCompleted)) * 100, 1) } else { 0 }

# Overall progress (weighted average)
$overallProgress = [math]::Round((($sourceProgress * 0.4) + ($chapterProgress * 0.4) + ($todoProgress * 0.2)), 1)

# Display statistics
Write-Host "Sources Processed: $sourcesProcessed / $sourcesTarget ($sourceProgress%)" -ForegroundColor Green
Write-Host "Chapters Ready: $chaptersReady / $chaptersTarget ($chapterProgress%)" -ForegroundColor Green
Write-Host "Tasks: $todoCompleted completed, $todoTotal active" -ForegroundColor Green
Write-Host "Overall Progress: $overallProgress%" -ForegroundColor Yellow

# ============================================================================
# Generate Dashboard Content
# ============================================================================

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$bar1Filled = [math]::Floor($overallProgress / 5)
$bar1Empty = 20 - $bar1Filled
$progressBar1 = ([string][char]0x2588) * $bar1Filled + ([string][char]0x2591) * $bar1Empty

$bar2Filled = [math]::Floor($sourceProgress / 5)
$bar2Empty = 20 - $bar2Filled
$progressBar2 = ([string][char]0x2588) * $bar2Filled + ([string][char]0x2591) * $bar2Empty

$bar3Filled = [math]::Floor($chapterProgress / 5)
$bar3Empty = 20 - $bar3Filled
$progressBar3 = ([string][char]0x2588) * $bar3Filled + ([string][char]0x2591) * $bar3Empty

$bar4Filled = [math]::Floor($todoProgress / 5)
$bar4Empty = 20 - $bar4Filled
$progressBar4 = ([string][char]0x2588) * $bar4Filled + ([string][char]0x2591) * $bar4Empty

$dashboardContent = @"
# PhD Dissertation Dashboard

**Last Updated:** $timestamp

---

## Overall Progress

### Completion Overview
``````
Overall Progress: $overallProgress%
[$progressBar1] $overallProgress%
``````

---

## Source Processing

**Processed:** $sourcesProcessed / $sourcesTarget sources ($sourceProgress%)

``````
[$progressBar2] $sourceProgress%
``````

### Sources Completed:
"@

# List processed sources
if ($sourcesProcessed -gt 0) {
    foreach ($file in $sourceSummaries) {
        $sourceName = $file.Name -replace "_summary\.md", "" -replace "_", " "
        $dashboardContent += "`n- $sourceName"
    }
} else {
    $dashboardContent += "`n- *(No sources processed yet)*"
}

$dashboardContent += @"


---

## Chapter Readiness

**Ready to Draft:** $chaptersReady / $chaptersTarget chapters ($chapterProgress%)

``````
[$progressBar3] $chapterProgress%
``````

### Chapter Status:
- Chapter 2: Literature Review (Ready)
- Chapter 3: Theoretical Framework (Ready)
- Chapter 4: Evolutionary Psychology (Ready)
- Chapter 8: Policy Analysis (Ready)
- Chapter 9: Conclusion (Ready)
- Chapter 5: Historical Analysis (Needs sources)
- Chapter 6: Contemporary Patterns (Needs sources)
- Chapter 7: Case Studies (Needs sources)
- Chapter 1: Introduction (Draft in progress)
- Chapter 10: Future Directions (Planning)

---

## Task Management

**Completed:** $todoCompleted tasks  
**Active:** $todoTotal tasks ($todoProgress% completion rate)

### Task Breakdown:
- High Priority: $todoHigh tasks
- Medium Priority: $todoMedium tasks
- Low Priority: $todoLow tasks

``````
[$progressBar4] $todoProgress%
``````

---

## Repository Stats

### File Counts:
- Summary Documents: $sourcesProcessed
- Quote Collections: $quotesCollected
- Active Tasks: $todoTotal
- Completed Tasks: $todoCompleted

### Recent Activity:
*(Last 5 Git commits)*

``````bash
# Run in terminal to see recent activity:
cd C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis
git log --oneline -5
``````

---

## Next Milestones

1. **Immediate:** Process Stone, Shackelford & Buss (2007)
2. **This Week:** Complete automation scripts (2-5)
3. **This Month:** Draft Chapter 2 (Literature Review)
4. **Quarter Goal:** Complete all 15 core sources

---

## Quick Links

- [ToDo List](todo.md)
- [Reading Notes](../notes/reading_notes/by_source/)
- [Quotes Database](../quotes/by_source/)
- [Research Journal](../research_journal/)
- [Project Scripts](scripts/)

---

*Dashboard auto-generated by update-dashboard.ps1*
*For manual updates, run: ``.\update-dashboard.ps1``*
"@

# ============================================================================
# Save Dashboard
# ============================================================================

try {
    $projectMgmtPath = Join-Path $RepoPath "project_management"
    if (-not (Test-Path $projectMgmtPath)) {
        New-Item -Path $projectMgmtPath -ItemType Directory -Force | Out-Null
    }

    Set-Content -Path $DashboardFile -Value $dashboardContent -Encoding UTF8
    Write-Host "`n" -NoNewline
    Write-Host "Dashboard updated successfully!" -ForegroundColor Green
    Write-Host "Location: $DashboardFile`n" -ForegroundColor Cyan
} catch {
    Write-Host "`n" -NoNewline
    Write-Host "Error creating dashboard: $_" -ForegroundColor Red
    exit 1
}

# ============================================================================
# Optional: Commit to Git
# ============================================================================

if ($Commit) {
    Write-Host "Committing dashboard update to Git..." -ForegroundColor Yellow
    
    Push-Location $RepoPath
    
    git add project_management/dashboard.md
    git commit -m "Update dashboard: $sourcesProcessed sources, $chapterProgress% chapters, $overallProgress% overall"
    
    Write-Host "Changes committed to Git" -ForegroundColor Green
    Write-Host "Run 'git push' to sync with remote`n" -ForegroundColor Cyan
    
    Pop-Location
}

Write-Host ("=" * 60) -ForegroundColor Gray
Write-Host "Dashboard update complete!`n" -ForegroundColor Green
