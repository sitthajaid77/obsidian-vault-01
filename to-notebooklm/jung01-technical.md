# Technical Knowledge Base (jung01)

**Version:** jung01  
**Generated:** 2026-01-24 12:49:57  
**Source:** Obsidian Vault (jung01)  
**Author:** Yashiro

---


## Contents

This document contains technical knowledge from all kb-* folders:

- kb-cdn
- kb-explore-implement
- kb-general
- kb-lionking-project
- kb-mobile
- kb-mw
- kb-ovp
- kb-robot-automate
- kb-ssai-advertisement
- kb-stb
- kb-storage

---


# kb-cdn


## feature

**File:** `kb-cdn/feature.md`

- Update on 13 Jan 26: N. Mac proposed a feature to automatically restart Nginx when the geo module fails. Teohong will going to test in LAB and will present to team again.
- 

---


## zabbix

**File:** `kb-cdn/zabbix.md`

- Update on 13 Jan 26: In Zabbix, there is a graph that shows whether the geo module is working properly. A value of 0 indicates an error, and 1 indicates OK, and 0 will sending the alarm.
- 

---


# kb-lionking-project


## orion-implamentation

**File:** `kb-lionking-project/orion-implamentation.md`

## **Tags**

  #orion #monitoring #epl #drm #axinom #key-service #proxy
## **Overview**
Orion is used for **continuous source monitoring** of EPL content.
During discussions with **JAS** and **Orion**(meeting at 2026-01-22), it was identified that Orion cannot integrate directly with **Axinom DRM License Service** due to the high volume of monitoring requests, which could cause excessive license attempts.
To address this, Orion will integrate with the **Axinom DRM Key Service** instead, using a custom-built **proxy service** as an intermediary.
### **Current Limitation**
  **Date Updated:** 2026-01-22
- Orion performs monitoring **continuously**
- If Orion requests DRM licenses directly:
    - License request attempts would be extremely high
    - Risk of:
        - System impact
        - Quota exhaustion
        - Unnecessary license usage
- Orion architecture is designed to:
    - Request **DRM keys**, not playback licenses
### **Proposed Architecture**
**Orion → Proxy Service → Axinom DRM Key Service**
### **Proxy Development**
- **Owner:** Team Khun Kla & P’New (JAS)
- **Timeline:** **26–30 Jan 2026**
- **Deliverables:**
    - Working proxy service
    - Endpoint and integration specification shared with Orion team
### **Orion Integration Timeline**
- **Total duration:** **3–4 weeks**
    - **Week 1–2:** Integration and functional validation
    - **Week 3–4:** UI implementation within Orion application
---

---


# kb-mobile


## chromecast-airplay

**File:** `kb-mobile/chromecast-airplay.md`

---
type: kb
category: mobile
tags: [chromecast, airplay, cast-receiver, watermark, fmts, drm, concurrency, adb, debugging]
date_created: 2026-01-13
last_updated: 2026-01-19
status: active
priority: medium
---

# Chromecast & AirPlay

## Tags
#chromecast #airplay #cast-receiver #watermark #fmts #drm #concurrency #mobile #adb #debugging

---

## Overview

Knowledge base สำหรับการทำงานของ Chromecast และ AirPlay รวมถึงการ integrate watermark SDK และ DRM handling บน Cast receiver application

---

## Technical Details

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

---


## device

**File:** `kb-mobile/device.md`

- การ install '.ipa' ให้ใช้ command 'xcrun devicectl device install app --device <DEVICE_UDID> AIS_Play_debug_V3.0.8_98_202601082138.ipa' โดยจะต้องมี status เป็น available (paired) ก่อน (ใช้ command xcrun devicectl list devices ในการตรวจสอบ) (update: 12jan26)
- 

---


## dolby-vision-and-atmos

**File:** `kb-mobile/dolby-vision-and-atmos.md`

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

---


## ios-app

**File:** `kb-mobile/ios-app.md`

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

---


# kb-mw


## api-platform-config

**File:** `kb-mw/api-platform-config.md`

---
type: kb
category: mw
tags: [api, admd, middleware, platform-config, authentication, purchase]
date_created: 2026-01-21
last_updated: 2026-01-21
status: active
priority: medium
---

# API Platform Configuration

## Tags
#api #admd #middleware #platform-config #authentication #purchase

---

## Overview

API endpoint configurations for ADMD and MW purchase APIs across different platforms (AWS and on-premise).

---

## Technical Details

### ADMD API Configuration

**Date Updated:** 2026-01-21

**Platform Coverage:** AWS and on-premise (same configuration)

**Authorization Endpoint:**
```
ais_authorization_url: https://api-aisplay.ais.th/api/v3/aaf/authorization
```

**Access Token Endpoint:**
```
ais_accesstoken_url: https://api-aisplay.ais.th/auth/v3.2/oauth/token
```

**Credentials:**
```
ais_client_id: W8z7Yof0Sm2WqRnzRzxSiZLKeAN6FqrufU4EHfrLvfI=
ais_client_secret: fc957b6d79db679aaf969e57bc6cf400
```

### MW and Purchase API

**Date Updated:** 2026-01-21

**Platform Coverage:** Different URLs per platform (1: proxy-tls, 2: proxy-sila, 3: proxyvdomw.cloud)

**Send OTP Request:**
```json
ais_sendotprequest_url: {
  "1": "https://proxy-tls.vdomw.ais.th/v1/otthub/vs/api/vinson-api/request-otp-dvp",
  "2": "https://proxy-sila.vdomw.ais.th/v1/otthub/vs/api/vinson-api/request-otp-dvp",
  "3": "https://proxyvdomw.cloud.ais.th/v1/otthub/vs/api/vinson-api/request-otp-dvp"
}
```

**Get Offer Package:**
```json
ais_getofferpackage_url: {
  "1": "https://proxy-tls.vdomw.ais.th/v1/otthub/vs/api/vinson-api/get-offer-packages",
  "2": "https://proxy-sila.vdomw.ais.th/v1/otthub/vs/api/vinson-api/get-offer-packages",
  "3": "https://proxyvdomw.cloud.ais.th/v1/otthub/vs/api/vinson-api/get-offer-packages"
}
```

**Verification (Confirm OTP and Subscribe):**
```json
vdo_verification_url: {
  "1": "https://proxy-tls.vdomw.ais.th/v1/otthub/vs/api/vinson-api/confirm-otp-and-subscribe-package-dvp",
  "2": "https://proxy-sila.vdomw.ais.th/v1/otthub/vs/api/vinson-api/confirm-otp-and-subscribe-package-dvp",
  "3": "https://proxyvdomw.cloud.ais.th/v1/otthub/vs/api/vinson-api/confirm-otp-and-subscribe-package-dvp"
}
```

---

## Reference

### Internal Docs
- [[kb-mw/README]]

---

## Notes

### 2026-01-21
- ADMD API configuration is consistent across AWS and on-premise platforms
- MW/purchase APIs use platform-specific proxy URLs (numbered 1, 2, 3)

---


## disney-sftp

**File:** `kb-mw/disney-sftp.md`

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

---


# kb-ovp


## manipulator

**File:** `kb-ovp/manipulator.md`

- update on 13jan26: sample of cURL request to ZTE manipulator to obtain the manifest file
  curl -H "userid: 8882938776" -H "authinfo: 6uVAjUFw1UqpAF1N1Xg9M%2FUgyhXZvwzYIfiThPZ2dua61Fslk8Dpmq8vFITH2wen" -H "usersessionid: MaLhyF@jUp3fpw6ch4v6229152265589" -H "User-Agent: ExoPlayer" -H "Host: mp3.ovp.ais.th:7111" --compressed https://mp3.ovp.ais.th:7111/out/v1/Monomax-Sport/sport9/dash/index.mpd?playbackUrlPrefix=https%3A%2F%2Ftr.play-rfcdn.ais.th%3A443&rfkname=rfkz&originBasicUrl=http%3A%2F%2Flive-sport-a.monomax.me&pname=monomax%22

---


# kb-robot-automate


## robot-framework-testing

**File:** `kb-robot-automate/robot-framework-testing.md`

---
type: kb
category: testing
tags: [robot-framework, automation, testing, copilot, docmost]
date_created: 2026-01-13
last_updated: 2026-01-19
status: active
priority: medium
---

# Robot Framework Testing & Automation

## Tags
#robot-framework #automation #testing #qa #copilot #docmost #ai-assisted

---

## Overview

AI-assisted test generation workflow using Robot Framework, Docmost, and Copilot.

---

## Technical Details

### Test Generation Workflow

**Date:** 2026-01-13
**Implemented by:** Faii (ฝ้าย)
**Demo to:** Testing Team (พี่ติว, พี่เกด)

**Workflow:**
```
Test Case (Manual)
  → Docmost (Documentation)
    → Copilot (AI Generation)
      → Robot Framework Script
        → Automated Test Execution
```

**Process:**
1. Write test case - Define test scenarios and expected results
2. Document in Docmost - Add test case details in Docmost
3. Generate with Copilot - Use AI Copilot to generate Robot Framework script
4. Run script - Execute automated test

---

## Reference

### Internal Docs
- [[WorkAssignment/2026-01-12_to_2026-01-16]] - Faii coordinate with testing team
- [[WorkLog/2026-01-12_to_2026-01-16]] - Testing team meeting
- [[kb-mobile/chromecast-airplay]] - Watermark SDK testing

---

## Notes

### 2026-01-13
- Faii demonstrated the workflow to testing team (พี่ติว, พี่เกด)
- Explained process: testcase → docmost → copilot gen → run script
- Testing team provided positive feedback and showed interest in adoption

---


# kb-ssai-advertisement


## sdr-server-side-ad-decisioning

**File:** `kb-ssai-advertisement/sdr-server-side-ad-decisioning.md`

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

---


# kb-stb


## TEST ExoPlayer Error Handling and Corrupted DASH Manifest

**File:** `kb-stb/TEST ExoPlayer Error Handling and Corrupted DASH Manifest.md`

# Update on 13JAN26: ExoPlayer Error Handling กับ Corrupted DASH Manifest

## วัตถุประสงค์

ทดสอบว่า ExoPlayer (Media3) จะ handle กรณีที่ได้รับ DASH manifest ที่ไม่สมบูรณ์อย่างไร เพื่อ reproduce และวิเคราะห์ error ต่างๆ เช่น `IndexOutOfBoundsException`

