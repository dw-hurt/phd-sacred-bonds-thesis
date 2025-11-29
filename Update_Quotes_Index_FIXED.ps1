# ============================================================================
# Update_Quotes_Index.ps1 (FIXED)
# Purpose: Regenerate the Complete Quote Index for the dissertation
# Based on: reorganize-quotes.ps1 (updated for current structure)
# ============================================================================

$ErrorActionPreference = "Stop"
$repoPath = "C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Update Quotes Index" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Change to repository directory
Set-Location $repoPath

Write-Host "[Step 1/6] Scanning quotes directory structure..." -ForegroundColor Yellow

# Define paths
$quotesByChapterPath = "quotes_by_chapter"
$quotesByThemePath = "quotes_by_theme"
$indexPath = "quotes\README.md"

# Verify directories exist
if (-not (Test-Path $quotesByChapterPath)) {
    Write-Host "  ✗ Error: quotes_by_chapter directory not found!" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $quotesByThemePath)) {
    Write-Host "  ✗ Error: quotes_by_theme directory not found!" -ForegroundColor Red
    exit 1
}

Write-Host "  ✓ Found quotes directories" -ForegroundColor Green

# ============================================================================
# STEP 2: SCAN CHAPTER QUOTES
# ============================================================================

Write-Host "`n[Step 2/6] Scanning chapter quote files..." -ForegroundColor Yellow

$chapterQuotes = @{}
$totalQuotesByChapter = 0

# Get all chapter markdown files
$chapterFiles = Get-ChildItem -Path $quotesByChapterPath -Filter "*.md" | 
                Where-Object { $_.Name -ne "README.md" } |
                Sort-Object Name

foreach ($file in $chapterFiles) {
    $content = Get-Content $file.FullName -Raw
    
    # Count quotes (lines starting with ">")
    $quoteCount = ($content -split "`n" | Where-Object { $_ -match "^>\s+" }).Count
    
    # Extract chapter number and name from filename or content
    $fileName = $file.BaseName
    
    # Try to extract chapter info from file content
    $chapterMatch = [regex]::Match($content, "^#\s+Chapter\s+(\d+):?\s*(.+?)$", [System.Text.RegularExpressions.RegexOptions]::Multiline)
    
    if ($chapterMatch.Success) {
        $chapterNum = $chapterMatch.Groups[1].Value
        $chapterName = $chapterMatch.Groups[2].Value.Trim()
    } else {
        # Fallback: extract from filename
        if ($fileName -match "chapter_?0?(\d+)") {
            $chapterNum = $Matches[1]
            $chapterName = $fileName -replace "chapter_?0?\d+_?", "" -replace "_", " "
            $chapterName = (Get-Culture).TextInfo.ToTitleCase($chapterName.ToLower())
        } else {
            $chapterNum = "00"
            $chapterName = $fileName
        }
    }
    
    $chapterQuotes[$chapterNum] = @{
        Name = $chapterName
        Count = $quoteCount
        File = $file.Name
    }
    
    $totalQuotesByChapter += $quoteCount
    $displayName = "Chapter $chapterNum ($chapterName)"
    Write-Host "  ✓ ${displayName}: $quoteCount quotes" -ForegroundColor White
}

Write-Host "`n  Total quotes from chapters: $totalQuotesByChapter" -ForegroundColor Green

# ============================================================================
# STEP 3: SCAN THEME QUOTES
# ============================================================================

Write-Host "`n[Step 3/6] Scanning theme quote files..." -ForegroundColor Yellow

$themeQuotes = @{}
$totalQuotesByTheme = 0

# Get all theme markdown files
$themeFiles = Get-ChildItem -Path $quotesByThemePath -Filter "*.md" | 
              Where-Object { $_.Name -ne "README.md" } |
              Sort-Object Name

