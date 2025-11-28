#Requires -Version 7.0
<#
.SYNOPSIS
    Comprehensive weekly dissertation update and sync tool

.DESCRIPTION
    Performs a complete weekly update cycle:
    1. Analyzes repository status (sources, chapters, quotes, etc.)
    2. Updates progress summary with current metrics
    3. Validates all file paths and links in SUMMARY.md
    4. Checks for common issues (naming, paths, git tracking)
    5. Commits and pushes all changes to GitHub
    6. Validates GitBook sync readiness
    7. Generates weekly report

.PARAMETER Preview
    Shows what changes will be made without applying them

.PARAMETER Apply
    Executes the full update and commits changes

.EXAMPLE
    .\Weekly_Dissertation_Update.ps1 -Preview
    Shows planned changes without executing

.EXAMPLE
    .\Weekly_Dissertation_Update.ps1 -Apply
    Performs full weekly update
#>

[CmdletBinding()]
param(
    [Parameter(ParameterSetName='Preview')]
    [switch]$Preview,
    
    [Parameter(ParameterSetName='Apply')]
    [switch]$Apply
)

# Color functions
function Write-Success { Write-Host $args -ForegroundColor Green }
function Write-Info { Write-Host $args -ForegroundColor Cyan }
function Write-Warning { Write-Host $args -ForegroundColor Yellow }
function Write-Error { Write-Host $args -ForegroundColor Red }
function Write-Section { 
    Write-Host "`n$('='*70)" -ForegroundColor Cyan
    Write-Host "  $args" -ForegroundColor Cyan
    Write-Host "$('='*70)`n" -ForegroundColor Cyan
}

Write-Host "`n" -NoNewline
Write-Host "══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Weekly Dissertation Update & Sync Tool" -ForegroundColor Cyan
Write-Host "══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

$startTime = Get-Date

# Check if in correct directory
if (-not (Test-Path "SUMMARY.md")) {
    Write-Error "ERROR: SUMMARY.md not found. Please run from repository root."
    exit 1
}

# ============================================================================
# PHASE 1: REPOSITORY ANALYSIS
# ============================================================================

Write-Section "PHASE 1: REPOSITORY ANALYSIS"

Write-Info "Analyzing dissertation repository status..."

# Count sources
$summaries = @(Get-ChildItem "notes/reading_notes/by_source" -Filter "*summary*.md" -ErrorAction SilentlyContinue)
$sourceCount = $summaries.Count
Write-Success "✓ Found $sourceCount research sources"

# Count comparative analyses
$analyses = @(Get-ChildItem "comparative-analyses" -Filter "*.md" -ErrorAction SilentlyContinue | Where-Object { $_.Name -ne "_Analyses_Overview.md" })
$analysisCount = $analyses.Count
Write-Success "✓ Found $analysisCount comparative analyses"

# Count quote files
$quoteFiles = @(Get-ChildItem "quotes" -Recurse -Filter "*.md" -ErrorAction SilentlyContinue)
$quoteCount = $quoteFiles.Count
Write-Success "✓ Found $quoteCount quote files"

# Check chapter status
$chapters = @(Get-ChildItem "chapters" -Recurse -Filter "chapter_*.md" -ErrorAction SilentlyContinue)
$chapterCount = $chapters.Count
Write-Success "✓ Found $chapterCount chapter drafts"

