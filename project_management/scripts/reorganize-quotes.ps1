<#
.SYNOPSIS
    Quote Reorganizer v1.1 - Universal Parser Edition
.DESCRIPTION
    Handles multiple quote formats: **Quote X:** and ### Quote X:
#>

param(
    [switch]$DryRun,
    [switch]$Verbose
)

$repoRoot = "C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis"

$colors = @{
    Header = "Cyan"; Success = "Green"; Warning = "Yellow"
    Error = "Red"; Info = "White"; Stat = "Magenta"
}

function Write-Header { param([string]$Text); Write-Host "`n=== $Text ===" -ForegroundColor $colors.Header }
function Write-Success { param([string]$Text); Write-Host "✓ $Text" -ForegroundColor $colors.Success }
function Write-Info { param([string]$Text); Write-Host "  $Text" -ForegroundColor $colors.Info }
function Write-Stat { param([string]$Text); Write-Host "  → $Text" -ForegroundColor $colors.Stat }

$chapterMap = @{
    "Chapter 1" = @{ Number = "01"; Title = "Introduction"; Keywords = @("research question", "motivation", "crisis", "contemporary", "bonding need", "mating imperative") }
    "Chapter 2" = @{ Number = "02"; Title = "Literature Review"; Keywords = @("darwin", "sexual selection", "literature", "theory", "evolution", "foundation", "bateman", "parental investment") }
    "Chapter 3" = @{ Number = "03"; Title = "Mating Strategies"; Keywords = @("strategy", "strategies", "mating", "courtship", "short-term", "long-term", "sexual behavior", "pluralism") }
    "Chapter 4" = @{ Number = "04"; Title = "Economic Dimensions"; Keywords = @("economic", "hypergamy", "income", "resources", "wealth", "status", "prosperity", "earnings", "salary", "bargaining") }
    "Chapter 5" = @{ Number = "05"; Title = "Psychological Dimensions"; Keywords = @("psychology", "psychological", "attachment", "emotion", "cognition", "consciousness", "adaptive", "mechanisms") }
    "Chapter 6" = @{ Number = "06"; Title = "Cultural Evolution"; Keywords = @("culture", "cultural", "social", "norms", "tradition", "modernity", "civilization", "civilized", "transmitted", "evoked") }
    "Chapter 7" = @{ Number = "07"; Title = "Sex Ratio Dynamics"; Keywords = @("sex ratio", "demographic", "population", "ratio", "synchronicity", "quantum", "entanglement", "acausal") }
    "Chapter 8" = @{ Number = "08"; Title = "Synthesis"; Keywords = @("synthesis", "integration", "framework", "model", "comprehensive") }
    "Chapter 9" = @{ Number = "09"; Title = "Implications"; Keywords = @("implications", "policy", "intervention", "recommendations") }
    "Chapter 10" = @{ Number = "10"; Title = "Conclusion"; Keywords = @("conclusion", "summary", "limitations", "future research") }
}

$themeMap = @{
    "Sexual Selection" = @{ Keywords = @("sexual selection", "mate choice", "intrasexual", "intersexual", "competition", "preference", "mate value") }
    "Hypergamy" = @{ Keywords = @("hypergamy", "marry up", "status seeking", "high status", "earnings potential", "rank") }
    "Polygyny" = @{ Keywords = @("polygyny", "polygamy", "polygynous", "multiple partners", "temporal polygyny", "monogamy") }
    "Demographic Crisis" = @{ Keywords = @("demographic", "fertility", "birth rate", "population decline", "childlessness", "collapse", "reproductive success") }
    "Mating Market" = @{ Keywords = @("mating market", "dating market", "mate value", "market dynamics", "bargaining power", "scarcity") }
    "Parental Investment" = @{ Keywords = @("parental investment", "offspring", "caregiving", "provisioning", "reproduction", "reproductive window", "fertility") }
    "Modernization Effects" = @{ Keywords = @("modernization", "modernity", "contemporary", "modern society", "prosperity", "egalitarian", "civilized") }
    "Economic Factors" = @{ Keywords = @("economic", "income", "wealth", "resources", "employment", "career", "salary", "earnings capacity") }
    "Psychological Mechanisms" = @{ Keywords = @("psychological", "cognitive", "emotional", "perception", "motivation", "mindset", "evolved mechanisms", "adaptations") }
    "Cultural Influences" = @{ Keywords = @("cultural", "culture", "social norms", "tradition", "values", "transmitted culture", "evoked culture") }
}

