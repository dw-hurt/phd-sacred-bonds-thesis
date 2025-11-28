#Requires -Version 7.0
<#
.SYNOPSIS
    Extracts current progress summary and creates updated version

.DESCRIPTION
    1. Finds the existing progress summary in the repository
    2. Analyzes current dissertation status
    3. Generates updated progress summary with current date
    4. Replaces the old summary file
    5. Commits and pushes to GitHub

.EXAMPLE
    .\Extract_And_Update_Progress_Summary.ps1
#>

Write-Host "`n═══════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Dissertation Progress Summary Updater" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════`n" -ForegroundColor Cyan

# Check if in correct directory
if (-not (Test-Path "SUMMARY.md")) {
    Write-Host "ERROR: SUMMARY.md not found. Please run from repository root." -ForegroundColor Red
    exit 1
}

# Find existing progress summary file
Write-Host "Step 1: Locating existing progress summary..." -ForegroundColor Yellow

$possiblePaths = @(
    "progress-summary/dissertation_progress_summary_2025_11_23.md"
    "progress_summary/dissertation_progress_summary_2025_11_23.md"
    "progress-summary/dissertation_progress_summary.md"
)

$existingSummary = $null
foreach ($path in $possiblePaths) {
    if (Test-Path $path) {
        $existingSummary = $path
        Write-Host "✓ Found existing summary: $existingSummary" -ForegroundColor Green
        break
    }
}

if (-not $existingSummary) {
    # Try to find any progress summary file
    $found = Get-ChildItem -Recurse -Filter "*progress*summary*.md" -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($found) {
        $existingSummary = $found.FullName.Replace((Get-Location).Path + "\", "")
        Write-Host "✓ Found summary at: $existingSummary" -ForegroundColor Green
    } else {
        Write-Host "⚠ No existing progress summary found. Will create new one." -ForegroundColor Yellow
        $existingSummary = "progress-summary/dissertation_progress_summary.md"
    }
}

# Read existing summary if it exists
$oldContent = ""
if (Test-Path $existingSummary) {
    $oldContent = Get-Content $existingSummary -Raw
    $oldSize = (Get-Item $existingSummary).Length / 1KB
    Write-Host "  Old summary size: $([math]::Round($oldSize, 1)) KB" -ForegroundColor Cyan
}

# Analyze current repository state
Write-Host "`nStep 2: Analyzing current dissertation status..." -ForegroundColor Yellow

# Count sources
$summaries = @(Get-ChildItem "notes/reading_notes/by_source" -Filter "*summary*.md" -ErrorAction SilentlyContinue)
$sourceCount = $summaries.Count
Write-Host "  Sources integrated: $sourceCount" -ForegroundColor Cyan

# Count comparative analyses
$analyses = @(Get-ChildItem "comparative-analyses" -Filter "*.md" -ErrorAction SilentlyContinue | Where-Object { $_.Name -ne "_Analyses_Overview.md" })
$analysisCount = $analyses.Count
Write-Host "  Comparative analyses: $analysisCount" -ForegroundColor Cyan

# Count quote files
$quoteFiles = @(Get-ChildItem "quotes" -Recurse -Filter "*.md" -ErrorAction SilentlyContinue)
$quoteCount = $quoteFiles.Count
Write-Host "  Quote files: $quoteCount" -ForegroundColor Cyan

# Check chapter status
$chapters = @(Get-ChildItem "chapters" -Recurse -Filter "chapter_*.md" -ErrorAction SilentlyContinue)
$chapterCount = $chapters.Count
Write-Host "  Chapters drafted: $chapterCount" -ForegroundColor Cyan

# Get recent commits
$recentCommits = git log --oneline -10
$lastCommitDate = git log -1 --format=%cd --date=short

Write-Host "  Last commit: $lastCommitDate" -ForegroundColor Cyan

# Generate updated progress summary
Write-Host "`nStep 3: Generating updated progress summary..." -ForegroundColor Yellow

