# ============================================================================
# Update_Quotes_Index_CUSTOM.ps1
# Purpose: Update quotes index for your specific directory structure
# Structure: quotes/by_chapter/, quotes/by_theme/, quotes/by_source/
# ============================================================================

$ErrorActionPreference = "Stop"
$repoPath = "C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Update Quotes Index" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Set-Location $repoPath

Write-Host "[Step 1/7] Scanning quotes directory structure..." -ForegroundColor Yellow

# Your actual directory structure
$quotesByChapterPath = "quotes\by_chapter"
$quotesByThemePath = "quotes\by_theme"
$quotesBySourcePath = "quotes\by_source"
$indexPath = "quotes\README.md"

# Verify directories exist
$foundChapters = Test-Path $quotesByChapterPath
$foundThemes = Test-Path $quotesByThemePath
$foundSources = Test-Path $quotesBySourcePath

Write-Host "  ✓ Found chapters: $foundChapters" -ForegroundColor $(if($foundChapters){"Green"}else{"Yellow"})
Write-Host "  ✓ Found themes: $foundThemes" -ForegroundColor $(if($foundThemes){"Green"}else{"Yellow"})
Write-Host "  ✓ Found sources: $foundSources" -ForegroundColor $(if($foundSources){"Green"}else{"Yellow"})

# ============================================================================
# STEP 2: SCAN CHAPTER QUOTES
# ============================================================================

Write-Host "`n[Step 2/7] Scanning chapter quote files..." -ForegroundColor Yellow

$chapterQuotes = @{}
$totalQuotesByChapter = 0

if ($foundChapters) {
    $chapterFiles = Get-ChildItem -Path $quotesByChapterPath -Filter "*.md" | 
                    Where-Object { $_.Name -notmatch "README|backup" } |
                    Sort-Object Name
    
    foreach ($file in $chapterFiles) {
        $content = Get-Content $file.FullName -Raw
        
        # Count quotes (lines starting with ">")
        $quoteCount = ($content -split "`n" | Where-Object { $_ -match "^>\s+" }).Count
        
        $fileName = $file.BaseName
        
        # Extract chapter number
        if ($fileName -match "chapter_?0?(\d+)") {
            $chapterNum = $Matches[1]
            
            # Extract chapter name
            if ($content -match "^#\s+Chapter\s+\d+:?\s*(.+?)$") {
                $chapterName = $Matches[1].Trim()
            } else {
                $chapterName = $fileName -replace "chapter_?0?\d+_?", "" -replace "_", " " -replace " quotes$", ""
                $chapterName = (Get-Culture).TextInfo.ToTitleCase($chapterName.ToLower())
            }
            
            $chapterQuotes[$chapterNum] = @{
                Name = $chapterName
                Count = $quoteCount
                File = $file.Name
            }
            
            $totalQuotesByChapter += $quoteCount
            Write-Host ("  ✓ Chapter " + $chapterNum + " (" + $chapterName + "): " + $quoteCount + " quotes") -ForegroundColor White
        }
    }
    
    Write-Host "`n  Total quotes from chapters: $totalQuotesByChapter" -ForegroundColor Green
}

# ============================================================================
# STEP 3: SCAN THEME QUOTES
# ============================================================================

Write-Host "`n[Step 3/7] Scanning theme quote files..." -ForegroundColor Yellow

$themeQuotes = @{}
$totalQuotesByTheme = 0

if ($foundThemes) {
    $themeFiles = Get-ChildItem -Path $quotesByThemePath -Filter "*.md" | 
                  Where-Object { $_.Name -ne "README.md" } |
                  Sort-Object Name
    
    foreach ($file in $themeFiles) {
        $content = Get-Content $file.FullName -Raw
        
        # Count quotes
        $quoteCount = ($content -split "`n" | Where-Object { $_ -match "^>\s+" }).Count
        
        $fileName = $file.BaseName
        
        # Extract theme name from first heading
        if ($content -match "^#\s+(.+?)$") {
            $themeName = $Matches[1].Trim()
            $themeName = $themeName -replace "^Quotes by Theme:\s*", "" -replace "^Theme:\s*", ""
        } else {
            $themeName = $fileName -replace "_", " "
        }
        
        $themeQuotes[$themeName] = @{
            Count = $quoteCount
            File = $file.Name
        }
        
        $totalQuotesByTheme += $quoteCount
        Write-Host ("  ✓ " + $themeName + ": " + $quoteCount + " quotes") -ForegroundColor White
    }
    
    Write-Host "`n  Total quotes from themes: $totalQuotesByTheme" -ForegroundColor Green
}

