<#
.SYNOPSIS
    GitBook Publication Status Checker
    
.DESCRIPTION
    Checks if your local GitBook repository is synced with the published GitBook site.
    Analyzes local SUMMARY.md structure and compares with published navigation.
    
.NOTES
    Author: PhD Automation Assistant
    Date: 2025-11-25
    Version: 3.0 (Regex pattern fix)
#>

# Set strict mode for better error handling
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Configuration
$RepoPath = "C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis"
$SummaryFile = Join-Path $RepoPath "SUMMARY.md"
$OutputReport = Join-Path $RepoPath "GitBook_Publication_Status.txt"

# Color output functions
function Write-Header {
    param([string]$Text)
    Write-Host "`n$('=' * 80)" -ForegroundColor Cyan
    Write-Host "  $Text" -ForegroundColor Cyan
    Write-Host "$('=' * 80)" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Text)
    Write-Host "✓ $Text" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Text)
    Write-Host "⚠ $Text" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Text)
    Write-Host "✗ $Text" -ForegroundColor Red
}

function Write-Info {
    param([string]$Text)
    Write-Host "ℹ $Text" -ForegroundColor Blue
}

# Start report
$Report = @()
$Report += "GitBook Publication Status Report"
$Report += "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
$Report += "=" * 80
$Report += ""

Write-Header "GitBook Publication Status Checker"

# Step 1: Auto-detect GitBook URL
Write-Header "Step 1: Detecting GitBook URL"

$GitBookUrl = $null
$DetectionMethod = "None"

# Method 1: Check .gitbook.yaml
$GitBookConfig = Join-Path $RepoPath ".gitbook.yaml"
if (Test-Path $GitBookConfig) {
    Write-Info "Checking .gitbook.yaml..."
    $content = Get-Content $GitBookConfig -Raw
    # Use simpler regex pattern to avoid quote escaping issues
    $urlPattern = 'https?://[^\s<>"\)]+\.gitbook\.io[^\s<>"\)]*'
    if ($content -match $urlPattern) {
        $GitBookUrl = $matches[0]
        $DetectionMethod = ".gitbook.yaml"
        Write-Success "Found URL in .gitbook.yaml: $GitBookUrl"
    }
}

# Method 2: Check book.json
if (-not $GitBookUrl) {
    $BookJson = Join-Path $RepoPath "book.json"
    if (Test-Path $BookJson) {
        Write-Info "Checking book.json..."
        $content = Get-Content $BookJson -Raw
        $urlPattern = 'https?://[^\s<>"\)]+\.gitbook\.io[^\s<>"\)]*'
        if ($content -match $urlPattern) {
            $GitBookUrl = $matches[0]
            $DetectionMethod = "book.json"
            Write-Success "Found URL in book.json: $GitBookUrl"
        }
    }
}

# Method 3: Check README.md for GitBook links
if (-not $GitBookUrl) {
    $ReadmeFile = Join-Path $RepoPath "README.md"
    if (Test-Path $ReadmeFile) {
        Write-Info "Checking README.md..."
        $content = Get-Content $ReadmeFile -Raw
        $urlPattern = 'https?://[^\s<>"\)]+\.gitbook\.io[^\s<>"\)]*'
        if ($content -match $urlPattern) {
            $GitBookUrl = $matches[0]
            $DetectionMethod = "README.md"
            Write-Success "Found URL in README.md: $GitBookUrl"
        }
    }
}

# Method 4: Check git remotes for gitbook
if (-not $GitBookUrl) {
    Write-Info "Checking git remotes..."
    Push-Location $RepoPath
    try {
        $remotes = git remote -v 2>$null
        $urlPattern = 'https?://[^\s<>"\)]+gitbook[^\s<>"\)]*'
        if ($remotes -match $urlPattern) {
            $GitBookUrl = $matches[0]
            $DetectionMethod = "git remote"
            Write-Success "Found URL in git remotes: $GitBookUrl"
        }
    } catch {
        Write-Warning "Git remote check failed: $_"
    }
    Pop-Location
}

