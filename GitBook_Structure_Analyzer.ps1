#Requires -Version 7.0

<#
.SYNOPSIS
    Analyzes GitBook repository structure and generates comprehensive report

.DESCRIPTION
    This script scans your GitBook repository and generates multiple views:
    1. Tree structure visualization
    2. File inventory with sizes
    3. SUMMARY.md analysis
    4. Recommendations for optimization

.PARAMETER RepoPath
    Path to your GitBook repository
    Default: Current directory

.PARAMETER OutputFile
    Path to save the analysis report
    Default: GitBook_Structure_Report.txt

.PARAMETER IncludeHidden
    Include hidden files/folders in analysis
    Default: False

.EXAMPLE
    .\GitBook_Structure_Analyzer.ps1
    Analyzes current directory

.EXAMPLE
    .\GitBook_Structure_Analyzer.ps1 -RepoPath "C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis" -OutputFile "structure.txt"
    Analyzes specific directory and saves to custom file

#>

param(
    [string]$RepoPath = (Get-Location).Path,
    [string]$OutputFile = "GitBook_Structure_Report.txt",
    [switch]$IncludeHidden = $false
)

$ErrorActionPreference = "Continue"

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

function Get-FolderSize {
    param([string]$Path)
    
    try {
        $size = (Get-ChildItem -Path $Path -Recurse -File -ErrorAction SilentlyContinue | 
                 Measure-Object -Property Length -Sum).Sum
        return $size
    }
    catch {
        return 0
    }
}

function Format-FileSize {
    param([long]$Bytes)
    
    if ($Bytes -ge 1GB) { return "{0:N2} GB" -f ($Bytes / 1GB) }
    elseif ($Bytes -ge 1MB) { return "{0:N2} MB" -f ($Bytes / 1MB) }
    elseif ($Bytes -ge 1KB) { return "{0:N2} KB" -f ($Bytes / 1KB) }
    else { return "$Bytes bytes" }
}

function Get-TreeStructure {
    param(
        [string]$Path,
        [string]$Prefix = "",
        [bool]$IsLast = $true,
        [int]$MaxDepth = 10,
        [int]$CurrentDepth = 0
    )
    
    if ($CurrentDepth -ge $MaxDepth) { return }
    
    $items = Get-ChildItem -Path $Path -ErrorAction SilentlyContinue
    
    if (-not $IncludeHidden) {
        $items = $items | Where-Object { -not $_.Name.StartsWith('.') }
    }
    
    # Exclude common non-essential folders
    $excludeFolders = @('node_modules', '.git', '_book', '.vscode', 'bin', 'obj')
    $items = $items | Where-Object { $_.Name -notin $excludeFolders }
    
    $items = $items | Sort-Object { $_.PSIsContainer }, Name
    
    $output = @()
    
    for ($i = 0; $i -lt $items.Count; $i++) {
        $item = $items[$i]
        $isLastItem = ($i -eq $items.Count - 1)
        
        $connector = if ($isLastItem) { "└── " } else { "├── " }
        $newPrefix = if ($isLastItem) { "    " } else { "│   " }
        
        if ($item.PSIsContainer) {
            $size = Get-FolderSize -Path $item.FullName
            $sizeStr = Format-FileSize -Bytes $size
            $output += "$Prefix$connector$($item.Name)/ [$sizeStr]"
            
            $subOutput = Get-TreeStructure -Path $item.FullName `
                                           -Prefix ($Prefix + $newPrefix) `
                                           -IsLast $isLastItem `
                                           -MaxDepth $MaxDepth `
                                           -CurrentDepth ($CurrentDepth + 1)
            $output += $subOutput
        }
        else {
            $sizeStr = Format-FileSize -Bytes $item.Length
            $extension = $item.Extension
            $output += "$Prefix$connector$($item.Name) [$sizeStr]"
        }
    }
    
    return $output
}

