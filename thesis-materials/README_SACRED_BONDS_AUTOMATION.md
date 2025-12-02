# Sacred Bonds PhD Thesis - Automation User Guide

## Overview

This automation suite manages your **Sacred Bonds PhD thesis** repository, organizing research materials and preparing content for GitBook publishing. The system handles Buss's evolutionary psychology materials and sets up infrastructure for future thesis content.

---

## 🎯 Quick Start

### Step 1: Download Materials
Download all thesis materials from the chat interface:
- `Push-To-Sacred-Bonds-Thesis.ps1` - Main upload script
- `Sync-To-Sacred-Bonds-GitBook.ps1` - GitBook preparation script
- All 5 research markdown files (Buss materials)

Place in: `C:\Users\user\Documents\GitHub\thesis-materials\`

### Step 2: Run Main Upload Script
```powershell
cd C:\Users\user\Documents\GitHub\thesis-materials
.\Push-To-Sacred-Bonds-Thesis.ps1
```

### Step 3: Prepare for GitBook
```powershell
cd C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis
.\Sync-To-Sacred-Bonds-GitBook.ps1 -CreateMissingREADMEs -UpdateNavigation
```

### Step 4: Set Up GitBook
1. Go to https://gitbook.com
2. Create space: "Sacred Bonds PhD Thesis"
3. Connect to: `dw-hurt/phd-sacred-bonds-thesis`
4. Enable Git Sync (branch: main)

---

## 📂 Repository Structure

Your Sacred Bonds thesis repository will be organized as:

```
phd-sacred-bonds-thesis/
├── README.md                          # Thesis overview
├── SUMMARY.md                         # GitBook navigation
├── .gitbook.yaml                      # GitBook configuration
├── INTEGRATION_REPORT.md              # Upload status report
├── GITBOOK_CHECKLIST.md               # Publishing checklist
│
├── Literature-Review/
│   ├── INDEX.md                       # Literature review overview
│   ├── 01-Sacred-Traditions/
│   ├── 02-Evolutionary-Psychology/
│   │   ├── README.md
│   │   └── Mens-Long-Term-Mating/
│   │       └── Buss_Mens_Long_Term_Mating_Strategies.md ✓
│   ├── 03-Attachment-Theory/
│   └── 04-Neuroscience-of-Bonding/
│
├── Bibliography/
│   ├── Primary-Sources/
│   │   ├── README.md
│   │   └── Buss_Evolutionary_Psychology_Handbook.md ✓
│   └── Secondary-Sources/
│
├── Resources/
│   ├── Key-Quotes/
│   │   ├── README.md
│   │   └── Evolutionary-Psychology/
│   │       └── Buss_Quotes_Mate_Preferences.md ✓
│   └── Research-Notes/
│
├── Research-Notes/
│   ├── Integration-Guides/
│   │   ├── README.md
│   │   └── Buss_Integration_Sacred_Bonds.md ✓
│   └── Synthesis-Documents/
│
├── Analysis/
│   ├── Theoretical-Frameworks/
│   │   ├── README.md
│   │   └── Evolutionary-vs-Social/
│   │       └── Buss_Comparative_Framework_Analysis.md ✓
│   └── Case-Studies/
│
├── Chapters/
│   ├── Chapter-01-Introduction/
│   ├── Chapter-02-Theoretical-Foundations/
│   ├── Chapter-03-Sacred-Traditions/
│   ├── Chapter-04-Evolutionary-Perspectives/
│   └── Chapter-05-Synthesis/
│
└── Appendices/
```

---

## 🔧 Script 1: Push-To-Sacred-Bonds-Thesis.ps1

### Purpose
Uploads Buss evolutionary psychology materials to your Sacred Bonds thesis repository and pushes to GitHub.

### Basic Usage
```powershell
cd C:\Users\user\Documents\GitHub\thesis-materials
.\Push-To-Sacred-Bonds-Thesis.ps1
```

### Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `-SourceDirectory` | Location of source markdown files | Current directory |
| `-ThesisRepoPath` | Path to Sacred Bonds thesis repository | `C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis` |
| `-GitHubRepo` | GitHub repository URL | `https://github.com/dw-hurt/phd-sacred-bonds-thesis.git` |
| `-BranchName` | Git branch name | `main` |
| `-DryRun` | Preview without executing | Off |
| `-Verbose` | Show detailed output | Off |

