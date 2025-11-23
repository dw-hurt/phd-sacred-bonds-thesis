param([Parameter(Mandatory=$true)][int]$ChapterNumber,[string]$Editor="notepad")
$cn="{0:D2}" -f $ChapterNumber
$cf=Get-ChildItem "chapters\${cn}_*\*.md" -EA SilentlyContinue|Select -First 1
if(!$cf){Write-Host "Chapter $ChapterNumber not found!" -ForegroundColor Red;exit 1}
Write-Host "Opening Chapter $ChapterNumber" -ForegroundColor Green
Start-Process $Editor $cf.FullName
Start-Sleep -Milliseconds 500
$qf="quotes\by_chapter\chapter_${cn}_quotes.md"
if(Test-Path $qf){Start-Process $Editor $qf}
