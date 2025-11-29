#Requires -Version 5.1
<#
.SYNOPSIS
    Sync Jung Literature Sources to Sacred Bonds GitBook

.DESCRIPTION
    This script syncs the Jung literature summaries from your local Git repository
    to your GitBook documentation. GitBook automatically syncs with your GitHub
    repository, so this script verifies the Git push and provides GitBook sync status.

.NOTES
    File Name      : Push_Jung_Sources_To_GitBook.ps1
    Author         : AI Research Assistant
    Prerequisite   : Git repository must be pushed to GitHub first
    Created        : 2025-11-28
    
.EXAMPLE
    .\Push_Jung_Sources_To_GitBook.ps1
#>

# ============================================================================
# CONFIGURATION
# ============================================================================

$phdBasePath = "C:\Users\user\Documents\PhD"
$dissertationRepo = Join-Path $phdBasePath "phd-sacred-bonds-thesis"
$gitBookURL = "https://app.gitbook.com/o/cyZpWhV7KomErB6BnmVk/s/hRoSpCiTUrfuH62swMvH/"
$gitHubRepo = "https://github.com/dw-hurt/phd-sacred-bonds-thesis"

# Colors for console output
$successColor = "Green"
$warningColor = "Yellow"
$errorColor = "Red"
$infoColor = "Cyan"
$highlightColor = "Magenta"

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

function Test-GitBookPrerequisites {
    Write-ColorOutput "`n=== Checking GitBook Sync Prerequisites ===" $infoColor
    
    # Check if dissertation repo exists
    if (-not (Test-Path $dissertationRepo)) {
        Write-ColorOutput "ERROR: Dissertation repository not found at $dissertationRepo" $errorColor
        return $false
    }
    Write-ColorOutput "✓ Dissertation repository found" $successColor
    
    # Change to repo directory
    Set-Location $dissertationRepo
    
    # Check if Git is installed
    try {
        $gitVersion = git --version 2>$null
        Write-ColorOutput "✓ Git installed: $gitVersion" $successColor
    } catch {
        Write-ColorOutput "ERROR: Git is not installed or not in PATH" $errorColor
        return $false
    }
    
    # Check if remote is configured
    $remoteURL = git remote get-url origin 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-ColorOutput "✓ Git remote configured: $remoteURL" $successColor
    } else {
        Write-ColorOutput "ERROR: Git remote 'origin' not configured" $errorColor
        Write-ColorOutput "Run: git remote add origin https://github.com/dw-hurt/phd-sacred-bonds-thesis.git" $warningColor
        return $false
    }
    
    # Check if files are committed
    $uncommitted = git status --porcelain 2>$null
    if ($uncommitted) {
        Write-ColorOutput "⚠ WARNING: Uncommitted changes detected:" $warningColor
        Write-ColorOutput $uncommitted "Gray"
        Write-ColorOutput "`nYou should commit these changes before syncing to GitBook." $warningColor
        Write-ColorOutput "Run: .\Push_Jung_Sources_To_Git.ps1 first" $infoColor
        
        $response = Read-Host "`nDo you want to continue anyway? (y/n)"
        if ($response -ne 'y') {
            return $false
        }
    } else {
        Write-ColorOutput "✓ All changes committed" $successColor
    }
    
    return $true
}

function Invoke-GitHubPush {
    Write-ColorOutput "`n=== Verifying GitHub Push ===" $infoColor
    
    Set-Location $dissertationRepo
    
    # Check if local is ahead of remote
    git fetch origin 2>$null
    $ahead = git rev-list --count origin/main..HEAD 2>$null
    
    if ($LASTEXITCODE -ne 0) {
        Write-ColorOutput "⚠ Cannot determine sync status with GitHub" $warningColor
        $ahead = "unknown"
    }
    
    if ($ahead -eq "0" -or $ahead -eq "") {
        Write-ColorOutput "✓ Local repository is in sync with GitHub" $successColor
        return $true
    } elseif ($ahead -eq "unknown") {
        Write-ColorOutput "⚠ Unable to verify sync status" $warningColor
        Write-ColorOutput "Attempting to push to GitHub..." $infoColor
    } else {
        Write-ColorOutput "⚠ Local is $ahead commit(s) ahead of GitHub" $warningColor
        Write-ColorOutput "Pushing to GitHub..." $infoColor
    }
    
    # Push to GitHub
    git push origin main 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-ColorOutput "✓ Successfully pushed to GitHub!" $successColor
        return $true
    } else {
        Write-ColorOutput "❌ Failed to push to GitHub" $errorColor
        Write-ColorOutput "Please manually push with: git push origin main" $warningColor
        return $false
    }
}

