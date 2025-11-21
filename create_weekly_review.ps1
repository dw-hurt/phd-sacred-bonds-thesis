# Create Weekly Review with Auto-Populated Data
# Run every Friday to start your weekly review

Write-Host "=== Creating Weekly Review ===" -ForegroundColor Cyan
Write-Host ""

# Get dates
$date = Get-Date -Format "yyyy-MM-dd"
$weekStart = (Get-Date).AddDays(-(Get-Date).DayOfWeek.value__).ToString("yyyy-MM-dd")
$weekEnd = (Get-Date).AddDays(6-(Get-Date).DayOfWeek.value__).ToString("yyyy-MM-dd")

# Create weekly_reviews folder if it doesn't exist
$reviewsFolder = "project_management/weekly_reviews"
if (-not (Test-Path $reviewsFolder)) {
    New-Item -ItemType Directory -Path $reviewsFolder | Out-Null
    Write-Host "Created weekly_reviews folder" -ForegroundColor Green
}

# Calculate word count stats
Write-Host "Calculating word count statistics..." -ForegroundColor Yellow

# Get current word count
$currentWords = 0
$chapterFiles = Get-ChildItem -Path "chapters" -Recurse -Filter "chapter_*.md" -ErrorAction SilentlyContinue
foreach ($file in $chapterFiles) {
    $words = (Get-Content $file.FullName | Measure-Object -Word).Words
    $currentWords += $words
}

$target = 87000
$percentage = [math]::Round(($currentWords / $target) * 100, 2)

# Try to get last week's word count (from last review)
$lastReviewFiles = Get-ChildItem -Path $reviewsFolder -Filter "weekly_review_*.md" -ErrorAction SilentlyContinue | Sort-Object Name -Descending
$startingWords = $currentWords

if ($lastReviewFiles -and $lastReviewFiles.Count -gt 0) {
    $lastReview = Get-Content $lastReviewFiles[0].FullName -Raw
    if ($lastReview -match "Ending count: (\d+) words") {
        $startingWords = [int]$matches[1]
    }
}

$wordChange = $currentWords - $startingWords

# Get sources processed this week
Write-Host "Checking processed sources..." -ForegroundColor Yellow
$recentCommits = git log --since="1 week ago" --pretty=format:"%s" 2>$null | Select-String -Pattern "Process|Add.*summary|Add.*quotes"

# Count commits this week
$weekCommits = (git log --since="1 week ago" --oneline 2>$null | Measure-Object -Line).Lines

# Build chapter breakdown
$chapterBreakdown = ""
if ($chapterFiles) {
    foreach ($file in $chapterFiles) {
        $chapterNum = $file.Name -replace '.*chapter_0?(\d+).*', '$1'
        $words = (Get-Content $file.FullName | Measure-Object -Word).Words
        $chapterBreakdown += "- Chapter $chapterNum : $words words`n"
    }
} else {
    $chapterBreakdown = "- No chapters found`n"
}

# Build sources processed section
$sourcesSection = ""
if ($recentCommits) {
    foreach ($commit in $recentCommits) {
        $sourcesSection += "- $($commit.Line)`n"
    }
} else {
    $sourcesSection = "- [Add processed sources here]`n"
}

# Create review file content
$reviewFile = "$reviewsFolder/weekly_review_$date.md"