function Get-QuoteFiles {
    Write-Header "Scanning Quote Files"
    $quotePath = Join-Path $repoRoot "quotes\by_source"
    if (-not (Test-Path $quotePath)) {
        Write-Host "Error: quotes/by_source/ directory not found!" -ForegroundColor $colors.Error
        return @()
    }
    $quoteFiles = Get-ChildItem -Path $quotePath -Filter "*_quotes.md" -File
    Write-Info "Found $($quoteFiles.Count) quote files"
    return $quoteFiles
}

function Parse-QuoteFile {
    param([System.IO.FileInfo]$File)
    
    if ($Verbose) { Write-Info "Parsing: $($File.Name)" }
    
    $content = Get-Content -Path $File.FullName -Raw -Encoding UTF8
    $quotes = @()
    
    # UNIVERSAL PATTERN: Split by both **Quote X: and ### Quote X:
    $quoteBlocks = $content -split '(?m)^(?:\*\*Quote \d+:|###\s*Quote \d+:)'
    
    foreach ($block in $quoteBlocks) {
        if ([string]::IsNullOrWhiteSpace($block)) { continue }
        
        # Extract quote title (first line after split)
        $quoteTitle = ""
        $lines = $block -split "`n"
        if ($lines.Count -gt 0) {
            $firstLine = $lines[0].Trim()
            # Remove trailing ** if present
            $quoteTitle = $firstLine -replace '\*\*$', ''
        }
        
        # Extract quote text (between > " and ")
        if ($block -match '(?s)>\s*"(.+?)"') {
            $quoteText = $matches[1].Trim()
            
            # Extract page number
            $pageNumber = "See source"
            if ($block -match '\*\*Page:\*\*\s*(.+?)(?:\r?\n|$)') {
                $pageNumber = $matches[1].Trim()
            } elseif ($block -match 'Page:\s*(.+?)(?:\r?\n|$)') {
                $pageNumber = $matches[1].Trim()
            }
            
            # Extract chapter assignment from structure
            $assignedChapters = @()
            
            # Method 1: From section headers (## CHAPTER X or ### Chapter X)
            if ($block -match '##\s*CHAPTER\s*(\d+):|###\s*Chapter\s*(\d+):') {
                $chapterNum = if ($matches[1]) { $matches[1] } else { $matches[2] }
                $assignedChapters += "Chapter $chapterNum"
            }
            
            # Method 2: Look in Integration Notes for Chapter mentions
            if ($block -match 'Integration Notes:') {
                $integrationSection = ($block -split 'Integration Notes:')[1]
                if ($integrationSection -match 'Chapter (\d+)') {
                    $chapterNum = $matches[1]
                    if ($assignedChapters -notcontains "Chapter $chapterNum") {
                        $assignedChapters += "Chapter $chapterNum"
                    }
                }
            }
            
            # Extract context from Integration Notes
            $contextLines = @()
            if ($block -match '(?s)\*\*Integration Notes:\*\*(.+?)(?=\*\*[A-Z]|\r?\n\r?\n---|$)') {
                $integrationText = $matches[1]
                $integrationText -split "`n" | ForEach-Object {
                    $line = $_.Trim()
                    if ($line -match '^-\s*\*\*(.+?)\*\*:\s*(.+)$') {
                        $contextLines += "$($matches[1]): $($matches[2])"
                    } elseif ($line -match '^-\s*(.+)$') {
                        $contextLines += $matches[1]
                    }
                }
            }
            
            # Also extract Significance if present
            if ($block -match '\*\*Significance\*\*:\s*(.+?)(?=\r?\n-|\r?\n\*\*|\r?\n\r?\n|$)') {
                $contextLines += "Significance: $($matches[1].Trim())"
            }
            
            $context = ($contextLines | Select-Object -First 3) -join " | "
            
            $quotes += [PSCustomObject]@{
                Text = $quoteText
                Title = $quoteTitle
                Page = $pageNumber
                Source = $File.BaseName -replace '_quotes$', ''
                AssignedChapters = $assignedChapters
                Context = $context
            }
        }
    }
    
    return $quotes
}

