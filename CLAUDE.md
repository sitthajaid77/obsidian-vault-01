# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## Content Creation Guidelines

> **IMPORTANT:** When creating or importing content:

- **Language:** Use English for all content (Thai only when explicitly requested or in quotes)
- Record ONLY actual information that was provided or requested
- Do NOT add supplementary content unless explicitly asked
- Do NOT add sections like:
  - Benefits/Advantages
  - Code examples (unless requested)
  - Usage examples (unless requested)
  - Best practices (unless requested)
  - Additional explanations beyond what was asked
- Keep content minimal and factual
- Follow the "kb-minimal" template principle strictly

**ALLOWED additions:**

- Internal Docs references using Obsidian wiki-links (`[[folder/filename]]`)
- Frontmatter metadata (type, category, tags, dates, status, priority)
- Section structure from templates (`## Overview`, `## Technical Details`, `## Reference`, `## Notes`)

---

## Repository Overview

This is an Obsidian vault for technical documentation and knowledge management related to streaming/media platform development. It covers CDN, set-top boxes, mobile apps, OVP (Open Video Platform), storage, and test automation.

---

## Vault Structure

### Knowledge Base Folders

| Folder | Description |
|--------|-------------|
| `kb-cdn/` | CDN infrastructure and monitoring (Zabbix) |
| `kb-stb/` | Set-top box apps, DRM, DNS, device specs |
| `kb-mobile/` | iOS/Android, Chromecast, AirPlay, watermark SDK |
| `kb-mw/` | Middleware |
| `kb-ovp/` | Open video platform, content manipulation |
| `kb-storage/` | Storage requirements |
| `kb-robot-automate/` | Robot Framework testing, Copilot-assisted test generation |

> **Note:** Additional `kb-*` folders can be added as needed for new knowledge domains.

### Work Documentation

| Folder | Description |
|--------|-------------|
| `WorkLog/` | Weekly work logs (format: `YYYY-MM-DD_to_YYYY-MM-DD.md`) — Personal work logs by Sittha |
| `WorkAssignment/` | Task assignments — Work assigned to team members by Sittha |

### Other Folders

| Folder | Description |
|--------|-------------|
| `templates/` | Note templates for Templater plugin |

---

## Work Organization

### Task Status Workflow

All work items (WorkLog, WorkAssignment) follow a standardized status progression:

| Status | Description | When to Use |
|--------|-------------|-------------|
| **Investigating** | Researching root cause or gathering requirements | Initial phase when problem/requirement is unclear |
| **Root Cause Identified** | Investigation complete, solution approach known | After investigation phase, before implementation |
| **In Progress** | Actively developing/implementing | Working on the actual fix or feature |
| **Code Review / Testing** | Implementation done, awaiting review or testing | After development, before staging deployment |
| **Staging** | Deployed to staging environment | After passing initial tests, before production |
| **Blocked** | Waiting for third party or external dependency | Cannot proceed due to external factors |
| **Production** | Deployed to production and verified | Task fully completed and live |
| **Completed** | Task finished (may not reach production if not applicable) | For tasks that don't have production deployment |

**Status Transition Rules:**
- Always specify which status a task is in when updating
- When moving between statuses, add date and brief reason
- Blocked tasks must specify what/who they're waiting for
- Never skip from "Investigating" directly to "Production" without intermediate steps

### Definition of Done

Different types of tasks have different completion criteria:

| Task Type | Definition of Done |
|-----------|-------------------|
| **Bug Fix** | Code merged + Staging verified + Production deployed + No regression |
| **Feature Development** | Requirements met + Code reviewed + Staging tested + Production deployed + Documentation updated |
| **Investigation** | Root cause identified + Solution approach documented + Next steps defined |
| **POC/Prototype** | Concept validated + Technical feasibility confirmed + Findings documented |
| **Configuration Change** | Change applied + Verified in target environment + Rollback plan tested |
| **Third-party Integration** | Integration complete + End-to-end tested + Partner confirmed working |

**Important Notes:**
- Mark task as "Staging" not "Completed" if it hasn't reached production yet
- Mark task as "Root Cause Identified" not "Completed" if you found the problem but haven't fixed it
- Specify the Definition of Done level achieved when closing tasks

### WorkLog

- **Purpose:** Personal work logs documenting Sittha's own tasks, progress, and activities
- **Format:** Weekly logs named `YYYY-MM-DD_to_YYYY-MM-DD.md`
- **Content:** Daily notes, completed tasks, ongoing work, blockers, decisions
- **Update requirement:** Always include date when updating
- **Status tracking:** Use status indicators from Task Status Workflow section

### WorkAssignment

