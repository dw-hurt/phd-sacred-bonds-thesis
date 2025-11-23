# Workflow Automation Guide

**Last Updated:** November 22, 2025

This guide explains how to use the automated PowerShell scripts to manage your dissertation workflow, update dashboards, and sync to GitBook.

---

## Quick Reference Commands

### Daily Workflow (Recommended)

```powershell
# Start interactive menu (easiest way)
.\phd-workflow.ps1
```

### Individual Commands

```powershell
# Update dashboard (calculate word counts, refresh trackers)
.\update-dashboard.ps1

# Start writing session for specific chapter (opens chapter + quotes)
.\start-writing-session.ps1 -ChapterNumber 2

# Add progress note (creates dated journal entry)
.\add-progress-note.ps1

# Sync to GitBook (commit and push all changes)
.\sync-to-gitbook.ps1
```

---

## Complete Daily Workflow

### Option 1: Using Interactive Menu (Recommended for Beginners)

```powershell
# 1. Navigate to thesis directory
cd C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis

# 2. Launch interactive menu
.\phd-workflow.ps1

# 3. Select options from menu:
#    - Option 1: Update Dashboard
#    - Option 3: Start Writing Session (choose chapter)
#    - Option 2: Add Progress Note (after writing)
#    - Option 4: Sync to GitBook (push changes)
```

### Option 2: Using Individual Commands (Recommended for Advanced Users)

```powershell
# 1. Navigate to thesis directory
cd C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis

# 2. Pull latest changes from GitHub (start of day)
git pull origin main

# 3. Start writing session
.\start-writing-session.ps1 -ChapterNumber 2

# 4. Write! (files open in notepad automatically)
#    - Chapter file: Main writing
#    - Quote database: Reference quotes
#    Save frequently (Ctrl+S)

# 5. Update dashboard (after writing)
.\update-dashboard.ps1

# 6. Add progress note (document what you did)
.\add-progress-note.ps1

# 7. Sync everything to GitBook
.\sync-to-gitbook.ps1

# 8. View updated GitBook (wait 1-2 minutes after sync)
#    https://your-gitbook-url.com
```

---

## Detailed Command Explanations

### 1. Update Dashboard (`update-dashboard.ps1`)

**Purpose:** Automatically calculates word counts for all chapters and updates progress trackers.

**Usage:**
```powershell
.\update-dashboard.ps1
```

**What it does:**
- Scans all 10 chapter files in `chapters/` directory
- Calculates word count for each chapter (removes markdown syntax for accuracy)
- Updates `project_management/progress_tracker.md` with current stats
- Shows total word count and progress toward 70,000-word goal
- Displays chapter-by-chapter breakdown

**When to run:**
- After every writing session
- Daily to track progress
- Before syncing to GitBook

**Output Example:**
```
Dashboard Update
  Chapter 1 : 10285 words
  Chapter 2 : 1500 words
  Chapter 3 : 0 words
  ...
  Total: 11785 words
Done! 11785 words
```

**What gets updated:**
- `project_management/progress_tracker.md` - Full progress table with percentages

---

### 2. Start Writing Session (`start-writing-session.ps1`)

**Purpose:** Opens chapter file with related resources for efficient writing.

**Usage:**
```powershell
# Write Chapter 2
.\start-writing-session.ps1 -ChapterNumber 2

# Write Chapter 5
.\start-writing-session.ps1 -ChapterNumber 5

# Use different editor (VS Code)
.\start-writing-session.ps1 -ChapterNumber 2 -Editor code
```

**Parameters:**
- `-ChapterNumber` (required): Chapter to work on (1-10)
- `-Editor` (optional): Editor to use
  - `notepad` (default)
  - `code` (Visual Studio Code)
  - `"C:\Program Files\Notepad++\notepad++.exe"` (Notepad++)

**What it opens:**
1. **Chapter markdown file** - Your main writing file
2. **Quote database** - Chapter-specific quotes for reference
3. Both files open in separate windows for easy reference