function Classify-QuoteByChapter {
    param([PSCustomObject]$Quote)
    $matchedChapters = @()
    
    if ($Quote.AssignedChapters.Count -gt 0) {
        $matchedChapters = $Quote.AssignedChapters
    }
    
    if ($matchedChapters.Count -eq 0) {
        $combinedText = "$($Quote.Text) $($Quote.Title) $($Quote.Context)".ToLower()
        foreach ($chapter in $chapterMap.Keys) {
            foreach ($keyword in $chapterMap[$chapter].Keywords) {
                if ($combinedText -like "*$keyword*") {
                    $matchedChapters += $chapter
                    break
                }
            }
        }
    }
    
    if ($matchedChapters.Count -eq 0) { $matchedChapters += "Chapter 2" }
    return $matchedChapters | Select-Object -Unique
}

function Classify-QuoteByTheme {
    param([PSCustomObject]$Quote)
    $matchedThemes = @()
    $combinedText = "$($Quote.Text) $($Quote.Title) $($Quote.Context)".ToLower()
    
    foreach ($theme in $themeMap.Keys) {
        foreach ($keyword in $themeMap[$theme].Keywords) {
            if ($combinedText -like "*$keyword*") {
                $matchedThemes += $theme
                break
            }
        }
    }
    return $matchedThemes | Select-Object -Unique
}

function Format-QuoteForOutput {
    param([PSCustomObject]$Quote, [int]$QuoteNumber)
    
    $output = "`n## Quote $QuoteNumber : $($Quote.Title)`n`n"
    $output += "> `"$($Quote.Text)`"`n> `n> — $($Quote.Source) (p. $($Quote.Page))`n`n"
    $output += "**Context:** $($Quote.Context)`n`n"
    $output += "**Source File:** quotes/by_source/$($Quote.Source)_quotes.md`n`n---`n`n"
    return $output
}

function Create-ChapterQuoteFiles {
    param([array]$AllQuotes)
    Write-Header "Organizing Quotes by Chapter"
    $chapterDir = Join-Path $repoRoot "quotes\by_chapter"
    if (-not (Test-Path $chapterDir)) {
        New-Item -Path $chapterDir -ItemType Directory -Force | Out-Null
        Write-Info "Created directory: quotes/by_chapter/"
    }
    
    $stats = @{}
    foreach ($chapterName in $chapterMap.Keys) {
        $chapterNum = $chapterMap[$chapterName].Number
        $chapterTitle = $chapterMap[$chapterName].Title
        
        $chapterQuotes = $AllQuotes | Where-Object {
            $quote = $_; $chapters = Classify-QuoteByChapter -Quote $quote
            $chapters -contains $chapterName
        }
        
        if ($chapterQuotes.Count -eq 0) {
            if ($Verbose) { Write-Info "Chapter $chapterNum ($chapterTitle): No quotes" }
            continue
        }
        
        $fileName = "chapter_${chapterNum}_${chapterTitle}.md" -replace ' ', '_'
        $filePath = Join-Path $chapterDir $fileName
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        
        $content = "# Chapter $chapterNum : $chapterTitle`n## Relevant Quotes`n`n"
        $content += "**Total Quotes:** $($chapterQuotes.Count)`n**Last Updated:** $timestamp`n`n"
        $content += "This file contains all quotes relevant to Chapter $chapterNum from processed sources.`n`n---`n`n"
        
        $quoteNumber = 1
        foreach ($quote in $chapterQuotes) {
            $content += Format-QuoteForOutput -Quote $quote -QuoteNumber $quoteNumber
            $quoteNumber++
        }
        
        $content += "---`n`n## Sources Represented`n`n"
        $sources = $chapterQuotes | Group-Object Source | Sort-Object Count -Descending
        foreach ($source in $sources) {
            $content += "- **$($source.Name):** $($source.Count) quotes`n"
        }
        
        if (-not $DryRun) {
            $content | Out-File -FilePath $filePath -Encoding UTF8 -Force
            Write-Success "Chapter $chapterNum : $($chapterQuotes.Count) quotes → $fileName"
        } else {
            Write-Info "[DRY RUN] Would create: $fileName ($($chapterQuotes.Count) quotes)"
        }
        
        $stats[$chapterName] = $chapterQuotes.Count
    }
    return $stats
}