# Manual input if auto-detection failed
if (-not $GitBookUrl) {
    Write-Warning "Could not auto-detect GitBook URL"
    Write-Host ""
    Write-Host "Please enter your GitBook URL manually:" -ForegroundColor Yellow
    Write-Host "Example: https://yourusername.gitbook.io/phd-sacred-bonds-thesis/" -ForegroundColor Gray
    Write-Host "Or press Enter to skip publication check" -ForegroundColor Gray
    $GitBookUrl = Read-Host "GitBook URL"
    
    if ([string]::IsNullOrWhiteSpace($GitBookUrl)) {
        Write-Warning "No GitBook URL provided. Skipping publication check."
        $Report += "GitBook URL Detection: FAILED (No URL provided)"
        $Report += ""
        $Report | Out-File $OutputReport -Encoding UTF8
        Write-Info "Report saved to: $OutputReport"
        exit
    }
    $DetectionMethod = "Manual Input"
}

$Report += "GitBook URL Detection: SUCCESS"
$Report += "Detection Method: $DetectionMethod"
$Report += "URL: $GitBookUrl"
$Report += ""

# Ensure URL doesn't have trailing slash for consistency
$GitBookUrl = $GitBookUrl.TrimEnd('/')

# Step 2: Test GitBook accessibility
Write-Header "Step 2: Testing GitBook Accessibility"

try {
    Write-Info "Testing connection to: $GitBookUrl"
    $response = Invoke-WebRequest -Uri $GitBookUrl -Method Head -TimeoutSec 10 -UseBasicParsing
    $statusCode = $response.StatusCode
    
    if ($statusCode -eq 200) {
        Write-Success "GitBook site is accessible (Status: $statusCode)"
        $Report += "GitBook Accessibility: SUCCESS (Status: $statusCode)"
    } else {
        Write-Warning "GitBook returned status: $statusCode"
        $Report += "GitBook Accessibility: WARNING (Status: $statusCode)"
    }
} catch {
    Write-Error "Cannot access GitBook site"
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    $Report += "GitBook Accessibility: FAILED"
    $Report += "Error: $($_.Exception.Message)"
    $Report += ""
    $Report | Out-File $OutputReport -Encoding UTF8
    Write-Info "Report saved to: $OutputReport"
    exit
}

$Report += ""

# Step 3: Analyze local SUMMARY.md
Write-Header "Step 3: Analyzing Local SUMMARY.md"

if (-not (Test-Path $SummaryFile)) {
    Write-Error "SUMMARY.md not found at: $SummaryFile"
    $Report += "Local SUMMARY.md: NOT FOUND"
    $Report | Out-File $OutputReport -Encoding UTF8
    exit
}

Write-Info "Reading SUMMARY.md..."
$summaryContent = Get-Content $SummaryFile -Raw
$summaryLines = Get-Content $SummaryFile

# Extract all markdown links from SUMMARY.md
$localLinks = @()
$linkPattern = '\[([^\]]+)\]\(([^\)]+)\)'
$summaryContent | Select-String -Pattern $linkPattern -AllMatches | ForEach-Object {
    $_.Matches | ForEach-Object {
        $localLinks += [PSCustomObject]@{
            Title = $_.Groups[1].Value
            Path = $_.Groups[2].Value
        }
    }
}

Write-Success "Found $($localLinks.Count) links in local SUMMARY.md"
$Report += "Local SUMMARY.md Analysis:"
$Report += "  Total Links: $($localLinks.Count)"

# Check for Firman materials specifically
$firmanLinks = $localLinks | Where-Object { $_.Path -like '*firman*' -or $_.Title -like '*firman*' }
if ($firmanLinks) {
    Write-Success "Found $($firmanLinks.Count) Firman-related links in local SUMMARY.md:"
    $Report += "  Firman Materials (Local): $($firmanLinks.Count) links found"
    foreach ($link in $firmanLinks) {
        Write-Host "    • $($link.Title) → $($link.Path)" -ForegroundColor Green
        $Report += "    • $($link.Title) → $($link.Path)"
    }
} else {
    Write-Warning "No Firman materials found in local SUMMARY.md"
    $Report += "  Firman Materials (Local): NOT FOUND"
}

$Report += ""

# Step 4: Fetch and analyze published GitBook structure
Write-Header "Step 4: Analyzing Published GitBook Structure"

