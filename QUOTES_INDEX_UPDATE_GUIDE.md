# Quotes Index Update - Complete Guide

## Overview

This script replaces the original `reorganize-quotes.ps1` and generates an updated quotes index based on your current dissertation structure with Jung-focused themes.

**Script**: `Update_Quotes_Index.ps1`  
**Replaces**: `reorganize-quotes.ps1`  
**Function**: Scan quotes files and regenerate complete index

---

## 🚀 Quick Start

### Step 1: Download Script
Save `Update_Quotes_Index.ps1` to:  
`C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis\`

### Step 2: Unblock and Run
```powershell
cd C:\Users\user\Documents\PhD\phd-sacred-bonds-thesis
Unblock-File .\Update_Quotes_Index.ps1
.\Update_Quotes_Index.ps1
```

### Step 3: Review and Commit
Script will ask if you want to push changes to GitHub

---

## ✅ What the Script Does

### **Automatic Operations** (6 Steps)

1. **[Step 1/6] Directory Scan**
   - Locates `quotes_by_chapter/` directory
   - Locates `quotes_by_theme/` directory
   - Verifies structure exists

2. **[Step 2/6] Chapter Quote Counting**
   - Scans all chapter markdown files
   - Counts quotes (lines starting with `>`)
   - Extracts chapter numbers and names
   - Calculates total quotes by chapter

3. **[Step 3/6] Theme Quote Counting**
   - Scans all theme markdown files
   - Counts quotes per theme
   - Extracts theme names
   - Calculates total quotes by theme

4. **[Step 4/6] Statistics Calculation**
   - Total unique quotes
   - Coverage percentages
   - Distribution analysis
   - Quality metrics

5. **[Step 5/6] Index Generation**
   - Creates navigation links
   - Generates statistics with bar charts
   - Adds usage instructions
   - Includes maintenance info

6. **[Step 6/6] File Writing & Git Commit**
   - Writes `quotes/README.md`
   - Commits changes (optional)
   - Pushes to GitHub (optional)
   - Triggers GitBook sync

---

## 📊 Expected Output Structure

### **Index File Location**
`quotes/README.md`

### **Index Sections**

1. **Header**
   - Total quote count
   - Last updated timestamp
   - Generator script name

2. **Quick Navigation**
   - By Chapter (sorted by chapter number)
   - By Theme (sorted alphabetically)
   - Direct links to quote files

3. **Statistics**
   - Chapter coverage with bar charts
   - Theme coverage with bar charts
   - Percentage breakdowns

4. **Usage Instructions**
   - For Writing
   - For Analysis
   - Cross-reference guidance

5. **Maintenance Info**
   - How to update
   - When to update
   - What gets updated

6. **Quality Metrics**
   - Coverage goals
   - Current status
   - Quality assessment

---

## 🔍 Current vs New Structure

### **Old Structure** (Original Script)
```
quotes_by_chapter/
  Chapter_01_Introduction.md
  Chapter_02_Literature_Review.md
  Chapter_03_Mating_Strategies.md
  Chapter_04_Economic_Dimensions.md
  ...

quotes_by_theme/
  Cultural_Influences.md
  Demographic_Crisis.md
  Economic_Factors.md
  Hypergamy.md
  ...
```

### **New Structure** (Current Dissertation)
```
quotes_by_chapter/
  chapter_01_introduction.md
  chapter_02_evolutionary_foundations.md
  chapter_03_archetypal_dimensions.md
  chapter_04_synchronicity.md
  chapter_05_transpersonal_dimensions.md
  chapter_06_unconscious_processes.md
  chapter_07_shadow_integration.md
  chapter_08_practical_applications.md
  ...

quotes_by_theme/
  Archetypal_Patterns.md
  Unconscious_Processes.md
  Synchronicity_Meaning.md
  Transpersonal_Dimensions.md
  Shadow_Integration.md
  ...
```

**Key Differences:**
- New Jung-focused themes
- Updated chapter structure
- Clearer scope definitions
- Cross-reference system

---

## 📋 Sample Output

### **Terminal Output**

```
========================================
Update Quotes Index
========================================

[Step 1/6] Scanning quotes directory structure...
  ✓ Found quotes directories

[Step 2/6] Scanning chapter quote files...
  ✓ Chapter 01 (Introduction): 12 quotes
  ✓ Chapter 02 (Evolutionary Foundations): 25 quotes
  ✓ Chapter 03 (Archetypal Dimensions): 28 quotes
  ✓ Chapter 04 (Synchronicity): 22 quotes
  ✓ Chapter 05 (Transpersonal Dimensions): 18 quotes
  ✓ Chapter 06 (Unconscious Processes): 24 quotes
  ✓ Chapter 07 (Shadow Integration): 20 quotes
  ✓ Chapter 08 (Practical Applications): 15 quotes

  Total quotes from chapters: 164