---

## สถาปัตยกรรม

```
┌─────────────┐     ┌─────────────┐     ┌───────────────┐     ┌────────┐
│  ExoPlayer  │────▶│ CloudFront  │────▶│ Lambda@Edge   │────▶│ Origin │
│  (Android)  │◀────│             │◀────│ (Origin Req)  │◀────│ (ALB)  │
└─────────────┘     └─────────────┘     └───────────────┘     └────────┘
                                               │
                                               ▼
                                        ┌──────────────┐
                                        │ สุ่ม Corrupt │
                                        │ Manifest     │
                                        └──────────────┘
```

---

## ผลการทดสอบ

|Type|วิธี Corrupt|Error|Toast|พฤติกรรม|
|---|---|---|---|---|
|0|ตัด XML กลางคัน (40%)|`XmlPullParserException: Unexpected EOF`|✅ มี|ค้าง + แสดง error|
|1|ลบ `</MPD>`|ไม่มี error|❌ ไม่มี|ค้างเงียบๆ (silent hang)|
|2|ลบ `<SegmentTimeline>` ทั้งก้อน|`ArithmeticException: divide by zero`|✅ มี|ค้าง + แสดง error|
|3|ลบ `<Period>` ทั้งหมด|`ParserException: No periods found`|✅ มี|ค้าง + แสดง error|
|**4**|**`<SegmentTimeline>` ว่าง**|**`IndexOutOfBoundsException`**|✅ มี|ค้าง + แสดง error|
type 0 จะแสดง toast error code 15023002 บน Aisplay STB และ streaming จะค้าง
type 1 จะไม่มี toast error แต่ streaming จะค้างบน Aisplay STB
type 2 จะแสดง toast error code 15022000 บน Aisplay STB และ streaming จะค้าง
type 3 จะ toast error code 15023002 บน Aisplay STB และ streaming จะค้าง
type 4 จะ toast error code 15022000  บน Aisplay STB และ streaming จะค้าง

## ตัวอย่าง Manifest

### Manifest ปกติ (Valid)

```xml
<?xml version="1.0" encoding="utf-8"?>
<MPD xmlns="urn:mpeg:dash:schema:mpd:2011" 
     xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
     xsi:schemaLocation="urn:mpeg:dash:schema:mpd:2011 DASH-MPD.xsd" 
     profiles="urn:mpeg:dash:profile:isoff-live:2011" 
     type="dynamic" 
     availabilityStartTime="2015-01-01T00:00:00Z" 
     publishTime="2026-01-13T09:33:32.057601Z" 
     minimumUpdatePeriod="PT2S" 
     minBufferTime="PT8S" 
     timeShiftBufferDepth="PT1M" 
     maxSegmentDuration="PT5S">
  <Period id="period_347690542891955" start="PT96580H42M22.891955S">
    <AdaptationSet id="1" group="1" mimeType="audio/mp4" lang="en" contentType="audio" segmentAlignment="true">
      <Role schemeIdUri="urn:mpeg:dash:role:2011" value="main" />
      <SegmentTemplate timescale="10000000" 
                       presentationTimeOffset="3476905428919552" 
                       initialization="https://example.com/init-$RepresentationID$.mp4" 
                       media="https://example.com/segment-$RepresentationID$-$Time$.mp4">
        <SegmentTimeline>
          <S t="3482263468812888" d="40106664" />
          <S d="40106668" r="1" />
          <S d="39679998" />
          <S d="40106668" r="1" />
          <S d="40106664" />
          <S d="39680002" />
          <S d="40106664" />
          <S d="40106668" r="1" />
          <S d="39679998" />
          <S d="40106668" r="1" />
          <S d="40106664" />
        </SegmentTimeline>
      </SegmentTemplate>
      <Representation id="mp4a_96000_eng=20001" bandwidth="96000" audioSamplingRate="24000" codecs="mp4a.40.2">
        <AudioChannelConfiguration schemeIdUri="urn:mpeg:dash:23003:3:audio_channel_configuration:2011" value="2" />
      </Representation>
    </AdaptationSet>
    <AdaptationSet id="2" group="2" frameRate="25" mimeType="video/mp4" startWithSAP="1" contentType="video" par="16:9" minBandwidth="400000" maxBandwidth="5000000" segmentAlignment="true">
      <Role schemeIdUri="urn:mpeg:dash:role:2011" value="main" />
      <SegmentTemplate timescale="10000000" 
                       presentationTimeOffset="3476905428919552" 
                       initialization="https://example.com/init-$RepresentationID$.mp4" 
                       media="https://example.com/segment-$RepresentationID$-$Time$.mp4">
        <SegmentTimeline>
          <S t="3482263468800000" d="40000000" r="14" />
        </SegmentTimeline>
      </SegmentTemplate>
      <Representation id="avc1_400000=10000" bandwidth="400000" width="480" height="270" codecs="avc1.640028" />
      <Representation id="avc1_800000=10001" bandwidth="800000" width="640" height="360" codecs="avc1.640028" />
      <Representation id="avc1_3000000=10003" bandwidth="3000000" width="1280" height="720" codecs="avc1.640028" />
      <Representation id="avc1_5000000=10004" bandwidth="5000000" width="1920" height="1080" codecs="avc1.640028" />
    </AdaptationSet>
  </Period>
  <UTCTiming schemeIdUri="urn:mpeg:dash:utc:direct:2014" value="2026-01-13T09:33:32.057Z" />
</MPD>
```

### Type 0: ตัด XML กลางคัน (40%)

**Error:** `XmlPullParserException: Unexpected EOF`

```xml
<?xml version="1.0" encoding="utf-8"?>
<MPD xmlns="urn:mpeg:dash:schema:mpd:2011" 
     xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
     xsi:schemaLocation="urn:mpeg:dash:schema:mpd:2011 DASH-MPD.xsd" 
     profiles="urn:mpeg:dash:profile:isoff-live:2011" 
     type="dynamic" 
     availabilityStartTime="2015-01-01T00:00:00Z" 
     publishTime="2026-01-13T09:33:32.057601Z" 
     minimumUpdatePeriod="PT2S" 
     minBufferTime="PT8S" 
     timeShiftBufferDepth="PT1M" 
     maxSegmentDuration="PT5S">
  <Period id="period_347690542891955" start="PT96580H42M22.891955S">
    <AdaptationSet id="1" group="1" mimeType="audio/mp4" lang="en" contentType="audio" segmentAlignment="true">
      <Role schemeIdUri="urn:mpeg:dash:role:2011" value="main" />
      <SegmentTemplate timescale="10000000" 
                       presentationTimeOffset="3476905428919552" 
                       initialization="https://example.com/init-$RepresentationID$.mp4" 
                       media="https://example.com/segment-$Representat
```

**สาเหตุ:** XML ถูกตัดกลางคัน ทำให้ parser ไม่สามารถ parse ได้

### Type 1: ลบ `</MPD>` (Silent Hang)

**Error:** ไม่มี error thrown (อันตรายที่สุด!)

```xml
<?xml version="1.0" encoding="utf-8"?>
<MPD xmlns="urn:mpeg:dash:schema:mpd:2011" 
     xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
     xsi:schemaLocation="urn:mpeg:dash:schema:mpd:2011 DASH-MPD.xsd" 
     profiles="urn:mpeg:dash:profile:isoff-live:2011" 
     type="dynamic" 
     availabilityStartTime="2015-01-01T00:00:00Z" 
     publishTime="2026-01-13T09:33:32.057601Z" 
     minimumUpdatePeriod="PT2S" 
     minBufferTime="PT8S" 
     timeShiftBufferDepth="PT1M" 
     maxSegmentDuration="PT5S">
  <Period id="period_347690542891955" start="PT96580H42M22.891955S">
    <!-- ... content ... -->
  </Period>
  <UTCTiming schemeIdUri="urn:mpeg:dash:utc:direct:2014" value="2026-01-13T09:33:32.057Z" />
<!-- </MPD> ถูกลบออก -->
```

**สาเหตุ:** XML parser บางตัวอาจ tolerant กับ missing closing tag แต่ทำให้ player ค้างโดยไม่มี error

**⚠️ อันตราย:** ไม่มี error log, ไม่มี toast, ยากต่อการ debug ใน production

### Type 2: ลบ `<SegmentTimeline>` ทั้งก้อน

**Error:** `ArithmeticException: divide by zero`

```xml
<?xml version="1.0" encoding="utf-8"?>
<MPD xmlns="urn:mpeg:dash:schema:mpd:2011" ...>
  <Period id="period_347690542891955" start="PT96580H42M22.891955S">
    <AdaptationSet id="1" group="1" mimeType="audio/mp4" lang="en" contentType="audio" segmentAlignment="true">
      <Role schemeIdUri="urn:mpeg:dash:role:2011" value="main" />
      <SegmentTemplate timescale="10000000" 
                       presentationTimeOffset="3476905428919552" 
                       initialization="https://example.com/init-$RepresentationID$.mp4" 
                       media="https://example.com/segment-$RepresentationID$-$Time$.mp4">
        <!-- SegmentTimeline ถูกลบออกทั้งหมด -->
      </SegmentTemplate>
      <Representation id="mp4a_96000_eng=20001" bandwidth="96000" audioSamplingRate="24000" codecs="mp4a.40.2">
        <AudioChannelConfiguration schemeIdUri="urn:mpeg:dash:23003:3:audio_channel_configuration:2011" value="2" />
      </Representation>
    </AdaptationSet>
  </Period>
</MPD>
```

**สาเหตุ:** ไม่มี SegmentTimeline ทำให้ ExoPlayer พยายามคำนวณ segment duration แต่ได้ค่า 0 → divide by zero

### Type 3: ลบ `<Period>` ทั้งหมด

**Error:** `ParserException: No periods found`

```xml
<?xml version="1.0" encoding="utf-8"?>
<MPD xmlns="urn:mpeg:dash:schema:mpd:2011" 
     xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
     xsi:schemaLocation="urn:mpeg:dash:schema:mpd:2011 DASH-MPD.xsd" 
     profiles="urn:mpeg:dash:profile:isoff-live:2011" 
     type="dynamic" 
     availabilityStartTime="2015-01-01T00:00:00Z" 
     publishTime="2026-01-13T09:33:32.057601Z" 
     minimumUpdatePeriod="PT2S" 
     minBufferTime="PT8S" 
     timeShiftBufferDepth="PT1M" 
     maxSegmentDuration="PT5S">
  <!-- Period ถูกลบออกทั้งหมด -->
  <UTCTiming schemeIdUri="urn:mpeg:dash:utc:direct:2014" value="2026-01-13T09:33:32.057Z" />
</MPD>
```

