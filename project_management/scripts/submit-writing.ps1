# ============================================================================
# submit-writing.ps1
# PhD Writing Submission System for AI Review
# ============================================================================

param(
    [Parameter(Mandatory=$false)]
    [string]$Chapter = "",
    
    [Parameter(Mandatory=$false)]
    [string]$Section = "",
    
    [Parameter(Mandatory=$false)]
    [string]$FilePath = "",
    
    [Parameter(Mandatory=$false)]
    [switch]$Interactive = $true
)

# Repository base path
$RepoPath = "C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis"
$SubmissionsRoot = Join-Path $RepoPath "writing_submissions"

Write-Host "`n" -NoNewline
Write-Host "PhD Writing Submission System" -ForegroundColor Cyan
Write-Host ("=" * 60) -ForegroundColor Gray

# ============================================================================
# Interactive Mode
# ============================================================================

if ($Interactive -and [string]::IsNullOrWhiteSpace($Chapter)) {
    Write-Host "`nThis tool formats your writing for AI review and tracks submissions." -ForegroundColor Yellow
    Write-Host "It will create a structured submission file with context.`n" -ForegroundColor Yellow
    
    # Prompt for chapter
    Write-Host "Available Chapters:" -ForegroundColor Cyan
    Write-Host "  1. Chapter 1: Introduction" -ForegroundColor White
    Write-Host "  2. Chapter 2: Literature Review" -ForegroundColor White
    Write-Host "  3. Chapter 3: Theoretical Framework" -ForegroundColor White
    Write-Host "  4. Chapter 4: Evolutionary Psychology" -ForegroundColor White
    Write-Host "  5. Chapter 5: Historical Analysis" -ForegroundColor White
    Write-Host "  6. Chapter 6: Contemporary Patterns" -ForegroundColor White
    Write-Host "  7. Chapter 7: Case Studies" -ForegroundColor White
    Write-Host "  8. Chapter 8: Policy Analysis" -ForegroundColor White
    Write-Host "  9. Chapter 9: Conclusion" -ForegroundColor White
    Write-Host " 10. Chapter 10: Future Directions" -ForegroundColor White
    
    $chapterNum = Read-Host "`nEnter chapter number (1-10)"
    
    $chapterNames = @{
        "1" = "chapter_01_introduction"
        "2" = "chapter_02_literature_review"
        "3" = "chapter_03_theoretical_framework"
        "4" = "chapter_04_evolutionary_psychology"
        "5" = "chapter_05_historical_analysis"
        "6" = "chapter_06_contemporary_patterns"
        "7" = "chapter_07_case_studies"
        "8" = "chapter_08_policy_analysis"
        "9" = "chapter_09_conclusion"
        "10" = "chapter_10_future_directions"
    }
    
    $Chapter = $chapterNames[$chapterNum]
    
    if ([string]::IsNullOrWhiteSpace($Chapter)) {
        Write-Host "Invalid chapter number. Exiting." -ForegroundColor Red
        exit 1
    }
    
    # Prompt for section
    $Section = Read-Host "Enter section name (e.g., '2.1 Darwin's Framework', 'Introduction')"
    
    # Prompt for content input method
    Write-Host "`nHow would you like to provide your writing?" -ForegroundColor Cyan
    Write-Host "  1. Paste text directly (multi-line)" -ForegroundColor White
    Write-Host "  2. Provide file path to existing draft" -ForegroundColor White
    
    $inputMethod = Read-Host "Enter choice (1 or 2)"
    
    if ($inputMethod -eq "1") {
        Write-Host "`nPaste your writing below (press Ctrl+Z then Enter when done):" -ForegroundColor Yellow
        $content = @()
        while ($true) {
            $line = Read-Host
            if ($line -eq $null) { break }
            $content += $line
        }
        $writingContent = $content -join "`n"
    } elseif ($inputMethod -eq "2") {
        $FilePath = Read-Host "Enter file path"
        if (Test-Path $FilePath) {
            $writingContent = Get-Content $FilePath -Raw
        } else {
            Write-Host "File not found. Exiting." -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "Invalid choice. Exiting." -ForegroundColor Red
        exit 1
    }
    
    # Additional context
    $reviewFocus = Read-Host "`nWhat should AI focus on? (e.g., 'argument flow', 'citation integration', 'clarity')"
    $specificQuestions = Read-Host "Any specific questions? (optional, press Enter to skip)"
    
} else {
    # Non-interactive mode (parameters provided)
    if ([string]::IsNullOrWhiteSpace($FilePath)) {
        Write-Host "Error: FilePath required in non-interactive mode" -ForegroundColor Red
        exit 1
    }
    
    if (-not (Test-Path $FilePath)) {
        Write-Host "Error: File not found at $FilePath" -ForegroundColor Red
        exit 1
    }
    
    $writingContent = Get-Content $FilePath -Raw
    $reviewFocus = "General review"
    $specificQuestions = ""
}

# ============================================================================
# Calculate Statistics
# ============================================================================

$wordCount = ($writingContent -split '\s+' | Where-Object { $_ -ne "" }).Count
$paragraphCount = ($writingContent -split "`n`n" | Where-Object { $_ -ne "" }).Count
$charCount = $writingContent.Length

Write-Host "`n" -NoNewline
Write-Host "Analyzing submission..." -ForegroundColor Yellow
Write-Host "  Word Count: $wordCount" -ForegroundColor White
Write-Host "  Paragraphs: $paragraphCount" -ForegroundColor White
Write-Host "  Characters: $charCount" -ForegroundColor White

# ============================================================================
# Create Submission Structure
# ============================================================================

if (-not (Test-Path $SubmissionsRoot)) {
    New-Item -Path $SubmissionsRoot -ItemType Directory -Force | Out-Null
}

$chapterFolder = Join-Path $SubmissionsRoot $Chapter
if (-not (Test-Path $chapterFolder)) {
    New-Item -Path $chapterFolder -ItemType Directory -Force | Out-Null
}

$timestamp = Get-Date -Format "yyyy-MM-dd_HHmmss"
$submissionFile = Join-Path $chapterFolder "$timestamp`_$($Section -replace '[\\/:*?\"<>|]', '_').md"

# ============================================================================
# Generate Submission Document
# ============================================================================

$submissionContent = @"
# Writing Submission for AI Review

**Date:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")  
**Chapter:** $Chapter  
**Section:** $Section  
**Word Count:** $wordCount  
**Status:** Submitted for Review

---

## Review Instructions

**Focus Areas:**
$reviewFocus

**Specific Questions:**
$specificQuestions

**Review Checklist:**
- [ ] Argument coherence and logical flow
- [ ] Evidence and citation integration
- [ ] Clarity and academic tone
- [ ] Structure and organization
- [ ] Transition quality between ideas
- [ ] Thesis alignment

---

## Submission Context

### Related Sources
*(Sources processed that relate to this section)*

"@

# Try to detect relevant sources based on content keywords
$sourcesPath = Join-Path $RepoPath "notes\reading_notes\by_source"
if (Test-Path $sourcesPath) {
    $sourceFiles = Get-ChildItem -Path $sourcesPath -Filter "*_summary.md"
    
    # Simple keyword matching (can be enhanced)
    $keywords = @("hypergamy", "polygyny", "sex ratio", "mating", "evolutionary", "marriage")
    $relevantSources = @()
    
    foreach ($file in $sourceFiles) {
        $fileName = $file.BaseName -replace "_summary", ""
        foreach ($keyword in $keywords) {
            if ($writingContent -match $keyword) {
                $relevantSources += "- $fileName"
                break
            }
        }
    }
    
    if ($relevantSources.Count -gt 0) {
        $submissionContent += ($relevantSources | Select-Object -Unique) -join "`n"
    } else {
        $submissionContent += "- (Auto-detection found no matches - add manually if needed)"
    }
}

$submissionContent += @"


### Available Quotes
- See: quotes/by_source/ for relevant quotes from processed sources
- See: quotes/by_chapter/ for chapter-organized quotes (if available)

### Cross-References
- See: research_journal/idea_linking/ for source integration analysis

---

## Writing Content

$writingContent

---

## Review Notes

*(AI feedback will be added below)*

### Strengths


### Areas for Improvement


### Specific Suggestions


### Revision Priority
- [ ] High Priority Issues
- [ ] Medium Priority Issues
- [ ] Low Priority Polish

---

## Revision History

**Version 1 (Submitted):** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
- Initial submission

---

*Submission generated by submit-writing.ps1*
*Next steps: Share this file with AI for review, then incorporate feedback*
"@

# ============================================================================
# Save Submission
# ============================================================================

try {
    Set-Content -Path $submissionFile -Value $submissionContent -Encoding UTF8
    Write-Host "`n" -NoNewline
    Write-Host "Submission created successfully!" -ForegroundColor Green
    Write-Host "`nSubmission File:" -ForegroundColor Cyan
    Write-Host "  $submissionFile" -ForegroundColor White
    
    # Update submissions index
    $indexFile = Join-Path $SubmissionsRoot "submissions_index.md"
    $indexEntry = "- **$timestamp** - $Chapter - $Section ($wordCount words)`n"
    
    if (Test-Path $indexFile) {
        $existingContent = Get-Content $indexFile -Raw
        $updatedContent = $existingContent -replace "(## Submission History`r?`n)", "`$1$indexEntry"
        Set-Content -Path $indexFile -Value $updatedContent -Encoding UTF8
    } else {
        $newIndexContent = @"
# Writing Submissions Index

Track all writing submissions for AI review.

---

## Submission History
$indexEntry
---

## Usage

Each submission includes:
- Full text of writing
- Word count and statistics
- Review focus areas
- Context (related sources, quotes)
- Space for AI feedback
- Revision tracking

## Workflow

1. Submit writing with this script
2. Share submission file with AI for review
3. AI adds feedback to "Review Notes" section
4. Revise based on feedback
5. Update "Revision History" section
6. Re-submit if needed

---

*Managed by submit-writing.ps1*
"@
        Set-Content -Path $indexFile -Value $newIndexContent -Encoding UTF8
    }
    
    Write-Host "`nNext Steps:" -ForegroundColor Yellow
    Write-Host "  1. Open the submission file" -ForegroundColor White
    Write-Host "  2. Share with AI for review" -ForegroundColor White
    Write-Host "  3. AI will add feedback to 'Review Notes' section" -ForegroundColor White
    Write-Host "  4. Revise your writing based on feedback" -ForegroundColor White
    Write-Host "  5. Update 'Revision History' and re-submit if needed`n" -ForegroundColor White
    
} catch {
    Write-Host "`n" -NoNewline
    Write-Host "Error creating submission: $_" -ForegroundColor Red
    exit 1
}

Write-Host ("=" * 60) -ForegroundColor Gray
Write-Host "Submission process complete!`n" -ForegroundColor Green
