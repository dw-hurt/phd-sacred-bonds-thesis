# To-Do List - Sacred Bonds Thesis

**Last Updated:** 2025-11-19

---

## 🔥 Critical Priority (This Week)

### Stage 2: Complete Integration Foundation

- [ ] **Process Jungian Source #1** (Est: 3-4 hours)
  - **Source:** Jung, C.G. - "The Psychology of the Transference" or "Mysterium Coniunctionis" excerpts
  - **Action:** Find PDF, process through AI summarization, extract quotes
  - **Output:** `notes/reading_notes/by_source/jung_[year]_[title]_summary.md`
  - **Dependencies:** None
  - **Note:** This unblocks Chapter 3 material

- [ ] **Process Jungian Source #2** (Est: 3-4 hours)
  - **Source:** Von Franz, M.L. - "The Interpretation of Fairy Tales" or "Projection and Re-Collection in Jungian Psychology"
  - **Action:** Find PDF, process through AI summarization, extract quotes
  - **Output:** `notes/reading_notes/by_source/vonfranz_[year]_[title]_summary.md`
  - **Dependencies:** None

- [ ] **Extract Quotes for Chapter 3** (Est: 2 hours)
  - **Action:** Review processed Jungian sources, extract relevant quotes
  - **Output:** Populate `quotes/by_chapter/chapter_03_quotes.md` (target: 15-20 quotes)
  - **Dependencies:** Jungian sources #1 & #2 processed

---

## ⚡ High Priority (Next 2 Weeks)

### Stage 2: Expand Archetypal/Transpersonal Foundation

- [ ] **Process Synchronicity Source #1** (Est: 2-3 hours)
  - **Source:** Jung, C.G. - "Synchronicity: An Acausal Connecting Principle"
  - **Action:** Process core text on synchronicity
  - **Output:** `notes/reading_notes/by_source/jung_1952_synchronicity_summary.md`
  - **Dependencies:** None

- [ ] **Process Transpersonal Source #1** (Est: 3-4 hours)
  - **Source:** Grof, S. - "Psychology of the Future" or "The Cosmic Game"
  - **Action:** Focus on transpersonal dimensions of relationships
  - **Output:** `notes/reading_notes/by_source/grof_[year]_[title]_summary.md`
  - **Dependencies:** None

- [ ] **Extract Quotes for Chapter 4** (Est: 1-2 hours)
  - **Action:** Extract synchronicity-related quotes
  - **Output:** Populate `quotes/by_chapter/chapter_04_quotes.md` (target: 10-15 quotes)
  - **Dependencies:** Synchronicity source processed

- [ ] **Extract Quotes for Chapter 5** (Est: 1-2 hours)
  - **Action:** Extract transpersonal-related quotes
  - **Output:** Populate `quotes/by_chapter/chapter_05_quotes.md` (target: 10-15 quotes)
  - **Dependencies:** Transpersonal source processed

### Stage 3: Begin Chapter Writing

- [ ] **Chapter 1: Draft Introduction Section** (Est: 3-4 hours)
  - **Section:** 1.1 - The Problem: Contemporary Mating Crisis
  - **Target:** 1,200-1,500 words
  - **Dependencies:** None (can start now)
  - **Output:** `chapters/01_introduction/chapter_01_introduction.md` (Section 1.1 completed)

- [ ] **Chapter 1: Draft Research Questions Section** (Est: 2-3 hours)
  - **Section:** 1.2 - Research Questions
  - **Target:** 800-1,000 words
  - **Dependencies:** Section 1.1 drafted
  - **Output:** `chapters/01_introduction/chapter_01_introduction.md` (Section 1.2 completed)

---

## 📋 Medium Priority (Next Month)

### Stage 2: Complete Source Processing

- [ ] **Process Evolutionary Psychology Source #3** (Est: 3-4 hours)
  - **Source:** TBD (e.g., additional Buss chapter, or Trivers)
  - **Action:** Process to reinforce biological foundation
  - **Output:** `notes/reading_notes/by_source/[author]_[year]_[title]_summary.md`

- [ ] **Process Contemporary Research Source #1** (Est: 2-3 hours)
  - **Source:** Recent papers on dating apps, modern relationships
  - **Action:** Process for Chapter 6 material
  - **Output:** `notes/reading_notes/by_source/[author]_[year]_[title]_summary.md`

