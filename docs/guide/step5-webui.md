# Step 3: Docker Deployment - Open WebUI with vLLM

Complete guide for deploying Open WebUI and vLLM in containerized environments using Docker Compose. This setup provides a ChatGPT-like web interface powered by your local GPU-accelerated LLM inference engine.

---

## Overview

This deployment combines two powerful components:

- **vLLM**: High-performance LLM inference engine with OpenAI-compatible API
- **Open WebUI**: Modern, ChatGPT-like web interface for interacting with language models

### Key Benefits

- GPU-accelerated inference with vLLM
- User-friendly ChatGPT-like interface
- Completely private and self-hosted
- Containerized for easy deployment and portability
- Support for multiple models and users
- Persistent storage for conversations and settings

### Use Cases

- Development and testing of LLM applications
- Private AI assistant for teams
- Research and experimentation with open-source models
- Production LLM serving with web UI

---

## Architecture

```
+-----------------------------------------------------+
|                    User Browser                     |
|               http://localhost:3000                 |
+-------------------------+---------------------------+
                          |
                          | Port 3000
                          |
+-------------------------v---------------------------+
|               Open WebUI Container                  |
|          (ghcr.io/open-webui/open-webui)            |
|                                                     |
|    - Web Interface                                  |
|    - User Management                                |
|    - Conversation History                           |
|    - Document Upload & RAG                          |
+-------------------------+---------------------------+
                          |
                          | Internal Network
                          | http://vllm:8000/v1
                          |
+-------------------------v---------------------------+
|                  vLLM Container                     |
|               (vllm/vllm-openai)                    |
|                                                     |
|    - LLM Inference Engine                           |
|    - OpenAI-Compatible API                          |
|    - GPU Acceleration                               |
|    - Model Loading & Caching                        |
+-------------------------+---------------------------+
                          |
                          | GPU Access
                          |
+-------------------------v---------------------------+
|                   NVIDIA GPU(s)                     |
|            (RTX 3090, RTX 5090, etc.)               |
+-----------------------------------------------------+
```

---

## Prerequisites

Before proceeding, ensure you have completed:

✅ **Step 1**: NVIDIA drivers and CUDA toolkit installed  
✅ **Step 2**: Docker, NVIDIA Container Toolkit, and supporting tools installed  
✅ Minimum 16GB RAM (32GB+ recommended)  
✅ Sufficient disk space (100GB+ for models and data)  
✅ At least one NVIDIA GPU with 12GB+ VRAM

**Verify prerequisites:**

```bash
# Check Docker
docker --version
docker compose version

# Check NVIDIA Docker support
docker run --rm --gpus all nvidia/cuda:12.1.0-base-ubuntu22.04 nvidia-smi

# Check available disk space
df -h /var/lib/docker
```

---

## Directory Structure

Create a dedicated project directory for your deployment:

```bash
mkdir -p ~/llm-stack
cd ~/llm-stack
```

**Recommended structure:**

```
llm-stack/
├── docker-compose.yml          # Main compose file
├── .env                        # Environment variables
├── models/                     # Hugging Face model cache
│   └── models--meta-llama--Llama-3.2-1B/
├── openwebui-data/            # Open WebUI persistent data
│   ├── uploads/
│   ├── cache/
│   └── vector_db/
├── nginx/                      # NGINX config (optional)
│   ├── nginx.conf
│   └── certs/
│       ├── server.crt
│       └── server.key
└── logs/                       # Application logs
    ├── vllm.log
    └── openwebui.log
```

**Create directories:**

```bash
cd ~/llm-stack
mkdir -p models openwebui-data nginx/certs logs
```

---

## Configuration Files

### Docker Compose File

Create the main `docker-compose.yml` file:

```bash
nano docker-compose.yml
```

**Basic Configuration (Single GPU):**

