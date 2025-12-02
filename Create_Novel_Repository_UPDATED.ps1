#Requires -Version 5.1

<#
.SYNOPSIS
    Creates and initializes GitHub repository for "The Quantum of Connection" novel.

.DESCRIPTION
    This script:
    1. Creates local novel project directory structure
    2. Copies novel materials (outline, opening chapter)
    3. Initializes git repository
    4. Creates README and supporting files
    5. Creates GitHub repository and pushes to dw-hurt account
    6. Automatically copies novel files to project directory

.PARAMETER LocalPath
    Base path for novel project. Default: C:\Users\user\Documents\Novels

.PARAMETER RepositoryName
    GitHub repository name. Default: novelization-of-sacred-bonds

.PARAMETER GitHubUsername
    Your GitHub username. Default: dw-hurt

.PARAMETER NovelFilesPath
    Path containing novel files. Default: C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis

.PARAMETER SkipGitHubCreation
    If specified, only creates local repository without pushing to GitHub.

.EXAMPLE
    .\Create_Novel_Repository_UPDATED.ps1
    # Creates local repository and pushes to GitHub as dw-hurt

.EXAMPLE
    .\Create_Novel_Repository_UPDATED.ps1 -SkipGitHubCreation
    # Creates only local repository

.NOTES
    Author: PhD Automation Assistant
    Date: November 30, 2025
    Purpose: Initialize novel project repository for dw-hurt GitHub account
    
    Requirements:
    - Git installed and configured
    - GitHub CLI (gh) installed and authenticated for automatic repo creation
    - Or manual GitHub repo creation if gh not available
    
    Novel: "The Quantum of Connection"
    Based on: Sacred Bonds thesis research
    Genre: Literary Science Fiction
    GitHub: https://github.com/dw-hurt/novelization-of-sacred-bonds
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$LocalPath = "C:\Users\user\Documents\Novels",
    
    [Parameter(Mandatory=$false)]
    [string]$RepositoryName = "novelization-of-sacred-bonds",
    
    [Parameter(Mandatory=$false)]
    [string]$GitHubUsername = "dw-hurt",
    
    [Parameter(Mandatory=$false)]
    [string]$NovelFilesPath = "C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis",
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipGitHubCreation
)

# Color output functions
function Write-Step {
    param([string]$Message)
    Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║ $($Message.PadRight(60)) ║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "✓ $Message" -ForegroundColor Green
}

function Write-Info {
    param([string]$Message)
    Write-Host "ℹ $Message" -ForegroundColor Yellow
}

function Write-Fail {
    param([string]$Message)
    Write-Host "✗ $Message" -ForegroundColor Red
}

$ErrorActionPreference = "Stop"
$startTime = Get-Date

Write-Host @"

╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║     CREATE NOVEL REPOSITORY: THE QUANTUM OF CONNECTION      ║
║                                                              ║
║     Novelization of Sacred Bonds Thesis                     ║
║     GitHub: https://github.com/dw-hurt                      ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝

"@ -ForegroundColor Cyan

# ============================================================
# STEP 1: Verify Prerequisites
# ============================================================
Write-Step "STEP 1: Verifying Prerequisites"

# Check git
try {
    $gitVersion = git --version
    Write-Success "Git installed: $gitVersion"
} catch {
    Write-Fail "Git is not installed or not in PATH"
    Write-Info "Install from: https://git-scm.com/"
    exit 1
}

# Check git config
try {
    $gitUserName = git config user.name
    $gitUserEmail = git config user.email
    
    if ($gitUserName -and $gitUserEmail) {
        Write-Success "Git configured: $gitUserName <$gitUserEmail>"
    } else {
        Write-Fail "Git not fully configured"
        Write-Info "Configure with:"
        Write-Host "  git config --global user.name 'Your Name'"
        Write-Host "  git config --global user.email 'your.email@example.com'"
        exit 1
    }
} catch {
    Write-Fail "Could not verify git configuration"
    exit 1
}

Write-Success "GitHub username: $GitHubUsername"

# Check GitHub CLI (optional)
$ghInstalled = $false
try {
    $ghVersion = gh --version 2>$null
    if ($ghVersion) {
        Write-Success "GitHub CLI installed: $($ghVersion[0])"
        $ghInstalled = $true
    }
} catch {
    Write-Info "GitHub CLI not installed (optional)"
    if (-not $SkipGitHubCreation) {
        Write-Info "To enable automatic GitHub repo creation, install from: https://cli.github.com/"
        Write-Info "Or the script will provide manual instructions"
    }
}

