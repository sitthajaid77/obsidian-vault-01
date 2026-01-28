---
type: kb
category: mw
tags: [api, admd, middleware, platform-config, authentication, purchase]
date_created: 2026-01-21
last_updated: 2026-01-28
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

### On-cloud MW Endpoints

**Date Updated:** 2026-01-28

| Group | No. | Full domain | Sub path |
| --- | --- | --- | --- |
| Common | 1 | https://commonvdomw.cloud.ais.th/v1/cm/distro?device=hp&platform=oncloud | /v1/cm/distro |
|  | 2 | https://commonvdomw.cloud.ais.th/v1/cm/authen/onboard/login | /v1/cm/authen/onboard/login |
|  | 3 | https://commonvdomw.cloud.ais.th/v1/cm/sso/middleware/login | /v1/cm/sso/middleware/login |
|  | 4 | https://commonvdomw.cloud.ais.th/v1/cm/pushnotification | /v1/cm/pushnotification |
| HP | 5 | https://fwdhpvdomw-aisplay.ais.th/v1/hp/authen/dvplogin | /v1/hp/authen/dvplogin |
|  | 6 | https://hpvdomw.cloud.ais.th/v1/hp/authen/refreshtoken | /v1/hp/authen/refreshtoken |
|  | 7 | https://hpvdomw.cloud.ais.th/v1/hp/authen/logout | /v1/hp/authen/logout |
|  | 8 | https://hpvdomw.cloud.ais.th/v1/hp/authen/validatemwtoken | /v1/hp/authen/validatemwtoken |
|  | 9 | https://hpvdomw.cloud.ais.th/v1/hp/authen/generateqrcode | /v1/hp/authen/generateqrcode |
|  | 10 | https://hpvdomw.cloud.ais.th/v1/hp/authen/dvpqrlogin | /v1/hp/authen/dvpqrlogin |
| BS | 11 | https://bsvdomw.cloud.ais.th/v1/bs/authen/generateqrcode | /v1/bs/authen/generateqrcode |
|  | 12 | https://bsvdomw.cloud.ais.th/v1/bs/authen/dvpqrlogin | /v1/bs/authen/dvpqrlogin |
|  | 13 | https://fwdbsvdomw-aisplay.ais.th/v1/bs/authen/dvplogin | /v1/bs/authen/dvplogin |
|  | 14 | https://fwdbsvdomw-aisplay.ais.th/v1/bs/authen/queryfbbid/dvplogin | /v1/bs/authen/queryfbbid/dvplogin |
|  | 15 | https://bsvdomw.cloud.ais.th/v1/bs/authen/requestOTP | /v1/bs/authen/requestOTP |
|  | 16 | https://bsvdomw.cloud.ais.th/v1/bs/authen/genmwtokenbyotp | /v1/bs/authen/genmwtokenbyotp |
|  | 17 | https://bsvdomw.cloud.ais.th/v1/bs/authen/refreshtoken | /v1/bs/authen/refreshtoken |
|  | 18 | https://bsvdomw.cloud.ais.th/v1/bs/authen/logout | /v1/bs/authen/logout |
|  | 19 | https://bsvdomw.cloud.ais.th/v1/bs/authen/validatemwtoken | /v1/bs/authen/validatemwtoken |
|  | 20 | https://bsvdomw.cloud.ais.th/v1/bs/authen/loginguest | /v1/bs/authen/loginguest |
| Crimson | 21 | http://crimsonvdomw.cloud.ais.th/v1/cs/authen/crimson/encrypt | /v1/cs/authen/crimson/encrypt |
| SM | 22 | https://smvdomw.cloud.ais.th/v1/sm/authen/dvplogin | /v1/sm/authen/dvplogin |
|  | 23 | https://smvdomw.cloud.ais.th/v1/sm/authen/requestOTP | /v1/sm/authen/requestOTP |
|  | 24 | https://smvdomw.cloud.ais.th/v1/sm/authen/genmwtokenbyotp | /v1/sm/authen/genmwtokenbyotp |
|  | 25 | https://smvdomw.cloud.ais.th/v1/sm/authen/refreshtoken | /v1/sm/authen/refreshtoken |
|  | 26 | https://smvdomw.cloud.ais.th/v1/sm/authen/logout | /v1/sm/authen/logout |
|  | 27 | https://smvdomw.cloud.ais.th/v1/sm/authen/validatemwtoken | /v1/sm/authen/validatemwtoken |
|  | 28 | https://smvdomw.cloud.ais.th/v1/sm/authen/confirmconnected | /v1/sm/authen/confirmconnected |
|  | 29 | https://smvdomw.cloud.ais.th/v1/sm/authen/loginguest | /v1/sm/authen/loginguest |
| Proxy | 30 | https://proxyvdomw.cloud.ais.th/v1/otthub/vs/api/vinson-api/get-offer-packages | /v1/otthub/vs/api/vinson-api/get-offer-packages |
|  | 31 | https://proxyvdomw.cloud.ais.th/v1/otthub/vs/api/vinson-api/get-commu-package | /v1/otthub/vs/api/vinson-api/get-commu-packages |
|  | 32 | https://proxyvdomw.cloud.ais.th/v1/otthub/vs/api/vinson-api/check-apply-package-eligibility | /v1/otthub/vs/api/vinson-api/check-apply-package-eligibility |
|  | 33 | https://proxyvdomw.cloud.ais.th/v1/otthub/vs/api/vinson-api/request-otp-dvp | /v1/otthub/vs/api/vinson-api/request-otp-dvp |
|  | 34 | https://proxyvdomw.cloud.ais.th/v1/otthub/vs/api/vinson-api/confirm-otp-and-subscribe-package-dvp | /v1/otthub/vs/api/vinson-api/confirm-otp-and-subscribe-package-dvp |
|  | 35 | https://proxyvdomw.cloud.ais.th/v1/otthub/vacc/api/eisenhower-api/token-auth | /v1/otthub/vacc/api/eisenhower-api/token-auth |
|  | 36 | https://proxyvdomw.cloud.ais.th/v1/admd3/api/v3/aaf/sendOTP | /v1/admd3/api/v3/aaf/sendOTP |
|  | 37 | https://proxyvdomw.cloud.ais.th/v1/admd3/api/v3/aaf/confirmOTP | /v1/admd3/api/v3/aaf/confirmOTP |

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

### 2026-01-28
- Added comprehensive on-cloud MW endpoints table for Common, HP, BS, Crimson, SM, and Proxy groups

### 2026-01-21
- ADMD API configuration is consistent across AWS and on-premise platforms
- MW/purchase APIs use platform-specific proxy URLs (numbered 1, 2, 3)
