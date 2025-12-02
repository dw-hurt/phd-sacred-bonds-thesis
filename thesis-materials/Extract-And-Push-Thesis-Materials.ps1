<![CDATA[# Extract-And-Push-Thesis-Materials.ps1
# Automates extraction of thesis materials, GitHub push, and GitBook integration
# Author: PhD Automation Script
# Date: 2025-12-02

param(
    [string]$SourceDirectory = "C:\Users\user\Documents\GitHub\thesis-materials",
    [string]$GitHubRepo = "https://github.com/dw-hurt/pie-framework-private.git",
    [string]$GitHubUsername = "dw-hurt",
    [string]$BranchName = "main",
    [switch]$PushToPublic,
    [string]$PublicRepo = "https://github.com/dw-hurt/pie-framework-garden.git",
    [switch]$DryRun
)

# Color-coded output functions
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

# Configuration
$ThesisMaterials = @(
    @{
        File = "Buss_Mens_Mating_Strategies_Summary.md"
        Category = "Literature-Review"
        SubFolder = "Evolutionary-Psychology"
        Visibility = "Private"
    },
    @{
        File = "Buss_Key_Quotes.md"
        Category = "Literature-Review"
        SubFolder = "Evolutionary-Psychology"
        Visibility = "Private"
    },
    @{
        File = "Bibliography_Buss_Evolutionary_Psychology.md"
        Category = "Bibliography"
        SubFolder = "Primary-Sources"
        Visibility = "Both"
    },
    @{
        File = "Buss_Mens_Mating_Integration_Guide.md"
        Category = "Research-Integration"
        SubFolder = "Integration-Guides"
        Visibility = "Private"
    },
    @{
        File = "Buss_Comparative_Analysis.md"
        Category = "Analysis"
        SubFolder = "Comparative-Studies"
        Visibility = "Private"
    }
)

# Initialize
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host "  PhD Thesis Materials - GitHub & GitBook Automation" -ForegroundColor Magenta
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Magenta

if ($DryRun) {
    Write-Warning "DRY RUN MODE - No changes will be made"
}

# Step 1: Verify source files exist
Write-Step "Verifying source files..."

$MissingFiles = @()
foreach ($material in $ThesisMaterials) {
    $filePath = Join-Path $SourceDirectory $material.File
    if (Test-Path $filePath) {
        Write-Success "Found: $($material.File)"
    } else {
        Write-Error "Missing: $($material.File)"
        $MissingFiles += $material.File
    }
}

if ($MissingFiles.Count -gt 0) {
    Write-Error "Cannot proceed - missing $($MissingFiles.Count) files"
    exit 1
}

# Step 2: Create directory structure in private repo
Write-Step "Setting up directory structure..."

$PrivateRepoPath = "C:\Users\user\Documents\GitHub\pie-framework-private"

if (-not (Test-Path $PrivateRepoPath)) {
    Write-Error "Private repository not found at: $PrivateRepoPath"
    exit 1
}

$DirectoryStructure = @(
    "Literature-Review\Evolutionary-Psychology",
    "Bibliography\Primary-Sources",
    "Research-Integration\Integration-Guides",
    "Analysis\Comparative-Studies"
)

foreach ($dir in $DirectoryStructure) {
    $fullPath = Join-Path $PrivateRepoPath $dir
    if (-not (Test-Path $fullPath)) {
        if (-not $DryRun) {
            New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
            Write-Success "Created: $dir"
        } else {
            Write-Host "  [DRY RUN] Would create: $dir" -ForegroundColor Gray
        }
    } else {
        Write-Host "  → Exists: $dir" -ForegroundColor DarkGray
    }
}

# Step 3: Copy files to private repository
Write-Step "Copying files to private repository..."

foreach ($material in $ThesisMaterials) {
    $sourcePath = Join-Path $SourceDirectory $material.File
    $destDir = Join-Path $PrivateRepoPath (Join-Path $material.Category $material.SubFolder)
    $destPath = Join-Path $destDir $material.File
    
    if (-not $DryRun) {
        Copy-Item -Path $sourcePath -Destination $destPath -Force
        Write-Success "Copied: $($material.File) → $($material.Category)\$($material.SubFolder)"
    } else {
        Write-Host "  [DRY RUN] Would copy: $($material.File)" -ForegroundColor Gray
    }
}

# Step 4: Update private repository index
Write-Step "Creating/updating repository index..."

$IndexContent = @"
# PIE Framework - Private Research Repository

## Document Index - Updated $(Get-Date -Format "yyyy-MM-dd HH:mm")

### Literature Review
#### Evolutionary Psychology
- [Buss - Men's Mating Strategies Summary](Literature-Review/Evolutionary-Psychology/Buss_Mens_Mating_Strategies_Summary.md)
- [Buss - Key Quotes](Literature-Review/Evolutionary-Psychology/Buss_Key_Quotes.md)

### Bibliography
#### Primary Sources
- [Buss - Evolutionary Psychology (Bibliography)](Bibliography/Primary-Sources/Bibliography_Buss_Evolutionary_Psychology.md)

### Research Integration
#### Integration Guides
- [Buss - Integration Guide](Research-Integration/Integration-Guides/Buss_Mens_Mating_Integration_Guide.md)

### Analysis
#### Comparative Studies
- [Buss - Comparative Analysis](Analysis/Comparative-Studies/Buss_Comparative_Analysis.md)

---

## Quick Links
- [PIE Framework Digital Garden (Public)](https://github.com/dw-hurt/pie-framework-garden)
- [Novel Repository (Public)](https://github.com/dw-hurt/pie-novelization-novel-2)

## Statistics
- Total Documents: $($ThesisMaterials.Count)
- Last Updated: $(Get-Date -Format "yyyy-MM-dd")
- Categories: $(($ThesisMaterials | Select-Object -ExpandProperty Category -Unique).Count)

"@

$indexPath = Join-Path $PrivateRepoPath "INDEX.md"
if (-not $DryRun) {
    Set-Content -Path $indexPath -Value $IndexContent -Force
    Write-Success "Created INDEX.md"
} else {
    Write-Host "  [DRY RUN] Would create INDEX.md" -ForegroundColor Gray
}

# Step 5: Git operations for private repository
Write-Step "Git operations - Private repository..."

Push-Location $PrivateRepoPath

try {
    if (-not $DryRun) {
        # Add files
        git add .
        Write-Success "Staged all changes"
        
        # Commit
        $commitMessage = "Add Buss evolutionary psychology materials ($(Get-Date -Format 'yyyy-MM-dd'))"
        git commit -m $commitMessage
        Write-Success "Committed: $commitMessage"
        
        # Push
        git push origin $BranchName
        Write-Success "Pushed to GitHub: $GitHubRepo"
    } else {
        Write-Host "  [DRY RUN] Would execute git commands:" -ForegroundColor Gray
        Write-Host "    git add ." -ForegroundColor DarkGray
        Write-Host "    git commit -m 'Add Buss evolutionary psychology materials...'" -ForegroundColor DarkGray
        Write-Host "    git push origin $BranchName" -ForegroundColor DarkGray
    }
} catch {
    Write-Error "Git operation failed: $_"
} finally {
    Pop-Location
}

# Step 6: Create sanitized versions for public repository (if requested)
if ($PushToPublic) {
    Write-Step "Preparing sanitized versions for public repository..."
    
    $PublicRepoPath = "C:\Users\user\Documents\GitHub\pie-framework-garden"
    
    if (-not (Test-Path $PublicRepoPath)) {
        Write-Error "Public repository not found at: $PublicRepoPath"
    } else {
        # Only copy materials marked as "Both" visibility
        $PublicMaterials = $ThesisMaterials | Where-Object { $_.Visibility -eq "Both" }
        
        foreach ($material in $PublicMaterials) {
            $sourcePath = Join-Path $SourceDirectory $material.File
            $destDir = Join-Path $PublicRepoPath "bibliography"
            
            if (-not (Test-Path $destDir)) {
                New-Item -ItemType Directory -Path $destDir -Force | Out-Null
            }
            
            $destPath = Join-Path $destDir $material.File
            
            if (-not $DryRun) {
                Copy-Item -Path $sourcePath -Destination $destPath -Force
                Write-Success "Copied to public: $($material.File)"
            } else {
                Write-Host "  [DRY RUN] Would copy to public: $($material.File)" -ForegroundColor Gray
            }
        }
        
        # Update public repository
        Push-Location $PublicRepoPath
        
        try {
            if (-not $DryRun) {
                git add .
                git commit -m "Add bibliography reference ($(Get-Date -Format 'yyyy-MM-dd'))"
                git push origin $BranchName
                Write-Success "Pushed to public repository"
            } else {
                Write-Host "  [DRY RUN] Would push to public repository" -ForegroundColor Gray
            }
        } catch {
            Write-Error "Public repo git operation failed: $_"
        } finally {
            Pop-Location
        }
    }
}

# Step 7: Generate GitBook integration report
Write-Step "Generating GitBook integration report..."

$GitBookReport = @"
# GitBook Integration Report
Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

## Files Added to Private Repository
$($ThesisMaterials | ForEach-Object { "- [$($_.File)]($($_.Category)/$($_.SubFolder)/$($_.File))" } | Out-String)

## Recommended GitBook Structure (Public Garden)

### Bibliography Section (Already Added)
- Public bibliography references available
- View at: https://github.com/dw-hurt/pie-framework-garden/tree/main/bibliography

### Next Steps for GitBook
1. **Navigate to GitBook**: https://gitbook.com
2. **Open Space**: PIE Framework Digital Garden
3. **Verify Git Sync**: Check that bibliography files appear
4. **Create New Pages**:
   - "Research Foundation" page linking to bibliography
   - "Evolutionary Psychology" subsection
   - Link to GitHub for full technical details

### Public vs Private Content Strategy
- **Public GitBook**: High-level summaries, bibliography, theoretical framework
- **Private GitHub**: Detailed analysis, integration guides, raw research notes
- **Sync Method**: Manual curation using Sync-ToPublicGarden.ps1 script

### GitBook Content Recommendations
Create these pages in your GitBook space:
1. **Bibliography** (already have markdown files)
2. **Theoretical Foundations** (summarize key concepts from integration guide)
3. **Research Themes** (high-level overview of comparative analysis)

## Repository Status
- Private Repo: $GitHubRepo
- Public Repo: $PublicRepo
- Local Private: $PrivateRepoPath
- Local Public: $PublicRepoPath

## Verification Commands
``````powershell
# Verify private repository
cd "$PrivateRepoPath"
git log --oneline -5
git status

# Verify public repository (if pushed)
cd "$PublicRepoPath"
git log --oneline -5
git status
``````

"@

$reportPath = Join-Path $PrivateRepoPath "GITBOOK_INTEGRATION_REPORT.md"
if (-not $DryRun) {
    Set-Content -Path $reportPath -Value $GitBookReport -Force
    Write-Success "Created GitBook integration report"
} else {
    Write-Host "  [DRY RUN] Would create integration report" -ForegroundColor Gray
}

# Summary
Write-Host "`n═══════════════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host "                    OPERATION COMPLETE" -ForegroundColor Magenta
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Magenta

Write-Host "`nSummary:" -ForegroundColor Cyan
Write-Host "  • Files processed: $($ThesisMaterials.Count)" -ForegroundColor White
Write-Host "  • Private repository updated: ✓" -ForegroundColor Green
if ($PushToPublic) {
    Write-Host "  • Public repository updated: ✓" -ForegroundColor Green
}

Write-Host "`nNext Steps:" -ForegroundColor Yellow
Write-Host "  1. Verify GitHub repositories:" -ForegroundColor White
Write-Host "     → $GitHubRepo" -ForegroundColor DarkGray
if ($PushToPublic) {
    Write-Host "     → $PublicRepo" -ForegroundColor DarkGray
}
Write-Host "  2. Open GitBook and sync: https://gitbook.com" -ForegroundColor White
Write-Host "  3. Review integration report: $reportPath" -ForegroundColor White

if ($DryRun) {
    Write-Host "`n[DRY RUN COMPLETE] Re-run without -DryRun to execute changes" -ForegroundColor Yellow
}
]]>