# Build content line by line to avoid here-string issues
$content = "# Weekly Review - Week of $weekStart to $weekEnd`n`n"
$content += "## Accomplishments This Week`n`n"
$content += "### Writing Progress`n"
$content += "- Added $wordChange words this week`n"
$content += "- Total: $currentWords / $target words ($percentage% complete)`n"
$content += "- Git commits this week: $weekCommits`n`n"
$content += "### Completed Tasks`n"
$content += "- [Add your accomplishments here]`n"
$content += "- `n`n"
$content += "### Chapters Worked On`n"
$content += "- [Which chapters did you write/edit?]`n"
$content += "- `n`n"
$content += "### Sources Processed`n"
$content += $sourcesSection
$content += "`n---`n`n"
$content += "## Challenges Encountered`n`n"
$content += "### Technical Challenges`n"
$content += "- [What technical obstacles did you face?]`n"
$content += "- `n`n"
$content += "### Conceptual Challenges`n"
$content += "- [What theoretical or conceptual issues arose?]`n"
$content += "- `n`n"
$content += "### Time Management`n"
$content += "- [How was your productivity this week?]`n"
$content += "- `n`n"
$content += "### How You Addressed Them`n"
$content += "- [What solutions did you find?]`n"
$content += "- `n`n"
$content += "---`n`n"
$content += "## Word Count Progress`n`n"
$content += "- **Starting count:** $startingWords words`n"
$content += "- **Ending count:** $currentWords words`n"
$content += "- **Net change:** +$wordChange words`n"
$content += "- **Percentage complete:** $percentage%`n"
$chaptersWithContent = ($chapterFiles | Where-Object { (Get-Content $_.FullName | Measure-Object -Word).Words -gt 0 }).Count
$content += "- **Chapters with content:** $chaptersWithContent / 10`n`n"
$content += "### Chapter Breakdown`n"
$content += $chapterBreakdown
$content += "`n---`n`n"
$content += "## Sources Processed This Week`n`n"
$content += "### New Sources Added`n"
$content += "- [List sources you processed]`n"
$content += "- `n`n"
$content += "### Quotes Extracted`n"
$content += "- [Number of quotes extracted by source]`n"
$content += "- `n`n"
$content += "### Integration Notes Created`n"
$content += "- [Any integration notes written?]`n"
$content += "- `n`n"
$content += "---`n`n"
$content += "## Next Week's Priorities`n`n"
$content += "### Critical (Must Complete)`n"
$content += "1. [Top priority task]`n"
$content += "2. [Second critical task]`n"
$content += "3. [Third critical task]`n`n"
$content += "### High Priority (Should Complete)`n"
$content += "1. [High priority task]`n"
$content += "2. [Another high priority]`n`n"
$content += "### Medium Priority (Nice to Have)`n"
$content += "1. [Medium priority task]`n"
$content += "2. [Another medium task]`n`n"
$content += "---`n`n"
$content += "## Notes and Reflections`n`n"
$content += "### What Went Well`n"
$content += "[What worked well this week?]`n`n"
$content += "### What Could Improve`n"
$content += "[What would you like to do differently?]`n`n"
$content += "### Insights Gained`n"
$content += "[Any theoretical or methodological insights?]`n`n"
$content += "### Energy and Motivation`n"
$content += "[How are you feeling about the dissertation?]`n`n"
$content += "### Next Steps`n"
$content += "[Specific actions for Monday morning]`n`n"
$content += "---`n`n"
$content += "## Metrics Summary`n`n"
$content += "- **Word Count:** $currentWords / $target ($percentage%)`n"
$content += "- **Words This Week:** +$wordChange`n"
$content += "- **Sources Processed:** [X] / 32`n"
$content += "- **Chapters Active:** [X] / 10`n"
$content += "- **Git Commits:** $weekCommits`n"
$content += "- **Work Sessions:** [How many sessions did you work?]`n`n"
$content += "---`n`n"
$nextReview = (Get-Date).AddDays(7).ToString("yyyy-MM-dd")
$content += "**Review Completed:** $date`n"
$content += "**Next Review Due:** $nextReview`n"

# Write the file
$content | Out-File -FilePath $reviewFile -Encoding UTF8

Write-Host ""
Write-Host "Weekly review created: $reviewFile" -ForegroundColor Green
Write-Host ""
Write-Host "Auto-populated data:" -ForegroundColor Cyan
Write-Host "  - Week: $weekStart to $weekEnd" -ForegroundColor White
Write-Host "  - Starting words: $startingWords" -ForegroundColor White
Write-Host "  - Current words: $currentWords" -ForegroundColor White
Write-Host "  - Words added: +$wordChange" -ForegroundColor White
Write-Host "  - Progress: $percentage%" -ForegroundColor White
Write-Host "  - Commits this week: $weekCommits" -ForegroundColor White
Write-Host ""

# Add to git
git add $reviewFile

Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Run: git commit -m 'Create weekly review $date'" -ForegroundColor White
Write-Host "  2. Run: git push" -ForegroundColor White
Write-Host "  3. Wait 2-5 min for GitBook sync" -ForegroundColor White
Write-Host "  4. Open GitBook and complete your review there!" -ForegroundColor White
Write-Host ""
Write-Host "Or open locally now:" -ForegroundColor Yellow
Write-Host "  code $reviewFile" -ForegroundColor White
Write-Host ""
