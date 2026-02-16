# Install App Stack

Complete post-NVIDIA driver installation guide for setting up a production-ready LLM inference system on Red Hat Enterprise Linux 10.1.

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Installation Roadmap](#installation-roadmap)
- [Step 1: System Utilities and Tools](#step-1-system-utilities-and-tools)
- [Step 2: Version Control with Git](#step-2-version-control-with-git)
- [Step 3: Python Environment Manager (UV)](#step-3-python-environment-manager-uv)
- [Step 4: Python 3.13 Installation](#step-4-python-313-installation)
- [Step 5: Docker Installation](#step-5-docker-installation)
- [Step 6: NVIDIA Container Toolkit](#step-6-nvidia-container-toolkit)
- [Step 7: System Monitoring Tools](#step-7-system-monitoring-tools)
- [Step 8: vLLM Installation](#step-8-vllm-installation)
- [Step 9: Hugging Face CLI and Authentication](#step-9-hugging-face-cli-and-authentication)
- [Step 10: Test LLM Inference](#step-10-test-llm-inference)
- [Step 11: Production Configuration](#step-11-production-configuration)
- [Verification and Testing](#verification-and-testing)
- [Troubleshooting](#troubleshooting)
- [Performance Optimization](#performance-optimization)
- [Additional Resources](#additional-resources)

---

## Overview

This guide configures a RHEL 10.1 system for production LLM inference workloads. After completing these steps, your system will be ready to:

- Serve large language models with vLLM
- Run containerized AI workloads with GPU acceleration
- Monitor system and GPU performance in real-time
- Download and manage models from Hugging Face
- Handle multi-GPU inference efficiently

**Estimated Time:** 45-60 minutes  
**Difficulty:** Intermediate

---

## Prerequisites

✅ NVIDIA drivers successfully installed (from previous guide)  
✅ CUDA Toolkit installed and configured  
✅ Active Red Hat subscription  
✅ Root or sudo access  
✅ Internet connectivity  
✅ Minimum 100GB free disk space (for models and caches)

**Verify NVIDIA installation:**

```bash
nvidia-smi
nvcc --version
```

Both commands should execute successfully before proceeding.

---

## Installation Roadmap

The installation follows this specific order to ensure dependencies are met:

1. **System Utilities** → Basic command-line tools
2. **Git** → Version control for repositories
3. **UV** → Modern Python package manager
4. **Python 3.13** → Latest stable Python runtime
5. **Docker** → Container platform
6. **NVIDIA Container Toolkit** → GPU access for containers
7. **Monitoring Tools** → System and GPU monitoring
8. **vLLM** → LLM inference engine
9. **Hugging Face** → Model management
10. **Testing** → Validation and optimization

---

## Step 1: System Utilities and Tools

Install essential command-line utilities for system management and editing.

### Install Core Utilities

```bash
# Update system first
sudo dnf update -y

# Install essential utilities
sudo dnf install -y \
    wget \
    curl \
    vim \
    nano \
    htop \
    git \
    gcc \
    gcc-c++ \
    make \
    cmake \
    automake \
    autoconf \
    libtool \
    python3-devel \
    openssl-devel \
    bzip2-devel \
    libffi-devel \
    zlib-devel \
    readline-devel \
    sqlite-devel \
    ncurses-devel
```

### Verify Installation

```bash
# Check each utility
wget --version
curl --version
vim --version
nano --version
htop --version
```

---

## Step 2: Version Control with Git

Git is essential for cloning repositories and managing code.

### Configure Git

```bash
# Set up global git configuration
git config --global user.name "Your Name"
git config --global user.email "[email protected]"

# Verify configuration
git config --list
```

### Test Git

```bash
# Clone a test repository
git clone https://github.com/vllm-project/vllm.git /tmp/vllm-test
rm -rf /tmp/vllm-test
```

---

## Step 3: Python Environment Manager (UV)

UV is a blazing-fast Python package manager written in Rust, 10-100x faster than pip.

### Install UV

```bash
# Install UV using the standalone installer
curl -LsSf https://astral.sh/uv/install.sh | sh
```

### Configure UV

```bash
# Add UV to PATH (automatically done by installer)
# Reload shell configuration
source ~/.bashrc

# Verify installation
uv --version
```

**Expected output:**
```
uv 0.5.x (or later)
```

### Configure UV for System-Wide Use

```bash
# Enable shell completion for UV
echo 'eval "$(uv generate-shell-completion bash)"' >> ~/.bashrc
source ~/.bashrc
```

### UV Quick Reference

```bash
# Create virtual environment
uv venv myenv

# Activate environment
source myenv/bin/activate

# Install package
uv pip install package-name

# Install from requirements.txt
uv pip install -r requirements.txt

# List installed packages
uv pip list
```

---

## Step 4: Python 3.13 Installation

Python 3.13 provides performance improvements and is recommended for vLLM.

### Install Python 3.13 with UV

```bash
# Install Python 3.13
uv python install 3.13

# Verify installation
uv python list

# Set Python 3.13 as default for projects
uv python pin 3.13
```

### Verify Python Installation

```bash
# Check Python version
python3.13 --version

# Check pip
python3.13 -m pip --version
```

**Expected output:**
```
Python 3.13.x
pip 24.x from /path/to/python3.13/site-packages/pip (python 3.13)
```

### Create System-Wide Python 3.13 Alias

```bash
# Add alias to bashrc
echo 'alias python=python3.13' >> ~/.bashrc
echo 'alias python3=python3.13' >> ~/.bashrc
source ~/.bashrc

# Verify
python --version
```

---

## Step 5: Docker Installation

Docker is required for containerized LLM deployments and provides isolation for different models.

### Add Docker Repository

```bash
# Add Docker CE repository
sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
```

### Install Docker

```bash
# Install Docker CE and related packages
sudo dnf install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin
```

### Configure Docker Service

```bash
# Start Docker service
sudo systemctl start docker

# Enable Docker to start on boot
sudo systemctl enable docker

# Verify Docker is running
sudo systemctl status docker
```
### if docker errors... try this....
```
sudo firewall-cmd --get-zone-of-interface=docker0
```
Remove docker0 from trusted zone
```
sudo firewall-cmd --permanent --zone=trusted --remove-interface=docker0
```
Reload firewalld
```
sudo firewall-cmd --reload
```
Restart Docker
```
sudo systemctl restart docker
sudo systemctl status docker
```

### Add User to Docker Group

**Important:** This allows running Docker without sudo.

# Add current user to docker group
sudo usermod -aG docker $USER

# Apply group changes (requires logout/login or use newgrp)
newgrp docker

# Verify
groups
```

You should see `docker` in the list of groups.

### Test Docker Installation

```bash
# Run hello-world container
docker run hello-world

# Check Docker version
docker --version
docker compose version
```

**Expected output:**
```
Docker version 27.x.x, build xxxxxxx
Docker Compose version v2.x.x
```

### Configure Docker for Production

Create daemon configuration for optimal performance:

```bash
sudo nano /etc/docker/daemon.json
```

**Add the following configuration:**

```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "storage-driver": "overlay2",
  "default-runtime": "nvidia"
}
```

**Restart Docker:**

```bash
sudo systemctl restart docker
```

---

## Step 6: NVIDIA Container Toolkit

The NVIDIA Container Toolkit enables Docker containers to access GPUs.

### Add NVIDIA Container Toolkit Repository

```bash
# Configure the repository
curl -s -L https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo | \
sudo tee /etc/yum.repos.d/nvidia-container-toolkit.repo
```

### Install NVIDIA Container Toolkit

```bash
# Clean DNF cache
sudo dnf clean all

# Install the toolkit
sudo dnf install -y nvidia-container-toolkit
```

### Configure Docker to Use NVIDIA Runtime

```bash
# Configure the container runtime
sudo nvidia-ctk runtime configure --runtime=docker

# Restart Docker to apply changes
sudo systemctl restart docker
```

### Verify NVIDIA Docker Integration

```bash
# Test GPU access in container
docker run --rm --gpus all nvidia/cuda:12.1.0-base-ubuntu22.04 nvidia-smi
```

**Expected output:** You should see the nvidia-smi output from within the container showing your GPUs.

### Advanced GPU Configuration

**Specify specific GPUs:**

```bash
# Use GPU 0 only
docker run --rm --gpus '"device=0"' nvidia/cuda:12.1.0-base-ubuntu22.04 nvidia-smi

# Use GPUs 0 and 1
docker run --rm --gpus '"device=0,1"' nvidia/cuda:12.1.0-base-ubuntu22.04 nvidia-smi
```

---

## Step 7: System Monitoring Tools

Install advanced monitoring tools for system and GPU performance tracking.

### Install nvitop (NVIDIA GPU Monitor)

```bash
# Create virtual environment for monitoring tools
uv venv ~/.venv/monitoring
source ~/.venv/monitoring/bin/activate

# Install nvitop
uv pip install nvitop

# Deactivate and create wrapper
deactivate

# Create system-wide nvitop command
sudo bash -c 'cat > /usr/local/bin/nvitop << "EOF"
#!/bin/bash
source ~/.venv/monitoring/bin/activate
nvitop "$@"
deactivate
EOF'

sudo chmod +x /usr/local/bin/nvitop
```

**Test nvitop:**

```bash
nvitop
```

Press `q` to exit.

### Install btop (Advanced System Monitor)

```bash
# Install btop from EPEL or build from source
# For RHEL 10, compile from source for latest version

# Install build dependencies
sudo dnf install -y coreutils sed git

# Clone btop repository
cd /tmp
git clone https://github.com/aristocratos/btop.git
cd btop

# Build and install
make
sudo make install

# Verify
btop --version
```

**Test btop:**

```bash
btop
```

Press `q` to exit.

### Configure htop

htop should already be installed from Step 1. Configure it for better display:

```bash
# Run htop
htop
```

Press `F2` for setup, customize as needed, then `F10` to save and exit.

### Create Monitoring Aliases

```bash
# Add useful aliases to bashrc
cat >> ~/.bashrc << 'EOF'

# Monitoring aliases
alias gpu='watch -n 1 nvidia-smi'
alias gpumon='nvitop'
alias sysmon='btop'
alias temp='nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader'
alias gpumem='nvidia-smi --query-gpu=memory.used,memory.total --format=csv,noheader'
alias gpuutil='nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader'
EOF

source ~/.bashrc
```

---

## Step 8: vLLM Installation

vLLM is a high-performance LLM inference engine optimized for throughput and memory efficiency.

### Create vLLM Virtual Environment

```bash
# Create dedicated environment for vLLM
uv venv ~/.venv/vllm --python 3.13
source ~/.venv/vllm/bin/activate
```

### Install PyTorch with CUDA Support

```bash
# Install PyTorch 2.6.0 with CUDA 12.1 support
uv pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
```

### Verify PyTorch CUDA Access

```bash
python -c "import torch; print(f'PyTorch version: {torch.__version__}'); print(f'CUDA available: {torch.cuda.is_available()}'); print(f'CUDA version: {torch.version.cuda}'); print(f'GPU count: {torch.cuda.device_count()}')"
```

**Expected output:**
```
PyTorch version: 2.6.0+cu121
CUDA available: True
CUDA version: 12.1
GPU count: 2 (or your GPU count)
```

### Install vLLM

```bash
# Install latest stable vLLM
uv pip install vllm

# Or install specific version
# uv pip install vllm==0.15.1
```

### Verify vLLM Installation

```bash
# Check vLLM version
python -c "import vllm; print(f'vLLM version: {vllm.__version__}')"

# Quick test with a small model (will download ~500MB)
python -c "
from vllm import LLM
llm = LLM(model='facebook/opt-125m')
output = llm.generate('Hello, my name is')
print(output[0].outputs[0].text)
"
```

### Create vLLM System Command

```bash
# Deactivate environment
deactivate

# Create wrapper script for vLLM
sudo bash -c 'cat > /usr/local/bin/vllm << "EOF"
#!/bin/bash
source ~/.venv/vllm/bin/activate
python -m vllm.entrypoints.openai.api_server "$@"
deactivate
EOF'

sudo chmod +x /usr/local/bin/vllm
```

### vLLM Quick Start Examples

**Offline Inference:**

```bash
# Activate vLLM environment
source ~/.venv/vllm/bin/activate

# Create test script
cat > /tmp/vllm_test.py << 'EOF'
from vllm import LLM, SamplingParams

# Initialize model
llm = LLM(model="facebook/opt-125m")

# Create prompts
prompts = [
    "Hello, my name is",
    "The future of AI is",
]

# Configure sampling parameters
sampling_params = SamplingParams(temperature=0.8, top_p=0.95)

# Generate
outputs = llm.generate(prompts, sampling_params)

# Print results
for output in outputs:
    prompt = output.prompt
    generated_text = output.outputs[0].text
    print(f"Prompt: {prompt!r}, Generated: {generated_text!r}")
EOF

# Run test
python /tmp/vllm_test.py
```

**Online Serving (OpenAI-compatible API):**

```bash
# Start vLLM server with small model
vllm serve facebook/opt-125m --port 8000

# In another terminal, test the API
curl http://localhost:8000/v1/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "facebook/opt-125m",
    "prompt": "San Francisco is a",
    "max_tokens": 50,
    "temperature": 0.7
  }'
```

---

## Step 9: Hugging Face CLI and Authentication

Hugging Face Hub hosts thousands of pre-trained models. Authentication is required for gated models.

### Install Hugging Face Hub

```bash
# Activate vLLM environment (or use UV directly)
source ~/.venv/vllm/bin/activate

# Install huggingface-hub CLI
uv pip install -U "huggingface_hub[cli]"
```

### Authenticate with Hugging Face

**Option 1: Interactive Login**

```bash
huggingface-cli login
```

You'll be prompted to enter your Hugging Face token. Get your token from:  
https://huggingface.co/settings/tokens

**Option 2: Environment Variable**

```bash
# Add to ~/.bashrc for persistence
echo 'export HF_TOKEN="your_token_here"' >> ~/.bashrc
source ~/.bashrc
```

**Option 3: Token File**

```bash
# Create token file
mkdir -p ~/.cache/huggingface
echo "your_token_here" > ~/.cache/huggingface/token
chmod 600 ~/.cache/huggingface/token
```

### Verify Authentication

```bash
huggingface-cli whoami
```

**Expected output:**
```
username: your-username
orgs: []
```

### Download Models with Hugging Face CLI

```bash
# Download a model
huggingface-cli download meta-llama/Llama-3.2-1B

# Download to specific directory
huggingface-cli download meta-llama/Llama-3.2-1B --local-dir ./models/llama-3.2-1b

# List downloaded models
ls -lh ~/.cache/huggingface/hub/
```

### Hugging Face Cache Management

```bash
# Check cache size
huggingface-cli scan-cache

# Delete unused models
huggingface-cli delete-cache

# Set custom cache directory
export HF_HOME=/data/huggingface_cache
```

Add to `~/.bashrc` for persistence:

```bash
echo 'export HF_HOME=/data/huggingface_cache' >> ~/.bashrc
source ~/.bashrc
```

---

## Step 10: Test LLM Inference

Comprehensive testing of the LLM inference setup.

### Test 1: Single GPU Inference

```bash
source ~/.venv/vllm/bin/activate

# Test with small model
python << 'EOF'
from vllm import LLM, SamplingParams

llm = LLM(
    model="facebook/opt-125m",
    tensor_parallel_size=1,  # Single GPU
    gpu_memory_utilization=0.8
)

prompts = ["Explain quantum computing in simple terms:"]
sampling_params = SamplingParams(temperature=0.7, max_tokens=100)

outputs = llm.generate(prompts, sampling_params)
for output in outputs:
    print(f"\n{output.outputs[0].text}")
EOF
```

### Test 2: Multi-GPU Inference (Tensor Parallelism)

```bash
# Test with 2 GPUs (adjust based on your setup)
python << 'EOF'
from vllm import LLM, SamplingParams

llm = LLM(
    model="facebook/opt-1.3b",
    tensor_parallel_size=2,  # Use 2 GPUs
    gpu_memory_utilization=0.8
)

prompts = ["Write a short story about AI:"]
sampling_params = SamplingParams(temperature=0.7, max_tokens=200)

outputs = llm.generate(prompts, sampling_params)
for output in outputs:
    print(f"\n{output.outputs[0].text}")
EOF
```

### Test 3: Docker GPU Inference

```bash
# Pull vLLM Docker image
docker pull vllm/vllm-openai:latest

# Run vLLM in container with GPU
docker run --gpus all \
    -v ~/.cache/huggingface:/root/.cache/huggingface \
    -p 8000:8000 \
    --ipc=host \
    vllm/vllm-openai:latest \
    --model facebook/opt-125m
```

**Test the API:**

```bash
# In another terminal
curl http://localhost:8000/v1/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "facebook/opt-125m",
    "prompt": "The meaning of life is",
    "max_tokens": 50
  }'
```

### Test 4: Monitor GPU Usage During Inference

**Terminal 1 - Run inference:**

```bash
source ~/.venv/vllm/bin/activate
python -c "from vllm import LLM; llm = LLM('facebook/opt-1.3b'); llm.generate(['test'] * 100)"
```

**Terminal 2 - Monitor GPUs:**

```bash
nvitop
# or
watch -n 1 nvidia-smi
```

---

## Step 11: Production Configuration

Configure the system for production LLM serving.

### Create vLLM Service (systemd)

```bash
# Create service file
sudo nano /etc/systemd/system/vllm.service
```

**Add the following content:**

```ini
[Unit]
Description=vLLM OpenAI-Compatible Server
After=network.target

[Service]
Type=simple
User=your-username
Group=your-username
WorkingDirectory=/home/your-username
Environment="PATH=/home/your-username/.venv/vllm/bin:/usr/local/bin:/usr/bin"
Environment="CUDA_VISIBLE_DEVICES=0,1"
Environment="HF_HOME=/data/huggingface_cache"
ExecStart=/home/your-username/.venv/vllm/bin/python -m vllm.entrypoints.openai.api_server \
    --model meta-llama/Llama-3.2-1B \
    --tensor-parallel-size 2 \
    --gpu-memory-utilization 0.9 \
    --port 8000 \
    --host 0.0.0.0
Restart=on-failure
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```

**Replace `your-username` with your actual username.**

**Enable and start the service:**

```bash
sudo systemctl daemon-reload
sudo systemctl enable vllm.service
sudo systemctl start vllm.service

# Check status
sudo systemctl status vllm.service

# View logs
sudo journalctl -u vllm.service -f
```

### Configure Firewall

```bash
# Allow vLLM API port
sudo firewall-cmd --permanent --add-port=8000/tcp
sudo firewall-cmd --reload

# Verify
sudo firewall-cmd --list-ports
```

### Create Model Management Scripts

**Download script:**

```bash
sudo nano /usr/local/bin/download-model
```

**Add content:**

```bash
#!/bin/bash
# Model download script

MODEL_ID="$1"
CACHE_DIR="${HF_HOME:-~/.cache/huggingface}"

if [ -z "$MODEL_ID" ]; then
    echo "Usage: download-model <model_id>"
    echo "Example: download-model meta-llama/Llama-3.2-1B"
    exit 1
fi

echo "Downloading $MODEL_ID to $CACHE_DIR..."
source ~/.venv/vllm/bin/activate
huggingface-cli download "$MODEL_ID"
deactivate
echo "Download complete!"
```

**Make executable:**

```bash
sudo chmod +x /usr/local/bin/download-model
```

**Usage:**

```bash
download-model meta-llama/Llama-3.2-1B
```

### Performance Tuning

**Create sysctl tuning file:**

```bash
sudo nano /etc/sysctl.d/99-llm-performance.conf
```

**Add content:**

```ini
# Network performance
net.core.rmem_max = 134217728
net.core.wmem_max = 134217728
net.ipv4.tcp_rmem = 4096 87380 67108864
net.ipv4.tcp_wmem = 4096 65536 67108864

# File descriptors
fs.file-max = 2097152

# Shared memory
kernel.shmmax = 68719476736
kernel.shmall = 16777216
```

**Apply settings:**

```bash
sudo sysctl -p /etc/sysctl.d/99-llm-performance.conf
```

---

## Verification and Testing

### Complete System Check

Run this comprehensive verification script:

```bash
cat > /tmp/system_check.sh << 'EOF'
#!/bin/bash

echo "=== LLM Inference System Verification ==="
echo ""

echo "1. NVIDIA Drivers:"
nvidia-smi --query-gpu=name,driver_version,memory.total --format=csv,noheader
echo ""

echo "2. CUDA:"
nvcc --version | grep "release"
echo ""

echo "3. Docker:"
docker --version
docker run --rm --gpus all nvidia/cuda:12.1.0-base-ubuntu22.04 nvidia-smi > /dev/null 2>&1 && echo "✓ Docker GPU access working" || echo "✗ Docker GPU access failed"
echo ""

echo "4. Python:"
python --version
echo ""

echo "5. UV:"
uv --version
echo ""

echo "6. vLLM:"
source ~/.venv/vllm/bin/activate
python -c "import vllm; print(f'vLLM version: {vllm.__version__}')" 2>/dev/null && echo "✓ vLLM installed" || echo "✗ vLLM not found"
python -c "import torch; print(f'PyTorch CUDA: {torch.cuda.is_available()}')" 2>/dev/null
deactivate
echo ""

echo "7. Hugging Face:"
source ~/.venv/vllm/bin/activate
huggingface-cli whoami 2>/dev/null && echo "✓ Authenticated" || echo "✗ Not authenticated"
deactivate
echo ""

echo "8. Monitoring Tools:"
which nvitop > /dev/null && echo "✓ nvitop installed" || echo "✗ nvitop not found"
which btop > /dev/null && echo "✓ btop installed" || echo "✗ btop not found"
which htop > /dev/null && echo "✓ htop installed" || echo "✗ htop not found"
echo ""

echo "=== Verification Complete ==="
EOF

chmod +x /tmp/system_check.sh
/tmp/system_check.sh
```

---

## Troubleshooting

### Common Issues and Solutions

#### Issue: vLLM CUDA Out of Memory

**Solution:**

```bash
# Reduce GPU memory utilization
python -c "
from vllm import LLM
llm = LLM(model='your-model', gpu_memory_utilization=0.7)  # Reduce from 0.9
"

# Or use tensor parallelism to split across GPUs
python -c "
from vllm import LLM
llm = LLM(model='your-model', tensor_parallel_size=2)
"
```

#### Issue: Docker Permission Denied

**Solution:**

```bash
# Re-add user to docker group
sudo usermod -aG docker $USER
newgrp docker

# Or logout and login again
```

#### Issue: Hugging Face Download Slow

**Solution:**

```bash
# Use mirror or CDN
export HF_ENDPOINT=https://hf-mirror.com
huggingface-cli download model-name

# Or use aria2c for faster downloads
pip install huggingface_hub[hf_transfer]
export HF_HUB_ENABLE_HF_TRANSFER=1
```

#### Issue: Model Loading Fails

**Solution:**

```bash
# Check model exists
huggingface-cli scan-cache

# Clear cache and re-download
rm -rf ~/.cache/huggingface/hub/models--*
huggingface-cli download model-name
```

---

## Performance Optimization

### GPU Optimization

**Enable persistence mode:**

```bash
sudo nvidia-smi -pm 1
```

**Set GPU clocks for maximum performance:**

```bash
sudo nvidia-smi -lgc 1950  # Adjust based on your GPU
```

**Monitor GPU performance:**

```bash
nvidia-smi dmon -s pucvmet -d 1
```

### vLLM Performance Tuning

**Optimize for throughput:**

```python
from vllm import LLM

llm = LLM(
    model="model-name",
    tensor_parallel_size=2,
    gpu_memory_utilization=0.95,
    max_num_batched_tokens=8192,
    max_num_seqs=256,
    enforce_eager=False,  # Use CUDA graphs
)
```

**Optimize for latency:**

```python
from vllm import LLM

llm = LLM(
    model="model-name",
    tensor_parallel_size=1,
    gpu_memory_utilization=0.8,
    max_num_batched_tokens=2048,
    max_num_seqs=128,
)
```

### System Resource Limits

```bash
# Increase file descriptors
echo "* soft nofile 65536" | sudo tee -a /etc/security/limits.conf
echo "* hard nofile 65536" | sudo tee -a /etc/security/limits.conf

# Increase user processes
echo "* soft nproc 65536" | sudo tee -a /etc/security/limits.conf
echo "* hard nproc 65536" | sudo tee -a /etc/security/limits.conf
```

---

## Additional Resources

### Official Documentation

- [vLLM Documentation](https://docs.vllm.ai/)
- [Hugging Face Hub Documentation](https://huggingface.co/docs/hub/index)
- [NVIDIA Container Toolkit Documentation](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/index.html)
- [UV Documentation](https://docs.astral.sh/uv/)
- [Docker Documentation](https://docs.docker.com/)

### Community Resources

- [vLLM GitHub](https://github.com/vllm-project/vllm)
- [vLLM Discord](https://discord.gg/vllm)
- [Hugging Face Forums](https://discuss.huggingface.co/)

### Performance Benchmarks

- [vLLM Performance Benchmarks](https://vllm.ai/blog/benchmark)
- [Multi-GPU Scaling Guide](https://docs.vllm.ai/en/latest/serving/distributed_serving.html)

### Model Resources

- [Hugging Face Model Hub](https://huggingface.co/models)
- [vLLM Supported Models](https://docs.vllm.ai/en/latest/models/supported_models.html)
- [LLM Leaderboard](https://huggingface.co/spaces/lmsys/chatbot-arena-leaderboard)

---

## Quick Command Reference

```bash
# Monitoring
gpu                    # Watch nvidia-smi
gpumon                # nvitop
sysmon                # btop
temp                  # GPU temperatures
gpumem                # GPU memory usage

# vLLM
source ~/.venv/vllm/bin/activate          # Activate vLLM environment
vllm serve model-name                     # Start vLLM server
systemctl status vllm                     # Check vLLM service

# Hugging Face
huggingface-cli whoami                    # Check auth status
huggingface-cli download model-id         # Download model
huggingface-cli scan-cache                # Check cache
download-model model-id                   # Custom download script

# Docker
docker ps                                 # List running containers
docker images                             # List images
docker run --gpus all ...                 # Run with GPU
docker logs container-name                # View logs

# UV
uv venv env-name                          # Create environment
uv pip install package                    # Install package
uv pip list                               # List packages
uv python list                            # List Python versions
```

---

**Configuration Complete!** 🎉

Your RHEL 10.1 system is now fully configured for production LLM inference workloads.

**Next recommended steps:**
1. Download your production models using `download-model`
2. Configure the vLLM service with your preferred model
3. Set up monitoring dashboards
4. Test performance with your expected workload
5. Configure backup and model versioning

---

**Last Updated:** February 2026  
**System:** RHEL 10.1  
**Target Use Case:** LLM Inference with Multi-GPU Support