$today = Get-Date -Format "yyyy-MM-dd"
$todayFormatted = Get-Date -Format "MMMM dd, yyyy"

$newSummary = @"
# Dissertation Progress Summary

**Last Updated:** $todayFormatted  
**Repository:** phd-sacred-bonds-thesis  
**Status:** Active Development

---

## Executive Summary

This document tracks the comprehensive progress of the PhD dissertation: *"The Contemporary Mating Crisis and the Sacred Bonds Framework: An Integrative Analysis."*

**Current Status:**
- **Research Phase:** Literature integration complete
- **Writing Phase:** Chapter 1 drafted, framework established
- **Sources Integrated:** $sourceCount core sources with full analysis
- **Next Milestone:** Complete remaining chapter drafts

---

## Research Integration Status

### Core Sources (Fully Integrated)

Total Sources: **$sourceCount**

| Source | Year | Focus | Status |
|--------|------|-------|--------|
| **Firman & Larsen** | 2011 | Sperm competition, evolutionary biology | ✅ Complete |
| **Gangestad & Simpson** | 2000 | Individual mating strategies | ✅ Complete |
| **Buss** | 2023 | Mate selection, sexual strategies | ✅ Complete |
| **Bertrand et al.** | 2023 | Economic factors, gender gaps | ✅ Complete |
| **Larsen** | 2023 | Polygyny, demographic collapse | ✅ Complete |
| **Limar** | 2011 | Sociological perspectives | ✅ Complete |
| **Thompson** | In press | Digital platforms, non-monogamy | ✅ Complete |

### Integration Components

For each source, the following materials have been created:

✅ **Research Summary** (comprehensive analysis)  
✅ **Quotes Database** (organized by chapter and theme)  
✅ **Comparative Analysis** (integration with other sources)  
✅ **Bibliography Entry** (APA, Chicago, MLA formats)

**Total Research Content:** ~500 KB of systematically organized material

---

## Comparative Analyses

**Total Analyses:** $analysisCount

Each comparative analysis includes:
- Points of convergence with other sources
- Points of divergence and tensions
- Multi-level integration framework
- Sacred Bonds framework mapping
- Chapter-specific usage guidance

**Average Analysis Length:** 20-40 KB per source

---

## Quote Collections

**Total Quote Files:** $quoteCount

Quote organization:
- ✅ By source (individual source quote databases)
- ✅ By chapter (quotes relevant to each dissertation chapter)
- ✅ By theme (thematic groupings across sources)

**Priority Ratings:**
- ⭐⭐⭐ Critical quotes (essential for main arguments)
- ⭐⭐ Important quotes (strong supporting evidence)
- ⭐ Supplementary quotes (additional context)

---

## Chapter Status

**Chapters Drafted:** $chapterCount / 10

### Chapter 1: Introduction ✅ COMPLETE
- **Status:** First draft complete (7,500 words)
- **Content:** 
  - Establishes contemporary mating crisis
  - Introduces Sacred Bonds framework (6 dimensions)
  - Integrates all 7 core sources
  - Full citation and quote integration
- **Next Steps:** Revise after completing other chapters

### Chapter 2: Theoretical Framework 🔄 IN PROGRESS
- **Status:** Framework established, needs primary source grounding
- **Priority:** Add Jung CW 8 & 9, Wilber *Integral Psychology*
- **Components:**
  - Evolutionary foundations dimension
  - Archetypal dimensions (Jung)
  - Transpersonal consciousness (Wilber, Grof)
  - Synchronicity (Jung CW 8)
  - Contemporary crisis manifestations
  - Integration and synthesis

### Chapter 3: Evolutionary Foundations ⏳ PLANNED
- **Primary Sources:** Firman & Larsen, Gangestad & Simpson, Buss
- **Focus:** Biological mechanisms of mating strategies
- **Status:** Sources integrated, ready for drafting

