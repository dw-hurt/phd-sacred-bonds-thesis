# ============================================================================
# phd-master.ps1
# PhD Dissertation Automation Master Controller
# ============================================================================

$RepoPath = "C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis"
$ScriptsPath = Join-Path $RepoPath "project_management\scripts"

function Show-Banner {
    Clear-Host
    Write-Host ""
    Write-Host "  ================================================================" -ForegroundColor Cyan
    Write-Host "  ||     PhD DISSERTATION AUTOMATION MASTER CONTROL             ||" -ForegroundColor Cyan
    Write-Host "  ||       Sacred Bonds: Marriage and Modernization             ||" -ForegroundColor Cyan
    Write-Host "  ================================================================" -ForegroundColor Cyan
    Write-Host ""
}

function Show-Menu {
    Write-Host "  TASK MANAGEMENT" -ForegroundColor Yellow
    Write-Host "    1. View ToDo List" -ForegroundColor White
    Write-Host "    2. Add New Task" -ForegroundColor White
    Write-Host "    3. Complete Task" -ForegroundColor White
    Write-Host "    4. Remove Task" -ForegroundColor White
    Write-Host ""
    Write-Host "  PROGRESS TRACKING" -ForegroundColor Yellow
    Write-Host "    5. View Dashboard" -ForegroundColor White
    Write-Host "    6. Update Dashboard Statistics" -ForegroundColor White
    Write-Host ""
    Write-Host "  WRITING AND SUBMISSION" -ForegroundColor Yellow
    Write-Host "    7. Submit Writing for Review" -ForegroundColor White
    Write-Host "    8. View Submission History" -ForegroundColor White
    Write-Host ""
    Write-Host "  BACKUP AND ARCHIVE" -ForegroundColor Yellow
    Write-Host "    9. Create Archive Snapshot" -ForegroundColor White
    Write-Host "   10. View Archive Index" -ForegroundColor White
    Write-Host ""
    Write-Host "  SYSTEM AND GIT" -ForegroundColor Yellow
    Write-Host "   11. Git Status" -ForegroundColor White
    Write-Host "   12. Commit and Push Changes" -ForegroundColor White
    Write-Host "   13. Open Repository Folder" -ForegroundColor White
    Write-Host ""
    Write-Host "  HELP AND EXIT" -ForegroundColor Yellow
    Write-Host "   14. Show Help" -ForegroundColor White
    Write-Host "    0. Exit" -ForegroundColor White
    Write-Host ""
    Write-Host "  ----------------------------------------------------------" -ForegroundColor Gray
}

function Invoke-TodoList {
    Push-Location $ScriptsPath
    .\add-todo.ps1 -Action show
    Pop-Location
    Read-Host "`nPress Enter to continue"
}

function Invoke-AddTask {
    Push-Location $ScriptsPath
    $task = Read-Host "`nEnter task description"
    $priority = Read-Host "Priority: (h)igh, (m)edium, (l)ow [m]"
    if ([string]::IsNullOrWhiteSpace($priority)) { $priority = "medium" }
    elseif ($priority -eq "h") { $priority = "high" }
    elseif ($priority -eq "l") { $priority = "low" }
    else { $priority = "medium" }
    
    $cat = Read-Host "Category: (R)eading, (W)riting, (Re)search, (A)dmin [General]"
    $category = "General"
    if ($cat -eq "R") { $category = "Reading" }
    elseif ($cat -eq "W") { $category = "Writing" }
    elseif ($cat -eq "Re") { $category = "Research" }
    elseif ($cat -eq "A") { $category = "Admin" }
    
    .\add-todo.ps1 -Action add -Task $task -Priority $priority -Category $category
    Pop-Location
    Read-Host "`nPress Enter to continue"
}

function Invoke-CompleteTask {
    Push-Location $ScriptsPath
    .\add-todo.ps1 -Action show
    $pattern = Read-Host "`nEnter text to match task"
    .\add-todo.ps1 -Action complete -Task $pattern
    Pop-Location
    Read-Host "`nPress Enter to continue"
}

function Invoke-RemoveTask {
    Push-Location $ScriptsPath
    .\add-todo.ps1 -Action show
    $pattern = Read-Host "`nEnter text to match task to remove"
    .\add-todo.ps1 -Action remove -Task $pattern
    Pop-Location
    Read-Host "`nPress Enter to continue"
}

function Invoke-ViewDashboard {
    $dashboardFile = Join-Path $RepoPath "project_management\dashboard.md"
    if (Test-Path $dashboardFile) {
        Get-Content $dashboardFile | Write-Host
    } else {
        Write-Host "`nDashboard not found. Run option 6 first." -ForegroundColor Yellow
    }
    Read-Host "`nPress Enter to continue"
}