# ============================================================
# STEP 2: Create Local Directory Structure
# ============================================================
Write-Step "STEP 2: Creating Local Directory Structure"

$projectPath = Join-Path $LocalPath $RepositoryName

if (Test-Path $projectPath) {
    Write-Fail "Directory already exists: $projectPath"
    $overwrite = Read-Host "Overwrite? (yes/no)"
    if ($overwrite -ne "yes") {
        Write-Info "Aborting. Please choose different path or repository name."
        exit 1
    }
    Remove-Item $projectPath -Recurse -Force
    Write-Success "Removed existing directory"
}

# Create directory structure
$directories = @(
    "",
    "manuscript",
    "manuscript\chapters",
    "manuscript\outlines",
    "research",
    "research\thesis-notes",
    "research\character-development",
    "research\world-building",
    "notes",
    "notes\writing-journal",
    "notes\revision-notes"
)

foreach ($dir in $directories) {
    $fullPath = Join-Path $projectPath $dir
    New-Item -Path $fullPath -ItemType Directory -Force | Out-Null
}

Write-Success "Created directory structure"
Write-Info "Project location: $projectPath"

# ============================================================
# STEP 3: Locate and Copy Novel Materials
# ============================================================
Write-Step "STEP 3: Locating and Copying Novel Materials"

# Search for novel files in likely locations
$searchPaths = @(
    $NovelFilesPath,
    "C:\Users\user\Documents",
    "C:\Users\user\Downloads",
    (Get-Location).Path
)

$sourceFiles = @{
    "Novel_Outline.md" = "manuscript\outlines\Novel_Outline_Complete.md"
    "Chapter_01_Opening.md" = "manuscript\chapters\Chapter_01_Opening.md"
    "NOVEL_PROJECT_GUIDE.md" = "research\NOVEL_PROJECT_GUIDE.md"
}

$copiedFiles = 0
$missingFiles = @()

foreach ($filename in $sourceFiles.Keys) {
    $found = $false
    
    foreach ($searchPath in $searchPaths) {
        $possiblePath = Join-Path $searchPath $filename
        if (Test-Path $possiblePath) {
            $destination = Join-Path $projectPath $sourceFiles[$filename]
            Copy-Item $possiblePath $destination -Force
            Write-Success "Copied: $filename → $($sourceFiles[$filename])"
            $copiedFiles++
            $found = $true
            break
        }
    }
    
    if (-not $found) {
        $missingFiles += $filename
        Write-Info "File not found in search paths: $filename"
    }
}

if ($copiedFiles -gt 0) {
    Write-Success "Copied $copiedFiles file(s)"
} else {
    Write-Fail "No novel files found to copy"
    Write-Info "Please ensure novel files are available in one of these locations:"
    foreach ($path in $searchPaths) {
        Write-Host "  - $path" -ForegroundColor White
    }
    exit 1
}

if ($missingFiles.Count -gt 0) {
    Write-Info "Missing files (optional): $($missingFiles -join ', ')"
}

# ============================================================
# STEP 4: Create Repository Files
# ============================================================
Write-Step "STEP 4: Creating Repository Files"

# Create README
$readmeContent = @"
# The Quantum of Connection

**A Novel Based on Sacred Bonds Research**

## About

*The Quantum of Connection* is a literary science fiction novel exploring consciousness, connection, and the nature of sacred bonds in a near-future society grappling with unprecedented disconnection.

### Genre
Literary Science Fiction / Philosophical Fiction

### Setting
2032-2033, primarily San Francisco Bay Area and Seattle

### Themes
- Individuation and personal growth through relationship
- Synchronicity and meaningful connection
- Quantum consciousness and archetypal psychology
- The search for authentic intimacy in a technologically mediated world
- Shadow integration and transformation
- Cultural evolution and collective awakening

### Inspiration
This novel synthesizes research from the PhD thesis *"Sacred Bonds: A Jungian Analysis of Connection in Twin Flame and Soulmate Relationships"* with literary fiction craft. It explores Jung's depth psychology, quantum consciousness theory, and the crisis of connection in contemporary Western society.

## Project Structure

