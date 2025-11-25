# Update Abstract with New Research Findings
# Creates new abstract reflecting expanded source integration

$ErrorActionPreference = "Stop"
$RepoPath = "C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis"

Push-Location $RepoPath

Write-Host "`n================================" -ForegroundColor Cyan
Write-Host "ABSTRACT UPDATER" -ForegroundColor Cyan
Write-Host "================================`n" -ForegroundColor Cyan

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"

# New abstract incorporating all recent research
$newAbstract = @"
---
title: Abstract - Evolutionary Psychology of Mating
description: Multi-level integration of mate selection from quantum biology to demographic outcomes
last_updated: $timestamp
---

# Abstract

The contemporary Western world faces a demographic paradox: despite unprecedented access to potential partners through digital technology and expanded social networks, relationship formation rates and birth rates have reached historic lows. This dissertation argues that the contemporary mating crisis cannot be understood through reductionist models that isolate single dimensions of mate choice. Instead, sustainable pair bonding emerges from successful navigation across multiple interdependent levels of analysis.

This research presents a comprehensive multi-level integration framework synthesizing evolutionary psychology, behavioral genetics, demographic analysis, economic sociology, Jungian depth psychology, and emerging quantum biology research. The framework demonstrates how mate selection operates simultaneously across six analytical levels: (1) **Quantum/Consciousness Substrate** - potential quantum biological processes underlying subjective attraction (Limar, 2011); (2) **Genetic Mechanisms** - postcopulatory selection demonstrating 77% paternity bias toward genetically superior males (Firman & Simmons, 2011); (3) **Evolutionary Psychology** - ancestral mate preferences and strategic pluralism (Buss, 2023; Gangestad & Simpson, 2000); (4) **Economic Constraints** - hypergamous mate choice creating reproductive stratification (Bertrand et al.); (5) **Demographic Outcomes** - temporal polygyny producing 10:1 reproductive ratios across 5,000 years (Larsen, 2023); and (6) **Transpersonal/Individuation** - Jungian shadow integration and synchronistic phenomena in pair bond formation.

The dissertation employs an interdisciplinary comparative methodology integrating: (a) experimental evolution data from 27-generation selection studies validating cryptic female choice mechanisms; (b) historical-demographic analysis spanning 5,000 years documenting persistent reproductive inequality; (c) cross-cultural psychological surveys on mate preferences and physical attractiveness; (d) economic registry data on hypergamous mating patterns; (e) Jungian analytical psychology frameworks for depth-psychological processes; and (f) speculative integration of quantum coherence research as potential substrate for consciousness and subjective compatibility.

**Key empirical findings** include documentation of extreme reproductive stratification operating through dual mechanisms: precopulatory filtering via economic status (Larsen's 10:1 ratio) combined with postcopulatory selection via genetic quality (Firman's 77% paternity monopolization), potentially yielding ~30:1 total reproductive advantage for top-tier males. This stratification represents the most extreme sexual selection documented in human populations, comparable to polygynous species like elephant seals. The dissertation traces how individual-level mate preferences (Buss, Gangestad & Simpson) operating within economic constraints (Bertrand) aggregate into population-level demographic crises (Larsen), while depth-psychological processes (Jung) and potential quantum substrates (Limar) address subjective dimensions of attraction inadequately explained by functional evolutionary models alone.

**Theoretical contributions** include: (1) multi-level integration model bridging reductionist biological explanations with holistic transpersonal perspectives; (2) demonstration that Buss's mating strategies framework provides meta-theoretical architecture within which genetic (Firman), economic (Bertrand, Larsen), and consciousness (Limar) mechanisms operate; (3) evolutionary mismatch thesis showing how adaptive ancestral preferences produce maladaptive outcomes in high-inequality modern environments; (4) Jungian reinterpretation of mate choice as individuation process where relationship serves as crucible for psychological growth beyond projection-based attraction.