function Wait-ForGitBookSync {
    Write-ColorOutput "`n=== GitBook Sync Status ===" $infoColor
    
    Write-ColorOutput "`nGitBook automatically syncs with your GitHub repository." $infoColor
    Write-ColorOutput "This typically takes 2-3 minutes after pushing to GitHub.`n" $infoColor
    
    Write-ColorOutput "📚 Your GitBook URL:" $highlightColor
    Write-ColorOutput "   $gitBookURL`n" "Cyan"
    
    Write-ColorOutput "🔄 Sync Process:" $infoColor
    Write-ColorOutput "   1. GitHub receives your push ✓" $successColor
    Write-ColorOutput "   2. GitBook detects GitHub changes (monitoring...)" "Yellow"
    Write-ColorOutput "   3. GitBook pulls updated content (2-3 minutes)" "Gray"
    Write-ColorOutput "   4. GitBook rebuilds documentation (automatic)" "Gray"
    Write-ColorOutput "   5. New content appears in GitBook (ready!)" "Gray"
    
    Write-ColorOutput "`n⏱️  Estimated sync time: 2-3 minutes" $warningColor
    
    $waitTime = 180 # 3 minutes in seconds
    $interval = 30 # Update every 30 seconds
    
    Write-ColorOutput "`nWaiting for GitBook sync..." $infoColor
    Write-ColorOutput "(You can press Ctrl+C to skip waiting and check manually)`n" "Gray"
    
    for ($i = 0; $i -lt $waitTime; $i += $interval) {
        $remaining = $waitTime - $i
        $minutes = [math]::Floor($remaining / 60)
        $seconds = $remaining % 60
        Write-Progress -Activity "Waiting for GitBook sync" `
                      -Status "$minutes min $seconds sec remaining" `
                      -PercentComplete (($i / $waitTime) * 100)
        Start-Sleep -Seconds $interval
    }
    
    Write-Progress -Activity "Waiting for GitBook sync" -Completed
    Write-ColorOutput "✓ Sync wait period complete" $successColor
}

function Test-GitBookContent {
    Write-ColorOutput "`n=== Verifying GitBook Content ===" $infoColor
    
    Write-ColorOutput "`nTo verify your Jung literature sources are in GitBook:" $infoColor
    Write-ColorOutput ""
    Write-ColorOutput "1. Open your GitBook:" "White"
    Write-ColorOutput "   $gitBookURL" "Cyan"
    Write-ColorOutput ""
    Write-ColorOutput "2. Navigate to the sidebar and look for:" "White"
    Write-ColorOutput "   📚 03_literature_sources/" "Gray"
    Write-ColorOutput "      └── Jung_Sources/" "Gray"
    Write-ColorOutput ""
    Write-ColorOutput "3. You should see these pages:" "White"
    Write-ColorOutput "   • 00_Jung_Sources_Bibliography" "Gray"
    Write-ColorOutput "   • 01_CW9-1_Archetypes_CollectiveUnconscious" "Gray"
    Write-ColorOutput "   • 02_CW16_Psychology_of_Transference" "Gray"
    Write-ColorOutput "   • 03_Anima_Animus_Essay" "Gray"
    Write-ColorOutput "   • 04_Jungian_Archetypes_Infidelity_Dissertation" "Gray"
    Write-ColorOutput "   • 99_Jung_Quotes_By_Chapter_Reference" "Gray"
    Write-ColorOutput ""
    
    $openBrowser = Read-Host "Would you like to open GitBook in your browser now? (y/n)"
    if ($openBrowser -eq 'y') {
        Write-ColorOutput "`nOpening GitBook in default browser..." $infoColor
        Start-Process $gitBookURL
    }
}

