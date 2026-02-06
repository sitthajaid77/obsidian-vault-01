1. 1102
   Faii performed a mock test using Charles. When the TR and CDN domains returned 403, this error occurred (update 2026-01-26)
2. 1105
   Faii performed a mock test using Charles. When the ZTE manifest manipulator domain returned 403, this error occurred (update 2026-01-26)
3. 20810
   Faii performed a mock test using Charles. When the Entitlement Service API is blocked, this error occurs. The error is caused by the Entitlement Service being unreachable (update 2026-01-27)
4. -12927
   CoreMediaErrorDomain error occurs when iOS player receives invalid init.mp4 with wrong DRM format (e.g., CENC encryption for DASH Widevine/PlayReady instead of FairPlay cbcs). Discovered during live channel playback testing. Root cause in tested case: CDN cache key collision in Varnish configuration causing DASH and HLS-fMP4 init segments to share same cache key due to profile name normalization. Confirmed by SHA-256 hash comparison. Fix: Exclude init segments from profile normalization in Varnish vcl_hash configuration. Note: This error is not content-specific (not related to Dolby or any particular channel) - it occurs whenever FairPlay receives incompatible init segment format (update 2026-02-04)