# Calculate word counts for chapters
$totalWords = 0
$chapterDetails = @()
foreach ($chapter in $chapters) {
    $content = Get-Content $chapter.FullName -Raw
    $words = ($content -split '\s+').Count
    $totalWords += $words
    $chapterDetails += [PSCustomObject]@{
        Chapter = $chapter.Name
        Words = $words
        Path = $chapter.FullName.Replace((Get-Location).Path + "\", "")
    }
}
Write-Success "✓ Total chapter word count: $totalWords words"

# Get recent git activity
$lastCommitDate = git log -1 --format=%cd --date=short
$commitsSinceLastWeek = @(git log --since="1 week ago" --oneline)
$commitCount = $commitsSinceLastWeek.Count
Write-Success "✓ $commitCount commits in the last week"
Write-Info "  Last commit: $lastCommitDate"

# Check for untracked files
$untrackedFiles = @(git status --porcelain | Where-Object { $_ -match '^\?\?' })
if ($untrackedFiles.Count -gt 0) {
    Write-Warning "⚠ $($untrackedFiles.Count) untracked files found"
} else {
    Write-Success "✓ No untracked files"
}

# Repository size
$repoSize = (Get-ChildItem -Recurse -File | Measure-Object -Property Length -Sum).Sum / 1MB
Write-Info "  Repository size: $([math]::Round($repoSize, 2)) MB"

# ============================================================================
# PHASE 2: VALIDATE SUMMARY.MD LINKS
# ============================================================================

Write-Section "PHASE 2: VALIDATE SUMMARY.MD LINKS"

Write-Info "Checking all links in SUMMARY.md..."

$summaryContent = Get-Content "SUMMARY.md" -Raw
$allLinks = [regex]::Matches($summaryContent, '\]\(([^\)]+\.md)\)')

$brokenLinks = @()
$validLinks = 0

foreach ($match in $allLinks) {
    $linkedPath = $match.Groups[1].Value
    if (-not (Test-Path $linkedPath)) {
        $brokenLinks += $linkedPath
    } else {
        $validLinks++
    }
}

Write-Success "✓ $validLinks valid links"
if ($brokenLinks.Count -gt 0) {
    Write-Warning "⚠ $($brokenLinks.Count) broken links found:"
    foreach ($broken in $brokenLinks) {
        Write-Host "    ✗ $broken" -ForegroundColor Red
    }
} else {
    Write-Success "✓ No broken links in SUMMARY.md"
}

# ============================================================================
# PHASE 3: GENERATE UPDATED PROGRESS SUMMARY
# ============================================================================

Write-Section "PHASE 3: GENERATE UPDATED PROGRESS SUMMARY"

Write-Info "Generating updated progress summary..."

$today = Get-Date
$todayFormatted = $today.ToString("MMMM dd, yyyy")
$todayShort = $today.ToString("yyyy-MM-dd")

# Calculate days since last update
$progressFile = "progress-summary/dissertation_progress_summary.md"
if (Test-Path $progressFile) {
    $lastUpdate = (Get-Item $progressFile).LastWriteTime
    $daysSinceUpdate = ($today - $lastUpdate).Days
    Write-Info "  Days since last update: $daysSinceUpdate"
}

# Create detailed chapter status
$chapterStatusTable = ""
for ($i = 1; $i -le 10; $i++) {
    $chapterFile = $chapterDetails | Where-Object { $_.Chapter -match "chapter_0?$i" } | Select-Object -First 1
    if ($chapterFile) {
        $status = "✅ DRAFT ($($chapterFile.Words) words)"
    } else {
        $status = "⏳ PLANNED"
    }
    $chapterStatusTable += "| Chapter $i | $status |`n"
}

# Get recent commits formatted
$recentCommitsFormatted = $commitsSinceLastWeek | Select-Object -First 10 | ForEach-Object { "  $_" }
$recentCommitsText = $recentCommitsFormatted -join "`n"

# Calculate completion percentage
$completionMetrics = @{
    SourcesTarget = 10
    SourcesActual = $sourceCount
    ChaptersTarget = 10
    ChaptersActual = $chapterCount
    WordsTarget = 80000
    WordsActual = $totalWords
}

$sourcesPct = [math]::Round(($completionMetrics.SourcesActual / $completionMetrics.SourcesTarget) * 100, 1)
$chaptersPct = [math]::Round(($completionMetrics.ChaptersActual / $completionMetrics.ChaptersTarget) * 100, 1)
$wordsPct = [math]::Round(($completionMetrics.WordsActual / $completionMetrics.WordsTarget) * 100, 1)
$overallPct = [math]::Round(($sourcesPct + $chaptersPct + $wordsPct) / 3, 1)

# Generate the complete progress summary
$progressSummary = @"
# Dissertation Progress Summary

**Last Updated:** $todayFormatted  
**Repository:** phd-sacred-bonds-thesis  
**Status:** Active Development  
**Overall Completion:** $overallPct%

---

## Quick Status Dashboard

| Metric | Progress | Target | Status |
|--------|----------|--------|--------|
| **Research Sources** | $sourceCount | $($completionMetrics.SourcesTarget) | $sourcesPct% ✅ |
| **Comparative Analyses** | $analysisCount | $($completionMetrics.SourcesTarget) | $([math]::Round(($analysisCount / $completionMetrics.SourcesTarget) * 100, 1))% |
| **Chapters Drafted** | $chapterCount | $($completionMetrics.ChaptersTarget) | $chaptersPct% |
| **Total Word Count** | $($totalWords.ToString('N0')) | $($completionMetrics.WordsTarget.ToString('N0')) | $wordsPct% |
| **Quote Files** | $quoteCount | - | ✅ |
| **Recent Commits (7 days)** | $commitCount | - | 📊 |

---

## Executive Summary

This dissertation examines the contemporary mating crisis through an integrative **Sacred Bonds framework**, combining evolutionary psychology, Jungian archetypal theory, transpersonal consciousness, and digital platform analysis.

**Current Phase:** Literature integration complete; framework established; chapter drafting in progress

**Key Milestone:** $sourceCount core sources fully integrated with comparative analyses and quotes

**Next Priority:** Complete remaining chapter drafts; integrate Jung and Wilber primary sources

---

## Research Integration Status

### Core Sources Integrated: $sourceCount

| Source | Year | Focus | Integration Status |
|--------|------|-------|-------------------|
| Firman & Larsen | 2011 | Sperm competition, evolutionary biology | ✅ Complete |
| Gangestad & Simpson | 2000 | Individual mating strategies | ✅ Complete |
| Buss | 2023 | Mate selection psychology | ✅ Complete |
| Bertrand et al. | 2023 | Economic factors, gender gaps | ✅ Complete |
| Larsen | 2023 | Polygyny, demographic collapse | ✅ Complete |
| Limar | 2011 | Sociological perspectives | ✅ Complete |
| Thompson | In press | Digital platforms, non-monogamy | ✅ Complete |

### Integration Components (Per Source)

For each source:
- ✅ Research Summary (comprehensive analysis)
- ✅ Quotes Database (organized by chapter/theme)
- ✅ Comparative Analysis (integration with other sources)
- ✅ Bibliography Entry (APA, Chicago, MLA)

**Total Integrated Content:** ~500 KB across $sourceCount sources

---

## Comparative Analyses

**Total Analyses:** $analysisCount complete

Each analysis includes:
- Points of convergence with other sources
- Points of divergence and theoretical tensions
- Multi-level integration framework
- Sacred Bonds framework mapping
- Chapter-specific usage guidance

**Average Length:** 20-40 KB per analysis  
**Total Analysis Content:** ~$([math]::Round(($analyses | Measure-Object -Property Length -Sum).Sum / 1KB, 0)) KB

---

## Quote Collections

**Total Quote Files:** $quoteCount

Organization:
- ✅ By source (individual databases)
- ✅ By chapter (dissertation structure)
- ✅ By theme (cross-cutting concepts)

**Priority System:**
- ⭐⭐⭐ Critical (essential arguments)
- ⭐⭐ Important (strong support)
- ⭐ Supplementary (context)

---

## Chapter Status

**Chapters Drafted:** $chapterCount / 10  
**Total Words:** $($totalWords.ToString('N0'))

$chapterStatusTable

### Chapter Details

"@

# Add individual chapter details if they exist
foreach ($chapter in $chapterDetails | Sort-Object Chapter) {
    $chapterNum = [regex]::Match($chapter.Chapter, '\d+').Value
    $progressSummary += @"

**Chapter $chapterNum:** $($chapter.Words.ToString('N0')) words
- Status: Draft in progress
- File: ``$($chapter.Path)``

"@
}

$progressSummary += @"

---

## Sacred Bonds Framework - Six Dimensions

| Dimension | Status | Primary Sources | Notes |
|-----------|--------|----------------|-------|
| **1. Evolutionary Foundations** | ✅ Strong | Firman & Larsen, Gangestad & Simpson, Buss | Biological mechanisms well-covered |
| **2. Archetypal Dimensions** | 🔄 Needs Primary | Jung CW 9 needed | Framework established; primary sources critical |
| **3. Synchronicity** | 🔄 Needs Primary | Jung CW 8 needed | Concept outlined; primary citation essential |
| **4. Transpersonal Consciousness** | 🔄 Needs Primary | Wilber needed | Dimension identified; grounding required |
| **5. Contemporary Crisis** | ✅ Strong | Thompson, Larsen, Bertrand | Digital, economic, demographic factors covered |
| **6. Integration & Synthesis** | ⏳ In Progress | Multi-source | Framework conceptualized; articulation ongoing |

---

## Recent Activity (Last 7 Days)

**Commits:** $commitCount

Recent updates:
``````
$recentCommitsText
``````

**Last Commit:** $lastCommitDate

---

## Critical Priorities

### PRIORITY 1: Primary Source Acquisition ⭐⭐⭐ URGENT

**Missing Essential Sources:**

1. **Jung, C.G. (1960). *Structure and Dynamics of the Psyche* (CW 8)**
   - Critical for: Synchronicity dimension
   - Cost: ~\$50
   - Status: URGENT - order immediately

2. **Jung, C.G. (1959). *Archetypes and the Collective Unconscious* (CW 9)**
   - Critical for: Archetypal dimension
   - Cost: ~\$50
   - Status: URGENT - order immediately

3. **Wilber, K. (2000). *Integral Psychology***
   - Critical for: Transpersonal dimension
   - Cost: ~\$25
   - Status: URGENT - order immediately

**Total Budget Needed:** ~\$125

### PRIORITY 2: Chapter Completion

**Immediate Drafting Targets:**
- Chapter 2: Theoretical Framework (needs Jung/Wilber integration)
- Chapter 3: Evolutionary Foundations (sources ready)
- Chapter 4: Digital Platforms (Thompson analysis ready)

**Timeline:** Next 2 months

### PRIORITY 3: Framework Integration

- Integrate Jung primary sources throughout existing drafts
- Add Wilber transpersonal framework to Chapter 2
- Strengthen archetypal analysis with primary citations

---

## Metrics and Statistics

### Content Volume

| Category | Count | Approximate Size |
|----------|-------|-----------------|
| Research Sources | $sourceCount | ~60 KB each |
| Comparative Analyses | $analysisCount | ~30 KB each |
| Quote Files | $quoteCount | Variable |
| Chapter Drafts | $chapterCount | $totalWords words total |
| Total Repository | - | $([math]::Round($repoSize, 2)) MB |

### Discipline Coverage

- ✅ Evolutionary Biology: Firman & Larsen
- ✅ Evolutionary Psychology: Gangestad & Simpson, Buss
- ✅ Economics/Demography: Bertrand et al., Larsen
- ✅ Sociology: Limar
- ✅ Digital/Cultural Studies: Thompson
- 🔄 Jungian Psychology: Needs primary sources
- 🔄 Transpersonal Psychology: Needs primary sources
- 🔄 Neuroscience: Planned additions

---

## Timeline and Milestones

### Immediate (Next 2 Weeks)
- [ ] Order Jung CW 8 & 9, Wilber *Integral Psychology*
- [ ] Begin reading Jung primary sources
- [ ] Draft Chapter 2 outline with all six dimensions

### Short-Term (Next 2 Months)
- [ ] Complete Jung/Wilber reading and integration
- [ ] Draft Chapters 2-4
- [ ] Acquire remaining Priority 2 sources

### Medium-Term (4-6 Months)
- [ ] Complete all chapter drafts
- [ ] Comprehensive revision pass
- [ ] Committee review cycle 1

### Long-Term (6-12 Months)
- [ ] Final revisions
- [ ] Defense preparation
- [ ] Dissertation defense

---

## GitBook Structure

### Current Organization

``````
📚 Sacred Bonds Thesis
├── 📖 Dissertation Chapters ($chapterCount drafted)
├── 📚 Research Sources
│   ├── Primary Sources ($sourceCount sources)
│   └── Comparative Analyses ($analysisCount analyses)
├── 💬 Quotes ($quoteCount files)
├── 📓 Research Journal
├── 📋 Research Materials
│   └── Future Research Directions
└── 📚 Bibliography
``````

---

## Post-Doctoral Research Directions

**Status:** Comprehensive planning complete

### Identified Programs (6 major directions)
1. Platform Design Interventions (NSF, \$50-80K/year)
2. Therapeutic Interventions (NIH, Fetzer, \$50-75K/year)
3. Community-Based Alternative Models (NSF)
4. Neuroscience of Archetypal Experiences (NIH)
5. Cultural Evolution of Mating Norms (NSF, ERC)
6. Big Data Analysis of Dating Apps (Industry partnerships)

**Total Funding Potential:** \$50K-\$1.5M over 2-5 years

---

## Next Actions (Prioritized)

### This Week
1. ✅ Weekly progress summary updated
2. ⏰ Order Jung CW 8 & 9 (\$100)
3. ⏰ Order Wilber *Integral Psychology* (\$25)
4. 📖 Begin reading Jung CW 8

### This Month
1. 📖 Complete Jung CW 8 & 9 reading
2. 📝 Draft Chapter 2: Theoretical Framework
3. 🔄 Integrate Jungian citations into existing drafts

### Next 2 Months
1. 📝 Draft Chapter 3: Evolutionary Foundations
2. 📝 Draft Chapter 4: Digital Platforms
3. 📋 Outline Chapters 5-10

---

## Known Issues

"@

if ($brokenLinks.Count -gt 0) {
    $progressSummary += "`n### Broken Links in SUMMARY.md`n`n"
    foreach ($link in $brokenLinks) {
        $progressSummary += "- ✗ $link`n"
    }
    $progressSummary += "`n**Action Required:** Fix broken links before next GitBook sync`n"
}

if ($untrackedFiles.Count -gt 0) {
    $progressSummary += "`n### Untracked Files`n`n"
    $progressSummary += "$($untrackedFiles.Count) files not tracked in git. Review and add if needed.`n"
}

$progressSummary += @"

---

## Revision History

| Date | Update | Changes |
|------|--------|---------|
| $todayFormatted | Weekly auto-update | Sources: $sourceCount, Analyses: $analysisCount, Chapters: $chapterCount, Words: $totalWords |

---

**Last Updated:** $todayFormatted  
**Generated By:** Weekly Dissertation Update Script  
**Next Update:** $(($today.AddDays(7)).ToString('MMMM dd, yyyy'))

---

*This progress summary is automatically updated weekly to reflect current repository status.*
"@

Write-Success "✓ Progress summary generated ($($progressSummary.Length) characters)"

# ============================================================================
# PHASE 4: VALIDATE AND FIX SUMMARY.MD PATHS
# ============================================================================

Write-Section "PHASE 4: VALIDATE AND FIX SUMMARY.MD PATHS"

Write-Info "Checking for common path issues in SUMMARY.md..."

$summaryMd = Get-Content "SUMMARY.md" -Raw
$issuesFixed = 0

# Check for progress summary link pointing to wrong location
if ($summaryMd -match 'project_management/dissertation_progress_summary') {
    Write-Warning "⚠ Found incorrect progress summary path"
    $summaryMd = $summaryMd -replace 'project_management/dissertation_progress_summary\.md', 'progress-summary/dissertation_progress_summary.md'
    $issuesFixed++
    Write-Success "  ✓ Fixed: Changed project_management to progress-summary"
}

# Remove dates from progress summary links for easier maintenance
if ($summaryMd -match 'dissertation_progress_summary_\d{4}_\d{2}_\d{2}') {
    Write-Warning "⚠ Found dated progress summary filename"
    $summaryMd = $summaryMd -replace 'dissertation_progress_summary_\d{4}_\d{2}_\d{2}\.md', 'dissertation_progress_summary.md'
    $issuesFixed++
    Write-Success "  ✓ Fixed: Removed date from filename"
}

# Check for double parentheses (broken links)
$doubleParens = [regex]::Matches($summaryMd, '\([^\)]+\)\)')
if ($doubleParens.Count -gt 0) {
    Write-Warning "⚠ Found $($doubleParens.Count) double parenthesis issues"
    $summaryMd = $summaryMd -replace '\.md\)\)', '.md)'
    $issuesFixed++
    Write-Success "  ✓ Fixed: Removed extra parentheses"
}

if ($issuesFixed -eq 0) {
    Write-Success "✓ No path issues found in SUMMARY.md"
} else {
    Write-Success "✓ Fixed $issuesFixed issues in SUMMARY.md"
}

# ============================================================================
# PHASE 5: PREVIEW OR APPLY CHANGES
# ============================================================================

Write-Section "PHASE 5: APPLY CHANGES"

if ($Preview) {
    Write-Info "[PREVIEW MODE] - Changes that would be made:`n"
    
    Write-Host "1. Progress Summary Update:" -ForegroundColor Cyan
    Write-Host "   File: progress-summary/dissertation_progress_summary.md" -ForegroundColor White
    Write-Host "   Size: $($progressSummary.Length) bytes" -ForegroundColor White
    Write-Host "   Metrics: $sourceCount sources, $analysisCount analyses, $chapterCount chapters" -ForegroundColor White
    Write-Host ""
    
    if ($issuesFixed -gt 0) {
        Write-Host "2. SUMMARY.md Fixes:" -ForegroundColor Cyan
        Write-Host "   Issues fixed: $issuesFixed" -ForegroundColor White
        Write-Host ""
    }
    
    if ($brokenLinks.Count -gt 0) {
        Write-Host "3. Broken Links Identified:" -ForegroundColor Cyan
        Write-Host "   Count: $($brokenLinks.Count)" -ForegroundColor White
        Write-Host "   (Manual review required)" -ForegroundColor Yellow
        Write-Host ""
    }
    
    Write-Host "4. Git Operations:" -ForegroundColor Cyan
    Write-Host "   - Stage progress-summary/dissertation_progress_summary.md" -ForegroundColor White
    Write-Host "   - Stage SUMMARY.md (if modified)" -ForegroundColor White
    Write-Host "   - Commit with descriptive message" -ForegroundColor White
    Write-Host "   - Push to origin main" -ForegroundColor White
    Write-Host ""
    
    Write-Success "`n✓ Preview complete. Run with -Apply to execute changes."
    exit 0
}

if (-not $Apply) {
    Write-Warning "`nNo action specified. Use -Preview or -Apply parameter."
    Write-Host "  Example: .\Weekly_Dissertation_Update.ps1 -Apply" -ForegroundColor White
    exit 0
}

# ============================================================================
# APPLY MODE - Execute changes
# ============================================================================

Write-Info "[APPLY MODE] - Executing weekly update...`n"

# Create progress-summary directory if needed
if (-not (Test-Path "progress-summary")) {
    New-Item -ItemType Directory -Path "progress-summary" -Force | Out-Null
    Write-Success "✓ Created progress-summary directory"
}

# Write updated progress summary
Set-Content "progress-summary/dissertation_progress_summary.md" -Value $progressSummary -NoNewline
Write-Success "✓ Progress summary updated"

# Write updated SUMMARY.md if changes were made
if ($issuesFixed -gt 0) {
    Set-Content "SUMMARY.md" -Value $summaryMd -NoNewline
    Write-Success "✓ SUMMARY.md updated ($issuesFixed fixes applied)"
}

# Git operations
Write-Info "`nCommitting changes to git..."

git add "progress-summary/dissertation_progress_summary.md"
if ($issuesFixed -gt 0) {
    git add "SUMMARY.md"
}

$commitMessage = @"
Weekly dissertation update - $todayFormatted

Automated weekly update:
- Progress summary updated with current metrics
- Sources: $sourceCount (comparative analyses: $analysisCount)
- Chapters: $chapterCount drafted ($totalWords words total)
- Quotes: $quoteCount files organized
- Recent activity: $commitCount commits in last 7 days
$(if ($issuesFixed -gt 0) { "- Fixed $issuesFixed SUMMARY.md issues" } else { "" })
$(if ($brokenLinks.Count -gt 0) { "- Identified $($brokenLinks.Count) broken links for review" } else { "" })

Overall completion: $overallPct%
Next priorities: Jung/Wilber acquisition, Chapter 2-4 drafts
"@

git commit -m $commitMessage | Out-Null

if ($LASTEXITCODE -eq 0) {
    Write-Success "✓ Changes committed"
    
    # Push to GitHub
    Write-Info "`nPushing to GitHub..."
    $pushResult = git push origin main 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "✓ Successfully pushed to GitHub!"
    } else {
        if ($pushResult -match "Everything up-to-date") {
            Write-Success "✓ Repository already up to date"
        } else {
            Write-Warning "⚠ Push had issues:"
            Write-Host $pushResult
        }
    }
} else {
    Write-Warning "⚠ No changes to commit (already up to date)"
}

