# AWS Application Performance Monitoring (APM) Lab - สรุปผลการทดลอง

**วันที่:** 7 กุมภาพันธ์ 2026  
**Region:** ap-southeast-7 (Bangkok)  
**เป้าหมาย:** ทดลองใช้ AWS Application Signals เพื่อทำ APM (Application Performance Monitoring) บน EKS

---

## 🎯 วัตถุประสงค์

เรียนรู้การใช้งาน AWS Application Signals สำหรับ:

- Distributed Tracing
- Service Dependencies Mapping
- Application Performance Metrics
- Service Level Objectives (SLO)

---

## 🏗️ สถาปัตยกรรมที่ใช้

### Infrastructure

- **EKS Cluster:** apm-lab-cluster
- **Kubernetes Version:** 1.30
- **Node Type:** t3.small (2 nodes)
- **Availability Zones:** ap-southeast-7b, ap-southeast-7c

### Application Architecture

```
Internet → LoadBalancer → frontend-api (port 8080) → backend-api (port 8081)
                              ↓                            ↓
                         CloudWatch Agent (OTLP collector)
                              ↓
                         AWS X-Ray / Application Signals
```

### Sample Applications

- **Frontend API:** Node.js + Express (2 replicas)
    - Endpoint: `/api/users`
    - Calls backend API internally
- **Backend API:** Node.js + Express (2 replicas)
    - Endpoint: `/api/data`
    - Returns mock user data with random delay (0-100ms)

---

## 📦 Components ที่ติดตั้ง

### 1. EKS Cluster

```bash
eksctl create cluster \
  --name apm-lab-cluster \
  --region ap-southeast-7 \
  --nodegroup-name standard-workers \
  --node-type t3.small \
  --nodes 2
```

### 2. Tools Installed

- **eksctl:** v0.205.0
- **kubectl:** v1.32.2
- **aws-cli:** v2.27.34

### 3. ECR Repositories

- `891377077085.dkr.ecr.ap-southeast-7.amazonaws.com/apm-lab/frontend-api:latest`
- `891377077085.dkr.ecr.ap-southeast-7.amazonaws.com/apm-lab/backend-api:latest`
- Platform: linux/amd64

### 4. IAM Permissions (Node Role)

```
eksctl-apm-lab-cluster-nodegroup-s-NodeInstanceRole-t8L19dhN2bMD
```

Attached Policies:

- CloudWatchAgentServerPolicy
- AWSXRayDaemonWriteAccess
- AmazonEC2ContainerRegistryReadOnly
- AmazonEKSWorkerNodePolicy
- AmazonEKS_CNI_Policy

### 5. CloudWatch Observability Add-on

- **Version:** v4.10.0-eksbuild.1
- **Components:**
    - CloudWatch Agent (DaemonSet, 2 pods)
    - OTLP Receivers: HTTP (4316), gRPC (4315)
    - Application Signals processors

---

## 🔧 OpenTelemetry Instrumentation

### Package Dependencies

```json
{
  "dependencies": {
    "express": "^4.18.2",
    "axios": "^2.1.0",
    "@opentelemetry/api": "^1.9.0",
    "@opentelemetry/sdk-node": "^0.211.0",
    "@opentelemetry/auto-instrumentations-node": "^0.69.0",
    "@opentelemetry/exporter-trace-otlp-http": "^0.211.0"
  }
}
```

### Dockerfile Configuration

```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install --production
COPY server.js ./
EXPOSE 8080

# Auto-instrumentation via --require flag
CMD ["node", "--require", "@opentelemetry/auto-instrumentations-node/register", "server.js"]
```

### Environment Variables (Kubernetes)

```yaml
env:
  - name: OTEL_SERVICE_NAME
    value: "frontend-api"  # หรือ "backend-api"
  - name: OTEL_EXPORTER_OTLP_ENDPOINT
    value: "http://cloudwatch-agent.amazon-cloudwatch:4316"
  - name: OTEL_TRACES_EXPORTER
    value: "otlp"
```

**หมายเหตุสำคัญ:**

- ต้องใช้ port **4316** (HTTP) ไม่ใช่ 4318
- ต้องมี `OTEL_TRACES_EXPORTER=otlp` ด้วย

---

## ✅ สิ่งที่ทำสำเร็จ

### 1. Infrastructure Setup

- ✅ สร้าง EKS cluster สำเร็จ
- ✅ Deploy applications (frontend + backend) สำเร็จ
- ✅ LoadBalancer ทำงานได้ (สามารถเรียก API จากภายนอกได้)
- ✅ IAM roles และ permissions ถูกต้อง

### 2. OpenTelemetry Instrumentation

