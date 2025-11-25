#Requires -Version 7.0

<#
.SYNOPSIS
    Master automation script for uploading Firman (2011) materials to GitBook repository

.DESCRIPTION
    This script automates the complete workflow for integrating Firman (2011) research materials
    into your PhD dissertation GitBook repository. It performs pre-flight checks, creates necessary
    directory structures, uploads files, commits changes to Git, and verifies successful integration.

.PARAMETER GitBookRepoPath
    Path to your GitBook repository root directory
    Default: C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis

.PARAMETER SourceMaterialsPath
    Path where the 5 Firman markdown source files are located
    Default: C:\Users\user\Documents\PhD\PhD_Sources\Firman_2011

.PARAMETER AutoCommit
    If present, automatically commits and pushes changes to Git
    If not present, stages changes but waits for manual commit

.PARAMETER BackupExisting
    If present, creates backups of any existing files before overwriting
    Default: Enabled (always backs up)

.EXAMPLE
    .\Firman_2011_GitBook_Upload_Master_CORRECTED.ps1
    Runs with default paths, stages changes but doesn't auto-commit

.EXAMPLE
    .\Firman_2011_GitBook_Upload_Master_CORRECTED.ps1 -AutoCommit
    Runs with default paths and automatically commits/pushes to Git

.EXAMPLE
    .\Firman_2011_GitBook_Upload_Master_CORRECTED.ps1 -GitBookRepoPath "D:\MyDissertation" -SourceMaterialsPath "D:\Sources\Firman"
    Uses custom paths for repository and source materials

.NOTES
    Author: AI Assistant (Genspark)
    Version: 2.0 (Path-corrected)
    Created: November 24, 2025
    
    IMPORTANT: Before first run, ensure:
    1. All 5 Firman markdown files exist in SourceMaterialsPath
    2. GitBook repository path is correct
    3. Git is installed and configured
    4. You have committed any pending changes in the repository
#>

param(
    [string]$GitBookRepoPath = "C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis",
    [string]$SourceMaterialsPath = "C:\Users\user\Documents\PhD\PhD_Sources\Firman_2011",
    [switch]$AutoCommit,
    [switch]$BackupExisting = $true
)

# ============================================================================
# CONFIGURATION
# ============================================================================

$ErrorActionPreference = "Stop"
$ProgressPreference = "Continue"

# Log file location (inside repository automation folder)
$LogDirectory = Join-Path $GitBookRepoPath "automation\logs"
$LogFile = Join-Path $LogDirectory "Firman_Upload_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

# Required source files
$RequiredFiles = @(
    "Firman_2011_Source_Summary.md",
    "Firman_2011_Quotes_Database.md",
    "Firman_2011_Chapter_Integration_Guide.md",
    "Firman_2011_Bibliography.bib",
    "Firman_Larsen_Comparative_Analysis.md"
)

# Target directory structure within GitBook repo
$TargetStructure = @{
    "SourceSummaries"      = "sources\summaries"
    "QuotesDatabases"      = "sources\quotes"
    "IntegrationGuides"    = "sources\integration_guides"
    "Bibliography"         = "sources\bibliography"
    "ComparativeAnalyses"  = "sources\comparative_analyses"
}

# ============================================================================
# LOGGING FUNCTIONS
# ============================================================================

function Write-Log {
    param(
        [string]$Message,
        [ValidateSet("INFO", "SUCCESS", "WARNING", "ERROR")]
        [string]$Level = "INFO"
    )
    
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMessage = "[$Timestamp] [$Level] $Message"
    
    # Create log directory if it doesn't exist
    if (-not (Test-Path $LogDirectory)) {
        New-Item -Path $LogDirectory -ItemType Directory -Force | Out-Null
    }
    
    # Write to log file
    Add-Content -Path $LogFile -Value $LogMessage
    
    # Write to console with color coding
    switch ($Level) {
        "INFO"    { Write-Host $LogMessage -ForegroundColor Cyan }
        "SUCCESS" { Write-Host $LogMessage -ForegroundColor Green }
        "WARNING" { Write-Host $LogMessage -ForegroundColor Yellow }
        "ERROR"   { Write-Host $LogMessage -ForegroundColor Red }
    }
}

# ============================================================================
# PRE-FLIGHT CHECKS
# ============================================================================