**Writing tips:**
- Save frequently (Ctrl+S every few minutes)
- Reference quotes using format: `[Author Year, p.XX]`
- Write in 500-1000 word chunks
- Don't worry about perfection in first draft
- Run `update-dashboard.ps1` when done to see progress

---

### 3. Add Progress Note (`add-progress-note.ps1`)

**Purpose:** Creates dated journal entry to document your work and insights.

**Usage:**
```powershell
# Create today's progress note
.\add-progress-note.ps1

# Create note with custom title
.\add-progress-note.ps1 -Title "Chapter2_Breakthrough"
```

**Parameters:**
- `-Title` (optional): Custom title for the note
- `-Editor` (optional): Editor to use (default: notepad)

**What it creates:**
- File location: `research_journal/daily/YYYY-MM-DD_[title].md`
- Pre-filled template with sections:
  - What I accomplished today
  - Key insights
  - Challenges/blockers
  - Next steps

**When to use:**
- End of each writing session
- After important insights or breakthroughs
- Before advisor meetings (to prepare questions)
- Weekly to reflect on progress

**Benefits:**
- Track your thinking over time
- Document important decisions
- Remember what you were working on
- Prepare for advisor meetings
- Build content for acknowledgements section

---

### 4. Sync to GitBook (`sync-to-gitbook.ps1`)

**Purpose:** One-command commit and push all changes to GitHub/GitBook.

**Usage:**
```powershell
# Sync with prompt for message
.\sync-to-gitbook.ps1

# Sync with custom message
.\sync-to-gitbook.ps1 -Message "Complete Chapter 2 Section 2.1 draft"
```

**What it does:**
1. Checks for changed files
2. Shows what will be committed
3. Prompts for commit message (or uses auto-generated timestamp)
4. Stages all changes (`git add -A`)
5. Commits with your message
6. Pushes to GitHub (`git push origin main`)
7. Confirms GitBook will sync in 1-2 minutes

**When to run:**
- After writing session
- After updating dashboard
- After adding progress notes
- End of day
- Before closing laptop

**If sync fails:**
```powershell
# Pull latest changes first
git pull origin main

# Resolve any conflicts, then try again
.\sync-to-gitbook.ps1
```

---

### 5. PhD Workflow Menu (`phd-workflow.ps1`)

**Purpose:** Interactive menu for all workflow tasks.

**Usage:**
```powershell
.\phd-workflow.ps1
```

**Menu Options:**
```
PhD Workflow

1. Update Dashboard        → Runs update-dashboard.ps1
2. Progress Note          → Runs add-progress-note.ps1
3. Start Writing          → Prompts for chapter, runs start-writing-session.ps1
4. Sync GitBook           → Runs sync-to-gitbook.ps1
5. Git Status             → Shows git status and recent commits
0. Exit                   → Closes menu
```

**Benefits:**
- No need to remember command syntax
- Guided workflow
- Perfect for daily routine
- Quick access to all tools

---

## Typical Writing Session Workflow

### Morning Session (2-3 hours)

```powershell
# 1. Start in thesis directory
cd C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis

# 2. Pull latest (if working from multiple computers)
git pull origin main

# 3. Check current progress
.\update-dashboard.ps1

# 4. Start writing
.\start-writing-session.ps1 -ChapterNumber 2

# 5. Write for 2-3 hours (save frequently!)

# 6. Update dashboard to see new word count
.\update-dashboard.ps1

# 7. Document your work
.\add-progress-note.ps1

# 8. Sync everything
.\sync-to-gitbook.ps1 -Message "Chapter 2: Added 800 words on Strategic Pluralism Theory"
```

---

## Dashboard Files Explained

### Files Automatically Updated

**1. `project_management/progress_tracker.md`**
- Updated by: `update-dashboard.ps1`
- Contains: Overall progress, chapter breakdown, milestone tracking
- View in GitBook: Project Management → Progress Tracker

**What's tracked:**
- Total word count vs 70,000 goal
- Per-chapter word counts vs targets
- Progress percentages
- Milestone completion (Stage 1-4)
- Last updated timestamp

### Files You Manually Update