function Get-FileInventory {
    param([string]$Path)
    
    $files = Get-ChildItem -Path $Path -Recurse -File -ErrorAction SilentlyContinue
    
    if (-not $IncludeHidden) {
        $files = $files | Where-Object { -not $_.Name.StartsWith('.') }
    }
    
    # Exclude non-essential files
    $files = $files | Where-Object { 
        $_.DirectoryName -notlike '*node_modules*' -and
        $_.DirectoryName -notlike '*.git*' -and
        $_.DirectoryName -notlike '*_book*'
    }
    
    return $files
}

function Analyze-SummaryMd {
    param([string]$Path)
    
    $summaryPath = Join-Path $Path "SUMMARY.md"
    
    if (-not (Test-Path $summaryPath)) {
        return @{
            Exists = $false
            Message = "SUMMARY.md not found"
        }
    }
    
    $content = Get-Content -Path $summaryPath -Raw
    $lines = Get-Content -Path $summaryPath
    
    # Extract all markdown links
    $linkPattern = '\[([^\]]+)\]\(([^\)]+)\)'
    $links = [regex]::Matches($content, $linkPattern)
    
    $linkedFiles = @()
    $brokenLinks = @()
    
    foreach ($link in $links) {
        $linkText = $link.Groups[1].Value
        $linkPath = $link.Groups[2].Value
        
        # Skip external links
        if ($linkPath -match '^https?://') { continue }
        
        $fullPath = Join-Path $Path $linkPath
        
        if (Test-Path $fullPath) {
            $linkedFiles += $linkPath
        }
        else {
            $brokenLinks += @{
                Text = $linkText
                Path = $linkPath
            }
        }
    }
    
    return @{
        Exists = $true
        LineCount = $lines.Count
        LinkCount = $links.Count
        LinkedFiles = $linkedFiles
        BrokenLinks = $brokenLinks
    }
}

function Get-FilesByType {
    param([System.IO.FileInfo[]]$Files)
    
    $grouped = $Files | Group-Object Extension | Sort-Object Count -Descending
    
    return $grouped | ForEach-Object {
        $totalSize = ($_.Group | Measure-Object -Property Length -Sum).Sum
        @{
            Extension = if ($_.Name) { $_.Name } else { "(no extension)" }
            Count = $_.Count
            TotalSize = $totalSize
        }
    }
}