[Step 3/6] Scanning theme quote files...
  ✓ Archetypal Patterns: 32 quotes
  ✓ Unconscious Processes: 28 quotes
  ✓ Synchronicity Meaning: 24 quotes
  ✓ Transpersonal Dimensions: 26 quotes
  ✓ Shadow Integration: 22 quotes

  Total quotes from themes: 132

[Step 4/6] Calculating statistics...
  ✓ Total unique quotes: 164

[Step 5/6] Generating updated index...
  ✓ Index content generated

[Step 6/6] Writing updated index...
  ✓ Created quotes directory
  ✓ Index written to: quotes/README.md
  ✓ File size: 8.5 KB

[Optional] Committing changes to git...
  ✓ Changes committed
  
  Push changes to GitHub? (y/n): y
  ✓ Changes pushed to GitHub
  ✓ GitBook will sync in 2-5 minutes

========================================
Quotes Index Update Complete!
========================================

Summary:
  • Total Quotes: 164
  • Chapter Files: 8
  • Theme Files: 5
  • Index Location: quotes/README.md
  • Last Updated: 2025-11-29 15:30:00

Chapter Breakdown:
  • Chapter 01 (Introduction): 12 quotes
  • Chapter 02 (Evolutionary Foundations): 25 quotes
  • Chapter 03 (Archetypal Dimensions): 28 quotes
  • Chapter 04 (Synchronicity): 22 quotes
  • Chapter 05 (Transpersonal Dimensions): 18 quotes

Top Themes:
  • Archetypal Patterns: 32 quotes
  • Unconscious Processes: 28 quotes
  • Transpersonal Dimensions: 26 quotes
  • Synchronicity Meaning: 24 quotes
  • Shadow Integration: 22 quotes

Next Steps:
  1. View updated index: notepad quotes/README.md
  2. Verify quote counts are accurate
  3. Review theme coverage
  4. Check GitBook after sync (if pushed)

GitBook URL: https://app.gitbook.com/o/cyZpWhV7KomErB6BnmVk/s/hRoSpCiTUrfuH62swMvH/
```

---

## 🛠️ Troubleshooting

### **Issue 1: Quotes Directory Not Found**

**Symptoms**:
```
✗ Error: quotes_by_chapter directory not found!
```

**Solution**:
```powershell
# Check current structure
Get-ChildItem -Directory | Select-Object Name

# If quotes are in different location, adjust script paths
# Or create expected structure:
New-Item -ItemType Directory -Path "quotes_by_chapter" -Force
New-Item -ItemType Directory -Path "quotes_by_theme" -Force
```

---

### **Issue 2: No Quotes Found**

**Symptoms**:
```
⚠ Warning: No quotes found!
Total unique quotes: 0
```

**Causes**:
1. Quote files don't use `>` prefix
2. Files are empty
3. Wrong file format

**Solution**:
```powershell
# Check quote file format
Get-Content "quotes_by_chapter\chapter_01_introduction.md"

# Quotes should look like:
# > "This is a quote from a source"
# > — Author (Year)

# If different format, adjust regex in script line 69:
# Change: $_ -match "^>\s+"
# To match your format
```

---

### **Issue 3: Wrong Chapter/Theme Names**

**Symptoms**:
- Chapter names display as filenames
- Theme names not formatted correctly

**Solution**:
Script tries to extract names from:
1. First heading in file (`# Chapter X: Name`)
2. Filename (fallback)

**To fix**, ensure files have proper headings:

```markdown
# Chapter 4: Synchronicity and Meaningful Coincidences

> "Quote text here..."
```

Or:

```markdown
# Archetypal Patterns

> "Quote text here..."
```

---

### **Issue 4: Git Commit Failed**

**Symptoms**:
```
⚠ Git operation skipped: [error]
```

**Solution**:
```powershell
# Manual commit
git add quotes/README.md
git commit -m "Update quotes index"
git push origin main
```

---

## 📊 Understanding Quote Counts

### **Why Chapter Total ≠ Theme Total**

- **Chapter Totals**: Unique quotes (authoritative count)
- **Theme Totals**: May include duplicates (same quote in multiple themes)

**Example**:
- Quote about archetypes in relationships
- Appears in Chapter 3 (counted once)
- Referenced in both:
  - `Archetypal_Patterns.md`
  - `Unconscious_Processes.md`
- Total chapter quotes: 1
- Total theme quotes: 2 (same quote counted in each theme)

**Script uses chapter count as authoritative** to avoid inflation

---

## 🎯 When to Run This Script