### Chapter 4: Digital Platforms and Technology ⏳ PLANNED
- **Primary Sources:** Thompson, Larsen
- **Focus:** How technology mediates contemporary mate selection
- **Status:** Thompson just integrated, ready for drafting

### Chapter 5-6: [To be defined] ⏳ PLANNED

### Chapter 7: Alternative Relationship Structures ⏳ PLANNED
- **Primary Sources:** Thompson, Limar, CNM literature
- **Focus:** Non-monogamous alternatives to crisis
- **Status:** Thompson integrated, CNM sources identified

### Chapter 8-9: [To be defined] ⏳ PLANNED

### Chapter 10: Integration and Synthesis ⏳ PLANNED
- **Focus:** Sacred Bonds framework as solution path
- **Status:** Framework established, needs full articulation

---

## Sacred Bonds Framework - Six Dimensions

### 1. Evolutionary Foundations ✅
- Biological basis of mating strategies
- Cross-cultural patterns
- **Sources:** Firman & Larsen, Gangestad & Simpson, Buss, Chapais

### 2. Archetypal Dimensions 🔄
- Jungian archetypes in relationships (Anima/Animus, Self, Shadow)
- Individuation through intimate relationships
- **Needs:** Jung CW 9 (primary source acquisition critical)

### 3. Synchronicity 🔄
- Meaningful coincidences in mate selection
- Acausal connecting principle
- **Needs:** Jung CW 8 (primary source acquisition critical)

### 4. Transpersonal Consciousness 🔄
- Expanded states in intimate bonding
- Spiritual dimensions of relationship
- **Needs:** Wilber *Integral Psychology* (primary source acquisition critical)

### 5. Contemporary Crisis Manifestations ✅
- Digital mediation (Thompson)
- Economic factors (Bertrand)
- Demographic collapse (Larsen)
- Authenticity challenges

### 6. Integration and Synthesis ⏳
- Multi-level intervention framework
- Platform design, therapy, cultural transformation
- **Status:** Conceptual framework established

---

## Recent Progress (Last 30 Days)

### Major Accomplishments

**Thompson Source Integration** (November 27-28, 2024)
- ✅ Complete research summary (12 KB)
- ✅ Quotes database (19 KB, 18 key quotes)
- ✅ Comparative analysis (23 KB)
- ✅ Bibliography entry (APA, Chicago, MLA)
- ✅ Added to Primary Sources and Comparative Analyses sections
- ✅ Updated Chapter 1 quotes with Thompson excerpts

**Future Research Directions** (November 28, 2024)
- ✅ Comprehensive gap analysis of 7 core sources
- ✅ 60+ recommended sources identified and prioritized
- ✅ Post-doctoral research directions mapped
- ✅ Funding opportunities identified (\$50K-\$1.5M)
- ✅ Timeline and budget for resource acquisition

**Chapter 1 Development**
- ✅ Expanded from outline to 7,500-word draft
- ✅ Integrated quotes from all 7 sources
- ✅ Established six-dimensional Sacred Bonds framework
- ✅ Complete academic structure with citations

### Git Activity

**Recent Commits:**
``````
$($recentCommits -join "`n")
``````

**Last Update:** $lastCommitDate

---

## Critical Gaps and Priorities

### PRIORITY 1: Primary Source Acquisition (URGENT) ⭐⭐⭐

**Why Critical:** Your Sacred Bonds framework explicitly references Jungian and transpersonal concepts, but you currently cite these through secondary sources or lack citations entirely.

#### Immediate Acquisitions Needed:

**1. Jung, C.G. (1960). *The Structure and Dynamics of the Psyche* (CW 8)**
- **Critical for:** Synchronicity dimension (core framework component)
- **Cost:** ~\$50
- **Timeline:** Order this week
- **Impact:** HIGH - primary source for major framework dimension

**2. Jung, C.G. (1959). *The Archetypes and the Collective Unconscious* (CW 9)**
- **Critical for:** Archetypal dimension (Anima/Animus, Self, Shadow)
- **Cost:** ~\$50
- **Timeline:** Order this week
- **Impact:** HIGH - primary source for major framework dimension