function Invoke-UpdateDashboard {
    Push-Location $ScriptsPath
    .\update-dashboard.ps1
    Pop-Location
    Read-Host "`nPress Enter to continue"
}

function Invoke-SubmitWriting {
    Push-Location $ScriptsPath
    .\submit-writing.ps1
    Pop-Location
    Read-Host "`nPress Enter to continue"
}

function Invoke-ViewSubmissions {
    $submissionsIndex = Join-Path $RepoPath "writing_submissions\submissions_index.md"
    if (Test-Path $submissionsIndex) {
        Get-Content $submissionsIndex | Write-Host
    } else {
        Write-Host "`nNo submissions yet. Use option 7 first." -ForegroundColor Yellow
    }
    Read-Host "`nPress Enter to continue"
}

function Invoke-CreateArchive {
    Push-Location $ScriptsPath
    $desc = Read-Host "`nEnter snapshot description"
    if ([string]::IsNullOrWhiteSpace($desc)) { $desc = "Manual snapshot" }
    .\archive-snapshot.ps1 -Description $desc
    Pop-Location
    Read-Host "`nPress Enter to continue"
}

function Invoke-ViewArchive {
    $archiveIndex = Join-Path $RepoPath "archive\archive_index.md"
    if (Test-Path $archiveIndex) {
        Get-Content $archiveIndex | Write-Host
    } else {
        Write-Host "`nNo archives yet. Use option 9 first." -ForegroundColor Yellow
    }
    Read-Host "`nPress Enter to continue"
}

function Invoke-GitStatus {
    Push-Location $RepoPath
    Write-Host "`nGit Status:" -ForegroundColor Cyan
    git status
    Pop-Location
    Read-Host "`nPress Enter to continue"
}

function Invoke-GitCommit {
    Push-Location $RepoPath
    Write-Host "`nCurrent Status:" -ForegroundColor Cyan
    git status --short
    $message = Read-Host "`nEnter commit message"
    
    if ([string]::IsNullOrWhiteSpace($message)) {
        Write-Host "Commit cancelled." -ForegroundColor Yellow
    } else {
        git add .
        git commit -m $message
        
        $push = Read-Host "`nPush to remote? (y/n) [y]"
        if ($push -ne "n") {
            git push
            Write-Host "`nChanges pushed." -ForegroundColor Green
        }
    }
    Pop-Location
    Read-Host "`nPress Enter to continue"
}

function Invoke-OpenFolder {
    Start-Process explorer.exe $RepoPath
    Write-Host "`nOpened repository folder." -ForegroundColor Green
    Start-Sleep -Seconds 1
}

function Show-Help {
    Write-Host "`nPhD AUTOMATION SCRIPTS HELP" -ForegroundColor Cyan
    Write-Host "============================================================" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Script 1: add-todo.ps1 - Task management" -ForegroundColor Yellow
    Write-Host "Script 2: update-dashboard.ps1 - Progress tracking" -ForegroundColor Yellow
    Write-Host "Script 3: archive-snapshot.ps1 - Repository backups" -ForegroundColor Yellow
    Write-Host "Script 4: submit-writing.ps1 - Writing submissions" -ForegroundColor Yellow
    Write-Host "Script 5: phd-master.ps1 - Master controller (this)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Repository: $RepoPath" -ForegroundColor Gray
    Write-Host ""
    Read-Host "Press Enter to continue"
}

while ($true) {
    Show-Banner
    
    $todoFile = Join-Path $RepoPath "project_management\todo.md"
    if (Test-Path $todoFile) {
        $todoContent = Get-Content $todoFile
        $activeTasks = ($todoContent | Select-String "^- \[").Count
        Write-Host "  Quick Stats: $activeTasks active tasks" -ForegroundColor Gray
        Write-Host ""
    }
    
    Show-Menu
    
    $choice = Read-Host "  Enter choice (0-14)"
    
    switch ($choice) {
        "1"  { Invoke-TodoList }
        "2"  { Invoke-AddTask }
        "3"  { Invoke-CompleteTask }
        "4"  { Invoke-RemoveTask }
        "5"  { Invoke-ViewDashboard }
        "6"  { Invoke-UpdateDashboard }
        "7"  { Invoke-SubmitWriting }
        "8"  { Invoke-ViewSubmissions }
        "9"  { Invoke-CreateArchive }
        "10" { Invoke-ViewArchive }
        "11" { Invoke-GitStatus }
        "12" { Invoke-GitCommit }
        "13" { Invoke-OpenFolder }
        "14" { Show-Help }
        "0"  { 
            Write-Host "`n  Goodbye! Happy writing!" -ForegroundColor Green
            Write-Host ""
            exit 
        }
        default { 
            Write-Host "`n  Invalid choice. Please enter 0-14." -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
}