### **Regular Schedule**
- **Weekly**: During active writing/quote collection
- **Before meetings**: Committee presentations
- **After reorganization**: Major quote file changes

### **Specific Triggers**
✅ Added new quote files  
✅ Reorganized existing quotes  
✅ Renamed chapter/theme files  
✅ Changed quote formats  
✅ Merged or split quote files  

### **GitBook Updates**
- Run before sharing GitBook links
- Ensure index reflects current structure
- Allow 2-5 minutes for sync after push

---

## 💡 Best Practices

### **Quote File Organization**

1. **Consistent Format**
   ```markdown
   # Chapter X: Title
   
   ## Section 1
   
   > "Quote text here..."
   > — Author (Year), p. XX
   
   **Context**: Brief explanation
   **Relevance**: How it supports thesis
   ```

2. **Clear Headers**
   - Always include chapter number and name
   - Use proper heading hierarchy
   - Maintain consistent naming

3. **Quote Prefixes**
   - Always start quotes with `>`
   - Include citation information
   - Add context when helpful

### **Theme File Organization**

1. **Scope Definition**
   ```markdown
   # Archetypal Patterns
   
   > **THEME DEFINITION**: Universal, inherited structures...
   
   ## Scope
   
   **Includes**: ...
   **Excludes**: ...
   ```

2. **Cross-References**
   - Link to related themes
   - Link to relevant chapter quotes
   - Reference Jung analyses

3. **Thematic Organization**
   - Group quotes by subtopic
   - Show conceptual development
   - Highlight patterns

---

## 📈 Quality Metrics Interpretation

### **Coverage Quality**

**Excellent** (100+ quotes):
- ✅ Comprehensive coverage
- ✅ Multiple perspectives per topic
- ✅ Strong evidential support

**Good** (50-100 quotes):
- ✅ Adequate coverage
- ⚠️ May need more depth in some areas
- ✅ Supports main arguments

**Needs Improvement** (<50 quotes):
- ⚠️ Insufficient coverage
- ❌ Gaps in support
- 🔄 Requires more quote collection

### **Distribution Goals**

**Chapters**:
- Major chapters (3-7): 20-30 quotes each
- Intro/Conclusion: 10-15 quotes each
- Synthesis: 15-20 quotes

**Themes**:
- Core themes: 25-35 quotes each
- Supporting themes: 15-25 quotes each
- Specialized themes: 10-20 quotes each

---

## 🔗 Integration with Dissertation Workflow

### **Quote Collection Phase**
1. Read sources
2. Extract relevant quotes
3. Add to chapter files
4. **Run update script**
5. Verify in index

### **Chapter Drafting Phase**
1. Review chapter quote file
2. Cross-reference theme files
3. Draft using quotes
4. Add new quotes as needed
5. **Run update script**

### **Revision Phase**
1. Review quote distribution
2. Identify gaps
3. Add missing quotes
4. Remove unused quotes
5. **Run update script**
6. Verify coverage

---

## 📞 Support

### **Common Questions**

**Q: How often should I update the index?**  
A: Weekly during active work, or whenever you add/reorganize quotes

**Q: Why are theme totals higher than chapter totals?**  
A: Same quote can appear in multiple themes (cross-cutting concepts)

**Q: Can I customize the output format?**  
A: Yes, edit the `$indexContent` variable in the script (starts around line 136)

**Q: What if I have different directory names?**  
A: Update `$quotesByChapterPath` and `$quotesByThemePath` variables (lines 20-21)

**Q: How do I add new statistics?**  
A: Modify the statistics section (lines 220-280)

---

## 🎓 Your Quote Collection Status

Based on your previous index:

**Original Structure**:
- Total: 111 quotes
- 10 chapters
- 10 themes
- Last updated: 2025-11-23

**After Running New Script**:
- Will reflect current Jung-focused structure
- Updated theme names
- Current chapter organization
- Fresh timestamp

**Expected Improvements**:
- More accurate counts
- Better organization
- Jung-aligned themes
- Cross-reference support

---

## 📅 Recommended Workflow

### **Daily** (if actively adding quotes)
```powershell
# Quick check - don't need to commit
.\Update_Quotes_Index.ps1
# Press 'n' when asked to push
```

### **Weekly** (regular maintenance)
```powershell
# Full update with commit
.\Update_Quotes_Index.ps1
# Press 'y' to push to GitHub/GitBook
```

### **Before Meetings** (ensure current)
```powershell
# Update and push
.\Update_Quotes_Index.ps1
# Press 'y' to push
# Wait 2-5 minutes for GitBook sync
# Share GitBook link with confidence
```

---

*Guide created: 2025-11-29*  
*Script: Update_Quotes_Index.ps1*  
*Replaces: reorganize-quotes.ps1*  
*Execution time: ~10-30 seconds*