function Test-Prerequisites {
    Write-Log "Starting pre-flight checks..." -Level "INFO"
    
    $AllChecksPassed = $true
    
    # Check: Git installed
    try {
        $GitVersion = git --version
        Write-Log "Git detected: $GitVersion" -Level "SUCCESS"
    }
    catch {
        Write-Log "Git is not installed or not in PATH. Please install Git and try again." -Level "ERROR"
        $AllChecksPassed = $false
    }
    
    # Check: PowerShell version
    if ($PSVersionTable.PSVersion.Major -lt 7) {
        Write-Log "PowerShell 7+ required. Current version: $($PSVersionTable.PSVersion)" -Level "ERROR"
        $AllChecksPassed = $false
    }
    else {
        Write-Log "PowerShell version check passed: $($PSVersionTable.PSVersion)" -Level "SUCCESS"
    }
    
    # Check: GitBook repository exists
    if (-not (Test-Path $GitBookRepoPath)) {
        Write-Log "GitBook repository not found at: $GitBookRepoPath" -Level "ERROR"
        $AllChecksPassed = $false
    }
    else {
        Write-Log "GitBook repository found: $GitBookRepoPath" -Level "SUCCESS"
    }
    
    # Check: Source materials directory exists
    if (-not (Test-Path $SourceMaterialsPath)) {
        Write-Log "Source materials directory not found at: $SourceMaterialsPath" -Level "ERROR"
        Write-Log "Creating source materials directory..." -Level "INFO"
        try {
            New-Item -Path $SourceMaterialsPath -ItemType Directory -Force | Out-Null
            Write-Log "Source materials directory created successfully." -Level "SUCCESS"
        }
        catch {
            Write-Log "Failed to create source materials directory: $_" -Level "ERROR"
            $AllChecksPassed = $false
        }
    }
    else {
        Write-Log "Source materials directory found: $SourceMaterialsPath" -Level "SUCCESS"
    }
    
    # Check: All required files exist
    $MissingFiles = @()
    foreach ($File in $RequiredFiles) {
        $FilePath = Join-Path $SourceMaterialsPath $File
        if (-not (Test-Path $FilePath)) {
            Write-Log "Required file not found: $File" -Level "WARNING"
            Write-Log "   Expected location: $FilePath" -Level "WARNING"
            $MissingFiles += $File
            $AllChecksPassed = $false
        }
        else {
            Write-Log "Required file found: $File" -Level "SUCCESS"
        }
    }
    
    if ($MissingFiles.Count -gt 0) {
        Write-Log "" -Level "ERROR"
        Write-Log "MISSING FILES DETECTED:" -Level "ERROR"
        Write-Log "The following files must be present in: $SourceMaterialsPath" -Level "ERROR"
        foreach ($File in $MissingFiles) {
            Write-Log "  - $File" -Level "ERROR"
        }
        Write-Log "" -Level "ERROR"
        Write-Log "INSTRUCTIONS:" -Level "INFO"
        Write-Log "1. Save all 5 Firman markdown/bib files to: $SourceMaterialsPath" -Level "INFO"
        Write-Log "2. Verify filenames match exactly (case-sensitive)" -Level "INFO"
        Write-Log "3. Re-run this script" -Level "INFO"
    }
    
    # Check: Git repository status
    if (Test-Path $GitBookRepoPath) {
        Push-Location $GitBookRepoPath
        try {
            $GitStatus = git status --porcelain
            if ($GitStatus) {
                Write-Log "Git repository has uncommitted changes:" -Level "WARNING"
                Write-Log $GitStatus -Level "WARNING"
                Write-Log "Recommendation: Commit or stash changes before running this script" -Level "WARNING"
                
                $Response = Read-Host "Continue anyway? (y/N)"
                if ($Response -notmatch '^[Yy]') {
                    Write-Log "Upload cancelled by user" -Level "INFO"
                    $AllChecksPassed = $false
                }
            }
            else {
                Write-Log "Git repository is clean (no uncommitted changes)" -Level "SUCCESS"
            }
        }
        catch {
            Write-Log "Could not check Git status: $_" -Level "WARNING"
        }
        finally {
            Pop-Location
        }
    }
    
    return $AllChecksPassed
}

# ============================================================================
# DIRECTORY STRUCTURE CREATION
# ============================================================================

