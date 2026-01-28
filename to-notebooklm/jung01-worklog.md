# Work Logs (jung01)

**Version:** jung01  
**Generated:** 2026-01-24 12:49:57  
**Source:** Obsidian Vault (jung01)  
**Author:** Yashiro

---


## Overview

Personal work logs by Yashiro documenting daily tasks, progress, and issues.

- **Format:** Weekly logs (YYYY-MM-DD to YYYY-MM-DD)
- **Content:** Completed tasks, ongoing work, blockers, decisions

---


# 2026-01-19_to_2026-01-23

**Period:** 2026-01-19_to_2026-01-23

---
type: worklog
week: 2026-W04
date_range: 2026-01-19 to 2026-01-23
date_created: 2026-01-19
tags: [worklog, weekly]
---

# WorkLog Week 04 (2026)

**Period:** 19 Jan 2026 to 23 Jan 2026

---

## 19Jan26
- Asked Yuexin AMT about Tizen 6.0 issue status
- Yuexin AMT replied: "The Cognito token for the stage environment has expired at present. We will verify and test it after the token is updated"
- [completed] Ask K. Noom (Monomax) for new cognito token for 'https://staging-entitlement-ais.monomax.me/drm/token'

---

## 20Jan26
- Vendor OVP (ZTE) reported issue from loop testing manifest file requests: ZTE manipulator → nea-cdn (packager)
  - **Error Code:** 15022000 - Empty SegmentTimeline (IndexOutOfBoundsException)
  - **Root Cause:** Incomplete manifest from AIS nea-cdn (packager)
  - **Channel:** V0015
  - **Issue:** Video AdaptationSet (id="3") has empty SegmentTimeline `<SegmentTimeline />`
  - Audio AdaptationSets contain complete SegmentTimeline
  - Contacted packager team for investigation
- ATEME support (N.Ton) investigation on IndexOutOfBound error(manifest incomplete):
  - Found PID missing from source (encoder) when viewed from packager's log
  - Correlates with high 'index out of bound' errors in NPAW (e.g., 19Jan26 ~14:17 and ~15:02)
  - Strong indication that source (encoder) has issues
  - ATEME support working on simulation method
  - Next steps:
    - Trace issue to encoder to identify root cause
    - If source issue cannot be fixed easily, need to optimize player to handle this case
- [completed] Requested N.Ton (ATEME support) to whitelist ZTE IPs on nea-cdn staging:
  - IPv4: 43.209.73.245
  - IPv6: 2406:da14:8a11:2c01:f96c:6dff:7e1c:60d9
- [completed] Tested Dolby Vision and ATMOS playback on iPhone:
  - Channel 101 (h264, Irdeto DRM): playback normal, screen capture blocked
  - Channel 952 (h265, Dolby Vision/ATMOS, Irdeto DRM): playback normal, screen capture blocked
  - Channel 953 (h265, Dolby Vision, no DRM): playback normal
  - Documented in [[kb-mobile/dolby-vision-and-atmos]]
- [completed] request cognito token from K. Noom (Monomax) and sent to Cao ZTE

---

## 21Jan26
- IndexOutOfBound error investigation update:
  - Reviewed packager and encoder logs
  - **Confirmed:** Feed unavailable issue from encoder/source
  - **Impact:** Packager generates incomplete manifest files
  - **Next action:** Coordinate with ZTE/AMT to adjust player to handle this case gracefully
  - Related: [[kb-stb/app]]
- [completed] Follow up with packager team (confirmed root cause: encoder feed unavailable)
- TODO: Coordinate with ZTE/AMT to adjust player handling for incomplete manifest case
- TODO: Follow up with Yuexin AMT on Tizen 6.0 issue status after cognito token update
- **Samsung TV vertical VOD playback issues investigation update:**
    - **Issue 1:** Subtitle positioning incorrect when playing vertical videos on Samsung TV
        - **Symptom:** Subtitle position is incorrect only on Samsung TV
        - **VO team analysis:**
            - Audio and video duration are mismatched
            - Subtitle positioning data in the stream is not handled correctly
        - **Confirmed:**
            - Video and audio tracks are not aligned in duration
            - Subtitle positioning issue is likely related to vertical video layout + stream metadata
        - **Playback:**
            - MPD: https://packager.dev-ovp.ais.th/vod/alfheim/02202601131530042501/_/DD4/02202601131530042501.mpd
        - **Impact:**
            - Subtitle rendering incorrect on Samsung TV (Tizen player)
        - **Next action:**
            - Validate subtitle track metadata and positioning logic for vertical content
            - Coordinate with OV team and Samsung/ZTE player team for vertical video handling
