---
type: kb
category: mw
tags: [disney-plus, sftp, aws-transfer-family, s3, metadata, ott-partner]
date_created: 2026-01-19
last_updated: 2026-01-19
status: active
priority: medium
---

# Disney+ SFTP Integration

## Tags
#disney-plus #sftp #aws-transfer-family #s3 #metadata #ott-partner #zte

---

## Overview

Disney+ metadata delivery integration using AWS Transfer Family.

---

## Technical Details

### Architecture

**Date Updated:** 2026-01-19

**Solution:** AWS Transfer Family (already in use)

**Flow:**
```
Disney+ → SFTP → AWS Transfer Family → S3 Bucket → ZTE
```

**Our side provides:**
- S3 bucket
- AWS Transfer Family endpoint
- User credentials + key

**Disney+ side:**
- Sends metadata via SFTP to our endpoint
- Needs to coordinate with ZTE on how ZTE will consume the data

### Open Items

- [ ] Confirm metadata format from Disney+ is compatible with ZTE
- [ ] If not compatible: Nuch & Bew need to develop transform app

---

## Reference

### Internal Docs
- [[WorkAssignment/2026-01-19_to_2026-01-23]] - Nuch & Bew Disney+ SFTP

---

## Notes

### 2026-01-19
- P. Pu asked about Disney+ SFTP setup
- Clarified: not using FileZilla, using AWS Transfer Family
- Nuch to explore AWS Transfer Family console
