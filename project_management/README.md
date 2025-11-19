# Project Management Dashboard

**Last Updated:** 2025-11-19

---

## 🎯 Purpose

This folder contains the **Project Management Dashboard** for the "Sacred Bonds and Sexual Selection" PhD dissertation. The dashboard provides centralized tracking, planning, and progress monitoring across all stages of the research pipeline.

---

## 📂 Dashboard Files

### 1. **progress_tracker.md** 📊
**Master progress overview** across the entire dissertation.

**Contents:**
- Overall dissertation progress (word count, completion %)
- Progress by research pipeline stage (Stages 1-7)
- Progress by chapter (Chapters 1-8)
- Source processing progress
- Quick metrics dashboard
- Milestone tracking

**Update Frequency:** After each work session (via `daily_progress.ps1`)

**When to Use:**
- Daily: Check current status before starting work
- Weekly: Full review and update during weekly review
- Monthly: Assess milestone progress and adjust timelines

---

### 2. **todo_list.md** ✅
**Action-oriented task list** organized by priority and stage.

**Contents:**
- Critical priority tasks (this week)
- High priority tasks (next 2 weeks)
- Medium priority tasks (next month)
- Ongoing/recurring tasks
- Blocked tasks (with dependencies)
- Completed tasks (last 2 weeks)

**Update Frequency:** Daily additions, weekly reorganization

**When to Use:**
- Daily: Start each work session by reviewing Critical/High priorities
- Weekly: Re-prioritize and move completed tasks during weekly review
- As needed: Add new tasks when they arise

---

### 3. **stage_status.md** 🔄
**Detailed breakdown of each workflow stage** (Stages 1-7).

**Contents:**
- Status, completion %, and health indicator for each stage
- Purpose and completion criteria per stage
- Current progress metrics
- Blockers and mitigation strategies
- Tools and workflow notes

**Update Frequency:** Weekly during weekly review

**When to Use:**
- Weekly: Full review during weekly review process
- When transitioning between stages (e.g., Stage 2 → Stage 3)
- When assessing blockers or planning next phase

---

### 4. **chapter_tracker.md** 📖
**Granular chapter-by-chapter progress** for all 8 chapters.

**Contents:**
- Metadata: word count, target, progress %, status, dependencies
- Section-by-section progress breakdown
- Citation metrics (planned vs. actual)
- Quality checklist per chapter
- Next actions for each chapter

**Update Frequency:** Weekly or after significant chapter progress

**When to Use:**
- Before starting work on a specific chapter: Review section plan
- After completing a section: Update section progress
- Weekly: Update word counts and reassess priorities
- During Stage 3 (Chapter Development): Primary reference document

---

### 5. **source_inventory.md** 📚
**Complete inventory of all sources** (processed, in queue, needed).

**Contents:**
- Sources processed (with summaries and quote counts)
- Sources in queue (acquired, not yet processed)
- Sources needed (prioritized: Critical → High → Medium)
- Source inventory summary table
- Immediate next steps for source acquisition
- Processing checklist and timeline

**Update Frequency:** After each source is processed, monthly review

**When to Use:**
- Before starting source processing: Identify next priority source
- Monthly: Assess source coverage and plan acquisitions
- When blocked on writing: Check if source gap is causing the block
- During Stage 1-2: Primary reference for source pipeline

---

### 6. **weekly_review.md** (Template) 📅
**Weekly reflection and planning template** for systematic review.