- ✅ ติดตั้ง OpenTelemetry packages ครบถ้วน
- ✅ Auto-instrumentation ทำงาน (ใช้ `--require` flag)
- ✅ Environment variables ครบถ้วนทั้ง 3 ตัว
- ✅ Applications เชื่อมต่อกับ CloudWatch Agent ได้ (port 4316)

### 3. CloudWatch Agent

- ✅ ติดตั้ง CloudWatch Observability Add-on สำเร็จ
- ✅ OTLP receivers listening บน port 4315 (gRPC) และ 4316 (HTTP)
- ✅ Application Signals processors enabled

### 4. Distributed Tracing

- ✅ **Traces ถูกส่งไป X-Ray backend สำเร็จ** (62 traces ใน 30 นาที)
- ✅ Service names ถูกต้อง: `frontend-api`, `backend-api`
- ✅ Origin: `AWS::EKS::Container`
- ✅ Trace IDs และ duration ถูกบันทึก

**ตรวจสอบได้จาก:**

```bash
aws xray get-trace-summaries \
  --start-time $(date -u -v-30M +%s) \
  --end-time $(date -u +%s) \
  --region ap-southeast-7
```

ผลลัพธ์: **62 traces** พร้อม HTTP URLs และ duration

---

## ❌ สิ่งที่ไม่ทำงาน

### 1. Application Signals Console

- ❌ **Dependencies tab:** แสดง "No dependencies"
- ❌ **Metrics:** Requests, Faults, Errors ทั้งหมดเป็น 0
- ❌ **Service Map:** ไม่แสดงความสัมพันธ์ระหว่าง frontend → backend
- ❌ **Service operations:** ไม่มีข้อมูล

### 2. CloudWatch Metrics

```bash
aws cloudwatch list-metrics \
  --namespace AWS/ApplicationSignals \
  --region ap-southeast-7
```

ผลลัพธ์: `{"Metrics": []}` (ว่างเปล่า)

---

## 🔍 การวินิจฉัยปัญหา

### สิ่งที่ตรวจสอบแล้ว

1. **Network Connectivity**
    
    ```bash
    kubectl exec deployment/frontend-api -- nc -zv cloudwatch-agent.amazon-cloudwatch 4316
    ```
    
    ✅ เชื่อมต่อได้ (port open)
    
2. **Environment Variables**
    
    ```bash
    kubectl exec deployment/frontend-api -- env | grep OTEL
    ```
    
    ✅ ครบทั้ง 3 ตัว (SERVICE_NAME, ENDPOINT, EXPORTER)
    
3. **OpenTelemetry Packages**
    
    ```bash
    kubectl exec deployment/frontend-api -- npm list | grep opentelemetry
    ```
    
    ✅ ติดตั้งครบถ้วน
    
4. **CloudWatch Agent Logs**
    
    ```bash
    kubectl logs -n amazon-cloudwatch -l app.kubernetes.io/name=cloudwatch-agent
    ```
    
    ✅ Agent รัน และ listening OTLP receivers ❌ ไม่เห็น logs บอกว่ารับ traces (แปลกแต่ X-Ray มี traces)
    
5. **Add-on Configuration**
    
    ```bash
    aws eks describe-addon --cluster-name apm-lab-cluster \
      --addon-name amazon-cloudwatch-observability \
      --region ap-southeast-7
    ```
    
    ✅ Application Signals enabled ใน config
    

---

## 🐛 ปัญหาที่พบและแก้ไข

### Issue 1: Port ผิด (4318 → 4316)

**ปัญหา:** ตั้งค่า `OTEL_EXPORTER_OTLP_ENDPOINT` ไปที่ port 4318  
**สาเหตุ:** CloudWatch Agent ฟัง HTTP ที่ port 4316, gRPC ที่ 4315  
**วิธีแก้:** เปลี่ยนเป็น `http://cloudwatch-agent.amazon-cloudwatch:4316`

### Issue 2: ขาด OTEL_TRACES_EXPORTER

**ปัญหา:** OpenTelemetry SDK ไม่ส่ง traces  
**สาเหตุ:** ต้องระบุ exporter type  
**วิธีแก้:** เพิ่ม `OTEL_TRACES_EXPORTER=otlp`

### Issue 3: Syntax Error ในโค้ด

**ปัญหา:** Application crash ด้วย `SyntaxError: Invalid or unexpected token`  
**สาเหตุ:** มี `\;` ผิดในโค้ด จาก copy/paste ผิดพลาด  
**วิธีแก้:** แก้ไข server.js และ rebuild Docker image

### Issue 4: Docker Image Platform

**ปัญหา:** ตอนแรก build บน ARM64 (Apple Silicon)  
**วิธีแก้:** Build ด้วย `--platform linux/amd64`

