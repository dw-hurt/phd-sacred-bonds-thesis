# Upload-Sacred-Bonds-Thesis.ps1
# Simplified version - uploads Buss materials to Sacred Bonds thesis repository
# Author: PhD Automation Script
# Date: 2025-12-02

param(
    [string]$SourceDirectory = "C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis\thesis-materials",
    [string]$ThesisRepoPath = "C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis",
    [string]$GitHubRepo = "https://github.com/dw-hurt/phd-sacred-bonds-thesis.git",
    [string]$BranchName = "main",
    [switch]$DryRun
)

Write-Host "`n===============================================================" -ForegroundColor Magenta
Write-Host "   Sacred Bonds PhD Thesis - Upload Script" -ForegroundColor Magenta
Write-Host "===============================================================" -ForegroundColor Magenta

if ($DryRun) {
    Write-Host "`n[DRY RUN MODE - No changes will be made]`n" -ForegroundColor Yellow
}

Write-Host "`nConfiguration:" -ForegroundColor Cyan
Write-Host "  Source: $SourceDirectory" -ForegroundColor Gray
Write-Host "  Target: $ThesisRepoPath" -ForegroundColor Gray
Write-Host "  GitHub: $GitHubRepo`n" -ForegroundColor Gray

# File mapping
$FilesToCopy = @(
    @{
        Source = "Buss_Mens_Mating_Strategies_Summary.md"
        Dest = "Literature-Review\02-Evolutionary-Psychology\Mens-Long-Term-Mating\Buss_Mens_Long_Term_Mating_Strategies.md"
    },
    @{
        Source = "Buss_Key_Quotes.md"
        Dest = "Resources\Key-Quotes\Evolutionary-Psychology\Buss_Quotes_Mate_Preferences.md"
    },
    @{
        Source = "Bibliography_Buss_Evolutionary_Psychology.md"
        Dest = "Bibliography\Primary-Sources\Buss_Evolutionary_Psychology_Handbook.md"
    },
    @{
        Source = "Buss_Mens_Mating_Integration_Guide.md"
        Dest = "Research-Notes\Integration-Guides\Buss_Integration_Sacred_Bonds.md"
    },
    @{
        Source = "Buss_Comparative_Analysis.md"
        Dest = "Analysis\Theoretical-Frameworks\Evolutionary-vs-Social\Buss_Comparative_Framework_Analysis.md"
    }
)

# Directories to create
$Directories = @(
    "Literature-Review\01-Sacred-Traditions",
    "Literature-Review\02-Evolutionary-Psychology\Mens-Long-Term-Mating",
    "Literature-Review\02-Evolutionary-Psychology\Womens-Mate-Selection",
    "Literature-Review\03-Attachment-Theory",
    "Literature-Review\04-Neuroscience-of-Bonding",
    "Bibliography\Primary-Sources",
    "Bibliography\Secondary-Sources",
    "Resources\Key-Quotes\Evolutionary-Psychology",
    "Resources\Key-Quotes\Sacred-Texts",
    "Research-Notes\Integration-Guides",
    "Research-Notes\Synthesis-Documents",
    "Analysis\Theoretical-Frameworks\Evolutionary-vs-Social",
    "Analysis\Case-Studies",
    "Chapters\Chapter-01-Introduction",
    "Chapters\Chapter-02-Theoretical-Foundations",
    "Appendices"
)

# Step 1: Validate source files
Write-Host "[1/7] Validating source files..." -ForegroundColor Cyan
$MissingFiles = @()
foreach ($file in $FilesToCopy) {
    $sourcePath = Join-Path $SourceDirectory $file.Source
    if (Test-Path $sourcePath) {
        Write-Host "  OK: $($file.Source)" -ForegroundColor Green
    } else {
        Write-Host "  MISSING: $($file.Source)" -ForegroundColor Red
        $MissingFiles += $file.Source
    }
}

if ($MissingFiles.Count -gt 0) {
    Write-Host "`nERROR: Missing $($MissingFiles.Count) file(s). Cannot proceed." -ForegroundColor Red
    exit 1
}
Write-Host "  All 5 files validated!" -ForegroundColor Green