**สาเหตุ:** ไม่มี Period element ทำให้ไม่มี content ให้ play

### Type 4: `<SegmentTimeline>` ว่าง (IndexOutOfBoundsException)

**Error:** `IndexOutOfBoundsException: Index 0 out of bounds for length 0`

```xml
<?xml version="1.0" encoding="utf-8"?>
<MPD xmlns="urn:mpeg:dash:schema:mpd:2011" ...>
  <Period id="period_347690542891955" start="PT96580H42M22.891955S">
    <AdaptationSet id="1" group="1" mimeType="audio/mp4" lang="en" contentType="audio" segmentAlignment="true">
      <Role schemeIdUri="urn:mpeg:dash:role:2011" value="main" />
      <SegmentTemplate timescale="10000000" 
                       presentationTimeOffset="3476905428919552" 
                       initialization="https://example.com/init-$RepresentationID$.mp4" 
                       media="https://example.com/segment-$RepresentationID$-$Time$.mp4">
        <SegmentTimeline></SegmentTimeline>  <!-- ว่างเปล่า ไม่มี <S> elements -->
      </SegmentTemplate>
      <Representation id="mp4a_96000_eng=20001" bandwidth="96000" audioSamplingRate="24000" codecs="mp4a.40.2">
        <AudioChannelConfiguration schemeIdUri="urn:mpeg:dash:23003:3:audio_channel_configuration:2011" value="2" />
      </Representation>
    </AdaptationSet>
    <AdaptationSet id="2" group="2" frameRate="25" mimeType="video/mp4" startWithSAP="1" contentType="video">
      <Role schemeIdUri="urn:mpeg:dash:role:2011" value="main" />
      <SegmentTemplate timescale="10000000" 
                       presentationTimeOffset="3476905428919552" 
                       initialization="https://example.com/init-$RepresentationID$.mp4" 
                       media="https://example.com/segment-$RepresentationID$-$Time$.mp4">
        <SegmentTimeline></SegmentTimeline>  <!-- ว่างเปล่า ไม่มี <S> elements -->
      </SegmentTemplate>
      <Representation id="avc1_400000=10000" bandwidth="400000" width="480" height="270" codecs="avc1.640028" />
    </AdaptationSet>
  </Period>
  <UTCTiming schemeIdUri="urn:mpeg:dash:utc:direct:2014" value="2026-01-13T09:33:32.057Z" />
</MPD>
```

**สาเหตุ:**

- XML valid และ parse ได้ปกติ
- แต่ `<SegmentTimeline>` ว่างเปล่า (ไม่มี `<S>` elements)
- เมื่อ ExoPlayer เรียก `getSegmentTimeUs()` → พยายาม `ArrayList.get(0)`
- ArrayList มี length 0 → `IndexOutOfBoundsException`

## Full Stack Traces
### Type 0: XmlPullParserException

```
androidx.media3.exoplayer.ExoPlaybackException: Source error
  at androidx.media3.exoplayer.ExoPlayerImplInternal.handleIoException(ExoPlayerImplInternal.java:785)
  ...
Caused by: androidx.media3.common.ParserException: null {contentIsMalformed=true, dataType=4}
  at androidx.media3.exoplayer.dash.manifest.DashManifestParser.parse(DashManifestParser.java:121)
  ...
Caused by: org.xmlpull.v1.XmlPullParserException: Unexpected EOF
  at com.android.org.kxml2.io.KXmlParser.checkRelaxed(KXmlParser.java:305)
  ...
```

### Type 2: ArithmeticException

```
androidx.media3.exoplayer.ExoPlaybackException: Source error
  at androidx.media3.exoplayer.ExoPlayerImplInternal.handleIoException(ExoPlayerImplInternal.java:785)
  ...
Caused by: androidx.media3.exoplayer.upstream.Loader$UnexpectedLoaderException: Unexpected ArithmeticException: divide by zero
  at androidx.media3.exoplayer.upstream.Loader$LoadTask.handleMessage(Loader.java:520)
  ...
Caused by: java.lang.ArithmeticException: divide by zero
  at androidx.media3.exoplayer.dash.manifest.SegmentBase$MultiSegmentBase.getSegmentNum(SegmentBase.java:183)
  ...
```

### Type 3: No periods found

```
androidx.media3.exoplayer.ExoPlaybackException: Source error
  at androidx.media3.exoplayer.ExoPlayerImplInternal.handleIoException(ExoPlayerImplInternal.java:785)
  ...
Caused by: androidx.media3.common.ParserException: No periods found. {contentIsMalformed=true, dataType=4}
  at androidx.media3.exoplayer.dash.manifest.DashManifestParser.parseMediaPresentationDescription(DashManifestParser.java:219)
  ...
```

### Type 4: IndexOutOfBoundsException

```
androidx.media3.exoplayer.ExoPlaybackException: Source error
  at androidx.media3.exoplayer.ExoPlayerImplInternal.handleIoException(ExoPlayerImplInternal.java:785)
  ...
Caused by: androidx.media3.exoplayer.upstream.Loader$UnexpectedLoaderException: Unexpected IndexOutOfBoundsException: Index 0 out of bounds for length 0
  at androidx.media3.exoplayer.upstream.Loader$LoadTask.handleMessage(Loader.java:520)
  ...
Caused by: java.lang.IndexOutOfBoundsException: Index 0 out of bounds for length 0
  at jdk.internal.util.Preconditions.outOfBounds(Preconditions.java:64)
  at java.util.ArrayList.get(ArrayList.java:434)
  at androidx.media3.exoplayer.dash.manifest.SegmentBase$MultiSegmentBase.getSegmentTimeUs(SegmentBase.java:228)
  at androidx.media3.exoplayer.dash.manifest.Representation$MultiSegmentRepresentation.getTimeUs(Representation.java:363)
  at androidx.media3.exoplayer.dash.DefaultDashChunkSource$RepresentationHolder.copyWithNewRepresentation(DefaultDashChunkSource.java:1088)
  at androidx.media3.exoplayer.dash.DefaultDashChunkSource.updateManifest(DefaultDashChunkSource.java:328)
  ...
```

## Lambda@Edge Code

```javascript
const https = require('https');
const http = require('http');

exports.handler = async (event) => {
    const request = event.Records[0].cf.request;
    const uri = request.uri;
    
    if (!uri.endsWith('.mpd')) {
        return request;
    }
    
    const now = Math.floor(Date.now() / 1000);
    const shouldCorrupt = (now % 20) < 2;  // corrupt 2 วินาทีในทุก 20 วินาที
    
    if (!shouldCorrupt) {
        return request;
    }
    
    const origin = request.origin.custom || request.origin.s3;
    const protocol = origin.protocol || 'https';
    const hostname = origin.domainName;
    const port = origin.port || (protocol === 'https' ? 443 : 80);
    const path = uri + (request.querystring ? '?' + request.querystring : '');
    
    try {
        const body = await fetchOrigin(protocol, hostname, port, path);
        
        const corruptType = 4;  // เปลี่ยนเป็น 0, 1, 2, 3, 4 ตามต้องการ
        let corruptedBody = body;
        
        switch (corruptType) {
            case 0:
                // ตัด XML กลางคัน
                corruptedBody = body.substring(0, Math.floor(body.length * 0.4));
                break;
            case 1:
                // ลบ closing tag </MPD>
                corruptedBody = body.replace('</MPD>', '');
                break;
            case 2:
                // ลบ SegmentTimeline ทั้งหมด
                corruptedBody = body.replace(/<SegmentTimeline>[\s\S]*?<\/SegmentTimeline>/g, '');
                break;
            case 3:
                // ลบ Period ทั้งหมด
                corruptedBody = body.replace(/<Period[\s\S]*?<\/Period>/g, '');
                break;
            case 4:
                // SegmentTimeline ว่าง (ทำให้เกิด IndexOutOfBoundsException)
                corruptedBody = body.replace(/<SegmentTimeline>[\s\S]*?<\/SegmentTimeline>/g, '<SegmentTimeline></SegmentTimeline>');
                break;
        }
        
        return {
            status: '200',
            statusDescription: 'OK',
            headers: {
                'content-type': [{ key: 'Content-Type', value: 'application/dash+xml' }],
                'x-corrupted': [{ key: 'X-Corrupted', value: `type-${corruptType}-time-${now}` }],
                'cache-control': [{ key: 'Cache-Control', value: 'no-cache, no-store' }]
            },
            body: corruptedBody
        };
    } catch (err) {
        console.error('Fetch error:', err);
        return request;
    }
};

function fetchOrigin(protocol, hostname, port, path) {
    return new Promise((resolve, reject) => {
        const client = protocol === 'https' ? https : http;
        const req = client.request({ hostname, port, path, method: 'GET' }, (res) => {
            let data = '';
            res.on('data', chunk => data += chunk);
            res.on('end', () => resolve(data));
        });
        req.on('error', reject);
        req.setTimeout(5000, () => reject(new Error('Timeout')));
        req.end();
    });
}
```

## AWS CLI Deploy Commands
### สร้าง IAM Role

```bash
cat > lambda-edge-trust-policy.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "lambda.amazonaws.com",
          "edgelambda.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

aws iam create-role \
  --role-name LambdaEdgeManifestCorruptor \
  --assume-role-policy-document file://lambda-edge-trust-policy.json

aws iam attach-role-policy \
  --role-name LambdaEdgeManifestCorruptor \
  --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
```
### สร้างและ Deploy Lambda

```bash
# สร้าง Lambda (ต้องอยู่ us-east-1)
zip function.zip index.js

aws lambda create-function \
  --function-name ManifestCorruptor \
  --runtime nodejs18.x \
  --role arn:aws:iam::<ACCOUNT_ID>:role/LambdaEdgeManifestCorruptor \
  --handler index.handler \
  --zip-file fileb://function.zip \
  --region us-east-1

# Publish version
aws lambda publish-version \
  --function-name ManifestCorruptor \
  --region us-east-1
```
### Associate กับ CloudFront

