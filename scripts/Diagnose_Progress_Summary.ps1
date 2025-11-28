#Requires -Version 7.0
<#
.SYNOPSIS
    Diagnoses progress summary status in local repo, GitHub, and GitBook

.DESCRIPTION
    Comprehensive diagnostic tool that checks:
    1. Local file existence and content
    2. Git tracking status
    3. GitHub remote status
    4. SUMMARY.md configuration
    5. GitBook sync issues
    6. File naming and path issues
#>

Write-Host "`n══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Progress Summary Diagnostic Tool" -ForegroundColor Cyan
Write-Host "══════════════════════════════════════════════════════`n" -ForegroundColor Cyan

# Check if in correct directory
if (-not (Test-Path "SUMMARY.md")) {
    Write-Host "ERROR: SUMMARY.md not found. Please run from repository root." -ForegroundColor Red
    exit 1
}

# ============================================================================
# SECTION 1: LOCAL FILE STATUS
# ============================================================================

Write-Host "═══ SECTION 1: LOCAL FILE STATUS ═══`n" -ForegroundColor Yellow

Write-Host "Searching for progress summary files..." -ForegroundColor Cyan

# Find all possible progress summary files
$progressFiles = Get-ChildItem -Recurse -Filter "*progress*summary*.md" -ErrorAction SilentlyContinue

