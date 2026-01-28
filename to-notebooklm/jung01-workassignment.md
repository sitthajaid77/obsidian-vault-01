# Work Assignments (jung01)

**Version:** jung01  
**Generated:** 2026-01-24 12:49:57  
**Source:** Obsidian Vault (jung01)  
**Author:** Yashiro

---


## Overview

Work assignments by Yashiro to team members.

- **Content:** Assignment details, assignee, deadlines, status tracking
- **Updates:** All updates include date stamps

---


# 2026-01-19_to_2026-01-23

**Period:** 2026-01-19_to_2026-01-23

---
type: assignment
week: 2026-W04
date_range: 2026-01-19 to 2026-01-23
date_created: 2026-01-19
last_updated: 2026-01-23
tags: [assignment, weekly]
---

# Work Assignment Week 04 (2026)

**Period:** 19 Jan 2026 to 23 Jan 2026

---

## In Progress

- **Koi**
	- [Developing] Develop STB and AndroidTV app to playback live channels through ZTE manipulator (mp)
		- Support both DRM and NON-DRM
		- Support both AIS and Monomax channels
		- **Date Assigned:** 2026-01-21
		- **Current Status:** Developing
		- **Definition of Done:** Feature Development
	- [Investigating] Debug entitlement expiration
		- Charles debug: found refresh at 10 hours
		- Code debug: still investigating, checking ExoPlayer session/cookie
		- **Current Status:** Investigating
		- **Definition of Done:** Investigation
	- [Investigating] (Carry over) Investigating authinfo with invalid CID
		- **Current Status:** Investigating
		- **Definition of Done:** Investigation
	- [Investigating] (Carry over) Finding 'Decoder fail' error
		- **Current Status:** Investigating
		- **Definition of Done:** Investigation
	- [Investigating] (Carry over) Simulate 'memory exhausted' on STB
		- **Current Status:** Investigating
		- **Definition of Done:** Investigation

- **Faii**
	- [Developing] Develop mobile app (iOS, Android) and tablet to playback live channels through ZTE manipulator (mp)
		- Support both DRM and NON-DRM
		- Support both AIS and Monomax channels
		- **Date Assigned:** 2026-01-21
		- **Current Status:** Developing
		- **Definition of Done:** Feature Development

- **Nuch & Bew**
	- [In Progress] DocMost Space & PLAY bot
		- Can use same space, but need to specify which space to use - inform Jack
		- **Current Status:** In Progress
		- **Definition of Done:** Configuration Change
	- [Developing] POC: Daily Alarm Summaries with RAG
		- **Date Assigned:** 2026-01-21
		- Goal: Build system to summarize alarm logs from CloudWatch daily and use RAG to answer questions via Teams/LINE bot
		- Timeline: 3-4 weeks
		- Budget: ~฿2,500/month
		- AWS Services:
			- Core: CloudWatch Logs, EventBridge, Lambda (4 functions), DynamoDB, S3
			- AI/ML: Bedrock (Claude for summarize + query, Titan for embeddings)
			- Database: Aurora PostgreSQL + pgvector
			- API: API Gateway, IAM
			- Monitoring: CloudWatch metrics and logs
		- **Current Status:** Developing
		- **Definition of Done:** POC/Prototype
	- [Investigating] Assist CCOE team to trace MW on-cloud ADMD connection issue
		- **Date Assigned:** 2026-01-22
		- Issue: MW on-cloud cannot connect to ADMD (timeout error)
		- Likely related to previous TLS SNI issue
		- **Current Status:** Investigating
		- **Definition of Done:** Investigation

- **Teohong**
	- [Testing] Nginx Auto-restart: Testing auto-restart feature in LAB when Geo module fails
		- Status: Testing in progress
		- **Date Updated:** 2026-01-22
		- **Current Status:** Testing
		- **Definition of Done:** Configuration Change

---

## Blocked / Waiting

- **Nuch & Bew**
	- DocMost production (coordinate with Jack/COE)
		- **Date Assigned:** Previous week
		- **Date Blocked:** 2026-01-19
		- **Blocked by:** P. Joke
		- **Waiting for:** Import Confluence data to DocMost
		- **Expected:** Unknown
		- **Last Update:** 2026-01-19 - Waiting for P. Joke to import Confluence data
	- OTT partner metadata - VIU
		- **Date Assigned:** Previous week
		- **Date Blocked:** 2026-01-19
		- **Blocked by:** VIU team
		- **Waiting for:** VIU team to contact back (they are busy)
		- **Expected:** Unknown
		- **Last Update:** 2026-01-19 - Haven't requested yet, their side is busy, will contact later
	- OTT partner metadata - Disney+ SFTP integration
		- **Date Assigned:** 2026-01-19
		- P. Pu asked about setup (2026-01-19)
		- Solution: AWS Transfer Family → S3 bucket → provide endpoint + user + key to Disney+
		- **Blocked by:** Disney+ and ZTE
		- **Waiting for:** Disney+ to coordinate with ZTE on data consumption, confirm metadata format compatibility
		- **Expected:** Unknown
		- **Last Update:** 2026-01-19 - Open: confirm metadata format compatibility with ZTE, if not compatible Nuch & Bew develop transform app
		- See [[kb-mw/disney-sftp]]

