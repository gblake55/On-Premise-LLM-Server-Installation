# System Architecture

## Overview

IDA is deployed as a containerized application stack within an isolated corporate network VLAN, with Active Directory integration for enterprise authentication.

## Architecture Diagram

```
+-----------------------------------------------------+
|                   Corporate Network                 |
|                    (Isolated VLAN)                  |
+---------------------------+-------------------------+
                            |
              +-------------v-------------+
              |     Active Directory      |
              |       (domain.org)        |
              |      Authentication       |
              +-------------+-------------+
                            |
              +-------------v-------------+
              |   Load Balancer (HAProxy) |
              |    SSL/TLS Termination    |
              +-------------+-------------+
                            |
         +------------------+------------------+
         |                  |                  |
    +----v-----+       +----v-----+       +----v-----+
    |  NGINX   |       |  NGINX   |       |  NGINX   |
    |  Proxy   |       |  Proxy   |       |  Proxy   |
    +----+-----+       +----+-----+       +----+-----+
         |                  |                  |
         +------------------+------------------+
                            |
              +-------------v-------------+
              |       Open WebUI          |
              |    (Docker Container)     |
              |                           |
              |    - User Sessions        |
              |    - Chat History         |
              |    - RAG Engine           |
              +-------------+-------------+
                            |
                            | OpenAI-Compatible API
                            | http://vllm:8000/v1
                            |
              +-------------v-------------+
              |          vLLM             |
              |    (Docker Container)     |
              |                           |
              |    - Model Loading        |
              |    - Inference            |
              |    - GPU Scheduling       |
              +-------------+-------------+
                            |
        +-------------------+-------------------+
        |                   |                   |
   +----v----+         +----v----+         +----v----+
   |RTX 3090 |         |RTX 3090 |         |RTX 5090 |
   | 24GB    |         | 24GB    |         | 32GB    |
   +---------+         +---------+         +---------+
   |RTX 3090 |         |RTX 3090 |
   | 24GB    |         | 24GB    |
   +---------+         +---------+

              Total GPU Memory: 128GB

+-----------------------------------------------------+
|           AMD EPYC 7443P (24C/48T)                  |
|           256GB DDR4 ECC RAM                        |
|           4TB NVMe Gen4 Storage                     |
+-----------------------------------------------------+
```

---

## Technology Stack

| Layer | Technology | Purpose |
|-------|------------|---------|
| **OS** | RHEL 10.1 | Enterprise Linux foundation |
| **Compute** | AMD EPYC 7443P | 24-core CPU, 128 PCIe lanes |
| **GPU** | 4x RTX 3090 + 1x RTX 5090 | 128GB total GPU memory |
| **Inference** | vLLM 0.15.1+ | High-throughput LLM serving |
| **Frontend** | Open WebUI | ChatGPT-like user interface |
| **Container** | Docker + Compose | Containerized deployment |
| **Auth** | Active Directory | Enterprise SSO integration |
| **Networking** | NGINX + HAProxy | Load balancing and SSL |
| **Storage** | 4TB NVMe Gen4 | Model cache and data |
| **Model** | Mistral-Large-2411 | 14B parameter reasoning model |

---

## Network Configuration

### VLAN Isolation

- Dedicated VLAN for LLM infrastructure
- Strict ingress/egress filtering
- No direct public internet access

### SSL/TLS Configuration

- TLS 1.3 for all connections
- Internal CA with automatic renewal
- End-to-end encryption

### Firewall Rules

| Port | Service | Direction |
|------|---------|-----------|
| 443 | HTTPS (Web UI) | Inbound |
| 8000 | vLLM API (internal) | Internal only |
| 389/636 | LDAP/LDAPS (AD) | Outbound |
| 88 | Kerberos (AD) | Outbound |

---

## Container Architecture

### Open WebUI Container

- **Image**: `ghcr.io/open-webui/open-webui:main`
- **Persistent Storage**: User data, conversations, uploads
- **Configuration**: Environment variables for API endpoints

### vLLM Container

- **Image**: `vllm/vllm-openai:latest`
- **GPU Access**: NVIDIA Container Toolkit
- **Model Cache**: Mounted volume for Hugging Face cache

### Container Networking

- Internal Docker bridge network
- Service discovery via container names
- No exposed ports except through NGINX

---

## High Availability Considerations

### Current Setup (Single Node)

- Single server deployment
- 99.8% uptime achieved
- Manual failover procedures

### Future HA Options

- Multiple vLLM instances with load balancing
- Shared model storage (NFS/Ceph)
- Database replication for Open WebUI
- Automated health checks and failover