function Create-ThemeQuoteFiles {
    param([array]$AllQuotes)
    Write-Header "Organizing Quotes by Theme"
    $themeDir = Join-Path $repoRoot "quotes\by_theme"
    if (-not (Test-Path $themeDir)) {
        New-Item -Path $themeDir -ItemType Directory -Force | Out-Null
        Write-Info "Created directory: quotes/by_theme/"
    }
    
    $stats = @{}
    foreach ($themeName in $themeMap.Keys) {
        $themeQuotes = $AllQuotes | Where-Object {
            $quote = $_; $themes = Classify-QuoteByTheme -Quote $quote
            $themes -contains $themeName
        }
        
        if ($themeQuotes.Count -eq 0) {
            if ($Verbose) { Write-Info "Theme '$themeName': No quotes" }
            continue
        }
        
        $fileName = "$($themeName -replace ' ', '_').md"
        $filePath = Join-Path $themeDir $fileName
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        
        $content = "# Theme: $themeName`n## Cross-Chapter Quotes`n`n"
        $content += "**Total Quotes:** $($themeQuotes.Count)`n**Last Updated:** $timestamp`n`n"
        $content += "This file contains all quotes related to the theme `"$themeName`" from processed sources.`n`n---`n`n"
        
        $quoteNumber = 1
        foreach ($quote in $themeQuotes) {
            $content += Format-QuoteForOutput -Quote $quote -QuoteNumber $quoteNumber
            $quoteNumber++
        }
        
        $content += "---`n`n## Sources Represented`n`n"
        $sources = $themeQuotes | Group-Object Source | Sort-Object Count -Descending
        foreach ($source in $sources) {
            $content += "- **$($source.Name):** $($source.Count) quotes`n"
        }
        
        $content += "`n## Chapter Distribution`n`n"
        $chapterDist = @{}
        foreach ($quote in $themeQuotes) {
            $chapters = Classify-QuoteByChapter -Quote $quote
            foreach ($chapter in $chapters) {
                if (-not $chapterDist.ContainsKey($chapter)) { $chapterDist[$chapter] = 0 }
                $chapterDist[$chapter]++
            }
        }
        foreach ($chapter in ($chapterDist.Keys | Sort-Object)) {
            $content += "- **${chapter}:** $($chapterDist[$chapter]) quotes`n"
        }
        
        if (-not $DryRun) {
            $content | Out-File -FilePath $filePath -Encoding UTF8 -Force
            Write-Success "$themeName : $($themeQuotes.Count) quotes → $fileName"
        } else {
            Write-Info "[DRY RUN] Would create: $fileName ($($themeQuotes.Count) quotes)"
        }
        
        $stats[$themeName] = $themeQuotes.Count
    }
    return $stats
}