```yaml
version: '3.8'

services:
  # vLLM Inference Engine
  vllm:
    image: vllm/vllm-openai:latest
    container_name: vllm-server
    runtime: nvidia
    environment:
      - NVIDIA_VISIBLE_DEVICES=all
      - HF_HOME=/models
      - HF_TOKEN=${HF_TOKEN}
    volumes:
      - ./models:/models:rw
      - ./logs:/logs:rw
    ports:
      - "8000:8000"
    command:
      - --model
      - meta-llama/Llama-3.2-1B-Instruct
      - --host
      - "0.0.0.0"
      - --port
      - "8000"
      - --gpu-memory-utilization
      - "0.9"
      - --max-model-len
      - "4096"
      - --dtype
      - auto
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all
              capabilities: [gpu]
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 5
      start_period: 300s
    restart: unless-stopped
    networks:
      - llm-network

  # Open WebUI Frontend
  open-webui:
    image: ghcr.io/open-webui/open-webui:main
    container_name: open-webui
    depends_on:
      vllm:
        condition: service_healthy
    environment:
      - OPENAI_API_BASE_URL=http://vllm:8000/v1
      - OPENAI_API_KEY=sk-dummy-key
      - WEBUI_SECRET_KEY=${WEBUI_SECRET_KEY}
      - WEBUI_NAME=LLM Inference Platform
      - ENABLE_SIGNUP=${ENABLE_SIGNUP:-true}
      - DEFAULT_USER_ROLE=user
      - ENABLE_OLLAMA_API=false
      - ENABLE_OPENAI_API=true
    volumes:
      - ./openwebui-data:/app/backend/data:rw
    ports:
      - "3000:8080"
    restart: unless-stopped
    networks:
      - llm-network

networks:
  llm-network:
    driver: bridge

volumes:
  models:
  openwebui-data:
```

### Environment Variables

Create a `.env` file for sensitive configuration:

```bash
nano .env
```

**Add the following content:**

```bash
# Hugging Face Token (required for gated models like Llama)
# Get your token from https://huggingface.co/settings/tokens
HF_TOKEN=hf_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

# Open WebUI Secret Key (generate with: openssl rand -hex 32)
WEBUI_SECRET_KEY=your-secret-key-here-generate-with-openssl

# User Registration
ENABLE_SIGNUP=true

# Optional: OpenAI API Key (if using external models)
OPENAI_API_KEY=

# Optional: Custom model path
MODEL_NAME=meta-llama/Llama-3.2-1B-Instruct

# GPU Configuration
CUDA_VISIBLE_DEVICES=0,1
```

**Generate a secure secret key:**

```bash
openssl rand -hex 32 >> .env
```

**Secure the .env file:**

```bash
chmod 600 .env
```

---

## Deployment Options

### Option 1: Basic Deployment

**Best for:** Single GPU systems, development, testing

**Features:**
- Single vLLM instance
- One model loaded at a time
- Simple configuration

**docker-compose.yml** (see Basic Configuration above)

**Deploy:**

```bash
cd ~/llm-stack
docker compose up -d
```

### Option 2: Multi-GPU Deployment

**Best for:** Systems with multiple GPUs, higher throughput requirements

**Features:**
- Tensor parallelism across GPUs
- Higher throughput
- Larger model support

**docker-compose-multi-gpu.yml:**

```yaml
version: '3.8'

services:
  vllm:
    image: vllm/vllm-openai:latest
    container_name: vllm-server
    runtime: nvidia
    environment:
      - NVIDIA_VISIBLE_DEVICES=0,1  # Use GPU 0 and 1
      - HF_HOME=/models
      - HF_TOKEN=${HF_TOKEN}
    volumes:
      - ./models:/models:rw
      - ./logs:/logs:rw
    ports:
      - "8000:8000"
    command:
      - --model
      - meta-llama/Llama-3.2-3B-Instruct
      - --host
      - "0.0.0.0"
      - --port
      - "8000"
      - --tensor-parallel-size
      - "2"  # Use 2 GPUs
      - --gpu-memory-utilization
      - "0.95"
      - --max-model-len
      - "8192"
      - --dtype
      - auto
      - --enforce-eager  # Disable CUDA graphs for stability
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              device_ids: ['0', '1']
              capabilities: [gpu]
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 5
      start_period: 600s  # Longer startup for larger models
    restart: unless-stopped
    networks:
      - llm-network

  open-webui:
    image: ghcr.io/open-webui/open-webui:main
    container_name: open-webui
    depends_on:
      vllm:
        condition: service_healthy
    environment:
      - OPENAI_API_BASE_URL=http://vllm:8000/v1
      - OPENAI_API_KEY=sk-dummy-key
      - WEBUI_SECRET_KEY=${WEBUI_SECRET_KEY}
      - WEBUI_NAME=Multi-GPU LLM Platform
      - ENABLE_SIGNUP=${ENABLE_SIGNUP:-false}
      - DEFAULT_USER_ROLE=user
      - ENABLE_OLLAMA_API=false
      - ENABLE_OPENAI_API=true
    volumes:
      - ./openwebui-data:/app/backend/data:rw
    ports:
      - "3000:8080"
    restart: unless-stopped
    networks:
      - llm-network

networks:
  llm-network:
    driver: bridge
```

