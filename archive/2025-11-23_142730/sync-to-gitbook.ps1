param([string]$Message="")
if(!(git status --porcelain)){Write-Host "No changes" -ForegroundColor Green;exit 0}
git status --short
if(!$Message){$um=Read-Host "`nCommit message";$Message=if($um){$um}else{"Update $(Get-Date -F 'yyyy-MM-dd HH:mm')"}}
git add -A
git commit -m $Message
git push origin main
Write-Host "`nSynced!" -ForegroundColor Green
