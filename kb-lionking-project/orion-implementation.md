## **Tags**

  #orion #monitoring #epl #drm #axinom #key-service #proxy
## **Overview**
Orion is used for **continuous source monitoring** of EPL content.
During discussions with **JAS** and **Orion**(meeting at 2026-01-22), it was identified that Orion cannot integrate directly with **Axinom DRM License Service** due to the high volume of monitoring requests, which could cause excessive license attempts.
To address this, Orion will integrate with the **Axinom DRM Key Service** instead, using a custom-built **proxy service** as an intermediary.
### **Current Limitation**
  **Date Updated:** 2026-01-22
- Orion performs monitoring **continuously**
- If Orion requests DRM licenses directly:
    - License request attempts would be extremely high
    - Risk of:
        - System impact
        - Quota exhaustion
        - Unnecessary license usage
- Orion architecture is designed to:
    - Request **DRM keys**, not playback licenses
### **Proposed Architecture**
**Orion → Proxy Service → Axinom DRM Key Service**
### **Proxy Development**
- **Owner:** Team Khun Kla & P’New (JAS)
- **Timeline:** **26–30 Jan 2026**
- **Deliverables:**
    - Working proxy service
    - Endpoint and integration specification shared with Orion team
### **Orion Integration Timeline**
- **Total duration:** **3–4 weeks**
    - **Week 1–2:** Integration and functional validation
    - **Week 3–4:** UI implementation within Orion application
---
