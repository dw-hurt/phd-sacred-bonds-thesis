# Simple Daily Progress Tracker
$repoPath = "C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"

Set-Location $repoPath

Write-Host "Syncing with GitHub..." -ForegroundColor Cyan
git pull

Write-Host "Counting words..." -ForegroundColor Cyan

function Count-Words {
    param([string]$path)
    if (Test-Path $path) {
        $content = Get-Content $path -Raw
        $words = ($content -split '\s+').Count
        return $words
    }
    return 0
}

$ch1 = Count-Words "chapters\01_introduction\chapter_01_introduction.md"
$ch2 = Count-Words "chapters\02_evolutionary_psychology\chapter_02_evolutionary_psychology.md"
$ch3 = Count-Words "chapters\03_jungian_framework\chapter_03_jungian_framework.md"
$ch4 = Count-Words "chapters\04_synchronicity\chapter_04_synchronicity.md"
$ch5 = Count-Words "chapters\05_transpersonal_dimensions\chapter_05_transpersonal_dimensions.md"
$ch6 = Count-Words "chapters\06_contemporary_crisis\chapter_06_contemporary_crisis.md"
$ch7 = Count-Words "chapters\07_synthesis\chapter_07_synthesis.md"
$ch8 = Count-Words "chapters\08_implications\chapter_08_implications.md"

$total = $ch1 + $ch2 + $ch3 + $ch4 + $ch5 + $ch6 + $ch7 + $ch8
$percent = [math]::Round(($total / 87000) * 100, 1)

Write-Host ""
Write-Host "Word Counts:" -ForegroundColor Green
Write-Host "Chapter 1: $ch1 words"
Write-Host "Chapter 2: $ch2 words"
Write-Host "Chapter 3: $ch3 words"
Write-Host "Chapter 4: $ch4 words"
Write-Host "Chapter 5: $ch5 words"
Write-Host "Chapter 6: $ch6 words"
Write-Host "Chapter 7: $ch7 words"
Write-Host "Chapter 8: $ch8 words"
Write-Host ""
Write-Host "TOTAL: $total words ($percent percent complete)" -ForegroundColor Yellow
Write-Host ""

Write-Host "Committing to GitHub..." -ForegroundColor Cyan
git add project_management/
git commit -m "Dashboard update: $total words - $timestamp"
git push

Write-Host ""
Write-Host "Done!" -ForegroundColor Green