- **Samsung TV vertical VOD duration mismatch investigation update:**
    - **Issue 2:** Incorrect duration shown on Samsung TV for certain vertical VOD titles
        - **Standard duration:** 21:44 (consistent across other platforms)
        - **Samsung TV duration:** 23:06 (+ ~1:22)
        - **Symptom:**
            - Playback freezes once video reaches the actual video duration (21:44)
        - **VO team analysis:**
            - Video track duration: 21:44
            - Audio track duration: 23:06
        - **Confirmed:**
            - Audio and video length mismatch in the streaming source
        - **Playback:**
            - MPD: https://packager.dev-ovp.ais.th/vod/alfheim/02202512231540042491/_/DD4/02202512231540042491.mpd
        - **Impact:**
            - Samsung TV player uses audio duration as total content duration
            - Playback freezes after video frames are exhausted
        - **Next action:**
            - Coordinate with encoder/source team to align audio/video durations
            - Confirm expected player behavior when track durations mismatch
- Investigated iPhone/iPad error -12927 during Dolby live channel switching(Dolby Vision and ATMOS playback on iPhone):
  - **Issue:** Error -12927 (CoreMediaErrorDomain) occurs intermittently when switching between channel 953 and 29
  - **Affected channels:** Only channel 29 (H.264 with DRM)
  - **Symptoms:**
    - License request initiated (fetchApplicationCertificate)
    - AVPlayerItem fails ~60ms later before license response received
  - **Log sample timing:**
    - 10:55:24.803: Certificate URL requested
    - 10:55:24.861: AVPlayerItem Status Failed (58ms later)
    - Error: CoreMediaErrorDomain Code=-12927, PlayerRemoteXPC err=-12860
  - TODO: follow up Cao ZTE for this case

---

## 22Jan26
- AMT raised issue: DRM license for Monomax channel 502 (sport41) returns 403 intermittently
	  - **Error message:** "key ID that is not present in the entitlement message"
	  - **Investigation:** KID mismatch between entitlement token and manifest
- [completed] Developed Go script to test and validate entitlement token KID matching for 'https://mbs-svc.3bbtv.com:8443/drm/token' and send the result to K.Kla (JAS) and P.Noom (Mono)
	- TODO: Follow up with K. Kla and P. Noom
- IndexOutOfBound/incomplete manifest handling update:
	- Koi and Faii are working on Media3 code to handle incomplete manifest gracefully
	- **Deadline:** End of this week
	- **Plan:** If incomplete by end of week, will send current progress to ZTE/AMT
	- [completed] Koii completed an interim solution using the Media3 player on Android STB, which allows video playback to continue when this issue occurs
- Meeting for **Orion monitoring for EPL source** with JAS and Orion
	- Currently project stuck on DRM integration
	- Solution depends on a **proxy service** between Orion and **Axinom DRM Key Service**, owned by **K. Kla and P’New’s team**
	- Proxy development is scheduled within **26–30 Jan 2026**
	- Orion integration will start only after the proxy is completed and delivered
	- TODO / Next Action
		- **Follow up with K. Kla and P’New in the next week (target: 29 Jan 2026)** to confirm whether the proxy service is completed and ready for Orion integration

---

## 23Jan26
- Meeting with team P'Pu with Disney team for the topic Disney metadata feed.
- [completed] Vertical VOD Subtitle positioning issue resolved:
	- VO Player team completed fix for subtitle positioning on vertical content
	- Solution now correctly handles horizontal subtitles with vertical content
	- Content Curation Team can now use horizontal subtitles with vertical content without positioning issues
- [completed] Media3 incomplete manifest handling optimization completed:
	- N.Koii successfully optimized Media3 to handle incomplete manifest case
	- Player continues playback when encountering incomplete manifest (may pause but does not crash/error)
	- Resolves IndexOutOfBound error reported by ZTE/AMT
- [completed] Tizen 6.0 DRM retry and display delay issue resolved:
	- Issue resolved in AMT template tested on 2026-01-22
	- No longer requires further development or verification from Pim's side
