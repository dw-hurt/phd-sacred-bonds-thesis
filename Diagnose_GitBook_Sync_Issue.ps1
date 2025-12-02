#Requires -Version 5.1

<#
.SYNOPSIS
    Diagnoses synchronization issues between GitHub repository and GitBook.

.DESCRIPTION
    This script:
    1. Analyzes local repository structure and content
    2. Checks GitHub commit history and file status
    3. Identifies files in GitHub but potentially not visible in GitBook
    4. Specifically investigates abstract.md sync issues
    5. Checks SUMMARY.md registration
    6. Analyzes common GitBook sync problems
    7. Provides actionable recommendations

.PARAMETER RepoPath
    Path to thesis repository. Default: C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis

.PARAMETER AbstractPath
    Relative path to abstract file. Default: 00_front_matter/abstract.md

.PARAMETER CheckFiles
    Specific files to check (comma-separated). Default: checks key files

.EXAMPLE
    .\Diagnose_GitBook_Sync_Issue.ps1
    # Runs comprehensive diagnostic

.EXAMPLE
    .\Diagnose_GitBook_Sync_Issue.ps1 -CheckFiles "abstract.md,SUMMARY.md"
    # Checks specific files only

.NOTES
    Author: PhD Automation Assistant
    Date: November 30, 2025
    Purpose: Diagnose why GitHub content is not syncing to GitBook
    
    Common GitBook Sync Issues:
    1. File not registered in SUMMARY.md
    2. Incorrect file path in SUMMARY.md
    3. File name/path mismatch (case sensitivity)
    4. GitBook integration disconnected
    5. Branch mismatch (not syncing from 'main' branch)
    6. File format issues (encoding, special characters)
    7. GitBook sync delay (can take 2-10 minutes)
    
    GitBook URL: https://app.gitbook.com/o/cyZpWhV7KomErB6BnmVk/s/hRoSpCiTUrfuH62swMvH/
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$RepoPath = "C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis",
    
    [Parameter(Mandatory=$false)]
    [string]$AbstractPath = "00_front_matter/abstract.md",
    
    [Parameter(Mandatory=$false)]
    [string[]]$CheckFiles = @()
)

# Color output functions
function Write-Step {
    param([string]$Message)
    Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║ $($Message.PadRight(60)) ║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
}

function Write-SubStep {
    param([string]$Message)
    Write-Host "`n=== $Message ===" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "✓ $Message" -ForegroundColor Green
}

function Write-Info {
    param([string]$Message)
    Write-Host "ℹ $Message" -ForegroundColor Yellow
}

function Write-Warning {
    param([string]$Message)
    Write-Host "⚠ $Message" -ForegroundColor Magenta
}

function Write-Fail {
    param([string]$Message)
    Write-Host "✗ $Message" -ForegroundColor Red
}

function Write-Finding {
    param([string]$Message)
    Write-Host "→ $Message" -ForegroundColor White
}

# Main script
$ErrorActionPreference = "Stop"
$startTime = Get-Date
$issues = @()
$recommendations = @()

Write-Host @"

╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║     GITBOOK SYNC DIAGNOSTIC TOOL                            ║
║                                                              ║
║     Identify differences between GitHub and GitBook         ║
║     Diagnose abstract.md sync issues                        ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝

"@ -ForegroundColor Cyan

Write-Info "GitBook URL: https://app.gitbook.com/o/cyZpWhV7KomErB6BnmVk/s/hRoSpCiTUrfuH62swMvH/"
Write-Info "Repository: $RepoPath"
Write-Info "Diagnostic started: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"

# ============================================================
# STEP 1: Verify Repository and Git Status
# ============================================================
Write-Step "STEP 1: Repository & Git Status Check"

if (-not (Test-Path $RepoPath)) {
    Write-Fail "Repository not found at: $RepoPath"
    exit 1
}

Set-Location $RepoPath
Write-Success "Repository location verified"

# Check if git repository
if (-not (Test-Path ".git")) {
    Write-Fail "Not a git repository"
    exit 1
}
Write-Success "Git repository confirmed"

