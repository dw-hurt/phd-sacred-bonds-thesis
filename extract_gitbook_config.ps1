# GitBook Configuration & Structure Extractor
# Comprehensive analysis for workflow optimization

$RepoPath = "C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis"
$OutputFile = "GitBook_Complete_Analysis.txt"

$Report = @()
$Report += "=" * 100
$Report += "GITBOOK CONFIGURATION & CONTENT STRUCTURE ANALYSIS"
$Report += "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
$Report += "=" * 100
$Report += ""

# Section 1: GitBook Configuration Files
$Report += "=" * 100
$Report += "SECTION 1: GITBOOK CONFIGURATION FILES"
$Report += "=" * 100
$Report += ""

# Check for .gitbook.yaml
$gitbookYaml = Join-Path $RepoPath ".gitbook.yaml"
if (Test-Path $gitbookYaml) {
    $Report += "--- .gitbook.yaml ---"
    $Report += Get-Content $gitbookYaml
    $Report += ""
} else {
    $Report += ".gitbook.yaml: NOT FOUND"
    $Report += ""
}

# Check for book.json
$bookJson = Join-Path $RepoPath "book.json"
if (Test-Path $bookJson) {
    $Report += "--- book.json ---"
    $Report += Get-Content $bookJson
    $Report += ""
} else {
    $Report += "book.json: NOT FOUND"
    $Report += ""
}

# Check for .gitbook directory
$gitbookDir = Join-Path $RepoPath ".gitbook"
if (Test-Path $gitbookDir) {
    $Report += "--- .gitbook/ Directory Contents ---"
    Get-ChildItem $gitbookDir -Recurse -File | ForEach-Object {
        $Report += "File: $($_.FullName.Replace($RepoPath, '.'))"
        $Report += "Size: $($_.Length) bytes"
        $Report += ""
    }
} else {
    $Report += ".gitbook/ directory: NOT FOUND"
    $Report += ""
}

# Section 2: SUMMARY.md Structure Analysis
$Report += "=" * 100
$Report += "SECTION 2: SUMMARY.MD STRUCTURE (TABLE OF CONTENTS)"
$Report += "=" * 100
$Report += ""

$summaryFile = Join-Path $RepoPath "SUMMARY.md"
if (Test-Path $summaryFile) {
    $summaryContent = Get-Content $summaryFile
    $Report += "Total Lines: $($summaryContent.Count)"
    $Report += ""
    $Report += "--- Full SUMMARY.md Content ---"
    $Report += $summaryContent
    $Report += ""
    
    # Analyze structure depth
    $Report += "--- Structure Analysis ---"
    $level1 = ($summaryContent | Where-Object { $_ -match '^\* ' }).Count
    $level2 = ($summaryContent | Where-Object { $_ -match '^\s{2}\* ' }).Count
    $level3 = ($summaryContent | Where-Object { $_ -match '^\s{4}\* ' }).Count
    $level4 = ($summaryContent | Where-Object { $_ -match '^\s{6}\* ' }).Count
    
    $Report += "Level 1 items (chapters): $level1"
    $Report += "Level 2 items (sections): $level2"
    $Report += "Level 3 items (subsections): $level3"
    $Report += "Level 4 items (sub-subsections): $level4"
    $Report += ""
} else {
    $Report += "SUMMARY.md: NOT FOUND"
    $Report += ""
}

# Section 3: Directory Structure & File Organization
$Report += "=" * 100
$Report += "SECTION 3: DIRECTORY STRUCTURE & FILE ORGANIZATION"
$Report += "=" * 100
$Report += ""

Push-Location $RepoPath

# Get all directories
$Report += "--- Top-Level Directories ---"
Get-ChildItem -Directory | ForEach-Object {
    $fileCount = (Get-ChildItem $_.FullName -File -Recurse).Count
    $Report += "$($_.Name)/ - $fileCount files"
}
$Report += ""

# Get file counts by type
$Report += "--- File Type Distribution ---"
$mdFiles = (Get-ChildItem -Recurse -Filter "*.md").Count
$htmlFiles = (Get-ChildItem -Recurse -Filter "*.html").Count
$jsFiles = (Get-ChildItem -Recurse -Filter "*.js").Count
$cssFiles = (Get-ChildItem -Recurse -Filter "*.css").Count
$imageFiles = (Get-ChildItem -Recurse -Include "*.png","*.jpg","*.jpeg","*.gif","*.svg").Count
$pdfFiles = (Get-ChildItem -Recurse -Filter "*.pdf").Count
$psFiles = (Get-ChildItem -Recurse -Filter "*.ps1").Count
$bibFiles = (Get-ChildItem -Recurse -Filter "*.bib").Count