### Issue 5: Too Many Pods

**ปัญหา:** `0/2 nodes are available: 2 Too many pods`  
**สาเหตุ:** t3.small รัน pods ได้จำกัด  
**วิธีแก้:** Kubernetes scheduler จัดการได้เอง (pods ถูก schedule สำเร็จ)

---

## 🧪 การทดสอบ

### Traffic Generation

```bash
# ส่ง 50-200 requests ด้วย interval 2-3 วินาที
for i in {1..50}; do
  curl -s http://a44fd4844e9c14595a989336d8ba0fe1-147359648.ap-southeast-7.elb.amazonaws.com:8080/api/users
  echo "Request $i sent"
  sleep 2
done
```

### API Response ตัวอย่าง

```json
{
  "service": "frontend",
  "data": {
    "service": "backend",
    "users": [
      {"id": 1, "name": "Yashiro", "role": "Technical Engineer"},
      {"id": 2, "name": "Alice", "role": "DevOps"},
      {"id": 3, "name": "Bob", "role": "Backend Developer"}
    ],
    "timestamp": "2026-02-07T06:11:41.731Z"
  },
  "timestamp": "2026-02-07T06:11:41.737Z"
}
```

---

## 📊 ผลการทดสอบ

|Component|Status|Details|
|---|---|---|
|EKS Cluster|✅ Working|2 nodes, Kubernetes 1.30|
|Applications|✅ Working|Frontend + Backend responding|
|LoadBalancer|✅ Working|Public access successful|
|OpenTelemetry|✅ Working|Auto-instrumentation configured|
|X-Ray Traces|✅ Working|62 traces collected|
|CloudWatch Agent|✅ Working|Receiving data on port 4316|
|Application Signals UI|❌ Not Working|No dependencies, no metrics|
|Service Map|❌ Not Working|Empty/blank|
|Metrics|❌ Not Working|All values = 0|

---

## 🤔 สาเหตุที่น่าจะเป็น (Root Cause Analysis)

### สมมติฐาน 1: Missing Trace Attributes

Application Signals ต้องการ attributes พิเศษ:

```javascript
{
  "aws.local.service": "frontend-api",
  "aws.local.operation": "GET /api/users",
  "aws.remote.service": "backend-api",      // อาจจะขาด
  "aws.remote.operation": "GET /api/data"   // อาจจะขาด
}
```

Auto-instrumentation อาจจะไม่ได้ส่ง `aws.remote.*` attributes

### สมมติฐาน 2: Region Limitation

ap-southeast-7 (Bangkok) เพิ่งเปิดให้บริการ Application Signals  
อาจจะมี bugs หรือ features ยังไม่ครบ

### สมมติฐาน 3: Add-on Configuration

CloudWatch Observability Add-on อาจจะต้องการ configuration เพิ่มเติมที่ documentation ไม่ได้บอก

### สมมติฐาน 4: Processing Delay

อาจจะต้องรอนานกว่า 10 นาที (บางทีถึง 30 นาที) แต่เราทดสอบหลายชั่วโมงแล้วก็ยังไม่มีข้อมูล

---

## 💡 บทเรียนที่ได้เรียนรู้

### 1. OpenTelemetry Auto-Instrumentation

**ข้อดี:**

- ไม่ต้องแก้โค้ดเลย
- แค่ใส่ `--require` flag และ environment variables

**ข้อเสีย:**

- อาจจะไม่ครบถ้วนสำหรับ AWS-specific attributes
- Debugging ยาก ไม่รู้ว่าส่งอะไรไปบ้าง

### 2. AWS Application Signals

**ข้อดี:**

- Integrated กับ CloudWatch (one-stop shop)
- Managed service ไม่ต้อง maintain infrastructure

**ข้อเสีย:**

- Documentation ไม่ชัดเจน
- Setup ซับซ้อน มีหลาย components
- Debugging ยากมาก ไม่มี error messages ที่ชัดเจน
- Region support ไม่เท่ากัน

### 3. Port Numbers Matter!

- CloudWatch Agent HTTP: **4316**
- CloudWatch Agent gRPC: **4315**
- ไม่ใช่ 4318 ตาม default ของ OpenTelemetry

### 4. Environment Variables ต้องครบ

```bash
OTEL_SERVICE_NAME          # ระบุชื่อ service
OTEL_EXPORTER_OTLP_ENDPOINT  # ระบุ collector endpoint
OTEL_TRACES_EXPORTER       # ระบุ exporter type (otlp)
```

ขาดตัวใดตัวหนึ่งก็ไม่ทำงาน

---