# Check current branch
$currentBranch = git branch --show-current
Write-Finding "Current branch: $currentBranch"

if ($currentBranch -ne "main") {
    Write-Warning "Not on 'main' branch! GitBook typically syncs from 'main'."
    $issues += "Currently on branch '$currentBranch' instead of 'main'"
    $recommendations += "Switch to 'main' branch: git checkout main"
}

# Check if there are uncommitted changes
$gitStatus = git status --porcelain
if ($gitStatus) {
    Write-Warning "Uncommitted changes detected:"
    $gitStatus | ForEach-Object { Write-Info "  $_" }
    $issues += "Uncommitted changes present"
    $recommendations += "Commit all changes: git add . && git commit -m 'message' && git push"
} else {
    Write-Success "Working directory clean (no uncommitted changes)"
}

# Check remote
$remoteUrl = git remote get-url origin
Write-Finding "Remote URL: $remoteUrl"

# Check if local is up to date with remote
Write-SubStep "Checking sync with remote"
try {
    git fetch origin 2>&1 | Out-Null
    
    $localCommit = git rev-parse HEAD
    $remoteCommit = git rev-parse origin/$currentBranch
    
    if ($localCommit -eq $remoteCommit) {
        Write-Success "Local repository is in sync with remote"
    } else {
        Write-Warning "Local and remote commits differ!"
        Write-Info "  Local:  $localCommit"
        Write-Info "  Remote: $remoteCommit"
        
        $behindCount = (git rev-list HEAD..origin/$currentBranch --count)
        $aheadCount = (git rev-list origin/$currentBranch..HEAD --count)
        
        if ($behindCount -gt 0) {
            Write-Warning "Local is $behindCount commit(s) behind remote"
            $issues += "Local repository behind remote by $behindCount commits"
            $recommendations += "Pull latest changes: git pull origin $currentBranch"
        }
        
        if ($aheadCount -gt 0) {
            Write-Warning "Local is $aheadCount commit(s) ahead of remote"
            $issues += "Local repository ahead of remote by $aheadCount commits"
            $recommendations += "Push local changes: git push origin $currentBranch"
        }
    }
} catch {
    Write-Warning "Could not check remote sync status: $_"
}

# Recent commits
Write-SubStep "Recent commits (last 5)"
$recentCommits = git log --oneline -5
$recentCommits | ForEach-Object { Write-Finding $_ }

