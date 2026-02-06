---
type: kb
category: kb-cdn
tags: [cdn, redfox, staging, nginx, 502, midtier]
date_created: 2026-02-04
last_updated: 2026-02-04
status: active
priority: medium
---

# Staging CDN 502 Bad Gateway — Redfox Midtier NGINX Not Running

## Tags
#cdn #redfox #staging #nginx #502 #midtier

---

## Overview

A user (AMT) received 502 Bad Gateway when requesting the 905 Redfox edge staging node. The edge forwarded the request to the local-mid upstream 903 Redfox midtier staging (58.64.56.250:8008); the connection was refused because NGINX on the 903 midtier node was not running. Root cause: required dynamic modules (NDK and Lua) were not loaded after `load_module` directives in `/etc/nginx/modules-enabled` were commented out, so NGINX failed at startup on Lua directives (e.g. `lua_package_path`). Enabling those modules and starting NGINX on the 903 midtier restored the upstream; the request then returned HTTP 200.

---

## Technical Details

**Date Updated:** 2026-02-04

- **Edge:** 905 Redfox edge staging
- **Upstream:** local-mid → 903 Redfox midtier staging `58.64.56.250:8008`
- **Symptom:** 502 Bad Gateway; edge could not reach upstream (connection refused)
- **Cause:** NGINX on 903 midtier was not running
- **Root cause:** `load_module` directives in `/etc/nginx/modules-enabled` were commented out → NDK and Lua modules not loaded → NGINX startup failed when parsing Lua directives (e.g. `lua_package_path`)
- **Fix:** Re-enabled the module directives in `/etc/nginx/modules-enabled`, started NGINX on the 903 midtier node
- **Verification:** Upstream reachable again; request returned HTTP 200

---

## Reference

### Internal Docs
- [[kb-cdn/README]]
- [[kb-cdn/feature]]
- [[kb-cdn/zabbix]]

---

## Notes

(Resolved; no ongoing action.)