```bash
# ดึง config
aws cloudfront get-distribution-config --id <DISTRIBUTION_ID> > dist-config.json
cat dist-config.json | grep ETag

# Update config
cat dist-config.json | jq --arg ver "<VERSION>" '.DistributionConfig | .DefaultCacheBehavior.LambdaFunctionAssociations = {
  "Quantity": 1,
  "Items": [
    {
      "LambdaFunctionARN": ("arn:aws:lambda:us-east-1:<ACCOUNT_ID>:function:ManifestCorruptor:" + $ver),
      "EventType": "origin-request",
      "IncludeBody": false
    }
  ]
}' > updated-config.json

# Update CloudFront
aws cloudfront update-distribution \
  --id <DISTRIBUTION_ID> \
  --if-match <ETAG> \
  --distribution-config file://updated-config.json
```
### ทดสอบ

```bash
# เช็ค header ว่า corrupt หรือไม่
curl -sI "https://<YOUR_DOMAIN>/path/to/manifest.mpd" | grep -i x-corrupted

# ดู manifest content
curl -s "https://<YOUR_DOMAIN>/path/to/manifest.mpd"
```
## Cleanup

```bash
# ดึง config ใหม่
aws cloudfront get-distribution-config --id <DISTRIBUTION_ID> > dist-config.json
cat dist-config.json | grep ETag

# ลบ Lambda association
cat dist-config.json | jq '.DistributionConfig | .DefaultCacheBehavior.LambdaFunctionAssociations = {"Quantity": 0}' > updated-config.json

# Update CloudFront
aws cloudfront update-distribution \
  --id <DISTRIBUTION_ID> \
  --if-match <NEW_ETAG> \
  --distribution-config file://updated-config.json
```

---

---


## app

**File:** `kb-stb/app.md`

---
type: kb
category: kb-stb
tags: [aisplay, stb, android, app-architecture, mvvm, hilt, exoplayer, dash, streaming, error-handling, manifest, drm, webview, widevine, monomax, caching, heartbeat, javascript-bridge, mmkv, datastore]
date_created: 2026-01-13
last_updated: 2026-01-24
status: active
priority: high
---

# AISPlay STB App

## Tags
#aisplay #stb #android #app-architecture #mvvm #hilt #exoplayer #dash #streaming #error-handling #manifest #drm #webview #widevine #monomax #caching #heartbeat #javascript-bridge #mmkv #datastore

---

## Overview

AISPlay STB (Set-Top Box) application documentation covering app architecture, flow, dependency injection, and error handling for Android-based STB platform.

---

## Application Flow

**Date Updated:** 2026-01-23

### Step 1: Application Initialization
**File:** `LauncherApplication.kt`

Application start with `@HiltAndroidApp` (Hilt DI):
- Initialize Logging (XLog)
- Setup Process lifecycle observer
- Setup Activity lifecycle callbacks
- Setup Uncaught exception handler
- Initialize Database (DBHelper)
- Check Video license (VOLicenseChecker)
- Load Config and Login config
- Initialize DeviceManager, CookieManager
- Initialize NPawManager (analytics)

### Step 2: LoginActivity (Launcher Activity)
**File:** `LoginActivity.kt`

First screen of the app:
- Check Network connection
- Clear Cache (if first launch)
- Start Login process

### Step 3: Login Process

Login flow sequence:

```
1. Check AIS Token → If expired/invalid → Login with AIS
                           ↓
2. Check ZTE Token → If invalid → Login with ZTE
                           ↓
3. Check ZTE Session → Validate with Server
                           ↓
4. Retrieve User data
                           ↓
5. Check PDPA → If required → Show Privacy Policy
                           ↓
6. Login Success → Navigate to MainActivity
```

### Step 4: MainActivity
**File:** `MainActivity.kt`

After successful login:
- Check app state (`Config.APP_STATE`)
- Setup Drawer Navigation
- Fetch JSON Config (Portal configuration)
- Fetch Channel list
- Setup Fragments (Home, Search, Setting)
- Start Heartbeat Worker

### Step 5: Fragment Navigation

Navigation structure:

```
MainActivity
    ├── HomeFragment (default) - Home screen with Banners, VOD, Channels, Apps
    ├── SearchFragment - Search functionality
    └── SettingFragment - Settings
```

From MainActivity to other Activities:
- `WebActivity` - Content playback
- `SeeMoreActivity` - See more content
- `LiveTvActivity` - Live TV playback

---

## Architecture

**Date Updated:** 2026-01-23

### MVVM Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        VIEW LAYER                           │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐ │
│  │   Activities    │  │    Fragments    │  │   Adapters  │ │
│  │ (LoginActivity, │  │ (HomeFragment,  │  │             │ │
│  │  MainActivity)  │  │  SearchFragment)│  │             │ │
│  └────────┬────────┘  └────────┬────────┘  └─────────────┘ │
└───────────┼─────────────────────┼───────────────────────────┘
            │                     │
            ▼                     ▼
┌─────────────────────────────────────────────────────────────┐
│                     VIEWMODEL LAYER                         │
│  ┌──────────────┐  ┌──────────────┐  ┌────────────────┐    │
│  │LoginViewModel│  │ MainViewModel│  │ HomeViewModel  │    │
│  └──────┬───────┘  └──────┬───────┘  └───────┬────────┘    │
└─────────┼─────────────────┼──────────────────┼──────────────┘
          │                 │                  │
          ▼                 ▼                  ▼
┌─────────────────────────────────────────────────────────────┐
│                    REPOSITORY LAYER                         │
│        ┌──────────────────┐  ┌──────────────────┐          │
│        │  ZteRepository   │  │  AmtRepository   │          │
│        └────────┬─────────┘  └────────┬─────────┘          │
└─────────────────┼─────────────────────┼─────────────────────┘
                  │                     │
                  ▼                     ▼
┌─────────────────────────────────────────────────────────────┐
│                   DATA SOURCE LAYER                         │
│  ┌────────────────────┐  ┌────────────────────┐            │
│  │ZteNetworkDataSource│  │AmtNetworkDataSource│            │
│  └─────────┬──────────┘  └─────────┬──────────┘            │
│            │                       │                        │
│            ▼                       ▼                        │
│  ┌────────────────────┐  ┌────────────────────┐            │
│  │   ZteApiService    │  │   AmtApiService    │            │
│  │     (Retrofit)     │  │     (Retrofit)     │            │
│  └────────────────────┘  └────────────────────┘            │
└─────────────────────────────────────────────────────────────┘
```

### Dependency Injection (Hilt)

Hilt Modules:
1. **AppModule** - Provides LauncherApplication, Handler
2. **NetworkModule** - Provides OkHttpClient, Retrofit, API Services
3. **DataModule** - Provides DataSources

---

## Activities

**Date Updated:** 2026-01-23

| Activity | Purpose |
|----------|---------|
| `LoginActivity` | Entry point, Authentication |
| `MainActivity` | Main screen with Drawer Navigation |
| `WebActivity` | WebView for Content playback |
| `LiveTvActivity` | Live TV playback |
| `SeeMoreActivity` | Show more content |
| `SettingActivity` | Settings |
| `PdpaActivity` | Privacy Policy display |
| `EmerActivity` | Emergency/Maintenance screen |
| `ExternalWebActivity` | External web browser |

---

## JSON Config (Portal Configuration)

**Date Updated:** 2026-01-24

### Overview

Portal configuration is fetched from CDN and cached locally with a 3-layer cache strategy.

### API Endpoint

```
Primary: Config.CDN_JSON_PATH
Fallback: /iptvepg/layout/portal.json
```

### Data Structure

```kotlin
data class JsonConfig(
    val code: String?,              // Config version code
    val updateTime: String?,        // Last update time
    val defaultFocusPosition: Int?, // Default focus position
    val drawer: Map<...>,           // Drawer Navigation menu
    val column: Map<...>,           // Content columns
    val app: Map<...>,              // Apps list
    val button: Map<...>,           // Buttons
    val param: Map<...>             // General parameters
)
```

### Cache Strategy (3 Layers)

| Layer | Location | Method | When Used |
|-------|----------|--------|-----------|
| 1. Network | CDN Server | `fetchJsonConfig()` | Always try first |
| 2. DataStore | Local Storage | `loadJsonConfig()` | If Network fails |
| 3. Raw Resource | APK bundle | `readJsonConfig()` | Final fallback |

---

## Channel List

**Date Updated:** 2026-01-24

### API Endpoint

```
GET /iptvepg/api/{version}/cache/channels
```

### Parameters

| Parameter | Description |
|-----------|-------------|
| `columncode` | Column code (e.g., "0000" = All channels) |
| `pageno` | Page number |
| `numperpage` | Number of channels per page |
| `ordertype` | Sort order |
| `requestkey` | Request key |

### Channel Entity

```kotlin
data class Channel(
    val columncode: String?,
    val posterpath: String?,        // Channel image URL
    val channelname: String?,       // Channel name
    val channelcode: String?,       // Channel code
    val tsavailable: String?,       // Timeshift available
    val mediaservices: String?,     // DRM type indicator
    val funcswitch: String?,        // Function switch
    val channeltype: String?,
    val watermarkavailable: String?
)
```

### Cache Mechanism

- **Storage:** DBHelper (MMKV)
- **Key:** `CHANNEL_0000_th` or `CHANNEL_xxxx_th`
- **⚠️ No Expiry Time!** - Data persists until clear data or API overwrites

---

## Caching System

**Date Updated:** 2026-01-24

### Cache Layers

| Layer | Storage | Expiry | Notes |
|-------|---------|--------|-------|
| Native Channel List | DBHelper (MMKV) | **None!** | ⚠️ Persists indefinitely |
| JS Cache (setJsValue) | DBHelper (MMKV) | **None!** | ⚠️ Persists indefinitely |
| WebView localStorage | App sandbox | **None** | ⚠️ Persists indefinitely |
| Banner/VOD Cache | DBHelper (MMKV) | **4 hours** | ✅ Has expiry |
| JSON Config | DataStore | Checks updateTime | ✅ Has mechanism |

### Cache Expiry Configuration

```kotlin
var PORTAL_CACHE_EXPIRES = "14400"  // 14400 seconds = 4 hours
```

---

## HeartBeat & Refresh Mechanism

**Date Updated:** 2026-01-24

### HeartBeat Worker

```kotlin
// MainActivity.kt
val periodicWork = PeriodicWorkRequestBuilder<HeartBeatWorker>(time, TimeUnit.MINUTES)
    .setInitialDelay(15, TimeUnit.MINUTES)  // Start after 15 minutes
    .build()
