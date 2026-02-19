# Support & Maintenance

## Maintenance Schedule

### Daily Tasks

| Task | Method | Owner |
|------|--------|-------|
| Health check review | Prometheus/Grafana dashboard | Automated |
| Log rotation | logrotate | Automated |
| Backup verification | Backup monitoring script | Automated |
| Alert review | Email/Slack notifications | On-call |

### Weekly Tasks

| Task | Method | Owner |
|------|--------|-------|
| Security updates | `dnf update --security` | SysAdmin |
| Container updates | `docker compose pull` | SysAdmin |
| Performance review | Metrics dashboard | SysAdmin |
| Disk space check | Monitoring alerts | Automated |

### Monthly Tasks

| Task | Method | Owner |
|------|--------|-------|
| Model evaluation | User feedback + metrics | AI Team |
| Capacity planning | Usage trend analysis | SysAdmin |
| User feedback review | Survey/tickets | Product Owner |
| Documentation updates | Review and revise | SysAdmin |

### Quarterly Tasks

| Task | Method | Owner |
|------|--------|-------|
| Major version upgrades | Planned maintenance window | SysAdmin |
| Hardware health check | SMART data, temps, logs | SysAdmin |
| DR testing | Failover simulation | SysAdmin |
| Security audit | Vulnerability scan + review | Security Team |

---

## Monitoring Stack

### Prometheus Metrics

Key metrics to monitor:

| Metric | Alert Threshold |
|--------|-----------------|
| `vllm_requests_total` | N/A (informational) |
| `vllm_request_latency_seconds` | P95 > 10s |
| `nvidia_gpu_utilization` | > 95% sustained |
| `nvidia_gpu_temperature` | > 85°C |
| `node_memory_available_bytes` | < 10% |
| `node_disk_available_bytes` | < 20% |

### Grafana Dashboards

Recommended dashboards:

1. **System Overview** - CPU, memory, disk, network
2. **GPU Metrics** - Utilization, temperature, memory
3. **vLLM Performance** - Requests, latency, throughput
4. **User Activity** - Active users, queries per hour

### Alerting

| Severity | Response Time | Examples |
|----------|---------------|----------|
| **Critical** | 15 minutes | Service down, GPU failure |
| **Warning** | 4 hours | High latency, disk space low |
| **Info** | Next business day | Update available, usage spike |

---

## Backup Procedures

### What to Backup

| Component | Location | Frequency |
|-----------|----------|-----------|
| Open WebUI data | `/app/backend/data` | Daily |
| Docker volumes | `openwebui-data` | Daily |
| Configuration | `.env`, `docker-compose.yml` | On change |
| Model cache | `/models` (optional) | Weekly |

### Backup Script Example

```bash
#!/bin/bash
BACKUP_DIR="/backup/llm-stack"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

cd ~/llm-stack
docker compose down

tar -czf $BACKUP_DIR/openwebui-$DATE.tar.gz openwebui-data/
tar -czf $BACKUP_DIR/config-$DATE.tar.gz docker-compose.yml .env

docker compose up -d

# Keep only last 7 daily backups
find $BACKUP_DIR -name "openwebui-*.tar.gz" -mtime +7 -delete
```

### Recovery Procedure

```bash
# Stop services
docker compose down

# Restore data
tar -xzf /backup/openwebui-YYYYMMDD.tar.gz

# Restore configuration
tar -xzf /backup/config-YYYYMMDD.tar.gz

# Restart services
docker compose up -d
```

---

## Troubleshooting Guide

### Common Issues

#### Service Not Starting

```bash
# Check container status
docker compose ps

# View logs
docker compose logs vllm --tail=100
docker compose logs open-webui --tail=100

# Check system resources
free -h
df -h
nvidia-smi
```

#### Slow Response Times

1. Check GPU utilization: `nvidia-smi`
2. Review concurrent users in Open WebUI admin
3. Check for memory pressure: `free -h`
4. Review vLLM logs for queue depth

#### GPU Not Detected

```bash
# Verify driver
nvidia-smi

# Check container GPU access
docker run --rm --gpus all nvidia/cuda:12.1.0-base-ubuntu22.04 nvidia-smi

# Restart NVIDIA services
sudo systemctl restart nvidia-persistenced
```

#### Authentication Issues

```bash
# Test AD connectivity
realm list

# Check SSSD status
sudo systemctl status sssd

# Clear SSSD cache
sudo sss_cache -E
sudo systemctl restart sssd
```

---

## Update Procedures

### Container Updates

```bash
# Pull latest images
docker compose pull

# Recreate containers
docker compose up -d --force-recreate

# Verify health
docker compose ps
curl http://localhost:8000/health
```

### Model Updates

```bash
# Download new model
huggingface-cli download new-model-name

# Update docker-compose.yml with new model
# Restart vLLM container
docker compose up -d vllm
```

### OS Updates

```bash
# Security updates only
sudo dnf update --security -y

# Full update (schedule maintenance window)
sudo dnf update -y
sudo reboot
```

---

## Contact & Resources

### Getting Help

| Resource | Link |
|----------|------|
| GitHub Issues | [Project Issues](https://github.com/gblake55/On-Premise-LLM-Server-Installation/issues) |
| vLLM Documentation | [docs.vllm.ai](https://docs.vllm.ai/) |
| Open WebUI Documentation | [docs.openwebui.com](https://docs.openwebui.com/) |
| RHEL Documentation | [Red Hat Portal](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/10) |

### Community Resources

| Resource | Link |
|----------|------|
| vLLM Discord | [discord.gg/vllm](https://discord.gg/vllm) |
| Open WebUI Discord | [discord.gg/openwebui](https://discord.gg/openwebui) |
| r/LocalLLaMA | [reddit.com/r/LocalLLaMA](https://reddit.com/r/LocalLLaMA) |
