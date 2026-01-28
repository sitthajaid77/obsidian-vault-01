---
type: kb
category: kb-stb
tags: [aisplay, stb, android, app-architecture, mvvm, hilt, exoplayer, dash, streaming, error-handling, manifest, drm, webview, widevine, monomax, caching, heartbeat, javascript-bridge, mmkv, datastore]
date_created: 2026-01-13
last_updated: 2026-01-27
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

## Error Codes

For detailed error code documentation and troubleshooting, see [[kb-stb/error-code]].

**Quick Reference:**
- Error Code 80250000 - ECS (Emergency Configure Server) unreachable during app startup
- Error Code 15023002 - DASH manifest ParserException (malformed XML, missing Period)
- Error Code 15022000 - DASH manifest UnexpectedLoaderException (missing/empty SegmentTimeline)
- Silent Hang - Missing closing `</MPD>` tag

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
- [[kb-stb/error-code]] - Error codes and troubleshooting guide

---

## Notes

### 2026-01-27
- Extracted error handling section to dedicated [[kb-stb/error-code]] file
  - Moved all error code documentation (80250000, 15023002, 15022000) to new file
  - Added quick reference section in app.md with link to error-code.md
  - Improves maintainability and follows same pattern as kb-mobile/ios-error-code.md

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
