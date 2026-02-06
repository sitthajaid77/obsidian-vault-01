---
type: kb
category: mobile
tags: [chromecast, airplay, cast-receiver, watermark, fmts, drm, concurrency, adb, debugging]
date_created: 2026-01-13
last_updated: 2026-02-03
status: active
priority: medium
---

# Chromecast & AirPlay

## Tags
#chromecast #airplay #cast-receiver #watermark #fmts #drm #concurrency #mobile #adb #debugging #cdn #huawei-cdn #rs-epg #cors

---

## Overview

Knowledge base สำหรับการทำงานของ Chromecast และ AirPlay รวมถึงการ integrate watermark SDK, DRM handling บน Cast receiver application, และ CDN routing optimization.

---

## Technical Details

### Chromecast CDN Routing & RS-EPG Integration

**Date Updated:** 2026-02-03

**Context:** การจัดการให้ Chromecast สามารถใช้งาน Huawei CDN ที่ไม่มีการตรวจสอบ User-Agent ได้ เนื่องจากข้อจำกัดที่ไม่สามารถปรับแต่ง User-Agent headers บน Chromecast ได้

#### Current Issue
- **ZTE RS-EPG Limitation:** ไม่สามารถใช้ custom headers เพื่อแจ้ง RS-EPG ให้เลือก target CDN ได้ เนื่องจากพบปัญหา **CORS** ใน module 'RS' ของ ZTE

#### Interim Solution (Until May 2026)
เพื่อให้ Chromecast สามารถใช้งานได้ก่อนการเปิดตัว Web Client (May 2026):
1. **deviceType Selection:** กำหนดให้ Chromecast ส่ง `deviceType` = `web` เมื่อร้องขอไปยัง RS-EPG และ NPAW
2. **CDN Routing:** การระบุเป็น `web` จะทำให้ระบบชี้ไปที่ **Huawei CDN** (Staging/Production) ซึ่งถูกตั้งค่าให้ **Bypass User-Agent validation**
3. **Timeline:** ใช้แนวทางนี้เป็นหลักจนกว่าจะมีการ Launch Web Client อย่างเป็นทางการ

#### Permanent Fix & Transition
1. **Module Upgrade:** ZTE ต้องทำการ deploy **'RS' module version ใหม่** เพื่อแก้ไขปัญหา CORS
2. **Revert Configuration:** หลังจากแก้ไข CORS แล้ว จะเปลี่ยน Chromecast กลับมาส่งข้อมูลผ่าน **Custom Headers** แทนการใช้ `deviceType` = `web`

---

### AirPlay Device Concurrency Behavior

**Date Updated:** 2026-01-13

**Issue:** AirPlay ถูก block เมื่อใช้ร่วมกับ Axinom CSL concurrency control

**How it works:**
1. เมื่อเริ่ม playback บน mobile device → Axinom CSL สร้าง playback session ที่:
   - Scope: `userId` เดียวกัน
   - Associated: กับ Device ID ของ sender

2. เมื่อ user เริ่ม AirPlay → Axinom ทำการ:
   - ถือว่า AirPlay receiver (TV) เป็น **new playback device**
   - Switch Device ID จาก sender → receiver
   - Block playback session ใหม่ (เพราะ Entitlement Message config: `BLOCK_NEW_DEVICE`)

**Why it happens:**
- CSL enforces concurrency per `userId`
- แยก sessions โดยใช้ `Device ID`
- AirPlay = **device transition** (ไม่ใช่ continuation of same device session)

**Behavior:** Expected ตาม design ของ Axinom CSL

---

### Cast Receiver - Watermark SDK Implementation

**Date Updated:** 2026-01-19
**Source:** Vendor Watermark (FMTS)
**Context:** ฝ้าย (Faii) ทดสอบการติดตั้ง watermark SDK บน Cast receiver - ทำได้แล้ว, สเต็ปต่อไปลองกับ production

#### Architecture/Design

**Where to handle:** Receiver Application (NOT Sender)

**Reason:** The DRM session is normally tied to the **device which is decrypting and displaying the content** → ในกรณีนี้คือ **receiver app** (ไม่ใช่ sender/mobile app)

#### Implementation

