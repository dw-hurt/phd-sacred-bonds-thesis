# Find all files and compute hashes
$files = Get-ChildItem -Path "C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis" -Recurse -File -Exclude *.git* | 
    Where-Object { $_.FullName -notlike '*\.git\*' -and $_.FullName -notlike '*\node_modules\*' }

Write-Host "Scanning $($files.Count) files for duplicates..." -ForegroundColor Cyan

$hashes = @{}
$duplicates = @()

foreach ($file in $files) {
    try {
        $hash = (Get-FileHash -Path $file.FullName -Algorithm MD5).Hash
        
        if ($hashes.ContainsKey($hash)) {
            $duplicates += [PSCustomObject]@{
                Hash = $hash
                Original = $hashes[$hash]
                Duplicate = $file.FullName
                Size = $file.Length
            }
        } else {
            $hashes[$hash] = $file.FullName
        }
    } catch {
        Write-Warning "Could not hash: $($file.FullName)"
    }
}

Write-Host "
=== DUPLICATE FILES FOUND ===" -ForegroundColor Yellow
Write-Host "Total duplicates: $($duplicates.Count)
" -ForegroundColor Yellow

if ($duplicates.Count -gt 0) {
    $duplicates | Group-Object Hash | ForEach-Object {
        Write-Host "
Duplicate Set (Hash: $($_.Name)):" -ForegroundColor Cyan
        Write-Host "Original : $($_.Group[0].Original)" -ForegroundColor Green
        foreach ($dup in $_.Group) {
            Write-Host "Duplicate: $($dup.Duplicate) [$([math]::Round($dup.Size/1KB, 2)) KB]" -ForegroundColor Red
        }
    }
} else {
    Write-Host "No duplicate files found!" -ForegroundColor Green
}