# ============================================================================
# STEP 4: SCAN SOURCE QUOTES
# ============================================================================

Write-Host "`n[Step 4/7] Scanning source quote files..." -ForegroundColor Yellow

$sourceQuotes = @{}
$totalQuotesBySource = 0

if ($foundSources) {
    $sourceFiles = Get-ChildItem -Path $quotesBySourcePath -Filter "*quotes*.md" |
                   Sort-Object Name
    
    foreach ($file in $sourceFiles) {
        $content = Get-Content $file.FullName -Raw
        
        # Count quotes
        $quoteCount = ($content -split "`n" | Where-Object { $_ -match "^>\s+" }).Count
        
        $fileName = $file.BaseName -replace "_quotes.*$", "" -replace "_Quotes.*$", ""
        
        # Extract source name
        if ($content -match "^#\s+(.+?)$") {
            $sourceName = $Matches[1].Trim()
            $sourceName = $sourceName -replace "^Quotes from\s*", "" -replace "\s*Quotes$", ""
        } else {
            $sourceName = $fileName -replace "_", " "
        }
        
        $sourceQuotes[$sourceName] = @{
            Count = $quoteCount
            File = $file.Name
        }
        
        $totalQuotesBySource += $quoteCount
        Write-Host ("  ✓ " + $sourceName + ": " + $quoteCount + " quotes") -ForegroundColor White
    }
    
    Write-Host "`n  Total quotes from sources: $totalQuotesBySource" -ForegroundColor Green
}

# ============================================================================
# STEP 5: CALCULATE STATISTICS
# ============================================================================

Write-Host "`n[Step 5/7] Calculating statistics..." -ForegroundColor Yellow

$totalQuotes = [math]::Max($totalQuotesByChapter, 1)

Write-Host "  ✓ Total unique quotes: $totalQuotes" -ForegroundColor Green
Write-Host "  ✓ Chapter files: $($chapterQuotes.Count)" -ForegroundColor Green
Write-Host "  ✓ Theme files: $($themeQuotes.Count)" -ForegroundColor Green
Write-Host "  ✓ Source files: $($sourceQuotes.Count)" -ForegroundColor Green

# ============================================================================
# STEP 6: GENERATE INDEX CONTENT
# ============================================================================

Write-Host "`n[Step 6/7] Generating updated index..." -ForegroundColor Yellow

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$indexContent = @"
# Complete Quote Index

**Total Quotes**: $totalQuotes  
**Last Updated**: $timestamp  
**Auto-generated by**: Update_Quotes_Index_CUSTOM.ps1

This index provides an overview of all quotes organized by chapter, theme, and source.

---

## Quick Navigation

### By Chapter

"@

foreach ($chapterNum in ($chapterQuotes.Keys | Sort-Object { [int]$_ })) {
    $chapter = $chapterQuotes[$chapterNum]
    $indexContent += "- **[Chapter $chapterNum - $($chapter.Name)](by_chapter/$($chapter.File))** — $($chapter.Count) quotes`n"
}

$indexContent += @"

### By Theme

"@

foreach ($themeName in ($themeQuotes.Keys | Sort-Object)) {
    $theme = $themeQuotes[$themeName]
    $indexContent += "- **[$themeName](by_theme/$($theme.File))** — $($theme.Count) quotes`n"
}

$indexContent += @"

### By Source

"@

foreach ($sourceName in ($sourceQuotes.Keys | Sort-Object)) {
    $source = $sourceQuotes[$sourceName]
    $indexContent += "- **[$sourceName](by_source/$($source.File))** — $($source.Count) quotes`n"
}

$indexContent += @"

---

## Statistics

### Chapter Coverage

"@

foreach ($chapterNum in ($chapterQuotes.Keys | Sort-Object { [int]$_ })) {
    $chapter = $chapterQuotes[$chapterNum]
    $percentage = [math]::Round(($chapter.Count / $totalQuotes) * 100, 1)
    $bar = "█" * [math]::Floor($percentage / 5)
    $indexContent += "- **Chapter $chapterNum** ($($chapter.Name)): $($chapter.Count) quotes ($percentage%) $bar`n"
}