**Deploy:**

```bash
docker compose -f docker-compose-multi-gpu.yml up -d
```

### Option 3: Production Deployment with NGINX

**Best for:** Production environments, SSL/TLS requirements, multiple domains

**Features:**
- NGINX reverse proxy
- SSL/TLS termination
- Load balancing ready
- Enhanced security

**Create NGINX configuration:**

```bash
nano nginx/nginx.conf
```

**Add content:**

```nginx
events {
    worker_connections 1024;
}

http {
    upstream open-webui {
        server open-webui:8080;
    }

    upstream vllm-api {
        server vllm:8000;
    }

    # HTTP to HTTPS redirect
    server {
        listen 80;
        server_name your-domain.com;
        return 301 https://$server_name$request_uri;
    }

    # HTTPS server for Open WebUI
    server {
        listen 443 ssl http2;
        server_name your-domain.com;

        ssl_certificate /etc/nginx/certs/server.crt;
        ssl_certificate_key /etc/nginx/certs/server.key;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers HIGH:!aNULL:!MD5;

        client_max_body_size 100M;

        location / {
            proxy_pass http://open-webui;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            # WebSocket support
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
        }

        # Optional: Direct API access
        location /api/ {
            proxy_pass http://vllm-api/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }
    }
}
```

**Generate self-signed SSL certificate (for testing):**

```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout nginx/certs/server.key \
  -out nginx/certs/server.crt \
  -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"
```

**docker-compose-nginx.yml:**

```yaml
version: '3.8'

services:
  vllm:
    image: vllm/vllm-openai:latest
    container_name: vllm-server
    runtime: nvidia
    environment:
      - NVIDIA_VISIBLE_DEVICES=all
      - HF_HOME=/models
      - HF_TOKEN=${HF_TOKEN}
    volumes:
      - ./models:/models:rw
    # No port exposure - accessed through NGINX
    command:
      - --model
      - meta-llama/Llama-3.2-1B-Instruct
      - --host
      - "0.0.0.0"
      - --port
      - "8000"
      - --gpu-memory-utilization
      - "0.9"
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all
              capabilities: [gpu]
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 5
      start_period: 300s
    restart: unless-stopped
    networks:
      - llm-network

  open-webui:
    image: ghcr.io/open-webui/open-webui:main
    container_name: open-webui
    depends_on:
      vllm:
        condition: service_healthy
    environment:
      - OPENAI_API_BASE_URL=http://vllm:8000/v1
      - OPENAI_API_KEY=sk-dummy-key
      - WEBUI_SECRET_KEY=${WEBUI_SECRET_KEY}
      - WEBUI_NAME=Production LLM Platform
      - ENABLE_SIGNUP=false
      - DEFAULT_USER_ROLE=pending
    volumes:
      - ./openwebui-data:/app/backend/data:rw
    # No port exposure - accessed through NGINX
    restart: unless-stopped
    networks:
      - llm-network

  nginx:
    image: nginx:alpine
    container_name: nginx-proxy
    depends_on:
      - open-webui
      - vllm
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./nginx/certs:/etc/nginx/certs:ro
    ports:
      - "80:80"
      - "443:443"
    restart: unless-stopped
    networks:
      - llm-network

networks:
  llm-network:
    driver: bridge
```

**Deploy:**

```bash
docker compose -f docker-compose-nginx.yml up -d
```

---

