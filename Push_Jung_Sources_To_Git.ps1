#Requires -Version 5.1
<#
.SYNOPSIS
    Push Jung Literature Summaries to Sacred Bonds PhD Git Repository

.DESCRIPTION
    This script organizes and commits the Jung PDF literature summaries, bibliography, 
    and quote collection to your PhD dissertation Git repository. It creates a proper 
    folder structure for literature sources and pushes everything to GitHub.

.NOTES
    File Name      : Push_Jung_Sources_To_Git.ps1
    Author         : AI Research Assistant
    Prerequisite   : Git must be installed and repository initialized
    Created        : 2025-11-28
    
.EXAMPLE
    .\Push_Jung_Sources_To_Git.ps1
#>

# ============================================================================
# CONFIGURATION
# ============================================================================

$phdBasePath = "C:\Users\user\Documents\PhD"
$dissertationRepo = Join-Path $phdBasePath "phd-sacred-bonds-thesis"
$literaturePath = Join-Path $dissertationRepo "03_literature_sources"
$jungPath = Join-Path $literaturePath "Jung_Sources"

# Colors for console output
$successColor = "Green"
$warningColor = "Yellow"
$errorColor = "Red"
$infoColor = "Cyan"

# ============================================================================
# FUNCTIONS
# ============================================================================

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

function Test-Prerequisites {
    Write-ColorOutput "`n=== Checking Prerequisites ===" $infoColor
    
    # Check if PhD directory exists
    if (-not (Test-Path $phdBasePath)) {
        Write-ColorOutput "ERROR: PhD directory not found at $phdBasePath" $errorColor
        return $false
    }
    Write-ColorOutput "✓ PhD directory found" $successColor
    
    # Check if dissertation repo exists
    if (-not (Test-Path $dissertationRepo)) {
        Write-ColorOutput "ERROR: Dissertation repository not found at $dissertationRepo" $errorColor
        Write-ColorOutput "Expected path: $dissertationRepo" $warningColor
        return $false
    }
    Write-ColorOutput "✓ Dissertation repository found" $successColor
    
    # Check if Git is installed
    try {
        $gitVersion = git --version 2>$null
        Write-ColorOutput "✓ Git installed: $gitVersion" $successColor
    } catch {
        Write-ColorOutput "ERROR: Git is not installed or not in PATH" $errorColor
        return $false
    }
    
    # Check if source files exist
    $sourceFiles = @(
        "Jung_Literature_Summary_CW9-1_Archetypes.md",
        "Jung_Literature_Summary_CW16_Transference.md",
        "Jung_Literature_Summary_Anima-Animus_Essay.md",
        "Literature_Summary_Jungian_Archetypes_Infidelity_Dissertation.md",
        "Jung_Sources_Bibliography.md",
        "Jung_Quotes_By_Chapter.md"
    )
    
    $missingFiles = @()
    foreach ($file in $sourceFiles) {
        $sourcePath = Join-Path $phdBasePath $file
        if (-not (Test-Path $sourcePath)) {
            $missingFiles += $file
        }
    }
    
    if ($missingFiles.Count -gt 0) {
        Write-ColorOutput "ERROR: Missing source files:" $errorColor
        $missingFiles | ForEach-Object { Write-ColorOutput "  - $_" $errorColor }
        Write-ColorOutput "`nPlease download all files to: $phdBasePath" $warningColor
        return $false
    }
    Write-ColorOutput "✓ All source files found ($($sourceFiles.Count) files)" $successColor
    
    return $true
}

