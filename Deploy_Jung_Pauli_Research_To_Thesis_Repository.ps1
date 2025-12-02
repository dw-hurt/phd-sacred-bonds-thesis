# PowerShell Deployment Script: Jung-Pauli Research Integration
# Repository: https://github.com/dw-hurt/phd-sacred-bonds-thesis
# Date: 2025-11-30
# Purpose: Deploy Jung-Pauli research materials to thesis repository

<#
.SYNOPSIS
    Deploys Jung-Pauli research materials to PhD thesis repository with proper organization.

.DESCRIPTION
    This script:
    1. Creates directory structure in thesis repository
    2. Copies Jung-Pauli research documents to appropriate locations
    3. Updates research index with new materials
    4. Commits and pushes changes to GitHub

.NOTES
    Prerequisites:
    - PowerShell 5.1 or higher
    - Git installed and configured
    - Write access to repository
    - Files downloaded to same directory as script
#>

# Script configuration
$RepositoryPath = "C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis"
$BranchName = "main"
$CommitMessage = "Add Jung-Pauli quantum mechanics collaboration research: unus mundus, synchronicity, dual-aspect monism integration"

# File mappings (source filename -> destination path in repository)
$FileMapping = @{
    "Jung_Pauli_Primary_Source_1_Zabriskie_Summary.md" = "research/theoretical-framework/jung-pauli/"
    "Jung_Pauli_Primary_Source_2_Atmanspacher_Summary.md" = "research/theoretical-framework/jung-pauli/"
    "Jung_Pauli_Quotes_by_Chapter_and_Theme.md" = "research/quotes/"
    "Jung_Pauli_Integration_Guide_for_Thesis.md" = "notes/integration-guides/"
    "Jung_Pauli_Comparative_Analysis_Across_Research.md" = "research/comparative-analysis/"
}

# Color output functions
function Write-Success { param($Message) Write-Host "✓ $Message" -ForegroundColor Green }
function Write-Info { param($Message) Write-Host "→ $Message" -ForegroundColor Cyan }
function Write-Warning { param($Message) Write-Host "⚠ $Message" -ForegroundColor Yellow }
function Write-Error { param($Message) Write-Host "✗ $Message" -ForegroundColor Red }

# Main deployment function
function Deploy-JungPauliResearch {
    Write-Host "`n=====================================" -ForegroundColor Magenta
    Write-Host "Jung-Pauli Research Deployment Script" -ForegroundColor Magenta
    Write-Host "=====================================" -ForegroundColor Magenta
    Write-Host ""

    # Step 1: Verify repository exists
    Write-Info "Verifying repository path..."
    if (-not (Test-Path $RepositoryPath)) {
        Write-Error "Repository not found at: $RepositoryPath"
        Write-Info "Please update `$RepositoryPath variable to correct location"
        return
    }
    Write-Success "Repository found: $RepositoryPath"

    # Step 2: Navigate to repository
    Write-Info "Navigating to repository..."
    Push-Location $RepositoryPath

    # Step 3: Verify Git repository
    Write-Info "Verifying Git repository..."
    if (-not (Test-Path ".git")) {
        Write-Error "Not a Git repository"
        Pop-Location
        return
    }
    Write-Success "Git repository verified"

    # Step 4: Check current branch
    $CurrentBranch = git rev-parse --abbrev-ref HEAD
    Write-Info "Current branch: $CurrentBranch"
    if ($CurrentBranch -ne $BranchName) {
        Write-Warning "Not on '$BranchName' branch. Switching..."
        git checkout $BranchName
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Failed to switch to '$BranchName' branch"
            Pop-Location
            return
        }
    }

    # Step 5: Pull latest changes
    Write-Info "Pulling latest changes from remote..."
    git pull origin $BranchName
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "Pull failed or conflicts exist. Proceeding with caution..."
    } else {
        Write-Success "Repository updated"
    }

    # Step 6: Create directory structure
    Write-Info "Creating directory structure..."
    $DirectoriesToCreate = @(
        "research/theoretical-framework/jung-pauli",
        "research/quotes",
        "notes/integration-guides",
        "research/comparative-analysis"
    )

    foreach ($Dir in $DirectoriesToCreate) {
        $FullPath = Join-Path $RepositoryPath $Dir
        if (-not (Test-Path $FullPath)) {
            New-Item -ItemType Directory -Path $FullPath -Force | Out-Null
            Write-Success "Created directory: $Dir"
        } else {
            Write-Info "Directory already exists: $Dir"
        }
    }

    # Step 7: Copy research files
    Write-Info "Copying Jung-Pauli research files..."
    $ScriptDirectory = $PSScriptRoot
    if ([string]::IsNullOrEmpty($ScriptDirectory)) {
        $ScriptDirectory = Get-Location
    }

    $FilesCopied = 0
    $FilesSkipped = 0

    foreach ($Entry in $FileMapping.GetEnumerator()) {
        $SourceFile = Join-Path $ScriptDirectory $Entry.Key
        $DestinationDir = Join-Path $RepositoryPath $Entry.Value
        $DestinationFile = Join-Path $DestinationDir $Entry.Key

        if (Test-Path $SourceFile) {
            Copy-Item -Path $SourceFile -Destination $DestinationFile -Force
            $FileSize = (Get-Item $SourceFile).Length
            $FileSizeKB = [math]::Round($FileSize / 1KB, 2)
            Write-Success "Copied: $($Entry.Key) ($FileSizeKB KB) → $($Entry.Value)"
            $FilesCopied++
        } else {
            Write-Warning "Source file not found: $($Entry.Key)"
            $FilesSkipped++
        }
    }

    Write-Host ""
    Write-Info "Files copied: $FilesCopied"
    if ($FilesSkipped -gt 0) {
        Write-Warning "Files skipped: $FilesSkipped"
    }

    # Step 8: Create/update research index
    Write-Info "Updating research index..."
    $IndexPath = Join-Path $RepositoryPath "research/RESEARCH_INDEX.md"
    
    $IndexContent = @"
