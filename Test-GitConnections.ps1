#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Tests connections between local Git repository, GitHub, and GitBook platform.

.DESCRIPTION
    This script verifies:
    1. Local Git repository status
    2. GitHub remote connection
    3. GitBook integration status
    4. Network connectivity to both platforms

.PARAMETER RepositoryPath
    Path to your local Git repository. Defaults to current directory.

.PARAMETER GitBookSpace
    Your GitBook space URL (e.g., https://yourspace.gitbook.io)

.EXAMPLE
    .\Test-GitConnections.ps1
    
.EXAMPLE
    .\Test-GitConnections.ps1 -RepositoryPath "C:\Projects\MyThesis" -GitBookSpace "https://myspace.gitbook.io"
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$RepositoryPath = (Get-Location).Path,
    
    [Parameter(Mandatory=$false)]
    [string]$GitBookSpace = ""
)

# Color output functions
function Write-Success {
    param([string]$Message)
    Write-Host "✓ $Message" -ForegroundColor Green
}

function Write-Failure {
    param([string]$Message)
    Write-Host "✗ $Message" -ForegroundColor Red
}

function Write-Info {
    param([string]$Message)
    Write-Host "ℹ $Message" -ForegroundColor Cyan
}

function Write-SectionHeader {
    param([string]$Title)
    Write-Host "`n========================================" -ForegroundColor Yellow
    Write-Host " $Title" -ForegroundColor Yellow
    Write-Host "========================================`n" -ForegroundColor Yellow
}

# Test results object
$TestResults = @{
    GitInstalled = $false
    IsGitRepo = $false
    HasRemotes = $false
    GitHubConnection = $false
    GitBookConnection = $false
    CurrentBranch = ""
    RemoteInfo = @()
}

# Start testing
Write-Host "`n🔍 Git & GitBook Connection Tester" -ForegroundColor Magenta
Write-Host "===================================`n" -ForegroundColor Magenta

# Test 1: Check if Git is installed
Write-SectionHeader "Test 1: Git Installation"
try {
    $gitVersion = git --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Git is installed: $gitVersion"
        $TestResults.GitInstalled = $true
    } else {
        Write-Failure "Git is not installed or not in PATH"
        exit 1
    }
} catch {
    Write-Failure "Git is not installed or not in PATH"
    Write-Info "Please install Git from: https://git-scm.com/downloads"
    exit 1
}

# Test 2: Verify repository path
Write-SectionHeader "Test 2: Local Repository"
if (Test-Path $RepositoryPath) {
    Write-Success "Repository path exists: $RepositoryPath"
    Set-Location $RepositoryPath
} else {
    Write-Failure "Repository path does not exist: $RepositoryPath"
    exit 1
}

# Test 3: Check if it's a Git repository
try {
    $gitStatus = git rev-parse --git-dir 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Valid Git repository detected"
        $TestResults.IsGitRepo = $true
        
        # Get current branch
        $currentBranch = git rev-parse --abbrev-ref HEAD 2>&1
        $TestResults.CurrentBranch = $currentBranch
        Write-Info "Current branch: $currentBranch"
        
        # Get repository status
        $status = git status --short
        if ($status) {
            Write-Info "Working directory has uncommitted changes"
        } else {
            Write-Success "Working directory is clean"
        }
    } else {
        Write-Failure "Not a Git repository"
        Write-Info "Initialize with: git init"
        exit 1
    }
} catch {
    Write-Failure "Error checking Git repository status"
    exit 1
}

# Test 4: Check remote repositories
Write-SectionHeader "Test 3: Remote Repositories"
try {
    $remotes = git remote -v 2>&1
    if ($LASTEXITCODE -eq 0 -and $remotes) {
        Write-Success "Remote repositories configured:"
        $remotes | ForEach-Object {
            Write-Host "  $_" -ForegroundColor Gray
            $TestResults.RemoteInfo += $_
        }
        $TestResults.HasRemotes = $true
    } else {
        Write-Failure "No remote repositories configured"
        Write-Info "Add GitHub remote: git remote add origin <github-url>"
        Write-Info "Add GitBook remote: git remote add gitbook <gitbook-url>"
    }
} catch {
    Write-Failure "Error checking remote repositories"
}

# Test 5: Test GitHub connection
Write-SectionHeader "Test 4: GitHub Connection"
$githubRemote = git remote get-url origin 2>&1
if ($LASTEXITCODE -eq 0 -and $githubRemote -match "github\.com") {
    Write-Info "GitHub remote URL: $githubRemote"
    
    # Test connection to GitHub
    Write-Info "Testing connection to GitHub..."
    try {
        $testConnection = git ls-remote origin HEAD 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Successfully connected to GitHub repository"
            $TestResults.GitHubConnection = $true
            
            # Check if local is up to date
            Write-Info "Fetching remote status..."
            git fetch origin --dry-run 2>&1 | Out-Null
            $localCommit = git rev-parse HEAD
            $remoteCommit = git rev-parse origin/$($TestResults.CurrentBranch) 2>&1
            
            if ($localCommit -eq $remoteCommit) {
                Write-Success "Local branch is up to date with remote"
            } else {
                Write-Info "Local and remote branches have diverged"
            }
        } else {
            Write-Failure "Cannot connect to GitHub repository"
            Write-Info "Error: $testConnection"
            Write-Info "Check your credentials and network connection"
        }
    } catch {
        Write-Failure "Error testing GitHub connection: $_"
    }
} else {
    Write-Info "No GitHub remote found (looking for 'origin')"
    Write-Info "Add with: git remote add origin <your-github-repo-url>"
}