**Flow:**
```
1. Sender App → sends "load" request → Receiver App
   ├─ Channel ID / Content ID
   └─ customData field (including FMTS init token)

2. Receiver App intercepts request:
   ├─ Extract data from customData field
   ├─ Request DRM license
   ├─ Check entitlement
   ├─ Request content from backend OVP system
   └─ Handle FMTS init token (watermark initialization)
```

**Key Integration Points:**
- **FMTS Token Location:** `customData` field in load request
- **DRM Session Scope:** Receiver device
- **Integration Point:** Load request interception logic on receiver app

#### Configuration

**Sender Application:**
```javascript
// Example: Sender sends load request with custom data
loadRequest.customData = {
  contentId: "channel_501",
  fmtsToken: "...",  // FMTS init token
  // other custom data
};
```

**Receiver Application:**
```javascript
// Receiver intercepts and handles
onLoad(event) {
  const customData = event.data.customData;
  const fmtsToken = customData.fmtsToken;

  // 1. Initialize FMTS watermark with token
  // 2. Request DRM license
  // 3. Check entitlement
  // 4. Load content from OVP
}
```

---

### Cast Receiver Debugging (ADB + Chrome Inspect)

**Date Updated:** 2026-01-19
**Source:** Faii investigation

#### ADB Connection Sequence

```bash
adb pair <ip:pairing_port>
adb connect <ip:debug_port>
```

Then open `chrome://inspect/#devices`

**Common mistakes:**
- Skip `adb connect` → Inspect button won't show
- Connection dropped (Wi-Fi change / device sleep) → need to reconnect

#### Chrome Crash During Trace - Causes

| Cause | Detail |
|-------|--------|
| Heavy vmodule logging | e.g., `--vmodule=*/media/*=2,*/components/cast/*=2` causes memory overflow |
| Trace buffer full/corrupted | Old trace session not cleared, or trace left hanging |
| Chrome version bug | Some Chrome builds crash on media/cast trace |
| Corrupted Chrome profile | User data/cache broken |
| Using regular Chrome | For media/cast trace, use Chrome Canary (more stable) |

---

## Testing/Verification

- [x] Test watermark SDK implementation on Cast receiver (ฝ้าย - 2026-01-19)
- [ ] Test on production environment
- [ ] Verify FMTS token handling in receiver app
- [ ] Test DRM session binding to receiver device
- [ ] Validate watermark rendering on Cast receiver

---

## Common Issues

| Issue | Root Cause | Solution |
|-------|-----------|----------|
| Chrome crash when clicking Trace button | Heavy vmodule logging / trace buffer corrupted / Chrome version bug | Use Chrome Canary, clear old trace sessions |
| Inspect button not showing in chrome://inspect | Skipped `adb connect` step | Run `adb pair` then `adb connect` before opening Chrome inspect |
| AirPlay blocked by concurrency | Axinom treats AirPlay as device transition | Expected behavior with BLOCK_NEW_DEVICE mode |

---

## Reference

### Internal Docs
- [[WorkAssignment/2026-01-12_to_2026-01-16]] - ฝ้ายทดสอบ watermark SDK
- [[WorkLog/2026-01-12_to_2026-01-16]] - App crash on Chromecast issue
- [[kb-robot-automate/robot-framework-testing]] - Robot Framework testing workflow

### External Links
- FMTS Watermark SDK Documentation
- Google Cast Developer Guide: https://developers.google.com/cast
- Axinom CSL Concurrency Documentation

---

## Notes

### 2026-01-19
- Vendor watermark (FMTS) แนะนำให้ handle FMTS init token บน receiver app แทนที่จะเป็น sender app
- เหตุผล: DRM session ผูกกับ device ที่ decrypt และ display content (receiver)
- ฝ้ายทดสอบสำเร็จแล้วบน staging, next step: production
- **Resolved:** Chrome crash issue from 2026-01-12:
  - Root cause: Faii skipped `adb connect` step → Inspect button didn't show, only Trace button available
  - Clicking Trace caused Chrome to crash
  - Ked assisted: correct sequence is `adb pair` → `adb connect` → then `chrome://inspect/#devices`
  - After following correct sequence, Inspect button now shows

### 2026-01-12
- N. Faii พบ app crash เมื่อ casting จาก mobile ไป ATV Chromecast
- ใช้ FMTS example Cast receiver ในการทดสอบ
- หน้าจอดำ ไม่มี playback → resolved 2026-01-19 (see above)