# Check when abstract was last modified in commits
Write-SubStep "Abstract commit history"
$abstractCommits = git log --follow --oneline -- $AbstractPath.Replace("/", "\") | Select-Object -First 5
if ($abstractCommits) {
    Write-Info "Last 5 commits affecting abstract:"
    $abstractCommits | ForEach-Object { Write-Finding "  $_" }
} else {
    Write-Warning "No commit history found for abstract file!"
    $issues += "Abstract file has no commit history"
}

# ============================================================
# STEP 2: Abstract File Analysis
# ============================================================
Write-Step "STEP 2: Abstract File Analysis"

$abstractFullPath = Join-Path $RepoPath $AbstractPath.Replace("/", "\")
Write-Finding "Checking: $abstractFullPath"

if (-not (Test-Path $abstractFullPath)) {
    Write-Fail "Abstract file not found at: $abstractFullPath"
    $issues += "Abstract file does not exist at specified path"
    $recommendations += "Verify abstract file location: Get-ChildItem -Recurse -Filter 'abstract.md'"
} else {
    Write-Success "Abstract file exists"
    
    # File details
    $abstractFile = Get-Item $abstractFullPath
    $abstractSize = $abstractFile.Length
    $abstractSizeKB = [math]::Round($abstractSize / 1KB, 1)
    $abstractModified = $abstractFile.LastWriteTime
    
    Write-Finding "File size: $abstractSizeKB KB ($abstractSize bytes)"
    Write-Finding "Last modified: $abstractModified"
    
    # Check if file is empty or too small
    if ($abstractSize -lt 100) {
        Write-Warning "Abstract file is very small ($abstractSize bytes) - might be blank!"
        $issues += "Abstract file size is only $abstractSize bytes"
        $recommendations += "Review abstract content: notepad $abstractFullPath"
    } elseif ($abstractSize -lt 1000) {
        Write-Warning "Abstract file is smaller than expected ($abstractSizeKB KB)"
    } else {
        Write-Success "Abstract file has reasonable size ($abstractSizeKB KB)"
    }
    
    # Read and analyze content
    $abstractContent = Get-Content $abstractFullPath -Raw
    $wordCount = ($abstractContent -split '\s+').Count
    $lineCount = ($abstractContent -split "`n").Count
    
    Write-Finding "Word count: $wordCount"
    Write-Finding "Line count: $lineCount"
    
    if ($wordCount -lt 100) {
        Write-Warning "Abstract has very few words ($wordCount) - might not be complete"
        $issues += "Abstract word count is only $wordCount"
    } else {
        Write-Success "Abstract has substantial content ($wordCount words)"
    }
    
    # Check for special characters or encoding issues
    if ($abstractContent -match '[^\x00-\x7F]') {
        Write-Info "Abstract contains non-ASCII characters (may cause encoding issues)"
    }
    
    # Check if it starts with proper markdown
    if ($abstractContent -match '^#\s+') {
        Write-Success "Abstract starts with markdown heading"
    } else {
        Write-Warning "Abstract does not start with markdown heading (#)"
        $recommendations += "Consider adding a heading: # Abstract"
    }
    
    # Show first 200 characters
    Write-SubStep "Abstract preview (first 200 characters)"
    Write-Host $abstractContent.Substring(0, [Math]::Min(200, $abstractContent.Length)) -ForegroundColor Gray
    Write-Host "..." -ForegroundColor Gray
}

# ============================================================
# STEP 3: SUMMARY.md Analysis
# ============================================================
Write-Step "STEP 3: SUMMARY.md Analysis"

$summaryPath = Join-Path $RepoPath "SUMMARY.md"

if (-not (Test-Path $summaryPath)) {
    Write-Fail "SUMMARY.md not found!"
    $issues += "SUMMARY.md file is missing"
    $recommendations += "Create SUMMARY.md in repository root"
} else {
    Write-Success "SUMMARY.md exists"
    
    $summaryContent = Get-Content $summaryPath -Raw
    
    # Check if abstract is registered
    Write-SubStep "Checking abstract registration in SUMMARY.md"
    
    $abstractPatterns = @(
        "abstract\.md",
        "00_front_matter/abstract\.md",
        "front_matter/abstract\.md",
        "\[Abstract\]"
    )
    
    $abstractFound = $false
    $abstractEntry = ""
    
    foreach ($pattern in $abstractPatterns) {
        if ($summaryContent -match $pattern) {
            $abstractFound = $true
            # Extract the line
            $lines = $summaryContent -split "`n"
            $matchingLine = $lines | Where-Object { $_ -match $pattern } | Select-Object -First 1
            $abstractEntry = $matchingLine.Trim()
            break
        }
    }
    
    if ($abstractFound) {
        Write-Success "Abstract is registered in SUMMARY.md"
        Write-Finding "Entry: $abstractEntry"
        
        # Validate the path format
        if ($abstractEntry -match '\[([^\]]+)\]\(([^\)]+)\)') {
            $linkText = $matches[1]
            $linkPath = $matches[2]
            
            Write-Finding "Link text: '$linkText'"
            Write-Finding "Link path: '$linkPath'"
            
            # Check if path format is correct
            if ($linkPath -match '\\') {
                Write-Warning "Path uses backslashes (\) - should use forward slashes (/)"
                $issues += "SUMMARY.md uses Windows path separators (backslashes)"
                $recommendations += "Fix path format: Change '\' to '/' in SUMMARY.md"
            } else {
                Write-Success "Path format is correct (forward slashes)"
            }
            
            # Check if linked file exists
            $linkedFilePath = Join-Path $RepoPath $linkPath.Replace("/", "\")
            if (Test-Path $linkedFilePath) {
                Write-Success "Linked file exists at specified path"
            } else {
                Write-Fail "Linked file NOT found at: $linkedFilePath"
                $issues += "SUMMARY.md links to non-existent file: $linkPath"
                $recommendations += "Fix path in SUMMARY.md or move file to correct location"
            }
            
            # Check case sensitivity
            $actualFiles = Get-ChildItem -Path (Split-Path $linkedFilePath) -Filter "abstract.md" -ErrorAction SilentlyContinue
            if ($actualFiles -and ($actualFiles[0].Name -cne "abstract.md")) {
                Write-Warning "File name case mismatch: actual is '$($actualFiles[0].Name)'"
                $issues += "File name case sensitivity issue"
            }
            
        } else {
            Write-Warning "Could not parse link format in SUMMARY.md entry"
        }
        
    } else {
        Write-Fail "Abstract is NOT registered in SUMMARY.md!"
        $issues += "Abstract not listed in SUMMARY.md"
        $recommendations += "Add to SUMMARY.md: * [Abstract](00_front_matter/abstract.md)"
        
        Write-Info "This is likely why it's not visible in GitBook!"
    }
    
    # Check SUMMARY.md structure
    Write-SubStep "Analyzing SUMMARY.md structure"
    
    $summaryLines = $summaryContent -split "`n"
    $totalEntries = ($summaryLines | Where-Object { $_ -match '^\s*\*\s+\[' }).Count
    $headings = ($summaryLines | Where-Object { $_ -match '^#' }).Count
    
    Write-Finding "Total navigation entries: $totalEntries"
    Write-Finding "Section headings: $headings"
    
    if ($totalEntries -eq 0) {
        Write-Warning "SUMMARY.md has no navigation entries!"
        $issues += "SUMMARY.md is empty or malformed"
    }
    
    # Check for common issues
    $hasIntroduction = $summaryContent -match '\[Introduction\]'
    $hasFrontMatter = $summaryContent -match 'Front Matter|Abstract|Acknowledgements'
    
    if (-not $hasFrontMatter) {
        Write-Warning "SUMMARY.md does not have Front Matter section"
        $issues += "No Front Matter section in SUMMARY.md"
        $recommendations += "Add Front Matter section with Abstract entry"
    }
}

# ============================================================
# STEP 4: Directory Structure Validation
# ============================================================
Write-Step "STEP 4: Directory Structure Validation"

Write-SubStep "Checking front matter directory"

$frontMatterDirs = @(
    "00_front_matter",
    "front_matter",
    "00-front-matter"
)

$frontMatterFound = $false
$actualFrontMatterDir = ""

foreach ($dir in $frontMatterDirs) {
    $dirPath = Join-Path $RepoPath $dir
    if (Test-Path $dirPath) {
        Write-Success "Found front matter directory: $dir"
        $frontMatterFound = $true
        $actualFrontMatterDir = $dir
        
        # List contents
        $contents = Get-ChildItem $dirPath -Filter "*.md"
        Write-Finding "Contents of $dir`:"
        $contents | ForEach-Object { Write-Finding "  - $($_.Name)" }
        
        break
    }
}

if (-not $frontMatterFound) {
    Write-Warning "No front matter directory found!"
    $issues += "Front matter directory does not exist"
    $recommendations += "Create directory: mkdir 00_front_matter"
}

# Check for duplicate abstract files
Write-SubStep "Checking for duplicate abstract files"

$abstractFiles = Get-ChildItem -Path $RepoPath -Recurse -Filter "abstract.md" -ErrorAction SilentlyContinue
$abstractCount = $abstractFiles.Count

Write-Finding "Total abstract.md files found: $abstractCount"

if ($abstractCount -eq 0) {
    Write-Fail "No abstract.md files found in repository!"
    $issues += "Abstract file is missing from repository"
    $recommendations += "Create abstract file in appropriate location"
} elseif ($abstractCount -gt 1) {
    Write-Warning "Multiple abstract.md files found:"
    $abstractFiles | ForEach-Object { 
        $relativePath = $_.FullName.Replace($RepoPath, "").TrimStart("\")
        Write-Finding "  - $relativePath"
    }
    $issues += "Multiple abstract files may cause confusion"
    $recommendations += "Keep only one abstract.md in 00_front_matter/"
} else {
    Write-Success "Exactly one abstract.md file found"
    $actualAbstractPath = $abstractFiles[0].FullName.Replace($RepoPath, "").TrimStart("\").Replace("\", "/")
    Write-Finding "Location: $actualAbstractPath"
    
    if ($actualAbstractPath -ne $AbstractPath) {
        Write-Warning "Abstract location differs from expected!"
        Write-Info "  Expected: $AbstractPath"
        Write-Info "  Actual:   $actualAbstractPath"
        $issues += "Abstract path mismatch"
        $recommendations += "Update SUMMARY.md to use correct path: $actualAbstractPath"
    }
}

# ============================================================
# STEP 5: File Encoding and Format Check
# ============================================================
Write-Step "STEP 5: File Encoding & Format Check"

if (Test-Path $abstractFullPath) {
    Write-SubStep "Checking file encoding"
    
    # Read as bytes to check encoding
    $bytes = [System.IO.File]::ReadAllBytes($abstractFullPath)
    
    # Check for BOM (Byte Order Mark)
    if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        Write-Info "File has UTF-8 BOM"
    } elseif ($bytes.Length -ge 2 -and $bytes[0] -eq 0xFF -and $bytes[1] -eq 0xFE) {
        Write-Warning "File is UTF-16 LE encoded - may cause issues!"
        $issues += "Abstract file is UTF-16 encoded"
        $recommendations += "Convert to UTF-8: Get-Content abstract.md | Set-Content abstract.md -Encoding UTF8"
    } else {
        Write-Success "File appears to be UTF-8 encoded"
    }
    
    # Check line endings
    $content = [System.IO.File]::ReadAllText($abstractFullPath)
    
    if ($content -match "`r`n") {
        Write-Info "File uses Windows line endings (CRLF)"
    } elseif ($content -match "`n") {
        Write-Info "File uses Unix line endings (LF)"
    }
    
    # Check for null bytes or other issues
    if ($content -match "`0") {
        Write-Warning "File contains null bytes - may be corrupted!"
        $issues += "Abstract file may be corrupted (contains null bytes)"
        $recommendations += "Re-create abstract file from clean text"
    }
}

# ============================================================
# STEP 6: Recent File Changes Analysis
# ============================================================
Write-Step "STEP 6: Recent File Changes Analysis"

Write-SubStep "Files changed in last commit"

$lastCommitFiles = git diff-tree --no-commit-id --name-only -r HEAD
if ($lastCommitFiles) {
    Write-Info "Files in last commit:"
    $lastCommitFiles | ForEach-Object { Write-Finding "  $_" }
    
    if ($lastCommitFiles -match "abstract\.md") {
        Write-Success "Abstract was part of last commit"
    } else {
        Write-Warning "Abstract was NOT in last commit"
        
        # Check when it was last committed
        $lastAbstractCommit = git log -1 --format="%h %ai %s" -- $AbstractPath.Replace("/", "\")
        if ($lastAbstractCommit) {
            Write-Info "Last abstract commit: $lastAbstractCommit"
        }
    }
    
    if ($lastCommitFiles -match "SUMMARY\.md") {
        Write-Success "SUMMARY.md was updated in last commit"
    }
} else {
    Write-Info "No files in last commit (or first commit)"
}

# Check files staged but not committed
Write-SubStep "Checking for staged but uncommitted files"

$stagedFiles = git diff --name-only --cached
if ($stagedFiles) {
    Write-Warning "Files are staged but not committed:"
    $stagedFiles | ForEach-Object { Write-Finding "  $_" }
    $issues += "Staged files not committed"
    $recommendations += "Commit staged files: git commit -m 'message'"
}

# ============================================================
# STEP 7: GitBook Integration Check
# ============================================================
Write-Step "STEP 7: GitBook Integration Diagnostics"

Write-Info "GitBook integration cannot be checked directly from command line"
Write-Info "Please verify the following in GitBook web interface:"
Write-Host ""
Write-Finding "1. Go to: https://app.gitbook.com/o/cyZpWhV7KomErB6BnmVk/s/hRoSpCiTUrfuH62swMvH/"
Write-Finding "2. Click Settings → Integrations"
Write-Finding "3. Verify GitHub integration is:"
Write-Finding "   • Connected (green checkmark)"
Write-Finding "   • Syncing from correct repository"
Write-Finding "   • Syncing from 'main' branch"
Write-Finding "   • Auto-sync is enabled"
Write-Host ""

# Check if .gitbook.yaml exists (configuration file)
$gitbookConfig = Join-Path $RepoPath ".gitbook.yaml"
if (Test-Path $gitbookConfig) {
    Write-Success ".gitbook.yaml configuration file exists"
    Write-SubStep "GitBook configuration"
    $configContent = Get-Content $gitbookConfig -Raw
    Write-Host $configContent -ForegroundColor Gray
    
    # Parse configuration
    if ($configContent -match 'root:\s*(.+)') {
        $gitbookRoot = $matches[1].Trim()
        Write-Finding "GitBook root directory: $gitbookRoot"
        
        if ($gitbookRoot -ne "./" -and $gitbookRoot -ne ".") {
            Write-Warning "GitBook is configured to use subdirectory: $gitbookRoot"
            $issues += "GitBook may be syncing from subdirectory only"
            $recommendations += "Verify files are in correct directory: $gitbookRoot"
        }
    }
    
    if ($configContent -match 'structure:') {
        Write-Info "Custom structure configuration detected"
        if ($configContent -match 'readme:\s*(.+)') {
            Write-Finding "Custom README: $($matches[1])"
        }
        if ($configContent -match 'summary:\s*(.+)') {
            Write-Finding "Custom SUMMARY: $($matches[1])"
        }
    }
    
} else {
    Write-Info ".gitbook.yaml not found (optional configuration)"
}

# ============================================================
# STEP 8: Timing Analysis
# ============================================================
Write-Step "STEP 8: Sync Timing Analysis"

if (Test-Path $abstractFullPath) {
    $fileModified = (Get-Item $abstractFullPath).LastWriteTime
    $now = Get-Date
    $timeSinceModified = $now - $fileModified
    
    Write-Finding "File last modified: $fileModified"
    Write-Finding "Time since modification: $([Math]::Floor($timeSinceModified.TotalMinutes)) minutes ago"
    
    if ($timeSinceModified.TotalMinutes -lt 5) {
        Write-Info "File was recently modified - GitBook may still be syncing"
        Write-Info "GitBook typically syncs within 2-10 minutes"
        $recommendations += "Wait 5-10 minutes and check GitBook again"
    } elseif ($timeSinceModified.TotalMinutes -lt 15) {
        Write-Warning "File modified $([Math]::Floor($timeSinceModified.TotalMinutes)) minutes ago - sync should be complete"
        Write-Warning "If still not visible, there may be a sync issue"
    } else {
        Write-Warning "File modified $([Math]::Floor($timeSinceModified.TotalHours)) hours ago"
        Write-Warning "Sync should definitely be complete - likely a configuration issue"
    }
}

# Check last push time
Write-SubStep "Checking last push to remote"

try {
    $lastPush = git log -1 --format="%ai" origin/$currentBranch
    if ($lastPush) {
        $lastPushTime = [DateTime]::Parse($lastPush)
        $timeSincePush = $now - $lastPushTime
        
        Write-Finding "Last push to remote: $lastPushTime"
        Write-Finding "Time since push: $([Math]::Floor($timeSincePush.TotalMinutes)) minutes ago"
        
        if ($timeSincePush.TotalMinutes -lt 5) {
            Write-Info "Recent push - GitBook may still be processing"
        }
    }
} catch {
    Write-Warning "Could not determine last push time"
}

# ============================================================
# STEP 9: Generate Diagnostic Report
# ============================================================
Write-Step "STEP 9: Diagnostic Report & Recommendations"

$endTime = Get-Date
$duration = ($endTime - $startTime).TotalSeconds

Write-Host "`n"
Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Yellow
Write-Host "║                                                              ║" -ForegroundColor Yellow
Write-Host "║                    DIAGNOSTIC SUMMARY                        ║" -ForegroundColor Yellow
Write-Host "║                                                              ║" -ForegroundColor Yellow
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Yellow

Write-Host "`n📊 ISSUES IDENTIFIED ($($issues.Count)):" -ForegroundColor Red
if ($issues.Count -eq 0) {
    Write-Success "No issues detected! Files should be syncing correctly."
} else {
    $issueNum = 1
    foreach ($issue in $issues) {
        Write-Host "  $issueNum. $issue" -ForegroundColor Red
        $issueNum++
    }
}

Write-Host "`n💡 RECOMMENDATIONS ($($recommendations.Count)):" -ForegroundColor Green
if ($recommendations.Count -eq 0) {
    Write-Info "No specific recommendations - verify GitBook integration in web interface"
} else {
    $recNum = 1
    foreach ($rec in $recommendations) {
        Write-Host "  $recNum. $rec" -ForegroundColor Green
        $recNum++
    }
}

# Most likely cause
Write-Host "`n🎯 MOST LIKELY CAUSE:" -ForegroundColor Magenta
if ($issues -match "not listed in SUMMARY.md") {
    Write-Host "  Abstract is not registered in SUMMARY.md" -ForegroundColor Magenta
    Write-Host "  → This is the most common reason files don't appear in GitBook" -ForegroundColor Magenta
    Write-Host "`n  IMMEDIATE FIX:" -ForegroundColor Yellow
    Write-Host "  1. Open SUMMARY.md" -ForegroundColor White
    Write-Host "  2. Add this line under a Front Matter section:" -ForegroundColor White
    Write-Host "     * [Abstract](00_front_matter/abstract.md)" -ForegroundColor Cyan
    Write-Host "  3. Save, commit, and push" -ForegroundColor White
    Write-Host "  4. Wait 2-5 minutes for GitBook to sync" -ForegroundColor White
} elseif ($issues -match "path mismatch") {
    Write-Host "  Abstract path in SUMMARY.md doesn't match actual file location" -ForegroundColor Magenta
    Write-Host "  → Fix the path in SUMMARY.md to match actual file location" -ForegroundColor Magenta
} elseif ($issues -match "branch") {
    Write-Host "  Not on 'main' branch" -ForegroundColor Magenta
    Write-Host "  → GitBook typically syncs from 'main' branch only" -ForegroundColor Magenta
} elseif ($issues -match "Uncommitted") {
    Write-Host "  Changes not committed/pushed to GitHub" -ForegroundColor Magenta
    Write-Host "  → Commit and push all changes" -ForegroundColor Magenta
} else {
    Write-Host "  Check GitBook integration settings in web interface" -ForegroundColor Magenta
    Write-Host "  → Verify GitHub integration is connected and auto-sync enabled" -ForegroundColor Magenta
}

# Next steps
Write-Host "`n📋 IMMEDIATE NEXT STEPS:" -ForegroundColor Cyan
Write-Host "  1. Address the issues listed above" -ForegroundColor White
Write-Host "  2. Commit and push any changes to GitHub" -ForegroundColor White
Write-Host "  3. Wait 2-10 minutes for GitBook to sync" -ForegroundColor White
Write-Host "  4. Verify in GitBook: https://app.gitbook.com/o/cyZpWhV7KomErB6BnmVk/s/hRoSpCiTUrfuH62swMvH/" -ForegroundColor White
Write-Host "  5. If still not visible, check GitBook integration settings" -ForegroundColor White

# Statistics
Write-Host "`n📈 DIAGNOSTIC STATISTICS:" -ForegroundColor Cyan
Write-Host "  • Execution time: $([math]::Round($duration, 1)) seconds" -ForegroundColor White
Write-Host "  • Current branch: $currentBranch" -ForegroundColor White
Write-Host "  • Issues found: $($issues.Count)" -ForegroundColor White
Write-Host "  • Recommendations: $($recommendations.Count)" -ForegroundColor White

Write-Host "`n" -NoNewline
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "              Diagnostic Complete - Review Results Above        " -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