# ============================================================================
# PHASE 6: POST-UPDATE VALIDATION
# ============================================================================

Write-Section "PHASE 6: POST-UPDATE VALIDATION"

Write-Info "Validating update..."

# Verify progress summary exists and has content
if (Test-Path "progress-summary/dissertation_progress_summary.md") {
    $size = (Get-Item "progress-summary/dissertation_progress_summary.md").Length / 1KB
    Write-Success "✓ Progress summary exists ($([math]::Round($size, 1)) KB)"
} else {
    Write-Error "✗ Progress summary file not found!"
}

# Verify SUMMARY.md links are correct
$summaryCheck = Get-Content "SUMMARY.md" -Raw
if ($summaryCheck -match 'progress-summary/dissertation_progress_summary\.md') {
    Write-Success "✓ SUMMARY.md links to correct progress summary location"
} else {
    Write-Warning "⚠ SUMMARY.md may not link to progress summary correctly"
}

# Check git status
$gitStatus = git status --short
if (-not $gitStatus) {
    Write-Success "✓ No uncommitted changes remaining"
} else {
    Write-Warning "⚠ Uncommitted changes present:"
    $gitStatus | ForEach-Object { Write-Host "  $_" -ForegroundColor Yellow }
}

# Check sync with remote
git fetch origin --quiet
$syncStatus = git status -uno
if ($syncStatus -match "Your branch is up to date") {
    Write-Success "✓ Local and remote branches in sync"
} elseif ($syncStatus -match "behind") {
    Write-Warning "⚠ Local branch behind remote - pull needed"
} elseif ($syncStatus -match "ahead") {
    Write-Warning "⚠ Local branch ahead of remote - push needed"
}