```

### Channel Refresh Trigger

```kotlin
// HeartBeatWorker.kt
it.channelstamp?.let { time ->
    if (timeExpired(time, Config.channelStamp)) {
        // Server has update!
        val delay = Util.getDelayTime(Config.data_config["heart_channel_cache_delay"], 600)
        RefreshManager.instance.setChannelRefreshTime(
            System.currentTimeMillis() + delay * 1000
        )
    }
    Config.channelStamp = time
}
```

### RefreshManager → WebView Notification

```kotlin
private fun notice(api: String) {
    val map = HashMap<String, String>()
    map["type"] = "3"
    when (api) {
        "channel" -> map["jsnotice"] = "refreshChannels"
    }
    WebManager.instance.callWeb(gson.toJson(map))
}
```

### Refresh Timeline

**From Code Analysis:**

| Step | Time |
|------|------|
| HeartBeat Initial Delay | 15 minutes |
| HeartBeat Period | 15 minutes |
| Channel Cache Delay | 10 minutes (default 600 seconds) |
| RefreshManager Polling | 1 minute |
| **Total Native** | **~26 minutes** |

**From Vendor:**

| Step | Time |
|------|------|
| HeartBeat notification | 15 minutes |
| FE/JavaScript update | 30 minutes |
| **Total** | **~45 minutes** |

---

## JavaScript FE Architecture

**Date Updated:** 2026-01-24

### CDN Domain

```
https://bkk-a.play-rfcdn.ais.th/
```

### Base URL Construction

```kotlin
fun getBsDomain(): String {
    return LoginConfig.DOMAIN + "/" + LoginConfig.USER_GROUP
}
// Production: https://apitls.ovp.ais.th/iptvepg/frame1002
```

### FE Version Control

```javascript
window.amt_env = "online"
window.amt_version = 1764304618371  // Used for cache busting
window.cdnmrsdomain = "https://bkk-a.play-rfcdn.ais.th/"
```

### JavaScript Files Structure

```
https://bkk-a.play-rfcdn.ais.th/iptvepg/frame1002/
├── frameset_builder.html          # Main container
├── js/
│   ├── boundle.min.js             # Main bundled JavaScript
│   ├── config.min.js              # Configuration
│   └── index.js                   # Index logic
└── pages/
    └── play/
        ├── channel.html           # Channel player page
        ├── vod.html               # VOD player page
        ├── css/
        │   └── channel.min.css
        └── js/
            └── channel.min.js     # ⭐ Channel playback logic
```

### frameset_builder.html Structure

```html
<!-- Main container with iframes -->
<div id="frameset">
    <iframe name="mainWin" id="mainWin"></iframe>     <!-- Main content -->
</div>
<iframe name="extrWin" id="extrWin"></iframe>         <!-- Hidden -->
<iframe name="remindWin" id="remindWin"></iframe>     <!-- Hidden -->
<iframe name="FrameJsWin" id="FrameJsWin"></iframe>   <!-- Hidden -->
<iframe name="thirdWin" id="thirdWin"></iframe>       <!-- Third party -->
<div id="popup">
    <iframe name="popupWin" id="popupWin"></iframe>   <!-- Popups -->
</div>
<div id="live">
    <iframe name="liveWin" id="liveWin"></iframe>     <!-- Live content -->
</div>
```

### Channel Page UI Elements

| Element ID | Purpose |
|------------|---------|
| `authPopBox` | Authorization popup |
| `authErrorPopBox` | Auth error display |
| `pre_channel_box` | Preview time remaining ("You have 03:00 of free preview minutes left") |
| `playForbidBox` | Play forbidden message |
| `channelList` | Channel list overlay |
| `progress` | Playback progress bar |
| `volumeBox` | Volume control |

### FE Page URL Patterns

| Page | URL Pattern |
|------|-------------|
| Channel Player | `{domain}/frameset_builder.html#/pages/play/channel.html?channelcode=XXX` |
| VOD Detail | `{domain}/frameset_builder.html#/pages/detail/index.html?programcode=XXX` |
| VOD Player | `{domain}/frameset_builder.html#/pages/play/vod.html?programcode=XXX` |
| All Channels | `{domain}/frameset_builder.html#/pages/tvSchedules/index.html?columncode=XXX` |

---

## Native-JS Bridge (WebManager)

**Date Updated:** 2026-01-24

### JS → Native Communication

```javascript
// JavaScript calls Native
var result = androidObj.callAndroidFun(JSON.stringify({
    type: "0",           // 0=utility, 1=playback, 3=events, 5=special
    nativeapi: "getData",
    params: {
        dataName: "cdnDomain"
    }
}));
```

### Native Handler

```kotlin
// WebManager.kt
@JavascriptInterface
fun callAndroidFun(data: String): String {
    val info = gson.fromJson(data, JsInfo::class.java)
    when (info.type) {
        "0" -> work0(info)  // getJsValue, setJsValue, getHeader, getData
        "1" -> work1(info)  // Play commands (open, openTstv, stop, etc.)
        "3" -> work3(info)  // Events
        "5" -> work5(info)  // Special (playstatusquery, sessionExpire, etc.)
    }
}
```

### Native → JS Communication

```kotlin
fun callWeb(str: String) {
    web?.evaluateJavascript("javascript:callWebFun($str)") { }
}
```

### JS Storage via Native

```kotlin
// JS can store cache in Native:
if (info.nativeapi == "setJsValue") {
    DBHelper.getInstance().setJsValue(key, value)  // Store in MMKV
}
if (info.nativeapi == "getJsValue") {
    return DBHelper.getInstance().getJsValue(key)  // Read from MMKV
}
```

### getData Options

| dataName | Returns |
|----------|---------|
| `deviceId` | Device Serial Number |
| `mac` | MAC Address |
| `model` | Device Platform |
| `frameConfig` | JSON of Config.data_config |
| `cdnDomain` | Config.CDN_DOMAIN |
| `key_language` | Current language |
| `packageOrder` | Order package data |
| `requestKey` | Request key |
| `cdnEpgDomain` | ZTE CDN Domain |

---

## Channel Properties and DRM

**Date Updated:** 2026-01-23

### Key Concept

**IMPORTANT:** DRM and Entitlement checks are **NOT performed in Native Android** but in the **JavaScript Layer (WebView)**.

### Channel Properties

From `Channel.kt`:

```kotlin
data class Channel(
    // ... other fields ...
    val mediaservices: String?,    // Indicates if DRM is required
    val funcswitch: String?,       // Function switch for features
    val channeltype: String?,      // Channel type
    // ...
)
```

The `mediaservices` field indicates whether the channel requires DRM.

### Channel Playback Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│                    Channel Playback Flow                            │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  1. User clicks Channel                                             │
│           │                                                         │
│           ▼                                                         │
│  2. Open WebActivity with URL:                                      │
│     /frameset_builder.html#/pages/play/channel.html?channelcode=XXX │
│           │                                                         │
│           ▼                                                         │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              WebView (JavaScript Layer)                      │   │
│  │                                                              │   │
│  │  3. Fetch Channel Details from API                           │   │
│  │     - Get mediaservices, funcswitch, etc.                    │   │
│  │           │                                                  │   │
│  │           ▼                                                  │   │
│  │  4. Check if DRM is required                                 │   │
│  │           │                                                  │   │
│  │     ┌─────┴─────┐                                           │   │
│  │     │           │                                           │   │
│  │   No DRM     Has DRM (e.g., Monomax)                        │   │
│  │     │           │                                           │   │
│  │     │           ▼                                           │   │
│  │     │     5. Call Entitlement API                           │   │
│  │     │        ← Check viewing rights                         │   │
│  │     │        ← Get DRM License URL                          │   │
│  │     │           │                                           │   │
│  │     └─────┬─────┘                                           │   │
│  │           │                                                  │   │
│  │           ▼                                                  │   │
│  │  6. Call callAndroidFun() to send play command               │   │
│  │                                                              │   │
│  └─────────────────────────────────────────────────────────────┘   │
│           │                                                         │
│           ▼                                                         │
│  7. Native Android receives command from JS:                        │
│     - nativeapi: "open" or "openTstv"                              │
│     - params:                                                       │
│         url: "https://stream.example.com/live/..."                 │
│         drmscheme: "widevine" (if DRM)                             │
│         drmlicenseurl: "https://drm.example.com/..." (if DRM)      │
│         authToken: "..."                                           │
│           │                                                         │
│           ▼                                                         │
│  8. startPlay(url, drmScheme, drmUrl)                              │
│           │                                                         │
│     ┌─────┴─────┐                                                  │
│     │           │                                                  │
│   No DRM      Has DRM                                              │
│     │           │                                                  │
│     │           ▼                                                  │
│     │     Setup DRM Configuration:                                 │
│     │     - DrmConfiguration.Builder(WIDEVINE_UUID)                │
│     │     - setLicenseUri(drmUrl)                                  │
│     │     - setup DrmLicenseHeaderInterceptor                      │
│     │           │                                                  │
│     └─────┬─────┘                                                  │
│           │                                                         │
│           ▼                                                         │
│  9. ExoPlayer plays video                                           │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### Native Code for Play Command

In `WebActivity.kt`:

```kotlin
// Receives command from JS
private fun work1(info: JsInfo): String {
    when (info.nativeapi) {
        "open" -> {
            // Live TV playback
            startPlay(
                info.params["url"],           // Stream URL
                info.params["drmscheme"],     // "widevine", "playready", or null
                info.params["drmlicenseurl"]  // DRM License URL or null
            )
        }
        "openTstv" -> {
            // Timeshift TV playback
            startPlay(...)
        }
    }
}
```

### DRM Configuration in Native

```kotlin
private fun startPlay(url: String?, drmScheme: String?, drmUrl: String?) {
    // ...

    // If DRM is present
    if (!playDrmScheme.isNullOrBlank() && !playDrmUrl.isNullOrEmpty()) {
        val uuid = uuidMap[playDrmScheme]  // e.g., C.WIDEVINE_UUID

        val config = MediaItem.DrmConfiguration.Builder(uuid)
            .setLicenseUri(
                if (!isMonomax()) {
                    playDrmUrl
                } else {
                    playDrmUrl.substringBefore('?')  // Monomax requires removing query string
                }
            )
            .setMultiSession(true)
            .build()

        drmLicenseHeaderInterceptor.upLicenseToken(token)
        mIbuild.setDrmConfiguration(config)
    }

    // Create MediaItem and play
    player?.setMediaItem(item)
    player?.playWhenReady = true
    player?.prepare()
}
```

