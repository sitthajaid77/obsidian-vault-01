---
type: assignment
week: <% tp.date.now("YYYY-[W]ww") %>
date_range: <% tp.date.now("YYYY-MM-DD") %> to <% tp.date.now("YYYY-MM-DD", 7) %>
date_created: <% tp.date.now("YYYY-MM-DD") %>
tags: [assignment, weekly]
---

# Work Assignment Week <% tp.date.now("ww") %> (<% tp.date.now("YYYY") %>)

**Period:** <% tp.date.now("DD MMM YYYY") %> to <% tp.date.now("DD MMM YYYY", 7) %>

---

## In Progress

> Active tasks currently being worked on. Use status indicators: [Investigating], [Root Cause Found], [Developing], [Code Review], [Testing], [Staging]

- **Team Member Name**
	- [Status] Task description
		- **Date Assigned:** YYYY-MM-DD
		- **Date Updated:** YYYY-MM-DD
		- **Current Status:** [Investigating | Root Cause Found | Developing | Code Review | Testing | Staging]
		- **Definition of Done:** [Bug Fix | Feature Development | Investigation | POC | Configuration Change]
		- Additional context or notes
		- See [[related-kb-doc]]

---

## Blocked / Waiting

> Tasks waiting for third party or external dependencies. Always specify what/who blocking and expected timeline.

- **Team Member Name**
	- Task description
		- **Date Assigned:** YYYY-MM-DD
		- **Date Blocked:** YYYY-MM-DD
		- **Blocked by:** [Person/Team/System]
		- **Waiting for:** [Specific action needed]
		- **Expected:** [Timeline if known, or "Unknown"]
		- **Last Update:** YYYY-MM-DD - [Latest status from blocking party]
		- See [[related-kb-doc]]

---

## Completed This Week

> Tasks completed during the current week. Include completion date and final status level.

- **Team Member Name**
	- ✅ Task description
		- **Date Completed:** YYYY-MM-DD
		- **Final Status:** [Staging | Production | Completed]
		- **Outcome:** Brief description of result
		- See [[related-kb-doc]]

---

## Notes

> Additional context, decisions, or important information for the week.

-

---

## Related

- [[WorkLog/<% tp.date.now("YYYY-MM-DD") %>_to_<% tp.date.now("YYYY-MM-DD", 7) %>]]
