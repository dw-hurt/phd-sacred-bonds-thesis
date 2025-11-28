# PhD Thesis Automation Scripts

This directory contains PowerShell scripts for automating thesis management and GitBook integration.

## Active Scripts

### Weekly_Dissertation_Update.ps1
**Purpose**: Automated weekly progress summary generation and GitBook sync
**Usage**: 
```powershell
.\Weekly_Dissertation_Update.ps1 -Preview  # Preview changes
.\Weekly_Dissertation_Update.ps1 -Apply    # Apply changes
```
**Schedule**: Run weekly to update progress summary

### Diagnose_Progress_Summary.ps1
**Purpose**: Diagnose GitBook sync issues and validate SUMMARY.md links
**Usage**: 
```powershell
.\Diagnose_Progress_Summary.ps1
```
**When to use**: When content doesn't appear in GitBook

### Extract_And_Update_Progress_Summary.ps1
**Purpose**: Generate undated progress summaries from repository analysis
**Usage**: 
```powershell
.\Extract_And_Update_Progress_Summary.ps1
```

### Add_Future_Research_To_GitBook.ps1
**Purpose**: Integrate future research directions into GitBook
**Usage**: 
```powershell
.\Add_Future_Research_To_GitBook.ps1
```

## Integration Guides

See \docs/integration_guides/THOMPSON_INTEGRATION_GUIDE.md\ for detailed integration workflows.

## Maintenance

- Keep scripts in this directory for easy access
- Archive completed integration scripts to \rchive/integration_scripts/\
- Document new scripts in this README