## Step-by-Step Deployment

### Step 1: Prepare Environment

```bash
# Navigate to project directory
cd ~/llm-stack

# Ensure Docker is running
sudo systemctl status docker

# Verify GPU access
nvidia-smi

# Check Docker GPU support
docker run --rm --gpus all nvidia/cuda:12.1.0-base-ubuntu22.04 nvidia-smi
```

### Step 2: Download Model (Optional but Recommended)

Pre-downloading models prevents long startup times and provides better visibility.

```bash
# Activate your vLLM environment (if using local installation)
source ~/.venv/vllm/bin/activate

# Download model to local cache
huggingface-cli download meta-llama/Llama-3.2-1B-Instruct --local-dir ./models/llama-3.2-1b

# Or let Docker handle it automatically on first start
```

### Step 3: Configure Environment

```bash
# Create .env file
nano .env

# Add your HF token and generate secret key
# See Environment Variables section above
```

### Step 4: Create Docker Compose File

```bash
# Create docker-compose.yml
nano docker-compose.yml

# Copy the appropriate configuration from above
```

### Step 5: Start Services

```bash
# Pull images (optional, will happen automatically)
docker compose pull

# Start services in background
docker compose up -d

# Watch logs
docker compose logs -f
```

**Expected startup sequence:**

1. vLLM container starts and loads the model (2-5 minutes)
2. Health check passes once model is loaded
3. Open WebUI starts and connects to vLLM
4. Services are ready for use

### Step 6: Verify Deployment

```bash
# Check container status
docker compose ps

# Should show:
# NAME                IMAGE                              STATUS
# vllm-server         vllm/vllm-openai:latest           Up (healthy)
# open-webui          ghcr.io/open-webui/open-webui     Up

# Test vLLM API directly
curl http://localhost:8000/v1/models

# Check Open WebUI
curl http://localhost:3000
```

### Step 7: Create First User

1. Open browser and navigate to `http://localhost:3000`
2. Click "Sign Up" (if `ENABLE_SIGNUP=true`)
3. Enter email and password
4. First user becomes admin automatically

---

## Model Management

### Changing Models

**Option 1: Edit docker-compose.yml**

```bash
# Stop services
docker compose down

# Edit docker-compose.yml
nano docker-compose.yml

# Change the --model parameter under vllm service
# Example: meta-llama/Llama-3.2-3B-Instruct

# Restart services
docker compose up -d
```

**Option 2: Environment Variable**

```bash
# In .env file
MODEL_NAME=meta-llama/Llama-3.2-3B-Instruct

# In docker-compose.yml, use:
command:
  - --model
  - ${MODEL_NAME}
```

### Loading Multiple Models

To serve multiple models simultaneously, create multiple vLLM containers:

```yaml
services:
  vllm-small:
    image: vllm/vllm-openai:latest
    container_name: vllm-small
    environment:
      - CUDA_VISIBLE_DEVICES=0
    command:
      - --model
      - meta-llama/Llama-3.2-1B-Instruct
      - --port
      - "8000"
    ports:
      - "8000:8000"

  vllm-large:
    image: vllm/vllm-openai:latest
    container_name: vllm-large
    environment:
      - CUDA_VISIBLE_DEVICES=1
    command:
      - --model
      - meta-llama/Llama-3.2-3B-Instruct
      - --port
      - "8001"
    ports:
      - "8001:8001"
```

Configure Open WebUI to use multiple endpoints in Admin Panel > Settings > Connections.

### Supported Models

vLLM supports many model architectures. Popular choices:

**Small Models (< 8GB VRAM):**
- meta-llama/Llama-3.2-1B-Instruct
- meta-llama/Llama-3.2-3B-Instruct
- Qwen/Qwen2.5-3B-Instruct
- microsoft/phi-3-mini-4k-instruct

**Medium Models (12-24GB VRAM):**
- meta-llama/Llama-3.1-8B-Instruct
- mistralai/Mistral-7B-Instruct-v0.3
- Qwen/Qwen2.5-7B-Instruct

**Large Models (24GB+ VRAM or Multi-GPU):**
- meta-llama/Llama-3.1-70B-Instruct (requires multi-GPU)
- mistralai/Mixtral-8x7B-Instruct-v0.1