foreach ($file in $themeFiles) {
    $content = Get-Content $file.FullName -Raw
    
    # Count quotes (lines starting with ">")
    $quoteCount = ($content -split "`n" | Where-Object { $_ -match "^>\s+" }).Count
    
    # Extract theme name from filename or content
    $fileName = $file.BaseName
    
    # Try to extract theme from file content
    $themeMatch = [regex]::Match($content, "^#\s+(.+?)$", [System.Text.RegularExpressions.RegexOptions]::Multiline)
    
    if ($themeMatch.Success) {
        $themeName = $themeMatch.Groups[1].Value.Trim()
        # Remove common prefixes
        $themeName = $themeName -replace "^Quotes by Theme:\s*", "" -replace "^Theme:\s*", ""
    } else {
        # Fallback: clean filename
        $themeName = $fileName -replace "_", " "
        $themeName = (Get-Culture).TextInfo.ToTitleCase($themeName.ToLower())
    }
    
    $themeQuotes[$themeName] = @{
        Count = $quoteCount
        File = $file.Name
    }
    
    $totalQuotesByTheme += $quoteCount
    # Fixed: Use explicit string formatting to avoid variable parsing issues
    $displayText = "  ✓ " + $themeName + ": " + $quoteCount + " quotes"
    Write-Host $displayText -ForegroundColor White
}

Write-Host "`n  Total quotes from themes: $totalQuotesByTheme" -ForegroundColor Green

# ============================================================================
# STEP 4: CALCULATE STATISTICS
# ============================================================================

Write-Host "`n[Step 4/6] Calculating statistics..." -ForegroundColor Yellow

# Use chapter total as authoritative count (themes may have duplicates)
$totalQuotes = $totalQuotesByChapter

if ($totalQuotes -eq 0) {
    Write-Host "  ⚠ Warning: No quotes found!" -ForegroundColor Yellow
    $totalQuotes = 1 # Avoid division by zero
}

Write-Host "  ✓ Total unique quotes: $totalQuotes" -ForegroundColor Green

# ============================================================================
# STEP 5: GENERATE INDEX CONTENT
# ============================================================================

Write-Host "`n[Step 5/6] Generating updated index..." -ForegroundColor Yellow

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# Build the index content
$indexContent = @"
# Complete Quote Index

**Total Quotes**: $totalQuotes  
**Last Updated**: $timestamp  
**Auto-generated by**: Update_Quotes_Index.ps1

This index provides an overview of all quotes organized by chapter and theme.

---

## Quick Navigation

### By Chapter

"@

# Add chapter links (sorted by chapter number)
foreach ($chapterNum in ($chapterQuotes.Keys | Sort-Object { [int]$_ })) {
    $chapter = $chapterQuotes[$chapterNum]
    $chapterName = $chapter.Name
    $quoteCount = $chapter.Count
    $fileName = $chapter.File -replace "\.md$", ""
    
    $indexContent += "- **[Chapter $chapterNum - $chapterName](../quotes_by_chapter/$fileName.md)** — $quoteCount quotes`n"
}

$indexContent += @"

### By Theme

"@

# Add theme links (sorted alphabetically)
foreach ($themeName in ($themeQuotes.Keys | Sort-Object)) {
    $theme = $themeQuotes[$themeName]
    $quoteCount = $theme.Count
    $fileName = $theme.File -replace "\.md$", ""
    
    $indexContent += "- **[$themeName](../quotes_by_theme/$fileName.md)** — $quoteCount quotes`n"
}

$indexContent += @"

---

## Statistics

### Chapter Coverage

"@

# Add chapter statistics (sorted by chapter number)
foreach ($chapterNum in ($chapterQuotes.Keys | Sort-Object { [int]$_ })) {
    $chapter = $chapterQuotes[$chapterNum]
    $chapterName = $chapter.Name
    $quoteCount = $chapter.Count
    $percentage = [math]::Round(($quoteCount / $totalQuotes) * 100, 1)
    $barLength = [math]::Floor($percentage / 5)
    $bar = "█" * $barLength
    
    $indexContent += "- **Chapter $chapterNum** ($chapterName): $quoteCount quotes ($percentage%) $bar`n"
}

