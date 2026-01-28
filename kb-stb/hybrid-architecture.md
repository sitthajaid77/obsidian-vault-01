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
