---
type: kb
category: kb-mw
tags: [nodejs, ecr, aws-inspector, openssl, cve, docker]
date_created: 2026-02-12
last_updated: 2026-02-12
status: active
priority: medium
---

# Node.js ECR Scan and OpenSSL CVE Assessment

## Tags
#nodejs #ecr #aws-inspector #openssl #cve #docker

---

## Overview

Findings from AWS ECR/Inspector scan of Docker images with different Node.js versions, and decision on Node version and risk acceptance for CVE-2025-15467 (OpenSSL).

**Date Updated:** 2026-02-12

---

## Technical Details

### Scan Results (Node 24, 25, 22)

- **Node v24:** Does not resolve the CVE reported in ECR scan.
- **Node v25:** No issues found in scan; OpenSSL CVE is addressed in Node v25.
- **Node v25 is not LTS.** Decision: use **Node v22** and accept risk (see below).

### CVE-2025-15467 and OpenSSL

- Vulnerability affects **OpenSSL 3.0–3.6**. OpenSSL 1.1.1 and 1.0.2 are not affected.
- OpenSSL has released patches: 3.6.1, 3.5.5, 3.4.4, 3.3.6, 3.0.19 (ref: SOC Prime).

### Node.js Security Advisory Assessment

- **"Node.js does not use CMS APIs"** — CVE-2025-15467 does not affect Node.js.
- Although Node.js may bundle a vulnerable OpenSSL version, Node.js does not call the affected CMS API.
- Node.js will include the OpenSSL update in a regular release, not a dedicated security release, as they assess attack surface is very limited.

### Decision

- Use **Node v22** (LTS) and **accept risk** for this CVE based on the Node.js advisory above.

---

## Reference

### Internal Docs
- [[WorkLog/2026-02-10_to_2026-02-16]]
- [[kb-mw/sra-monitoring-tools]]

---

## Notes

- ECR scan and image build (Node 24 push/scan) performed by Nuch per request; outcome documented in WorkLog and WorkAssignment Week 07.