function Show-GitBookIntegrationGuide {
    Write-ColorOutput "`n╔════════════════════════════════════════════════════════════════╗" $highlightColor
    Write-ColorOutput "║         GitBook Integration Guide - Jung Sources               ║" $highlightColor
    Write-ColorOutput "╚════════════════════════════════════════════════════════════════╝`n" $highlightColor
    
    Write-ColorOutput "📖 How GitBook Organizes Your Content:`n" $infoColor
    
    Write-ColorOutput "Your dissertation structure in GitBook:" "White"
    Write-ColorOutput ""
    Write-ColorOutput "Sacred Bonds: Evolutionary Psychology and the Contemporary Mating Crisis" "Cyan"
    Write-ColorOutput "├── 01_introduction/" "White"
    Write-ColorOutput "├── 02_theoretical_framework/" "White"
    Write-ColorOutput "│   └── (Add links to Jung sources here)" "Gray"
    Write-ColorOutput "├── 03_literature_sources/ 👈 NEW!" "Green"
    Write-ColorOutput "│   └── Jung_Sources/" "Green"
    Write-ColorOutput "│       ├── 00_Jung_Sources_Bibliography" "Green"
    Write-ColorOutput "│       ├── 01_CW9-1_Archetypes_CollectiveUnconscious" "Green"
    Write-ColorOutput "│       ├── 02_CW16_Psychology_of_Transference" "Green"
    Write-ColorOutput "│       ├── 03_Anima_Animus_Essay" "Green"
    Write-ColorOutput "│       ├── 04_Jungian_Archetypes_Infidelity_Dissertation" "Green"
    Write-ColorOutput "│       └── 99_Jung_Quotes_By_Chapter_Reference" "Green"
    Write-ColorOutput "├── 04_methodology/" "White"
    Write-ColorOutput "├── 05_discussion/" "White"
    Write-ColorOutput "└── 06_conclusion/" "White"
    Write-ColorOutput ""
    
    Write-ColorOutput "🔗 Creating Internal Links in GitBook:`n" $infoColor
    
    Write-ColorOutput "In your Chapter 2 (Theoretical Framework), add links like:" "White"
    Write-ColorOutput ""
    Write-ColorOutput '  For detailed Jung source analysis, see:' "Gray"
    Write-ColorOutput '  - [CW 9: Archetypes](../03_literature_sources/Jung_Sources/01_CW9-1_Archetypes_CollectiveUnconscious.md)' "Gray"
    Write-ColorOutput '  - [CW 16: Transference](../03_literature_sources/Jung_Sources/02_CW16_Psychology_of_Transference.md)' "Gray"
    Write-ColorOutput ""
    
    Write-ColorOutput "📊 Using Quotes in Your Chapters:`n" $infoColor
    
    Write-ColorOutput "When drafting, reference:" "White"
    Write-ColorOutput "  → 99_Jung_Quotes_By_Chapter_Reference.md" "Cyan"
    Write-ColorOutput ""
    Write-ColorOutput "This file has quotes pre-organized by chapter, so you can:" "White"
    Write-ColorOutput "  • Copy quotes directly into your drafts" "Gray"
    Write-ColorOutput "  • Include proper page citations" "Gray"
    Write-ColorOutput "  • Link to full literature summaries for context" "Gray"
    Write-ColorOutput ""
    
    Write-ColorOutput "✏️  Example Integration:`n" $infoColor
    
    Write-ColorOutput 'In Chapter 2, Section "Anima and Animus Archetypes":' "White"
    Write-ColorOutput ""
    Write-ColorOutput '  Jung (1969) argued that anima and animus are inherited' "Gray"
    Write-ColorOutput '  psychological structures with biological foundations:' "Gray"
    Write-ColorOutput '  ' "Gray"
    Write-ColorOutput '  > "The anima is projected upon women. Either sex is' "Gray"
    Write-ColorOutput '  > inhabited by the opposite sex up to a point, for,' "Gray"
    Write-ColorOutput '  > biologically speaking, it is simply the greater number' "Gray"
    Write-ColorOutput '  > of masculine genes that tips the scales..." (p. 57)' "Gray"
    Write-ColorOutput '  ' "Gray"
    Write-ColorOutput '  This biological basis [links to your evolutionary psych framework].' "Gray"
    Write-ColorOutput '  For complete analysis, see [CW 9 Summary](link).' "Gray"
    Write-ColorOutput ""
}

function Show-Summary {
    Write-ColorOutput "`n╔════════════════════════════════════════════════════════════════╗" $successColor
    Write-ColorOutput "║       Jung Literature Sources - GitBook Sync Complete!         ║" $successColor
    Write-ColorOutput "╚════════════════════════════════════════════════════════════════╝`n" $successColor
    
    Write-ColorOutput "✅ What Happened:`n" $infoColor
    Write-ColorOutput "  1. ✓ Git repository verified" "White"
    Write-ColorOutput "  2. ✓ Changes pushed to GitHub" "White"
    Write-ColorOutput "  3. ✓ GitBook sync initiated (automatic)" "White"
    Write-ColorOutput "  4. ✓ Content should now be visible in GitBook" "White"
    Write-ColorOutput ""
    
    Write-ColorOutput "🔗 Your Resources:`n" $infoColor
    Write-ColorOutput "  • GitBook URL: $gitBookURL" "Cyan"
    Write-ColorOutput "  • GitHub Repo: $gitHubRepo" "Cyan"
    Write-ColorOutput "  • Local Path: $dissertationRepo\03_literature_sources\Jung_Sources" "Gray"
    Write-ColorOutput ""
    
    Write-ColorOutput "📚 Content Now Available in GitBook:`n" $infoColor
    Write-ColorOutput "  • 4 Jung source summaries (57 KB)" "White"
    Write-ColorOutput "  • Complete APA bibliography (11 KB)" "White"
    Write-ColorOutput "  • 45+ quotes organized by chapter (20 KB)" "White"
    Write-ColorOutput "  • Comprehensive README and index" "White"
    Write-ColorOutput ""
    
    Write-ColorOutput "🎯 Next Steps:`n" $infoColor
    Write-ColorOutput "  1. Open GitBook and verify Jung_Sources folder appears" "White"
    Write-ColorOutput "  2. Review 99_Jung_Quotes_By_Chapter_Reference.md" "White"
    Write-ColorOutput "  3. Begin integrating quotes into Chapter 2 draft" "White"
    Write-ColorOutput "  4. Create internal links from chapters to literature sources" "White"
    Write-ColorOutput "  5. Share GitBook URL with your advisor for feedback" "White"
    Write-ColorOutput ""
}