$indexContent += @"

### Theme Coverage

"@

foreach ($themeName in ($themeQuotes.Keys | Sort-Object)) {
    $theme = $themeQuotes[$themeName]
    $percentage = [math]::Round(($theme.Count / $totalQuotes) * 100, 1)
    $bar = "█" * [math]::Floor($percentage / 5)
    $indexContent += "- **$themeName**: $($theme.Count) quotes ($percentage%) $bar`n"
}

$indexContent += @"

### Source Coverage

Top 10 sources by quote count:

"@

$topSources = $sourceQuotes.GetEnumerator() | Sort-Object {$_.Value.Count} -Descending | Select-Object -First 10
foreach ($source in $topSources) {
    $sourceName = $source.Key
    $count = $source.Value.Count
    $indexContent += "- **$sourceName**: $count quotes`n"
}

$indexContent += @"

---

## Usage

### For Writing
1. Navigate to the chapter you're drafting
2. Review relevant quotes from the chapter file
3. Cross-reference with theme files for additional perspectives
4. Check source files for context

### For Analysis
- Use theme files to track cross-cutting concepts
- Compare quote distribution across chapters
- Identify gaps in source coverage
- Track theoretical frameworks

---

## Maintenance

**To update this index:**
``````powershell
cd C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis
.\Update_Quotes_Index_CUSTOM.ps1
``````

**When to update:**
- After adding new quote files
- After reorganizing existing quotes
- Weekly during active writing

---

## Quality Metrics

- **Total Quotes**: $totalQuotes
- **Chapter Files**: $($chapterQuotes.Count)
- **Theme Files**: $($themeQuotes.Count)
- **Source Files**: $($sourceQuotes.Count)
- **Average per Chapter**: $([math]::Round($totalQuotes / [math]::Max($chapterQuotes.Count, 1), 1))
- **Coverage Quality**: $(if ($totalQuotes -gt 100) { "Excellent" } elseif ($totalQuotes -gt 50) { "Good" } else { "Needs improvement" })

---

*Last generated: $timestamp*
"@

# ============================================================================
# STEP 7: WRITE INDEX FILE
# ============================================================================

Write-Host "`n[Step 7/7] Writing and committing..." -ForegroundColor Yellow

$indexContent | Out-File -FilePath $indexPath -Encoding UTF8 -NoNewline
Write-Host "  ✓ Index written: $indexPath" -ForegroundColor Green

$fileSize = (Get-Item $indexPath).Length
Write-Host "  ✓ File size: $([math]::Round($fileSize/1KB, 2)) KB" -ForegroundColor White

# Git operations
try {
    $gitDiff = git diff --name-only $indexPath 2>$null
    
    if ($gitDiff) {
        git add $indexPath
        git commit -m "Update quotes index: $totalQuotes total, $($chapterQuotes.Count) chapters, $($themeQuotes.Count) themes, $($sourceQuotes.Count) sources"
        Write-Host "  ✓ Committed" -ForegroundColor Green
        
        Write-Host "`n  Push to GitHub? (y/n): " -ForegroundColor Yellow -NoNewline
        $response = Read-Host
        
        if ($response -eq 'y') {
            git push origin main
            Write-Host "  ✓ Pushed to GitHub - GitBook will sync in 2-5 min" -ForegroundColor Green
        }
    } else {
        Write-Host "  ℹ No changes" -ForegroundColor Cyan
    }
} catch {
    Write-Host "  ⚠ Git skipped" -ForegroundColor Yellow
}

# ============================================================================
# SUMMARY
# ============================================================================

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "✓ Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Summary:" -ForegroundColor Yellow
Write-Host "  • Total Quotes: $totalQuotes" -ForegroundColor White
Write-Host "  • Chapters: $($chapterQuotes.Count)" -ForegroundColor White
Write-Host "  • Themes: $($themeQuotes.Count)" -ForegroundColor White
Write-Host "  • Sources: $($sourceQuotes.Count)" -ForegroundColor White
Write-Host ""
Write-Host "View: notepad $indexPath" -ForegroundColor Cyan
Write-Host "GitBook: https://app.gitbook.com/o/cyZpWhV7KomErB6BnmVk/s/hRoSpCiTUrfuH62swMvH/" -ForegroundColor Cyan
Write-Host ""
Write-Host "Press any key..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
