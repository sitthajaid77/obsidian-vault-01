---
type: kb
category: kb-stb
tags: [stb, video, surface, drm, scaling, vertical, 4k, textureview, framelayout]
date_created: 2026-02-04
last_updated: 2026-02-04
status: active
priority: medium
---

# Vertical 4K Black Bar (Surface Scaling)

## Tags
#stb #video #surface #drm #scaling #vertical #4k #textureview #framelayout

---

## Overview

Vertical 4K content can show a black bar at the bottom of the screen on some TV boxes. This is attributed to hardware decoder and surface behavior: when the pixel buffer size exceeds the device's maximum supported output, non-linear scaling may not be supported, resulting in a black border. Source: Cao (ZTE) reported the issue; VisualOn provided the technical explanation and workaround.

---

## Technical Details

**Date Updated:** 2026-02-04

### Cause (VisualOn)

- For surface views, the **hardware decoder's output is prioritized**. When redrawing using `FrameLayout`'s `onMeasure`, it might not achieve the user's desired resolution.
- When the **pixel buffer size exceeds the TV box's maximum supported value** (obtainable via `getMeasuredWidth()` and `getMeasuredHeight()`), the device may not support non-linear scaling. A black border at e.g. 1440×2560 is therefore a **limitation of the device's surface**, not a bug.

### Clear vs DRM content

- **Clear streams:** Using **TextureView** directly can resolve the black border. TextureView is generally **not suitable for DRM-protected content**.
- **DRM-protected content:** Subject to the surface limitation above; workaround is to scale by an integer multiple (see below).

### Workaround (integer multiple scaling)

When the video width×height exceeds the device's maximum output, scaling must be an **integer multiple** to avoid the black border.

**Example (VisualOn):** For 1440×2560 test stream:

- Set the **height to 1280** in `onMeasure` (integer multiple). Device maximum supported value is 1080, but this still resolves the border.
- Logic: when video dimensions exceed the device's maximum output, use integer-multiple scaling in `onMeasure` to avoid the black bar.

---

## Reference

### Internal Docs
- [[device]] - Device specifications and platform behavior
- [[app]] - STB app, ExoPlayer, surface usage
- [[drm]] - DRM integration (TextureView limitation for DRM)

---

## Notes

### 2026-02-04
- Added from Cao (ZTE) report and VisualOn technical explanation and workaround.