# Test 6: Test GitBook connection
Write-SectionHeader "Test 5: GitBook Connection"
$gitbookRemote = git remote get-url gitbook 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Info "GitBook remote URL: $gitbookRemote"
    
    # Test connection to GitBook
    Write-Info "Testing connection to GitBook..."
    try {
        $testConnection = git ls-remote gitbook HEAD 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Successfully connected to GitBook repository"
            $TestResults.GitBookConnection = $true
        } else {
            Write-Failure "Cannot connect to GitBook repository"
            Write-Info "Error: $testConnection"
        }
    } catch {
        Write-Failure "Error testing GitBook connection: $_"
    }
} else {
    Write-Info "No GitBook remote found (looking for 'gitbook')"
    Write-Info "GitBook integration typically uses GitHub sync"
}

# Test 7: Network connectivity
Write-SectionHeader "Test 6: Network Connectivity"
Write-Info "Testing network connectivity..."

# Test GitHub.com
try {
    $githubTest = Test-Connection -ComputerName github.com -Count 1 -Quiet -ErrorAction SilentlyContinue
    if ($githubTest) {
        Write-Success "Can reach github.com"
    } else {
        Write-Failure "Cannot reach github.com"
    }
} catch {
    Write-Info "Network test for github.com failed"
}

# Test GitBook.com
try {
    $gitbookTest = Test-Connection -ComputerName gitbook.com -Count 1 -Quiet -ErrorAction SilentlyContinue
    if ($gitbookTest) {
        Write-Success "Can reach gitbook.com"
    } else {
        Write-Failure "Cannot reach gitbook.com"
    }
} catch {
    Write-Info "Network test for gitbook.com failed"
}

# Test custom GitBook space if provided
if ($GitBookSpace) {
    try {
        $response = Invoke-WebRequest -Uri $GitBookSpace -Method Head -TimeoutSec 5 -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            Write-Success "Can reach your GitBook space: $GitBookSpace"
        } else {
            Write-Info "GitBook space returned status: $($response.StatusCode)"
        }
    } catch {
        Write-Info "Could not reach GitBook space: $GitBookSpace"
    }
}

# Test 8: Check Git credentials
Write-SectionHeader "Test 7: Git Credentials"
try {
    $gitUser = git config user.name
    $gitEmail = git config user.email
    
    if ($gitUser) {
        Write-Success "Git user configured: $gitUser"
    } else {
        Write-Info "Git user not configured"
        Write-Info "Set with: git config --global user.name 'Your Name'"
    }
    
    if ($gitEmail) {
        Write-Success "Git email configured: $gitEmail"
    } else {
        Write-Info "Git email not configured"
        Write-Info "Set with: git config --global user.email 'your.email@example.com'"
    }
} catch {
    Write-Info "Error checking Git credentials"
}

# Summary
Write-SectionHeader "Summary"
Write-Host "Test Results:" -ForegroundColor Cyan
Write-Host "  Git Installed:        $(if($TestResults.GitInstalled){'✓'}else{'✗'})" -ForegroundColor $(if($TestResults.GitInstalled){'Green'}else{'Red'})
Write-Host "  Is Git Repository:    $(if($TestResults.IsGitRepo){'✓'}else{'✗'})" -ForegroundColor $(if($TestResults.IsGitRepo){'Green'}else{'Red'})
Write-Host "  Has Remotes:          $(if($TestResults.HasRemotes){'✓'}else{'✗'})" -ForegroundColor $(if($TestResults.HasRemotes){'Green'}else{'Red'})
Write-Host "  GitHub Connection:    $(if($TestResults.GitHubConnection){'✓'}else{'✗'})" -ForegroundColor $(if($TestResults.GitHubConnection){'Green'}else{'Red'})
Write-Host "  GitBook Connection:   $(if($TestResults.GitBookConnection){'✓'}else{'✗'})" -ForegroundColor $(if($TestResults.GitBookConnection){'Green'}else{'Red'})

Write-Host "`n"

# Recommendations
if (-not $TestResults.GitHubConnection) {
    Write-Host "💡 Recommendations:" -ForegroundColor Yellow
    Write-Host "  • Ensure your GitHub credentials are configured" -ForegroundColor Yellow
    Write-Host "  • Check if you need to authenticate: gh auth login" -ForegroundColor Yellow
    Write-Host "  • Verify your SSH key or Personal Access Token" -ForegroundColor Yellow
}

if (-not $TestResults.GitBookConnection -and $TestResults.HasRemotes) {
    Write-Host "💡 GitBook Integration:" -ForegroundColor Yellow
    Write-Host "  • GitBook typically syncs via GitHub integration" -ForegroundColor Yellow
    Write-Host "  • Configure at: https://app.gitbook.com > Integrations > GitHub" -ForegroundColor Yellow
}

Write-Host "`n✨ Connection test complete!`n" -ForegroundColor Magenta

# Return results for programmatic use
return $TestResults