``````
novelization-of-sacred-bonds/
├── manuscript/
│   ├── chapters/          # Individual chapter files
│   ├── outlines/          # Novel outline and plot development
│   └── drafts/            # Full manuscript drafts
├── research/
│   ├── thesis-notes/      # Notes from Sacred Bonds thesis
│   ├── character-development/
│   └── world-building/
├── notes/
│   ├── writing-journal/   # Process notes and reflections
│   └── revision-notes/    # Editing and revision tracking
└── README.md
``````

## Status

**Current Phase**: Outlining and opening chapter complete  
**Target Length**: 110,000-130,000 words  
**Estimated Completion**: 2026

## Writing Approach

This novel follows an Asimovian plotting style:
- Ideas-driven narrative
- Multiple POV characters
- Gradual revelation of deeper truths
- Scientific concepts woven into philosophical exploration
- Complex social and cultural implications

The voice is literary but accessible, exploring profound themes through lived human experience.

## Characters

### Primary
- **Dr. Marcus Chen** - Quantum physicist, 38, developing Entanglement Resonance Theory
- **Dr. Elena Volkov** - Jungian analyst, 36, studying archetypal patterns
- **Dr. Olivia Reeves** - AI scientist, 42, Chief Science Officer of SyntheticIntimacy
- **Thomas Mercer** - Data scientist, 31, creator of relationship abstinence app

### Secondary
- **Sarah** - Elena's client, navigating Sovereign Self movement
- **David** - Sarah's eventual partner
- **Rebecca** - Thomas's partner

## World-Building

### 2032 Social Context
- Marriage rates: 18% (down from 45% in 2020)
- Birth rates: 0.9 per woman
- "Relationship abstinence" movements mainstream
- AI intimacy companions (Companion 2.0) have 12 million subscribers
- "The Great Reconnection" begins as cultural shift

### Technology
- Advanced AI relationship simulation
- Neural interfacing for emotional experiences
- Quantum consciousness research (controversial)
- Behavioral modification algorithms

## Themes from Thesis Research

### Jungian Psychology
- Individuation as lifelong process
- Anima/animus integration
- Shadow work and transformation
- Synchronicity as meaningful connection
- Coniunctio (sacred marriage of opposites)

### Quantum Consciousness
- Consciousness as quantum phenomenon
- Entanglement across distance
- Observer effect in relationships
- Non-locality of awareness

### Cultural Analysis
- Demographic collapse in Western societies
- Technology as solution vs. problem
- Collective unconscious eruptions
- Archetypal patterns in cultural movements

## License

© $(Get-Date -Format yyyy) $gitUserName. All rights reserved.

This is a creative work in progress. Please do not reproduce or distribute without permission.

## Contact

**Author**: $gitUserName  
**Email**: $gitUserEmail  
**Thesis Repository**: https://github.com/$GitHubUsername/phd-sacred-bonds-thesis  
**Novel Repository**: https://github.com/$GitHubUsername/$RepositoryName

---

*"The quantum and the archetypal, entangled."*
"@

Set-Content -Path (Join-Path $projectPath "README.md") -Value $readmeContent -Encoding UTF8
Write-Success "Created README.md"

# Create .gitignore
$gitignoreContent = @"
# OS files
.DS_Store
Thumbs.db
*.tmp

# Editor files
*.swp
*.swo
*~
.vscode/
.idea/

# Backup files
*.bak
*.backup

# Private notes
notes/private/
*_PRIVATE.md

# Drafts not ready for commit
*_DRAFT_*.md

# Large files
*.pdf
*.docx
*.doc
"@

Set-Content -Path (Join-Path $projectPath ".gitignore") -Value $gitignoreContent -Encoding UTF8
Write-Success "Created .gitignore"

# Create initial writing journal entry
$journalContent = @"
# Writing Journal - $(Get-Date -Format 'yyyy-MM-dd')

## Project Initiation

Today I initialized the repository for *The Quantum of Connection*, a literary science fiction novel based on my Sacred Bonds thesis research.