if ($progressFiles.Count -eq 0) {
    Write-Host "✗ NO progress summary files found in repository!" -ForegroundColor Red
} else {
    Write-Host "✓ Found $($progressFiles.Count) progress summary file(s):`n" -ForegroundColor Green
    
    foreach ($file in $progressFiles) {
        $relativePath = $file.FullName.Replace((Get-Location).Path + "\", "")
        $size = [math]::Round($file.Length / 1KB, 1)
        $lastModified = $file.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")
        
        Write-Host "  File: $relativePath" -ForegroundColor White
        Write-Host "    Size: $size KB" -ForegroundColor Gray
        Write-Host "    Last Modified: $lastModified" -ForegroundColor Gray
        Write-Host "    Full Path: $($file.FullName)" -ForegroundColor Gray
        
        # Check if file has content
        $content = Get-Content $file.FullName -Raw
        if ($content.Length -lt 100) {
            Write-Host "    ⚠ WARNING: File appears empty or very small!" -ForegroundColor Red
        } else {
            $lines = ($content -split "`n").Count
            Write-Host "    Content: $lines lines" -ForegroundColor Gray
            
            # Check for date in content
            if ($content -match "Last Updated.*?(\d{4})") {
                Write-Host "    Date in content: Contains date reference" -ForegroundColor Gray
            }
        }
        Write-Host ""
    }
}

# ============================================================================
# SECTION 2: GIT TRACKING STATUS
# ============================================================================

Write-Host "`n═══ SECTION 2: GIT TRACKING STATUS ═══`n" -ForegroundColor Yellow

Write-Host "Checking git status..." -ForegroundColor Cyan

# Check if files are tracked
Write-Host "`nTracked progress summary files in git:" -ForegroundColor Cyan
$trackedFiles = git ls-files | Select-String -Pattern "progress.*summary"

if ($trackedFiles) {
    foreach ($file in $trackedFiles) {
        Write-Host "  ✓ $file" -ForegroundColor Green
    }
} else {
    Write-Host "  ✗ NO progress summary files tracked in git!" -ForegroundColor Red
}

# Check for untracked files
Write-Host "`nUntracked progress summary files:" -ForegroundColor Cyan
$untrackedFiles = git status --short | Select-String -Pattern "progress.*summary"

if ($untrackedFiles) {
    foreach ($file in $untrackedFiles) {
        Write-Host "  ⚠ $file" -ForegroundColor Yellow
    }
} else {
    Write-Host "  ✓ No untracked progress summary files" -ForegroundColor Green
}

# Check recent commits for progress summary
Write-Host "`nRecent commits mentioning progress summary:" -ForegroundColor Cyan
$recentCommits = git log --oneline --all --grep="progress" -10

if ($recentCommits) {
    $recentCommits | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
} else {
    Write-Host "  ⚠ No recent commits found mentioning 'progress'" -ForegroundColor Yellow
}

# ============================================================================
# SECTION 3: GITHUB REMOTE STATUS
# ============================================================================

Write-Host "`n`n═══ SECTION 3: GITHUB REMOTE STATUS ═══`n" -ForegroundColor Yellow

Write-Host "Fetching latest from GitHub..." -ForegroundColor Cyan
git fetch origin --quiet

# Check if local is behind remote
$status = git status -uno
Write-Host "`nBranch sync status:" -ForegroundColor Cyan
if ($status -match "behind") {
    Write-Host "  ⚠ Local branch is BEHIND remote - you need to pull!" -ForegroundColor Red
    $behindCount = [regex]::Match($status, "behind (\d+)").Groups[1].Value
    Write-Host "    Behind by: $behindCount commits" -ForegroundColor Yellow
} elseif ($status -match "ahead") {
    Write-Host "  ⚠ Local branch is AHEAD of remote - you need to push!" -ForegroundColor Yellow
    $aheadCount = [regex]::Match($status, "ahead (\d+)").Groups[1].Value
    Write-Host "    Ahead by: $aheadCount commits" -ForegroundColor Yellow
} else {
    Write-Host "  ✓ Local and remote branches are in sync" -ForegroundColor Green
}

# Check what's on GitHub remote
Write-Host "`nFiles on GitHub remote (origin/main):" -ForegroundColor Cyan
$remoteFiles = git ls-tree -r --name-only origin/main | Select-String -Pattern "progress.*summary"

if ($remoteFiles) {
    foreach ($file in $remoteFiles) {
        Write-Host "  ✓ $file" -ForegroundColor Green
    }
} else {
    Write-Host "  ✗ NO progress summary files found on GitHub!" -ForegroundColor Red
}

# ============================================================================
# SECTION 4: SUMMARY.MD CONFIGURATION
# ============================================================================

Write-Host "`n`n═══ SECTION 4: SUMMARY.MD CONFIGURATION ═══`n" -ForegroundColor Yellow

Write-Host "Checking SUMMARY.md for progress summary links..." -ForegroundColor Cyan

$summaryContent = Get-Content "SUMMARY.md" -Raw

# Search for progress-related entries
$progressEntries = Get-Content "SUMMARY.md" | Select-String -Pattern "progress" -Context 2

if ($progressEntries) {
    Write-Host "`n✓ Found progress-related entries in SUMMARY.md:`n" -ForegroundColor Green
    
    foreach ($entry in $progressEntries) {
        Write-Host $entry.Line -ForegroundColor White
        if ($entry.Context.PreContext) {
            $entry.Context.PreContext | ForEach-Object { Write-Host "  Context: $_" -ForegroundColor Gray }
        }
        Write-Host ""
    }
    
    # Extract the actual link
    $linkMatches = [regex]::Matches($summaryContent, '\[.*?progress.*?\]\((.*?)\)')
    
    if ($linkMatches.Count -gt 0) {
        Write-Host "Progress summary links found:" -ForegroundColor Cyan
        foreach ($match in $linkMatches) {
            $linkedPath = $match.Groups[1].Value
            Write-Host "  Linked path: $linkedPath" -ForegroundColor White
            
            # Check if linked file exists
            if (Test-Path $linkedPath) {
                Write-Host "    ✓ File exists at this path" -ForegroundColor Green
                $fileSize = [math]::Round((Get-Item $linkedPath).Length / 1KB, 1)
                Write-Host "    Size: $fileSize KB" -ForegroundColor Gray
            } else {
                Write-Host "    ✗ FILE DOES NOT EXIST at this path!" -ForegroundColor Red
            }
        }
    }
} else {
    Write-Host "✗ NO progress-related entries found in SUMMARY.md!" -ForegroundColor Red
    Write-Host "  This is likely why GitBook isn't showing it!" -ForegroundColor Yellow
}

# ============================================================================
# SECTION 5: GITBOOK CONFIGURATION
# ============================================================================

Write-Host "`n`n═══ SECTION 5: GITBOOK CONFIGURATION ═══`n" -ForegroundColor Yellow

Write-Host "Checking .gitbook.yaml configuration..." -ForegroundColor Cyan

if (Test-Path ".gitbook.yaml") {
    $gitbookConfig = Get-Content ".gitbook.yaml" -Raw
    Write-Host "✓ .gitbook.yaml exists`n" -ForegroundColor Green
    Write-Host $gitbookConfig -ForegroundColor Gray
    
    # Check for exclusions
    if ($gitbookConfig -match "progress") {
        Write-Host "`n⚠ WARNING: 'progress' pattern found in .gitbook.yaml!" -ForegroundColor Red
        Write-Host "  Check if progress folder is being excluded!" -ForegroundColor Yellow
    } else {
        Write-Host "`n✓ No 'progress' exclusion pattern found" -ForegroundColor Green
    }
} else {
    Write-Host "✗ .gitbook.yaml NOT FOUND!" -ForegroundColor Red
    Write-Host "  GitBook may not sync properly without this file" -ForegroundColor Yellow
}

# Check .gitignore for progress exclusions
Write-Host "`nChecking .gitignore for progress exclusions..." -ForegroundColor Cyan

if (Test-Path ".gitignore") {
    $gitignoreContent = Get-Content ".gitignore" | Select-String -Pattern "progress"
    
    if ($gitignoreContent) {
        Write-Host "⚠ WARNING: 'progress' pattern found in .gitignore:" -ForegroundColor Red
        foreach ($line in $gitignoreContent) {
            Write-Host "  $line" -ForegroundColor Yellow
        }
    } else {
        Write-Host "✓ No 'progress' exclusion in .gitignore" -ForegroundColor Green
    }
} else {
    Write-Host "⚠ .gitignore not found" -ForegroundColor Yellow
}

# ============================================================================
# SECTION 6: FILE NAMING AND PATH ANALYSIS
# ============================================================================

Write-Host "`n`n═══ SECTION 6: FILE NAMING ANALYSIS ═══`n" -ForegroundColor Yellow

Write-Host "Analyzing file naming conventions..." -ForegroundColor Cyan

# Check for common naming issues
$allProgressFiles = Get-ChildItem -Recurse -Filter "*progress*.md" -ErrorAction SilentlyContinue

if ($allProgressFiles) {
    Write-Host "`nAll progress-related markdown files:" -ForegroundColor Cyan
    
    foreach ($file in $allProgressFiles) {
        $relativePath = $file.FullName.Replace((Get-Location).Path + "\", "")
        Write-Host "  $relativePath" -ForegroundColor White
        
        # Check for naming issues
        if ($file.Name -match "\s") {
            Write-Host "    ⚠ Contains spaces in filename" -ForegroundColor Yellow
        }
        if ($file.Name -match "[A-Z]") {
            Write-Host "    ⚠ Contains uppercase letters" -ForegroundColor Yellow
        }
        if ($file.Directory.Name -match "\s") {
            Write-Host "    ⚠ Directory contains spaces" -ForegroundColor Yellow
        }
    }
}

# ============================================================================
# SECTION 7: RECOMMENDED ACTIONS
# ============================================================================

Write-Host "`n`n═══ SECTION 7: DIAGNOSTIC SUMMARY & RECOMMENDATIONS ═══`n" -ForegroundColor Yellow

# Collect all issues
$issues = @()
$warnings = @()

if ($progressFiles.Count -eq 0) {
    $issues += "No progress summary files found locally"
}

if (-not $trackedFiles) {
    $issues += "No progress summary files tracked in git"
}

if (-not $remoteFiles) {
    $issues += "No progress summary files on GitHub remote"
}

if (-not $progressEntries) {
    $issues += "No progress summary links in SUMMARY.md"
}

if ($status -match "behind") {
    $warnings += "Local branch behind remote - need to pull"
}

if ($status -match "ahead") {
    $warnings += "Local branch ahead of remote - need to push"
}

# Display issues
if ($issues.Count -gt 0) {
    Write-Host "🚨 CRITICAL ISSUES FOUND:`n" -ForegroundColor Red
    foreach ($issue in $issues) {
        Write-Host "  ✗ $issue" -ForegroundColor Red
    }
    Write-Host ""
}

if ($warnings.Count -gt 0) {
    Write-Host "⚠ WARNINGS:`n" -ForegroundColor Yellow
    foreach ($warning in $warnings) {
        Write-Host "  ⚠ $warning" -ForegroundColor Yellow
    }
    Write-Host ""
}

if ($issues.Count -eq 0 -and $warnings.Count -eq 0) {
    Write-Host "✓ No critical issues found!" -ForegroundColor Green
    Write-Host "`nLikely cause of GitBook issue: Sync delay or cache" -ForegroundColor Cyan
    Write-Host "Wait 5-10 minutes and check again." -ForegroundColor Cyan
}

# Provide specific recommendations
Write-Host "`nRECOMMENDED ACTIONS:`n" -ForegroundColor Cyan

if ($issues -contains "No progress summary files found locally") {
    Write-Host "1. ⚠ Run Extract_And_Update_Progress_Summary.ps1 to create the file" -ForegroundColor Yellow
}

if ($issues -contains "No progress summary files tracked in git") {
    Write-Host "2. ⚠ Stage and commit progress summary file:" -ForegroundColor Yellow
    Write-Host "   git add progress-summary/dissertation_progress_summary.md" -ForegroundColor White
    Write-Host "   git commit -m 'Add progress summary'" -ForegroundColor White
}

if ($issues -contains "No progress summary files on GitHub remote") {
    Write-Host "3. ⚠ Push to GitHub:" -ForegroundColor Yellow
    Write-Host "   git push origin main" -ForegroundColor White
}

if ($issues -contains "No progress summary links in SUMMARY.md") {
    Write-Host "4. 🚨 CRITICAL: Add progress summary to SUMMARY.md:" -ForegroundColor Red
    Write-Host "   Add this line to SUMMARY.md:" -ForegroundColor White
    Write-Host "   * [Progress Summary](progress-summary/dissertation_progress_summary.md)" -ForegroundColor White
}

if ($warnings -contains "Local branch behind remote - need to pull") {
    Write-Host "5. ⚠ Pull latest changes:" -ForegroundColor Yellow
    Write-Host "   git pull --rebase origin main" -ForegroundColor White
}

if ($warnings -contains "Local branch ahead of remote - need to push") {
    Write-Host "6. ⚠ Push local commits:" -ForegroundColor Yellow
    Write-Host "   git push origin main" -ForegroundColor White
}

if ($issues.Count -eq 0) {
    Write-Host "7. ⏰ If all files are correct, this may be a GitBook sync issue:" -ForegroundColor Cyan
    Write-Host "   - Wait 5-10 minutes for automatic sync" -ForegroundColor White
    Write-Host "   - Or manually trigger sync in GitBook settings" -ForegroundColor White
    Write-Host "   - Check GitBook > Space Settings > Git Sync" -ForegroundColor White
}

# ============================================================================
# SECTION 8: QUICK FIX COMMANDS
# ============================================================================

Write-Host "`n`n═══ SECTION 8: QUICK FIX COMMANDS ═══`n" -ForegroundColor Yellow

Write-Host "If progress summary exists but isn't showing in GitBook, run these commands:`n" -ForegroundColor Cyan

Write-Host "# 1. Verify file exists and has content" -ForegroundColor Gray
Write-Host 'Get-Item "progress-summary/dissertation_progress_summary.md" | Select-Object Name, Length' -ForegroundColor White
Write-Host ""

Write-Host "# 2. Check SUMMARY.md contains link" -ForegroundColor Gray
Write-Host 'Get-Content "SUMMARY.md" | Select-String "progress"' -ForegroundColor White
Write-Host ""

Write-Host "# 3. Ensure file is tracked and pushed" -ForegroundColor Gray
Write-Host 'git add progress-summary/dissertation_progress_summary.md' -ForegroundColor White
Write-Host 'git add SUMMARY.md' -ForegroundColor White
Write-Host 'git commit -m "Update progress summary"' -ForegroundColor White
Write-Host 'git push origin main' -ForegroundColor White
Write-Host ""

Write-Host "# 4. Force GitBook sync (if still not showing after 10 min)" -ForegroundColor Gray
Write-Host 'echo "<!-- Sync trigger: $(Get-Date) -->" >> README.md' -ForegroundColor White
Write-Host 'git add README.md' -ForegroundColor White
Write-Host 'git commit -m "Trigger GitBook sync"' -ForegroundColor White
Write-Host 'git push origin main' -ForegroundColor White
Write-Host ""

Write-Host "`n══════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "  Diagnostic Complete!" -ForegroundColor Green
Write-Host "══════════════════════════════════════════════════════`n" -ForegroundColor Green

Write-Host "Review the sections above to identify the issue." -ForegroundColor Cyan
Write-Host "Follow the recommended actions to resolve problems.`n" -ForegroundColor Cyan
