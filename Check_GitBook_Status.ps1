#Requires -Version 7.0

<#
.SYNOPSIS
    Checks GitBook publication status and extracts published structure

.DESCRIPTION
    This script verifies what's actually published on GitBook by:
    1. Finding your GitBook URL
    2. Checking sync status with GitHub
    3. Extracting the navigation structure from GitBook
    4. Comparing with local SUMMARY.md
    5. Generating a report of what's live vs what's local

.PARAMETER GitBookURL
    Your GitBook publication URL (if known)
    Example: https://your-space.gitbook.io/your-book

.PARAMETER OutputFile
    Where to save the comparison report
    Default: GitBook_Publication_Status.txt

.EXAMPLE
    .\Check_GitBook_Status.ps1
    Attempts to auto-detect GitBook URL and checks status

.EXAMPLE
    .\Check_GitBook_Status.ps1 -GitBookURL "https://your-space.gitbook.io/phd-thesis"
    Checks specific GitBook URL

#>

param(
    [string]$GitBookURL = "",
    [string]$OutputFile = "GitBook_Publication_Status.txt"
)

$ErrorActionPreference = "Continue"

# ============================================================================
# CONFIGURATION
# ============================================================================

$possibleGitBookDomains = @(
    "gitbook.io",
    "gitbook.com"
)

# Common GitBook config files
$gitbookConfigFiles = @(
    ".gitbook.yaml",
    ".gitbook.yml",
    "book.json",
    ".gitbook/config.yml"
)

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

function Get-GitBookConfigUrl {
    Write-Host "[INFO] Checking for GitBook configuration files..." -ForegroundColor Cyan
    
    foreach ($configFile in $gitbookConfigFiles) {
        if (Test-Path $configFile) {
            Write-Host "  ✓ Found: $configFile" -ForegroundColor Green
            
            try {
                $content = Get-Content $configFile -Raw
                
                # Try to extract URL from various config formats
                if ($content -match 'url[:\s]+["\']?(https?://[^"\'`s]+)') {
                    $url = $matches[1]
                    Write-Host "  ✓ Extracted URL: $url" -ForegroundColor Green
                    return $url
                }
            }
            catch {
                Write-Host "  ⚠ Could not parse $configFile" -ForegroundColor Yellow
            }
        }
    }
    
    Write-Host "  ℹ No GitBook config files found" -ForegroundColor Gray
    return $null
}

function Get-GitBookUrlFromReadme {
    Write-Host "[INFO] Checking README.md for GitBook links..." -ForegroundColor Cyan
    
    if (Test-Path "README.md") {
        $content = Get-Content "README.md" -Raw
        
        foreach ($domain in $possibleGitBookDomains) {
            if ($content -match "(https?://[^/\s]+\.$domain/[^\s\)]+)") {
                $url = $matches[1]
                Write-Host "  ✓ Found GitBook URL in README: $url" -ForegroundColor Green
                return $url
            }
        }
    }
    
    Write-Host "  ℹ No GitBook URL found in README.md" -ForegroundColor Gray
    return $null
}

function Get-GitRemoteUrls {
    Write-Host "[INFO] Checking Git remotes for GitBook..." -ForegroundColor Cyan
    
    $remotes = git remote -v 2>$null
    
    if ($remotes) {
        foreach ($remote in $remotes) {
            foreach ($domain in $possibleGitBookDomains) {
                if ($remote -match $domain) {
                    Write-Host "  ✓ Found GitBook in git remotes!" -ForegroundColor Green
                    Write-Host "    $remote" -ForegroundColor Cyan
                    
                    # Extract URL
                    if ($remote -match '(https?://[^\s]+)') {
                        return $matches[1]
                    }
                }
            }
        }
    }
    
    Write-Host "  ℹ No GitBook remote found" -ForegroundColor Gray
    return $null
}