### Stage 3: Expand Chapter Writing

- [ ] **Chapter 2: Draft Section 2.1** (Est: 4-5 hours)
  - **Section:** Darwin's Sexual Selection Framework
  - **Target:** 4,000-5,000 words
  - **Dependencies:** Chapter 1 drafted, all Chapter 2 quotes reviewed

- [ ] **Chapter 1: Complete Full Draft** (Est: 8-10 hours total)
  - **Action:** Draft all 6 sections of introduction
  - **Target:** 8,000-10,000 words total
  - **Dependencies:** Research questions defined, thesis structure clear

---

## 🔄 Ongoing / Recurring Tasks

### Daily Workflow

- [ ] **Daily Progress Tracking**
  - **Frequency:** End of each work session
  - **Action:** Run `daily_progress.ps1` script
  - **Output:** Updated word counts in progress tracker

- [ ] **Git Sync**
  - **Frequency:** End of each work session
  - **Action:** `git add . && git commit -m "[description]" && git push`
  - **Output:** Repository backed up to GitHub, GitBook synced

### Weekly Workflow

- [ ] **Weekly Review** (Every Friday)
  - **Action:** Complete `weekly_review.md` template
  - **Duration:** 30-45 minutes
  - **Output:** Reflection on week's progress, next week's priorities

- [ ] **Update Trackers** (Every Sunday)
  - **Action:** Review and update `progress_tracker.md`, `todo_list.md`, `stage_status.md`
  - **Duration:** 30 minutes
  - **Output:** Accurate status for new week

- [ ] **Zotero Maintenance** (Weekly)
  - **Action:** Add new sources to library, update collections, check auto-export
  - **Duration:** 15 minutes
  - **Output:** `references.bib` up to date

### Monthly Workflow

- [ ] **Chapter Tracker Review** (First Sunday of month)
  - **Action:** Full review of `chapter_tracker.md`, assess word count targets
  - **Duration:** 1 hour
  - **Output:** Adjusted chapter targets and timelines

- [ ] **Source Inventory Update** (Monthly)
  - **Action:** Review `source_inventory.md`, identify gaps, prioritize next sources
  - **Duration:** 45 minutes
  - **Output:** Updated source queue

---

## 🚫 Blocked Tasks (Waiting on Dependencies)

- **Chapter 3 Writing** - Blocked until Jungian sources processed and quotes extracted
- **Chapter 4 Writing** - Blocked until Synchronicity sources processed
- **Chapter 5 Writing** - Blocked until Transpersonal sources processed
- **Chapter 6 Writing** - Blocked until Chapters 2-5 have substantial drafts (need to analyze gap)
- **Chapter 7 Writing** - Blocked until all content chapters (2-6) have first drafts

---

## ✅ Completed Tasks (Last 2 Weeks)

- ✅ Set up Git/GitHub/GitBook infrastructure
- ✅ Create PowerShell workflow scripts (`sync_workflow.ps1`, `writing_session.ps1`, `daily_progress.ps1`)
- ✅ Install and configure Zotero with Better BibTeX
- ✅ Process Gangestad & Simpson (2000) - Evolutionary psychology source
- ✅ Process Buss (2023) - Sexual selection strategies source
- ✅ Extract 28 quotes for Chapter 2
- ✅ Create chapter templates for all 8 chapters
- ✅ Create project management dashboard files
- ✅ Fix GitBook sync issues (SUMMARY.md duplicates, missing READMEs)
- ✅ Create placeholder quote files for Chapters 3, 4, 5

---

## 📝 Notes

**Task Prioritization Logic:**
- **Critical:** Unblocks major workflow stages, foundational material
- **High:** Required for near-term writing, fills knowledge gaps
- **Medium:** Enhances quality, prepares for later stages

**Time Estimates:**
- Source processing: 2-4 hours per source (depending on length/complexity)
- Quote extraction: 1-2 hours per chapter
- Section drafting: 2-5 hours per section (depending on word count target)
- Chapter drafting: 8-15 hours per chapter total

**How to Use This List:**
1. Start each work session by reviewing Critical and High priority tasks
2. Complete at least one Critical task per week
3. Move completed tasks to "Completed Tasks" section (keep last 2 weeks for motivation)
4. Re-prioritize weekly based on progress and blockers
5. 