- [completed] Tested live channel playback without DRM on iPhone with Faii:
	- **Channels tested:** HBO (V0117), mono29 (V0016)
	- **Format:** h264 fMP4 (.m4s)
	- **Player:** VOPlayer on iPhone (Faii embedded playbackURL in Aisplay app)
	- **Manifest manipulator:** Custom manipulator
		- HBO: https://d17kjhxmz8ss3z.cloudfront.net/live/eds/V0016/HN4F/V0016.m3u8
		- mono29: https://d17kjhxmz8ss3z.cloudfront.net/live/eds/V0117/HN4F/V0117.m3u8
	- **Result:** Playback worked normally with no issues
- [completed] Studied STB app code for Channel Properties and DRM flow:
	- **Files analyzed:** `Channel.kt`, `WebActivity.kt`
	- **Key findings:**
		- DRM and Entitlement checks performed in JavaScript Layer (WebView), not Native Android
		- Channel properties: `mediaservices` field indicates DRM requirement
		- Playback flow: User click → WebView loads `/frameset_builder.html` → JS checks DRM → calls Entitlement API → `callAndroidFun()` sends command to Native → Native receives `open`/`openTstv` with params (url, drmscheme, drmlicenseurl) → ExoPlayer plays
		- Native handles DRM configuration with `DrmConfiguration.Builder`
		- Monomax channels require special handling: query string removed from license URL
		- Supported DRM types: widevine, playready, clearkey
	- **Documented in:** [[kb-stb/app]]

---

## Week Summary

### Key Accomplishments
- [Root Cause Identified] IndexOutOfBound error caused by encoder feed unavailable → packager generates incomplete manifest
- [Completed] Whitelist ZTE IPs on nea-cdn staging
- [Completed] Tested Dolby Vision/ATMOS playback on iPhone - documented in [[kb-mobile/dolby-vision-and-atmos]]
- [Completed] Cognito token requested from K. Noom (Monomax) and sent to Cao ZTE
- [Completed] Follow up with packager team - confirmed root cause
- [Completed] Developed Go script to validate entitlement token KID matching for Monomax DRM
- [Completed] N.Koii optimized Media3 to handle incomplete manifest - player continues playback without crash
- [Completed] Meeting for Orion monitoring - proxy development scheduled 26-30 Jan 2026
- [Completed] VO Player team resolved Vertical VOD subtitle positioning issue - horizontal subtitles now display correctly with vertical content
- [Completed] Tizen 6.0 DRM retry and display delay issue resolved in AMT template (tested 2026-01-22)
- [Completed] Tested live channel playback without DRM on iPhone - HBO and mono29 channels with h264 fMP4 format
- [Completed] Studied STB app code for Channel Properties and DRM flow - documented WebView JS layer handling and Native DRM configuration

### In Progress
- [Investigating] Samsung TV vertical VOD duration mismatch issue (audio/video track misalignment)
- [Investigating] iPhone/iPad error -12927 during Dolby live channel switching (channel 29 with DRM)
- [Investigating] DRM license 403 error for Monomax channel 502 - KID mismatch issue

### Blocked / Waiting
- Orion monitoring integration - **Blocked by:** K.Kla and P'New's team, **Waiting for:** Proxy service between Orion and Axinom DRM, **Expected:** 26-30 Jan 2026

### Next Week Focus
- Follow up with K.Kla and P'New on proxy service completion (target: 29 Jan 2026)
- Follow up Cao ZTE on iPhone error -12927
- Follow up K.Kla and P.Noom on entitlement token KID mismatch issue
- Continue investigating Samsung TV vertical VOD duration mismatch issue

---

## Related
- [[WorkAssignment/2026-01-19_to_2026-01-23]]

---


# 2026-01-12_to_2026-01-16

**Period:** 2026-01-12_to_2026-01-16

12JAN26
- Regarding the ‘Blocking on Chromecast’ issue, the JAS team has already configured the concurrency limit of *mbs-svc.3bbtv.com:8443/drm/token* to 1.
- Weekly team meeting.
- Coordinate with Somsiri, Richard (ZTE), and K.Noom from the Monomax team to disable the DRM key on Sport 9.
	- K.Noom disable DRM at 12:01 PM
	- Richard ZTE disable DRM on SMS portat at 13:00 PM
	- The tester team, P. Ae Vichulada and N. Ked, helped with testing. No devices experienced stream freezing, and everything worked fine.
	- At 13:05, N. Koi checked via Charles and still found that the application still sending requests to the Entitlement Service.
	- At 13:30, N. Koi checked via Charles and found no Entitlement service or Widevine request.
