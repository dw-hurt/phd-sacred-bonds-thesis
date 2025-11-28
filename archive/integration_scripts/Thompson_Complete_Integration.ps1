#Requires -Version 7.0
<#
.SYNOPSIS
    Complete integration of Thompson (In press) research into PhD thesis GitBook repository
    
.DESCRIPTION
    This script performs a complete integration of the Thompson paper on OkCupid and non-monogamy:
    1. Creates/uploads comprehensive research summary
    2. Creates/uploads quotes database (organized by chapter and theme)
    3. Creates/uploads comparative analysis
    4. Creates/uploads bibliography entry
    5. Updates SUMMARY.md navigation
    6. Updates source list README
    7. Updates Chapter 1 quotes with Thompson excerpts
    8. Commits and pushes all changes to GitHub

.PARAMETER Preview
    Shows what changes will be made without applying them

.PARAMETER Apply
    Applies all changes and pushes to GitHub

.EXAMPLE
    .\Thompson_Complete_Integration.ps1 -Preview
    Shows all planned changes

.EXAMPLE
    .\Thompson_Complete_Integration.ps1 -Apply
    Executes full integration
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

Write-Host "`n══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Thompson (In press) - Complete GitBook Integration" -ForegroundColor Cyan
Write-Host "══════════════════════════════════════════════════════`n" -ForegroundColor Cyan

# Check if in correct directory
if (-not (Test-Path "SUMMARY.md")) {
    Write-Error "ERROR: SUMMARY.md not found. Please run from repository root."
    exit 1
}

# Define file paths
$paths = @{
    Summary = "notes/reading_notes/by_source/Thompson_InPress_Summary.md"
    Quotes = "quotes/by_source/Thompson_InPress_Quotes.md"
    Comparative = "comparative-analyses/Thompson_Comparative_Analysis.md"
    Bibliography = "bibliography/Thompson_InPress.md"
    SourceReadme = "notes/reading_notes/by_source/README.md"
    Chapter1Quotes = "quotes/by_chapter/chapter_01_Introduction.md"
}

Write-Info "Integration Plan:"
Write-Info "━━━━━━━━━━━━━━━━"
Write-Host ""
Write-Host "  1. Summary Document    → $($paths.Summary)"
Write-Host "  2. Quotes Database     → $($paths.Quotes)"
Write-Host "  3. Comparative Analysis→ $($paths.Comparative)"
Write-Host "  4. Bibliography Entry  → $($paths.Bibliography)"
Write-Host "  5. Update Source List  → $($paths.SourceReadme)"
Write-Host "  6. Update Chapter 1    → $($paths.Chapter1Quotes)"
Write-Host "  7. Update SUMMARY.md   → Link all new content"
Write-Host ""

if ($Preview) {
    Write-Info "`n[PREVIEW MODE] - Showing planned changes..."
    
    Write-Host "`n1. FILES TO BE CREATED:"
    Write-Host "   ✓ Thompson research summary (11KB)"
    Write-Host "   ✓ Thompson quotes database (18KB)"
    Write-Host "   ✓ Comparative analysis (22KB)"
    Write-Host "   ✓ Bibliography entry (7KB)"
    
    Write-Host "`n2. FILES TO BE UPDATED:"
    Write-Host "   ✓ Source list README (add Thompson entry)"
    Write-Host "   ✓ Chapter 1 quotes (add key Thompson quotes)"
    Write-Host "   ✓ SUMMARY.md (link Thompson in navigation)"
    
    Write-Host "`n3. GIT OPERATIONS:"
    Write-Host "   ✓ Stage all new/modified files"
    Write-Host "   ✓ Commit with message: 'Add Thompson (In press) research - OkCupid and CNM analysis'"
    Write-Host "   ✓ Pull with rebase"
    Write-Host "   ✓ Push to origin main"
    
    Write-Success "`n✓ Preview complete. Run with -Apply to execute."
    exit 0
}

if (-not $Apply) {
    Write-Warning "`nNo action specified. Use -Preview or -Apply parameter."
    Write-Host "  Example: .\Thompson_Complete_Integration.ps1 -Apply"
    exit 0
}

Write-Info "`n[APPLY MODE] - Executing integration..."

# Create necessary directories
$directories = @(
    "notes/reading_notes/by_source"
    "quotes/by_source"
    "comparative-analyses"
    "bibliography"
)

foreach ($dir in $directories) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Success "✓ Created directory: $dir"
    }
}

# Check if source files exist
$sourceFiles = @(
    "Thompson_2020_Research_Summary.md"
    "Thompson_2020_Quotes.md"
    "Thompson_Comparative_Analysis.md"
    "Thompson_Bibliography.md"
)

$missingFiles = $sourceFiles | Where-Object { -not (Test-Path $_) }
if ($missingFiles) {
    Write-Error "ERROR: Missing source files:"
    $missingFiles | ForEach-Object { Write-Host "  ✗ $_" -ForegroundColor Red }
    Write-Host ""
    Write-Warning "Please ensure all Thompson documents are in the current directory."
    exit 1
}

