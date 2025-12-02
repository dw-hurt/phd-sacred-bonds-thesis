<![CDATA[# Sync-To-Sacred-Bonds-GitBook.ps1
# Ensures Sacred Bonds thesis content is properly organized for GitBook publishing
# Updates SUMMARY.md, creates section READMEs, and pushes to trigger GitBook sync
# Author: PhD Automation Script
# Date: 2025-12-02

param(
    [string]$ThesisRepoPath = "C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis",
    [string]$BranchName = "main",
    [switch]$CreateMissingREADMEs,
    [switch]$UpdateNavigation,
    [switch]$DryRun,
    [switch]$Force
)

function Write-Step {
    param([string]$Message)
    Write-Host "`n[STEP] $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "  ✓ $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "  ⚠ $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "  ✗ $Message" -ForegroundColor Red
}

# Section README templates
$SectionREADMEs = @{
    "Literature-Review/02-Evolutionary-Psychology" = @"
# Evolutionary Psychology

## Overview

This section examines the evolutionary foundations of long-term pair bonding, focusing on:
- Adaptive problems solved by committed relationships
- Sex-specific mating strategies
- Cross-cultural universals and variations
- Integration with neuroscience and developmental psychology

---

## Contents

### Men's Long-Term Mating Strategies
- [Buss - Men's Long-Term Mating](Mens-Long-Term-Mating/Buss_Mens_Long_Term_Mating_Strategies.md)
  - Youth and physical attractiveness preferences
  - Solutions to paternity uncertainty (chastity, fidelity)
  - Context effects on mate preferences
  - Cross-cultural evidence from 37 societies

### Coming Soon
- **Women's Mate Selection**: Resource preferences, good genes vs. good dad trade-offs
- **Pair-Bonding Evolution**: Neurobiological mechanisms, comparative perspectives
- **Strategic Pluralism**: Individual differences in mating strategies

---

## Key Theoretical Frameworks

- **Sexual Selection Theory** (Darwin, Trivers)
- **Parental Investment Theory** (Trivers, 1972)
- **Error Management Theory** (Haselton & Buss)
- **Strategic Pluralism** (Gangestad & Simpson)

---

## Integration with Sacred Bonds Thesis

Evolutionary psychology provides the biological foundation for understanding:
1. **Universal patterns** in mate preferences and bonding
2. **Adaptive functions** of commitment and fidelity
3. **Sex differences** in relationship psychology
4. **Contextual variation** in mating strategies

These insights complement sacred traditions by revealing the deep evolutionary roots of bonding rituals and relationship commitments.

---

**Last Updated**: $(Get-Date -Format "yyyy-MM-dd")
"@

    "Resources/Key-Quotes" = @"
# Key Quotes - Research Resources

## Overview

This section contains curated quotations from primary sources, organized by research domain. These quotes support thesis arguments, provide evidence for claims, and facilitate efficient reference during writing.

---

## Collections

### Evolutionary Psychology
- [Buss - Mate Preferences Quotes](Evolutionary-Psychology/Buss_Quotes_Mate_Preferences.md)

### Sacred Traditions
- Coming soon

### Neuroscience
- Coming soon

### Attachment Theory
- Coming soon

---

## Usage Guidelines

1. **Citation**: All quotes include page numbers and full citations
2. **Context**: Quotes are accompanied by explanatory notes
3. **Organization**: Thematic grouping for easy reference
4. **Integration**: Cross-referenced with integration guides

---

**Last Updated**: $(Get-Date -Format "yyyy-MM-dd")
"@

    "Research-Notes/Integration-Guides" = @"
# Integration Guides

## Purpose

Integration guides provide strategic roadmaps for incorporating research findings into the Sacred Bonds thesis. Each guide identifies:
- Where material fits in thesis structure
- How to synthesize with other sources
- Key arguments and supporting evidence
- Writing strategies and chapter outlines

---

## Available Guides

### Evolutionary Psychology
- [Buss - Integration into Sacred Bonds](Buss_Integration_Sacred_Bonds.md)
  - Thesis positioning strategy
  - Chapter-by-chapter integration points
  - Synthesis with sacred traditions
  - Critical engagement approaches

### Coming Soon
- Attachment theory integration
- Neuroscience integration
- Sacred texts integration
- Cross-cultural anthropology integration

---

## How to Use Integration Guides

1. **Before Writing**: Review guide to understand positioning strategy
2. **During Research**: Use cross-references to find related materials
3. **While Writing**: Consult integration points for chapter placement
4. **During Revision**: Check synthesis recommendations

---

**Last Updated**: $(Get-Date -Format "yyyy-MM-dd")
"@

    "Analysis/Theoretical-Frameworks" = @"
# Theoretical Frameworks Analysis

## Overview

This section contains comparative analyses of competing and complementary theoretical frameworks relevant to the Sacred Bonds thesis.

---

## Current Analyses

### Evolutionary vs. Social Construction
- [Buss - Comparative Framework Analysis](Evolutionary-vs-Social/Buss_Comparative_Framework_Analysis.md)
  - Evolutionary psychology vs. social role theory
  - Evidence for biological vs. cultural explanations
  - Integration strategies
  - Critical evaluation

### Coming Soon
- **Sacred vs. Secular** frameworks
- **Biological vs. Spiritual** perspectives
- **Attachment vs. Evolutionary** paradigms

---

## Purpose

Comparative framework analyses serve to:
1. Identify points of theoretical convergence and divergence
2. Evaluate empirical evidence for competing explanations
3. Develop integrative theoretical models
4. Address potential critiques preemptively

---

**Last Updated**: $(Get-Date -Format "yyyy-MM-dd")
"@

    "Bibliography/Primary-Sources" = @"
# Bibliography - Primary Sources

## Overview

Primary sources are original research articles, book chapters, and monographs that provide direct evidence and theoretical frameworks for the thesis.

---

## Evolutionary Psychology

### Mate Selection & Preferences
- [Buss - Evolutionary Psychology Handbook](Buss_Evolutionary_Psychology_Handbook.md)
  - Men's long-term mating strategies
  - Cross-cultural mate preference data
  - Theoretical foundations

### Coming Soon
- Trivers - Parental Investment and Sexual Selection (1972)
- Symons - The Evolution of Human Sexuality (1979)
- Gangestad & Thornhill - Ovulatory cycle effects

---

## Neuroscience

### Coming Soon
- Fisher - Neurochemistry of romantic love
- Carter - Oxytocin and pair bonding
- Young - Vasopressin and monogamy

---

## Attachment Theory

### Coming Soon
- Bowlby - Attachment trilogy
- Ainsworth - Strange Situation studies
- Hazan & Shaver - Adult romantic attachment

---

## Sacred Traditions

### Coming Soon
- Comparative religious texts on marriage
- Anthropological studies of bonding rituals
- Cross-cultural marriage practices

---

**Last Updated**: $(Get-Date -Format "yyyy-MM-dd")
"@
}

# Initialize
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host "     Sacred Bonds Thesis - GitBook Publishing Preparation" -ForegroundColor Magenta
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Magenta

if ($DryRun) {
    Write-Warning "DRY RUN MODE - No changes will be made"
}

# Validate repository
Write-Step "Validating thesis repository..."

if (-not (Test-Path $ThesisRepoPath)) {
    Write-Error "Thesis repository not found: $ThesisRepoPath"
    exit 1
}
Write-Success "Repository found"

# Step 1: Create section README files
if ($CreateMissingREADMEs) {
    Write-Step "Creating section README files..."
    
    foreach ($section in $SectionREADMEs.Keys) {
        $sectionPath = Join-Path $ThesisRepoPath $section
        $readmePath = Join-Path $sectionPath "README.md"
        
        if (-not (Test-Path $readmePath) -or $Force) {
            if (-not $DryRun) {
                # Ensure directory exists
                if (-not (Test-Path $sectionPath)) {
                    New-Item -ItemType Directory -Path $sectionPath -Force | Out-Null
                }
                
                Set-Content -Path $readmePath -Value $SectionREADMEs[$section] -Force
                Write-Success "Created: $section\README.md"
            } else {
                Write-Host "  [DRY RUN] Would create: $section\README.md" -ForegroundColor Gray
            }
        } else {
            Write-Host "  → Exists: $section\README.md" -ForegroundColor DarkGray
        }
    }
}

# Step 2: Update SUMMARY.md with enhanced navigation
if ($UpdateNavigation) {
    Write-Step "Updating GitBook navigation (SUMMARY.md)..."
    
    $EnhancedSummary = @"
# Table of Contents

* [Sacred Bonds PhD Thesis](README.md)
* [Integration Report](INTEGRATION_REPORT.md)

---

## Part I: Literature Review

* [Literature Review Overview](Literature-Review/INDEX.md)

### Evolutionary Psychology
* [Evolutionary Psychology Overview](Literature-Review/02-Evolutionary-Psychology/README.md)
* [Men's Long-Term Mating Strategies](Literature-Review/02-Evolutionary-Psychology/Mens-Long-Term-Mating/Buss_Mens_Long_Term_Mating_Strategies.md)

### Sacred Traditions
* [Sacred Traditions Overview](Literature-Review/01-Sacred-Traditions/README.md)

### Attachment Theory
* [Attachment Theory Overview](Literature-Review/03-Attachment-Theory/README.md)

### Neuroscience of Bonding
* [Neuroscience Overview](Literature-Review/04-Neuroscience-of-Bonding/README.md)

---

## Part II: Theoretical Foundations

* [Theoretical Foundations](Chapters/Chapter-02-Theoretical-Foundations/README.md)

---

## Part III: Analysis

* [Analysis Overview](Analysis/README.md)

### Theoretical Frameworks
* [Frameworks Overview](Analysis/Theoretical-Frameworks/README.md)
* [Evolutionary vs. Social Construction](Analysis/Theoretical-Frameworks/Evolutionary-vs-Social/Buss_Comparative_Framework_Analysis.md)

### Case Studies
* [Case Studies Overview](Analysis/Case-Studies/README.md)

---

## Part IV: Synthesis

* [Sacred Bond Paradigm](Chapters/Chapter-05-Synthesis/README.md)

---

## Bibliography

* [Bibliography Overview](Bibliography/README.md)

### Primary Sources
* [Primary Sources Overview](Bibliography/Primary-Sources/README.md)
* [Buss - Evolutionary Psychology Handbook](Bibliography/Primary-Sources/Buss_Evolutionary_Psychology_Handbook.md)

### Secondary Sources
* [Secondary Sources Overview](Bibliography/Secondary-Sources/README.md)

---

## Resources

* [Resources Overview](Resources/README.md)

### Key Quotes
* [Key Quotes Overview](Resources/Key-Quotes/README.md)
* [Evolutionary Psychology Quotes](Resources/Key-Quotes/Evolutionary-Psychology/Buss_Quotes_Mate_Preferences.md)

### Research Notes
* [Research Notes Overview](Research-Notes/README.md)
* [Integration Guides](Research-Notes/Integration-Guides/README.md)
  * [Buss Integration Guide](Research-Notes/Integration-Guides/Buss_Integration_Sacred_Bonds.md)

---

## Appendices

* [Methodology](Appendices/Methodology.md)
* [Glossary](Appendices/Glossary.md)

"@
    
    $summaryPath = Join-Path $ThesisRepoPath "SUMMARY.md"
    if (-not $DryRun) {
        Set-Content -Path $summaryPath -Value $EnhancedSummary -Force
        Write-Success "Updated SUMMARY.md"
    } else {
        Write-Host "  [DRY RUN] Would update SUMMARY.md" -ForegroundColor Gray
    }
}

# Step 3: Create placeholder overview files
Write-Step "Creating section overview files..."

$OverviewFiles = @{
    "Resources/README.md" = "# Resources`n`nResearch resources including key quotes, definitions, and reference materials."
    "Analysis/README.md" = "# Analysis`n`nComparative analyses and theoretical framework evaluations."
    "Chapters/README.md" = "# Thesis Chapters`n`nDraft chapters and outlines for the Sacred Bonds thesis."
    "Appendices/README.md" = "# Appendices`n`nSupplemental materials, methodology details, and reference information."
}

foreach ($file in $OverviewFiles.Keys) {
    $filePath = Join-Path $ThesisRepoPath $file
    $fileDir = Split-Path -Parent $filePath
    
    if (-not (Test-Path $filePath) -or $Force) {
        if (-not $DryRun) {
            if (-not (Test-Path $fileDir)) {
                New-Item -ItemType Directory -Path $fileDir -Force | Out-Null
            }
            Set-Content -Path $filePath -Value $OverviewFiles[$file] -Force
            Write-Success "Created: $file"
        } else {
            Write-Host "  [DRY RUN] Would create: $file" -ForegroundColor Gray
        }
    }
}

# Step 4: Verify all files referenced in SUMMARY.md exist
Write-Step "Verifying SUMMARY.md references..."

$summaryPath = Join-Path $ThesisRepoPath "SUMMARY.md"
if (Test-Path $summaryPath) {
    $summaryContent = Get-Content -Path $summaryPath -Raw
    $fileReferences = [regex]::Matches($summaryContent, '\[.*?\]\((.*?\.md)\)') | ForEach-Object { $_.Groups[1].Value }
    
    $MissingFiles = @()
    foreach ($ref in $fileReferences) {
        $refPath = Join-Path $ThesisRepoPath $ref
        if (-not (Test-Path $refPath)) {
            $MissingFiles += $ref
        }
    }
    
    if ($MissingFiles.Count -gt 0) {
        Write-Warning "Found $($MissingFiles.Count) missing file(s) referenced in SUMMARY.md:"
        foreach ($missing in $MissingFiles) {
            Write-Host "    - $missing" -ForegroundColor Yellow
        }
        Write-Host "`n  These files should be created before publishing to GitBook" -ForegroundColor Yellow
    } else {
        Write-Success "All SUMMARY.md references verified"
    }
}

# Step 5: Create GitBook publishing checklist
Write-Step "Creating GitBook publishing checklist..."

$ChecklistContent = @"
# GitBook Publishing Checklist

**Generated**: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

---

## Pre-Publishing Verification

### Repository Structure
- [x] README.md exists and is informative
- [x] SUMMARY.md navigation structure is complete
- [x] .gitbook.yaml configuration file exists
- [x] All section README files created
- [ ] All chapters have placeholder or draft content
- [ ] All referenced files in SUMMARY.md exist

### Content Quality
- [x] Buss evolutionary psychology materials added
- [ ] Proofread main README.md
- [ ] Verify all markdown formatting
- [ ] Check internal links work correctly
- [ ] Ensure images are accessible (if any)
- [ ] Review bibliography formatting

### GitBook Configuration
- [ ] GitBook account created
- [ ] New space created: "Sacred Bonds PhD Thesis"
- [ ] GitHub integration configured
- [ ] Repository connected: dw-hurt/phd-sacred-bonds-thesis
- [ ] Branch selected: main
- [ ] Bi-directional sync enabled
- [ ] Initial sync completed successfully

---

## GitBook Setup Instructions

### 1. Create GitBook Account
1. Go to: https://gitbook.com
2. Sign up with GitHub account (recommended)
3. Verify email address

### 2. Create New Space
1. Click "New Space"
2. Name: "Sacred Bonds PhD Thesis"
3. Visibility: Private (for thesis work) or Public (for academic sharing)
4. Click "Create Space"

### 3. Connect GitHub Repository
1. In space settings, go to "Integrations"
2. Click "GitHub" integration
3. Authorize GitBook to access GitHub
4. Select repository: ``dw-hurt/phd-sacred-bonds-thesis``
5. Select branch: ``main``
6. Enable "Bi-directional sync"
7. Click "Save"

### 4. Configure Publishing
1. Go to "Share" settings
2. Choose visibility:
   - **Private**: Only you can access (thesis work in progress)
   - **Public**: Anyone with link (academic portfolio)
3. Customize URL slug (optional)
4. Configure domain (optional, for custom domain)

### 5. Trigger Initial Sync
1. Make a small change in GitHub (e.g., edit README.md)
2. Commit and push change
3. Wait 2-5 minutes for GitBook sync
4. Refresh GitBook space to see changes
5. Verify SUMMARY.md navigation appears correctly

---

## Post-Publishing Tasks

### Content Development
- [ ] Draft Chapter 1: Introduction
- [ ] Draft Chapter 2: Theoretical Foundations
- [ ] Add women's mate selection research
- [ ] Add attachment theory materials
- [ ] Add neuroscience literature
- [ ] Add sacred traditions research

### Organization
- [ ] Create chapter outlines
- [ ] Develop integration synthesis documents
- [ ] Build comprehensive bibliography
- [ ] Create glossary of terms
- [ ] Add methodology appendix

### GitBook Customization
- [ ] Choose theme/appearance
- [ ] Add custom logo (optional)
- [ ] Configure PDF export settings
- [ ] Set up search functionality
- [ ] Create table of contents widgets

---

## Verification Commands

``````powershell
# Navigate to repository
cd "C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis"

# Check Git status
git status

# View recent commits
git log --oneline -5

# Verify file structure
Get-ChildItem -Recurse -Directory | Select-Object FullName

# Test markdown files
Get-ChildItem -Recurse -Filter "*.md" | Select-Object FullName

# Push to GitHub
git push origin main
``````

---

## Troubleshooting

### GitBook Not Syncing
1. Check GitBook activity log for errors
2. Verify GitHub integration is active
3. Ensure branch name matches (main)
4. Try manual sync trigger in GitBook settings
5. Check for markdown syntax errors

### Navigation Not Appearing
1. Verify SUMMARY.md format is correct
2. Ensure file paths are relative (not absolute)
3. Check for typos in file references
4. Confirm all referenced files exist

### Images Not Displaying
1. Use relative paths: ``![alt](images/file.png)``
2. Ensure images are committed to repository
3. Check image file extensions are lowercase
4. Verify images are in supported formats (PNG, JPG, GIF)

---

## Next Steps After Publishing

1. **Share GitBook URL** with advisors/committee
2. **Regular Updates**: Push changes to GitHub, sync automatically
3. **Feedback Integration**: Track comments/suggestions
4. **Version Control**: Use Git tags for major milestones
5. **Backup**: Regularly export PDF versions

---

**Status**: Ready for GitBook setup
**Last Updated**: $(Get-Date -Format "yyyy-MM-dd")

"@

$checklistPath = Join-Path $ThesisRepoPath "GITBOOK_CHECKLIST.md"
if (-not $DryRun) {
    Set-Content -Path $checklistPath -Value $ChecklistContent -Force
    Write-Success "Created GitBook checklist"
} else {
    Write-Host "  [DRY RUN] Would create GITBOOK_CHECKLIST.md" -ForegroundColor Gray
}

# Step 6: Git operations (if changes made)
Write-Step "Finalizing changes..."

Push-Location $ThesisRepoPath

try {
    if (-not $DryRun) {
        # Check if there are changes
        $status = git status --porcelain
        
        if ($status) {
            git add .
            Write-Success "Staged changes"
            
            $commitMsg = "Prepare for GitBook publishing - Add section READMEs and navigation ($(Get-Date -Format 'yyyy-MM-dd'))"
            git commit -m $commitMsg
            Write-Success "Committed: $commitMsg"
            
            git push origin $BranchName
            Write-Success "Pushed to GitHub"
            
            Write-Host "`n  GitBook will automatically sync these changes if integration is set up" -ForegroundColor Cyan
        } else {
            Write-Host "  → No changes to commit" -ForegroundColor DarkGray
        }
    } else {
        Write-Host "  [DRY RUN] Would commit and push changes to GitHub" -ForegroundColor Gray
    }
} catch {
    Write-Error "Git operation failed: $_"
} finally {
    Pop-Location
}

# Summary
Write-Host "`n═══════════════════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host "               GITBOOK PREPARATION COMPLETE" -ForegroundColor Magenta
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Magenta

Write-Host "`nRepository Status:" -ForegroundColor Cyan
if (-not $DryRun) {
    Write-Host "  ✓ Section READMEs created" -ForegroundColor Green
    Write-Host "  ✓ Navigation updated" -ForegroundColor Green
    Write-Host "  ✓ GitBook checklist created" -ForegroundColor Green
    Write-Host "  ✓ Changes pushed to GitHub" -ForegroundColor Green
}

Write-Host "`nNext Steps:" -ForegroundColor Yellow
Write-Host "  1. Review GitBook checklist:" -ForegroundColor White
Write-Host "     → $ThesisRepoPath\GITBOOK_CHECKLIST.md" -ForegroundColor DarkGray
Write-Host "  2. Set up GitBook integration:" -ForegroundColor White
Write-Host "     → Go to https://gitbook.com" -ForegroundColor DarkGray
Write-Host "     → Create space: 'Sacred Bonds PhD Thesis'" -ForegroundColor DarkGray
Write-Host "     → Connect repository: dw-hurt/phd-sacred-bonds-thesis" -ForegroundColor DarkGray
Write-Host "  3. Wait for automatic sync (2-5 minutes)" -ForegroundColor White
Write-Host "  4. Verify content appears in GitBook" -ForegroundColor White

if ($DryRun) {
    Write-Host "`n[DRY RUN] Re-run with -CreateMissingREADMEs -UpdateNavigation to execute" -ForegroundColor Yellow
}

Write-Host "`n🚀 Ready for GitBook publishing! 🚀`n" -ForegroundColor Green
]]>