# Daily Writing Session Script
# Manages workflow for dissertation writing

param(
    [string]$Chapter = "01_introduction",
    [string]$Action = "start"
)

$repoPath = "$HOME\Documents\PhD\phd-sacred-bonds-thesis"
Set-Location $repoPath

function Start-WritingSession {
    param([string]$ChapterNum)
    
    Write-Host "`n📝 STARTING WRITING SESSION" -ForegroundColor Green
    Write-Host "Chapter: $ChapterNum`n" -ForegroundColor Cyan
    
    # Pull latest changes
    Write-Host "Syncing with GitHub/GitBook..." -ForegroundColor Yellow
    git pull
    
    # Open relevant files
    Write-Host "Opening chapter file..." -ForegroundColor Yellow
    $chapterFile = "chapters\$ChapterNum\chapter_$($ChapterNum)_*.md"
    code $chapterFile
    
    # Open quote database for reference
    Write-Host "Opening quote database..." -ForegroundColor Yellow
    if ($ChapterNum -eq "01_introduction" -or $ChapterNum -match "02") {
        code quotes\by_chapter\chapter_02_quotes.md
    }
    
    # Open relevant summary
    Write-Host "Opening source summaries..." -ForegroundColor Yellow
    code notes\reading_notes\by_source\
    
    Write-Host "`n✅ Ready to write!" -ForegroundColor Green
    Write-Host "💡 TIP: Save regularly (Ctrl+S)`n" -ForegroundColor Cyan
}

function End-WritingSession {
    Write-Host "`n💾 ENDING WRITING SESSION" -ForegroundColor Green
    
    # Show what changed
    Write-Host "`nChanges made:" -ForegroundColor Yellow
    git status --short
    
    # Calculate word count
    $mdFiles = Get-ChildItem chapters -Recurse -Filter *.md
    $totalWords = 0
    foreach ($file in $mdFiles) {
        $content = Get-Content $file.FullName -Raw
        $words = ($content -split '\s+').Count
        $totalWords += $words
    }
    
    Write-Host "`nTotal dissertation words: $totalWords" -ForegroundColor Green
    
    # Prompt for commit
    $commitMsg = Read-Host "`nDescribe today's progress"
    
    git add .
    git commit -m "Writing session: $commitMsg (Total words: $totalWords)"
    git push
    
    Write-Host "`n✅ Session saved and synced to GitHub/GitBook!" -ForegroundColor Green
}

# Execute action
switch ($Action) {
    "start" { Start-WritingSession -ChapterNum $Chapter }
    "end" { End-WritingSession }
    default { Write-Host "Usage: .\writing_session.ps1 -Chapter 01_introduction -Action start|end" }
}