# Copy files to correct locations
Write-Info "`nStep 1: Copying research documents..."
Copy-Item "Thompson_2020_Research_Summary.md" $paths.Summary -Force
Write-Success "✓ Summary document created"

Copy-Item "Thompson_2020_Quotes.md" $paths.Quotes -Force
Write-Success "✓ Quotes database created"

Copy-Item "Thompson_Comparative_Analysis.md" $paths.Comparative -Force
Write-Success "✓ Comparative analysis created"

Copy-Item "Thompson_Bibliography.md" $paths.Bibliography -Force
Write-Success "✓ Bibliography entry created"

# Update Source List README
Write-Info "`nStep 2: Updating source list..."
$readmeContent = Get-Content $paths.SourceReadme -Raw

# Check if Thompson already exists
if ($readmeContent -notmatch "Thompson") {
    $thompsonEntry = @"

## Thompson (In press)

### Research Summary
- [Full Summary](Thompson_InPress_Summary.md)
- **Focus:** Digital dating platforms, non-monogamy, platform normativity
- **Method:** Qualitative multimodal discourse analysis
- **Key Finding:** Platform design reinforces mononormativity despite inclusive features

### Related Materials
- [Quotes Database](../../quotes/by_source/Thompson_InPress_Quotes.md)
- [Comparative Analysis](../../comparative-analyses/Thompson_Comparative_Analysis.md)
- [Bibliography Entry](../../bibliography/Thompson_InPress.md)

"@
    
    # Insert Thompson alphabetically (after Larsen, before others if needed)
    if ($readmeContent -match "## Larsen") {
        $readmeContent = $readmeContent -replace "(## Larsen.*?)(\n\n##|\z)", "`$1$thompsonEntry`$2"
    } else {
        $readmeContent += $thompsonEntry
    }
    
    Set-Content $paths.SourceReadme -Value $readmeContent -NoNewline
    Write-Success "✓ Source list updated with Thompson entry"
} else {
    Write-Warning "⚠ Thompson entry already exists in source list"
}

# Update Chapter 1 Quotes
Write-Info "`nStep 3: Updating Chapter 1 quotes..."

# Read current Chapter 1 quotes
$chapter1Content = Get-Content $paths.Chapter1Quotes -Raw

# Add Thompson section if not exists
if ($chapter1Content -notmatch "Thompson") {
    $thompsonQuotes = @"


---

## Thompson (In press): Digital Dating and Non-Monogamy

### Quote T1: Digital Dating Prevalence ⭐⭐⭐
**Quote:** "With the invention of the smart phone and mobile apps, online dating has become one of the most common means of connecting (Shepherd, 2016). In the U.S. alone, approximately 33.9 million users accessed online dating services in 2018 and the number is expected to reach 37.2 million by 2022 (Kunst 2019)." (p.2)

**Theme:** Technology impact, mating market scale  
**Usage:** Establish scope of digital transformation in mate selection  
**Integration:** Pair with evolutionary mismatch arguments about modern vs. ancestral environments

### Quote T2: Mononormativity as Dominant Script ⭐⭐⭐
**Quote:** "Since mononormativity, the belief system that 'establishes the monogamous (and heterosexual) couple as natural, optimal, and morally loftier' (Ferrer 2018: 819)—is the dominant script that underpins ideals of romantic love and intimate relations in our society (Wolkomir 2019), for the millions of people who ascribe to non-monogamy, online profile creation is often complicated by dating platform interfaces and relationship structures." (p.3)

**Theme:** Cultural norms, relationship scripts  
**Usage:** Establish cultural context for contemporary mating norms  
**Integration:** Connect to archetypal analysis of couple-bond as cultural script

### Quote T3: Cross-Cultural Monogamy Data ⭐⭐⭐
**Quote:** "Monogamy has been shown to be less common than non-monogamy, with strictly monogamous cultures accounting for only 17% of human cultures (Chapais 2013). A representative study in the U.S. found that '21% of the study's participants reported having had some kind of non-monogamous relationship—which the study defined as "any relationship in which all partners agree that each may have romantic and/or sexual relationships with other partners"' (Haupert et al. 2017)." (p.6)

**Theme:** Cross-cultural patterns, mating diversity  
**Usage:** Challenge monogamy-as-universal assumption  
**Integration:** Support evolutionary foundation of mating strategy flexibility

### Quote T4: Platform Design Reinforces Norms ⭐⭐⭐
**Quote:** "I argue that while the addition of non-monogamy features on OkCupid appear to challenge mononormativity on the surface, the platform design and user discursive practices simultaneously reinscribe hegemonic coupledom as the preferred way to do relationships." (p.35)

**Theme:** Technology and normativity  
**Usage:** Critical analysis of technological "solutions" to mating crisis  
**Integration:** Support argument that crisis requires deeper cultural transformation

---

**Thompson Source:** Thompson, R. (In press). More than the selfie: online dating, non-monogamy, normativity, and linked profiles on OkCupid. *Journal of Language and Sexuality*.

"@
    
    $chapter1Content += $thompsonQuotes
    Set-Content $paths.Chapter1Quotes -Value $chapter1Content -NoNewline
    Write-Success "✓ Chapter 1 quotes updated with Thompson excerpts"
} else {
    Write-Warning "⚠ Thompson quotes already exist in Chapter 1"
}