$Report += "Markdown files (.md): $mdFiles"
$Report += "HTML files: $htmlFiles"
$Report += "JavaScript files: $jsFiles"
$Report += "CSS files: $cssFiles"
$Report += "Image files: $imageFiles"
$Report += "PDF files: $pdfFiles"
$Report += "PowerShell scripts: $psFiles"
$Report += "Bibliography files (.bib): $bibFiles"
$Report += ""

Pop-Location

# Section 4: Chapter Files Analysis
$Report += "=" * 100
$Report += "SECTION 4: CHAPTER FILES ANALYSIS"
$Report += "=" * 100
$Report += ""

Push-Location $RepoPath

# Find all chapter files
$chapterFiles = Get-ChildItem -Recurse -Filter "*.md" | Where-Object { 
    $_.Name -match 'chapter|ch\d+' -or $_.DirectoryName -match 'chapters?'
}

if ($chapterFiles) {
    $Report += "Found $($chapterFiles.Count) chapter files:"
    $Report += ""
    
    foreach ($chapter in $chapterFiles | Sort-Object FullName) {
        $relativePath = $chapter.FullName.Replace($RepoPath, '.').Replace('\', '/')
        $content = Get-Content $chapter.FullName -Raw
        $wordCount = ($content -split '\s+').Count
        $lineCount = (Get-Content $chapter.FullName).Count
        
        $Report += "File: $relativePath"
        $Report += "  Size: $($chapter.Length) bytes"
        $Report += "  Lines: $lineCount"
        $Report += "  Word Count: ~$wordCount"
        
        # Extract first heading if exists
        $firstHeading = (Get-Content $chapter.FullName | Where-Object { $_ -match '^#+ ' } | Select-Object -First 1)
        if ($firstHeading) {
            $Report += "  Title: $firstHeading"
        }
        $Report += ""
    }
} else {
    $Report += "No chapter files found matching common patterns"
    $Report += ""
}

Pop-Location

# Section 5: README.md Analysis
$Report += "=" * 100
$Report += "SECTION 5: README.MD (LANDING PAGE)"
$Report += "=" * 100
$Report += ""

$readmeFile = Join-Path $RepoPath "README.md"
if (Test-Path $readmeFile) {
    $readmeContent = Get-Content $readmeFile
    $Report += "Total Lines: $($readmeContent.Count)"
    $Report += ""
    $Report += "--- Full README.md Content ---"
    $Report += $readmeContent
    $Report += ""
} else {
    $Report += "README.md: NOT FOUND"
    $Report += ""
}

# Section 6: Sources & References Organization
$Report += "=" * 100
$Report += "SECTION 6: SOURCES & REFERENCES ORGANIZATION"
$Report += "=" * 100
$Report += ""

Push-Location $RepoPath

$sourcesDir = "sources"
if (Test-Path $sourcesDir) {
    $Report += "--- sources/ Directory Structure ---"
    Get-ChildItem $sourcesDir -Recurse | ForEach-Object {
        $relativePath = $_.FullName.Replace($RepoPath, '.').Replace('\', '/')
        if ($_.PSIsContainer) {
            $fileCount = (Get-ChildItem $_.FullName -File).Count
            $Report += "$relativePath/ - $fileCount files"
        } else {
            $Report += "$relativePath ($($_.Length) bytes)"
        }
    }
    $Report += ""
} else {
    $Report += "sources/ directory: NOT FOUND"
    $Report += ""
}

# Check for bibliography files
$Report += "--- Bibliography Files ---"
$bibFiles = Get-ChildItem -Recurse -Filter "*.bib"
if ($bibFiles) {
    foreach ($bib in $bibFiles) {
        $relativePath = $bib.FullName.Replace($RepoPath, '.').Replace('\', '/')
        $Report += "$relativePath ($($bib.Length) bytes)"
    }
} else {
    $Report += "No .bib files found"
}
$Report += ""

Pop-Location

# Section 7: Orphaned Files (Not in SUMMARY.md)
$Report += "=" * 100
$Report += "SECTION 7: ORPHANED FILES (NOT LINKED IN SUMMARY.MD)"
$Report += "=" * 100
$Report += ""

Push-Location $RepoPath

if (Test-Path $summaryFile) {
    $summaryContent = Get-Content $summaryFile -Raw
    
    # Extract all linked files from SUMMARY.md
    $linkedFiles = @()
    if ($summaryContent -match '\(([^)]+\.md)\)') {
        $linkedFiles = [regex]::Matches($summaryContent, '\(([^)]+\.md)\)') | ForEach-Object { $_.Groups[1].Value }
    }
    
    # Get all markdown files
    $allMdFiles = Get-ChildItem -Recurse -Filter "*.md" | Where-Object { 
        $_.Name -ne "SUMMARY.md" -and $_.Name -ne "README.md" 
    }
    
    $orphanedFiles = @()
    foreach ($file in $allMdFiles) {
        $relativePath = $file.FullName.Replace($RepoPath + '\', '').Replace('\', '/')
        $isLinked = $false
        
        foreach ($link in $linkedFiles) {
            if ($link -eq $relativePath -or $link -eq "./$relativePath" -or $relativePath -like "*$link") {
                $isLinked = $true
                break
            }
        }
        
        if (-not $isLinked) {
            $orphanedFiles += $relativePath
        }
    }
    
    $Report += "Total orphaned files: $($orphanedFiles.Count)"
    $Report += ""
    
    if ($orphanedFiles.Count -gt 0) {
        $Report += "Orphaned files list:"
        foreach ($orphan in $orphanedFiles | Sort-Object) {
            $Report += "  - $orphan"
        }
    }
    $Report += ""
}

Pop-Location

# Section 8: Git Configuration
$Report += "=" * 100
$Report += "SECTION 8: GIT CONFIGURATION"
$Report += "=" * 100
$Report += ""

Push-Location $RepoPath

try {
    $Report += "--- Git Remotes ---"
    $remotes = git remote -v 2>$null
    if ($remotes) {
        $Report += $remotes
    } else {
        $Report += "No git remotes configured"
    }
    $Report += ""
    
    $Report += "--- Git Branch ---"
    $branch = git branch --show-current 2>$null
    $Report += "Current branch: $branch"
    $Report += ""
    
    $Report += "--- Recent Commits (Last 10) ---"
    $commits = git log --oneline -10 2>$null
    if ($commits) {
        $Report += $commits
    }
    $Report += ""
} catch {
    $Report += "Error accessing git information: $_"
    $Report += ""
}

Pop-Location

# Section 9: Metadata & Front Matter Analysis
$Report += "=" * 100
$Report += "SECTION 9: METADATA & FRONT MATTER ANALYSIS"
$Report += "=" * 100
$Report += ""

Push-Location $RepoPath

$filesWithFrontMatter = @()
$filesWithoutFrontMatter = @()

Get-ChildItem -Recurse -Filter "*.md" | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    if ($content -match '^---\s*\n') {
        $filesWithFrontMatter += $_.FullName.Replace($RepoPath, '.').Replace('\', '/')
    } else {
        $filesWithoutFrontMatter += $_.FullName.Replace($RepoPath, '.').Replace('\', '/')
    }
}

$Report += "Files with front matter (YAML): $($filesWithFrontMatter.Count)"
$Report += "Files without front matter: $($filesWithoutFrontMatter.Count)"
$Report += ""

if ($filesWithFrontMatter.Count -gt 0 -and $filesWithFrontMatter.Count -le 20) {
    $Report += "Files with front matter:"
    foreach ($file in $filesWithFrontMatter | Sort-Object) {
        $Report += "  - $file"
    }
    $Report += ""
}

Pop-Location

# Save report
$Report | Out-File $OutputFile -Encoding UTF8

Write-Host "=" * 80 -ForegroundColor Cyan
Write-Host "GitBook Configuration & Structure Analysis Complete!" -ForegroundColor Green
Write-Host "=" * 80 -ForegroundColor Cyan
Write-Host ""
Write-Host "Report saved to: $OutputFile" -ForegroundColor Yellow
Write-Host "File size: $((Get-Item $OutputFile).Length) bytes" -ForegroundColor Gray
Write-Host ""
Write-Host "This report contains:" -ForegroundColor Cyan
Write-Host "  1. GitBook configuration files" -ForegroundColor White
Write-Host "  2. SUMMARY.md structure analysis" -ForegroundColor White
Write-Host "  3. Directory & file organization" -ForegroundColor White
Write-Host "  4. Chapter files analysis with word counts" -ForegroundColor White
Write-Host "  5. README.md content" -ForegroundColor White
Write-Host "  6. Sources & references organization" -ForegroundColor White
Write-Host "  7. Orphaned files list" -ForegroundColor White
Write-Host "  8. Git configuration" -ForegroundColor White
Write-Host "  9. Metadata & front matter analysis" -ForegroundColor White
Write-Host ""