function Get-OrphanedFiles {
    param(
        [string]$Path,
        [string[]]$LinkedFiles
    )
    
    $allMarkdownFiles = Get-ChildItem -Path $Path -Recurse -Filter "*.md" -File -ErrorAction SilentlyContinue |
                        Where-Object { $_.Name -ne "README.md" -and $_.Name -ne "SUMMARY.md" }
    
    $orphaned = @()
    
    foreach ($file in $allMarkdownFiles) {
        $relativePath = $file.FullName.Replace("$Path\", "").Replace("\", "/")
        
        if ($relativePath -notin $LinkedFiles) {
            $orphaned += $relativePath
        }
    }
    
    return $orphaned
}

# ============================================================================
# MAIN ANALYSIS
# ============================================================================

function Main {
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "GitBook Structure Analyzer" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Repository: $RepoPath" -ForegroundColor White
    Write-Host "Output File: $OutputFile" -ForegroundColor White
    Write-Host ""
    
    if (-not (Test-Path $RepoPath)) {
        Write-Host "ERROR: Repository path not found: $RepoPath" -ForegroundColor Red
        return
    }
    
    $report = @()
    
    # Header
    $report += "=" * 80
    $report += "GITBOOK REPOSITORY STRUCTURE ANALYSIS"
    $report += "=" * 80
    $report += "Repository: $RepoPath"
    $report += "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    $report += "=" * 80
    $report += ""
    
    # Section 1: Tree Structure
    Write-Host "[1/6] Generating tree structure..." -ForegroundColor Yellow
    $report += ""
    $report += "=" * 80
    $report += "SECTION 1: DIRECTORY TREE STRUCTURE"
    $report += "=" * 80
    $report += ""
    $report += Get-TreeStructure -Path $RepoPath -MaxDepth 5
    $report += ""
    
    # Section 2: File Inventory
    Write-Host "[2/6] Analyzing file inventory..." -ForegroundColor Yellow
    $files = Get-FileInventory -Path $RepoPath
    $totalSize = ($files | Measure-Object -Property Length -Sum).Sum
    
    $report += ""
    $report += "=" * 80
    $report += "SECTION 2: FILE INVENTORY SUMMARY"
    $report += "=" * 80
    $report += ""
    $report += "Total Files: $($files.Count)"
    $report += "Total Size: $(Format-FileSize -Bytes $totalSize)"
    $report += ""
    
    # Section 3: Files by Type
    Write-Host "[3/6] Grouping files by type..." -ForegroundColor Yellow
    $filesByType = Get-FilesByType -Files $files
    
    $report += ""
    $report += "=" * 80
    $report += "SECTION 3: FILES BY TYPE"
    $report += "=" * 80
    $report += ""
    $report += "{0,-20} {1,10} {2,15}" -f "Extension", "Count", "Total Size"
    $report += "-" * 50
    
    foreach ($type in $filesByType) {
        $report += "{0,-20} {1,10} {2,15}" -f $type.Extension, $type.Count, (Format-FileSize -Bytes $type.TotalSize)
    }
    $report += ""
    
    # Section 4: SUMMARY.md Analysis
    Write-Host "[4/6] Analyzing SUMMARY.md..." -ForegroundColor Yellow
    $summaryAnalysis = Analyze-SummaryMd -Path $RepoPath
    
    $report += ""
    $report += "=" * 80
    $report += "SECTION 4: SUMMARY.MD ANALYSIS"
    $report += "=" * 80
    $report += ""
    
    if ($summaryAnalysis.Exists) {
        $report += "Status: ✓ Found"
        $report += "Lines: $($summaryAnalysis.LineCount)"
        $report += "Total Links: $($summaryAnalysis.LinkCount)"
        $report += "Valid File Links: $($summaryAnalysis.LinkedFiles.Count)"
        $report += ""
        
        if ($summaryAnalysis.BrokenLinks.Count -gt 0) {
            $report += "⚠ BROKEN LINKS FOUND: $($summaryAnalysis.BrokenLinks.Count)"
            $report += ""
            foreach ($broken in $summaryAnalysis.BrokenLinks) {
                $report += "  × [$($broken.Text)]($($broken.Path))"
            }
            $report += ""
        }
        else {
            $report += "✓ No broken links detected"
            $report += ""
        }
        
        # Linked Files List
        $report += "Linked Files in SUMMARY.md:"
        $report += "-" * 50
        foreach ($linked in $summaryAnalysis.LinkedFiles) {
            $report += "  • $linked"
        }
    }
    else {
        $report += "Status: ✗ Not Found"
        $report += "Message: $($summaryAnalysis.Message)"
        $report += ""
        $report += "⚠ RECOMMENDATION: Create SUMMARY.md for GitBook navigation"
    }
    $report += ""
    
    # Section 5: Orphaned Files
    Write-Host "[5/6] Detecting orphaned files..." -ForegroundColor Yellow
    
    if ($summaryAnalysis.Exists) {
        $orphanedFiles = Get-OrphanedFiles -Path $RepoPath -LinkedFiles $summaryAnalysis.LinkedFiles
        
        $report += ""
        $report += "=" * 80
        $report += "SECTION 5: ORPHANED FILES (Not in SUMMARY.md)"
        $report += "=" * 80
        $report += ""
        
        if ($orphanedFiles.Count -gt 0) {
            $report += "⚠ Found $($orphanedFiles.Count) orphaned Markdown files:"
            $report += ""
            foreach ($orphan in $orphanedFiles) {
                $report += "  • $orphan"
            }
        }
        else {
            $report += "✓ No orphaned files detected"
        }
        $report += ""
    }
    
    # Section 6: Recommendations
    Write-Host "[6/6] Generating recommendations..." -ForegroundColor Yellow
    $report += ""
    $report += "=" * 80
    $report += "SECTION 6: OPTIMIZATION RECOMMENDATIONS"
    $report += "=" * 80
    $report += ""
    
    $recommendations = @()
    
    # Check for large files
    $largeFiles = $files | Where-Object { $_.Length -gt 5MB } | Sort-Object Length -Descending
    if ($largeFiles.Count -gt 0) {
        $recommendations += "⚠ Large Files Detected ($($largeFiles.Count) files > 5MB):"
        foreach ($file in $largeFiles) {
            $relativePath = $file.FullName.Replace("$RepoPath\", "")
            $recommendations += "  • $relativePath [$(Format-FileSize -Bytes $file.Length)]"
        }
        $recommendations += ""
    }
    
    # Check for backup files
    $backupFiles = $files | Where-Object { $_.Name -match '\.(backup|bak|old|tmp)' }
    if ($backupFiles.Count -gt 0) {
        $recommendations += "⚠ Backup/Temporary Files Detected ($($backupFiles.Count) files):"
        foreach ($file in $backupFiles) {
            $relativePath = $file.FullName.Replace("$RepoPath\", "")
            $recommendations += "  • $relativePath"
        }
        $recommendations += "  → Consider cleaning up backup files or adding to .gitignore"
        $recommendations += ""
    }
    
    # Check for proper folder structure
    $hasChapters = Test-Path (Join-Path $RepoPath "chapters")
    $hasSources = Test-Path (Join-Path $RepoPath "sources")
    
    if (-not $hasChapters -and -not $hasSources) {
        $recommendations += "💡 Folder Structure Suggestion:"
        $recommendations += "  Consider organizing content into:"
        $recommendations += "  • chapters/ (main dissertation content)"
        $recommendations += "  • sources/ (reference materials)"
        $recommendations += "  • images/ or assets/ (media files)"
        $recommendations += ""
    }
    
    # Check if SUMMARY.md exists
    if (-not $summaryAnalysis.Exists) {
        $recommendations += "⚠ Missing SUMMARY.md:"
        $recommendations += "  GitBook requires SUMMARY.md for navigation structure"
        $recommendations += "  → Create SUMMARY.md with links to your content"
        $recommendations += ""
    }
    
    # Check for orphaned files
    if ($summaryAnalysis.Exists -and $orphanedFiles.Count -gt 0) {
        $recommendations += "⚠ Orphaned Files ($($orphanedFiles.Count) files not linked in SUMMARY.md):"
        $recommendations += "  These files exist but aren't accessible through GitBook navigation"
        $recommendations += "  → Add links to SUMMARY.md or remove unused files"
        $recommendations += ""
    }
    
    # Check for broken links
    if ($summaryAnalysis.Exists -and $summaryAnalysis.BrokenLinks.Count -gt 0) {
        $recommendations += "⚠ Broken Links in SUMMARY.md ($($summaryAnalysis.BrokenLinks.Count) broken links):"
        $recommendations += "  → Fix or remove broken links for proper GitBook navigation"
        $recommendations += ""
    }
    
    if ($recommendations.Count -eq 0) {
        $report += "✓ No major issues detected!"
        $report += "  Your GitBook structure looks well-organized."
    }
    else {
        $report += $recommendations
    }
    
    $report += ""
    $report += "=" * 80
    $report += "END OF REPORT"
    $report += "=" * 80
    
    # Save report
    $report | Out-File -FilePath $OutputFile -Encoding UTF8
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "ANALYSIS COMPLETE" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "Report saved to: $OutputFile" -ForegroundColor White
    Write-Host "Total files analyzed: $($files.Count)" -ForegroundColor White
    Write-Host "Total size: $(Format-FileSize -Bytes $totalSize)" -ForegroundColor White
    Write-Host ""
    Write-Host "You can now share this report with AI for optimization suggestions!" -ForegroundColor Cyan
    Write-Host ""
    
    # Open the report file
    $openFile = Read-Host "Open report file now? (Y/n)"
    if ($openFile -match '^[Yy]' -or [string]::IsNullOrWhiteSpace($openFile)) {
        Start-Process notepad $OutputFile
    }
}

# Run main function
Main