### Examples

**Standard Upload**:
```powershell
.\Push-To-Sacred-Bonds-Thesis.ps1
```

**Preview Mode** (recommended first run):
```powershell
.\Push-To-Sacred-Bonds-Thesis.ps1 -DryRun
```

**Verbose Output**:
```powershell
.\Push-To-Sacred-Bonds-Thesis.ps1 -Verbose
```

**Custom Source Directory**:
```powershell
.\Push-To-Sacred-Bonds-Thesis.ps1 `
    -SourceDirectory "D:\Research\Materials"

# Default source is: C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis\thesis-materials
# Default thesis repo is: C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis
```

### What It Does

1. ✅ Validates all source files exist
2. ✅ Creates Sacred Bonds thesis directory structure (15+ folders)
3. ✅ Copies 5 research files to appropriate locations:
   - Summary → `Literature-Review/02-Evolutionary-Psychology/Mens-Long-Term-Mating/`
   - Quotes → `Resources/Key-Quotes/Evolutionary-Psychology/`
   - Bibliography → `Bibliography/Primary-Sources/`
   - Integration Guide → `Research-Notes/Integration-Guides/`
   - Comparative Analysis → `Analysis/Theoretical-Frameworks/Evolutionary-vs-Social/`
4. ✅ Creates comprehensive README.md for thesis
5. ✅ Creates Literature Review INDEX.md
6. ✅ Creates SUMMARY.md for GitBook navigation
7. ✅ Creates .gitbook.yaml configuration
8. ✅ Initializes Git repository (if needed)
9. ✅ Commits and pushes to GitHub
10. ✅ Generates integration report

### Output Files Created

- `README.md` - Thesis overview with structure and recent updates
- `SUMMARY.md` - GitBook table of contents
- `.gitbook.yaml` - GitBook configuration
- `Literature-Review/INDEX.md` - Literature review navigation
- `INTEGRATION_REPORT.md` - Detailed upload report with verification commands

---

## 🔧 Script 2: Sync-To-Sacred-Bonds-GitBook.ps1

### Purpose
Prepares thesis content for GitBook publishing by creating section READMEs, updating navigation, and verifying file references.

### Basic Usage
```powershell
cd C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis
.\Sync-To-Sacred-Bonds-GitBook.ps1 -CreateMissingREADMEs -UpdateNavigation
```

### Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `-ThesisRepoPath` | Path to thesis repository | `C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis` |
| `-BranchName` | Git branch name | `main` |
| `-CreateMissingREADMEs` | Create section overview files | Off (switch) |
| `-UpdateNavigation` | Update SUMMARY.md navigation | Off (switch) |
| `-DryRun` | Preview without executing | Off |
| `-Force` | Overwrite existing README files | Off |

### Examples

**Full Preparation** (recommended):
```powershell
.\Sync-To-Sacred-Bonds-GitBook.ps1 -CreateMissingREADMEs -UpdateNavigation
```

**Preview Only**:
```powershell
.\Sync-To-Sacred-Bonds-GitBook.ps1 -CreateMissingREADMEs -UpdateNavigation -DryRun
```

**Create READMEs Only**:
```powershell
.\Sync-To-Sacred-Bonds-GitBook.ps1 -CreateMissingREADMEs
```

**Update Navigation Only**:
```powershell
.\Sync-To-Sacred-Bonds-GitBook.ps1 -UpdateNavigation
```

**Force Overwrite Existing Files**:
```powershell
.\Sync-To-Sacred-Bonds-GitBook.ps1 -CreateMissingREADMEs -Force
```

### What It Does

1. ✅ Creates section README.md files for:
   - `Literature-Review/02-Evolutionary-Psychology/README.md`
   - `Resources/Key-Quotes/README.md`
   - `Research-Notes/Integration-Guides/README.md`
   - `Analysis/Theoretical-Frameworks/README.md`
   - `Bibliography/Primary-Sources/README.md`
2. ✅ Updates SUMMARY.md with enhanced navigation structure
3. ✅ Creates placeholder overview files for empty sections
4. ✅ Verifies all SUMMARY.md file references exist
5. ✅ Creates GITBOOK_CHECKLIST.md with setup instructions
6. ✅ Commits and pushes changes to GitHub
7. ✅ Triggers GitBook auto-sync

### Output Files Created

- Section `README.md` files (5 sections)
- `GITBOOK_CHECKLIST.md` - Step-by-step publishing guide
- Updated `SUMMARY.md` with complete navigation
- Overview files for Resources, Analysis, Chapters, Appendices

---

## 📋 Complete Workflow

### Workflow 1: Initial Setup (First Time)

**Step 1: Prepare Materials**
```powershell
# Navigate to materials directory
cd C:\Users\user\Documents\GitHub\thesis-materials