Check [vLLM supported models](https://docs.vllm.ai/en/latest/models/supported_models.html) for full list.

---

## Accessing the Interface

### Web Interface

**URL:** `http://localhost:3000`

**First Login:**
1. Navigate to `http://localhost:3000`
2. Sign up with email and password (first user is admin)
3. Select model from dropdown (should auto-detect vLLM model)
4. Start chatting!

### API Access

**OpenAI-Compatible API:**

```bash
# List models
curl http://localhost:8000/v1/models

# Chat completion
curl http://localhost:8000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "meta-llama/Llama-3.2-1B-Instruct",
    "messages": [
      {"role": "user", "content": "Hello, how are you?"}
    ],
    "max_tokens": 100
  }'
```

**Python Example:**

```python
import openai

client = openai.OpenAI(
    base_url="http://localhost:8000/v1",
    api_key="dummy-key"
)

response = client.chat.completions.create(
    model="meta-llama/Llama-3.2-1B-Instruct",
    messages=[
        {"role": "user", "content": "Explain quantum computing"}
    ]
)

print(response.choices[0].message.content)
```

---

## Configuration and Customization

### Open WebUI Settings

Access via: Admin Panel (top right) > Settings

**Key Settings:**

1. **General**
   - Interface language
   - Default model
   - Message retention

2. **Connections**
   - Add/remove API endpoints
   - Configure API keys
   - Test connections

3. **Users**
   - User management
   - Role assignments
   - Access control

4. **Models**
   - Model selection
   - Default parameters
   - Temperature, top_p, etc.

### vLLM Performance Tuning

**Memory Optimization:**

```yaml
command:
  - --model
  - your-model
  - --gpu-memory-utilization
  - "0.95"  # Use up to 95% of GPU memory
  - --swap-space
  - "4"     # 4GB CPU swap space
```

**Throughput Optimization:**

```yaml
command:
  - --model
  - your-model
  - --max-num-batched-tokens
  - "8192"   # Larger batch processing
  - --max-num-seqs
  - "256"    # More concurrent sequences
```

**Latency Optimization:**

```yaml
command:
  - --model
  - your-model
  - --disable-log-requests  # Reduce logging overhead
  - --enforce-eager         # Disable CUDA graphs for lower latency
```

### Advanced Open WebUI Configuration

**Environment Variables:**

```yaml
environment:
  # Authentication
  - ENABLE_SIGNUP=false
  - DEFAULT_USER_ROLE=pending
  - WEBUI_AUTH=true
  
  # Features
  - ENABLE_RAG_WEB_SEARCH=true
  - ENABLE_IMAGE_GENERATION=false
  - ENABLE_COMMUNITY_SHARING=false
  
  # Uploads
  - UPLOAD_ENABLED=true
  - FILE_SIZE_LIMIT=100
  
  # Database
  - DATABASE_URL=sqlite:////app/backend/data/webui.db
```

---

## Monitoring and Maintenance

### View Logs

```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f vllm
docker compose logs -f open-webui

# Last 100 lines
docker compose logs --tail=100 vllm
```

### Monitor GPU Usage

```bash
# Real-time GPU monitoring
watch -n 1 nvidia-smi

# Or use nvitop (if installed)
nvitop
```

### Container Resource Usage

```bash
# View resource usage
docker stats

# Specific container
docker stats vllm-server open-webui
```

### Health Checks

```bash
# Check vLLM health
curl http://localhost:8000/health

# Check Open WebUI
curl http://localhost:3000/api/health

# Check container health status
docker inspect vllm-server | grep -A 10 Health
```

### Update Containers

```bash
# Pull latest images
docker compose pull

# Recreate containers with new images
docker compose up -d --force-recreate

# Or do it in one step
docker compose pull && docker compose up -d --force-recreate
```

---

## Troubleshooting

### Issue: vLLM Container Fails to Start

**Symptoms:**
- Container exits immediately
- "CUDA out of memory" errors
- Model loading failures

**Solutions:**

```bash
# Check logs
docker compose logs vllm

# Reduce GPU memory utilization
# In docker-compose.yml:
command:
  - --gpu-memory-utilization
  - "0.8"  # Reduce from 0.9

# Try smaller model
command:
  - --model
  - meta-llama/Llama-3.2-1B-Instruct  # Instead of larger model

# Clear cache and restart
docker compose down
rm -rf models/*
docker compose up -d
```

### Issue: Open WebUI Cannot Connect to vLLM

**Symptoms:**
- "Connection refused" errors
- No models shown in Open WebUI
- API calls fail

**Solutions:**

```bash
# Check if vLLM is healthy
docker compose ps

# Verify network connectivity
docker exec -it open-webui curl http://vllm:8000/health

# Check environment variable
docker exec -it open-webui env | grep OPENAI_API_BASE_URL

# Should be: http://vllm:8000/v1 (not http://localhost:8000/v1)

# Restart services
docker compose restart
```

### Issue: Slow Model Loading

**Symptoms:**
- vLLM takes 10+ minutes to start
- Health check times out

**Solutions:**

```bash
# Pre-download models
huggingface-cli download meta-llama/Llama-3.2-1B-Instruct --local-dir ./models/llama-3.2-1b

# Increase health check start period
# In docker-compose.yml:
healthcheck:
  start_period: 600s  # 10 minutes instead of 5

# Use faster storage for model cache
# Mount SSD instead of HDD for ./models
```

### Issue: Permission Denied Errors

**Symptoms:**
- "Permission denied" when writing to volumes
- Container cannot create files

**Solutions:**

```bash
# Fix ownership
sudo chown -R $USER:$USER ./models ./openwebui-data

# Or run containers with user
# In docker-compose.yml:
services:
  vllm:
    user: "${UID}:${GID}"

# Set UID and GID in .env:
UID=1000
GID=1000
```

### Issue: Out of Disk Space

**Symptoms:**
- "No space left on device"
- Model downloads fail

**Solutions:**

```bash
# Check disk usage
df -h
docker system df

# Clean up unused Docker resources
docker system prune -a --volumes

# Remove old model files
rm -rf models/models--old-model-name

# Move models to larger disk
sudo systemctl stop docker
sudo mv /var/lib/docker /data/docker
sudo ln -s /data/docker /var/lib/docker
sudo systemctl start docker
```

---

## Performance Optimization

### GPU Optimization

**Enable Persistence Mode:**

```bash
sudo nvidia-smi -pm 1
```

**Set Power Limit (optional):**

```bash
# Set to maximum performance
sudo nvidia-smi -pl 350  # Adjust based on your GPU
```

### vLLM Optimization

**For Maximum Throughput:**

```yaml
command:
  - --model
  - your-model
  - --tensor-parallel-size
  - "2"  # Multi-GPU
  - --gpu-memory-utilization
  - "0.95"
  - --max-num-batched-tokens
  - "16384"
  - --max-num-seqs
  - "512"
```

**For Minimum Latency:**

```yaml
command:
  - --model
  - your-model
  - --gpu-memory-utilization
  - "0.8"
  - --max-num-batched-tokens
  - "2048"
  - --max-num-seqs
  - "64"
  - --enforce-eager
```

### Docker Optimization

**Increase shared memory:**

```yaml
services:
  vllm:
    shm_size: '8gb'  # Or use ipc: host
```

**Resource limits:**

```yaml
services:
  vllm:
    deploy:
      resources:
        limits:
          memory: 32g
        reservations:
          memory: 16g
```

---

## Security Considerations

### Network Security

**1. Restrict Public Access:**

```yaml
# Bind only to localhost
ports:
  - "127.0.0.1:3000:8080"  # Not accessible from network
```

**2. Use NGINX with Authentication:**

```nginx
location / {
    auth_basic "Restricted Access";
    auth_basic_user_file /etc/nginx/.htpasswd;
    proxy_pass http://open-webui;
}
```

**3. Enable Firewall:**

```bash
# Allow only from specific IP
sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="192.168.1.0/24" port protocol="tcp" port="3000" accept'
sudo firewall-cmd --reload
```

### Application Security

**1. Disable Public Signup:**

```yaml
environment:
  - ENABLE_SIGNUP=false
```

**2. Use Strong Secret Key:**

```bash
# Generate strong key
openssl rand -hex 32
```

**3. Set Default User Role to Pending:**

```yaml
environment:
  - DEFAULT_USER_ROLE=pending
```

**4. Regular Updates:**

```bash
# Update monthly
docker compose pull
docker compose up -d --force-recreate
```

---

## Backup and Recovery

### Backup Procedure

**1. Backup Open WebUI Data:**

```bash
# Stop services
docker compose down

# Backup data directory
tar -czf openwebui-backup-$(date +%Y%m%d).tar.gz openwebui-data/

# Backup .env
cp .env .env.backup

# Restart services
docker compose up -d
```

**2. Backup Models (Optional):**

```bash
# Models are cached and can be re-downloaded
# But for air-gapped systems:
tar -czf models-backup-$(date +%Y%m%d).tar.gz models/
```

**3. Automated Backup Script:**

```bash
#!/bin/bash
# backup.sh

BACKUP_DIR="/backup/llm-stack"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

cd ~/llm-stack
docker compose down

tar -czf $BACKUP_DIR/openwebui-$DATE.tar.gz openwebui-data/
tar -czf $BACKUP_DIR/config-$DATE.tar.gz docker-compose.yml .env

docker compose up -d

# Keep only last 7 backups
find $BACKUP_DIR -name "openwebui-*.tar.gz" -mtime +7 -delete
```

### Recovery Procedure

**1. Restore from Backup:**

```bash
# Stop services
docker compose down

# Restore data
tar -xzf openwebui-backup-20260214.tar.gz

# Restore configuration
tar -xzf config-backup-20260214.tar.gz

# Restart services
docker compose up -d
```

**2. Disaster Recovery:**

```bash
# Fresh start with backed up data
cd ~/llm-stack-new
cp /backup/.env .
cp /backup/docker-compose.yml .
tar -xzf /backup/openwebui-backup-latest.tar.gz
docker compose up -d
```

---

## Additional Resources

### Official Documentation

- [vLLM Documentation](https://docs.vllm.ai/)
- [Open WebUI Documentation](https://docs.openwebui.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/)

### Community Resources

- [vLLM GitHub](https://github.com/vllm-project/vllm)
- [Open WebUI GitHub](https://github.com/open-webui/open-webui)
- [vLLM Discord](https://discord.gg/vllm)
- [Open WebUI Discord](https://discord.gg/openwebui)

### Example Configurations

- [vLLM + Open WebUI Examples](https://github.com/marib00/vllm-openwebui-nginx-compose)
- [Production Docker Compose](https://github.com/open-webui/open-webui/tree/main/docker-compose)

### Model Resources

- [Hugging Face Model Hub](https://huggingface.co/models)
- [vLLM Supported Models](https://docs.vllm.ai/en/latest/models/supported_models.html)
- [LLM Leaderboard](https://huggingface.co/spaces/lmsys/chatbot-arena-leaderboard)

---

## Quick Command Reference

```bash
# Deployment
docker compose up -d                    # Start services
docker compose down                     # Stop services
docker compose restart                  # Restart services
docker compose pull                     # Update images

# Monitoring
docker compose logs -f                  # View logs
docker compose ps                       # Service status
docker stats                           # Resource usage
nvidia-smi                             # GPU status

# Maintenance
docker compose exec vllm bash          # Enter vLLM container
docker compose exec open-webui sh      # Enter Open WebUI container
docker system prune -a                 # Clean up Docker

# Troubleshooting
docker compose logs vllm --tail=100    # Last 100 vLLM logs
curl http://localhost:8000/health      # Check vLLM health
curl http://localhost:3000             # Check Open WebUI
```

---

**Deployment Complete!**

Your containerized LLM inference platform is now ready. Access Open WebUI at `http://localhost:3000` and start chatting with your local AI models.

**Next Steps:**
1. Create your first user account
2. Download additional models
3. Configure user preferences
4. Set up backups
5. Explore RAG features and document uploads

---

**Last Updated:** February 2026  
**System:** RHEL 10.1  
**Components:** vLLM + Open WebUI + Docker Compose