- **Purpose:** Tasks assigned by Sittha to team members
- **Content:** Assignment details, assignee, deadlines, status tracking
- **Update requirement:** Always include date when updating
- **Structure:** Use four sections to track tasks:
  - `## In Progress` - Active tasks currently being worked on
  - `## Blocked / Waiting` - Tasks waiting for third party or external dependencies (specify what/who)
  - `## Completed This Week` - Tasks completed during the current week
  - `## Notes` - Additional context, decisions, or important information
- **Task status indicators:**
  - Use emoji/prefix to indicate status: `[Investigating]`, `[Root Cause Found]`, `[Developing]`, `[Staging]`, `[Production]`
  - For blocked tasks, always specify: what you're waiting for, who owns it, expected timeline if known
- **Task completion workflow:**
  - When a task is completed, **MOVE it** from current section to "Completed This Week"
  - **NEVER delete** completed tasks - always preserve the history
  - Add completion details: date, final status (Staging/Production), outcome
  - Specify which Definition of Done level was achieved
  - This ensures visibility of what was logged and accomplished
- **Blocked task workflow:**
  - Move blocked tasks to "Blocked / Waiting" section immediately
  - Specify: `Blocked by: [person/team/system]`, `Waiting for: [specific action]`, `Expected: [timeline if known]`
  - Update regularly with latest status from blocking party
  - Move back to "In Progress" when unblocked

---

## Team Members

Reference names for team members mentioned in WorkLog and WorkAssignment:

| Name in Code | Thai Name | Notes |
|--------------|-----------|-------|
| Koi | กอย | Not "ก้อย" |
| Teohong | เตียวฮง | Not "เตียวหง" |
| Faii | ฝ้าย | |
| Pim | พิม | |
| Nuch & Bew | นุช & บิว | |

---

## Document Conventions

### Update Requirements

> **CRITICAL:** Every update to any document MUST include a date stamp.

| Context | Format |
|---------|--------|
| General | `**Date Updated:** YYYY-MM-DD` or `**Updated:** YYYY-MM-DD HH:MM` |
| WorkLog | Date is inherent in the weekly structure |
| WorkAssignment | Add update date when status changes or new information is added |
| KB articles | Add `**Date Updated:** YYYY-MM-DD` in the relevant section |

### Templates

Use Templater plugin syntax:

| Template | Purpose |
|----------|---------|
| `kb-minimal.md` | Default for new KB articles (record only actual information) |
| `kb-readme.md` | Index pages for KB folders |
| `kb-technical.md` | Detailed technical documentation |
| `issue-investigation.md` | Issue tracking with timeline, root cause, solution |
| `weekly-worklog.md` | Weekly work logs (personal tasks by Sittha) |
| `work-assignment.md` | Weekly work assignments (tasks assigned to team members) |

### Frontmatter Structure

```yaml
type: kb | kb-index | worklog | issue | assignment
category: <folder-name>
tags: []
date_created: YYYY-MM-DD
last_updated: YYYY-MM-DD
status: active
priority: medium
```

### KB Writing Guidelines

*Reference: kb-guideline.md*

- Use `kb-minimal` as default template
- **Tags format:** Write tags directly without HTML comments
  - Correct: `#tag1 #tag2 #tag3`
  - Wrong: `<!-- #tag1 #tag2 #tag3 -->`
- Record only actual information — no placeholders or generic examples
- **Language Requirements:**
  - Default: **English** for all content
  - Thai allowed only when:
    - User explicitly requests Thai
    - Quoting Thai content (e.g., "Faii (ฝ้าย) demonstrated...")
    - In WorkLog entries (which are naturally in Thai)
  - Internal Docs references can be in any language (they're just links)
- **NEVER add unsolicited content:**
  - No benefits/advantages sections
  - No code examples unless requested
  - No usage examples unless requested
  - No best practices unless requested
  - No additional explanations beyond what was asked
- Stick strictly to the information provided by the user
- **Always include dates when updating:** `**Date Updated:** YYYY-MM-DD`
- Tags: use kebab-case (`#robot-framework` not `#Robot Framework`)
- Always include Internal Docs references; External Links only when requested
- Sections are optional except Overview and Internal Docs references

### Linking

- Use Obsidian wiki-links: `[[filename]]` or `[[folder/filename]]`
- Reference related docs in `## Reference > ### Internal Docs` section

---

## Key Domain Knowledge

### STB (Set-Top Box)

- **Platform:** Android-based STB (912 STB, Android TV)
- App uses WebView component — crashes can occur during WebView package updates
- DRM-protected content cannot be screen captured on 912 STB; ATV blocks all capture

### Mobile / Casting

- Chromecast/AirPlay implementation with watermark SDK (FMTS)
- FMTS watermark handled on receiver app (not sender) — DRM session tied to display device
- Axinom CSL concurrency: AirPlay treated as device transition (not session continuation)

### Testing

Robot Framework with AI-assisted test generation workflow:

```
Test Case → Docmost → Copilot → Robot Framework Script → Execution
```