# Preview what will happen
.\Push-To-Sacred-Bonds-Thesis.ps1 -DryRun
```

**Step 2: Execute Upload**
```powershell
# Upload to Sacred Bonds repository
.\Push-To-Sacred-Bonds-Thesis.ps1
```

**Expected Output**:
```
[STEP] Validating source files and repository...
  ✓ Source directory found
  ✓ All source files validated (5 files)

[STEP] Creating Sacred Bonds thesis directory structure...
  ✓ Directory structure ready

[STEP] Copying files to Sacred Bonds thesis repository...
  ✓ All files copied to thesis repository

[STEP] Creating/updating thesis README.md...
  ✓ Created README.md

[STEP] Performing Git operations...
  ✓ Staged all changes
  ✓ Committed: Add Buss evolutionary psychology materials...
  ✓ Pushed to https://github.com/dw-hurt/phd-sacred-bonds-thesis.git

OPERATION COMPLETE
```

**Step 3: Verify on GitHub**
1. Go to: https://github.com/dw-hurt/phd-sacred-bonds-thesis
2. Verify files are present
3. Check README.md displays correctly

**Step 4: Prepare for GitBook**
```powershell
# Navigate to thesis repository
cd C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis

# Create section READMEs and update navigation
.\Sync-To-Sacred-Bonds-GitBook.ps1 -CreateMissingREADMEs -UpdateNavigation
```

**Step 5: Set Up GitBook**
1. Go to: https://gitbook.com
2. Sign in with GitHub account
3. Click "New Space"
4. Name: "Sacred Bonds PhD Thesis"
5. Visibility: Private (recommended for thesis work)
6. Click "Create Space"

**Step 6: Connect GitHub**
1. In GitBook space, go to Settings → Integrations
2. Click "GitHub"
3. Authorize GitBook
4. Select repository: `dw-hurt/phd-sacred-bonds-thesis`
5. Select branch: `main`
6. Enable "Bi-directional sync"
7. Click "Save"

**Step 7: Wait for Sync**
- GitBook will automatically sync within 2-5 minutes
- Check GitBook activity log for sync status
- Verify navigation appears from SUMMARY.md

**Step 8: Review Published Thesis**
- Navigate through GitBook pages
- Verify all links work
- Check formatting and readability

---

### Workflow 2: Adding New Materials

When you have new research materials to add:

**Step 1: Prepare New Files**
- Place new markdown files in `thesis-materials` directory
- Name according to convention: `[Author]_[Topic]_[Type].md`

**Step 2: Update Script Configuration**
Edit `Push-To-Sacred-Bonds-Thesis.ps1`:
```powershell
# Add to $ThesisFiles array
@{
    SourceFile = "NewAuthor_Topic_Summary.md"
    ThesisPath = "Literature-Review\XX-Subdiscipline\Topic"
    FileName = "NewAuthor_Topic.md"
    GitBookSection = "Literature Review"
    GitBookSubsection = "Subdiscipline"
    Chapter = "Chapter X: Topic"
    Description = "Description of content"
}
```

**Step 3: Run Upload Script**
```powershell
.\Push-To-Sacred-Bonds-Thesis.ps1
```

**Step 4: Update GitBook Navigation**
```powershell
cd C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis
.\Sync-To-Sacred-Bonds-GitBook.ps1 -UpdateNavigation
```

**Step 5: Verify Auto-Sync**
- Check GitBook activity log
- New content should appear within minutes

---

## 🔍 Verification & Troubleshooting

### Verify Repository Status

```powershell
cd C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis

