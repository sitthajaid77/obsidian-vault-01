---
type: kb
category: kb-stb
tags: [stb, hotel, ovp, fbbid]
date_created: 2026-01-28
last_updated: 2026-01-28
status: active
priority: medium
---

# STB Hotel Version

## Tags
#stb #hotel #ovp #fbbid

---

## Overview

Documentation regarding the technical implementation and configuration process for the Set-Top Box (STB) hotel version, which utilizes specialized templates and FBBID-based identification.

---

## Technical Details

### Template Selection Logic

**Date Updated:** 2026-01-28

The STB hotel version uses a different UI/UX template compared to normal users. The selection logic is handled on the OVP (Open Video Platform) side:

- **Logic Provider:** Cao (ZTE)
- **Identification Method:** FBBID (Fixed Broadband ID) validation.
- **Process:** When a client enters the OVP platform, the OVP checks the incoming FBBID. If the FBBID matches a pre-configured list of hotel users, OVP returns the specific template designed for hotel users.

### FBBID Configuration Process

**Date Updated:** 2026-01-28

For the template selection logic to function, all hotel-related FBBIDs must be configured in the ZTE backend.

- **Requirement:** ZTE team needs to add all FBBIDs belonging to hotel customers to their database.
- **Current Issue:** The AIS sell team often completes sales to hotel customers without informing the technical team of the specific FBBIDs involved, leading to configuration delays.
- **Proposed Process:** Once the AIS sell team completes a sale to a hotel customer, they must immediately inform the technical team of the associated FBBIDs so ZTE can perform the necessary backend configuration.

---

## Reference

### Internal Docs
- [[WorkLog/2026-01-26_to_2026-01-30]] - Initial discussion and backlog entry.

---

## Notes

### 2026-01-28
- Initiated discussion regarding the FBBID notification process between the sell team and the technical team.
- Cao (ZTE) confirmed OVP-side logic for FBBID-based template selection is planned.