-  N. Faii found that the app crashes during casting from her mobile app to ATV Chromecast. The screen also shows a black screen with no playback. This test was performed using the FMTS example Cast receiver.
- Investigate case: The STB on Mr. Sitthisak’s desk exited from the playback screen to the home menu. No related error was recorded in NPAW. The logcat summary indicates that the system killed the application.
	- Trigger: A WebView package update was initiated while the application was playing back content
	- Action: The system force-stopped the WebView component to apply the update
	- Impact: Since com.ais.playbox.debug depends on WebView, the system terminated the application process
	- Result: The application was killed and returned to the home screen (MainActivity), with no playback state saved
13JAN26
- Weekly meeting with JAS/Monomax: project timeline
	- vendor for POC the on-prem packager: ATEME, ScalStrm, KT
- Making the storage protocol table for P.Sithiphon
	  - **Content Curation Team (SMB/SMB/SFTP):** Edit ใน hot → เก็บไฟล์ไม่ค่อยใช้ใน warm → archive ระยะยาว
	  - **ZTE VoD Platform (NFS ทุก tier):** Ingest original file → transcode → process metadata ใช้ครบ 3 tier
	  - **MediaProxy Recorder (NFS):** Record live ลง hot tier แล้ว auto-move ไป warm
	  - **Vantage Transcoder/Packager (NFS):** Read/write ที่ hot tier แล้ว auto-move ไป warm
	  - **Cloud Transcoder (Aspera):** Read/write ที่ hot tier แล้ว auto-move ไป warm
	  - **Content Editor (SMB/SMB/SFTP):** Adobe Premiere edit ที่ hot tier เพื่อ performance
	  - **Content Partner (Aspera):** External user read/write เฉพาะ warm tier
- Discuss with the ZTE team about the Google WebView update that kills the AIS Play process, and explore ways to protect against or avoid this.
- Team meeting with P.Sitthisak
	- The Cloud Transcoder project has been put on hold and does not need to be implemented for now.
	- The Redfox CDN installation of the new OS and software needs to continue, as the CDN project must proceed with bidding for Tencent, ZTE, and Varnish and this take a time.
- CDN weekly meeting
	- Extend the Nginx socket limit from 1024 to 2048. The operations team will find a suitable date and inform Teohong to perform the activity.
	- Add new monitoring statistics on ZTR to count responses by status code. Teohong will perform load testing and send the results to the operations team.

---


# 2026-01-05_to_2026-01-09

**Period:** 2026-01-05_to_2026-01-09

5JAN26
- Discussed with Richard from ZTE regarding a frontend 403 error. This issue occurred because the frontend used authinfo with an invalid CID (channel ID) when requesting the manifest file from the ZTE manipulator. The error occurred on the ‘Workpoint’ channel, which uses CID V0015. However, according to Richard’s query, the request using authinfo contained CID V0022, which resulted in the 403 error. Richard ZTE will investigate further with AMT team.
- Ask Nuch to allow the CORS origin for MW dev/SIT for Yuexin (AMT)’s request.
- tracing this issue with Pengyi from AMT regarding the Monomax channel Sport 42 being unavailable. We found that the channel had an invalid configuration: it was using the AIS staging packager instead of the Monomax origin staging. Pengyi updated the configuration in the ZTE SMS portal to resolve the issue.
6JAN26
- K.Tah from ZTE Thailand Support raised an issue where the image was not updated after the Content Curation team made changes. He will coordinate with the operations team to purge the image using  P.Poch’s tool.
- K.Namprathai asked about the issue. We found that it was caused by a ‘hostname cannot be resolved’ error. I suggested that she further check which DNS the STB is using and why this error occurs.
- received https://mbs-svc.3bbtv.com:8443/drm/token from K.Kla (JAS). I am testing it and then shared the details with Yuexin as an interim solution for the Monomax concurrency issue.
- Supported P. Eak and P. Ton (Content Curation Team) in completing the Paramount questionnaire.
- K.Kangwan raised a case regarding an HTTP 403 error. NPAW logs show applogintype: HBA, apperrorname: 80250002, and apploginstatus: Fail when accessing https://commonvdomw.cloud.ais.th/v1/cm/distro?device=hp&&platform=oncloud. 
  After investigation, Natkitta confirmed that the issue was caused by the IP not being allowed on the WAF.
