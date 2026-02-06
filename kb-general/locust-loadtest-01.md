# Load Testing HLS Streaming with Locust

#loadtest #hls #streaming #locust #performance

## Overview

Locust เป็น open-source load testing tool ที่ใช้ Python ในการเขียน test scenarios เหมาะสำหรับทดสอบ HLS streaming workflow (master playlist → variant playlist → segments)

## Prerequisites

### macOS Installation

```bash
# ใช้ pipx (แนะนำ)
brew install pipx
pipx ensurepath
pipx install locust

# ตรวจสอบ
locust --version
```

### Ubuntu Server Installation

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# ติดตั้ง Python3 และ pip
sudo apt install python3 python3-pip -y

# ติดตั้ง Locust
pip3 install locust

# ตรวจสอบ
locust --version
```

## Basic HLS Test Script

สร้างไฟล์ `locustfile.py`:

```python
from locust import HttpUser, task, between

class HLSStreamUser(HttpUser):
    wait_time = between(1, 2)  # รอ 1-2 วินาทีระหว่าง requests
    host = "https://test-streams.mux.dev"
    
    def on_start(self):
        """กำหนด headers สำหรับทุก requests"""
        self.headers = {
            'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36',
            'Accept': '*/*',
            'Accept-Encoding': 'identity',
            'Connection': 'keep-alive'
        }
    
    @task
    def test_hls_workflow(self):
        """Simulate HLS player behavior"""
        master_path = "/x36xhzz/x36xhzz.m3u8"
        
        # 1. Request master playlist
        with self.client.get(master_path,
                            headers=self.headers,
                            catch_response=True,
                            name="Master Playlist") as response:
            if response.status_code == 200:
                print(f"✓ Master: {response.status_code} - {len(response.text)} bytes")
                
                # 2. Parse variant playlists
                variant_urls = self.parse_variant_playlists(response.text, master_path)
                
                if variant_urls:
                    variant_url = variant_urls[0]
                    
                    # 3. Request variant playlist
                    with self.client.get(variant_url,
                                        headers=self.headers,
                                        catch_response=True,
                                        name="Variant Playlist") as var_response:
                        if var_response.status_code == 200:
                            print(f"✓ Variant: {var_response.status_code}")
                            
                            # 4. Get latest segment
                            segment_url = self.get_latest_segment(var_response.text, variant_url)
                            
                            if segment_url:
                                # 5. Request segment
                                with self.client.get(segment_url,
                                                    headers=self.headers,
                                                    catch_response=True,
                                                    name="Video Segment") as seg_response:
                                    if seg_response.status_code == 200:
                                        print(f"✓ Segment: {len(seg_response.content)} bytes")
                                        response.success()
                                    else:
                                        response.failure(f"Segment: {seg_response.status_code}")
                            else:
                                response.failure("No segments found")
                        else:
                            response.failure(f"Variant: {var_response.status_code}")
                else:
                    response.failure("No variants found")
            else:
                response.failure(f"Master: {response.status_code}")
    
    def parse_variant_playlists(self, master_content, master_path):
        """แยก variant playlist URLs จาก master playlist"""
        variant_urls = []
        lines = master_content.split('\n')
        base_path = '/'.join(master_path.split('/')[:-1])
        
        for line in lines:
            line = line.strip()
            if line and not line.startswith('#') and '.m3u8' in line:
                if not line.startswith('http'):
                    variant_urls.append(f"{base_path}/{line}")
                else:
                    variant_urls.append(line)
        
        return variant_urls
    
    def get_latest_segment(self, variant_content, variant_path):
        """หา segment ล่าสุดจาก variant playlist"""
        segments = []
        lines = variant_content.split('\n')
        base_path = '/'.join(variant_path.split('/')[:-1])
        
        for line in lines:
            line = line.strip()
            if line and not line.startswith('#') and ('.ts' in line or '.m4s' in line):
                if not line.startswith('http'):
                    segments.append(f"{base_path}/{line}")
                else:
                    segments.append(line)
        
        return segments[-1] if segments else None
```

## Running Tests

### Local Development

```bash
# รัน Locust
locust -f locustfile.py