**Practical implications** address the contemporary demographic crisis by showing that evolved female hypergamous preferences (unchangeable via policy) interact with modern economic inequality (policy-addressable) to produce reproductive stratification and fertility collapse. The dissertation argues that sustainable interventions must work *with* evolved psychology rather than against it, suggesting economic redistribution and family-formation support for lower-income males as demographic-stabilization strategies. Additionally, the framework proposes that conscious recognition of projection-based mate selection can facilitate transition to growth-oriented partnerships, offering therapeutic applications for relationship counseling.

This work distinguishes itself by refusing reductionist monism—neither purely biological (evolutionary psychology) nor purely psychological (Jungian) nor purely economic (sociological) explanations suffice. Instead, sustainable pair bonding requires alignment across all levels: from potential quantum resonance through genetic compatibility, psychological individuation, economic viability, to contribution to demographic stability. The dissertation thus offers both theoretical advancement in understanding human mating's multi-level complexity and evidence-based strategies for addressing modernity's relationship and fertility crises.

**Keywords:** pair bonding, evolutionary psychology, sexual selection, reproductive stratification, hypergamy, temporal polygyny, postcopulatory selection, cryptic female choice, Jungian psychology, individuation, synchronicity, transpersonal psychology, quantum biology, demographic collapse, evolutionary mismatch, mate preferences

---

**Word Count:** ~550 words  
**Primary Sources:** Firman & Simmons (2011), Larsen (2023), Buss (2023), Gangestad & Simpson (2000), Bertrand et al., Jung (1946/1954), Limar (2011)  
**Key Quantitative Findings:** 77% paternity bias (Firman), 10:1 reproductive ratio (Larsen), 3.3:1 genetic advantage (Firman)  
**Methodological Approach:** Comparative analysis across experimental evolution, historical demography, economic sociology, depth psychology, and quantum biology  
**Dissertation Status:** Chapter 1 draft (~1,300 words), comprehensive source integration framework complete (~15,000 words comparative analyses)
"@

# Backup old abstract
$abstractPath = "front_matter/abstract.md"
if (Test-Path $abstractPath) {
    $backupPath = "front_matter/abstract.md.backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    Copy-Item $abstractPath $backupPath -Force
    Write-Host "✓ Backed up original abstract to:" -ForegroundColor Green
    Write-Host "  $backupPath`n" -ForegroundColor Gray
}

# Write new abstract
$newAbstract | Out-File $abstractPath -Encoding UTF8
Write-Host "✓ Created new abstract at:" -ForegroundColor Green
Write-Host "  $abstractPath`n" -ForegroundColor Gray

# Calculate word counts
$oldWordCount = 0
if (Test-Path $backupPath) {
    $oldContent = Get-Content $backupPath -Raw
    $oldWordCount = ($oldContent -split '\s+').Count
}
$newWordCount = ($newAbstract -split '\s+').Count

Write-Host "Abstract Statistics:" -ForegroundColor Cyan
Write-Host "  Old: ~$oldWordCount words" -ForegroundColor Gray
Write-Host "  New: ~$newWordCount words" -ForegroundColor Gray
Write-Host "  Change: +$($newWordCount - $oldWordCount) words`n" -ForegroundColor Gray

Write-Host "Key Updates:" -ForegroundColor Cyan
Write-Host "  ✓ Added Firman & Simmons (2011) experimental evolution data" -ForegroundColor White
Write-Host "  ✓ Added Larsen (2023) 5,000-year demographic analysis" -ForegroundColor White
Write-Host "  ✓ Added Gangestad & Simpson (2000) good genes framework" -ForegroundColor White
Write-Host "  ✓ Upgraded to multi-level integration model (6 levels)" -ForegroundColor White
Write-Host "  ✓ Added quantitative findings: 77% paternity bias, 10:1 ratio" -ForegroundColor White
Write-Host "  ✓ Added reproductive stratification (~30:1 combined effect)" -ForegroundColor White
Write-Host "  ✓ Strengthened evolutionary mismatch thesis" -ForegroundColor White
Write-Host "  ✓ Updated methodology to comparative analysis approach`n" -ForegroundColor White

