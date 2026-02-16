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
- [Step 8: Hugging Face CLI and Authentication](#step-9-hugging-face-cli-and-authentication)
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
8. **Hugging Face** → Model management

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
```
# Add current user to docker group
sudo usermod -aG docker $USER
```
```
# Apply group changes (requires logout/login or use newgrp)
newgrp docker
```
```
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
Docker version 29.2.1, build xxxxxxx
Docker Compose version v5.0.2 - or something laters
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



## Step 8: Hugging Face CLI and Authentication

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
please paste your hugging face login token to login.
go to huggingface.co and register and create a token for your computer.

```bash
hf auth login
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


### Configure Firewall

```bash
# Allow vLLM API port
sudo firewall-cmd --permanent --add-port=8000/tcp
sudo firewall-cmd --reload

# Verify
sudo firewall-cmd --list-ports
```


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