**Contents:**
- This week's metrics (targets vs. actuals)
- Accomplishments and wins
- Challenges encountered and resolutions
- Progress assessment and ratings
- Reflections (what worked, what didn't, lessons learned)
- Next week's goals and priorities
- Schedule preview

**Update Frequency:** Weekly (every Friday or Sunday)

**When to Use:**
- End of week: Complete full review (30-45 minutes)
- Beginning of week: Reference next week's goals
- Monthly: Review multiple weeks to identify trends

**Note:** Archive completed reviews in `weekly_reviews/` subfolder with date-stamped filenames (e.g., `2025-11-19_weekly_review.md`)

---

## 🔄 Dashboard Workflow

### Daily Workflow

```
Morning (5-10 minutes):
1. Open progress_tracker.md - Check overall status
2. Open todo_list.md - Identify today's Critical/High priorities
3. Open chapter_tracker.md - Review target chapter/section details
4. Begin work session

Evening (5 minutes):
5. Run daily_progress.ps1 - Update word counts
6. Update todo_list.md - Check off completed tasks, add new ones
7. Git commit and push - Backup progress
```

---

### Weekly Workflow

```
Friday or Sunday (30-45 minutes):
1. Complete weekly_review.md template
   - Fill in metrics, accomplishments, challenges
   - Assess progress and set next week's goals
   
2. Update progress_tracker.md based on weekly review
   - Update chapter word counts
   - Update stage progress percentages
   - Check milestone status
   
3. Update stage_status.md
   - Reassess stage health indicators
   - Update blockers and mitigation strategies
   
4. Reorganize todo_list.md
   - Re-prioritize tasks based on weekly review
   - Move completed tasks to archive section
   - Add new tasks for next week
   
5. Review source_inventory.md
   - Check if sources processed this week
   - Confirm next week's source priorities
   
6. Archive completed weekly_review.md to weekly_reviews/ folder
   
7. Git commit and push all dashboard updates
```

---

### Monthly Workflow

```
First Sunday of Month (60 minutes):
1. Full review of chapter_tracker.md
   - Assess word count targets vs. actuals
   - Adjust targets if needed (be realistic)
   - Update section completion statuses
   
2. Comprehensive source_inventory.md review
   - Assess source coverage by category
   - Identify critical gaps
   - Plan source acquisitions for next month
   
3. Review milestone tracking in progress_tracker.md
   - Check if on track for major milestones
   - Adjust target dates if necessary
   - Document reasons for timeline changes
   
4. Trend analysis across weekly reviews
   - Identify patterns in productivity
   - Note recurring challenges
   - Adjust workflow if needed
   
5. Update all trackers based on monthly assessment
   
6. Git commit and push all updates
```

---

## 🎯 How to Use This Dashboard

### Starting a New Work Session
1. **Navigate:** `phd` (in PowerShell)
2. **Sync:** `git pull`
3. **Check Dashboard:** Open `progress_tracker.md` and `todo_list.md`
4. **Identify Target:** Choose today's priority from todo list
5. **Start Session:** `writing_session` (opens relevant files)

### Ending a Work Session
1. **Track Progress:** Run `daily_progress.ps1`
2. **Update To-Do:** Check off completed tasks in `todo_list.md`
3. **Commit Work:** `git add . && git commit -m "[description]"`
4. **Push:** `git push`

### When Feeling Lost or Overwhelmed
1. **Open `progress_tracker.md`** - See big picture progress
2. **Review `stage_status.md`** - Understand current stage focus
3. **Check `todo_list.md` Critical Priority** - Identify immediate next action
4. **Consult `chapter_tracker.md`** - Get detailed guidance for specific chapter

### When Blocked on Writing
1. **Check `source_inventory.md`** - Is there a source gap?
2. **Review `stage_status.md`** - Are you in the right stage for this task?
3. **Consult `chapter_tracker.md`** - Are dependencies met for this chapter?

---

## 📊 Integration with GitBook

All dashboard files are:
- **Stored in:** `project_management/` folder in Git repository
- **Linked in:** GitBook's `SUMMARY.md` under "Project Management" section
- **Accessible via:** GitBook web interface at https://[your-gitbook-url]/project-management
- **Version controlled:** All changes tracked in Git history
- **Cloud synced:** Automatically backed up to GitHub

**Benefits:**
- Access dashboard from any device via GitBook web interface
- Historical tracking via Git commits
- No risk of data loss (version controlled + cloud backup)
- Professional presentation in GitBook format

---

## 🛠️ Automation Opportunities

**Current Scripts:**
- `daily_progress.ps1` - Tracks word counts automatically
- `writing_session.ps1` - Opens relevant files for writing
- `sync_workflow.ps1` - Handles Git sync operations

**Future Automation Ideas:**
- `update_dashboard.ps1` - Automatically updates word counts in all trackers
- `weekly_report.ps1` - Generates weekly summary report
- `next_task.ps1` - Displays next priority task on PowerShell startup
- `milestone_check.ps1` - Alerts if falling behind on milestones

---

## 📝 Best Practices

### Do's ✅
- ✅ Update trackers consistently (daily/weekly rhythm)
- ✅ Be honest about progress and challenges
- ✅ Celebrate small wins in weekly reviews
- ✅ Adjust targets if consistently missing them (be realistic)
- ✅ Use dashboard to maintain focus on priorities
- ✅ Commit dashboard updates to Git regularly

### Don'ts ❌
- ❌ Don't let trackers fall out of date (they become useless)
- ❌ Don't set unrealistic targets (leads to demoralization)
- ❌ Don't skip weekly reviews (critical for course correction)
- ❌ Don't obsess over perfection (progress > perfection)
- ❌ Don't ignore blockers (address them early)

---

## 🔗 Quick Links

**Dashboard Files:**
- [Progress Tracker](progress_tracker.md)
- [To-Do List](todo_list.md)
- [Stage Status](stage_status.md)
- [Chapter Tracker](chapter_tracker.md)
- [Source Inventory](source_inventory.md)
- [Weekly Review Template](weekly_review.md)

**Other Key Project Files:**
- [Dissertation README](../README.md)
- [Quote Database](../quotes/README.md)
- [Source Summaries](../notes/reading_notes/by_source/README.md)
- [Chapter Files](../chapters/)

---

## 📧 Questions or Issues?

If you encounter issues with the dashboard system or have ideas for improvements:
1. Document the issue/idea in your current weekly review
2. Consider if a new automation script would help
3. Consult AI assistant for dashboard modifications or new trackers

---

**Remember:** The dashboard is a tool to **support** your work, not replace it. Use it to maintain clarity, track progress, and stay focused on priorities—but don't let dashboard maintenance become more time-consuming than actual writing!

---

**Dashboard Version:** 1.0  
**Created:** 2025-11-19  
**Last Major Update:** 2025-11-19
# project\_management