$indexContent += @"

### Theme Coverage

"@

# Add theme statistics (sorted alphabetically)
foreach ($themeName in ($themeQuotes.Keys | Sort-Object)) {
    $theme = $themeQuotes[$themeName]
    $quoteCount = $theme.Count
    
    if ($totalQuotes -gt 0) {
        $percentage = [math]::Round(($quoteCount / $totalQuotes) * 100, 1)
    } else {
        $percentage = 0
    }
    
    $barLength = [math]::Floor($percentage / 5)
    $bar = "█" * $barLength
    
    $indexContent += "- **$themeName**: $quoteCount quotes ($percentage%) $bar`n"
}

$indexContent += @"

---

## Usage

### For Writing

1. Navigate to the chapter you're drafting
2. Review relevant quotes from the chapter file
3. Cross-reference with theme files for additional perspectives

### For Analysis

- Use theme files to track cross-cutting concepts
- Compare quote distribution across chapters
- Identify gaps in source coverage

---

## Cross-Reference Structure

### Chapter to Theme Mapping

Each quote in a chapter file should reference relevant themes:
- Archetypal patterns and universal structures
- Unconscious processes and psychodynamic mechanisms
- Synchronicity and meaningful coincidences
- Transpersonal dimensions in relationships
- Shadow integration and projection dynamics

### Theme to Chapter Mapping

Each theme file organizes quotes across multiple chapters:
- Track thematic development throughout dissertation
- Identify conceptual patterns across different contexts
- Support comparative analysis and integration

---

## Maintenance

**To update this index:**

``````powershell
cd C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis
.\Update_Quotes_Index.ps1
``````

**When to update:**
- After adding new quote files
- After reorganizing existing quotes
- After significant content changes
- Weekly during active writing

**What gets updated:**
- Quote counts per chapter
- Quote counts per theme
- Total quote statistics
- Coverage percentages
- Last updated timestamp

---

## Quality Metrics

### Coverage Goals
- ✅ All chapters have relevant quotes
- ✅ All themes are represented across chapters
- ✅ Even distribution across major chapters (3-7)
- ✅ Sufficient depth per chapter (15-30 quotes)

### Current Status
- **Total Quotes**: $totalQuotes
- **Chapter Files**: $($chapterQuotes.Count)
- **Theme Files**: $($themeQuotes.Count)
- **Average per Chapter**: $([math]::Round($totalQuotes / [math]::Max($chapterQuotes.Count, 1), 1))
- **Coverage Quality**: $(if ($totalQuotes -gt 100) { "Excellent" } elseif ($totalQuotes -gt 50) { "Good" } else { "Needs improvement" })

---

*This index is auto-generated. Re-run Update_Quotes_Index.ps1 to refresh.*  
*Last generated: $timestamp*
"@

# ============================================================================
# STEP 6: WRITE INDEX FILE
# ============================================================================

Write-Host "`n[Step 6/6] Writing updated index..." -ForegroundColor Yellow

# Ensure quotes directory exists
$quotesDir = Split-Path $indexPath -Parent
if (-not (Test-Path $quotesDir)) {
    New-Item -ItemType Directory -Path $quotesDir -Force | Out-Null
    Write-Host "  ✓ Created quotes directory" -ForegroundColor Green
}

# Write the index file
$indexContent | Out-File -FilePath $indexPath -Encoding UTF8 -NoNewline
Write-Host "  ✓ Index written to: $indexPath" -ForegroundColor Green

$fileSize = (Get-Item $indexPath).Length
Write-Host "  ✓ File size: $([math]::Round($fileSize/1KB, 2)) KB" -ForegroundColor White

# ============================================================================
# COMMIT CHANGES
# ============================================================================

Write-Host "`n[Optional] Committing changes to git..." -ForegroundColor Yellow