# Research Materials Index
**Last Updated:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

## Theoretical Framework

### Jung-Pauli Quantum Mechanics Collaboration
**Location:** ``research/theoretical-framework/jung-pauli/``

**Primary Sources:**
1. **Jung_Pauli_Primary_Source_1_Zabriskie_Summary.md**
   - Source: Beverley Zabriskie, "Jung and Pauli: A Meeting of Rare Minds" (Princeton)
   - Content: 26-year collaboration, unus mundus, synchronicity, psychoid archetypes
   - Key Concepts: Pauli's 1,300 dreams, therapeutic relationship, joint 1952 publication

2. **Jung_Pauli_Primary_Source_2_Atmanspacher_Summary.md**
   - Source: Harald Atmanspacher, "Dual-Aspect Monism à la Pauli and Jung" (JCS 2012)
   - Content: Philosophical rigor, complementarity types, measurement problem
   - Key Concepts: Ontic/epistemic distinction, acausal orderedness, psychoid interfaces

**Support Materials:**
- **Quotes Database:** ``research/quotes/Jung_Pauli_Quotes_by_Chapter_and_Theme.md``
  - 50+ quotes organized by thesis chapter and theme
  - Ready-to-cite passages with full attribution

- **Integration Guide:** ``notes/integration-guides/Jung_Pauli_Integration_Guide_for_Thesis.md``
  - Chapter-by-chapter implementation strategies
  - Writing techniques and citation examples
  - Methodological applications

- **Comparative Analysis:** ``research/comparative-analysis/Jung_Pauli_Comparative_Analysis_Across_Research.md``
  - Cross-integration with existing research (thesis, novel, SF analysis)
  - Convergences, tensions, synthesis opportunities
  - Unified theoretical vision

## Key Concepts Covered

### Unus Mundus
- Psychophysically neutral domain underlying mind-matter distinction
- Source of archetypes, synchronicity, complementarity
- Application: AI as psychoid interface exploiting ontological ambiguity

### Synchronicity
- Acausal meaningful coincidence (vs. algorithmic determinism)
- Three conditions: dual components, acausality, shared meaning
- Application: Pseudo-synchronicity in AI companionship

### Complementarity
- Mutually exclusive yet jointly necessary aspects
- Type 1: Non-commutative operations (quantum physics)
- Type 2: Incompatible descriptions (conceptual)
- Application: Conscious choice / Unconscious desire in AI relationships

### Archetypes
- Psychophysically neutral ordering principles
- Manifest as physical laws + psychological images
- Application: AI exploitation of anima/animus, mother, self archetypes

### Psychoid
- Transcendental realm where psyche and matter interpenetrate
- Neither purely physical nor purely mental
- Application: AI as genuinely psychoid phenomenon

### Measurement Problem
- Observation collapses wave function (physics)
- Awareness brings unconscious to consciousness (psychology)
- Application: Self-report alters AI relationship dynamics

## Integration Status

- [x] Primary sources summarized (2 documents)
- [x] Quotes database compiled (50+ quotes)
- [x] Integration guide drafted (chapter-by-chapter strategies)
- [x] Comparative analysis completed (cross-research synthesis)
- [ ] Chapter 2 revision (add Jung-Pauli section) - **IN PROGRESS**
- [ ] Chapter 5 reinterpretation (psychoid AI findings) - **PENDING**
- [ ] Chapter 7 expansion (ontological harm ethics) - **PENDING**

## Repository Links