try {
    Write-Info "Fetching published GitBook content..."
    $publishedContent = Invoke-WebRequest -Uri $GitBookUrl -UseBasicParsing -TimeoutSec 15
    $html = $publishedContent.Content
    
    # Extract navigation links (GitBook uses specific patterns)
    $publishedLinks = @()
    
    # Simpler pattern for extracting hrefs
    $navPattern = 'href=["'']([^"'']+)["'']'
    $html | Select-String -Pattern $navPattern -AllMatches | ForEach-Object {
        $_.Matches | ForEach-Object {
            $href = $_.Groups[1].Value
            
            # Filter to only include content links
            if ($href -notmatch '^(http|#|javascript|\s*$)' -and $href -match '\w') {
                $publishedLinks += [PSCustomObject]@{
                    Path = $href
                }
            }
        }
    }
    
    # Remove duplicates
    $publishedLinks = $publishedLinks | Select-Object -Property Path -Unique
    
    Write-Success "Extracted $($publishedLinks.Count) unique links from published GitBook"
    $Report += "Published GitBook Analysis:"
    $Report += "  Extracted Links: $($publishedLinks.Count)"
    
    # Check for Firman materials in published version
    $publishedFirmanLinks = $publishedLinks | Where-Object { 
        $_.Path -like '*firman*'
    }
    
    if ($publishedFirmanLinks) {
        Write-Success "Found $($publishedFirmanLinks.Count) Firman-related links in published GitBook:"
        $Report += "  Firman Materials (Published): $($publishedFirmanLinks.Count) links found"
        foreach ($link in $publishedFirmanLinks) {
            Write-Host "    • $($link.Path)" -ForegroundColor Green
            $Report += "    • $($link.Path)"
        }
    } else {
        Write-Warning "No Firman materials found in published GitBook navigation"
        $Report += "  Firman Materials (Published): NOT FOUND in navigation"
    }
    
} catch {
    Write-Error "Failed to analyze published GitBook structure"
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    $Report += "Published GitBook Analysis: FAILED"
    $Report += "Error: $($_.Exception.Message)"
}

$Report += ""

# Step 5: Compare and provide recommendations
Write-Header "Step 5: Sync Status & Recommendations"

$Report += "Sync Status Summary:"
$Report += ""

if ($firmanLinks -and $publishedFirmanLinks) {
    Write-Success "Firman materials are present in BOTH local and published versions"
    $Report += "✓ Firman Materials: SYNCED"
    $Report += "  Local: $($firmanLinks.Count) links"
    $Report += "  Published: $($publishedFirmanLinks.Count) links"
    $Report += ""
    $Report += "RECOMMENDATION: Your Firman materials appear to be published!"
    $Report += "Verify by visiting: $GitBookUrl"
} elseif ($firmanLinks -and -not $publishedFirmanLinks) {
    Write-Warning "Firman materials exist locally but NOT found in published GitBook"
    $Report += "⚠ Firman Materials: NOT SYNCED"
    $Report += "  Local: $($firmanLinks.Count) links found"
    $Report += "  Published: NOT FOUND"
    $Report += ""
    $Report += "RECOMMENDATION: You need to publish/sync your GitBook"
    $Report += "Options:"
    $Report += "  1. If using GitBook.com: Check your space settings for GitHub sync"
    $Report += "  2. If using GitBook CLI: Run 'gitbook build' and deploy"
    $Report += "  3. Check GitBook dashboard for sync status"
} elseif (-not $firmanLinks) {
    Write-Error "Firman materials NOT FOUND in local SUMMARY.md!"
    $Report += "✗ Firman Materials: NOT IN LOCAL SUMMARY.md"
    $Report += ""
    $Report += "RECOMMENDATION: Run Add_Firman_To_Summary.ps1 first"
} else {
    Write-Info "Analysis complete with mixed results"
    $Report += "ℹ Status unclear - manual verification recommended"
}

$Report += ""
$Report += "=" * 80
$Report += "For detailed navigation comparison, review the links above."
$Report += "Visit your GitBook directly to verify: $GitBookUrl"

# Save report
$Report | Out-File $OutputReport -Encoding UTF8
Write-Success "Report saved to: $OutputReport"

Write-Host "`n" -NoNewline
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "  1. Review the report: " -NoNewline
Write-Host "$OutputReport" -ForegroundColor Cyan
Write-Host "  2. Visit your GitBook: " -NoNewline
Write-Host "$GitBookUrl" -ForegroundColor Cyan
Write-Host "  3. Verify Firman materials are accessible" -ForegroundColor Yellow
Write-Host ""