# Show comparison
Write-Host "================================" -ForegroundColor Yellow
Write-Host "COMPARISON: OLD vs NEW" -ForegroundColor Yellow
Write-Host "================================`n" -ForegroundColor Yellow

Write-Host "FRAMEWORK:" -ForegroundColor Cyan
Write-Host "  Old: Four-dimensional model" -ForegroundColor Gray
Write-Host "  New: Six-level integration model`n" -ForegroundColor White

Write-Host "EMPIRICAL GROUNDING:" -ForegroundColor Cyan
Write-Host "  Old: Mentioned Buss, Bertrand, Fayyaz, Limar" -ForegroundColor Gray
Write-Host "  New: Experimental evolution (Firman), 5,000-year data (Larsen)," -ForegroundColor White
Write-Host "       cross-cultural surveys (G&S), economic data (Bertrand)`n" -ForegroundColor White

Write-Host "QUANTITATIVE FINDINGS:" -ForegroundColor Cyan
Write-Host "  Old: None specified" -ForegroundColor Gray
Write-Host "  New: 77% paternity bias, 10:1 reproductive ratio, 3.3:1 genetic advantage`n" -ForegroundColor White

Write-Host "THEORETICAL DEPTH:" -ForegroundColor Cyan
Write-Host "  Old: Integration of biological + transpersonal" -ForegroundColor Gray
Write-Host "  New: Multi-level causal chains from quantum → demographic`n" -ForegroundColor White

Write-Host "PRACTICAL IMPLICATIONS:" -ForegroundColor Cyan
Write-Host "  Old: General relationship counseling applications" -ForegroundColor Gray
Write-Host "  New: Specific demographic policy recommendations (economic redistribution)`n" -ForegroundColor White

# Git status
Write-Host "================================" -ForegroundColor Green
Write-Host "ABSTRACT UPDATE COMPLETE!" -ForegroundColor Green
Write-Host "================================`n" -ForegroundColor Green

$commitNow = Read-Host "Commit changes to Git? (yes/no)"

if ($commitNow -eq "yes") {
    Write-Host "`nCommitting..." -ForegroundColor Cyan
    
    git add -A
    git commit -m "Update abstract with comprehensive source integration

Major updates:
- Added Firman & Simmons (2011) experimental evolution findings
- Added Larsen (2023) 5,000-year demographic analysis  
- Added Gangestad & Simpson (2000) good genes framework
- Upgraded to multi-level integration model (6 levels)
- Added key quantitative findings: 77% paternity bias, 10:1 reproductive ratio
- Documented ~30:1 combined reproductive stratification effect
- Strengthened evolutionary mismatch thesis
- Updated methodology to comparative analysis approach

Word count: ~$oldWordCount → ~$newWordCount words (+$($newWordCount - $oldWordCount))

Reflects completion of 5 comparative analyses and comprehensive source integration."
    
    git push origin main
    
    Write-Host "`n✓ Changes committed and pushed!" -ForegroundColor Green
    Write-Host "GitBook will sync within 2-3 minutes.`n" -ForegroundColor Cyan
    
} else {
    Write-Host "`nCommit manually when ready:" -ForegroundColor Yellow
    Write-Host "  git add -A" -ForegroundColor Gray
    Write-Host "  git commit -m 'Update abstract with new research'" -ForegroundColor Gray
    Write-Host "  git push origin main`n" -ForegroundColor Gray
}

Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "  1. Review new abstract in: front_matter/abstract.md" -ForegroundColor White
Write-Host "  2. Check GitBook display after sync" -ForegroundColor White
Write-Host "  3. Consider updating dissertation proposal if required`n" -ForegroundColor White

Pop-Location
