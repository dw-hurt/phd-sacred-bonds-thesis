param([string]$Title="",[string]$Editor="notepad")
$d=Get-Date -Format "yyyy-MM-dd"
$dp="research_journal\daily"
if(!(Test-Path $dp)){New-Item -ItemType Directory -Force -Path $dp|Out-Null}
$fn=if($Title){"${d}_$($Title -replace '\W','_').md"}else{"${d}_progress.md"}
$fp=Join-Path $dp $fn
if(Test-Path $fp){Start-Process $Editor $fp;exit 0}
"# Progress - $d`n`n## Done`n- `n`n## Next`n1. "|Out-File $fp -Encoding UTF8
Start-Process $Editor $fp
