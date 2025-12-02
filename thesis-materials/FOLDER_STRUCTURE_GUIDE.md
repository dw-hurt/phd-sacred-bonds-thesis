# Sacred Bonds Thesis - Folder Structure Guide

## ✅ Updated Folder Configuration

All PowerShell scripts have been updated to use the correct folder on your laptop.

---

## 📁 Your Laptop Folder Structure

```
C:\Users\user\Documents\PhD\
└── phd-sacred-bonds-thesis\
    ├── thesis-materials\              ← 📥 DOWNLOAD ALL FILES HERE
    │   ├── Push-To-Sacred-Bonds-Thesis.ps1
    │   ├── Sync-To-Sacred-Bonds-GitBook.ps1
    │   ├── QUICK_START_GUIDE.md
    │   ├── README_SACRED_BONDS_AUTOMATION.md
    │   ├── Buss_Mens_Mating_Strategies_Summary.md
    │   ├── Buss_Key_Quotes.md
    │   ├── Bibliography_Buss_Evolutionary_Psychology.md
    │   ├── Buss_Mens_Mating_Integration_Guide.md
    │   └── Buss_Comparative_Analysis.md
    │
    ├── .git\                          ← Created by script
    ├── .gitignore                     ← Created by script
    ├── .gitbook.yaml                  ← Created by script
    ├── README.md                      ← Created by script
    ├── SUMMARY.md                     ← Created by script
    ├── INTEGRATION_REPORT.md          ← Created by script
    ├── GITBOOK_CHECKLIST.md           ← Created by script
    │
    ├── Literature-Review\             ← Created by script
    │   ├── INDEX.md
    │   ├── 01-Sacred-Traditions\
    │   ├── 02-Evolutionary-Psychology\
    │   │   ├── README.md
    │   │   └── Mens-Long-Term-Mating\
    │   │       └── Buss_Mens_Long_Term_Mating_Strategies.md ✓
    │   ├── 03-Attachment-Theory\
    │   └── 04-Neuroscience-of-Bonding\
    │
    ├── Bibliography\                  ← Created by script
    │   ├── README.md
    │   ├── Primary-Sources\
    │   │   ├── README.md
    │   │   └── Buss_Evolutionary_Psychology_Handbook.md ✓
    │   └── Secondary-Sources\
    │
    ├── Resources\                     ← Created by script
    │   ├── README.md
    │   └── Key-Quotes\
    │       ├── README.md
    │       └── Evolutionary-Psychology\
    │           └── Buss_Quotes_Mate_Preferences.md ✓
    │
    ├── Research-Notes\                ← Created by script
    │   ├── README.md
    │   ├── Integration-Guides\
    │   │   ├── README.md
    │   │   └── Buss_Integration_Sacred_Bonds.md ✓
    │   └── Synthesis-Documents\
    │
    ├── Analysis\                      ← Created by script
    │   ├── README.md
    │   ├── Theoretical-Frameworks\
    │   │   ├── README.md
    │   │   └── Evolutionary-vs-Social\
    │   │       └── Buss_Comparative_Framework_Analysis.md ✓
    │   └── Case-Studies\
    │
    ├── Chapters\                      ← Created by script
    │   ├── README.md
    │   ├── Chapter-01-Introduction\
    │   ├── Chapter-02-Theoretical-Foundations\
    │   ├── Chapter-03-Sacred-Traditions\
    │   ├── Chapter-04-Evolutionary-Perspectives\
    │   └── Chapter-05-Synthesis\
    │
    └── Appendices\                    ← Created by script
        └── README.md
```

---

## 🎯 Script Default Paths (Updated)

### Push-To-Sacred-Bonds-Thesis.ps1
- **Source Directory**: `C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis\thesis-materials`
- **Thesis Repo Path**: `C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis`
- **GitHub Remote**: `https://github.com/dw-hurt/phd-sacred-bonds-thesis.git`
- **Branch**: `main`

### Sync-To-Sacred-Bonds-GitBook.ps1
- **Thesis Repo Path**: `C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis`
- **Branch**: `main`

---

## 📋 Step-by-Step Setup

### Step 1: Create Folder Structure
```powershell
# Create main thesis folder (if it doesn't exist)
mkdir C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis -Force

# Create thesis-materials subfolder
mkdir C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis\thesis-materials -Force
```

### Step 2: Download Files
Download all 9 files from chat and save to:
```
C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis\thesis-materials\
```

**Files to download:**
1. ✅ Push-To-Sacred-Bonds-Thesis.ps1
2. ✅ Sync-To-Sacred-Bonds-GitBook.ps1
3. ✅ QUICK_START_GUIDE.md
4. ✅ README_SACRED_BONDS_AUTOMATION.md
5. ✅ Buss_Mens_Mating_Strategies_Summary.md
6. ✅ Buss_Key_Quotes.md
7. ✅ Bibliography_Buss_Evolutionary_Psychology.md
8. ✅ Buss_Mens_Mating_Integration_Guide.md
9. ✅ Buss_Comparative_Analysis.md

### Step 3: Create GitHub Repository
1. Go to: https://github.com/new
2. Repository name: `phd-sacred-bonds-thesis`
3. Visibility: **Private**
4. **Do NOT** check "Initialize this repository with a README"
5. Click "Create repository"

### Step 4: Run Upload Script
```powershell
# Navigate to thesis-materials folder
cd C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis\thesis-materials

# Optional: Preview what will happen
.\Push-To-Sacred-Bonds-Thesis.ps1 -DryRun

# Execute upload
.\Push-To-Sacred-Bonds-Thesis.ps1
```

**The script will automatically:**
- ✅ Create all thesis folders in `C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis`
- ✅ Copy 5 research files to correct locations
- ✅ Generate README.md, SUMMARY.md, etc.
- ✅ Initialize Git repository
- ✅ Commit and push to GitHub

