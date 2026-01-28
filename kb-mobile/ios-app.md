---
type: kb
category: kb-mobile
tags: [ios, iphone, error-handling, playback, hls, fmp4]
date_created: 2026-01-21
last_updated: 2026-01-23
status: active
priority: medium
---

# iOS App

## Tags
#ios #iphone #error-handling #playback #hls #fmp4

---

## Overview

iOS app (iPhone/iPad) behavior, error handling, and playback characteristics.

---

## Technical Details

### Segment Request Blocking Behavior

**Date Updated:** 2026-01-21

When using Charles Proxy to block segment endpoints during active playback:

- **Behavior:** Screen shows spinning loading indicator with black screen
- **Duration:** Approximately 3 minutes
- **Error:** Toast message displays error code 1005 (Aisplay toast 1502-1005)
- **Test method:** Charles Proxy blocking segment request endpoint during playback

### HLS fMP4 Format Support

**Date Updated:** 2026-01-23

iPhone supports HLS with fMP4 (.m4s) segments:

- **Format:** h.264 fMP4 (.m4s)
- **Player:** VOPlayer (embedded in Aisplay app)
- **DRM:** Tested without DRM
- **Channels tested:** HBO (V0117), mono29 (V0016)
- **Result:** Playback works normally with no issues

---

## Reference

### Internal Docs
- [[kb-mobile/dolby-vision-and-atmos]] - iPhone playback capabilities
- [[kb-mobile/device]] - iOS device installation

---

## Notes

### 2026-01-23
- Documented HLS fMP4 (.m4s) format support with h.264 codec

### 2026-01-21
- Documented segment blocking behavior and error 1005 timeout (3 minutes)