try {
    # Check if there are changes
    $gitDiff = git diff --name-only $indexPath 2>$null
    
    if ($gitDiff) {
        git add $indexPath
        
        $commitMessage = @"
Update quotes index

- Total quotes: $totalQuotes
- Chapter files: $($chapterQuotes.Count)
- Theme files: $($themeQuotes.Count)
- Updated: $timestamp

Auto-generated by Update_Quotes_Index.ps1
"@
        
        git commit -m $commitMessage
        Write-Host "  ✓ Changes committed" -ForegroundColor Green
        
        # Ask if user wants to push
        Write-Host "`n  Push changes to GitHub? (y/n): " -ForegroundColor Yellow -NoNewline
        $response = Read-Host
        
        if ($response -eq 'y') {
            git push origin main
            Write-Host "  ✓ Changes pushed to GitHub" -ForegroundColor Green
            Write-Host "  ✓ GitBook will sync in 2-5 minutes" -ForegroundColor Cyan
        } else {
            Write-Host "  ℹ Changes committed locally only" -ForegroundColor Cyan
            Write-Host "  Run 'git push origin main' to sync to GitHub/GitBook" -ForegroundColor White
        }
    } else {
        Write-Host "  ℹ No changes to commit (index unchanged)" -ForegroundColor Cyan
    }
} catch {
    Write-Host "  ⚠ Git operation skipped: $_" -ForegroundColor Yellow
    Write-Host "  You can commit manually if needed" -ForegroundColor White
}

# ============================================================================
# COMPLETION SUMMARY
# ============================================================================

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Quotes Index Update Complete!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Summary:" -ForegroundColor Yellow
Write-Host "  • Total Quotes: $totalQuotes" -ForegroundColor White
Write-Host "  • Chapter Files: $($chapterQuotes.Count)" -ForegroundColor White
Write-Host "  • Theme Files: $($themeQuotes.Count)" -ForegroundColor White
Write-Host "  • Index Location: $indexPath" -ForegroundColor White
Write-Host "  • Last Updated: $timestamp" -ForegroundColor White
Write-Host ""

Write-Host "Chapter Breakdown:" -ForegroundColor Yellow
foreach ($chapterNum in ($chapterQuotes.Keys | Sort-Object { [int]$_ } | Select-Object -First 5)) {
    $chapter = $chapterQuotes[$chapterNum]
    $chName = $chapter.Name
    $chCount = $chapter.Count
    Write-Host "  • Chapter $chapterNum ($chName): $chCount quotes" -ForegroundColor White
}
if ($chapterQuotes.Count -gt 5) {
    Write-Host "  • ... and $($chapterQuotes.Count - 5) more chapters" -ForegroundColor Gray
}
Write-Host ""

Write-Host "Top Themes:" -ForegroundColor Yellow
foreach ($themeName in ($themeQuotes.Keys | Sort-Object { $themeQuotes[$_].Count } -Descending | Select-Object -First 5)) {
    $theme = $themeQuotes[$themeName]
    $thCount = $theme.Count
    Write-Host "  • ${themeName}: $thCount quotes" -ForegroundColor White
}
if ($themeQuotes.Count -gt 5) {
    Write-Host "  • ... and $($themeQuotes.Count - 5) more themes" -ForegroundColor Gray
}
Write-Host ""

Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "  1. View updated index: notepad $indexPath" -ForegroundColor White
Write-Host "  2. Verify quote counts are accurate" -ForegroundColor White
Write-Host "  3. Review theme coverage" -ForegroundColor White
Write-Host "  4. Check GitBook after sync (if pushed)" -ForegroundColor White
Write-Host ""

Write-Host "GitBook URL: https://app.gitbook.com/o/cyZpWhV7KomErB6BnmVk/s/hRoSpCiTUrfuH62swMvH/" -ForegroundColor Cyan
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "✓ Index successfully updated!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