**3. Wilber, K. (2000). *Integral Psychology***
- **Critical for:** Transpersonal consciousness dimension
- **Cost:** ~\$25
- **Timeline:** Order this week
- **Impact:** HIGH - establishes transpersonal framework credibility

**Total Priority 1 Budget:** ~\$125

### PRIORITY 2: Strengthen Existing Arguments ⭐⭐

**4. Fisher, H.E., Aron, A., & Brown, L.L. (2006). "Romantic Love: A Mammalian Brain System"**
- **For:** Neuroscience foundation, biological validation
- **Cost:** Free (journal access)
- **Timeline:** Download this week

**5. Hazan, C., & Shaver, P. (1987). "Romantic Love as Attachment Process"**
- **For:** Attachment theory in adult relationships
- **Cost:** Free (journal access)
- **Timeline:** Download this week

**6. Chapais, B. (2008). *Primeval Kinship***
- **For:** Direct citation vs. via Thompson
- **Cost:** ~\$50
- **Timeline:** Next month

### PRIORITY 3: Chapter-Specific Strengthening ⭐

See Future Research Directions document for complete prioritized list (60+ sources).

---

## Timeline and Milestones

### Immediate (Next 2 Weeks)

- [ ] Order Jung CW 8 & 9, Wilber *Integral Psychology*
- [ ] Download Fisher et al., Hazan & Shaver papers
- [ ] Begin reading Jung CW 8 (synchronicity)
- [ ] Create Chapter 2 outline with framework dimensions

### Short-Term (Next 2 Months)

- [ ] Complete reading Jung primary sources
- [ ] Integrate Jungian citations throughout dissertation
- [ ] Add Wilber transpersonal framework to Chapter 2
- [ ] Draft Chapter 2: Theoretical Framework
- [ ] Draft Chapter 3: Evolutionary Foundations

### Medium-Term (Next 4 Months)

- [ ] Draft Chapter 4: Digital Platforms
- [ ] Draft Chapter 7: Alternative Relationship Structures
- [ ] Complete all remaining chapter outlines
- [ ] Acquire remaining Priority 2 sources

### Long-Term (6+ Months to Defense)

- [ ] Complete all chapter drafts
- [ ] Comprehensive revision and integration
- [ ] Committee review and feedback
- [ ] Final revisions
- [ ] Defense preparation

---

## GitBook Structure

### Current Organization

``````
📚 Sacred Bonds Thesis
├── 📖 Dissertation Chapters
│   ├── Chapter 1: Introduction ✅
│   ├── Chapter 2-10: [In planning]
├── 📚 Research Sources
│   ├── Primary Sources (7 sources) ✅
│   │   ├── Firman & Larsen
│   │   ├── Gangestad & Simpson
│   │   ├── Buss
│   │   ├── Bertrand et al.
│   │   ├── Larsen
│   │   ├── Limar
│   │   └── Thompson ✅ NEW
│   └── Comparative Analyses (7 analyses) ✅
├── 💬 Quotes
│   ├── By Source (7+ databases) ✅
│   ├── By Chapter ✅
│   └── By Theme ✅
├── 📓 Research Journal
│   └── Various research notes
├── 📋 Research Materials
│   └── Future Research Directions ✅ NEW
└── 📚 Bibliography ✅
``````

**Total Repository Size:** ~2 MB of research materials

---

## Metrics and Statistics

### Content Volume

| Category | Count | Total Size |
|----------|-------|------------|
| Core Sources | $sourceCount | ~500 KB |
| Comparative Analyses | $analysisCount | ~200 KB |
| Quote Databases | $quoteCount files | ~150 KB |
| Chapter Drafts | $chapterCount | ~50 KB |
| Research Materials | Multiple | ~100 KB |
| **Total Content** | **~100 files** | **~1 MB** |

### Source Coverage by Discipline

