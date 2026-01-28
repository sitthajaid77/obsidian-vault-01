---
type: kb
category: kb-mobile
tags: [dolby-vision, atmos, ios, drm, screen-capture]
date_created: 2026-01-20
last_updated: 2026-01-20
status: active
priority: medium
---

# Dolby Vision and ATMOS

## Tags
#dolby-vision #atmos #ios #drm #screen-capture 

---

## Overview

Testing results for Dolby Vision and ATMOS content playback on iPhone with different configurations (codec, DRM, container format).

---

## Technical Details

### iPhone Playback Tests

**Date Updated:** 2026-01-20

#### Channel 101 (H.264)
- **Codec:** h264
- **Container:** fMP4 (.m4s)
- **Dolby Vision/ATMOS:** No
- **DRM:** Irdeto
- **Result:** Playback normal, screen capture blocked

#### Channel 952 (H.265)
- **Codec:** h265
- **Container:** fMP4 (.m4s)
- **Dolby Vision/ATMOS:** Yes
- **DRM:** Irdeto
- **Result:** Playback normal, screen capture blocked

#### Channel 953 (H.265)
- **Codec:** h265
- **Container:** fMP4 (.m4s)
- **Dolby Vision:** Yes
- **DRM:** None
- **Result:** Playback normal

#### Channel 950 (H.264)
- **Codec:** h264
- **Container:** fMP4 (.m4s)
- **Dolby Vision:** No
- **DRM:** None
- **Result:** Playback normal

#### Channel 951 (H.265)
- **Codec:** h265
- **Container:** fMP4 (.m4s)
- **Dolby Vision:** Yes
- **DRM:** None
- **Result:** Playback normal

---

## Notes

### 2026-01-20
- All tested channels with Irdeto DRM block screen capture on iPhone
- Dolby Vision content plays normally on iPhone regardless of DRM presence