# Step 2: Create directory structure
Write-Host "`n[2/7] Creating directory structure..." -ForegroundColor Cyan
foreach ($dir in $Directories) {
    $fullPath = Join-Path $ThesisRepoPath $dir
    if (-not $DryRun) {
        if (-not (Test-Path $fullPath)) {
            New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
            Write-Host "  Created: $dir" -ForegroundColor Green
        }
    } else {
        Write-Host "  [DRY RUN] Would create: $dir" -ForegroundColor Gray
    }
}
Write-Host "  Directory structure ready!" -ForegroundColor Green

# Step 3: Copy files
Write-Host "`n[3/7] Copying research files..." -ForegroundColor Cyan
foreach ($file in $FilesToCopy) {
    $sourcePath = Join-Path $SourceDirectory $file.Source
    $destPath = Join-Path $ThesisRepoPath $file.Dest
    $destDir = Split-Path -Parent $destPath
    
    if (-not $DryRun) {
        if (-not (Test-Path $destDir)) {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        }
        Copy-Item -Path $sourcePath -Destination $destPath -Force
        Write-Host "  Copied: $($file.Source)" -ForegroundColor Green
        Write-Host "      -> $($file.Dest)" -ForegroundColor DarkGray
    } else {
        Write-Host "  [DRY RUN] Would copy: $($file.Source)" -ForegroundColor Gray
    }
}
Write-Host "  All files copied!" -ForegroundColor Green

# Step 4: Create README.md
Write-Host "`n[4/7] Creating thesis README.md..." -ForegroundColor Cyan
$readmePath = Join-Path $ThesisRepoPath "README.md"
if (-not $DryRun) {
    $readmeText = "# Sacred Bonds PhD Thesis`n`n"
    $readmeText += "An interdisciplinary analysis of long-term pair bonding.`n`n"
    $readmeText += "## Recent Updates - $(Get-Date -Format 'yyyy-MM-dd')`n`n"
    $readmeText += "Added Buss evolutionary psychology materials:`n"
    $readmeText += "- Men's long-term mating strategies summary`n"
    $readmeText += "- Key quotes and bibliography`n"
    $readmeText += "- Integration guide and comparative analysis`n`n"
    $readmeText += "## Repository Structure`n`n"
    $readmeText += "- Literature-Review/ - Research summaries by discipline`n"
    $readmeText += "- Bibliography/ - Citations and references`n"
    $readmeText += "- Resources/ - Quotes, notes, tools`n"
    $readmeText += "- Research-Notes/ - Integration guides`n"
    $readmeText += "- Analysis/ - Comparative analyses`n"
    $readmeText += "- Chapters/ - Thesis chapter drafts`n"
    
    Set-Content -Path $readmePath -Value $readmeText -Force
    Write-Host "  README.md created!" -ForegroundColor Green
} else {
    Write-Host "  [DRY RUN] Would create README.md" -ForegroundColor Gray
}

# Step 5: Create SUMMARY.md for GitBook
Write-Host "`n[5/7] Creating SUMMARY.md for GitBook..." -ForegroundColor Cyan
$summaryPath = Join-Path $ThesisRepoPath "SUMMARY.md"
if (-not $DryRun) {
    $summaryText = "# Table of Contents`n`n"
    $summaryText += "* [Sacred Bonds Thesis](README.md)`n`n"
    $summaryText += "## Literature Review`n`n"
    $summaryText += "* [Evolutionary Psychology](Literature-Review/02-Evolutionary-Psychology/Mens-Long-Term-Mating/Buss_Mens_Long_Term_Mating_Strategies.md)`n`n"
    $summaryText += "## Bibliography`n`n"
    $summaryText += "* [Primary Sources](Bibliography/Primary-Sources/Buss_Evolutionary_Psychology_Handbook.md)`n`n"
    $summaryText += "## Resources`n`n"
    $summaryText += "* [Key Quotes](Resources/Key-Quotes/Evolutionary-Psychology/Buss_Quotes_Mate_Preferences.md)`n`n"
    $summaryText += "## Research Notes`n`n"
    $summaryText += "* [Integration Guides](Research-Notes/Integration-Guides/Buss_Integration_Sacred_Bonds.md)`n`n"
    $summaryText += "## Analysis`n`n"
    $summaryText += "* [Theoretical Frameworks](Analysis/Theoretical-Frameworks/Evolutionary-vs-Social/Buss_Comparative_Framework_Analysis.md)`n"
    
    Set-Content -Path $summaryPath -Value $summaryText -Force
    Write-Host "  SUMMARY.md created!" -ForegroundColor Green
} else {
    Write-Host "  [DRY RUN] Would create SUMMARY.md" -ForegroundColor Gray
}