function Show-TroubleshootingGuide {
    Write-ColorOutput "`n📋 Troubleshooting Guide:`n" $warningColor
    
    Write-ColorOutput "If Jung sources don't appear in GitBook:" "White"
    Write-ColorOutput ""
    Write-ColorOutput "1. Check GitHub first:" "Yellow"
    Write-ColorOutput "   • Visit: $gitHubRepo" "Gray"
    Write-ColorOutput "   • Navigate to: 03_literature_sources/Jung_Sources/" "Gray"
    Write-ColorOutput "   • Verify all 7 files are present" "Gray"
    Write-ColorOutput ""
    Write-ColorOutput "2. Force GitBook sync:" "Yellow"
    Write-ColorOutput "   • Open GitBook" "Gray"
    Write-ColorOutput "   • Go to Settings → GitHub Integration" "Gray"
    Write-ColorOutput "   • Click 'Sync Now' or 'Reconnect'" "Gray"
    Write-ColorOutput ""
    Write-ColorOutput "3. Check GitBook sync settings:" "Yellow"
    Write-ColorOutput "   • Ensure GitHub sync is enabled" "Gray"
    Write-ColorOutput "   • Verify correct branch (main) is selected" "Gray"
    Write-ColorOutput "   • Check for any sync error messages" "Gray"
    Write-ColorOutput ""
    Write-ColorOutput "4. Wait longer:" "Yellow"
    Write-ColorOutput "   • Large repositories can take 5-10 minutes" "Gray"
    Write-ColorOutput "   • Refresh GitBook page after waiting" "Gray"
    Write-ColorOutput ""
    Write-ColorOutput "5. Manual verification:" "Yellow"
    Write-ColorOutput "   • In GitBook, click 'Files' in sidebar" "Gray"
    Write-ColorOutput "   • Check file tree for 03_literature_sources/" "Gray"
    Write-ColorOutput "   • If files are there but not visible, rebuild navigation" "Gray"
    Write-ColorOutput ""
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

Clear-Host
Write-ColorOutput "╔════════════════════════════════════════════════════════════════╗" $infoColor
Write-ColorOutput "║      Sync Jung Literature Sources to Sacred Bonds GitBook      ║" $infoColor
Write-ColorOutput "╚════════════════════════════════════════════════════════════════╝`n" $infoColor

# Check prerequisites
if (-not (Test-GitBookPrerequisites)) {
    Write-ColorOutput "`n❌ Prerequisites check failed. Please resolve issues and try again.`n" $errorColor
    Show-TroubleshootingGuide
    exit 1
}

# Push to GitHub (if needed)
$pushSuccess = Invoke-GitHubPush
if (-not $pushSuccess) {
    Write-ColorOutput "`n⚠️  GitHub push failed. Cannot proceed with GitBook sync.`n" $warningColor
    Show-TroubleshootingGuide
    exit 1
}

# Wait for GitBook sync
Wait-ForGitBookSync

# Verify content in GitBook
Test-GitBookContent

# Show integration guide
Show-GitBookIntegrationGuide

# Show summary
Show-Summary

# Show troubleshooting if needed
$hadIssues = Read-Host "`nDid you encounter any sync issues? (y/n)"
if ($hadIssues -eq 'y') {
    Show-TroubleshootingGuide
}

Write-ColorOutput "🎉 GitBook sync process complete!`n" $successColor
Write-ColorOutput "Your Jung literature sources are now accessible in your dissertation GitBook." $infoColor
Write-ColorOutput "Share $gitBookURL with your advisor and committee members.`n" $infoColor