# Check Git status
git status

# View recent commits
git log --oneline -5

# List all markdown files
Get-ChildItem -Recurse -Filter "*.md" | Select-Object FullName

# Check specific file exists
Test-Path "Literature-Review\02-Evolutionary-Psychology\Mens-Long-Term-Mating\Buss_Mens_Long_Term_Mating_Strategies.md"
```

### Common Issues & Solutions

#### Issue 1: Git Push Authentication Failed

**Symptoms**: Error when pushing to GitHub  
**Cause**: GitHub credentials not configured

**Solution**:
```powershell
# Generate Personal Access Token (PAT)
# 1. Go to: https://github.com/settings/tokens
# 2. Click "Generate new token" (classic)
# 3. Select scopes: repo (all), workflow
# 4. Generate and copy token

# Configure Git to use PAT
git config --global credential.helper wincred

# Next push will prompt for credentials
# Username: dw-hurt
# Password: [paste PAT here]
```

#### Issue 2: Repository Doesn't Exist on GitHub

**Symptoms**: `repository not found` error  
**Cause**: GitHub repository not created yet

**Solution**:
1. Go to: https://github.com/new
2. Repository name: `phd-sacred-bonds-thesis`
3. Visibility: **Private** (recommended for thesis)
4. Do NOT initialize with README (already created locally)
5. Click "Create repository"
6. Re-run upload script

#### Issue 3: GitBook Not Syncing

**Symptoms**: Changes pushed to GitHub don't appear in GitBook  
**Cause**: Multiple possible causes

**Solution**:
```powershell
# 1. Check GitBook integration is active
#    - Go to GitBook Settings → Integrations
#    - Verify GitHub shows "Connected"
#    - Check branch is "main"

# 2. Manually trigger sync
#    - In GitBook, go to Settings → Git Sync
#    - Click "Sync now"

# 3. Check for markdown syntax errors
#    - Review GitBook activity log
#    - Fix any reported errors

# 4. Verify SUMMARY.md format
cd C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis
Get-Content SUMMARY.md

# 5. Check file paths are relative (not absolute)
#    - WRONG: * [Page](/absolute/path/file.md)
#    - RIGHT: * [Page](relative/path/file.md)
```

#### Issue 4: Missing Files in SUMMARY.md

**Symptoms**: Script warns about missing files

**Solution**:
```powershell
# The script will report missing files referenced in SUMMARY.md
# Create placeholder files for missing references:

$missingFile = "Chapters\Chapter-01-Introduction\README.md"
$fileDir = Split-Path -Parent $missingFile
New-Item -ItemType Directory -Path $fileDir -Force
Set-Content -Path $missingFile -Value "# Chapter 1: Introduction`n`nContent coming soon..."

# Re-run GitBook sync
.\Sync-To-Sacred-Bonds-GitBook.ps1 -UpdateNavigation
```

#### Issue 5: Dry Run Shows No Output

**Symptoms**: `-DryRun` flag doesn't show expected output

**Solution**:
```powershell
# Add -Verbose flag for more details
.\Push-To-Sacred-Bonds-Thesis.ps1 -DryRun -Verbose

# Check PowerShell execution policy
Get-ExecutionPolicy

# If Restricted, change to RemoteSigned
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

---

## 📊 File Mapping Reference

| Source File | Destination | GitBook Section |
|-------------|-------------|----------------|
| `Buss_Mens_Mating_Strategies_Summary.md` | `Literature-Review/02-Evolutionary-Psychology/Mens-Long-Term-Mating/Buss_Mens_Long_Term_Mating_Strategies.md` | Literature Review → Evolutionary Psychology |
| `Buss_Key_Quotes.md` | `Resources/Key-Quotes/Evolutionary-Psychology/Buss_Quotes_Mate_Preferences.md` | Resources → Key Quotes |
| `Bibliography_Buss_Evolutionary_Psychology.md` | `Bibliography/Primary-Sources/Buss_Evolutionary_Psychology_Handbook.md` | Bibliography → Primary Sources |
| `Buss_Mens_Mating_Integration_Guide.md` | `Research-Notes/Integration-Guides/Buss_Integration_Sacred_Bonds.md` | Resources → Research Notes |
| `Buss_Comparative_Analysis.md` | `Analysis/Theoretical-Frameworks/Evolutionary-vs-Social/Buss_Comparative_Framework_Analysis.md` | Analysis → Theoretical Frameworks |

