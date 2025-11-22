param([switch]$Verbose)
Write-Host "Dashboard Update" -ForegroundColor Cyan
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$chapterData = @()
$totalWords = 0
for ($i = 1; $i -le 10; $i++) {
    $chapterNum = "{0:D2}" -f $i
    $chapterPath = "chapters\${chapterNum}_*\*.md"
    $chapterFile = Get-ChildItem $chapterPath -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($chapterFile) {
        $content = Get-Content $chapterFile.FullName -Raw
        $content = $content -replace '(?s)^---.*?---', '' -replace '#', '' -replace '\[.*?\]\(.*?\)', '' -replace '\*', ''
        $words = ($content | Measure-Object -Word).Words
        $totalWords += $words
        $chapterData += [PSCustomObject]@{Number=$i; WordCount=$words; Target=if($i -in 1,2,3,7){10000}elseif($i -in 4,5,6,8,9){7000}else{5000}}
        Write-Host "  Chapter $i : $words words" -ForegroundColor Green
    }
}
Write-Host "  Total: $totalWords words" -ForegroundColor Cyan
$titles=@{1="Introduction";2="Evolutionary";3="Archetypal";4="Synchronicity";5="Transpersonal";6="Crisis";7="Synthesis";8="Implications";9="Applications";10="Conclusion"}
$pc="# Progress Tracker`n`n**Updated:** $timestamp`n**Total:** $totalWords/70000`n`n|Ch|Title|Words|Target|%|`n|---|---|---|---|---|`n"
foreach($ch in $chapterData){$pct=[math]::Round(($ch.WordCount/$ch.Target)*100,1);$pc+="| $($ch.Number) | $($titles[$ch.Number]) | $($ch.WordCount) | $($ch.Target) | $pct% |`n"}
$pc | Out-File "project_management\progress_tracker.md" -Encoding UTF8
Write-Host "Done! $totalWords words" -ForegroundColor Green
