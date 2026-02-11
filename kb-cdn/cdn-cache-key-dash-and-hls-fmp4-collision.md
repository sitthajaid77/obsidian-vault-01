## Problem

DASH (MPEG-DASH) and HLS-fMP4 (Apple HLS with fMP4 segments) both use ISO BMFF containers and generate `init.mp4` initialization segments with identical filenames. The packager (SAF_DRM) generates init filenames using the pattern:

```
{channel}-{representation_id}-p={period}-init.mp4
```

Since the audio representation ID is the same across all profiles (e.g. `mp4a_96000_eng=6`), the **audio init filename is identical across every DASH and HLS-fMP4 profile**. The only differentiator is the subpath containing the profile name.

### Example (Channel Z0016)

|Profile|Format|Init Segment Path|
|---|---|---|
|DD4 (DASH)|MPEG-DASH|`/live/eds/Z0016/DD4/Z0016-mp4a_96000_eng=6-p=350360765880000-init.mp4`|
|HD4F (HLS-fMP4)|Apple HLS 4s fMP4|`/live/eds/Z0016/HD4F/Z0016-mp4a_96000_eng=6-p=350360765880000-init.mp4`|
|DDF (DASH)|MPEG-DASH|`/live/eds/Z0016/DDF/Z0016-mp4a_96000_eng=6-p=350360765880000-init.mp4`|
|HDFF (HLS-fMP4)|Apple HLS 4s fMP4|`/live/eds/Z0016/HDFF/Z0016-mp4a_96000_eng=6-p=350360765880000-init.mp4`|

If the CDN uses only the filename as the cache key, a DASH `init.mp4` could be served to an HLS-fMP4 player (or vice versa), causing playback failure.

## Affected Profiles

All DASH and HLS-fMP4 profiles are affected:

`DASH, DD4, DDF, DDH, DDS, DNCF, DNF, HD4F, HDFF, HDHF, HDSF, HN4F`

HLS-TS profiles (HD4, HDF, HDH, HDS, HLS, HNCF, HLSV3) are **not affected** as they do not use `init.mp4`.

### Matched Pairs (Same Bitrate, Different Format)

|DASH Profile|HLS-fMP4 Profile|Bitrate|
|---|---|---|
|DD4|HD4F|Up to 11000 kbit/s|
|DDF|HDFF|Up to 6000 kbit/s|
|DDH|HDHF|Up to 4000 kbit/s|
|DDS|HDSF|Up to 2800 kbit/s|

Note: Audio init segments collide across **all** profile combinations, not just matched pairs.

## Solution: Cache Key Strategy

Use the **full URI path** as the cache key.

| Component             | Example                                  | Include in Cache Key? | Reason                                                               |
| --------------------- | ---------------------------------------- | --------------------- | -------------------------------------------------------------------- |
| Full path             | `/live/eds/Z0016/DD4/Z0016-...-init.mp4` | ✅ Yes                 | Differentiates profiles                                              |
| Query string (`rfkz`) | `rfkz=1770786000_3545c8...`              | ❌ No                  | Changes on token rotation; including it causes constant cache misses |

### Cache Key Format

```
/live/eds/{channel}/{profile}/{filename}
```

This ensures that `/live/eds/Z0016/DD4/...init.mp4` and `/live/eds/Z0016/HD4F/...init.mp4` are cached as separate objects.

---

_Source: SAF_DRM configuration (used by 73 channels), verified against live manifests for channel Z0016 on 2026-02-11._