### Monomax Channel Special Handling

```kotlin
private fun isMonomax(): Boolean {
    val code = Config.data_config["Monomax_Cp_Code"]
    if (code.isNullOrBlank() || cpCode.isNullOrBlank()) {
        return false
    }
    return code == cpCode
}
```

For Monomax channels:
- Query string must be removed from `drmlicenseurl`
- Separate DRM license header handling

### Summary

| Topic | Details |
|-------|---------|
| **Channel Properties** | In `Channel.kt` - `mediaservices`, `funcswitch` |
| **DRM Check Location** | **JavaScript Layer** in WebView |
| **Entitlement API** | Called from **JavaScript**, not Native |
| **Native Responsibility** | Receives `open` command with `url`, `drmscheme`, `drmlicenseurl` and plays |
| **DRM Types** | `widevine`, `playready`, `clearkey` |
| **Monomax** | Special handling - removes query string from license URL |

**Note:** To understand which channels require Entitlement API, check the **JavaScript code** loaded in WebView (`/frameset_builder.html`), which is not in the Native Android codebase.

---

## Error Handling

### Error Codes - Corrupted DASH Manifest

**Date Updated:** 2026-01-13

### สรุป Error Codes

|Error Code|Exception Category|Error Message|พฤติกรรม|
|---|---|---|---|
|**15023002**|`ParserException`|XmlPullParserException, No periods found|Toast + ค้าง|
|**15022000**|`UnexpectedLoaderException`|ArithmeticException, IndexOutOfBoundsException|Toast + ค้าง|
|ไม่มี|ไม่มี error thrown|-|ค้างเงียบๆ (silent hang)|

---

### Error Code Pattern

```
1502 + XXXX
│      │
│      └── Exception Category (ประเภท Exception ไม่ใช่ specific message)
└── AISPlay Prefix สำหรับ streaming/playback error
```

---

### รายละเอียดแต่ละ Error

### Error Code: 15023002 (ParserException)

**สาเหตุ:** Manifest XML ไม่สมบูรณ์หรือ parse ไม่ได้

#### กรณี 1: XML ถูกตัดกลางคัน

**Error Message:**

```
ParserException: null {contentIsMalformed=true, dataType=4}
Caused by: XmlPullParserException: Unexpected EOF
```

**ตัวอย่าง Manifest:**

```xml
<?xml version="1.0" encoding="utf-8"?>
<MPD xmlns="urn:mpeg:dash:schema:mpd:2011" 
     profiles="urn:mpeg:dash:profile:isoff-live:2011" 
     type="dynamic" 
     availabilityStartTime="2015-01-01T00:00:00Z" 
     minimumUpdatePeriod="PT2S" 
     minBufferTime="PT8S">
  <Period id="period_1" start="PT0S">
    <AdaptationSet id="1" mimeType="audio/mp4" contentType="audio">
      <SegmentTemplate timescale="10000000">
        <SegmentTimeline>
          <S t="348226346881288
```

_XML ถูกตัดกลางคัน ไม่มี closing tags_

---

#### กรณี 2: ไม่มี Period

**Error Message:**

```
ParserException: No periods found. {contentIsMalformed=true, dataType=4}
```

**ตัวอย่าง Manifest:**

```xml
<?xml version="1.0" encoding="utf-8"?>
<MPD xmlns="urn:mpeg:dash:schema:mpd:2011" 
     profiles="urn:mpeg:dash:profile:isoff-live:2011" 
     type="dynamic" 
     availabilityStartTime="2015-01-01T00:00:00Z" 
     minimumUpdatePeriod="PT2S" 
     minBufferTime="PT8S">
  <!-- ไม่มี Period element -->
  <UTCTiming schemeIdUri="urn:mpeg:dash:utc:direct:2014" value="2026-01-13T09:33:32.057Z" />
</MPD>
```

---

### Error Code: 15022000 (UnexpectedLoaderException)

**สาเหตุ:** Runtime exception เกิดขึ้นระหว่าง load/process manifest

#### กรณี 1: ไม่มี SegmentTimeline

**Error Message:**

```
UnexpectedLoaderException: Unexpected ArithmeticException: divide by zero
Caused by: ArithmeticException: divide by zero
  at SegmentBase$MultiSegmentBase.getSegmentNum()
```

**ตัวอย่าง Manifest:**

```xml
<?xml version="1.0" encoding="utf-8"?>
<MPD xmlns="urn:mpeg:dash:schema:mpd:2011" 
     profiles="urn:mpeg:dash:profile:isoff-live:2011" 
     type="dynamic">
  <Period id="period_1" start="PT0S">
    <AdaptationSet id="1" mimeType="video/mp4" contentType="video">
      <SegmentTemplate timescale="10000000" 
                       initialization="init-$RepresentationID$.mp4" 
                       media="segment-$RepresentationID$-$Time$.mp4">
        <!-- ไม่มี SegmentTimeline -->
      </SegmentTemplate>
      <Representation id="video_1" bandwidth="5000000" width="1920" height="1080" codecs="avc1.640028" />
    </AdaptationSet>
  </Period>
</MPD>
```

---

#### กรณี 2: SegmentTimeline ว่างเปล่า

**Error Message:**

```
UnexpectedLoaderException: Unexpected IndexOutOfBoundsException: Index 0 out of bounds for length 0
Caused by: IndexOutOfBoundsException: Index 0 out of bounds for length 0
  at ArrayList.get()
  at SegmentBase$MultiSegmentBase.getSegmentTimeUs()
```

**ตัวอย่าง Manifest:**

```xml
<?xml version="1.0" encoding="utf-8"?>
<MPD xmlns="urn:mpeg:dash:schema:mpd:2011" 
     profiles="urn:mpeg:dash:profile:isoff-live:2011" 
     type="dynamic">
  <Period id="period_1" start="PT0S">
    <AdaptationSet id="1" mimeType="audio/mp4" contentType="audio">
      <SegmentTemplate timescale="10000000" 
                       initialization="init-$RepresentationID$.mp4" 
                       media="segment-$RepresentationID$-$Time$.mp4">
        <SegmentTimeline></SegmentTimeline>  <!-- ว่างเปล่า ไม่มี <S> elements -->
      </SegmentTemplate>
      <Representation id="audio_1" bandwidth="96000" codecs="mp4a.40.2" />
    </AdaptationSet>
    <AdaptationSet id="2" mimeType="video/mp4" contentType="video">
      <SegmentTemplate timescale="10000000" 
                       initialization="init-$RepresentationID$.mp4" 
                       media="segment-$RepresentationID$-$Time$.mp4">
        <SegmentTimeline></SegmentTimeline>  <!-- ว่างเปล่า ไม่มี <S> elements -->
      </SegmentTemplate>
      <Representation id="video_1" bandwidth="5000000" width="1920" height="1080" codecs="avc1.640028" />
    </AdaptationSet>
  </Period>
</MPD>
```

---

### ไม่มี Error Code (Silent Hang)

**สาเหตุ:** Manifest ขาด closing tag `</MPD>` แต่ XML parser ยัง tolerant

**Error Message:** ไม่มี

**พฤติกรรม:**

- ไม่มี Toast error
- Streaming ค้างเงียบๆ
- ⚠️ **อันตรายที่สุด** เพราะยากต่อการ debug

**ตัวอย่าง Manifest:**

```xml
<?xml version="1.0" encoding="utf-8"?>
<MPD xmlns="urn:mpeg:dash:schema:mpd:2011" 
     profiles="urn:mpeg:dash:profile:isoff-live:2011" 
     type="dynamic">
  <Period id="period_1" start="PT0S">
    <AdaptationSet id="1" mimeType="video/mp4" contentType="video">
      <SegmentTemplate timescale="10000000" 
                       initialization="init-$RepresentationID$.mp4" 
                       media="segment-$RepresentationID$-$Time$.mp4">
        <SegmentTimeline>
          <S t="3482263468800000" d="40000000" r="14" />
        </SegmentTimeline>
      </SegmentTemplate>
      <Representation id="video_1" bandwidth="5000000" width="1920" height="1080" codecs="avc1.640028" />
    </AdaptationSet>
  </Period>
  <UTCTiming schemeIdUri="urn:mpeg:dash:utc:direct:2014" value="2026-01-13T09:33:32.057Z" />
<!-- </MPD> หายไป -->
```

---

### ตัวอย่าง Manifest ที่ถูกต้อง

```xml
<?xml version="1.0" encoding="utf-8"?>
<MPD xmlns="urn:mpeg:dash:schema:mpd:2011" 
     profiles="urn:mpeg:dash:profile:isoff-live:2011" 
     type="dynamic" 
     availabilityStartTime="2015-01-01T00:00:00Z" 
     publishTime="2026-01-13T09:33:32.057601Z" 
     minimumUpdatePeriod="PT2S" 
     minBufferTime="PT8S" 
     timeShiftBufferDepth="PT1M" 
     maxSegmentDuration="PT5S">
  <Period id="period_1" start="PT0S">
    <AdaptationSet id="1" mimeType="audio/mp4" lang="th" contentType="audio" segmentAlignment="true">
      <SegmentTemplate timescale="10000000" 
                       initialization="init-$RepresentationID$.mp4" 
                       media="segment-$RepresentationID$-$Time$.mp4">
        <SegmentTimeline>
          <S t="3482263468812888" d="40106664" />
          <S d="40106668" r="1" />
          <S d="39679998" />
        </SegmentTimeline>
      </SegmentTemplate>
      <Representation id="audio_th" bandwidth="96000" audioSamplingRate="24000" codecs="mp4a.40.2" />
    </AdaptationSet>
    <AdaptationSet id="2" mimeType="video/mp4" contentType="video" segmentAlignment="true">
      <SegmentTemplate timescale="10000000" 
                       initialization="init-$RepresentationID$.mp4" 
                       media="segment-$RepresentationID$-$Time$.mp4">
        <SegmentTimeline>
          <S t="3482263468800000" d="40000000" r="14" />
        </SegmentTimeline>
      </SegmentTemplate>
      <Representation id="video_1080p" bandwidth="5000000" width="1920" height="1080" codecs="avc1.640028" />
      <Representation id="video_720p" bandwidth="3000000" width="1280" height="720" codecs="avc1.640028" />
      <Representation id="video_480p" bandwidth="1200000" width="854" height="480" codecs="avc1.640028" />
    </AdaptationSet>
  </Period>
  <UTCTiming schemeIdUri="urn:mpeg:dash:utc:direct:2014" value="2026-01-13T09:33:32.057Z" />
</MPD>
```