# เปิด Web UI
http://localhost:8089
```

### Remote Server

```bash
# รัน และเปิดให้เข้าถึงจากภายนอก
locust -f locustfile.py --web-host=0.0.0.0

# เข้า Web UI
http://<SERVER_IP>:8089
```

### Headless Mode (CLI)

```bash
# รันโดยไม่ต้องใช้ Web UI
locust -f locustfile.py \
  --host=https://your-target.com \
  --users=100 \
  --spawn-rate=10 \
  --run-time=5m \
  --headless
```

## Understanding Parameters

### Number of Users

- จำนวน **virtual users** ที่ทำงานพร้อมกัน
- แต่ละ user วนทำ tasks ซ้ำไปเรื่อยๆ
- ตัวอย่าง: 10 users = มี 10 virtual users ทำงานพร้อมกัน

### Spawn Rate

- เพิ่ม users ทีละกี่คนต่อวินาที
- ตัวอย่าง: spawn rate = 2
    - วินาทีที่ 0: 0 users
    - วินาทีที่ 1: 2 users
    - วินาทีที่ 2: 4 users
    - วินาทีที่ 5: 10 users (ครบ)

### Wait Time

```python
wait_time = between(1, 2)  # รอ 1-2 วินาทีระหว่าง tasks
```

## Reading Test Results

### Statistics Tab

|Metric|Description|
|---|---|
|# Requests|จำนวน requests ทั้งหมด|
|# Fails|จำนวน requests ที่ล้มเหลว|
|Median (ms)|เวลาตอบสนองกลาง (50%ile)|
|95%ile (ms)|95% ของ requests เร็วกว่านี้|
|99%ile (ms)|99% ของ requests เร็วกว่านี้|
|Average (ms)|เวลาตอบสนองเฉลี่ย|
|Min/Max (ms)|เวลาตอบสนองต่ำสุด/สูงสุด|
|Average size|ขนาดเฉลี่ยของ response (bytes)|
|Current RPS|Requests Per Second ปัจจุบัน|

### Example Results

```
Master Playlist:  101 requests, 0 failures
  - Median: 34ms, 95%ile: 230ms, Avg: 85.78ms
  - Size: 752 bytes

Variant Playlist: 101 requests, 0 failures
  - Median: 22ms, 95%ile: 63ms, Avg: 30.31ms
  - Size: 3,606 bytes

Video Segment:    101 requests, 0 failures
  - Median: 170ms, 95%ile: 330ms, Avg: 200.84ms
  - Size: 631,868 bytes (~617 KB)

Overall RPS: 16.8 requests/second
```

## Distributed Load Testing

สำหรับ load test ขนาดใหญ่ ใช้ master-worker architecture:

### Master Node

```bash
# รัน master (ไม่ simulate users)
locust -f locustfile.py \
  --master \
  --master-bind-host=0.0.0.0 \
  --expect-workers=4
```

### Worker Nodes

```bash
# รัน worker แต่ละเครื่อง
locust -f locustfile.py \
  --worker \
  --master-host=<MASTER_IP>
```

### Architecture

```
┌─────────────┐
│   Master    │ <-- Web UI (port 8089)
│  (Control)  │
└──────┬──────┘
       │
   ┌───┴───┬───────┬───────┐
   │       │       │       │
┌──▼──┐ ┌──▼──┐ ┌──▼──┐ ┌──▼──┐
│Work1│ │Work2│ │Work3│ │Work4│
└─────┘ └─────┘ └─────┘ └─────┘
```

### Docker Compose Setup

```yaml
version: '3'

services:
  master:
    image: locustio/locust
    ports:
      - "8089:8089"
    volumes:
      - ./:/mnt/locust
    command: -f /mnt/locust/locustfile.py --master

  worker:
    image: locustio/locust
    volumes:
      - ./:/mnt/locust
    command: -f /mnt/locust/locustfile.py --worker --master-host=master
    deploy:
      replicas: 4
