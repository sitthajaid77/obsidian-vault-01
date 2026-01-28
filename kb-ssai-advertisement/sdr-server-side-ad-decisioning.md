---
type: kb
category: kb-ssai
tags: [ssai, sdr, gam, dai, ad-decisioning]
date_created: 2026-01-21
last_updated: 2026-01-21
status: active
priority: medium
---

# SDR - Server-Side Ad Decisioning and Reporting

## Tags
#ssai #sdr #gam #dai #ad-decisioning

---

## Overview

SDR (Server-side ad Decisioning and Reporting) is a feature of SSAI where the SSAI module performs ad selection and tracking on the server side, rather than relying on client-side logic.

---

## Technical Details

### SDR Implementation Approaches

**Date Updated:** 2026-01-21

SDR can be implemented using two main approaches:

1. **Standard VAST flows** - Traditional VAST XML-based workflow
2. **Google Ad Manager (GAM) DAI API** - Direct API integration with structured responses

### Traditional VAST Workflow vs SDR Approach

**Traditional VAST workflow:**
1. Request VAST XML from ad server
2. Parse VAST XML
3. Fetch media file from parsed URLs

**SDR approach via GAM DAI API:**
1. SSAI module makes direct API call to Google Ad Manager
2. Receives JSON response containing:
   - Ad metadata
   - Pre-transcoded media URLs
3. SSAI module uses JSON data to perform manifest manipulation (stitching) directly

### Benefits of SDR with GAM DAI API

- Eliminates VAST XML parsing overhead
- Structured JSON responses are easier to process
- Pre-transcoded media URLs improve performance
- Server-side ad selection and tracking provide better control

---

## Reference

### Internal Docs
- Related: [[kb-ovp/content-manipulation]] - Manifest manipulation concepts

---

## Notes

### 2026-01-21
- Discussion with P. Wow to align terminology and establish SDR implementation approach
- Decision to use GAM DAI API approach for direct JSON-based integration instead of traditional VAST workflow
