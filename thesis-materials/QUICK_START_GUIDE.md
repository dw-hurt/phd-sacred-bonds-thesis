# Sacred Bonds PhD Thesis - Quick Start Guide

## 🚀 5-Minute Setup

This guide gets your Sacred Bonds thesis repository up and running on GitHub with GitBook integration.

---

## 📦 What You're Getting

### Research Content (5 Files)
1. **Buss_Mens_Mating_Strategies_Summary.md** (18KB) - Comprehensive analysis
2. **Buss_Key_Quotes.md** (15KB) - Curated quotations
3. **Bibliography_Buss_Evolutionary_Psychology.md** (15KB) - Full citation
4. **Buss_Mens_Mating_Integration_Guide.md** (9.5KB) - Strategic integration roadmap
5. **Buss_Comparative_Analysis.md** (20KB) - Framework comparisons

### Automation Scripts (3 Files)
1. **Push-To-Sacred-Bonds-Thesis.ps1** (28KB) - Main upload script
2. **Sync-To-Sacred-Bonds-GitBook.ps1** (22KB) - GitBook preparation
3. **README_SACRED_BONDS_AUTOMATION.md** (19KB) - Complete documentation

---

## ⚡ Step-by-Step Execution

### Step 1: Download Everything (1 minute)

Click these links to download all files:

**PowerShell Scripts:**
- [Push-To-Sacred-Bonds-Thesis.ps1](computer:///mnt/user-data/outputs/sacred-bonds-thesis/Push-To-Sacred-Bonds-Thesis.ps1)
- [Sync-To-Sacred-Bonds-GitBook.ps1](computer:///mnt/user-data/outputs/sacred-bonds-thesis/Sync-To-Sacred-Bonds-GitBook.ps1)
- [User Guide](computer:///mnt/user-data/outputs/sacred-bonds-thesis/README_SACRED_BONDS_AUTOMATION.md)

**Research Materials:**
- [Buss Summary](computer:///mnt/user-data/outputs/thesis-materials/Buss_Mens_Mating_Strategies_Summary.md)
- [Key Quotes](computer:///mnt/user-data/outputs/thesis-materials/Buss_Key_Quotes.md)
- [Bibliography](computer:///mnt/user-data/outputs/thesis-materials/Bibliography_Buss_Evolutionary_Psychology.md)
- [Integration Guide](computer:///mnt/user-data/outputs/thesis-materials/Buss_Mens_Mating_Integration_Guide.md)
- [Comparative Analysis](computer:///mnt/user-data/outputs/thesis-materials/Buss_Comparative_Analysis.md)

**Save to:** `C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis\thesis-materials\`

**Create folder if needed:**
```powershell
mkdir C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis\thesis-materials -Force
```

---

### Step 2: Create GitHub Repository (1 minute)

1. Go to: **https://github.com/new**
2. Repository name: `phd-sacred-bonds-thesis`
3. Visibility: ✅ **Private** (recommended for thesis work)
4. ❌ Do NOT initialize with README
5. Click **"Create repository"**

✅ Repository created: `https://github.com/dw-hurt/phd-sacred-bonds-thesis`

---

### Step 3: Run Upload Script (2 minutes)

Open PowerShell:

```powershell
# Navigate to materials directory
cd C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis\thesis-materials

# Preview what will happen (optional but recommended)
.\Push-To-Sacred-Bonds-Thesis.ps1 -DryRun

# Execute upload
.\Push-To-Sacred-Bonds-Thesis.ps1
```

**What happens:**
- ✅ Creates 15+ organized directories
- ✅ Copies 5 research files to correct locations
- ✅ Generates README.md, SUMMARY.md, .gitbook.yaml
- ✅ Commits and pushes to GitHub

**Expected Output:**
```
[STEP] Validating source files and repository...
  ✓ All source files validated (5 files)
[STEP] Creating Sacred Bonds thesis directory structure...
  ✓ Directory structure ready
[STEP] Copying files to Sacred Bonds thesis repository...
  ✓ All files copied to thesis repository
[STEP] Performing Git operations...
  ✓ Pushed to GitHub: https://github.com/dw-hurt/phd-sacred-bonds-thesis.git

OPERATION COMPLETE
```

---

### Step 4: Verify on GitHub (30 seconds)

1. Go to: **https://github.com/dw-hurt/phd-sacred-bonds-thesis**
2. You should see:
   - ✅ README.md with thesis overview
   - ✅ SUMMARY.md for GitBook navigation
   - ✅ Folders: Literature-Review, Bibliography, Resources, Analysis, etc.
   - ✅ 5 research files in appropriate locations

---

### Step 5: Prepare for GitBook (1 minute)

```powershell
# Navigate to thesis repository
cd C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis

# Create section READMEs and update navigation
.\Sync-To-Sacred-Bonds-GitBook.ps1 -CreateMissingREADMEs -UpdateNavigation
```

**What happens:**
- ✅ Creates 5 section README.md files
- ✅ Updates SUMMARY.md navigation
- ✅ Creates GITBOOK_CHECKLIST.md
- ✅ Pushes changes to GitHub

---

### Step 6: Set Up GitBook (3 minutes)

**6.1 Create GitBook Account**
1. Go to: **https://gitbook.com**
2. Click **"Sign in with GitHub"**
3. Authorize GitBook to access GitHub

**6.2 Create Space**
1. Click **"New Space"**
2. Name: `Sacred Bonds PhD Thesis`
3. Visibility: **Private** (for thesis work) or **Public** (for academic portfolio)
4. Click **"Create Space"**

**6.3 Connect GitHub Repository**
1. In your new space, go to: **Settings → Integrations**
2. Click **"GitHub"** integration
3. Click **"Configure"**
4. Select repository: `dw-hurt/phd-sacred-bonds-thesis`
5. Select branch: `main`
6. Enable **"Bi-directional sync"** ✅
7. Click **"Save"**

**6.4 Wait for Initial Sync**
- ⏱️ GitBook will sync within **2-5 minutes**
- Check: **Settings → Git Sync → Activity Log**
- ✅ Status should show "Sync successful"

---

### Step 7: View Your Published Thesis (30 seconds)

1. In GitBook, click **"Share"** button
2. Your thesis is now live! Copy the URL
3. Navigate through the pages:
   - Literature Review → Evolutionary Psychology → Men's Long-Term Mating
   - Bibliography → Primary Sources → Buss
   - Resources → Key Quotes
   - Analysis → Theoretical Frameworks

---

## ✅ Verification Checklist

After setup, verify everything worked:

```powershell
cd C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis

# Check Git status
git status              # Should show "nothing to commit, working tree clean"

# View recent commits
git log --oneline -5    # Should show your commits

# Verify files exist
Test-Path "Literature-Review\02-Evolutionary-Psychology\Mens-Long-Term-Mating\Buss_Mens_Long_Term_Mating_Strategies.md"
# Should return: True

Test-Path "SUMMARY.md"
# Should return: True

Test-Path "README.md"
# Should return: True
```

**On GitHub:**
- ✅ Repository exists at: https://github.com/dw-hurt/phd-sacred-bonds-thesis
- ✅ 5 research files visible in correct folders
- ✅ README.md displays thesis overview
- ✅ Multiple commits showing upload activity

**On GitBook:**
- ✅ Space shows "Sacred Bonds PhD Thesis"
- ✅ Navigation menu populated from SUMMARY.md
- ✅ Pages display correctly
- ✅ Links between pages work
- ✅ Activity log shows successful sync

---

## 🔧 Troubleshooting

### Problem: Git push authentication failed

**Solution:**
```powershell
# 1. Generate Personal Access Token
# Go to: https://github.com/settings/tokens
# Click: "Generate new token (classic)"
# Scopes: Select "repo" (all), "workflow"
# Generate and COPY the token

# 2. Push again - it will prompt for credentials
git push origin main
# Username: dw-hurt
# Password: [paste your token here]
```

---

### Problem: GitBook not syncing

**Check these:**
1. ✅ GitHub integration shows "Connected" in GitBook settings
2. ✅ Branch is set to "main" (not "master")
3. ✅ Activity log doesn't show errors
4. ✅ SUMMARY.md has valid markdown syntax

**Manual sync:**
- Go to: Settings → Git Sync
- Click **"Sync now"**

---

### Problem: Repository already exists error

**You already created the repo before! Solution:**
```powershell
cd C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis

# Check if remote exists
git remote -v

# If no remote, add it
git remote add origin https://github.com/dw-hurt/phd-sacred-bonds-thesis.git

# Push
git push -u origin main
```

---

## 🎯 What's Next?

Now that your thesis repository is live, here are your next steps:

### Immediate (This Week)
1. ✅ Bookmark your GitBook URL
2. ✅ Review the published content
3. ✅ Share GitBook URL with advisor (if appropriate)
4. ⬜ Read the Integration Guide to plan Chapter 2
5. ⬜ Review Comparative Analysis for Chapter 4 structure

### Short-term (This Month)
1. ⬜ Draft Chapter 1: Introduction
2. ⬜ Add women's mate selection research
3. ⬜ Add attachment theory literature
4. ⬜ Create chapter outlines

### Medium-term (This Semester)
1. ⬜ Add neuroscience of bonding materials
2. ⬜ Add sacred traditions research
3. ⬜ Develop integration synthesis documents
4. ⬜ Write theoretical foundations chapter

---

## 📚 Additional Resources

### Documentation
- [Complete User Guide](computer:///mnt/user-data/outputs/sacred-bonds-thesis/README_SACRED_BONDS_AUTOMATION.md) - Full automation documentation
- Integration Report: `C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis\INTEGRATION_REPORT.md`
- GitBook Checklist: `C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis\GITBOOK_CHECKLIST.md`

### External Links
- **GitHub Docs**: https://docs.github.com/en/get-started/quickstart
- **GitBook Docs**: https://docs.gitbook.com
- **Markdown Guide**: https://www.markdownguide.org/basic-syntax/

---

## 💡 Pro Tips

1. **Commit Often**: Make small, frequent commits with descriptive messages
   ```powershell
   git add .
   git commit -m "Add draft of Chapter 2 section on parental investment"
   git push origin main
   ```

2. **Use Branches for Major Revisions**: 
   ```powershell
   git checkout -b chapter-2-revision
   # Make changes
   git commit -m "Revise theoretical framework section"
   git push origin chapter-2-revision
   # Later: merge to main
   ```

3. **Tag Milestones**:
   ```powershell
   git tag -a v1.0-proposal -m "Thesis proposal submitted to committee"
   git push --tags
   ```

4. **Regular Backups**: GitBook and GitHub are backups, but also:
   ```powershell
   xcopy C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis D:\Backup\thesis-$(Get-Date -Format 'yyyyMMdd') /E /I
   ```

5. **Export PDFs from GitBook**: Regularly export PDF versions of your thesis for offline review

---

## ⏱️ Total Setup Time

- **Download files**: 1 minute
- **Create GitHub repo**: 1 minute  
- **Run upload script**: 2 minutes
- **Verify on GitHub**: 30 seconds
- **Prepare for GitBook**: 1 minute
- **Set up GitBook**: 3 minutes
- **View published thesis**: 30 seconds

**Total: ~9 minutes** ⚡

---

## 🎓 Your Thesis is Now Live!

Congratulations! You now have:

✅ **GitHub Repository**: Professional version control  
✅ **Organized Structure**: 15+ categorized folders  
✅ **Research Materials**: Buss evolutionary psychology analysis  
✅ **GitBook Site**: Beautiful, published thesis documentation  
✅ **Automation Scripts**: Easy updates and content management  
✅ **Integration Guides**: Strategic roadmap for thesis development  

**Your thesis journey has officially begun!** 🚀

---

## 📞 Quick Commands Reference

```powershell
# === UPLOAD TO GITHUB ===
cd C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis\thesis-materials
.\Push-To-Sacred-Bonds-Thesis.ps1

# === PREPARE GITBOOK ===
cd C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis
.\Sync-To-Sacred-Bonds-GitBook.ps1 -CreateMissingREADMEs -UpdateNavigation

# === CHECK STATUS ===
git status
git log --oneline -5

# === MAKE UPDATES ===
git add .
git commit -m "Description of changes"
git push origin main
```

---

**Ready to begin? Start with Step 1! ⬆️**

---

*Document Version: 1.0*  
*Last Updated: 2025-12-02*  
*Total Files: 8 (5 research + 3 scripts)*  
*Total Size: ~110KB*