---

## 🎨 GitBook Customization

After basic setup, customize your GitBook:

### Theme & Appearance
1. Go to GitBook Settings → Appearance
2. Choose theme (Light/Dark/Auto)
3. Select primary color
4. Upload custom logo (optional)

### Search & Navigation
1. Enable search (Settings → Features)
2. Configure table of contents depth
3. Add page insights

### PDF Export
1. Go to Settings → PDF
2. Configure export options
3. Add cover page
4. Enable/disable table of contents

### Custom Domain (Optional)
1. Go to Settings → Domain
2. Add custom domain (e.g., thesis.yourdomain.com)
3. Follow DNS configuration instructions

---

## 📈 Best Practices

### 1. Regular Commits
```powershell
# Commit frequently with descriptive messages
git add .
git commit -m "Add Chapter 2 draft - Theoretical foundations"
git push origin main
```

### 2. Use Meaningful File Names
- ✅ `Buss_Mens_Long_Term_Mating_Strategies.md`
- ❌ `file1.md` or `notes.md`

### 3. Organize by Discipline
```
Literature-Review/
├── 01-Sacred-Traditions/
├── 02-Evolutionary-Psychology/
├── 03-Attachment-Theory/
└── 04-Neuroscience-of-Bonding/
```

### 4. Cross-Reference Materials
Link related documents:
```markdown
See also:
- [Integration Guide](../Research-Notes/Integration-Guides/Buss_Integration_Sacred_Bonds.md)
- [Bibliography Entry](../Bibliography/Primary-Sources/Buss_Evolutionary_Psychology_Handbook.md)
```

### 5. Version Control Milestones
```powershell
# Tag major milestones
git tag -a v1.0-proposal -m "Thesis proposal submitted"
git tag -a v2.0-draft -m "First complete draft"
git push --tags
```

### 6. Backup Strategy
```powershell
# Regular backups beyond Git
xcopy C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis D:\Backup\thesis-$(Get-Date -Format 'yyyyMMdd') /E /I /H /Y

# Export GitBook PDFs periodically
# (from GitBook interface: Share → Export → PDF)
```

---

## 🔗 Quick Links

- **GitHub Repository**: https://github.com/dw-hurt/phd-sacred-bonds-thesis
- **GitBook**: https://gitbook.com (your account)
- **Personal Access Tokens**: https://github.com/settings/tokens
- **GitBook Documentation**: https://docs.gitbook.com

---

## 📞 Command Reference Card

```powershell
# === INITIAL SETUP ===
cd C:\Users\user\Documents\GitHub\thesis-materials
.\Push-To-Sacred-Bonds-Thesis.ps1

# === PREPARE GITBOOK ===
cd C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis
.\Sync-To-Sacred-Bonds-GitBook.ps1 -CreateMissingREADMEs -UpdateNavigation

# === VERIFICATION ===
git status
git log --oneline -5
Test-Path "Literature-Review\02-Evolutionary-Psychology\Mens-Long-Term-Mating\Buss_Mens_Long_Term_Mating_Strategies.md"

# === UPDATES ===
git add .
git commit -m "Update message"
git push origin main

# === DRY RUN (PREVIEW) ===
.\Push-To-Sacred-Bonds-Thesis.ps1 -DryRun
.\Sync-To-Sacred-Bonds-GitBook.ps1 -CreateMissingREADMEs -UpdateNavigation -DryRun
```

---

## 📝 Next Steps After Setup

1. ✅ Verify repository on GitHub
2. ✅ Set up GitBook integration
3. ✅ Review published thesis structure
4. ⬜ Draft Chapter 1: Introduction
5. ⬜ Add women's mate selection research
6. ⬜ Add attachment theory materials
7. ⬜ Add neuroscience literature
8. ⬜ Add sacred traditions research
9. ⬜ Develop integration synthesis documents
10. ⬜ Build comprehensive bibliography

---

**Document Version**: 1.0  
**Last Updated**: 2025-12-02  
**Author**: PhD Automation System  
**Repository**: Sacred Bonds PhD Thesis
