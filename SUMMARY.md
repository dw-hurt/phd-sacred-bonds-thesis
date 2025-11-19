# Table of contents

* [PhD Dissertation: Sacred Bonds and Sexual Selection](README.md)
* [Test Document](test.md)
* [project\_management](project_management/README.md)
  * [To-Do List](project_management/todo.md)
* [chapters](chapters/README.md)
  * [01\_introduction](chapters/01_introduction/README.md)
    * [Chapter 1: Introduction - Sacred Bonds and Sexual Selection](chapters/01_introduction/chapter_01_introduction.md)
* [notes](notes/README.md)
        * [SOURCE SUMMARY: Gangestad & Simpson (2000)](notes/reading_notes/by_source/gangestad_simpson_2000_notes.md)
* 

## Research Materials

* [Quote Database](quotes/README.md)
  * [Chapter 2 Quotes](quotes/by_chapter/chapter_02_quotes.md)
  * [Chapter 3 Quotes](quotes/by_chapter/chapter_03_quotes.md)
  * [Chapter 4 Quotes](quotes/by_chapter/chapter_04_quotes.md)
  * [Chapter 5 Quotes](quotes/by_chapter/chapter_05_quotes.md)

* [Source Summaries](notes/reading_notes/by_source/README.md)
  * [Gangestad & Simpson 2000](notes/reading_notes/by_source/gangestad_simpson_2000_summary.md)
  * [Buss 2023 - Sexual Strategies](notes/reading_notes/by_source/buss_2023_mating_strategies_summary.md)

* [Reading Notes](notes/README.md)
  * [By Source](notes/reading_notes/by_source/README.md)
  * [By Theme](notes/reading_notes/by_theme/README.md)

# Dashboard Deployment Guide

**Created:** 2025-11-19  
**Purpose:** Step-by-step instructions to deploy the Project Management Dashboard to your PhD repository

---

## 📦 What You're Deploying

A complete **Project Management Dashboard** system consisting of:

1. **progress_tracker.md** - Master progress overview
2. **todo_list.md** - Prioritized task list
3. **stage_status.md** - Detailed stage breakdown
4. **chapter_tracker.md** - Chapter-by-chapter tracking
5. **source_inventory.md** - Complete source management
6. **weekly_review.md** - Weekly review template
7. **README.md** - Dashboard documentation and navigation

**Total:** 7 files for the `project_management/` folder

---

## 🎯 Your Current Research Pipeline Status

**You are at the Stage 2 → Stage 3 transition point:**

### ✅ What You've Accomplished (Stage 2: 85% Complete)
- Infrastructure fully operational (Git, GitHub, GitBook, VSCode, Zotero)
- 2 evolutionary psychology sources processed
- 28 quotes extracted for Chapter 2
- Chapter templates created for all 8 chapters
- Workflow automation scripts created

### ⏳ What's Next (Immediate Priorities)
1. **Complete Stage 2:** Process 2-3 Jungian sources to enable Chapter 3
2. **Begin Stage 3:** Start writing Chapter 1 (Introduction) - **can start now**
3. **Parallel Work:** Write Chapter 2 while processing archetypal sources

### 🔴 Current Blockers
- **Chapters 3, 4, 5:** Blocked by missing Jungian/Synchronicity/Transpersonal sources
- **Chapters 6, 7:** Blocked by missing content from Chapters 2-5

---

## 📋 Deployment Steps

### Step 1: Navigate to Repository (PowerShell)

```powershell
# Navigate to your PhD repository
phd

# Verify you're in the right place
pwd
# Should show: C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis

# Sync with GitHub first
git pull
```

---

### Step 2: Create Dashboard Files

You have two options:

#### **Option A: Manual Copy-Paste (Recommended for First Time)**

