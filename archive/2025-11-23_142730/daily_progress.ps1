# Daily Progress Tracker

$chapters = Get-ChildItem chapters -Recurse -Filter chapter_*.md

Write-Host "`n📊 DISSERTATION PROGRESS`n" -ForegroundColor Cyan

$totalWords = 0
foreach ($chapter in $chapters) {
    $content = Get-Content $chapter.FullName -Raw
    $words = ($content -split '\s+').Count
    $totalWords += $words
    
    $chapterName = $chapter.Directory.Name
    Write-Host "$chapterName`: $words words" -ForegroundColor Green
}

Write-Host "`nTotal Words: $totalWords" -ForegroundColor Yellow
Write-Host "Target: 280,000-300,000 words" -ForegroundColor Cyan
$percent = [math]::Round(($totalWords / 280000) * 100, 2)
Write-Host "Progress: $percent%`n" -ForegroundColor Green

# Recent commits
Write-Host "Recent Writing Sessions:" -ForegroundColor Cyan
git log --oneline -5 --grep="Writing session"

