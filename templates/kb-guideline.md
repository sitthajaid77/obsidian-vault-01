# Knowledge Base Guideline

## Principles

### Use kb-minimal.md as default

**Rule:** Record only actual information. Do NOT include placeholder, example, configuration, benefits, or external links unless explicitly instructed.

---

## Basic Structure (Always Include)

```markdown
---
frontmatter (metadata)
---

# Title

## Tags

## Overview
[Brief summary]

## Technical Details
[Actual details only]

## Reference
### Internal Docs
[Links to related vault docs]

## Notes
[Chronological notes]
```

---

## Optional Sections (Only when explicitly requested)

### Examples
- **Include when:** Explicitly requested or have actual working code/config
- **Skip:** Generic examples or placeholder code

### Configuration
- **Include when:** Explicitly requested or have actual config used
- **Skip:** Template configs or examples

### Architecture/Design
- **Include when:** Have actual flow, diagram, or architecture details
- **Skip:** Unless specifically mentioned

### Common Issues Table
- **Include when:** Actually encountered issues with solutions
- **Skip:** Empty tables

### Testing/Verification
- **Include when:** Explicitly requested or have actual test results
- **Skip:** Generic checklists

### Benefits
- **Include when:** Explicitly requested
- **Skip:** By default

### External Links
- **Include when:** Explicitly requested
- **Skip:** By default (Internal Docs are always included)

---

## Language

**Default:** English
**Exception:** Use Thai only when explicitly instructed

---

## Format

### Dates
- Always include dates when updating
- Format: `**Date Updated:** YYYY-MM-DD` or `### YYYY-MM-DD`

### Section Headers
- `##` for main sections
- `###` for subsections
- `####` for sub-subsections

### Tags
- Include in both frontmatter (`tags: []`) and body (`#tag`)
- Use kebab-case: `#robot-framework` (not `#Robot Framework`)

### References
- **Internal Docs:** Always include when relevant (links to other vault documents)
- **External Links:** Only include when explicitly requested

---

## Examples

### ✅ GOOD - Actual information with internal references

```markdown
## Technical Details

### Cast Receiver Implementation

**Date Updated:** 2026-01-19
**Source:** Vendor Watermark (FMTS)

The vendor recommends handling FMTS init token on the receiver app because the DRM session is tied to the device that decrypts content.

## Reference

### Internal Docs
- [[WorkAssignment/2026-01-12_to_2026-01-16]] - Watermark SDK testing
- [[kb-mobile/chromecast-airplay]] - Related implementation
```

### ❌ BAD - Unnecessary external links without request

```markdown
## Reference

### Internal Docs
- [[WorkAssignment/2026-01-12_to_2026-01-16]]

### External Links
- https://example.com/docs
- https://vendor.com/api
```

---

## Expansion

**Start:** Use kb-minimal template → Record actual information only

**Later:** When more information arrives → Add sections as needed

**Remember:** Sections are optional except for Internal Docs references. Only include what's useful and requested.