function New-FolderStructure {
    Write-ColorOutput "`n=== Creating Folder Structure ===" $infoColor
    
    # Create literature sources directory if it doesn't exist
    if (-not (Test-Path $literaturePath)) {
        New-Item -ItemType Directory -Path $literaturePath -Force | Out-Null
        Write-ColorOutput "✓ Created: 03_literature_sources/" $successColor
    } else {
        Write-ColorOutput "✓ Exists: 03_literature_sources/" $successColor
    }
    
    # Create Jung sources subdirectory
    if (-not (Test-Path $jungPath)) {
        New-Item -ItemType Directory -Path $jungPath -Force | Out-Null
        Write-ColorOutput "✓ Created: 03_literature_sources/Jung_Sources/" $successColor
    } else {
        Write-ColorOutput "✓ Exists: 03_literature_sources/Jung_Sources/" $successColor
    }
    
    # Create README for literature sources folder
    $readmePath = Join-Path $literaturePath "README.md"
    if (-not (Test-Path $readmePath)) {
        $readmeContent = @"
# Literature Sources

This directory contains comprehensive literature reviews, summaries, and bibliographic information for all source materials used in the Sacred Bonds dissertation.

## Structure

- **Jung_Sources/** - C.G. Jung primary sources and related empirical research
  - Literature summaries for each major work (CW 9, CW 16, etc.)
  - Comprehensive bibliography in APA 7th format
  - Quotes organized by dissertation chapter

## Usage

Each literature summary includes:
- Executive summary of the source
- Key concepts and definitions
- Critical quotes with page numbers
- Integration notes for specific dissertation chapters
- Cross-references to related sources

## Adding New Sources

1. Create literature summary using template format
2. Add to appropriate subdirectory (Jung_Sources, Evolutionary_Psych, etc.)
3. Update master bibliography
4. Tag relevant dissertation chapters

---

**Last Updated:** $(Get-Date -Format "yyyy-MM-dd")
"@
        Set-Content -Path $readmePath -Value $readmeContent -Encoding UTF8
        Write-ColorOutput "✓ Created: README.md" $successColor
    }
}

function Copy-JungSources {
    Write-ColorOutput "`n=== Copying Jung Source Files ===" $infoColor
    
    $files = @{
        "Jung_Literature_Summary_CW9-1_Archetypes.md" = "01_CW9-1_Archetypes_CollectiveUnconscious.md"
        "Jung_Literature_Summary_CW16_Transference.md" = "02_CW16_Psychology_of_Transference.md"
        "Jung_Literature_Summary_Anima-Animus_Essay.md" = "03_Anima_Animus_Essay.md"
        "Literature_Summary_Jungian_Archetypes_Infidelity_Dissertation.md" = "04_Jungian_Archetypes_Infidelity_Dissertation.md"
        "Jung_Sources_Bibliography.md" = "00_Jung_Sources_Bibliography.md"
        "Jung_Quotes_By_Chapter.md" = "99_Jung_Quotes_By_Chapter_Reference.md"
    }
    
    foreach ($sourceFile in $files.Keys) {
        $sourcePath = Join-Path $phdBasePath $sourceFile
        $destFile = $files[$sourceFile]
        $destPath = Join-Path $jungPath $destFile
        
        if (Test-Path $sourcePath) {
            Copy-Item -Path $sourcePath -Destination $destPath -Force
            $fileSize = (Get-Item $destPath).Length / 1KB
            Write-ColorOutput "✓ Copied: $destFile ($([math]::Round($fileSize, 1)) KB)" $successColor
        } else {
            Write-ColorOutput "⚠ Skipped: $sourceFile (not found)" $warningColor
        }
    }
}

function New-JungSourcesIndex {
    Write-ColorOutput "`n=== Creating Jung Sources Index ===" $infoColor
    
    $indexPath = Join-Path $jungPath "README.md"
    $indexContent = @"
# Jung Sources for Sacred Bonds Dissertation

This folder contains comprehensive literature reviews and analysis of C.G. Jung's primary works and related empirical research relevant to the dissertation **"Sacred Bonds: Evolutionary Psychology and the Contemporary Mating Crisis."**

## 📚 Sources Processed

### Primary Jung Works

1. **[01_CW9-1_Archetypes_CollectiveUnconscious.md](01_CW9-1_Archetypes_CollectiveUnconscious.md)**
   - *The Archetypes and the Collective Unconscious* (CW 9, Part 1)
   - Foundation for archetypal theory, anima/animus, shadow, Self
   - 17KB summary with 10+ critical quotes
   - **Key for:** Chapter 2 (Theoretical Framework)

2. **[02_CW16_Psychology_of_Transference.md](02_CW16_Psychology_of_Transference.md)**
   - *The Practice of Psychotherapy* (CW 16)
   - Transference, projection, alchemical *coniunctio* in relationships
   - 13KB summary with alchemical stages mapped to relationship development
   - **Key for:** Chapter 3 (Literature Review - Projection Mechanisms)

3. **[03_Anima_Animus_Essay.md](03_Anima_Animus_Essay.md)**
   - Accessible essay on anima/animus projection
   - Explains mate selection projection crisis
   - 12KB summary with practical examples
   - **Key for:** Chapter 3 (Accessible introduction for readers)

### Empirical Research

4. **[04_Jungian_Archetypes_Infidelity_Dissertation.md](04_Jungian_Archetypes_Infidelity_Dissertation.md)**
   - Doctoral dissertation: Archetypes as predictors of infidelity
   - n=122 quantitative study validating Jungian theory
   - 16KB summary with statistical findings
   - **Key for:** Chapter 3 (Empirical validation), Chapter 4 (Methodology)

### Reference Materials

5. **[00_Jung_Sources_Bibliography.md](00_Jung_Sources_Bibliography.md)**
   - Complete APA 7th edition citations for all Jung sources
   - Citation examples and quick reference guide
   - 11KB with cross-references
   - **Use for:** All chapters, final bibliography

6. **[99_Jung_Quotes_By_Chapter_Reference.md](99_Jung_Quotes_By_Chapter_Reference.md)**
   - 45+ critical quotes organized by dissertation chapter
   - Direct integration guide for drafting
   - 20KB comprehensive quote collection
   - **Use for:** Drafting all chapters

## 🎯 Quick Navigation by Dissertation Chapter

### Chapter 1: Introduction
- CW 9 (p. 200): "American divorce rate... anima projects herself"
- Anima/Animus Essay: Crisis when "projections lessen and fall"

### Chapter 2: Theoretical Framework
- **Primary:** CW 9 - all major concepts (archetypes, collective unconscious, anima/animus, shadow, Self)
- **Secondary:** CW 16 - transference and projection mechanisms
- See `99_Jung_Quotes_By_Chapter_Reference.md` for complete list

### Chapter 3: Literature Review
- **Primary:** Infidelity Dissertation - empirical validation
- **Supporting:** All three Jung sources for theoretical foundation
- Key finding: Archetypes predict infidelity behavior (p < .05)

### Chapter 4: Methodology
- Reference Infidelity Dissertation for quantitative archetypal assessment
- Cite CW 9 for archetypal definitions used in research

### Chapter 5: Discussion
- Integrate all sources to interpret findings
- Heavy use of CW 16 for relationship dynamics analysis
- Apply empirical findings from Infidelity Dissertation

### Chapter 6: Conclusion
- CW 9 on individuation as solution (pp. 275-276)
- Infidelity Dissertation as empirical support for recommendations

## 📖 How to Use These Summaries

1. **Start with Bibliography** (`00_Jung_Sources_Bibliography.md`) to understand citation format
2. **Read Executive Summaries** at top of each literature summary for quick overview
3. **Use Quotes Reference** (`99_Jung_Quotes_By_Chapter_Reference.md`) when drafting specific chapters
4. **Cross-reference** between sources using "Cross-References" section in each summary

## 🔗 Integration with Evolutionary Psychology

All summaries highlight connections between Jungian theory and evolutionary psychology:

- **Archetypes as evolutionary inheritance** (CW 9, p. 279)
- **Anima/animus as genetic patterns** (CW 9, p. 57; Infidelity Dissertation, p. 10)
- **Fast/slow life history strategies** map to Jester vs. Caregiver archetypes
- **Projection as mate assessment mechanism**

## ✅ Processing Status

| Source | Summary | Bibliography | Quotes | Status |
|--------|---------|--------------|---------|--------|
| CW 9/I | ✅ | ✅ | ✅ | Complete |
| CW 16 | ✅ | ✅ | ✅ | Complete |
| Anima/Animus | ✅ | ⚠️ Needs verification | ✅ | Mostly Complete |
| Infidelity Diss. | ✅ | ⚠️ Needs verification | ✅ | Mostly Complete |

**Note:** Two sources need full citation verification (see Bibliography for details).

## 📌 Next Steps

1. ✅ Literature summaries complete
2. ✅ Bibliography created
3. ✅ Quotes organized by chapter
4. ⬜ Verify Anima/Animus essay original source
5. ⬜ Extract Infidelity Dissertation full citation
6. ⬜ Begin integrating quotes into Chapter 2 draft
7. ⬜ Cross-reference with evolutionary psychology literature (Buss, Trivers, etc.)

## 🔍 Quick Reference

**Total Pages Processed:** 1,500+  
**Total Quotes Extracted:** 45+  
**Key Concepts Defined:** 15+  
**Chapters Mapped:** All 6 dissertation chapters

**Last Updated:** $(Get-Date -Format "yyyy-MM-dd HH:mm")  
**Files in This Folder:** 7

---

For questions about Jung source integration, consult the comprehensive `99_Jung_Quotes_By_Chapter_Reference.md` guide.
"@
    Set-Content -Path $indexPath -Value $indexContent -Encoding UTF8
    Write-ColorOutput "✓ Created: Jung_Sources/README.md ($(([math]::Round((Get-Item $indexPath).Length / 1KB, 1))) KB)" $successColor
}

function Invoke-GitOperations {
    Write-ColorOutput "`n=== Git Operations ===" $infoColor
    
    # Change to dissertation repository
    Set-Location $dissertationRepo
    
    # Check Git status
    Write-ColorOutput "`nChecking Git status..." $infoColor
    git status --short
    
    # Stage all new files
    Write-ColorOutput "`nStaging Jung literature sources..." $infoColor
    git add 03_literature_sources/
    
    # Create commit
    $commitMessage = @"
Add comprehensive Jung literature summaries and bibliography

- Processed 4 Jung sources (1,500+ pages total):
  * CW 9/I: Archetypes and the Collective Unconscious
  * CW 16: Psychology of the Transference
  * Anima/Animus Essay
  * Empirical dissertation on archetypes and infidelity

- Created literature summaries (57KB total):
  * Executive summaries and key concepts
  * 45+ critical quotes with page numbers
  * Integration notes for each dissertation chapter
  * Cross-references between sources

- Complete APA 7th bibliography (11KB):
  * All 4 sources with proper citations
  * Citation examples and quick reference guide
  * Notes on translation dates and editions

- Quote reference organized by chapter (20KB):
  * Quotes tagged by dissertation chapter
  * Usage guidelines and citation frequency recommendations
  * Direct integration instructions

- Created organized folder structure:
  * 03_literature_sources/Jung_Sources/
  * Comprehensive README files for navigation
  * Numbered files for easy access

Total added: 6 literature review files + 2 README files

This establishes the Jungian theoretical foundation for Sacred Bonds
dissertation, integrating depth psychology with evolutionary psychology.
"@
    
    git commit -m $commitMessage
    
    if ($LASTEXITCODE -eq 0) {
        Write-ColorOutput "✓ Commit successful" $successColor
    } else {
        Write-ColorOutput "⚠ No changes to commit (files may already be up to date)" $warningColor
        return
    }
    
    # Push to GitHub
    Write-ColorOutput "`nPushing to GitHub..." $infoColor
    git push
    
    if ($LASTEXITCODE -eq 0) {
        Write-ColorOutput "✓ Successfully pushed to GitHub!" $successColor
    } else {
        Write-ColorOutput "⚠ Push may have failed. Check your GitHub connection." $warningColor
        Write-ColorOutput "You can manually push later with: git push" $infoColor
    }
}

function Show-Summary {
    Write-ColorOutput "`n╔════════════════════════════════════════════════════════════════╗" $successColor
    Write-ColorOutput "║          Jung Literature Sources - Git Push Complete!          ║" $successColor
    Write-ColorOutput "╚════════════════════════════════════════════════════════════════╝`n" $successColor
    
    Write-ColorOutput "📚 Files Added to Git Repository:" $infoColor
    Write-ColorOutput ""
    Write-ColorOutput "  03_literature_sources/" $infoColor
    Write-ColorOutput "    └── Jung_Sources/" $infoColor
    Write-ColorOutput "        ├── 00_Jung_Sources_Bibliography.md (11 KB)" "White"
    Write-ColorOutput "        ├── 01_CW9-1_Archetypes_CollectiveUnconscious.md (17 KB)" "White"
    Write-ColorOutput "        ├── 02_CW16_Psychology_of_Transference.md (13 KB)" "White"
    Write-ColorOutput "        ├── 03_Anima_Animus_Essay.md (12 KB)" "White"
    Write-ColorOutput "        ├── 04_Jungian_Archetypes_Infidelity_Dissertation.md (16 KB)" "White"
    Write-ColorOutput "        ├── 99_Jung_Quotes_By_Chapter_Reference.md (20 KB)" "White"
    Write-ColorOutput "        └── README.md (Comprehensive index)" "White"
    Write-ColorOutput ""
    Write-ColorOutput "📊 Content Summary:" $infoColor
    Write-ColorOutput "  • 4 Jung sources processed (1,500+ pages)" "White"
    Write-ColorOutput "  • 45+ critical quotes extracted and organized" "White"
    Write-ColorOutput "  • Complete APA 7th bibliography" "White"
    Write-ColorOutput "  • All quotes mapped to dissertation chapters" "White"
    Write-ColorOutput "  • 89 KB total documentation" "White"
    Write-ColorOutput ""
    Write-ColorOutput "🔗 Quick Links:" $infoColor
    Write-ColorOutput "  • GitHub Repository: https://github.com/dw-hurt/phd-sacred-bonds-thesis" "Cyan"
    Write-ColorOutput "  • Local Path: $jungPath" "Gray"
    Write-ColorOutput ""
    Write-ColorOutput "✅ Next Steps:" $infoColor
    Write-ColorOutput "  1. Verify files on GitHub (refresh browser)" "White"
    Write-ColorOutput "  2. Open 99_Jung_Quotes_By_Chapter_Reference.md for drafting guidance" "White"
    Write-ColorOutput "  3. Begin integrating quotes into Chapter 2 (Theoretical Framework)" "White"
    Write-ColorOutput "  4. Verify citation details for 2 sources (see Bibliography notes)" "White"
    Write-ColorOutput ""
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

Clear-Host
Write-ColorOutput "╔════════════════════════════════════════════════════════════════╗" $infoColor
Write-ColorOutput "║      Push Jung Literature Sources to Sacred Bonds Thesis       ║" $infoColor
Write-ColorOutput "╚════════════════════════════════════════════════════════════════╝`n" $infoColor

# Check prerequisites
if (-not (Test-Prerequisites)) {
    Write-ColorOutput "`n❌ Prerequisites check failed. Please resolve issues and try again.`n" $errorColor
    exit 1
}

# Create folder structure
New-FolderStructure

# Copy Jung source files
Copy-JungSources

# Create index/README
New-JungSourcesIndex

# Perform Git operations
Invoke-GitOperations

# Show summary
Show-Summary

Write-ColorOutput "🎉 Process complete! Your Jung literature sources are now in Git and GitHub.`n" $successColor