### Step 5: Prepare for GitBook
```powershell
# Navigate to thesis repository root
cd C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis

# Create section READMEs and update navigation
.\Sync-To-Sacred-Bonds-GitBook.ps1 -CreateMissingREADMEs -UpdateNavigation
```

### Step 6: Set Up GitBook
1. Go to: https://gitbook.com
2. Sign in with GitHub
3. Create new space: "Sacred Bonds PhD Thesis"
4. Settings → Integrations → GitHub
5. Connect repository: `dw-hurt/phd-sacred-bonds-thesis`
6. Branch: `main`
7. Enable bi-directional sync

---

## 🔍 Verification Commands

### Check Folder Exists
```powershell
Test-Path "C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis"
# Should return: True

Test-Path "C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis\thesis-materials"
# Should return: True
```

### List Downloaded Files
```powershell
Get-ChildItem "C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis\thesis-materials"
# Should show 9 files
```

### Check Git Status (After Upload)
```powershell
cd C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis
git status
# Should show: "nothing to commit, working tree clean"

git log --oneline -3
# Should show recent commits
```

### Verify Repository Structure (After Upload)
```powershell
cd C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis

# List main directories
Get-ChildItem -Directory

# Should show:
# - Literature-Review
# - Bibliography
# - Resources
# - Research-Notes
# - Analysis
# - Chapters
# - Appendices
# - thesis-materials
```

### Verify Research Files (After Upload)
```powershell
# Check Buss summary exists
Test-Path "Literature-Review\02-Evolutionary-Psychology\Mens-Long-Term-Mating\Buss_Mens_Long_Term_Mating_Strategies.md"
# Should return: True

# Check bibliography exists
Test-Path "Bibliography\Primary-Sources\Buss_Evolutionary_Psychology_Handbook.md"
# Should return: True

# Check quotes exist
Test-Path "Resources\Key-Quotes\Evolutionary-Psychology\Buss_Quotes_Mate_Preferences.md"
# Should return: True
```

---

## ⚠️ Important Notes

### Do NOT Use These Old Paths
❌ `C:\Users\user\Documents\GitHub\thesis-materials` (OLD - WRONG)
❌ `C:\Users\user\Documents\GitHub\phd-sacred-bonds-thesis` (OLD - WRONG)

### Use These New Paths
✅ `C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis` (THESIS ROOT)
✅ `C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis\thesis-materials` (SOURCE FILES)

### Scripts Are Pre-Configured
- ✅ All scripts use the correct paths by default
- ✅ No need to modify parameters unless using custom locations
- ✅ Just run: `.\Push-To-Sacred-Bonds-Thesis.ps1`

### Folder Will Be Empty Initially
The thesis folder (`phd-sacred-bonds-thesis`) should be **empty** or **non-existent** before running the script. The script will:
1. Create the folder if needed
2. Initialize Git repository
3. Create all subdirectories
4. Copy research files
5. Generate configuration files
6. Push to GitHub

---

## 🚨 Troubleshooting

### Issue: "Path not found"
```powershell
# Create the folders manually
mkdir C:\Users\user\Documents\PhD -Force
mkdir C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis -Force
mkdir C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis\thesis-materials -Force
```

### Issue: "Cannot find file"
- ✅ Verify you downloaded all 9 files
- ✅ Check they're in `thesis-materials` folder
- ✅ Check file names match exactly (including extensions)

### Issue: "Git not recognized"
- ✅ Install Git: https://git-scm.com/download/win
- ✅ Restart PowerShell after installation
- ✅ Verify: `git --version`

### Issue: "Execution policy restricted"
```powershell
# Allow script execution
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# Verify
Get-ExecutionPolicy
# Should show: RemoteSigned
```

### Issue: Script uses wrong path
If the script somehow uses the old path, you can override it:
```powershell
.\Push-To-Sacred-Bonds-Thesis.ps1 `
    -SourceDirectory "C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis\thesis-materials" `
    -ThesisRepoPath "C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis"
```

---

## 📊 What Each Script Does

### Push-To-Sacred-Bonds-Thesis.ps1
**Input**: 5 markdown files in `thesis-materials\`  
**Output**: Organized thesis structure with files in correct locations  
**Action**: Uploads to GitHub at `dw-hurt/phd-sacred-bonds-thesis`

**Creates:**
- 15+ organized folders
- README.md (thesis overview)
- SUMMARY.md (GitBook navigation)
- .gitbook.yaml (GitBook config)
- Literature-Review/INDEX.md
- INTEGRATION_REPORT.md

### Sync-To-Sacred-Bonds-GitBook.ps1
**Input**: Existing thesis structure  
**Output**: GitBook-ready configuration  
**Action**: Prepares for GitBook publishing

**Creates:**
- Section README.md files (5)
- Updated SUMMARY.md
- GITBOOK_CHECKLIST.md
- Overview files for empty sections

---

## ✅ Quick Reference

### Navigate to Folders
```powershell
# Thesis root (where Git repo lives)
cd C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis

# Source files (where you download scripts and markdown)
cd C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis\thesis-materials
```

### Run Scripts
```powershell
# From thesis-materials folder
cd C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis\thesis-materials
.\Push-To-Sacred-Bonds-Thesis.ps1

# From thesis root
cd C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis
.\Sync-To-Sacred-Bonds-GitBook.ps1 -CreateMissingREADMEs -UpdateNavigation
```

### Check Status
```powershell
cd C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis
git status
git log --oneline -5
```

---

**Document Version**: 2.0 (Updated for PhD folder)  
**Last Updated**: 2025-12-02  
**Path Update**: Scripts now use `C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis`
