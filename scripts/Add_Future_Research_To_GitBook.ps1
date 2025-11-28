#Requires -Version 7.0
<#
.SYNOPSIS
    Adds Future Research Directions document to GitBook under Research Materials

.DESCRIPTION
    Copies the Future Research Directions document to research_materials/future_research
    and updates SUMMARY.md to link it properly
#>

Write-Host "`n═══════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Add Future Research Directions to GitBook" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════`n" -ForegroundColor Cyan

# Check if in correct directory
if (-not (Test-Path "SUMMARY.md")) {
    Write-Host "ERROR: SUMMARY.md not found. Please run from repository root." -ForegroundColor Red
    exit 1
}

# Check if source file exists
if (-not (Test-Path "Future_Research_Directions.md")) {
    Write-Host "ERROR: Future_Research_Directions.md not found in current directory." -ForegroundColor Red
    exit 1
}

# Create directory structure
$targetDir = "research_materials/future_research"
if (-not (Test-Path $targetDir)) {
    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
    Write-Host "✓ Created directory: $targetDir" -ForegroundColor Green
}

# Copy file
$destination = "$targetDir/future_research_directions.md"
Copy-Item "Future_Research_Directions.md" $destination -Force
Write-Host "✓ Copied document to: $destination" -ForegroundColor Green

# Check file size
$fileSize = (Get-Item $destination).Length / 1KB
Write-Host "  Document size: $([math]::Round($fileSize, 1)) KB" -ForegroundColor Cyan

# Update SUMMARY.md if needed
$summary = Get-Content "SUMMARY.md" -Raw

if ($summary -notmatch "future_research_directions") {
    Write-Host "`nUpdating SUMMARY.md..." -ForegroundColor Yellow
    
    # Find Research Materials section or create it
    if ($summary -match "## Research Materials") {
        Write-Host "  Found Research Materials section" -ForegroundColor Cyan
        
        # Check if Future Research subsection exists
        if ($summary -match "### Future Research") {
            # Add under existing Future Research subsection
            $summary = $summary -replace "(### Future Research\n)", "`$1`n* [Future Research Directions](research_materials/future_research/future_research_directions.md)`n"
        } else {
            # Create Future Research subsection
            $futureResearchSection = @"
`n### Future Research`n
* [Future Research Directions](research_materials/future_research/future_research_directions.md)`n
"@
            # Add after Research Materials heading
            $summary = $summary -replace "(## Research Materials\n)", "`$1$futureResearchSection"
        }
        
        Set-Content "SUMMARY.md" -Value $summary -NoNewline
        Write-Host "✓ Added link to SUMMARY.md under Research Materials > Future Research" -ForegroundColor Green
    } else {
        # Create entire Research Materials section
        Write-Host "  Creating Research Materials section" -ForegroundColor Cyan
        
        $researchMaterialsSection = @"
`n## Research Materials`n
### Future Research`n
* [Future Research Directions](research_materials/future_research/future_research_directions.md)`n
"@
        
        # Add before Bibliography or at end
        if ($summary -match "## Bibliography") {
            $summary = $summary -replace "(## Bibliography)", "$researchMaterialsSection`$1"
        } else {
            $summary += $researchMaterialsSection
        }
        
        Set-Content "SUMMARY.md" -Value $summary -NoNewline
        Write-Host "✓ Created Research Materials section in SUMMARY.md" -ForegroundColor Green
    }
} else {
    Write-Host "✓ Link already exists in SUMMARY.md" -ForegroundColor Green
}

# Show where the link was added
Write-Host "`nVerifying SUMMARY.md entry:" -ForegroundColor Cyan
Get-Content "SUMMARY.md" | Select-String -Pattern "Research Materials|Future Research|future_research_directions" -Context 1

# Commit and push
Write-Host "`nCommitting to Git..." -ForegroundColor Yellow

git add $destination
git add "SUMMARY.md"

$commitMessage = @"
Add Future Research Directions to Research Materials

- Comprehensive analysis of research gaps based on 7 core sources
- 60+ recommended sources organized by priority
- Post-doctoral research directions identified
- Funding opportunities and collaboration targets
- Integration strategy for new sources
- Placed under Research Materials > Future Research section
"@

git commit -m $commitMessage

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Changes committed" -ForegroundColor Green
} else {
    Write-Host "⚠ No changes to commit (already up to date)" -ForegroundColor Yellow
}

# Push
Write-Host "`nPushing to GitHub..." -ForegroundColor Yellow
$pushResult = git push origin main 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Successfully pushed to GitHub!" -ForegroundColor Green
} else {
    Write-Host "Push output:" -ForegroundColor Yellow
    Write-Host $pushResult
    
    if ($pushResult -match "Everything up-to-date") {
        Write-Host "✓ Repository already up to date" -ForegroundColor Green
    } else {
        Write-Host "⚠ Push had issues - may need manual resolution" -ForegroundColor Yellow
    }
}

# Summary
Write-Host "`n═══════════════════════════════════════════" -ForegroundColor Green
Write-Host "  Future Research Document Added!" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════" -ForegroundColor Green
Write-Host ""
Write-Host "Document Location:" -ForegroundColor Cyan
Write-Host "  $destination"
Write-Host ""
Write-Host "GitBook Structure:" -ForegroundColor Cyan
Write-Host "  Research Materials"
Write-Host "    └─ Future Research"
Write-Host "        └─ Future Research Directions"
Write-Host ""
Write-Host "Content Summary:" -ForegroundColor Cyan
Write-Host "  • Analysis of 7 core dissertation sources"
Write-Host "  • 60+ recommended additional sources"
Write-Host "  • Organized by priority (PhD vs Post-Doc)"
Write-Host "  • Post-doc research directions"
Write-Host "  • Funding opportunities"
Write-Host "  • Reading list with timeline"
Write-Host ""
Write-Host "Wait 2-3 minutes for GitBook sync, then check:" -ForegroundColor Yellow
Write-Host "  https://app.gitbook.com/o/cyZpWhV7KomErB6BnmVk/s/hRoSpCiTUrfuH62swMvH/"
Write-Host ""
Write-Host "The document should appear under:" -ForegroundColor Cyan
Write-Host "  Research Materials → Future Research → Future Research Directions"
Write-Host ""
Write-Host "✓ Integration complete!" -ForegroundColor Green
Write-Host ""