- **Evolutionary Biology:** Firman & Larsen ✅
- **Evolutionary Psychology:** Gangestad & Simpson, Buss ✅
- **Economics/Demography:** Bertrand et al., Larsen ✅
- **Sociology:** Limar ✅
- **Digital/Cultural Studies:** Thompson ✅
- **Jungian Psychology:** 🔄 NEEDS PRIMARY SOURCES
- **Transpersonal Psychology:** 🔄 NEEDS PRIMARY SOURCES
- **Neuroscience:** 🔄 NEEDS ADDITION

### Framework Dimension Coverage

| Dimension | Sources | Status |
|-----------|---------|--------|
| Evolutionary Foundations | 3 sources | ✅ Strong |
| Archetypal Dimensions | 0 primary | 🔄 CRITICAL GAP |
| Synchronicity | 0 primary | 🔄 CRITICAL GAP |
| Transpersonal Consciousness | 0 primary | 🔄 CRITICAL GAP |
| Contemporary Crisis | 4 sources | ✅ Strong |
| Integration & Synthesis | Framework only | ⏳ In Development |

---

## Post-Doctoral Research Directions

**Status:** Comprehensive planning document created

### Identified Research Programs (6 major directions)

1. **Platform Design Interventions**
   - Experimental platform development
   - Funding target: NSF Cyber-Human Systems

2. **Therapeutic Interventions**
   - Jungian/transpersonal therapy for mating crisis
   - Funding target: NIH, Fetzer Institute

3. **Community-Based Alternative Models**
   - Ethnography of intentional communities
   - Funding target: NSF Cultural Anthropology

4. **Neuroscience of Archetypal Experiences**
   - fMRI of archetypal patterns
   - Funding target: NIH, Brain & Behavior Foundation

5. **Cultural Evolution of Mating Norms**
   - Agent-based modeling, historical analysis
   - Funding target: NSF, ERC

6. **Big Data Analysis of Dating Apps**
   - Machine learning on user interactions
   - Funding target: Platform partnerships

**Total Funding Potential:** \$50K-\$1.5M over 2-5 years

### Target Institutions

- Institute of Noetic Sciences (transpersonal)
- Max Planck Institute (cultural evolution, neuroscience)
- Cornell Tech (digital platforms)
- UBC (Joe Henrich - cultural evolution)

---

## Collaboration and Support

### Committee Status

[To be updated with committee member feedback and guidance]

### Peer Support

[To be updated with writing group progress and peer review]

### Funding

**Dissertation Phase:**
- University funding: [Status]
- External grants: [Status]

**Post-Doctoral Phase:**
- Target agencies: NSF, NIH, Fetzer Institute, ERC
- Application timeline: Year before completion

---

## Known Issues and Challenges

### Technical Challenges

**GitBook Sync Issues:**
- Resolved: Comparative analyses now displaying correctly
- Resolved: Thompson integration complete
- Solution: Proper SUMMARY.md structure and file naming conventions

### Content Challenges

**Critical Gap - Primary Sources:**
- Issue: Framework references Jungian/transpersonal concepts without primary sources
- Priority: URGENT - acquisition within 2 weeks
- Budget: ~\$125 for essential texts
- Timeline: Read and integrate within 2 months

**Chapter Structure:**
- Issue: Chapters 5-6, 8-9 not yet defined
- Priority: MEDIUM - outline needed
- Timeline: Next 2 months

---

## Success Metrics

### Completion Criteria

**Phase 1: Literature Foundation (Current)**
- ✅ 7+ core sources fully integrated
- ✅ Comparative analyses complete
- ✅ Quote databases organized
- 🔄 Primary Jungian/transpersonal sources acquired (IN PROGRESS)

**Phase 2: Framework Development**
- ✅ Six-dimensional framework established
- 🔄 Primary source grounding (IN PROGRESS)
- ⏳ Theoretical chapter drafted

**Phase 3: Chapter Completion**
- ✅ Chapter 1 draft complete
- ⏳ Remaining 9 chapters to draft
- ⏳ Comprehensive revision