function New-DirectoryStructure {
    Write-Log "Creating target directory structure..." -Level "INFO"
    
    foreach ($DirName in $TargetStructure.Values) {
        $FullPath = Join-Path $GitBookRepoPath $DirName
        
        if (-not (Test-Path $FullPath)) {
            try {
                New-Item -Path $FullPath -ItemType Directory -Force | Out-Null
                Write-Log "Created directory: $DirName" -Level "SUCCESS"
            }
            catch {
                Write-Log "Failed to create directory $DirName : $_" -Level "ERROR"
                throw
            }
        }
        else {
            Write-Log "Directory already exists: $DirName" -Level "INFO"
        }
    }
}

# ============================================================================
# FILE BACKUP FUNCTION
# ============================================================================

function Backup-ExistingFile {
    param([string]$FilePath)
    
    if (Test-Path $FilePath) {
        $BackupPath = "$FilePath.backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        try {
            Copy-Item -Path $FilePath -Destination $BackupPath -Force
            Write-Log "Backed up existing file to: $BackupPath" -Level "INFO"
            return $true
        }
        catch {
            Write-Log "Failed to backup file: $_" -Level "WARNING"
            return $false
        }
    }
    return $false
}

# ============================================================================
# FILE UPLOAD FUNCTION
# ============================================================================

function Copy-SourceFiles {
    Write-Log "Uploading Firman source files to GitBook repository..." -Level "INFO"
    
    $FileMapping = @{
        "Firman_2011_Source_Summary.md"                = $TargetStructure["SourceSummaries"]
        "Firman_2011_Quotes_Database.md"               = $TargetStructure["QuotesDatabases"]
        "Firman_2011_Chapter_Integration_Guide.md"     = $TargetStructure["IntegrationGuides"]
        "Firman_2011_Bibliography.bib"                 = $TargetStructure["Bibliography"]
        "Firman_Larsen_Comparative_Analysis.md"        = $TargetStructure["ComparativeAnalyses"]
    }
    
    $UploadedFiles = @()
    
    foreach ($FileName in $FileMapping.Keys) {
        $SourceFile = Join-Path $SourceMaterialsPath $FileName
        $TargetDir = Join-Path $GitBookRepoPath $FileMapping[$FileName]
        $TargetFile = Join-Path $TargetDir $FileName
        
        try {
            # Backup existing file if requested
            if ($BackupExisting) {
                Backup-ExistingFile -FilePath $TargetFile | Out-Null
            }
            
            # Copy file
            Copy-Item -Path $SourceFile -Destination $TargetFile -Force
            Write-Log "Uploaded: $FileName -> $($FileMapping[$FileName])" -Level "SUCCESS"
            
            $UploadedFiles += @{
                FileName = $FileName
                TargetPath = $TargetFile
                Size = (Get-Item $TargetFile).Length
            }
        }
        catch {
            Write-Log "Failed to upload $FileName : $_" -Level "ERROR"
            throw
        }
    }
    
    return $UploadedFiles
}

# ============================================================================
# GIT INTEGRATION
# ============================================================================