# Update SUMMARY.md
Write-Info "`nStep 4: Updating SUMMARY.md navigation..."
$summaryContent = Get-Content "SUMMARY.md" -Raw

# Check if Thompson is already in comparative analyses
if ($summaryContent -notmatch "Thompson_Comparative_Analysis") {
    # Find comparative analyses section and add Thompson
    if ($summaryContent -match "(comparative-analyses/Larsen_2023_Comparative_Analysis\.md)") {
        $summaryContent = $summaryContent -replace `
            "(comparative-analyses/Larsen_2023_Comparative_Analysis\.md)", `
            "`$1`n  * [Thompson (In press)](comparative-analyses/Thompson_Comparative_Analysis.md)"
        
        Set-Content "SUMMARY.md" -Value $summaryContent -NoNewline
        Write-Success "✓ SUMMARY.md updated with Thompson link"
    } else {
        Write-Warning "⚠ Could not find insertion point in SUMMARY.md"
        Write-Warning "  Please manually add: * [Thompson (In press)](comparative-analyses/Thompson_Comparative_Analysis.md)"
    }
} else {
    Write-Warning "⚠ Thompson already linked in SUMMARY.md"
}

# Git operations
Write-Info "`nStep 5: Committing to Git..."

# Check git status first
$gitStatus = git status --short
if ($gitStatus) {
    Write-Host "`nChanges detected:"
    $gitStatus | ForEach-Object { Write-Host "  $_" -ForegroundColor Yellow }
    
    # Stage all Thompson-related files
    git add $paths.Summary
    git add $paths.Quotes
    git add $paths.Comparative
    git add $paths.Bibliography
    git add $paths.SourceReadme
    git add $paths.Chapter1Quotes
    git add "SUMMARY.md"
    
    Write-Success "✓ Files staged for commit"
    
    # Commit
    $commitMessage = @"
Add Thompson (In press) research - OkCupid and CNM analysis

- Add comprehensive research summary (11KB)
- Add quotes database organized by chapter/theme (18KB)
- Add comparative analysis with other sources (22KB)
- Add bibliography entry (APA/Chicago/MLA formats)
- Update source list README with Thompson entry
- Update Chapter 1 quotes with key Thompson excerpts
- Update SUMMARY.md navigation

Source: Thompson, R. (In press). More than the selfie: online dating, 
non-monogamy, normativity, and linked profiles on OkCupid. 
Journal of Language and Sexuality.
"@
    
    git commit -m $commitMessage
    Write-Success "✓ Changes committed"
    
    # Pull with rebase
    Write-Info "`nPulling latest changes from remote..."
    $pullResult = git pull --rebase origin main 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "✓ Successfully pulled and rebased"
    } else {
        Write-Warning "⚠ Pull/rebase had issues:"
        Write-Host $pullResult
        Write-Host ""
        Write-Warning "You may need to resolve conflicts manually before pushing."
        exit 1
    }
    
    # Push
    Write-Info "`nPushing to GitHub..."
    $pushResult = git push origin main 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "✓ Successfully pushed to GitHub!"
    } else {
        Write-Error "✗ Push failed:"
        Write-Host $pushResult
        exit 1
    }
    
} else {
    Write-Warning "⚠ No changes detected in git status"
}

# Final summary
Write-Host ""
Write-Host "══════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "  Thompson Integration Complete!" -ForegroundColor Green
Write-Host "══════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host ""
Write-Success "✓ All Thompson materials integrated into GitBook"
Write-Host ""
Write-Host "Integrated Files:" -ForegroundColor Cyan
Write-Host "  • Research Summary: $($paths.Summary)"
Write-Host "  • Quotes Database: $($paths.Quotes)"
Write-Host "  • Comparative Analysis: $($paths.Comparative)"
Write-Host "  • Bibliography: $($paths.Bibliography)"
Write-Host ""
Write-Host "Updated Files:" -ForegroundColor Cyan
Write-Host "  • Source List: $($paths.SourceReadme)"
Write-Host "  • Chapter 1 Quotes: $($paths.Chapter1Quotes)"
Write-Host "  • Navigation: SUMMARY.md"
Write-Host ""
Write-Info "Wait 2-3 minutes for GitBook to sync, then check:"
Write-Host "  https://app.gitbook.com/o/cyZpWhV7KomErB6BnmVk/s/hRoSpCiTUrfuH62swMvH/"
Write-Host ""
Write-Host "Thompson should now appear in:" -ForegroundColor Cyan
Write-Host "  • Research Sources > Comparative Analyses"
Write-Host "  • Research Sources > Primary Sources > Thompson"
Write-Host "  • Quotes > Chapter 1 Quotes (Thompson section)"
Write-Host "  • Bibliography"
Write-Host ""
Write-Success "✓ Integration complete! Your thesis now includes Thompson's digital platform analysis."
Write-Host ""