```

```bash
# รัน distributed setup
docker-compose up --scale worker=4
```

## Capacity Planning

### Single Server Setup

- **Hardware:** 4-8 vCPU, 8-16 GB RAM
- **Capacity:** ~500-1,000 concurrent users
- **Use case:** Development, small-scale testing

### Distributed Setup

- **Master:** 2 vCPU, 4 GB RAM
- **Workers:** 4-8 workers × (4-8 vCPU each)
- **Capacity:** 5,000-10,000+ concurrent users
- **Use case:** Production load testing

## Advanced Scenarios

### Multiple Bitrate Testing

```python
@task(3)  # น้ำหนัก 3
def test_high_bitrate(self):
    # Test highest bitrate variant
    pass

@task(2)  # น้ำหนัก 2
def test_medium_bitrate(self):
    # Test medium bitrate variant
    pass

@task(1)  # น้ำหนัก 1
def test_low_bitrate(self):
    # Test lowest bitrate variant
    pass
```

### ABR Simulation

```python
def test_adaptive_bitrate(self):
    """Simulate adaptive bitrate switching"""
    variants = self.get_all_variants()
    
    # Start with lowest
    current = variants[0]
    
    # Gradually increase quality
    for variant in variants:
        self.request_segment(variant)
        time.sleep(2)
```

### Long-Running Sessions

```python
class LongSessionUser(HttpUser):
    @task
    def watch_full_stream(self):
        """Simulate watching for 5 minutes"""
        start_time = time.time()
        
        while time.time() - start_time < 300:  # 5 minutes
            self.request_latest_segment()
            time.sleep(6)  # segment duration
```

## Monitoring & Metrics

### Key Metrics to Track

- **Response Time:** P50, P95, P99
- **Error Rate:** % of failed requests
- **Throughput:** RPS (Requests Per Second)
- **Bandwidth:** MB/s consumed
- **Success Rate:** % of successful complete workflows

### Export Results

```bash
# Download as CSV from Web UI
# หรือใช้ --csv flag
locust -f locustfile.py --csv=results --headless
```

## Best Practices

### 1. Start Small

- เริ่มด้วย 10-50 users
- ตรวจสอบว่า workflow ทำงานถูกต้อง
- ค่อยๆ เพิ่ม load

### 2. Realistic Simulation

```python
# ใช้ wait time ที่สมจริง
wait_time = between(5, 15)  # segment duration

# เพิ่ม User-Agent หลากหลาย
user_agents = [
    'iOS/Safari',
    'Android/Chrome',
    'Smart TV/WebKit'
]
```

### 3. Monitor Target Server

- ดู CPU, Memory, Network usage
- ตรวจสอบ CDN metrics
- ดู application logs

### 4. Test Scenarios

- Peak load (concurrent users สูงสุด)
- Sustained load (ทำงานต่อเนื่อง)
- Spike test (เพิ่ม users ทันที)
- Stress test (หา breaking point)

## Troubleshooting

### High Failure Rate

- ตรวจสอบ FAILURES tab
- ดู error codes (403, 404, 500, 503)
- เช็ค authentication/headers
- ตรวจสอบ rate limiting

### Low RPS

- เพิ่มจำนวน workers
- ลด wait_time
- เพิ่ม hardware resources
- ใช้ distributed mode

### Connection Errors

```python
# เพิ่ม connection pool
class MyUser(HttpUser):
    connection_timeout = 10.0
    network_timeout = 10.0
```

## Related Tools

### Alternative Load Testing Tools

- **JMeter:** GUI-based, มี HLS plugin
- **k6:** JavaScript-based, performance สูง
- **Artillery:** YAML config, CI/CD friendly
- **Gatling:** Scala-based, detailed reports

### Complementary Tools

- **Grafana + InfluxDB:** Real-time monitoring
- **Prometheus:** Metrics collection
- **AWS CloudWatch:** AWS infrastructure monitoring

## References

- [Locust Documentation](https://docs.locust.io/)
- [HLS Specification](https://datatracker.ietf.org/doc/html/rfc8216)
- [Load Testing Best Practices](https://docs.locust.io/en/stable/running-distributed.html)

## Tags

#testing #performance #video #cdn #aws #distributed-systems

---

**Related Notes:**

- [[HLS Streaming Protocol]]
- [[CDN Configuration]]
- [[Video Performance Testing]]
- [[AWS Distributed Load Testing]]