---

### Quick Reference

| ปัญหา                 | Error Code     | วิธีตรวจสอบ                                          |
| --------------------- | -------------- | ---------------------------------------------------- |
| XML ไม่สมบูรณ์        | 15023002       | เช็ค closing tags                                    |
| ไม่มี Period          | 15023002       | เช็คว่ามี `<Period>`                                 |
| ไม่มี SegmentTimeline | 15022000       | เช็คว่ามี `<SegmentTimeline>` ใน `<SegmentTemplate>` |
| SegmentTimeline ว่าง  | 15022000       | เช็คว่ามี `<S>` elements ใน `<SegmentTimeline>`      |
| ขาด `</MPD>`          | ไม่มี (silent) | เช็ค closing tag `</MPD>`                            |

---

## Known Issues

**Date Updated:** 2026-01-24

### DRM Channel Cache Problem

**Issue:**
When Backend changes a channel from non-DRM to DRM:
- Some devices do not call Entitlement Service
- Requires Clear App Data to work
- Some devices work after switching channels and coming back

**Possible Causes:**

1. **channelstamp not updated** - HeartBeat does not trigger refresh
2. **CDN Cache** - `/cache/channels` API is cached at CDN
3. **Per-channel JS cache** - JS caches data for each channel separately
4. **Different cache states** - Devices that never opened that channel get fresh data

**Why Some Devices Work, Others Don't?**

```
Device A (✅ Works):
- Never opened channel 509 before Backend changed
- Or HeartBeat triggered refresh successfully
- JS fetches fresh data → Gets DRM info → Calls Entitlement

Device B (❌ Does not work):
- Opened channel 509 before Backend changed
- Has old cache (non-DRM)
- HeartBeat may not trigger or hasn't reached time yet
- JS uses old cache → No DRM info → Does not call Entitlement
```

**Temporary Fix:**
- Clear App Data
- Wait 45+ minutes (if channelstamp is updated)

**Permanent Fix:**
1. **Backend:** Update `channelstamp` when DRM settings change
2. **Backend:** Purge CDN cache
3. **App:** Add cache expiry for channel data
4. **App:** Force refresh when app version changes

**Logs to Check:**

```bash
adb logcat | grep -E "HeartBeat|RefreshManager|channelstamp|refreshChannels"
```

---

## Reference

### Internal Docs
- [[kb-stb/hybrid-architecture]] - Hybrid App architecture concepts and design rationale
- [[kb-stb/device]] - STB device specifications
- [[kb-stb/drm]] - DRM implementation

---

## Notes

### 2026-01-24
- Added JSON Config (Portal Configuration) section
  - API endpoint, data structure, 3-layer cache strategy
- Added Channel List section
  - API endpoint, parameters, Channel entity, cache mechanism (MMKV, no expiry)
- Added Caching System section
  - All cache layers: Native Channel List, JS Cache, WebView localStorage, Banner/VOD, JSON Config
  - Cache expiry configuration (4 hours for Banner/VOD)
- Added HeartBeat & Refresh Mechanism section
  - HeartBeat Worker configuration (15 min initial delay, 15 min period)
  - Channel refresh trigger logic
  - RefreshManager notification to WebView
  - Refresh timeline: ~26 minutes (native), ~45 minutes (total with FE)
- Added JavaScript FE Architecture section
  - CDN domain, base URL construction, FE version control
  - JavaScript files structure (frameset_builder.html, boundle.min.js, channel.min.js)
  - frameset_builder.html iframe structure
  - Channel page UI elements
  - FE page URL patterns
- Added Native-JS Bridge (WebManager) section
  - JS → Native communication (callAndroidFun)
  - Native handler (work0, work1, work3, work5)
  - Native → JS communication (callWeb)
  - JS storage via Native (setJsValue, getJsValue in MMKV)
  - getData options
- Added Known Issues section
  - DRM Channel Cache Problem: symptoms, causes, why some devices work/don't work
  - Temporary and permanent fixes
  - Logs to check for debugging

### 2026-01-23
- Documented application flow (6 steps from initialization to navigation)
- Documented MVVM architecture with layer diagram
- Documented Hilt DI modules (AppModule, NetworkModule, DataModule)
- Documented 9 Activities and their purposes
- Documented Channel Properties and DRM flow
  - Channel.kt properties: mediaservices, funcswitch, channeltype
  - DRM checks performed in JavaScript Layer (WebView), not Native Android
  - Channel playback flow: User click → WebView → JS checks DRM → callAndroidFun() → Native plays
  - WebActivity.kt handles play commands: "open", "openTstv"
  - DRM configuration with DrmConfiguration.Builder
  - Monomax special handling: removes query string from license URL
  - DRM types supported: widevine, playready, clearkey

### 2026-01-13
- Documented Error Codes for corrupted DASH manifest
- Documented ExoPlayer error handling patterns

---


## device

**File:** `kb-stb/device.md`

- Screen capture during streaming (updated on 12 Jan 26)
	• On the 912 STB, screen capture during streaming is supported, except for DRM-protected content, which cannot be captured.
	• On Android TV (ATV), screen capture is not supported, regardless of whether the content is DRM-protected or not.
- STB App Crash Analysis - 12JAN26 Summary
	- Device: STB on Mr. Sitthisak's desk
	- **Environment**: Staging
	- **FBBID**: 8880524099
	- **Issue**: App exited from playback screen to home menu
	- **NPAW**: No related error recorded
	- **Root Cause**: System killed app due to WebView package update
	- Timeline Breakdown
		- 14:43:51.148-287 - Package Installation Initiated
			- `E/PackageInstallerSession(938)`: mUserActionRequired should not be null (x2)
			- `I/PackageManager(938)`: Integrity check passed for `vmdl812250574.tmp`
			- `I/PackageManager(938)`: Integrity check passed for `vmdl2138451895.tmp` 
		- 14:43:51.374-375 - Installation Started
			- `I/PackageManager(938)`: Continuing with installation of `vmdl812250574.tmp`
			- `I/PackageManager(938)`: Continuing with installation of `vmdl2138451895.tmp`
		 - 14:43:51.489 - WebView Force Stop
			 - `I/ActivityManager(938)`: Force stopping `com.google.android.webview` appid=10057 user=-1: installPackageLI
			 - **Note**: System force stopped WebView to perform update
		- 14:43:51.508 - WebView Update
			- `I/PackageManager(938)`: Update system package `com.google.android.webview` code path changed
			- From: `/data/app/~~KE26135V9KRvK6ZqAR1gWA==/com.google.android.webview-X_Smn1MTq_8Ke6d1rXbQkQ==`
			- To: `/data/app/~~9jdWnCMXhdZ9RVQ-uyzaog==/com.google.android.webview-2vMSxoS6DoNuEyZT_7lcpw==`
		- 14:43:51.576 - App Killed 
			- `I/ActivityManager(938)`: Killing 8368:`com.ais.playbox.debug`/u0a8 (adj 0): stop `com.google.android.webview` due to installPackageLI
			- **Critical**: This is the moment the playback app was terminated
		- 14:43:51.595-830 - Shared Library Issues
			- `E/PackageManager(938)`: Shared lib without setting: `SharedLibraryInfo{name:com.google.android.trichromelibrary, type:static, version:749914630}` (x2)
			- **Note**: TrichromeLibrary (Chrome/WebView component) had issues during update
		- 14:43:51.877 - Window Death
			- `I/WindowManager(938)`: WIN DEATH: `Window{e1068b3 u0 com.ais.playbox.debug/com.amt.launcher_ais.ui.activity.WebActivity}`
			- **Note**: WebActivity window destroyed
		- 14:43:52.321 - DeadObjectException
			- `W/ActivityManager(938)`: Exception when unbinding service `com.ais.playbox.debug/org.chromium.content.app.SandboxedProcessService0:0`
			- `W/ActivityManager(938)`: `android.os.DeadObjectException`
			- **Note**: Exception thrown because service was already killed when system tried to unbind
		- 14:43:52.332 - WebView Process Cleanup
			- `I/ActivityManager(938)`: Killing `com.google.android.webview:sandboxed_process0` (adj 900): isolated not needed
		- 14:43:52.342 - Activity Force Removed
			- `W/ActivityTaskManager(938)`: Force removing `ActivityRecord{683456c u0 com.ais.playbox.debug/com.amt.launcher_ais.ui.activity.WebActivity t167 f}`: app died, no saved state
		 - 14:43:52.383 - Process Obituary
			 - `V/ActivityManager(938)`: Got obituary of 8368:`com.ais.playbox.debug`
			 - `W/ActivityManager(938)`: setHasOverlayUi called on unknown pid: 8368
			 - **Note**: System confirmed process 8368 is dead
		- 14:43:52.478 - App Restart
			- `I/ActivityManager(938)`: Start proc 28439:`com.ais.playbox.debug`/u0a8 for top-activity `{com.ais.playbox.debug/com.amt.launcher_ais.ui.activity.MainActivity}`
			- **Note**: System restarted app automatically with new PID: 28439
		- Root Cause Analysis
			- Trigger: WebView package update initiated during app playback
			- Action: System force-stopped WebView component to apply update
			- Impact: Since `com.ais.playbox.debug` depends on WebView, system killed the app process
			- Result: App crashed, returned to home (MainActivity), no playback state saved
- 

---


## dns

**File:** `kb-stb/dns.md`

- From N.Nam and N.Tew testing, found the STB using router DNS (192.168.2.1) to resolving the hostname (updated on 12 Jan 26)
  ![[dns_resolve.png]]

---


## drm

**File:** `kb-stb/drm.md`

- After ZTE disabled DRM on the SMS portal, within 30 minutes the frontend application stopped requesting the Entitlement Service. N.Koi verified this using Charles while testing during the DRM disablement on Monomax Sport 9 (updated on 12 Jan 26)

---


## hybrid-architecture

**File:** `kb-stb/hybrid-architecture.md`