# ============================================================================
# FINAL REPORT
# ============================================================================

Write-Section "WEEKLY UPDATE COMPLETE"

$endTime = Get-Date
$duration = ($endTime - $startTime).TotalSeconds

Write-Host "Update Summary:" -ForegroundColor Cyan
Write-Host "  • Progress summary updated: ✅" -ForegroundColor White
Write-Host "  • Current metrics: $sourceCount sources, $analysisCount analyses, $chapterCount chapters" -ForegroundColor White
Write-Host "  • Total words: $($totalWords.ToString('N0'))" -ForegroundColor White
Write-Host "  • Overall completion: $overallPct%" -ForegroundColor White
Write-Host "  • SUMMARY.md issues fixed: $issuesFixed" -ForegroundColor White
Write-Host "  • Recent commits (7 days): $commitCount" -ForegroundColor White
Write-Host "  • Duration: $([math]::Round($duration, 2)) seconds" -ForegroundColor White
Write-Host ""

if ($brokenLinks.Count -gt 0) {
    Write-Warning "⚠ Action Required: $($brokenLinks.Count) broken links need manual review"
    Write-Host ""
}

Write-Info "GitBook Sync:"
Write-Host "  Wait 2-3 minutes for GitBook to sync with GitHub" -ForegroundColor White
Write-Host "  Check: https://app.gitbook.com/o/cyZpWhV7KomErB6BnmVk/s/hRoSpCiTUrfuH62swMvH/" -ForegroundColor White
Write-Host ""

Write-Info "Next Steps:"
Write-Host "  1. ⏰ Verify progress summary displays in GitBook" -ForegroundColor White
Write-Host "  2. 📚 Order Jung CW 8 & 9, Wilber Integral Psychology (\$125)" -ForegroundColor White
Write-Host "  3. 📝 Continue chapter drafting (Chapters 2-4 priority)" -ForegroundColor White
Write-Host "  4. 🔄 Run this script again next week" -ForegroundColor White
Write-Host ""

Write-Success "✓ Weekly update completed successfully!"
Write-Host ""
Write-Info "Run this script weekly to maintain up-to-date progress tracking."
Write-Host ""