**Phase 4: Defense Preparation**
- ⏳ Committee review
- ⏳ Revisions based on feedback
- ⏳ Defense slides and preparation

---

## Resources and Links

### Repository
- **GitHub:** https://github.com/dw-hurt/phd-sacred-bonds-thesis
- **GitBook:** https://app.gitbook.com/o/cyZpWhV7KomErB6BnmVk/s/hRoSpCiTUrfuH62swMvH/

### Key Documents
- [Future Research Directions](research_materials/future_research/future_research_directions.md)
- [Chapter 1 Draft](chapters/01_introduction/chapter_01_introduction.md)
- [Comparative Analyses Overview](comparative-analyses/_Analyses_Overview.md)

### External Resources
- Jung primary texts: Available via university library or purchase
- Journal articles: Accessible via university database subscriptions
- Future reading list: See Future Research Directions document

---

## Revision History

| Date | Changes | Updated By |
|------|---------|------------|
| $todayFormatted | Complete progress summary generated with current status | Automated Update |
| November 27-28, 2024 | Thompson integration, Future Research Directions added | Major Update |
| November 23, 2024 | Initial progress summary created | Initial Version |

---

## Next Actions (Priority Order)

### This Week:
1. ✅ **Order Jung CW 8 & 9** (~\$100) - CRITICAL
2. ✅ **Order Wilber *Integral Psychology*** (~\$25) - CRITICAL
3. ✅ **Download Fisher et al., Hazan & Shaver** - FREE
4. 📖 **Begin reading Jung CW 8** (synchronicity)
5. 📝 **Create Chapter 2 detailed outline**

### This Month:
1. 📖 **Complete Jung CW 8 & 9** reading
2. 📝 **Draft Chapter 2: Theoretical Framework**
3. 📚 **Acquire remaining Priority 2 sources**
4. 🔄 **Integrate Jungian citations throughout existing draft**

### Next 2 Months:
1. 📝 **Draft Chapter 3: Evolutionary Foundations**
2. 📝 **Draft Chapter 4: Digital Platforms**
3. 📝 **Outline remaining chapters (5-10)**
4. 🔄 **First revision of Chapter 1**

---

**Document Generated:** $todayFormatted  
**Script Version:** 1.0  
**Status:** Active Development  
**Next Update:** As major milestones are reached

---

*This progress summary is automatically updated to reflect current repository status and dissertation development.*
"@

# Create progress-summary directory if needed
if (-not (Test-Path "progress-summary")) {
    New-Item -ItemType Directory -Path "progress-summary" -Force | Out-Null
    Write-Host "✓ Created progress-summary directory" -ForegroundColor Green
}

# Determine output path
$outputPath = "progress-summary/dissertation_progress_summary.md"

# Write new summary
Set-Content $outputPath -Value $newSummary -NoNewline
$newSize = (Get-Item $outputPath).Length / 1KB

Write-Host "✓ New summary generated: $([math]::Round($newSize, 1)) KB" -ForegroundColor Green

# Show summary of changes
Write-Host "`nSummary of Updates:" -ForegroundColor Cyan
Write-Host "  • Updated date: $todayFormatted" -ForegroundColor White
Write-Host "  • Source count: $sourceCount" -ForegroundColor White
Write-Host "  • Comparative analyses: $analysisCount" -ForegroundColor White
Write-Host "  • Quote files: $quoteCount" -ForegroundColor White
Write-Host "  • Chapters drafted: $chapterCount" -ForegroundColor White
Write-Host "  • Recent commits included: 10 most recent" -ForegroundColor White

# Remove old dated file if different from new path
$oldDatedFile = "progress-summary/dissertation_progress_summary_2025_11_23.md"
if ((Test-Path $oldDatedFile) -and ($oldDatedFile -ne $outputPath)) {
    Remove-Item $oldDatedFile -Force
    Write-Host "✓ Removed old dated summary file" -ForegroundColor Green
}