---
type: kb
category: kb-stb
tags: [hybrid-app, webview, javascript-bridge, mobile-architecture, native-app, web-app, cordova, ionic, react-native, flutter, android-tv, ott, iptv]
date_created: 2026-01-24
last_updated: 2026-01-24
status: active
priority: high
---

# Hybrid App Architecture

## Tags
#hybrid-app #webview #javascript-bridge #mobile-architecture #native-app #web-app #cordova #ionic #react-native #flutter #android-tv #ott #iptv

---

## Overview

AIS Playbox STB is a **WebView-based Hybrid App** - an architecture that combines Native Android code (Kotlin) with Web technologies (HTML/JavaScript) to create a flexible, maintainable application. This document explains the concept of Hybrid Apps, how they work, and why this architecture was chosen for the STB platform.

---

## Mobile App Architecture Types

**Date Updated:** 2026-01-24

### Classification

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         Mobile App Architecture Types                        │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  1. Native App           2. Hybrid App           3. Web App (PWA)           │
│  ┌──────────────┐        ┌──────────────┐        ┌──────────────┐           │
│  │   Kotlin     │        │   Native     │        │   Browser    │           │
│  │   Swift      │        │      +       │        │   (Chrome)   │           │
│  │   100%       │        │   WebView    │        │   100% Web   │           │
│  └──────────────┘        └──────────────┘        └──────────────┘           │
│                                                                              │
│  Examples:               Examples:               Examples:                   │
│  - Instagram             - AIS Playbox ⬅️        - Twitter Lite             │
│  - Banking Apps          - Grab                  - Starbucks                │
│  - Games                 - LINE                  - Pinterest                │
│                          - Discord                                          │
│                          - Slack                                            │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Comparison

| Type | Technology | Performance | Development Speed | Update Flexibility |
|------|-----------|-------------|-------------------|-------------------|
| **Native** | Kotlin, Swift | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐ (Requires app release) |
| **Hybrid** | Native + WebView | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ (Update JS on server) |
| **Web App (PWA)** | HTML/JS | ⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ (Instant) |

---

## Hybrid App Architecture

**Date Updated:** 2026-01-24

### Structure of AIS Playbox STB

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              AIS Playbox STB                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                         Native Layer (Kotlin)                        │    │
│  │                                                                      │    │
│  │  • App lifecycle, permissions, hardware access                       │    │
│  │  • Login/Authentication                                              │    │
│  │  • ExoPlayer (video playback + DRM)                                 │    │
│  │  • Local storage (MMKV, DataStore)                                  │    │
│  │  • Background services (HeartBeat Worker)                           │    │
│  │  • Push notifications                                                │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                              ▲                                               │
│                              │  JS Bridge                                    │
│                              │  (androidObj)                                 │
│                              ▼                                               │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                        WebView Layer (HTML/JS)                       │    │
│  │                                                                      │    │
│  │  • UI rendering (channel pages, VOD pages)                          │    │
│  │  • Business logic (DRM check, entitlement)                          │    │
│  │  • API calls to backend                                              │    │
│  │  • Dynamic content updates                                           │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Responsibilities Division

**Native Layer (Kotlin) handles:**
- App Lifecycle (onCreate, onDestroy)
- Login / Authentication
- Hardware Access (Remote control, Storage)
- Video Playback (ExoPlayer + DRM)
- Background Tasks (HeartBeat, Refresh)
- Local Storage (MMKV, DataStore)
- Network Interceptors (Headers, Cookies)
- TV Navigation (Leanback, Home screen)

**WebView Layer (JavaScript) handles:**
- Channel/VOD Page UI
- Business Logic (DRM check, Entitlement)
- Dynamic Content (EPG, Recommendations)
- API Calls (fetch channel details, VOD info)
- User Interactions (buttons in playback pages)
- Error Handling UI (auth popup, preview limit)

---

## JavaScript Bridge

**Date Updated:** 2026-01-24

### What is JavaScript Bridge?

JavaScript Bridge is the "bridge" that connects JavaScript code in WebView with Native Android code, enabling bi-directional communication.

### Native Side (Kotlin)

```kotlin
// WebManager.kt
web?.addJavascriptInterface(androidObj!!, "androidObj")

// Create interface that JS can call
@JavascriptInterface
fun callAndroidFun(data: String): String {
    // Receive commands from JS and execute in Native
}
```

### JavaScript Side (WebView)

```javascript
// JavaScript calls Native
var result = androidObj.callAndroidFun(JSON.stringify({
    type: "1",
    nativeapi: "open",
    params: {
        url: "stream_url",
        drmscheme: "widevine",
        drmlicenseurl: "license_url"
    }
}));
```

### Communication Flow

```
┌─────────────┐                          ┌─────────────┐
│  JavaScript │                          │   Native    │
│  (WebView)  │                          │  (Kotlin)   │
└─────────────┘                          └─────────────┘
       │                                        │
       │  1. User clicks play channel           │
       │────────────────────────────────────────│
       │                                        │
       │  2. JS checks DRM, calls Entitlement   │
       │────────────────────────────────────────│
       │                                        │
       │  3. androidObj.callAndroidFun(...)     │
       │───────────────────────────────────────►│
       │     "Open this stream with DRM"        │
       │                                        │
       │                                        │  4. Native configures ExoPlayer
       │                                        │     + DRM License
       │                                        │
       │  5. callWebFun({status: "playing"})    │
       │◄───────────────────────────────────────│
       │     "Notify JS that playback started"  │
       │                                        │
```

---

## Advantages and Disadvantages

**Date Updated:** 2026-01-24

### Advantages

| Advantage | Description |
|-----------|-------------|
| **🚀 Update without App Release** | Change JS on Server = All devices updated instantly |
| **👥 Share Code across Platforms** | Same JS works on Android TV, iOS, Web |
| **⚡ Faster Development** | Web developers can write UI without Native knowledge |
| **💰 Cost Effective** | No need to hire multiple Native developers |
| **🔄 Easy A/B Testing** | Change logic on Server side |

### Disadvantages

| Disadvantage | Description |
|--------------|-------------|
| **🐢 Lower Performance** | WebView has overhead |
| **🐛 Harder to Debug** | Must debug both layers |
| **📱 Less Smooth UX** | Animation, gestures may not be as smooth |
| **🔒 Security Concerns** | JS code can be inspected |
| **🔗 Dependency** | Relies on WebView version |

---

## Comparison with Other Frameworks

**Date Updated:** 2026-01-24

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        Hybrid App Frameworks                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │   Cordova   │  │    Ionic    │  │React Native │  │   Flutter   │         │
│  │  (PhoneGap) │  │             │  │             │  │             │         │
│  ├─────────────┤  ├─────────────┤  ├─────────────┤  ├─────────────┤         │
│  │  WebView    │  │  WebView    │  │  JS + Native│  │  Dart +     │         │
│  │  100%       │  │  + Angular  │  │  Components │  │  Skia       │         │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘         │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                    AIS Playbox (Custom Hybrid)                       │    │
│  ├─────────────────────────────────────────────────────────────────────┤    │
│  │  Native Kotlin + Custom WebView + Custom JS Bridge                   │    │
│  │  (Not using ready-made framework, built from scratch)                │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Framework Comparison

| Framework | Type | Performance | Popularity | Use Case |
|-----------|------|-------------|-----------|----------|
| **Cordova/PhoneGap** | WebView Wrapper | ⭐⭐ | Legacy | Simple apps |
| **Ionic** | WebView + Framework | ⭐⭐⭐ | Medium | Business apps |
| **React Native** | JS + Native Components | ⭐⭐⭐⭐ | High | Cross-platform apps |
| **Flutter** | Dart + Skia | ⭐⭐⭐⭐⭐ | High | Modern apps |
| **Custom (AIS Playbox)** | Native + WebView | ⭐⭐⭐ | N/A | Industry-specific (IPTV/OTT) |

---

## Why AIS Playbox Uses Hybrid Architecture

**Date Updated:** 2026-01-24

### Key Reasons

1. **Multi-platform Support**
   - Android TV, Android Box, potentially iOS
   - Same JS codebase works across all platforms

2. **OTT/IPTV Industry Standard**
   - ZTE IPTV system uses WebView-based architecture
   - Industry standard in Telco sector

3. **Rapid Updates**
   - Change business logic without app release
   - Critical for Content/DRM policy changes

4. **Content Management**
   - Channel/VOD page UI managed from Backend
   - Marketing team can change layout independently

5. **Vendor Integration**
   - Easier integration with ZTE platform
   - Frontend team can work independently from Native team

---

## Summary

**Date Updated:** 2026-01-24

> **Hybrid App** = Native Code (Kotlin) + WebView (HTML/JS) working together
>
> - **Native** is responsible for: Hardware, Security, Performance-critical tasks
> - **WebView** is responsible for: UI, Business logic that changes frequently
> - **JS Bridge** connects both layers for communication

This architecture explains why some logic exists in Native (Kotlin) and some in JavaScript in the AIS Playbox STB codebase.

---

## Reference

### Internal Docs
- [[kb-stb/app]] - STB App architecture, flow, and implementation details
- [[kb-stb/drm]] - DRM implementation in STB

---

## Notes

### 2026-01-24
- Initial documentation of Hybrid App Architecture
- Documented Mobile App Architecture Types (Native, Hybrid, Web App)
- Documented AIS Playbox STB structure (Native Layer + WebView Layer)
- Documented JavaScript Bridge concept and communication flow
- Documented advantages and disadvantages of Hybrid architecture
- Documented comparison with other frameworks (Cordova, Ionic, React Native, Flutter)
- Documented reasons why AIS Playbox uses Hybrid architecture

---


# kb-storage


## requirement

**File:** `kb-storage/requirement.md`

13jan26: Who use the storage, which protocol
- **Content Curation Team (SMB/SMB/SFTP):** Edit in hot tier, store infrequently used files in warm tier, long-term storage in archive tier
- **ZTE VoD Platform (NFS all tiers):** Ingest original files, transcode, and process metadata across all 3 tiers
- **MediaProxy Recorder (NFS):** Record live sources to hot tier, auto-move to warm when inactive
- **Vantage Transcoder/Packager (NFS):** Read/write from hot tier, auto-move to warm when inactive
- **Cloud Transcoder (Aspera):** Read/write from hot tier, auto-move to warm when inactive
- **Content Editor (SMB/SMB/SFTP):** Adobe Premiere editing on hot tier for optimal performance
- **Content Partner (Aspera):** External users read/write to warm tier only

---