# Step 6: Create .gitbook.yaml
Write-Host "`n[6/7] Creating .gitbook.yaml..." -ForegroundColor Cyan
$gitbookConfigPath = Join-Path $ThesisRepoPath ".gitbook.yaml"
if (-not $DryRun) {
    $gitbookConfig = "root: ./`n`nstructure:`n  readme: README.md`n  summary: SUMMARY.md`n"
    Set-Content -Path $gitbookConfigPath -Value $gitbookConfig -Force
    Write-Host "  .gitbook.yaml created!" -ForegroundColor Green
} else {
    Write-Host "  [DRY RUN] Would create .gitbook.yaml" -ForegroundColor Gray
}

# Step 7: Git operations
Write-Host "`n[7/7] Git operations..." -ForegroundColor Cyan
Push-Location $ThesisRepoPath

try {
    if (-not $DryRun) {
        # Initialize Git if needed
        if (-not (Test-Path ".git")) {
            git init
            Write-Host "  Git repository initialized" -ForegroundColor Green
        }
        
        # Add remote if needed
        $remotes = git remote 2>$null
        if ($remotes -notcontains "origin") {
            git remote add origin $GitHubRepo
            Write-Host "  Remote 'origin' added" -ForegroundColor Green
        }
        
        # Rename branch to main if needed
        $currentBranch = git branch --show-current 2>$null
        if ($currentBranch -and $currentBranch -ne $BranchName) {
            git branch -M $BranchName
            Write-Host "  Branch renamed to '$BranchName'" -ForegroundColor Green
        }
        
        # Stage, commit, push
        git add .
        Write-Host "  Files staged" -ForegroundColor Green
        
        $commitMsg = "Add Buss evolutionary psychology materials ($(Get-Date -Format 'yyyy-MM-dd'))"
        git commit -m $commitMsg
        Write-Host "  Changes committed" -ForegroundColor Green
        
        git push -u origin $BranchName
        Write-Host "  Pushed to GitHub!" -ForegroundColor Green
        
    } else {
        Write-Host "  [DRY RUN] Would execute git commands" -ForegroundColor Gray
    }
} catch {
    Write-Host "  Git operation encountered an issue: $_" -ForegroundColor Yellow
    Write-Host "  You may need to push manually or configure credentials" -ForegroundColor Yellow
} finally {
    Pop-Location
}

# Summary
Write-Host "`n===============================================================" -ForegroundColor Magenta
Write-Host "                   UPLOAD COMPLETE!" -ForegroundColor Magenta
Write-Host "===============================================================" -ForegroundColor Magenta

Write-Host "`nSummary:" -ForegroundColor Cyan
Write-Host "  Files uploaded: 5" -ForegroundColor White
Write-Host "  Directories created: $($Directories.Count)" -ForegroundColor White
Write-Host "  Repository: $ThesisRepoPath" -ForegroundColor White

Write-Host "`nNext Steps:" -ForegroundColor Yellow
Write-Host "  1. Verify on GitHub: $GitHubRepo" -ForegroundColor White
Write-Host "  2. Set up GitBook at: https://gitbook.com" -ForegroundColor White
Write-Host "  3. Connect GitBook to your repository" -ForegroundColor White

if ($DryRun) {
    Write-Host "`n[DRY RUN COMPLETE] Re-run without -DryRun to execute" -ForegroundColor Yellow
}

Write-Host ""
