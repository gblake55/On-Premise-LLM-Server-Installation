# IDA — Intelligent Document Assistant

## Enterprise-Grade On-Premise LLM Inference Platform

**Production-Proven AI Infrastructure Serving 500+ Employees**

![RHEL](https://img.shields.io/badge/RHEL-10.1-EE0000?logo=redhat)
![NVIDIA](https://img.shields.io/badge/NVIDIA-RTX_3090_|_5090-76B900?logo=nvidia)
![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?logo=docker)
![vLLM](https://img.shields.io/badge/vLLM-Inference_Engine-FF6B6B)

**128GB GPU Memory | 24-Core EPYC | 256GB RAM | Private & Secure**

---

## About IDA

**IDA (Intelligent Document Assistant)** is a production-grade, on-premise large language model inference platform deployed at a state housing agency, serving 500+ employees across multiple departments. Built on enterprise-grade hardware and open-source software, IDA provides ChatGPT-like capabilities while maintaining complete data privacy and security within the corporate network.

### Key Highlights

| | |
|---|---|
| **Production Deployment** | Running 24/7 in enterprise environment since Q4 2025 |
| **Active Users** | 500+ employees across IT, Sales, Legal, and Operations |
| **Primary Model** | Mistral-Large-2411 (14B) — Advanced reasoning and instruction-following |
| **Complete Privacy** | 100% on-premise, zero data leaves corporate network |
| **High Performance** | Sub-2-second response times, 95th percentile < 5 seconds |
| **Cost Effective** | $8,000 hardware investment vs $100,000+ annual SaaS costs |
| **Self-Hosted** | Full control over updates, models, and configurations |

### Use Cases in Production

| Department | Use Case | Daily Queries |
|------------|----------|---------------|
| **Engineering** | Code review, documentation, debugging | ~800 |
| **Operations** | Proposal generation, email drafting | ~500 |
| **Finance and HR** | Contract analysis, policy drafting | ~200 |
| **Homeownership** | Report summarization, data analysis | ~300 |
| **Marketing** | Content creation, campaign ideas | ~400 |

**Total Daily Interactions**: ~2,200 queries
**Monthly Token Processing**: ~150M tokens
**Availability**: 99.8% uptime (excluding planned maintenance)

---

## Documentation

Full deployment documentation is available at the project site:

**[View Documentation](https://gblake55.github.io/On-Premise-LLM-Server-Installation/)**

### Deployment Guide

| Step | Phase | Time | Difficulty |
|------|-------|------|------------|
| 1 | [Hardware Procurement & Assembly](docs/guide/step1-hardware.md) | 1-2 weeks | Advanced |
| 2 | [RHEL 10.1 Installation](docs/guide/step2-rhel.md) | 2-3 hours | Intermediate |
| 3 | [NVIDIA Driver Installation](docs/guide/step3-nvidia.md) | 1-2 hours | Intermediate |
| 4 | [Software Stack Deployment](docs/guide/step4-apps.md) | 1 hour | Intermediate |
| 5 | [Open WebUI & vLLM Deployment](docs/guide/step5-webui.md) | 30 minutes | Beginner |
| 6 | [Active Directory Integration](docs/guide/step6-ad.md) | 1 hour | Intermediate |

**Total Project Timeline**: 2-3 weeks (including shipping)
**Total Hands-On Time**: ~8-12 hours
**Total Investment**: $7,000 - $9,000 (used components)

---

## System Architecture

```
+-----------------------------------------------------+
|                   Corporate Network                 |
|                    (Isolated VLAN)                  |
+---------------------------+-------------------------+
                            |
              +-------------v-------------+
              |     Active Directory      |
              |       (domain.org)        |
              +-------------+-------------+
                            |
              +-------------v-------------+
              |    Load Balancer/NGINX    |
              |    SSL/TLS Termination    |
              +-------------+-------------+
                            |
              +-------------v-------------+
              |       Open WebUI          |
              |    (Docker Container)     |
              |    - User Sessions        |
              |    - Chat History         |
              |    - RAG Engine           |
              +-------------+-------------+
                            |
                            | OpenAI-Compatible API
                            |
              +-------------v-------------+
              |          vLLM             |
              |    (Docker Container)     |
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

### Technology Stack

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

## Cost Analysis

### Initial Investment

| Category | Cost |
|----------|------|
| Hardware (used components) | $8,000 |
| RHEL License | $350 |
| Software | $0 (open-source) |
| **Total** | **$8,350** |

### Monthly Operating Costs

| Category | Cost |
|----------|------|
| Electricity (~2.4 kW) | $85 |
| Cooling | $30 |
| Maintenance | $50 |
| **Total** | **$165/month** |

### ROI vs Commercial APIs

| Provider | Monthly Cost (55M tokens) | Annual Cost |
|----------|---------------------------|-------------|
| **IDA (Self-Hosted)** | $165 | $1,980 |
| OpenAI GPT-4 | ~$4,000 | ~$48,000 |
| Anthropic Claude | ~$5,000 | ~$60,000 |

**Payback Period**: ~2.5 months
**Annual Savings**: $40,000 - $58,000

---

## License

This project is provided as-is for educational and informational purposes.

### Third-Party Licenses

- **vLLM**: Apache 2.0 License
- **Open WebUI**: MIT License
- **Docker**: Apache 2.0 License
- **RHEL**: Red Hat Developer Subscription

---

## Author

**Greg Blake**
Chief Information Officer | Vice President of Administration

---

**Last Updated**: February 2026