### Initial Materials
- Complete novel outline (32 chapters, 4 parts)
- Opening chapter (Chapter 1: Marcus Chen's Laboratory)
- Project guide with character and world-building details

### Writing Goals
- Target length: 110,000-130,000 words
- Completion timeline: 2026
- Writing schedule: To be determined based on PhD thesis completion

### Next Steps
1. Review and refine outline based on opening chapter
2. Develop detailed character profiles
3. Expand world-building notes
4. Begin drafting Chapter 2 after PhD thesis submission

### Reflections
This novel represents a bridge between academic research and creative expression. The challenge will be to explore profound philosophical and psychological themes through compelling narrative and authentic character development.

The Asimovian approach—ideas-driven, multiple perspectives, gradual revelation—feels right for this material. The goal is not to explain the thesis but to *live* its questions through characters who embody different perspectives on consciousness, connection, and meaning.

### Thesis → Novel Transformation
Key academic concepts to explore narratively:
- **Individuation**: Through Marcus and Elena's personal journeys
- **Synchronicity**: Through meaningful encounters that drive plot
- **Shadow Integration**: Through character conflicts and growth
- **Collective Unconscious**: Through social movements and cultural shifts
- **Quantum Consciousness**: Through Marcus's scientific research

The novel will not cite sources or explain theory—it will embody these concepts through lived experience.

---
"@

$journalPath = Join-Path $projectPath "notes\writing-journal\$(Get-Date -Format 'yyyy-MM-dd')_InitialEntry.md"
Set-Content -Path $journalPath -Value $journalContent -Encoding UTF8
Write-Success "Created initial writing journal entry"

# ============================================================
# STEP 5: Initialize Git Repository
# ============================================================
Write-Step "STEP 5: Initializing Git Repository"

Set-Location $projectPath

git init
Write-Success "Initialized git repository"

git add .
Write-Success "Staged all files"

$commitMessage = "Initial commit: Novel outline and opening chapter

- Complete outline for The Quantum of Connection (32 chapters, 4 parts)
- Chapter 1: Marcus Chen's Laboratory (~5,000 words)
- Project structure and documentation
- README with project overview
- Writing journal entry
- Novel project guide with character and world-building details

Based on Sacred Bonds thesis research.
Literary SF exploring consciousness, connection, and individuation."

git commit -m $commitMessage
Write-Success "Created initial commit"

$commitHash = git rev-parse --short HEAD
Write-Info "Commit hash: $commitHash"

# ============================================================
# STEP 6: Create GitHub Repository
# ============================================================
Write-Step "STEP 6: GitHub Repository Setup"

if ($SkipGitHubCreation) {
    Write-Info "Skipping GitHub repository creation (user specified)"
    Write-Host "`nLocal repository created successfully at:" -ForegroundColor Green
    Write-Host "  $projectPath" -ForegroundColor White
    Write-Host "`nTo create GitHub repository manually:" -ForegroundColor Cyan
    Write-Host "  1. Go to: https://github.com/new" -ForegroundColor White
    Write-Host "  2. Repository name: $RepositoryName" -ForegroundColor White
    Write-Host "  3. Description: Literary SF novel based on Sacred Bonds research" -ForegroundColor White
    Write-Host "  4. Choose: Private (for unpublished creative work)" -ForegroundColor White
    Write-Host "  5. Do NOT initialize with README, .gitignore, or license" -ForegroundColor White
    Write-Host "  6. Click 'Create repository'" -ForegroundColor White
    Write-Host "`nThen push your local repository:" -ForegroundColor Cyan
    Write-Host "  git remote add origin https://github.com/$GitHubUsername/$RepositoryName.git" -ForegroundColor White
    Write-Host "  git branch -M main" -ForegroundColor White
    Write-Host "  git push -u origin main" -ForegroundColor White
} elseif ($ghInstalled) {
    # Use GitHub CLI to create repository
    Write-Info "Creating GitHub repository using GitHub CLI..."
    
    try {
        # Check if logged in
        gh auth status 2>$null
        $ghLoggedIn = $?
        
        if (-not $ghLoggedIn) {
            Write-Info "GitHub CLI not authenticated"
            Write-Info "Attempting to authenticate..."
            gh auth login
        }
        
        # Create repository (private by default for creative work)
        $repoDescription = "Literary science fiction novel based on Sacred Bonds thesis research. Explores consciousness, connection, and individuation in near-future society."
        
        gh repo create $RepositoryName --private --description $repoDescription --source=. --remote=origin --push
        
        Write-Success "GitHub repository created and pushed!"
        Write-Info "Repository URL: https://github.com/$GitHubUsername/$RepositoryName"
        
    } catch {
        Write-Fail "GitHub CLI creation failed: $_"
        Write-Info "Falling back to manual instructions..."
        $ghInstalled = $false
    }
}

if (-not $ghInstalled -and -not $SkipGitHubCreation) {
    Write-Info "GitHub CLI not available - providing manual setup instructions"
    
    Write-Host "`n═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  MANUAL GITHUB SETUP INSTRUCTIONS" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    
    Write-Host "`n1. Create GitHub Repository:" -ForegroundColor Yellow
    Write-Host "   Go to: https://github.com/new" -ForegroundColor White
    Write-Host "   Repository name: $RepositoryName" -ForegroundColor White
    Write-Host "   Description: Literary SF novel based on Sacred Bonds research" -ForegroundColor White
    Write-Host "   Visibility: Private (recommended for unpublished work)" -ForegroundColor White
    Write-Host "   Do NOT initialize with README, .gitignore, or license" -ForegroundColor White
    
    Write-Host "`n2. Connect Local Repository to GitHub:" -ForegroundColor Yellow
    Write-Host "   Run these commands from your project directory:" -ForegroundColor White
    Write-Host "   cd `"$projectPath`"" -ForegroundColor Cyan
    Write-Host "   git remote add origin https://github.com/$GitHubUsername/$RepositoryName.git" -ForegroundColor Cyan
    Write-Host "   git branch -M main" -ForegroundColor Cyan
    Write-Host "   git push -u origin main" -ForegroundColor Cyan
    
    Write-Host "`n3. Verify:" -ForegroundColor Yellow
    Write-Host "   Visit: https://github.com/$GitHubUsername/$RepositoryName" -ForegroundColor White
}

# ============================================================
# COMPLETION SUMMARY
# ============================================================
$endTime = Get-Date
$duration = ($endTime - $startTime).TotalSeconds

Write-Host "`n"
Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                                                              ║" -ForegroundColor Green
Write-Host "║              ✓ REPOSITORY CREATED SUCCESSFULLY              ║" -ForegroundColor Green
Write-Host "║                                                              ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Green

Write-Host "`n📚 Novel Project: The Quantum of Connection" -ForegroundColor Cyan
Write-Host "`n📁 Local Repository:" -ForegroundColor Cyan
Write-Host "   $projectPath" -ForegroundColor White

Write-Host "`n🌐 Target GitHub Repository:" -ForegroundColor Cyan
Write-Host "   https://github.com/$GitHubUsername/$RepositoryName" -ForegroundColor White

Write-Host "`n📊 Repository Contents:" -ForegroundColor Cyan
Write-Host "   ✓ Novel outline (32 chapters, 110k-130k words planned)" -ForegroundColor Green
Write-Host "   ✓ Chapter 1 complete (~5,000 words)" -ForegroundColor Green
Write-Host "   ✓ README and project documentation" -ForegroundColor Green
Write-Host "   ✓ Writing journal initialized" -ForegroundColor Green
Write-Host "   ✓ Directory structure for manuscript development" -ForegroundColor Green
if ($copiedFiles -gt 0) {
    Write-Host "   ✓ Copied $copiedFiles novel file(s)" -ForegroundColor Green
}

Write-Host "`n🎯 Next Steps:" -ForegroundColor Cyan
if ($ghInstalled) {
    Write-Host "   ✓ Repository pushed to GitHub automatically" -ForegroundColor Green
    Write-Host "   1. Verify repository at: https://github.com/$GitHubUsername/$RepositoryName" -ForegroundColor White
    Write-Host "   2. Review outline and opening chapter" -ForegroundColor White
    Write-Host "   3. Begin developing character profiles" -ForegroundColor White
} else {
    Write-Host "   1. Follow manual instructions above to push to GitHub" -ForegroundColor White
    Write-Host "   2. Verify repository at: https://github.com/$GitHubUsername/$RepositoryName" -ForegroundColor White
    Write-Host "   3. Review outline and opening chapter" -ForegroundColor White
    Write-Host "   4. Begin developing character profiles" -ForegroundColor White
}

Write-Host "`n⏱️  Execution Time: $([math]::Round($duration, 1)) seconds" -ForegroundColor Cyan

Write-Host "`n" -NoNewline
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "      Novel repository ready - Begin your writing journey!      " -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