- Yuexin raise that the Axinom license DRM server rejected when using Airplay. Still finding the cause.
7JAN26
- Review SSAI and virtual channel document.
- The issue that occurred yesterday, raised by K.Kangwan—an HTTP 403 error where NPAW logs showed applogintype: HBA, apperrorname: 80250002, and apploginstatus: Fail when accessing https://commonvdomw.cloud.ais.th/v1/cm/distro?device=hp&&platform=oncloud—has been investigated and the root cause has been identified. 
  This error was caused by a WAF block.
- Confirm Mac from operation team to stop 'lightweight' service.
- Meeting with K.Meng Sukrit regarding the Irdeto re-solution and Irdeto configuration. The Irdeto ‘BID’ functions like a parent folder, and the content is associated with an ‘EPID’ and a ‘protection profile’.
  K.Meng would like to change the BID to use the CP ID.
  After discussion, we agreed that each content item will be associated with only one EPID initially.
8JAN26
- daily meeting with JAS/MONO team. Confirm the Cognito API and deleteSession API with Cao ZTE.
- Updated the Vidaa CSP questionnaire with additional information.
- review SSAI and FAST (virtual channel) POC test case.
- Meeting with ATEME for Pilot Media presentation.
- K.Oat from Trinergy create Vantage new flow to transcode the content with subtitle.
- investigate VO log for case Tizen 6.0
  Suspect root Cause: Tizen 6.0 triggers a second video license request ~1.4 seconds after the first one, but the 4-minute delay logic blocks it, causing the CDM to `timeout-fail` while waiting for a license that never comes.
  Fix: Allow immediate license retry when duplicate requests occur within a short timeframe, or bypass the delay logic when `timeout-fail` status is detected.
9JAN26
- Allow New AMT China HK: 156.59.98.47, 210.245.146.136 to staging Redfox CDN.
- Meeting to discuss how to investigate the hotel issue. Below are the tasks that need to test and investigate
	  - Rewrite the manifest to handle missing data to avoid **Error 2000 (OutOfIndex)**.
	  - Rewrite the application to verify whether all required mp data is properly received.
	  - We checked which source (mp3, mp2 and mp1) is reported in NPAW when errors occur during requests. For this case, N.Koi has already verified the behavior.
	  - When only mp3 is blocked, NPAW reports the resource as mp1, and mp3 appears in the error metadata. When mp3, mp2, and mp1 are all blocked, NPAW reports three error sessions, and the resources shown are mp1, mp2, and mp2 in sequence. This happens because after retrying mp1—which is the last available MP—the application cannot retry further, so NPAW logs the resource as mp2.
	  - This has already been verified: repeatedly selecting the same channel generates multiple NPAW sessions.
	  - Investigate **Decode Fail: Codec 4003** errors.
	  - For **memory-related errors**, coordinate with the ZTE team.
- testing request 'esTokenFordeleteSession' API that provided by JAS team, it's working.
  curl -X POST [http://ec2-43-209-205-181.ap-southeast-7.compute.amazonaws.com/csl/token](http://ec2-43-209-205-181.ap-southeast-7.compute.amazonaws.com/csl/token "http://ec2-43-209-205-181.ap-southeast-7.compute.amazonaws.com/csl/token") \  
  -H "Authorization: Bearer eyJhbGci..." \  
  -H "Content-Type: application/json" \  
  -d '{  
    "lic_jwt": "eyJhbGciOiJIUzI1Ni..."  
  }'
  {"token":"eyJhbGciOi...","expires_in":120}
- P. Rose discussed a solution for emergency broadcast messages (such as earthquake alerts). AIS plans to distribute these messages via AIS PLAYBOX. The solution will leverage S3, and OVP will collect the list of customers from S3 and process the emergency broadcast messages.
- Meeting with FMTS. A sample code for using a watermark in the Cast receiver was provided to K.Wow. I will bring it to N.Fray(Rujipat) to try.
- Blocking on Chromecast process
  The two entitlement endpoints use different, non-interchangeable cognitoToken (staging-entitlement-ais.monomax.me with concurrency_limit=1 and mbs-svc.3bbtv.com:8443 with concurrency_limit=2), and since the API to generate esTokenForDelSession is currently deployed only on mbs-svc.3bbtv.com:8443, we cannot generate it on the staging endpoint with limit=1, preventing meaningful testing; therefore, to allow the AMT team to continue development, we either need JAS to deploy the esTokenForDelSession API on staging-entitlement-ais.monomax.me or reduce the concurrency limit of mbs-svc.3bbtv.com:8443/drm/token to 1. Already summarize and send to K.Kla (JAS team)

---