function Test-GitBookUrl {
    param([string]$Url)
    
    if ([string]::IsNullOrWhiteSpace($Url)) {
        return $false
    }
    
    Write-Host "[INFO] Testing GitBook URL: $Url" -ForegroundColor Cyan
    
    try {
        $response = Invoke-WebRequest -Uri $Url -Method Head -TimeoutSec 10 -ErrorAction Stop
        
        if ($response.StatusCode -eq 200) {
            Write-Host "  ✓ GitBook site is accessible!" -ForegroundColor Green
            return $true
        }
    }
    catch {
        Write-Host "  ✗ Cannot access GitBook site: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
    
    return $false
}

function Get-GitBookNavigation {
    param([string]$Url)
    
    Write-Host "[INFO] Fetching GitBook navigation structure..." -ForegroundColor Cyan
    
    try {
        $response = Invoke-WebRequest -Uri $Url -TimeoutSec 15 -ErrorAction Stop
        $html = $response.Content
        
        # GitBook embeds navigation in various ways
        # Try to extract navigation data
        
        $navigation = @{
            Success = $true
            Sections = @()
            PageTitle = ""
            LastModified = $response.Headers.'Last-Modified'
        }
        
        # Extract page title
        if ($html -match '<title>([^<]+)</title>') {
            $navigation.PageTitle = $matches[1]
            Write-Host "  ✓ Page Title: $($navigation.PageTitle)" -ForegroundColor Green
        }
        
        # Try to extract navigation from various GitBook patterns
        # Pattern 1: Look for navigation structure in script tags (common in GitBook)
        if ($html -match '"navigation":\s*\{([^\}]+)\}') {
            Write-Host "  ✓ Found navigation data structure" -ForegroundColor Green
        }
        
        # Pattern 2: Extract visible navigation links
        $linkPattern = '<a[^>]+href="([^"]+)"[^>]*>([^<]+)</a>'
        $matches = [regex]::Matches($html, $linkPattern)
        
        $internalLinks = @()
        foreach ($match in $matches) {
            $href = $match.Groups[1].Value
            $text = $match.Groups[2].Value
            
            # Filter for likely content links (not external, not assets)
            if ($href -match '^/' -and 
                $href -notmatch '\.(css|js|png|jpg|svg|ico)$' -and
                $text.Trim() -ne '') {
                
                $internalLinks += @{
                    Href = $href
                    Text = $text.Trim()
                }
            }
        }
        
        if ($internalLinks.Count -gt 0) {
            Write-Host "  ✓ Found $($internalLinks.Count) internal content links" -ForegroundColor Green
            $navigation.Sections = $internalLinks | Select-Object -Unique -Property Href, Text
        }
        
        return $navigation
    }
    catch {
        Write-Host "  ✗ Failed to fetch GitBook navigation: $($_.Exception.Message)" -ForegroundColor Red
        return @{ Success = $false; Error = $_.Exception.Message }
    }
}

function Get-LocalSummaryStructure {
    Write-Host "[INFO] Reading local SUMMARY.md structure..." -ForegroundColor Cyan
    
    if (-not (Test-Path "SUMMARY.md")) {
        Write-Host "  ✗ SUMMARY.md not found" -ForegroundColor Red
        return $null
    }
    
    $content = Get-Content "SUMMARY.md"
    $structure = @{
        TotalLines = $content.Count
        Links = @()
        Sections = @()
    }
    
    $linkPattern = '\[([^\]]+)\]\(([^\)]+)\)'
    
    foreach ($line in $content) {
        # Extract section headers
        if ($line -match '^#{1,3}\s+(.+)$') {
            $structure.Sections += @{
                Level = ($line -match '^(#{1,3})').Matches[0].Groups[1].Value.Length
                Title = $matches[1].Trim()
            }
        }
        
        # Extract links
        if ($line -match $linkPattern) {
            $linkText = $matches[1]
            $linkPath = $matches[2]
            
            $structure.Links += @{
                Text = $linkText
                Path = $linkPath
                Exists = (Test-Path $linkPath)
            }
        }
    }
    
    Write-Host "  ✓ Found $($structure.Links.Count) links" -ForegroundColor Green
    Write-Host "  ✓ Found $($structure.Sections.Count) sections" -ForegroundColor Green
    
    return $structure
}

function Compare-LocalVsPublished {
    param(
        [object]$LocalStructure,
        [object]$PublishedNav
    )
    
    $comparison = @{
        InLocalOnly = @()
        InPublishedOnly = @()
        InBoth = @()
    }
    
    # Get list of local file paths
    $localPaths = $LocalStructure.Links | ForEach-Object { $_.Path }
    
    # Get list of published paths (need to normalize)
    $publishedPaths = $PublishedNav.Sections | ForEach-Object { $_.Href -replace '^/', '' }
    
    # Find items only in local
    foreach ($localPath in $localPaths) {
        $normalizedLocal = $localPath -replace '\\', '/'
        
        $foundInPublished = $false
        foreach ($pubPath in $publishedPaths) {
            if ($pubPath -like "*$normalizedLocal*" -or $normalizedLocal -like "*$pubPath*") {
                $foundInPublished = $true
                break
            }
        }
        
        if ($foundInPublished) {
            $comparison.InBoth += $localPath
        }
        else {
            $comparison.InLocalOnly += $localPath
        }
    }
    
    # Find items only in published
    foreach ($pubPath in $publishedPaths) {
        $foundInLocal = $false
        foreach ($localPath in $localPaths) {
            $normalizedLocal = $localPath -replace '\\', '/'
            if ($pubPath -like "*$normalizedLocal*" -or $normalizedLocal -like "*$pubPath*") {
                $foundInLocal = $true
                break
            }
        }
        
        if (-not $foundInLocal) {
            $comparison.InPublishedOnly += $pubPath
        }
    }
    
    return $comparison
}

function Get-GitHubRepoInfo {
    Write-Host "[INFO] Extracting GitHub repository information..." -ForegroundColor Cyan
    
    $remoteUrl = git config --get remote.origin.url 2>$null
    
    if ($remoteUrl) {
        Write-Host "  ✓ GitHub URL: $remoteUrl" -ForegroundColor Green
        
        # Extract owner/repo from URL
        if ($remoteUrl -match 'github\.com[:/]([^/]+)/([^/\.]+)') {
            return @{
                Owner = $matches[1]
                Repo = $matches[2]
                Url = $remoteUrl
                ApiUrl = "https://api.github.com/repos/$($matches[1])/$($matches[2])"
            }
        }
    }
    
    Write-Host "  ℹ Could not extract GitHub info" -ForegroundColor Gray
    return $null
}

function Get-LastGitCommitInfo {
    Write-Host "[INFO] Checking last Git commit..." -ForegroundColor Cyan
    
    try {
        $commitHash = git rev-parse HEAD 2>$null
        $commitDate = git log -1 --format=%cd --date=iso 2>$null
        $commitMessage = git log -1 --format=%s 2>$null
        
        if ($commitHash) {
            Write-Host "  ✓ Last commit: $commitHash" -ForegroundColor Green
            Write-Host "  ✓ Date: $commitDate" -ForegroundColor Green
            Write-Host "  ✓ Message: $commitMessage" -ForegroundColor Green
            
            return @{
                Hash = $commitHash
                Date = $commitDate
                Message = $commitMessage
            }
        }
    }
    catch {
        Write-Host "  ⚠ Could not get commit info" -ForegroundColor Yellow
    }
    
    return $null
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

function Main {
    $report = @()
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "GitBook Publication Status Checker" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    
    $report += "=" * 80
    $report += "GITBOOK PUBLICATION STATUS REPORT"
    $report += "=" * 80
    $report += "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    $report += "Repository: $(Get-Location)"
    $report += "=" * 80
    $report += ""
    
    # Section 1: Detect GitBook URL
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "SECTION 1: DETECTING GITBOOK URL" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host ""
    
    $report += ""
    $report += "=" * 80
    $report += "SECTION 1: GITBOOK URL DETECTION"
    $report += "=" * 80
    $report += ""
    
    if ([string]::IsNullOrWhiteSpace($GitBookURL)) {
        # Try multiple detection methods
        $detectedUrl = Get-GitBookConfigUrl
        if ([string]::IsNullOrWhiteSpace($detectedUrl)) {
            $detectedUrl = Get-GitBookUrlFromReadme
        }
        if ([string]::IsNullOrWhiteSpace($detectedUrl)) {
            $detectedUrl = Get-GitRemoteUrls
        }
        
        if ([string]::IsNullOrWhiteSpace($detectedUrl)) {
            Write-Host "⚠ Could not auto-detect GitBook URL" -ForegroundColor Yellow
            Write-Host ""
            $report += "⚠ GitBook URL Detection: FAILED"
            $report += "  No GitBook URL found in:"
            $report += "  - Configuration files (.gitbook.yaml, book.json)"
            $report += "  - README.md"
            $report += "  - Git remotes"
            $report += ""
            
            $manualUrl = Read-Host "Please enter your GitBook URL (e.g., https://your-space.gitbook.io/your-book)"
            if (-not [string]::IsNullOrWhiteSpace($manualUrl)) {
                $GitBookURL = $manualUrl
                $report += "✓ Manual URL provided: $GitBookURL"
            }
            else {
                Write-Host "✗ No GitBook URL provided. Cannot check publication status." -ForegroundColor Red
                $report += "✗ No GitBook URL available - cannot verify publication"
                $report | Out-File -FilePath $OutputFile -Encoding UTF8
                Write-Host ""
                Write-Host "Report saved to: $OutputFile" -ForegroundColor Yellow
                return
            }
        }
        else {
            $GitBookURL = $detectedUrl
            $report += "✓ GitBook URL detected: $GitBookURL"
        }
    }
    else {
        $report += "✓ GitBook URL provided: $GitBookURL"
    }
    
    Write-Host ""
    
    # Section 2: Test GitBook Accessibility
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "SECTION 2: GITBOOK ACCESSIBILITY TEST" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host ""
    
    $report += ""
    $report += "=" * 80
    $report += "SECTION 2: GITBOOK ACCESSIBILITY"
    $report += "=" * 80
    $report += ""
    
    $isAccessible = Test-GitBookUrl -Url $GitBookURL
    
    if ($isAccessible) {
        $report += "✓ GitBook site is LIVE and accessible"
        $report += "  URL: $GitBookURL"
    }
    else {
        $report += "✗ GitBook site is NOT accessible"
        $report += "  URL: $GitBookURL"
        $report += "  Possible reasons:"
        $report += "  - Site is private (requires authentication)"
        $report += "  - Sync is pending"
        $report += "  - URL is incorrect"
        $report += "  - Network/firewall blocking access"
    }
    
    Write-Host ""
    
    # Section 3: Extract Published Navigation
    if ($isAccessible) {
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
        Write-Host "SECTION 3: PUBLISHED NAVIGATION" -ForegroundColor Cyan
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
        Write-Host ""
        
        $report += ""
        $report += "=" * 80
        $report += "SECTION 3: PUBLISHED NAVIGATION STRUCTURE"
        $report += "=" * 80
        $report += ""
        
        $publishedNav = Get-GitBookNavigation -Url $GitBookURL
        
        if ($publishedNav.Success) {
            $report += "✓ Successfully retrieved published navigation"
            $report += "  Page Title: $($publishedNav.PageTitle)"
            if ($publishedNav.LastModified) {
                $report += "  Last Modified: $($publishedNav.LastModified)"
            }
            $report += "  Content Links Found: $($publishedNav.Sections.Count)"
            $report += ""
            
            if ($publishedNav.Sections.Count -gt 0) {
                $report += "Published Content Links:"
                $report += "-" * 50
                foreach ($section in $publishedNav.Sections) {
                    $report += "  • $($section.Text)"
                    $report += "    → $($section.Href)"
                }
            }
        }
        else {
            $report += "⚠ Could not extract detailed navigation"
            $report += "  Error: $($publishedNav.Error)"
            $publishedNav = $null
        }
        
        Write-Host ""
    }
    else {
        $publishedNav = $null
    }
    
    # Section 4: Local SUMMARY.md Structure
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "SECTION 4: LOCAL SUMMARY.MD STRUCTURE" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host ""
    
    $report += ""
    $report += "=" * 80
    $report += "SECTION 4: LOCAL SUMMARY.MD STRUCTURE"
    $report += "=" * 80
    $report += ""
    
    $localStructure = Get-LocalSummaryStructure
    
    if ($localStructure) {
        $report += "✓ Local SUMMARY.md analyzed"
        $report += "  Total Lines: $($localStructure.TotalLines)"
        $report += "  Total Links: $($localStructure.Links.Count)"
        $report += "  Sections: $($localStructure.Sections.Count)"
        $report += ""
        
        # Check for Firman materials specifically
        $firmanLinks = $localStructure.Links | Where-Object { $_.Path -like '*Firman*' }
        if ($firmanLinks.Count -gt 0) {
            $report += "✓ Firman Materials Found in SUMMARY.md:"
            $report += "-" * 50
            foreach ($link in $firmanLinks) {
                $status = if ($link.Exists) { "✓" } else { "✗" }
                $report += "  $status [$($link.Text)]($($link.Path))"
            }
            $report += ""
        }
        else {
            $report += "⚠ No Firman materials found in SUMMARY.md"
            $report += ""
        }
        
        # Show all sections
        $report += "Section Structure:"
        $report += "-" * 50
        foreach ($section in $localStructure.Sections) {
            $indent = "  " * ($section.Level - 1)
            $report += "$indent$('#' * $section.Level) $($section.Title)"
        }
    }
    else {
        $report += "✗ Could not read local SUMMARY.md"
    }
    
    Write-Host ""
    
    # Section 5: GitHub Information
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "SECTION 5: GITHUB SYNC STATUS" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host ""
    
    $report += ""
    $report += "=" * 80
    $report += "SECTION 5: GITHUB SYNC STATUS"
    $report += "=" * 80
    $report += ""
    
    $githubInfo = Get-GitHubRepoInfo
    $commitInfo = Get-LastGitCommitInfo
    
    if ($githubInfo) {
        $report += "✓ GitHub Repository:"
        $report += "  Owner: $($githubInfo.Owner)"
        $report += "  Repo: $($githubInfo.Repo)"
        $report += "  URL: $($githubInfo.Url)"
        $report += ""
    }
    
    if ($commitInfo) {
        $report += "✓ Last Commit:"
        $report += "  Hash: $($commitInfo.Hash)"
        $report += "  Date: $($commitInfo.Date)"
        $report += "  Message: $($commitInfo.Message)"
        $report += ""
    }
    
    # Section 6: Comparison
    if ($publishedNav -and $localStructure) {
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
        Write-Host "SECTION 6: LOCAL VS PUBLISHED COMPARISON" -ForegroundColor Cyan
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
        Write-Host ""
        
        $report += ""
        $report += "=" * 80
        $report += "SECTION 6: LOCAL VS PUBLISHED COMPARISON"
        $report += "=" * 80
        $report += ""
        
        $comparison = Compare-LocalVsPublished -LocalStructure $localStructure -PublishedNav $publishedNav
        
        $report += "Items in both local and published: $($comparison.InBoth.Count)"
        $report += "Items only in local (not yet synced): $($comparison.InLocalOnly.Count)"
        $report += "Items only in published (removed locally): $($comparison.InPublishedOnly.Count)"
        $report += ""
        
        if ($comparison.InLocalOnly.Count -gt 0) {
            $report += "⚠ NOT YET PUBLISHED (in local SUMMARY.md only):"
            $report += "-" * 50
            foreach ($item in $comparison.InLocalOnly) {
                $report += "  • $item"
            }
            $report += ""
        }
        
        if ($comparison.InPublishedOnly.Count -gt 0) {
            $report += "⚠ PUBLISHED BUT NOT IN LOCAL (removed from SUMMARY.md):"
            $report += "-" * 50
            foreach ($item in $comparison.InPublishedOnly) {
                $report += "  • $item"
            }
            $report += ""
        }
    }
    
    # Section 7: Recommendations
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "SECTION 7: RECOMMENDATIONS" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host ""
    
    $report += ""
    $report += "=" * 80
    $report += "SECTION 7: RECOMMENDATIONS"
    $report += "=" * 80
    $report += ""
    
    if (-not $isAccessible) {
        $report += "⚠ GITBOOK NOT ACCESSIBLE"
        $report += "  Action Required:"
        $report += "  1. Verify GitBook URL is correct"
        $report += "  2. Check if space is set to private (may need login)"
        $report += "  3. Visit GitBook.com to check sync status"
        $report += "  4. Manually trigger sync if needed"
        $report += ""
    }
    elseif ($comparison -and $comparison.InLocalOnly.Count -gt 0) {
        $report += "⚠ LOCAL CHANGES NOT YET PUBLISHED"
        $report += "  GitBook typically syncs within 2-10 minutes after GitHub push"
        $report += "  Action:"
        $report += "  1. Wait a few more minutes for automatic sync"
        $report += "  2. Or manually trigger sync in GitBook dashboard:"
        $report += "     → Settings → Integrations → GitHub → Sync Now"
        $report += ""
        
        # Check if Firman is in the not-yet-synced list
        $firmanNotSynced = $comparison.InLocalOnly | Where-Object { $_ -like '*Firman*' }
        if ($firmanNotSynced.Count -gt 0) {
            $report += "⚠ FIRMAN MATERIALS NOT YET SYNCED:"
            foreach ($item in $firmanNotSynced) {
                $report += "  • $item"
            }
            $report += ""
        }
    }
    else {
        $report += "✓ Everything looks good!"
        $report += "  Local and published structures appear synchronized"
        $report += ""
    }
    
    $report += ""
    $report += "=" * 80
    $report += "END OF REPORT"
    $report += "=" * 80
    
    # Save report
    $report | Out-File -FilePath $OutputFile -Encoding UTF8
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "REPORT COMPLETE" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "Report saved to: $OutputFile" -ForegroundColor White
    Write-Host ""
    
    if ($GitBookURL) {
        Write-Host "GitBook URL: $GitBookURL" -ForegroundColor Cyan
        $openUrl = Read-Host "Open GitBook in browser? (Y/n)"
        if ($openUrl -match '^[Yy]' -or [string]::IsNullOrWhiteSpace($openUrl)) {
            Start-Process $GitBookURL
        }
    }
    
    $openReport = Read-Host "Open report file? (Y/n)"
    if ($openReport -match '^[Yy]' -or [string]::IsNullOrWhiteSpace($openReport)) {
        Start-Process notepad $OutputFile
    }
}

# Run main function
Main
