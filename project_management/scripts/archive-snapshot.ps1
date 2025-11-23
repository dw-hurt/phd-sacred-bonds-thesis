

# ============================================================================
# archive-snapshot.ps1
# PhD Project Archive Snapshot System
# ============================================================================

param(
    [Parameter(Mandatory=$false)]
    [string]$Description = "Manual snapshot"
)

# Repository base path
$RepoPath = "C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis"
$ArchiveRoot = Join-Path $RepoPath "archive"
$Timestamp = Get-Date -Format "yyyy-MM-dd_HHmmss"
$SnapshotFolder = Join-Path $ArchiveRoot $Timestamp

Write-Host "`n" -NoNewline
Write-Host "Creating Archive Snapshot..." -ForegroundColor Cyan
Write-Host ("=" * 60) -ForegroundColor Gray

# ============================================================================
# Create Archive Directory Structure
# ============================================================================

if (-not (Test-Path $ArchiveRoot)) {
    New-Item -Path $ArchiveRoot -ItemType Directory -Force | Out-Null
    Write-Host "Created archive root directory" -ForegroundColor Green
}

New-Item -Path $SnapshotFolder -ItemType Directory -Force | Out-Null
Write-Host "Snapshot folder: $Timestamp" -ForegroundColor Yellow

# ============================================================================
# Collect Repository Statistics
# ============================================================================

$stats = @{
    Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Description = $Description
    TotalFiles = 0
    TotalSize = 0
    DirectoriesCopied = 0
    FilesByCat = @{}
}

# Count files before copying
$allFiles = Get-ChildItem -Path $RepoPath -Recurse -File -ErrorAction SilentlyContinue | Where-Object { 
    $_.FullName -notlike "*\.git\*" -and 
    $_.FullName -notlike "*\archive\*" -and
    $_.FullName -notlike "*\node_modules\*"
}

$stats.TotalFiles = $allFiles.Count
$stats.TotalSize = ($allFiles | Measure-Object -Property Length -Sum).Sum

Write-Host "`nRepository Statistics:" -ForegroundColor Cyan
Write-Host "  Total Files: $($stats.TotalFiles)" -ForegroundColor White
Write-Host "  Total Size: $([math]::Round($stats.TotalSize / 1MB, 2)) MB" -ForegroundColor White

# ============================================================================
# Copy Repository Contents
# ============================================================================

Write-Host "`nCopying repository contents..." -ForegroundColor Yellow

$directoriesToCopy = @(
    "chapters",
    "front_matter",
    "notes",
    "quotes",
    "research_journal",
    "project_management",
    "assets"
)

foreach ($dir in $directoriesToCopy) {
    $sourcePath = Join-Path $RepoPath $dir
    $destPath = Join-Path $SnapshotFolder $dir
    
    if (Test-Path $sourcePath) {
        try {
            Copy-Item -Path $sourcePath -Destination $destPath -Recurse -Force -ErrorAction Stop
            $stats.DirectoriesCopied++
            Write-Host "  Copied: $dir" -ForegroundColor Green
        } catch {
            Write-Host "  Failed: $dir - $_" -ForegroundColor Red
        }
    }
}

# Copy root files (SUMMARY.md, README.md, etc.)
$rootFiles = Get-ChildItem -Path $RepoPath -File | Where-Object {
    $_.Name -notlike ".*" -and $_.Name -ne "package-lock.json"
}

foreach ($file in $rootFiles) {
    Copy-Item -Path $file.FullName -Destination $SnapshotFolder -Force
    Write-Host "  Copied: $($file.Name)" -ForegroundColor Green
}

# ============================================================================
# Generate Archive Metadata
# ============================================================================

$metadataContent = @"
# Archive Snapshot Metadata

**Created:** $($stats.Timestamp)  
**Description:** $Description

---

## Snapshot Statistics

- **Total Files Archived:** $($stats.TotalFiles)
- **Total Size:** $([math]::Round($stats.TotalSize / 1MB, 2)) MB
- **Directories Copied:** $($stats.DirectoriesCopied)

---

## Directory Structure

"@

# List directories
Get-ChildItem -Path $SnapshotFolder -Directory | ForEach-Object {
    $fileCount = (Get-ChildItem -Path $_.FullName -Recurse -File).Count
    $metadataContent += "- **$($_.Name)**: $fileCount files`n"
}

$metadataContent += @"

---

## File Type Breakdown

"@

# Count by extension
$filesByExt = $allFiles | Group-Object Extension | Sort-Object Count -Descending
foreach ($group in $filesByExt) {
    $ext = if ($group.Name) { $group.Name } else { "(no extension)" }
    $metadataContent += "- **$ext**: $($group.Count) files`n"
}

$metadataContent += @"

---

## Git Status at Time of Snapshot

``````
"@

# Capture Git status
Push-Location $RepoPath
$gitStatus = git status --short 2>&1 | Out-String
$gitBranch = git branch --show-current 2>&1
$gitCommit = git log -1 --oneline 2>&1
Pop-Location

$metadataContent += @"
Branch: $gitBranch
Latest Commit: $gitCommit

$gitStatus
``````

---

*Archive created by archive-snapshot.ps1*
"@

$metadataFile = Join-Path $SnapshotFolder "ARCHIVE_INFO.md"
Set-Content -Path $metadataFile -Value $metadataContent -Encoding UTF8

Write-Host "`nMetadata file created: ARCHIVE_INFO.md" -ForegroundColor Green

# ============================================================================
# Update Archive Index
# ============================================================================

$indexFile = Join-Path $ArchiveRoot "archive_index.md"
$indexEntry = "- **$Timestamp** - $Description ($([math]::Round($stats.TotalSize / 1MB, 2)) MB, $($stats.TotalFiles) files)`n"

if (Test-Path $indexFile) {
    $existingContent = Get-Content $indexFile -Raw
    $updatedContent = $existingContent -replace "(## Archive List`r?`n)", "`$1$indexEntry"
    Set-Content -Path $indexFile -Value $updatedContent -Encoding UTF8
} else {
    $newIndexContent = @"
# Archive Index

This directory contains timestamped snapshots of the PhD dissertation repository.

---

## Archive List
$indexEntry
---

## Usage

Each snapshot folder contains:
- Complete copy of all project files (excluding .git)
- ARCHIVE_INFO.md with metadata and statistics
- Full directory structure preserved

## Restore from Archive

To restore from a snapshot:
1. Navigate to desired timestamp folder
2. Copy contents back to main repository
3. Review ARCHIVE_INFO.md for Git status at time of snapshot

---

*Managed by archive-snapshot.ps1*
"@
    Set-Content -Path $indexFile -Value $newIndexContent -Encoding UTF8
}

Write-Host "Archive index updated" -ForegroundColor Green

# ============================================================================
# Summary
# ============================================================================

Write-Host "`n" -NoNewline
Write-Host ("=" * 60) -ForegroundColor Gray
Write-Host "Archive snapshot complete!" -ForegroundColor Green
Write-Host "`nSnapshot Location:" -ForegroundColor Cyan
Write-Host "  $SnapshotFolder" -ForegroundColor White
Write-Host "`nArchive Statistics:" -ForegroundColor Cyan
Write-Host "  Files: $($stats.TotalFiles)" -ForegroundColor White
Write-Host "  Size: $([math]::Round($stats.TotalSize / 1MB, 2)) MB" -ForegroundColor White
Write-Host "  Directories: $($stats.DirectoriesCopied)" -ForegroundColor White
Write-Host "`n" -NoNewline
