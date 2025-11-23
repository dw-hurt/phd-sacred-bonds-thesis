# ============================================================================
# add-todo.ps1
# PhD Project ToDo List Manager
# ============================================================================

param(
    [Parameter(Mandatory=$false)]
    [string]$Action = "show",
    
    [Parameter(Mandatory=$false)]
    [string]$Task = "",
    
    [Parameter(Mandatory=$false)]
    [string]$Priority = "medium",
    
    [Parameter(Mandatory=$false)]
    [string]$Category = "General"
)

# Repository base path (hardcoded)
$RepoPath = "C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis"
$TodoFile = Join-Path $RepoPath "project_management\todo.md"

# ============================================================================
# Initialize ToDo File
# ============================================================================
function Initialize-TodoFile {
    if (-not (Test-Path $TodoFile)) {
        $initContent = @"
# PhD Project ToDo List

## Legend
- 🔴 High Priority
- 🟡 Medium Priority
- 🟢 Low Priority
- ✅ Completed
- ⏳ In Progress

---

## High Priority Tasks


## Medium Priority Tasks


## Low Priority Tasks


## Completed Tasks


---

*Last Updated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')*
"@
        Set-Content -Path $TodoFile -Value $initContent -Encoding UTF8
        Write-Host "✅ Initialized todo.md at: $TodoFile" -ForegroundColor Green
    } else {
        Write-Host "ℹ️  Todo file already exists at: $TodoFile" -ForegroundColor Cyan
    }
}

# ============================================================================
# Add New Task
# ============================================================================
function Add-Task {
    param($TaskText, $PriorityLevel, $CategoryTag)
    
    if ([string]::IsNullOrWhiteSpace($TaskText)) {
        Write-Host "❌ Error: Task text cannot be empty" -ForegroundColor Red
        return
    }
    
    $content = Get-Content $TodoFile -Raw
    
    # Determine emoji and section
    $emoji = switch ($PriorityLevel.ToLower()) {
        "high"   { "🔴" }
        "medium" { "🟡" }
        "low"    { "🟢" }
        default  { "🟡" }
    }
    
    $sectionHeader = switch ($PriorityLevel.ToLower()) {
        "high"   { "## High Priority Tasks" }
        "medium" { "## Medium Priority Tasks" }
        "low"    { "## Low Priority Tasks" }
        default  { "## Medium Priority Tasks" }
    }
    
    $timestamp = Get-Date -Format "yyyy-MM-dd"
    $newTask = "- $emoji **[$CategoryTag]** $TaskText *(Added: $timestamp)*"
    
    # Insert after section header
    $content = $content -replace "($sectionHeader`r?`n)", "`$1$newTask`n"
    
    # Update timestamp
    $content = $content -replace "\*Last Updated:.*\*", "*Last Updated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')*"
    
    Set-Content -Path $TodoFile -Value $content -Encoding UTF8
    Write-Host "✅ Added task: $TaskText" -ForegroundColor Green
}

# ============================================================================
# Complete Task - FIXED VERSION
# ============================================================================
function Complete-Task {
    param($TaskPattern)
    
    if ([string]::IsNullOrWhiteSpace($TaskPattern)) {
        Write-Host "❌ Error: Task search pattern cannot be empty" -ForegroundColor Red
        return
    }
    
    $lines = Get-Content $TodoFile
    $found = $false
    $matchedLine = ""
    $matchedIndex = -1
    
    # Simple string search (case-insensitive)
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -like "*$TaskPattern*" -and $lines[$i] -match "^- [🔴🟡🟢]") {
            $matchedLine = $lines[$i]
            $matchedIndex = $i
            $found = $true
            break
        }
    }
    
    if ($found) {
        # Create completed version
        $completedTask = $matchedLine -replace "^- [🔴🟡🟢]", "- ✅"
        $completedTask += " *(Completed: $(Get-Date -Format 'yyyy-MM-dd'))*"
        
        # Remove original line
        $lines[$matchedIndex] = ""
        
        # Find Completed Tasks section and add there
        $completedIndex = -1
        for ($i = 0; $i -lt $lines.Count; $i++) {
            if ($lines[$i] -eq "## Completed Tasks") {
                $completedIndex = $i + 1
                break
            }
        }
        
        if ($completedIndex -gt 0) {
            $lines[$completedIndex] = $completedTask + "`n" + $lines[$completedIndex]
        }
        
        # Update timestamp
        for ($i = 0; $i -lt $lines.Count; $i++) {
            if ($lines[$i] -match "\*Last Updated:") {
                $lines[$i] = "*Last Updated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')*"
                break
            }
        }
        
        # Save back
        $lines | Where-Object { $_ -ne "" -or $_ -eq $null } | Set-Content -Path $TodoFile -Encoding UTF8
        
        Write-Host "✅ Completed task matching: $TaskPattern" -ForegroundColor Green
    } else {
        Write-Host "❌ Task not found matching: $TaskPattern" -ForegroundColor Red
        Write-Host "💡 Try using a shorter search term from your task text" -ForegroundColor Yellow
    }
}

# ============================================================================
# Remove Task - FIXED VERSION
# ============================================================================
function Remove-Task {
    param($TaskPattern)
    
    if ([string]::IsNullOrWhiteSpace($TaskPattern)) {
        Write-Host "❌ Error: Task search pattern cannot be empty" -ForegroundColor Red
        return
    }
    
    $lines = Get-Content $TodoFile
    $found = $false
    $matchedIndex = -1
    
    # Simple string search (case-insensitive)
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -like "*$TaskPattern*" -and $lines[$i] -match "^- [🔴🟡🟢✅]") {
            $matchedIndex = $i
            $found = $true
            break
        }
    }
    
    if ($found) {
        # Remove the line
        $lines[$matchedIndex] = ""
        
        # Update timestamp
        for ($i = 0; $i -lt $lines.Count; $i++) {
            if ($lines[$i] -match "\*Last Updated:") {
                $lines[$i] = "*Last Updated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')*"
                break
            }
        }
        
        # Save back (filter out empty line)
        $lines | Where-Object { $_ -ne "" -or $_ -eq $null } | Set-Content -Path $TodoFile -Encoding UTF8
        
        Write-Host "✅ Removed task matching: $TaskPattern" -ForegroundColor Green
    } else {
        Write-Host "❌ Task not found matching: $TaskPattern" -ForegroundColor Red
    }
}

# ============================================================================
# Show ToDo List
# ============================================================================
function Show-TodoList {
    if (Test-Path $TodoFile) {
        Write-Host "`n" -NoNewline
        Get-Content $TodoFile | Write-Host
        Write-Host "`n📁 File location: $TodoFile`n" -ForegroundColor Cyan
    } else {
        Write-Host "❌ Todo file not found. Run with -Action init to create it." -ForegroundColor Red
    }
}

# ============================================================================
# Main Execution
# ============================================================================

switch ($Action.ToLower()) {
    "init" {
        Initialize-TodoFile
    }
    "add" {
        if (-not (Test-Path $TodoFile)) {
            Write-Host "❌ Todo file not found. Initializing..." -ForegroundColor Yellow
            Initialize-TodoFile
        }
        Add-Task -TaskText $Task -PriorityLevel $Priority -CategoryTag $Category
    }
    "complete" {
        Complete-Task -TaskPattern $Task
    }
    "remove" {
        Remove-Task -TaskPattern $Task
    }
    "show" {
        Show-TodoList
    }
    default {
        Write-Host "❌ Invalid action: $Action" -ForegroundColor Red
        Write-Host "Valid actions: init, add, complete, remove, show" -ForegroundColor Yellow
    }
}