1. **Create the project_management folder** (if it doesn't exist):
   ```powershell
   mkdir project_management
   cd project_management
   ```

2. **Create each dashboard file** using VSCode:
   ```powershell
   # Open VSCode to create files
   code progress_tracker.md
   ```
   - Copy content from the AI's `progress_tracker.md` output above
   - Paste into VSCode
   - Save (Ctrl+S)
   
3. **Repeat for all dashboard files:**
   ```powershell
   code todo_list.md
   code stage_status.md
   code chapter_tracker.md
   code source_inventory.md
   code weekly_review.md
   code README.md  # Use the project_management_README.md content
   ```

#### **Option B: AI Drive Method**

If you've saved the dashboard files to AI Drive:
1. Navigate to AI Drive location
2. Copy files to `project_management/` folder:
   ```powershell
   cp [ai-drive-path]/progress_tracker.md ./project_management/
   cp [ai-drive-path]/todo_list.md ./project_management/
   # ... repeat for all files
   ```

---

### Step 3: Update SUMMARY.md for GitBook Navigation

1. **Open SUMMARY.md:**
   ```powershell
   phd  # Make sure you're in root directory
   code SUMMARY.md
   ```

2. **Add Project Management section** (insert after "Research Materials" section):

```markdown
## Project Management

* [Dashboard Overview](project_management/README.md)
* [Progress Tracker](project_management/progress_tracker.md)
* [To-Do List](project_management/todo_list.md)
* [Stage Status](project_management/stage_status.md)
* [Chapter Tracker](project_management/chapter_tracker.md)
* [Source Inventory](project_management/source_inventory.md)
* [Weekly Review Template](project_management/weekly_review.md)
```

3. **Save SUMMARY.md** (Ctrl+S)

---

### Step 4: Verify Files Locally

```powershell
# Navigate to project_management folder
cd project_management

# List all files to verify
ls

# Should show:
# progress_tracker.md
# todo_list.md
# stage_status.md
# chapter_tracker.md
# source_inventory.md
# weekly_review.md
# README.md
```

---

### Step 5: Create Weekly Reviews Subfolder

```powershell
# Create folder for archived weekly reviews
mkdir weekly_reviews

# Create a README for the subfolder
code weekly_reviews/README.md
```

**Content for `weekly_reviews/README.md`:**
```markdown
# Archived Weekly Reviews

This folder contains completed weekly reviews, archived for reference.

**Naming Convention:** `YYYY-MM-DD_weekly_review.md`

**Example:** `2025-11-19_weekly_review.md`

## Reviews by Date

* [Add links to archived reviews here as you complete them]
```

Save and close.

---

### Step 6: Commit to Git

```powershell
# Navigate back to repository root
cd ..  # (if you're in project_management or weekly_reviews)
phd    # Or use this to be sure

# Check Git status
git status

# Should show new files in project_management/

# Add all new dashboard files
git add project_management/

# Add updated SUMMARY.md
git add SUMMARY.md

# Commit with descriptive message
git commit -m "Add Project Management Dashboard: progress tracker, to-do list, stage status, chapter tracker, source inventory, weekly review template"

# Push to GitHub
git push
```

---

### Step 7: Verify GitBook Sync

1. **Wait 1-2 minutes** for GitHub → GitBook sync

2. **Open GitBook** in your browser:
   - Go to your GitBook URL
   - Look for "Project Management" section in navigation

3. **Click through each dashboard file** to verify:
   - Progress Tracker loads correctly
   - To-Do List displays properly
   - All links work
   - No formatting issues

4. **If issues arise:**
   - Check that all files are in `project_management/` folder
   - Verify `SUMMARY.md` has correct paths
   - Ensure files are named exactly as specified (case-sensitive)
   - Check GitBook sync status on GitBook dashboard

---

### Step 8: Test Dashboard Workflow

**Morning Test:**
```powershell
# Navigate to repository
phd

# Sync with GitHub
git pull

# Open progress tracker
code project_management/progress_tracker.md

# Open to-do list
code project_management/todo_list.md

# This should be your daily morning routine
```

**Evening Test:**
```powershell
# Track daily progress
daily_progress

# Update to-do list (manually check off tasks)
code project_management/todo_list.md

# Commit changes
git add project_management/
git commit -m "Daily dashboard update: [brief description]"
git push
```

---

## 🎯 Stage 3 Configuration: Chapter Development

Now that your dashboard is deployed, here's how to **configure Stage 3** (Chapter Development):

### A. Technical Setup (Already Complete ✅)

You've already set up:
- ✅ `writing_session.ps1` script
- ✅ `daily_progress.ps1` script
- ✅ `citation_guide.md`
- ✅ Chapter templates (all 8 chapters)
- ✅ Git/GitBook workflow

**No additional technical setup needed!**

---

### B. Process Setup (How to Use Stage 3)

#### **Stage 3 Daily Writing Routine:**

**Morning (30 minutes):**
1. **Navigate & Sync:**
   ```powershell
   phd
   git pull
   ```

2. **Check Dashboard:**
   ```powershell
   code project_management/progress_tracker.md
   code project_management/todo_list.md
   ```
   - Review overall progress
   - Identify today's Critical/High priority task

3. **Review Target Chapter:**
   ```powershell
   code project_management/chapter_tracker.md
   ```
   - Find the chapter/section you're working on
   - Review section goals, target word count, next actions

**Active Writing (2-4 hours):**

4. **Start Writing Session:**
   ```powershell
   writing_session
   ```
   - This opens your target chapter file and quote database
   - Write in the chapter file, referencing quotes as needed

5. **Writing Best Practices:**
   - **Start with outline:** Sketch section structure before writing
   - **Use quotes:** Copy from quote files, cite with `[@author2023key]` format
   - **Write in chunks:** 500-1,000 words at a time, then break
   - **Save frequently:** Ctrl+S every few minutes

**Evening (15 minutes):**

6. **Track Progress:**
   ```powershell
   daily_progress
   ```
   - Script automatically calculates word counts
   - Updates progress in your local tracking

7. **Update To-Do List:**
   ```powershell
   code project_management/todo_list.md
   ```
   - Check off completed tasks
   - Add new tasks if identified during work

8. **Commit & Push:**
   ```powershell
   git add .
   git commit -m "Chapter X: Section Y progress - [brief description]"
   git push
   ```

---

### C. Which Chapters to Start With?

**Recommendation: Start with Chapter 1 and Chapter 2 in parallel**

#### **Week 1-2: Chapter 1, Section 1.1**
- **Target:** Draft Section 1.1 (Contemporary Mating Crisis) - 1,200-1,500 words
- **Status:** ⏳ **Can start immediately** (no blockers)
- **Approach:**
  1. Describe observable crisis (loneliness, dating app fatigue, declining relationships)
  2. Cite Buss 2023 for evolutionary context
  3. Set up problem that thesis will address

#### **Week 2-3: Chapter 2, Section 2.1**
- **Target:** Draft Section 2.1 (Darwin's Sexual Selection Framework) - 4,000-5,000 words
- **Status:** 🟢 **Material ready** (15 quotes available)
- **Approach:**
  1. Explain Darwin's sexual selection theory
  2. Use quotes from Buss 2023
  3. Establish evolutionary foundation

#### **Week 3-4: Continue Chapter 1**
- **Target:** Draft Section 1.2 (Research Questions) - 800-1,000 words
- **Approach:**
  1. Define core research questions
  2. Preview five-dimensional model
  3. State thesis contribution

#### **Week 5+: Continue Chapter 2, Process Jungian Sources in Parallel**
- **Writing:** Continue drafting Chapter 2 sections sequentially
- **Source Processing:** Begin processing Jung "Psychology of Transference"
- **Goal:** Have Chapter 2 draft advancing while unlocking Chapter 3 material

---

### D. When Do You Start Chapter 3?

**Start Chapter 3 after:**
1. ✅ At least 2 Jungian sources processed (Jung, Von Franz)
2. ✅ 15-20 quotes extracted for Chapter 3
3. ✅ Chapter 1, Sections 1.1-1.2 drafted (to maintain intro momentum)
4. ⏳ Chapter 2, Sections 2.1-2.3 drafted (biological foundation established)

**Estimated Timeline:** 6-8 weeks from now (assuming 1 source processed per 2 weeks)

---

## 📊 Dashboard Usage Guidelines

### Daily Dashboard Routine (5-10 minutes)

**Morning:**
- Open `progress_tracker.md` - Check overall status
- Open `todo_list.md` - Identify today's priority
- Open `chapter_tracker.md` - Review target section details

**Evening:**
- Run `daily_progress.ps1` - Update word counts
- Update `todo_list.md` - Check off tasks

---

### Weekly Dashboard Routine (30-45 minutes)

**Every Friday or Sunday:**
1. **Complete `weekly_review.md` template:**
   - Fill in metrics (hours worked, words written, sources processed)
   - List accomplishments and challenges
   - Reflect on what worked and what didn't
   - Set next week's top 3 priorities

2. **Update all trackers based on weekly review:**
   - Update `progress_tracker.md` (word counts, stage progress)
   - Update `stage_status.md` (health indicators, blockers)
   - Reorganize `todo_list.md` (re-prioritize, archive completed)
   - Review `source_inventory.md` (confirm next sources)

3. **Archive completed weekly review:**
   ```powershell
   # Rename and move completed review to archive
   mv project_management/weekly_review.md project_management/weekly_reviews/2025-11-19_weekly_review.md
   
   # Copy template back to main folder for next week
   cp project_management/weekly_reviews/README.md project_management/weekly_review.md
   # (or just manually create a fresh template)
   ```

4. **Commit dashboard updates:**
   ```powershell
   git add project_management/
   git commit -m "Weekly dashboard update: Week of [date]"
   git push
   ```

---

### Monthly Dashboard Routine (60 minutes)

**First Sunday of Each Month:**
1. **Full review of `chapter_tracker.md`:**
   - Assess word count targets vs. actuals
   - Adjust targets if consistently missing (be realistic)

2. **Comprehensive `source_inventory.md` review:**
   - Assess source coverage by category
   - Plan next month's source acquisitions

3. **Review milestone tracking in `progress_tracker.md`:**
   - Check if on track for major milestones
   - Adjust timelines if necessary

4. **Trend analysis across weekly reviews:**
   - Review 4 weekly reviews
   - Identify productivity patterns
   - Adjust workflow if needed

---

## ⚠️ Common Issues & Troubleshooting

### Issue 1: Dashboard Files Not Showing in GitBook

**Symptoms:** "Project Management" section missing in GitBook navigation

**Solutions:**
1. Check `SUMMARY.md` syntax (correct Markdown links?)
2. Verify file paths are correct (`project_management/filename.md`)
3. Ensure files are committed and pushed to GitHub
4. Wait 2-3 minutes for GitHub → GitBook sync
5. Force refresh GitBook page (Ctrl+Shift+R)

---

### Issue 2: Word Counts Not Updating

**Symptoms:** `daily_progress.ps1` not updating trackers

**Solutions:**
1. Check if script is finding chapter files (correct paths?)
2. Ensure chapter files have content (not empty)
3. Manually update `progress_tracker.md` if script fails
4. Review script logic and adjust if needed

---

### Issue 3: Git Merge Conflicts in Dashboard Files

**Symptoms:** Git reports conflicts when pulling/pushing dashboard updates

**Solutions:**
1. If conflict is minor (word count updates), accept your local version
2. If conflict is substantial, carefully merge manually
3. To reduce conflicts: Always `git pull` before making dashboard updates
4. Consider making dashboard updates at different times than writing updates

---

### Issue 4: Feeling Overwhelmed by Dashboard

**Symptoms:** Dashboard maintenance taking too much time

**Solutions:**
1. Focus on **essential files only**: `progress_tracker.md` and `todo_list.md`
2. Skip weekly review if exceptionally busy (but don't skip 2 weeks in a row)
3. Remember: Dashboard is a tool, not a requirement - adapt to your needs
4. Automate more with PowerShell scripts if manual updates feel burdensome

---

## ✅ Deployment Checklist

Before considering deployment complete, verify:

- [ ] All 7 dashboard files created in `project_management/` folder
- [ ] `weekly_reviews/` subfolder created with README
- [ ] `SUMMARY.md` updated with Project Management section
- [ ] All files committed to Git
- [ ] Changes pushed to GitHub
- [ ] GitBook sync verified (all dashboard files visible)
- [ ] Test: Morning routine (open progress tracker, to-do list)
- [ ] Test: Evening routine (run `daily_progress`, update to-do list)
- [ ] `writing_session.ps1` script still works (not affected by new files)

---

## 🎉 Next Steps After Deployment

**Immediate (This Week):**
1. **Complete first weekly review** using the `weekly_review.md` template
   - Reflect on your progress so far
   - Set next week's top 3 priorities

2. **Begin Chapter 1, Section 1.1** (Contemporary Mating Crisis)
   - Target: 1,200-1,500 words
   - Use `writing_session` script to start

3. **Process first Jungian source** (Jung "Psychology of Transference")
   - Use AI summarization tools
   - Extract 15-20 quotes for Chapter 3

**Short-Term (Next 2-4 Weeks):**
4. **Continue Chapter 1** sections sequentially
5. **Begin Chapter 2, Section 2.1** (Darwin's framework)
6. **Process second Jungian source** (Von Franz "Projection and Re-Collection")

**Medium-Term (Next 2-3 Months):**
7. **Complete Chapter 1 first draft** (all 6 sections)
8. **Advance Chapter 2** (Sections 2.1-2.4)
9. **Unlock Chapter 3** (process remaining Jungian sources, begin writing)

---

## 📞 Support

If you encounter issues or need modifications to the dashboard:
- **Document the issue** in your next weekly review
- **Consult AI assistant** for dashboard adjustments or new tracker ideas
- **Experiment** - the dashboard is flexible and can be customized to your needs

---

**Dashboard Deployment Guide Complete**  
**Version:** 1.0  
**Date:** 2025-11-19

---

Good luck with your PhD dissertation! The infrastructure is now in place to support systematic, tracked progress across all stages of your research. 🚀📚