- **Teohong**
	- Nginx Socket Limit: Expand socket limit from 1024 to 2048
		- **Date Assigned:** Previous week
		- **Date Blocked:** 2026-01-22
		- **Blocked by:** Operations team
		- **Waiting for:** Operations team to confirm suitable date for deployment
		- **Expected:** Unknown
		- **Last Update:** 2026-01-22 - Waiting for Operations team to confirm suitable date

---

## Completed This Week

- **Nuch & Bew**
	- ✅ Lambda@Edge for ECS IPs - Deployed to production
		- **Date Completed:** 2026-01-14
		- **Final Status:** Production
		- **Outcome:** Successfully deployed to production
	- ✅ DocMost production - Migration from UAT to production
		- **Date Completed:** 2026-01-19
		- **Final Status:** Production
		- **Outcome:** Migration completed successfully

- **Koi**
	- ✅ Single App for NPAW staging
		- **Date Completed:** 2026-01-19
		- **Final Status:** Staging
		- **Outcome:** Can send to NPAW staging now
	- ✅ Single App - Solved stream disconnect issue
		- **Date Completed:** 2026-01-20
		- **Final Status:** Completed
		- **Outcome:** Fixed by setting the time for disable the monitor
	- ✅ Finding 'OutOfIndex' error
		- **Date Completed:** 2026-01-20
		- **Final Status:** Root Cause Identified
		- **Outcome:** Found root cause - caused by incomplete manifest
		- See [[kb-stb/app]]

- **Faii**
	- ✅ Watermark SDK on Cast receiver - Staging
		- **Date Completed:** 2026-01-20
		- **Final Status:** Staging
		- **Outcome:** Staging testing completed successfully
	- ✅ (Carry over) Watermark SDK on Cast receiver - production testing
		- **Date Completed:** 2026-01-21
		- **Final Status:** Completed
		- **Outcome:** Not needed; sent test code to ZTE/AMT, they will handle production testing themselves

- **Teohong**
	- ✅ Load Testing for new monitoring statistics on ZTR
		- **Date Completed:** 2026-01-22
		- **Final Status:** Completed
		- **Outcome:** Load testing completed successfully

- **Koi & Faii**
	- ✅ Handle IndexOutOfBound error in Media3 player for incomplete manifest
		- **Date Completed:** 2026-01-23
		- **Final Status:** Completed
		- **Outcome:** N.Koii optimized Media3 to handle incomplete manifest - player continues playback when encountering this case (may pause but does not crash)
		- Issue: IndexOutOfBound occurs on STB and Android mobile when encountering incomplete manifest
		- Note: Chromecast (Shaka player) does not have this issue
		- See [[kb-stb/app]] [[kb-mobile/app]]

- **Pim**
	- ✅ Tizen 6.0 DRM retry and display delay issue verification
		- **Date Completed:** 2026-01-23
		- **Final Status:** Completed
		- **Outcome:** Issue resolved in AMT template tested on 2026-01-22
		- Original task: Developing a Tizen Samsung Smart TV app to stream Monomax channel 501 in order to verify the DRM retry and display delay issue on Tizen 6.0

---

## Notes

- **2026-01-23:** Migrated to new WorkAssignment structure with status workflow and Definition of Done

---

## Related

- [[WorkLog/2026-01-19_to_2026-01-23]] (if exists)

---


# 2026-01-12_to_2026-01-16

**Period:** 2026-01-12_to_2026-01-16

- Pim
	- Developing a Tizen Samsung Smart TV app to stream Monomax channel 501 in order to verify the DRM retry and display delay issue on Tizen 6.0, and to check whether Tizen 6.0 aggressively retries DRM license requests.
- Koi
	- Investigating the root cause of the application using authinfo with an invalid CID.
	- Developing a single app to stream playback from the URL "https://d17kjhxmz8ss3z.cloudfront.net/live/localdisk/v0007_stg/dnf/v0007_stg.mpd" and send reports to NPAW staging. The goal is to verify whether we can reproduce the ‘unable to resolve hostname’ error similar to what occurs in AIS Play.
	- Finding the error 'OutOfIndex'
	- Finding the error 'Decoder fail'
	- Simulate a scenario to trigger ‘memory exhausted’ on the STB.
- Faii
	- Test the implementation of the watermark SDK on the Cast receiver.
		- ทำได้แล้ว สเต็ปต่อไปลองกับ production (update 2026-01-19)
	- Coordinate with the test team to perform testing using the Robot Framework.
		- โชว์เคสให้ทีมทดสอบ (พี่ติว พี่เกด) ดูแล้ว อธิบายกระบวนการตามที่น้องทำให้ได้สคริปต์ที่รันมา โยน testcase เข้า docmost > ให้ copilot gen > run script (update 2026-01-19)
- Nuch & Bew
	- Support a Lambda@Edge function for handling requests from specific ECS IPs.
	- Coordinate with Jack from the COE team to check the DocMost production timeline, including when production access can be received and how the storage space will be structured and used.
		- From DocMost UAT to DocMost production, do we need to perform a migration, or will DocMost production automatically copy everything from DocMost UAT?
		- In DocMost production, can we separate content into multiple spaces similar to Confluence, or do we have to use a single space and organize topics within that space?
		- If multiple spaces are supported like in Confluence, will this affect the AI agent (PLAY bot)? Specifically, will PLAY bot be able to use multiple spaces as its data sources?
	- OTT partner metadata VIU, Disney+ support.

---