function Create-MasterIndex {
    param([hashtable]$ChapterStats, [hashtable]$ThemeStats, [int]$TotalQuotes)
    Write-Header "Creating Master Quote Index"
    $indexPath = Join-Path $repoRoot "quotes\QUOTE_INDEX.md"
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    
    $content = "# Master Quote Index`n`n**Total Quotes:** $TotalQuotes`n"
    $content += "**Last Updated:** $timestamp`n**Auto-generated by:** reorganize-quotes.ps1`n`n"
    $content += "This index provides an overview of all quotes organized by chapter and theme.`n`n---`n`n"
    $content += "## Quick Navigation`n`n### By Chapter`n"
    
    foreach ($chapterName in ($ChapterStats.Keys | Sort-Object)) {
        $chapterNum = $chapterMap[$chapterName].Number
        $chapterTitle = $chapterMap[$chapterName].Title
        $count = $ChapterStats[$chapterName]
        $fileName = "chapter_${chapterNum}_${chapterTitle}.md" -replace ' ', '_'
        $content += "- [Chapter $chapterNum : $chapterTitle](by_chapter/$fileName) — $count quotes`n"
    }
    
    $content += "`n### By Theme`n`n"
    foreach ($themeName in ($ThemeStats.Keys | Sort-Object)) {
        $count = $ThemeStats[$themeName]
        $fileName = "$($themeName -replace ' ', '_').md"
        $content += "- [$themeName](by_theme/$fileName) — $count quotes`n"
    }
    
    $content += "`n---`n`n## Statistics`n`n### Chapter Coverage`n"
    foreach ($chapterName in ($ChapterStats.Keys | Sort-Object)) {
        $count = $ChapterStats[$chapterName]
        $percentage = [math]::Round(($count / $TotalQuotes) * 100, 1)
        $bar = "█" * [math]::Floor($percentage / 5)
        $content += "- **${chapterName}:** $count quotes ($percentage%) $bar`n"
    }
    
    $content += "`n### Theme Coverage`n`n"
    foreach ($themeName in ($ThemeStats.Keys | Sort-Object)) {
        $count = $ThemeStats[$themeName]
        $percentage = [math]::Round(($count / $TotalQuotes) * 100, 1)
        $bar = "█" * [math]::Floor($percentage / 5)
        $content += "- **${themeName}:** $count quotes ($percentage%) $bar`n"
    }
    
    $content += "`n---`n`n## Usage`n`n### For Writing`n"
    $content += "1. Navigate to the chapter you're drafting`n2. Review relevant quotes from the chapter file`n"
    $content += "3. Cross-reference with theme files for additional perspectives`n`n### For Analysis`n"
    $content += "1. Use theme files to track cross-cutting concepts`n2. Compare quote distribution across chapters`n"
    $content += "3. Identify gaps in source coverage`n`n---`n`n*This index is auto-generated. Re-run reorganize-quotes.ps1 to update.*`n"
    
    if (-not $DryRun) {
        $content | Out-File -FilePath $indexPath -Encoding UTF8 -Force
        Write-Success "Master index created → quotes/QUOTE_INDEX.md"
    } else {
        Write-Info "[DRY RUN] Would create: QUOTE_INDEX.md"
    }
}

Clear-Host
Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║       QUOTE REORGANIZER v1.1 - UNIVERSAL PARSER          ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

if ($DryRun) { Write-Host "🔍 DRY RUN MODE - No files will be written`n" -ForegroundColor Yellow }

$quoteFiles = Get-QuoteFiles
if ($quoteFiles.Count -eq 0) { exit }

Write-Header "Parsing Quotes"
$allQuotes = @()
foreach ($file in $quoteFiles) {
    $quotes = Parse-QuoteFile -File $file
    $allQuotes += $quotes
    Write-Info "$($file.Name): $($quotes.Count) quotes"
}
Write-Stat "Total quotes parsed: $($allQuotes.Count)"

$chapterStats = Create-ChapterQuoteFiles -AllQuotes $allQuotes
$themeStats = Create-ThemeQuoteFiles -AllQuotes $allQuotes
Create-MasterIndex -ChapterStats $chapterStats -ThemeStats $themeStats -TotalQuotes $allQuotes.Count

Write-Header "REORGANIZATION COMPLETE"
Write-Host "`n📊 Summary:" -ForegroundColor White
Write-Stat "Total quotes processed: $($allQuotes.Count)"
Write-Stat "Chapter files created: $($chapterStats.Count)"
Write-Stat "Theme files created: $($themeStats.Count)"
Write-Stat "Source files scanned: $($quoteFiles.Count)"

if (-not $DryRun) {
    Write-Host "`n✓ Files written to:" -ForegroundColor Green
    Write-Info "  - quotes/by_chapter/ ($($chapterStats.Count) files)"
    Write-Info "  - quotes/by_theme/ ($($themeStats.Count) files)"
    Write-Info "  - quotes/QUOTE_INDEX.md (master index)"
    Write-Host "`n📖 View master index:" -ForegroundColor Cyan
    Write-Info "  cat quotes\QUOTE_INDEX.md"
} else {
    Write-Host "`n🔍 Dry run complete - no files were written" -ForegroundColor Yellow
    Write-Host "Run without -DryRun to create files`n" -ForegroundColor White
}
Write-Host ""
