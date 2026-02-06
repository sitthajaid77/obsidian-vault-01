---
type: kb-index
category: kb-stb
date_created: 2026-01-19
last_updated: 2026-02-04
tags: [index, readme, stb, set-top-box]
---

# kb-stb Knowledge Base

## Overview

Set-top box platform knowledge base covering STB applications, DRM, DNS, and device specifications.

**Purpose:** Documentation for STB app development, streaming issues, and device behavior
**Scope:** 912 STB, Android TV, ExoPlayer, DASH streaming, DRM integration
**Owner/Team:** STB Development Team

---

## Quick Links

### Core Documentation
- [[hybrid-architecture]] - Hybrid App architecture, WebView-Native integration, JS Bridge
- [[app]] - App architecture, flow, caching, ExoPlayer error codes, DRM handling
- [[device]] - Device specifications, screen capture behavior, app crash analysis
- [[drm]] - DRM disable behavior and Entitlement Service
- [[dns]] - STB DNS resolution behavior
- [[hotel-version]] - STB hotel version template selection and FBBID process
- [[vertical-4k-black-bar]] - Vertical 4K black bar (surface scaling, DRM, integer-multiple workaround)

### Troubleshooting
- [[TEST ExoPlayer Error Handling and Corrupted DASH Manifest]] - Detailed ExoPlayer error testing

---

## Structure

**Categories in this folder:**
- **Architecture** - Hybrid app design, WebView integration
- **Application** - STB app, ExoPlayer, error handling, caching
- **Device** - STB hardware specs and platform behavior
- **DRM** - DRM integration and entitlement
- **Network** - DNS resolution, connectivity
- **Hotel** - Hotel-specific configurations and templates

---

## Related Domains
- [[kb-mobile/README]] - Mobile platform (related casting features)
- [[kb-ovp/README]] - OVP system (content delivery)
- [[kb-cdn/README]] - CDN infrastructure

---

## Notes

### 2026-02-04
- Added [[vertical-4k-black-bar]] - Vertical 4K black bar (ZTE/VisualOn: surface scaling, DRM, integer-multiple workaround)

### 2026-01-28
- Added [[hotel-version]] - STB hotel version template selection and FBBID process documentation

### 2026-01-24
- Added [[hybrid-architecture]] - Hybrid App architecture documentation
- Updated [[app]] - Added caching, heartbeat, JS Bridge, FE architecture sections

### 2026-01-19
- Initial kb-stb folder structure