# Update SUMMARY.md if needed
Write-Host "`nStep 4: Updating SUMMARY.md..." -ForegroundColor Yellow

$summary = Get-Content "SUMMARY.md" -Raw

# Check if progress summary is linked
if ($summary -match "dissertation_progress_summary") {
    # Update existing link to remove date
    $summary = $summary -replace 'dissertation_progress_summary_\d{4}_\d{2}_\d{2}\.md', 'dissertation_progress_summary.md'
    Set-Content "SUMMARY.md" -Value $summary -NoNewline
    Write-Host "✓ Updated SUMMARY.md link (removed date)" -ForegroundColor Green
} elseif ($summary -notmatch "progress") {
    # Add new section
    $progressSection = @"
`n## Progress Summary`n
* [Dissertation Progress Summary](progress-summary/dissertation_progress_summary.md)`n
"@
    
    if ($summary -match "## Bibliography") {
        $summary = $summary -replace "(## Bibliography)", "$progressSection`$1"
    } else {
        $summary += $progressSection
    }
    
    Set-Content "SUMMARY.md" -Value $summary -NoNewline
    Write-Host "✓ Added Progress Summary section to SUMMARY.md" -ForegroundColor Green
} else {
    Write-Host "✓ SUMMARY.md already has progress summary link" -ForegroundColor Green
}

# Git operations
Write-Host "`nStep 5: Committing to Git..." -ForegroundColor Yellow

git add $outputPath
git add "SUMMARY.md"

# Remove old file from git if exists
if (Test-Path $oldDatedFile) {
    git rm $oldDatedFile -f 2>$null
}

$commitMessage = @"
Update dissertation progress summary - $todayFormatted

- Updated status metrics ($sourceCount sources, $analysisCount analyses, $chapterCount chapters)
- Included recent git activity (last 10 commits)
- Updated priorities and next actions
- Removed date from filename for easier maintenance
- Comprehensive current status across all dimensions

Current Status:
- Thompson integration complete
- Future Research Directions added
- Chapter 1 drafted (7,500 words)
- Critical gaps identified (Jung, Wilber primary sources)
"@

git commit -m $commitMessage

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Changes committed" -ForegroundColor Green
} else {
    Write-Host "⚠ No changes to commit" -ForegroundColor Yellow
}

# Push
Write-Host "`nStep 6: Pushing to GitHub..." -ForegroundColor Yellow
$pushResult = git push origin main 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Successfully pushed to GitHub!" -ForegroundColor Green
} else {
    if ($pushResult -match "Everything up-to-date") {
        Write-Host "✓ Repository already up to date" -ForegroundColor Green
    } else {
        Write-Host "⚠ Push had issues:" -ForegroundColor Yellow
        Write-Host $pushResult
    }
}

# Final summary
Write-Host "`n═══════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "  Progress Summary Updated!" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Green
Write-Host ""
Write-Host "New Summary Location:" -ForegroundColor Cyan
Write-Host "  $outputPath"
Write-Host ""
Write-Host "Summary Statistics:" -ForegroundColor Cyan
Write-Host "  • File size: $([math]::Round($newSize, 1)) KB"
Write-Host "  • Sources: $sourceCount"
Write-Host "  • Analyses: $analysisCount"
Write-Host "  • Quotes: $quoteCount files"
Write-Host "  • Chapters: $chapterCount"
Write-Host "  • Last commit: $lastCommitDate"
Write-Host ""
Write-Host "Wait 2-3 minutes for GitBook sync, then check:" -ForegroundColor Yellow
Write-Host "  https://app.gitbook.com/o/cyZpWhV7KomErB6BnmVk/s/hRoSpCiTUrfuH62swMvH/"
Write-Host ""
Write-Host "The updated summary should appear under:" -ForegroundColor Cyan
Write-Host "  Progress Summary → Dissertation Progress Summary"
Write-Host ""
Write-Host "✓ Update complete!" -ForegroundColor Green
Write-Host ""