## 🔄 Actions Taken (สิ่งที่ทำทั้งหมด)

### Infrastructure

1. สร้าง EKS cluster ด้วย eksctl
2. สร้าง ECR repositories สำหรับ frontend และ backend
3. ตั้งค่า IAM roles และ policies

### Application Development

1. เขียน Node.js microservices (frontend + backend)
2. เพิ่ม OpenTelemetry dependencies
3. Config Dockerfile ด้วย auto-instrumentation
4. Build Docker images (linux/amd64)
5. Push ไป ECR

### Kubernetes Deployment

1. สร้าง Kubernetes manifests (Deployments, Services)
2. Deploy frontend-api (2 replicas)
3. Deploy backend-api (2 replicas)
4. สร้าง LoadBalancer service

### Observability Setup

1. ติดตั้ง CloudWatch Observability Add-on
2. ตั้งค่า environment variables สำหรับ OTLP
3. Restart deployments หลายรอบเพื่อแก้ไขปัญหา
4. ลบและติดตั้ง add-on ใหม่ (troubleshooting)

### Testing & Validation

1. ส่ง traffic ไป LoadBalancer (200+ requests)
2. ตรวจสอบ X-Ray traces ด้วย AWS CLI
3. ตรวจสอบ CloudWatch Metrics
4. ตรวจสอบ Application Signals Console
5. Debug ด้วย kubectl logs, describe, exec

---

## 💰 ค่าใช้จ่าย (ประมาณการ)

### EKS

- Control Plane: ~$73/month
- Worker Nodes (t3.small × 2): Free tier 750 hrs/month (first 12 months)

### CloudWatch

- X-Ray Traces: Free tier 100K traces/month (เราใช้ 62 traces)
- CloudWatch Logs: Free tier 5GB/month
- Application Signals: ไม่เสียเงินเพราะไม่มีข้อมูล 😅

### Network

- LoadBalancer: ~$20/month
- Data Transfer: น้อยมาก

**รวม:** ประมาณ $100/month (ถ้ารันต่อเนื่อง)

---

## 🎓 สรุปความรู้ที่ได้

### ✅ Technical Skills

1. Setup EKS cluster ด้วย eksctl
2. Deploy containerized applications บน Kubernetes
3. OpenTelemetry auto-instrumentation
4. AWS IAM roles และ policies สำหรับ EKS
5. ECR (Elastic Container Registry) usage
6. Kubernetes debugging (logs, describe, exec)

### ✅ Observability Concepts

1. Distributed Tracing architecture
2. OTLP (OpenTelemetry Protocol)
3. Service mesh observability
4. Trace attributes และ context propagation
5. APM metrics: Latency, Error rate, Throughput (RED metrics)

### ❌ Pain Points Discovered

1. AWS Application Signals ยังไม่ mature พอ
2. Documentation ขาดรายละเอียดสำคัญ
3. Debugging observability stack ยากมาก
4. Region availability แตกต่างกัน

## 📝 Recommendations

### สำหรับ Learning/Lab

- ✅ ใช้ AWS X-Ray traces ก็พอ (ได้แล้ว)
- ✅ ลอง Grafana + Tempo (free, ควบคุมเอง)
- ⚠️ Application Signals ยังไม่แนะนำ (ยังมี issues)

---

## 🧹 Cleanup Commands

```bash
# ลบ deployments
kubectl delete deployment frontend-api backend-api

# ลบ services
kubectl delete service frontend-service backend-service

# ลบ CloudWatch add-on
aws eks delete-addon \
  --cluster-name apm-lab-cluster \
  --addon-name amazon-cloudwatch-observability \
  --region ap-southeast-7

# ลบ EKS cluster
eksctl delete cluster \
  --name apm-lab-cluster \
  --region ap-southeast-7

# ลบ ECR repositories
aws ecr delete-repository \
  --repository-name apm-lab/frontend-api \
  --force \
  --region ap-southeast-7

aws ecr delete-repository \
  --repository-name apm-lab/backend-api \
  --force \
  --region ap-southeast-7
```

---

## 🎯 สรุปสุดท้าย

### ความสำเร็จ (70%)

- ✅ Infrastructure setup สมบูรณ์
- ✅ Applications ทำงานได้ดี
- ✅ OpenTelemetry instrumentation ถูกต้อง
- ✅ Traces ถูกส่งไป X-Ray สำเร็จ

### ไม่สำเร็จ (30%)

- ❌ Application Signals UI ไม่แสดงข้อมูล
- ❌ Service dependencies ไม่ปรากฏ
- ❌ Metrics ไม่ถูกสร้าง

---

**วันที่บันทึก:** 7 กุมภาพันธ์ 2026  