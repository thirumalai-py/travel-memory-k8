
| Feature            | Layer 4 LB                                         | Layer 7 LB                                                      |
| ------------------ | -------------------------------------------------- | --------------------------------------------------------------- |
| OSI Layer          | 4 (Transport)                                      | 7 (Application)                                                 |
| Protocol           | TCP/UDP                                            | HTTP/HTTPS/WebSocket/gRPC                                       |
| Smart Routing      | ❌ No                                               | ✅ Yes (path, header, cookie, host-based, version-based)         |
| SSL Termination    | ❌ No (pass-through or TCP offload)                 | ✅ Yes (TLS termination, HTTPS offload)                          |
| Performance        | 🚀 Very fast                                       | 🚀 Fast but with more processing (due to app layer inspection)  |
| Health Checks      | Basic (TCP/UDP level: port open/close)             | Advanced (HTTP status codes, content match, custom checks)      |
| Connection Type    | Layer 4 connection: IP address + Port              | Layer 7 connection: URL path + Hostname + Headers               |
| Example AWS        | Network Load Balancer (NLB), Classic Load Balancer | Application Load Balancer (ALB), API Gateway                    |
| Example Azure      | Azure Load Balancer (Public/Private)               | Azure Application Gateway, Azure Front Door                     |
| Example GCP        | Network Load Balancer                              | HTTP(S) Load Balancer, GCP API Gateway                          |
| Example IBM Cloud  | IBM Cloud Network Load Balancer                    | IBM Cloud Application Load Balancer                             |
| Example Alibaba    | Alibaba Cloud SLB (TCP/UDP listeners)              | Alibaba Cloud SLB (HTTP/HTTPS listeners)                        |
| Example Kubernetes | Service of type LoadBalancer (L4) → NLB / Azure LB | Kubernetes Ingress Controller (L7) → NGINX Ingress, Traefik     |
| Example Software   | HAProxy (TCP mode), F5 BIG-IP LTM (L4), LVS        | HAProxy (HTTP mode), NGINX, Envoy Proxy, Traefik, Istio Ingress |
| Cost               | Lower (simple traffic forwarding)                  | Higher (more CPU/RAM needed for inspection & smart routing)     |
| Observability      | Basic (connection metrics)                         | Detailed (URL, status codes, response times, request tracing)   |

---

### Notes:

✅ In **Kubernetes** → Layer 4 LB = `Service type LoadBalancer`
✅ Layer 7 LB = `Ingress Controller` (Traefik, NGINX, Istio, Ambassador, Envoy, HAProxy, etc.)

✅ In **AWS**:

* NLB → Layer 4
* ALB → Layer 7
* Classic LB → Hybrid (supports both, but old → use ALB/NLB instead)

✅ In **Azure**:

* Azure Load Balancer → Layer 4
* Azure Application Gateway → Layer 7
* Azure Front Door → Global Layer 7 LB + CDN + WAF → can work with Application Gateway

✅ In **GCP**:

* Network LB → Layer 4
* HTTP(S) LB → Global Layer 7 LB (very powerful and global)

---

### Summary:

👉 **Layer 4 LB** → Simple, fast, IP-based, good for non-HTTP apps (databases, games, raw TCP/UDP).
👉 **Layer 7 LB** → Smart, app-aware, used in modern web apps, APIs, microservices, Kubernetes Ingress.

---