function Invoke-GitCommit {
    param([array]$UploadedFiles)
    
    Write-Log "Integrating changes with Git..." -Level "INFO"
    
    Push-Location $GitBookRepoPath
    try {
        # Stage all uploaded files
        foreach ($FileInfo in $UploadedFiles) {
            $RelativePath = $FileInfo.TargetPath.Replace("$GitBookRepoPath\", "").Replace("\", "/")
            git add $RelativePath
            Write-Log "Staged: $RelativePath" -Level "INFO"
        }
        
        # Check if AutoCommit is enabled
        if ($AutoCommit) {
            # Create commit message
            $CommitMessage = @"
Add Firman (2011) research materials

- Source summary (experimental evolution study)
- Quotes database (35 quotes, 11 themes)
- Chapter integration guide (8 chapters)
- Bibliography record (BibTeX format)
- Firman-Larsen comparative analysis

Key finding: 77% paternity monopolization by genetically superior males
Uploaded: $(Get-Date -Format 'yyyy-MM-dd HH:mm')
"@
            
            # Commit changes
            git commit -m $CommitMessage
            Write-Log "Changes committed to Git" -Level "SUCCESS"
            
            # Push to remote
            $Response = Read-Host "Push changes to remote repository? (Y/n)"
            if ($Response -match '^[Yy]' -or [string]::IsNullOrWhiteSpace($Response)) {
                git push
                Write-Log "Changes pushed to remote repository" -Level "SUCCESS"
            }
            else {
                Write-Log "Changes committed locally but not pushed" -Level "INFO"
            }
        }
        else {
            Write-Log "Files staged but not committed (AutoCommit not enabled)" -Level "INFO"
            Write-Log "To commit manually, run:" -Level "INFO"
            Write-Log '   git commit -m "Add Firman (2011) research materials"' -Level "INFO"
            Write-Log "   git push" -Level "INFO"
        }
    }
    catch {
        Write-Log "Git operation failed: $_" -Level "ERROR"
        throw
    }
    finally {
        Pop-Location
    }
}

# ============================================================================
# VERIFICATION
# ============================================================================

function Test-UploadIntegrity {
    param([array]$UploadedFiles)
    
    Write-Log "Verifying upload integrity..." -Level "INFO"
    
    $AllFilesValid = $true
    
    foreach ($FileInfo in $UploadedFiles) {
        if (Test-Path $FileInfo.TargetPath) {
            $TargetSize = (Get-Item $FileInfo.TargetPath).Length
            
            if ($TargetSize -eq $FileInfo.Size) {
                Write-Log "Verified: $($FileInfo.FileName) ($TargetSize bytes)" -Level "SUCCESS"
            }
            else {
                Write-Log "Size mismatch: $($FileInfo.FileName) (expected: $($FileInfo.Size), got: $TargetSize)" -Level "ERROR"
                $AllFilesValid = $false
            }
        }
        else {
            Write-Log "File not found after upload: $($FileInfo.FileName)" -Level "ERROR"
            $AllFilesValid = $false
        }
    }
    
    return $AllFilesValid
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

function Main {
    Write-Log "========================================" -Level "INFO"
    Write-Log "Firman (2011) GitBook Upload Master" -Level "INFO"
    Write-Log "========================================" -Level "INFO"
    Write-Log "GitBook Repository: $GitBookRepoPath" -Level "INFO"
    Write-Log "Source Materials: $SourceMaterialsPath" -Level "INFO"
    Write-Log "Auto-Commit: $($AutoCommit.IsPresent)" -Level "INFO"
    Write-Log "Log File: $LogFile" -Level "INFO"
    Write-Log "" -Level "INFO"
    
    try {
        # Step 1: Pre-flight checks
        if (-not (Test-Prerequisites)) {
            Write-Log "Pre-flight checks failed. Please fix errors and try again." -Level "ERROR"
            return
        }
        
        Write-Log "" -Level "INFO"
        
        # Step 2: Create directory structure
        New-DirectoryStructure
        
        Write-Log "" -Level "INFO"
        
        # Step 3: Upload files
        $UploadedFiles = Copy-SourceFiles
        
        Write-Log "" -Level "INFO"
        
        # Step 4: Verify uploads
        if (-not (Test-UploadIntegrity -UploadedFiles $UploadedFiles)) {
            Write-Log "Upload verification failed. Please check log for details." -Level "ERROR"
            return
        }
        
        Write-Log "" -Level "INFO"
        
        # Step 5: Git integration
        Invoke-GitCommit -UploadedFiles $UploadedFiles
        
        Write-Log "" -Level "INFO"
        Write-Log "========================================" -Level "SUCCESS"
        Write-Log "UPLOAD COMPLETE" -Level "SUCCESS"
        Write-Log "========================================" -Level "SUCCESS"
        Write-Log "Files uploaded: $($UploadedFiles.Count)" -Level "SUCCESS"
        Write-Log "Total size: $([math]::Round(($UploadedFiles | Measure-Object -Property Size -Sum).Sum / 1KB, 2)) KB" -Level "SUCCESS"
        Write-Log "Log file: $LogFile" -Level "SUCCESS"
        Write-Log "" -Level "INFO"
        Write-Log "NEXT STEPS:" -Level "INFO"
        Write-Log "1. Review uploaded files in GitBook repository" -Level "INFO"
        Write-Log "2. Update SUMMARY.md to link to new materials (if needed)" -Level "INFO"
        Write-Log "3. Test GitBook build locally: gitbook serve" -Level "INFO"
        Write-Log "4. If not auto-committed, commit and push changes manually" -Level "INFO"
        
    }
    catch {
        Write-Log "Fatal error occurred: $_" -Level "ERROR"
        Write-Log "Stack trace: $($_.ScriptStackTrace)" -Level "ERROR"
        exit 1
    }
}

# Run main function
Main
