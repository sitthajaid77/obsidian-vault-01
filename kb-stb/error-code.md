---
type: kb
category: kb-stb
tags: [stb, error-code, exoplayer, dash, manifest, ecs, debugging]
date_created: 2026-01-27
last_updated: 2026-01-27
status: active
priority: high
---

# STB Error Codes

## Tags
#stb #error-code #exoplayer #dash #manifest #ecs #debugging

---

## Overview

Error codes and troubleshooting guide for AISPlay STB (Set-Top Box) application, covering application errors, streaming errors, and DASH manifest parsing issues.

---

## Application Errors

**Date Updated:** 2026-01-27

### Error Code: 80250000 (ECS Unreachable)

**Cause:** Emergency Configure Server (ECS) request is blocked or unreachable during STB app startup

**Test Method:**
- N.Koi performed a mock test using Charles to block the ECS (Emergency Configure Server) request
- Blocked during app opening

**Error Behavior:**
- App displays toast error with code 80250000

**Related:**
- ECS (Emergency Configure Server) is required during app initialization

---

## Streaming Errors - Corrupted DASH Manifest

**Date Updated:** 2026-01-13

### Error Code Summary

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

### Silent Hang (No Error Code)

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

### Valid DASH Manifest Example

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

## Reference

### Internal Docs
- [[kb-stb/app]] - STB app architecture and implementation details
- [[kb-stb/device]] - STB device specifications

---

## Notes

### 2026-01-27
- Created dedicated error code documentation file (extracted from app.md)
- Added Error Code 80250000 (ECS Unreachable) - tested by N.Koi using Charles to block ECS request

### 2026-01-13
- Documented Error Codes for corrupted DASH manifest (15023002, 15022000)
- Documented ExoPlayer error handling patterns
- Documented silent hang cases with no error code