- **Thesis:** https://github.com/dw-hurt/phd-sacred-bonds-thesis
- **Novel:** https://github.com/dw-hurt/novelization-of-sacred-bonds

## Citation Information

**Primary References:**
- Meier, C.A. (Ed.). (2001). *Atom and Archetype: The Pauli/Jung Letters, 1932-1958*. Princeton University Press.
- Atmanspacher, H. (2012). Dual-aspect monism à la Pauli and Jung. *Journal of Consciousness Studies*, 19(9-10), 1-20.
- Jung, C.G. (1946/1954). *On the Nature of the Psyche* (CW 8).
- Jung, C.G. & Pauli, W. (1952). *Naturerklärung und Psyche*. Zurich: Rascher.
- von Meyenn, K. (Ed.). (1985-2005). *Wolfgang Pauli: Wissenschaftlicher Briefwechsel* (8 vols.). Berlin: Springer.

---

**Document Generated:** $(Get-Date -Format "yyyy-MM-dd")  
**By:** Deploy_Jung_Pauli_Research_To_Thesis_Repository.ps1  
**Status:** Jung-Pauli integration materials ready for thesis revision
"@

    Set-Content -Path $IndexPath -Value $IndexContent -Encoding UTF8
    Write-Success "Research index updated: $IndexPath"

    # Step 9: Stage changes
    Write-Info "Staging changes for commit..."
    git add research/theoretical-framework/jung-pauli/*
    git add research/quotes/Jung_Pauli_*
    git add notes/integration-guides/Jung_Pauli_*
    git add research/comparative-analysis/Jung_Pauli_*
    git add research/RESEARCH_INDEX.md

    # Step 10: Check status
    Write-Info "Checking git status..."
    $GitStatus = git status --porcelain
    if ([string]::IsNullOrEmpty($GitStatus)) {
        Write-Warning "No changes to commit (files may already exist)"
        Pop-Location
        return
    }

    Write-Host ""
    Write-Host "Changes to be committed:" -ForegroundColor Yellow
    git status --short

    # Step 11: Commit changes
    Write-Host ""
    Write-Info "Committing changes..."
    git commit -m $CommitMessage

    if ($LASTEXITCODE -ne 0) {
        Write-Error "Commit failed"
        Pop-Location
        return
    }

    $CommitHash = git rev-parse --short HEAD
    Write-Success "Committed: $CommitHash"

    # Step 12: Push to remote
    Write-Host ""
    Write-Info "Pushing to GitHub..."
    git push origin $BranchName

    if ($LASTEXITCODE -ne 0) {
        Write-Error "Push failed - check authentication and network connection"
        Write-Warning "Changes are committed locally. You can push manually later with:"
        Write-Host "    cd `"$RepositoryPath`""
        Write-Host "    git push origin $BranchName"
        Pop-Location
        return
    }

    Write-Success "Pushed to GitHub successfully"

    # Step 13: Display summary
    Write-Host ""
    Write-Host "=====================================" -ForegroundColor Magenta
    Write-Host "Deployment Complete!" -ForegroundColor Magenta
    Write-Host "=====================================" -ForegroundColor Magenta
    Write-Host ""
    Write-Success "Jung-Pauli research materials deployed to thesis repository"
    Write-Host ""
    Write-Info "Repository: https://github.com/dw-hurt/phd-sacred-bonds-thesis"
    Write-Info "Commit: $CommitHash"
    Write-Host ""
    Write-Host "Files Deployed:" -ForegroundColor Yellow
    Write-Host "  → research/theoretical-framework/jung-pauli/ (2 primary sources)"
    Write-Host "  → research/quotes/ (1 quote database)"
    Write-Host "  → notes/integration-guides/ (1 integration guide)"
    Write-Host "  → research/comparative-analysis/ (1 comparative analysis)"
    Write-Host "  → research/RESEARCH_INDEX.md (updated)"
    Write-Host ""
    Write-Host "Next Steps:" -ForegroundColor Yellow
    Write-Host "  1. Review deployed materials in GitHub"
    Write-Host "  2. Begin Chapter 2 revision (add Jung-Pauli section)"
    Write-Host "  3. Reinterpret Chapter 5 findings through psychoid AI lens"
    Write-Host "  4. Expand Chapter 7 ethics with ontological harm framework"
    Write-Host "  5. Use quotes database for citation integration"
    Write-Host ""
    Write-Host "Priority: PhD thesis completion by Feb 28, 2025" -ForegroundColor Cyan
    Write-Host ""

    # Return to original directory
    Pop-Location
}

# Execute deployment
try {
    Deploy-JungPauliResearch
    Write-Host "Press any key to exit..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
catch {
    Write-Error "Deployment failed with error: $_"
    Write-Host "Press any key to exit..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