**1. `project_management/chapter_tracker.md`**
- Update manually as you work
- Track: Section status, blockers, dependencies
- More detailed than progress_tracker.md

**2. `research_journal/daily/*.md`**
- Created by: `add-progress-note.ps1`
- Your daily reflections and progress notes

---

## Troubleshooting

### "Script cannot be loaded" Error

**Solution:**
```powershell
# Run PowerShell as Administrator, then:
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Word Counts Not Updating

**Check:**
```powershell
# 1. Verify you're in correct directory
cd C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis

# 2. Check chapter files exist
Get-ChildItem chapters\*\*.md

# 3. Run dashboard update
.\update-dashboard.ps1
```

### Sync Fails with "Push Failed"

**Solution:**
```powershell
# Pull latest changes first
git pull origin main

# If there are conflicts, resolve them, then:
git add -A
git commit -m "Resolve merge conflicts"
git push origin main
```

### GitBook Not Updating

**Check:**
1. Wait 1-2 minutes after push (GitBook sync delay)
2. Verify push succeeded: `git log -1 --oneline`
3. Check GitBook sync status in GitBook web interface
4. Refresh GitBook page (Ctrl+F5)

---

## Tips for Maximum Productivity

### 1. Start Each Day with Dashboard Update
```powershell
.\update-dashboard.ps1
```
- See yesterday's progress
- Motivates continued work
- Identifies gaps

### 2. Use Writing Sessions Instead of Manual File Opening
```powershell
.\start-writing-session.ps1 -ChapterNumber 2
```
- Automatic quote database access
- Consistent workflow
- Saves time

### 3. Document Everything in Progress Notes
```powershell
.\add-progress-note.ps1
```
- Future-you will thank you
- Builds your research narrative
- Useful for acknowledgements section

### 4. Sync Multiple Times Per Day
```powershell
.\sync-to-gitbook.ps1
```
- Never lose work
- Track incremental progress
- Easy to revert if needed

### 5. Review GitBook Weekly
- See your work in polished format
- Catch formatting issues
- Review overall structure
- Share with advisor

---

## Advanced Usage

### Custom Editor Configuration

Edit scripts to change default editor:

```powershell
# Open start-writing-session.ps1
notepad start-writing-session.ps1

# Find this line:
[string]$Editor="notepad"

# Change to:
[string]$Editor="code"  # VS Code
# Or:
[string]$Editor="C:\Program Files\Notepad++\notepad++.exe"
```

### Batch Operations

```powershell
# Update dashboard and sync in one go
.\update-dashboard.ps1; .\sync-to-gitbook.ps1

# Start writing and update dashboard after (manual write between)
.\start-writing-session.ps1 -ChapterNumber 2
# [Write here]
.\update-dashboard.ps1

# Quick commit of specific changes
git add project_management/
git commit -m "Update trackers"
git push origin main
```

### Check Progress Without Running Full Update

```powershell
# Quick word count for one chapter
Get-Content chapters\02_evolutionary_foundations\*.md | Measure-Object -Word

# Total words across all chapters
Get-ChildItem chapters\*\*.md | Get-Content | Measure-Object -Word
```

---

## Support and Documentation

**Script Locations:**
- All scripts in repository root: `C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis\*.ps1`

**Generated Files:**
- Dashboard: `project_management/progress_tracker.md`
- Progress notes: `research_journal/daily/YYYY-MM-DD_*.md`

**For Help:**
```powershell
# View script contents
Get-Content update-dashboard.ps1
Get-Content start-writing-session.ps1

# Check git status
git status
git log --oneline -10
```

---

## Summary: Essential Commands

```powershell
# Everything you need for daily workflow:

cd C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis  # Navigate
.\phd-workflow.ps1                                       # Interactive menu

# Or individual commands:
.\update-dashboard.ps1                                   # Update progress
.\start-writing-session.ps1 -ChapterNumber 2            # Write
.\add-progress-note.ps1                                  # Journal
.\sync-to-gitbook.ps1                                    # Sync
```

**Remember:** The automation is here to help you focus on writing, not on managing files. Use the tools daily and your dissertation will progress steadily! 📝🎓