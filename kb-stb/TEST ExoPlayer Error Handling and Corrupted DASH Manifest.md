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