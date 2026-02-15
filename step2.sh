#!/bin/bash

################################################################################
# RHEL 10.1 LLM Inference System Setup Script
# 
# This script automates the installation and configuration of:
# - System utilities (wget, curl, vim, nano, htop, etc.)
# - Git version control
# - UV Python package manager
# - Python 3.13
# - Docker and Docker Compose
# - NVIDIA Container Toolkit
# - Monitoring tools (nvitop, btop)
# - vLLM inference engine
# - Hugging Face CLI
#
# Prerequisites:
# - NVIDIA drivers and CUDA toolkit already installed
# - Active Red Hat subscription
# - Root or sudo access
# - Internet connectivity
#
# Usage: sudo bash step2.sh
################################################################################

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Log functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   log_error "This script must be run as root (use sudo)"
   exit 1
fi

# Get the actual user who ran sudo
ACTUAL_USER="${SUDO_USER:-$USER}"
ACTUAL_HOME=$(eval echo ~$ACTUAL_USER)

log_info "Script will configure system for user: $ACTUAL_USER"
log_info "User home directory: $ACTUAL_HOME"

################################################################################
# Step 0: Pre-flight Checks
################################################################################

log_info "========================================="
log_info "Step 0: Pre-flight Checks"
log_info "========================================="

# Check NVIDIA drivers
if ! command -v nvidia-smi &> /dev/null; then
    log_error "NVIDIA drivers not found. Please install NVIDIA drivers first."
    exit 1
fi

log_success "NVIDIA drivers found: $(nvidia-smi --query-gpu=driver_version --format=csv,noheader | head -1)"

# Check CUDA
if ! command -v nvcc &> /dev/null; then
    log_warning "CUDA compiler (nvcc) not found in PATH. CUDA may not be properly configured."
else
    log_success "CUDA found: $(nvcc --version | grep release | awk '{print $5}' | sed 's/,//')"
fi

# Check Red Hat subscription
if ! subscription-manager status &> /dev/null; then
    log_warning "Red Hat subscription may not be active"
else
    log_success "Red Hat subscription is active"
fi

sleep 2

################################################################################
# Step 1: System Update and Core Utilities
################################################################################

log_info "========================================="
log_info "Step 1: System Update and Core Utilities"
log_info "========================================="

log_info "Updating system packages..."
dnf update -y

log_info "Installing core utilities..."
dnf install -y \
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
    ncurses-devel \
    tar \
    gzip \
    bzip2 \
    unzip

log_success "Core utilities installed"

################################################################################
# Step 2: Git Configuration
################################################################################

log_info "========================================="
log_info "Step 2: Git Configuration"
log_info "========================================="

# Configure git for the actual user
sudo -u $ACTUAL_USER git config --global user.name "RHEL LLM System" 2>/dev/null || true
sudo -u $ACTUAL_USER git config --global user.email "admin@localhost" 2>/dev/null || true

log_success "Git configured (user can update name/email later with: git config --global user.name 'Your Name')"

################################################################################
# Step 3: Install UV (Python Package Manager)
################################################################################

log_info "========================================="
log_info "Step 3: Installing UV Package Manager"
log_info "========================================="

# Install UV as the actual user
sudo -u $ACTUAL_USER bash -c 'curl -LsSf https://astral.sh/uv/install.sh | sh'

# Add UV to PATH in bashrc if not already present
if ! grep -q 'uv' "$ACTUAL_HOME/.bashrc"; then
    sudo -u $ACTUAL_USER bash -c 'echo "" >> ~/.bashrc'
    sudo -u $ACTUAL_USER bash -c 'echo "# UV Python package manager" >> ~/.bashrc'
    sudo -u $ACTUAL_USER bash -c 'echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> ~/.bashrc'
fi

# Source the UV installation for current script
export PATH="$ACTUAL_HOME/.local/bin:$PATH"

# Verify UV installation
if sudo -u $ACTUAL_USER bash -c 'source ~/.bashrc && uv --version' &> /dev/null; then
    log_success "UV installed: $(sudo -u $ACTUAL_USER bash -c 'source ~/.bashrc && uv --version')"
else
    log_error "UV installation failed"
    exit 1
fi

################################################################################
# Step 4: Install Python 3.13
################################################################################

log_info "========================================="
log_info "Step 4: Installing Python 3.13"
log_info "========================================="

# Install Python 3.13 using UV as the actual user
sudo -u $ACTUAL_USER bash -c "source ~/.bashrc && uv python install 3.13"

log_success "Python 3.13 installed"

# Set Python 3.13 as default for projects
sudo -u $ACTUAL_USER bash -c "source ~/.bashrc && cd $ACTUAL_HOME && uv python pin 3.13" || true

# Add Python aliases to bashrc
if ! grep -q 'alias python=' "$ACTUAL_HOME/.bashrc"; then
    sudo -u $ACTUAL_USER bash -c 'echo "" >> ~/.bashrc'
    sudo -u $ACTUAL_USER bash -c 'echo "# Python aliases" >> ~/.bashrc'
    sudo -u $ACTUAL_USER bash -c 'echo "alias python=python3.13" >> ~/.bashrc'
    sudo -u $ACTUAL_USER bash -c 'echo "alias python3=python3.13" >> ~/.bashrc'
fi

log_success "Python 3.13 configured with aliases"

################################################################################
# Step 5: Install Docker
################################################################################

log_info "========================================="
log_info "Step 5: Installing Docker"
log_info "========================================="

# Add Docker repository
log_info "Adding Docker CE repository..."
dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo

# Install Docker
log_info "Installing Docker packages..."
dnf install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

# Start and enable Docker
log_info "Starting Docker service..."
systemctl start docker
systemctl enable docker

# Add user to docker group
log_info "Adding $ACTUAL_USER to docker group..."
usermod -aG docker $ACTUAL_USER

# Configure Docker daemon
log_info "Configuring Docker daemon..."
cat > /etc/docker/daemon.json <<EOF
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "storage-driver": "overlay2",
  "default-runtime": "nvidia"
}
EOF

# Restart Docker to apply configuration
systemctl restart docker

log_success "Docker installed and configured"
log_info "Docker version: $(docker --version)"

################################################################################
# Step 6: Install NVIDIA Container Toolkit
################################################################################

log_info "========================================="
log_info "Step 6: Installing NVIDIA Container Toolkit"
log_info "========================================="

# Add NVIDIA Container Toolkit repository
log_info "Adding NVIDIA Container Toolkit repository..."
curl -s -L https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo | \
    tee /etc/yum.repos.d/nvidia-container-toolkit.repo

# Clean cache and install
dnf clean all
dnf install -y nvidia-container-toolkit

# Configure Docker to use NVIDIA runtime
log_info "Configuring NVIDIA runtime for Docker..."
nvidia-ctk runtime configure --runtime=docker

# Restart Docker
systemctl restart docker

log_success "NVIDIA Container Toolkit installed"

# Test GPU access in Docker
log_info "Testing GPU access in Docker..."
if docker run --rm --gpus all nvidia/cuda:12.1.0-base-ubuntu22.04 nvidia-smi &> /dev/null; then
    log_success "Docker GPU access verified"
else
    log_warning "Docker GPU access test failed - may need manual verification"
fi

################################################################################
# Step 7: Install System Monitoring Tools
################################################################################

log_info "========================================="
log_info "Step 7: Installing Monitoring Tools"
log_info "========================================="

# Install htop (should already be installed)
log_info "htop already installed from core utilities"

# Install btop from source
log_info "Installing btop from source..."
cd /tmp
if [ -d "btop" ]; then
    rm -rf btop
fi

git clone https://github.com/aristocratos/btop.git
cd btop
make
make install

cd /tmp
rm -rf btop

log_success "btop installed"

# Create virtual environment for nvitop
log_info "Creating virtual environment for monitoring tools..."
sudo -u $ACTUAL_USER bash -c "source ~/.bashrc && uv venv $ACTUAL_HOME/.venv/monitoring --python 3.13"

# Install nvitop
log_info "Installing nvitop..."
sudo -u $ACTUAL_USER bash -c "source $ACTUAL_HOME/.venv/monitoring/bin/activate && uv pip install nvitop && deactivate"

# Create nvitop wrapper script
cat > /usr/local/bin/nvitop <<EOF
#!/bin/bash
source $ACTUAL_HOME/.venv/monitoring/bin/activate
nvitop "\$@"
deactivate
EOF

chmod +x /usr/local/bin/nvitop

log_success "nvitop installed"

# Add monitoring aliases to bashrc
if ! grep -q 'alias gpu=' "$ACTUAL_HOME/.bashrc"; then
    sudo -u $ACTUAL_USER bash -c 'cat >> ~/.bashrc <<'"'"'ALIASES'"'"'

# Monitoring aliases
alias gpu='"'"'watch -n 1 nvidia-smi'"'"'
alias gpumon='"'"'nvitop'"'"'
alias sysmon='"'"'btop'"'"'
alias temp='"'"'nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader'"'"'
alias gpumem='"'"'nvidia-smi --query-gpu=memory.used,memory.total --format=csv,noheader'"'"'
alias gpuutil='"'"'nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader'"'"'
ALIASES'
fi

log_success "Monitoring aliases added to bashrc"

################################################################################
# Step 8: Install vLLM and Dependencies
################################################################################

log_info "========================================="
log_info "Step 8: Installing vLLM and Dependencies"
log_info "========================================="

# Create vLLM virtual environment
log_info "Creating vLLM virtual environment..."
sudo -u $ACTUAL_USER bash -c "source ~/.bashrc && uv venv $ACTUAL_HOME/.venv/vllm --python 3.13"

# Install PyTorch with CUDA support
log_info "Installing PyTorch with CUDA 12.1 support (this may take a few minutes)..."
sudo -u $ACTUAL_USER bash -c "source $ACTUAL_HOME/.venv/vllm/bin/activate && uv pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121"

log_success "PyTorch installed"

# Verify PyTorch CUDA
log_info "Verifying PyTorch CUDA support..."
TORCH_CUDA=$(sudo -u $ACTUAL_USER bash -c "source $ACTUAL_HOME/.venv/vllm/bin/activate && python -c 'import torch; print(torch.cuda.is_available())' 2>/dev/null")
if [ "$TORCH_CUDA" = "True" ]; then
    log_success "PyTorch CUDA support verified"
else
    log_warning "PyTorch CUDA support not detected - may need manual verification"
fi

# Install vLLM
log_info "Installing vLLM (this may take several minutes)..."
sudo -u $ACTUAL_USER bash -c "source $ACTUAL_HOME/.venv/vllm/bin/activate && uv pip install vllm"

log_success "vLLM installed"

# Create vLLM wrapper script
cat > /usr/local/bin/vllm-serve <<EOF
#!/bin/bash
source $ACTUAL_HOME/.venv/vllm/bin/activate
python -m vllm.entrypoints.openai.api_server "\$@"
deactivate
EOF

chmod +x /usr/local/bin/vllm-serve

log_success "vLLM command wrapper created: vllm-serve"

################################################################################
# Step 9: Install Hugging Face CLI
################################################################################

log_info "========================================="
log_info "Step 9: Installing Hugging Face CLI"
log_info "========================================="

# Install Hugging Face Hub with CLI
log_info "Installing Hugging Face Hub CLI..."
sudo -u $ACTUAL_USER bash -c "source $ACTUAL_HOME/.venv/vllm/bin/activate && uv pip install -U 'huggingface_hub[cli]'"

log_success "Hugging Face CLI installed"

# Create Hugging Face cache directory
mkdir -p $ACTUAL_HOME/.cache/huggingface
chown -R $ACTUAL_USER:$ACTUAL_USER $ACTUAL_HOME/.cache/huggingface

# Add HF_HOME to bashrc if not present
if ! grep -q 'HF_HOME' "$ACTUAL_HOME/.bashrc"; then
    sudo -u $ACTUAL_USER bash -c 'echo "" >> ~/.bashrc'
    sudo -u $ACTUAL_USER bash -c 'echo "# Hugging Face cache directory" >> ~/.bashrc'
    sudo -u $ACTUAL_USER bash -c 'echo "export HF_HOME=$HOME/.cache/huggingface" >> ~/.bashrc'
fi

log_success "Hugging Face environment configured"

################################################################################
# Step 10: Create Helper Scripts
################################################################################

log_info "========================================="
log_info "Step 10: Creating Helper Scripts"
log_info "========================================="

# Create model download script
cat > /usr/local/bin/download-model <<'EOF'
#!/bin/bash
# Model download script

MODEL_ID="$1"
ACTUAL_USER="${SUDO_USER:-$USER}"
ACTUAL_HOME=$(eval echo ~$ACTUAL_USER)

if [ -z "$MODEL_ID" ]; then
    echo "Usage: download-model <model_id>"
    echo "Example: download-model meta-llama/Llama-3.2-1B"
    exit 1
fi

echo "Downloading $MODEL_ID..."
sudo -u $ACTUAL_USER bash -c "source $ACTUAL_HOME/.venv/vllm/bin/activate && huggingface-cli download '$MODEL_ID' && deactivate"
echo "Download complete!"
EOF

chmod +x /usr/local/bin/download-model

log_success "Helper script created: download-model"

# Create vLLM activation helper
cat > /usr/local/bin/vllm-env <<EOF
#!/bin/bash
echo "Activating vLLM environment..."
echo "Run: source $ACTUAL_HOME/.venv/vllm/bin/activate"
EOF

chmod +x /usr/local/bin/vllm-env

log_success "Helper script created: vllm-env"

################################################################################
# Step 11: Configure Firewall
################################################################################

log_info "========================================="
log_info "Step 11: Configuring Firewall"
log_info "========================================="

# Check if firewalld is running
if systemctl is-active --quiet firewalld; then
    log_info "Configuring firewall to allow vLLM API port (8000)..."
    firewall-cmd --permanent --add-port=8000/tcp
    firewall-cmd --reload
    log_success "Firewall configured - port 8000 open"
else
    log_warning "firewalld is not running - skipping firewall configuration"
fi

################################################################################
# Step 12: System Performance Tuning
################################################################################

log_info "========================================="
log_info "Step 12: System Performance Tuning"
log_info "========================================="

# Create sysctl tuning file
cat > /etc/sysctl.d/99-llm-performance.conf <<EOF
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
EOF

# Apply sysctl settings
sysctl -p /etc/sysctl.d/99-llm-performance.conf

log_success "System performance tuning applied"

# Configure system resource limits
cat >> /etc/security/limits.conf <<EOF

# LLM inference resource limits
* soft nofile 65536
* hard nofile 65536
* soft nproc 65536
* hard nproc 65536
EOF

log_success "Resource limits configured"

# Enable GPU persistence mode
if command -v nvidia-smi &> /dev/null; then
    nvidia-smi -pm 1
    log_success "GPU persistence mode enabled"
fi

################################################################################
# Step 13: Create Verification Script
################################################################################

log_info "========================================="
log_info "Step 13: Creating Verification Script"
log_info "========================================="

cat > /usr/local/bin/llm-system-check <<EOF
#!/bin/bash

echo "=== LLM Inference System Verification ==="
echo ""

echo "1. NVIDIA Drivers:"
nvidia-smi --query-gpu=name,driver_version,memory.total --format=csv,noheader
echo ""

echo "2. CUDA:"
nvcc --version | grep "release" || echo "nvcc not in PATH"
echo ""

echo "3. Docker:"
docker --version
docker run --rm --gpus all nvidia/cuda:12.1.0-base-ubuntu22.04 nvidia-smi > /dev/null 2>&1 && echo "✓ Docker GPU access working" || echo "✗ Docker GPU access failed"
echo ""

echo "4. Python:"
sudo -u $ACTUAL_USER bash -c "source ~/.bashrc && python --version"
echo ""

echo "5. UV:"
sudo -u $ACTUAL_USER bash -c "source ~/.bashrc && uv --version"
echo ""

echo "6. vLLM:"
sudo -u $ACTUAL_USER bash -c "source $ACTUAL_HOME/.venv/vllm/bin/activate && python -c 'import vllm; print(f\"vLLM version: {vllm.__version__}\")' 2>/dev/null && echo '✓ vLLM installed' || echo '✗ vLLM not found'"
sudo -u $ACTUAL_USER bash -c "source $ACTUAL_HOME/.venv/vllm/bin/activate && python -c 'import torch; print(f\"PyTorch CUDA: {torch.cuda.is_available()}\")' 2>/dev/null"
echo ""

echo "7. Monitoring Tools:"
which nvitop > /dev/null && echo "✓ nvitop installed" || echo "✗ nvitop not found"
which btop > /dev/null && echo "✓ btop installed" || echo "✗ btop not found"
which htop > /dev/null && echo "✓ htop installed" || echo "✗ htop not found"
echo ""

echo "8. Helper Scripts:"
which download-model > /dev/null && echo "✓ download-model installed" || echo "✗ download-model not found"
which vllm-serve > /dev/null && echo "✓ vllm-serve installed" || echo "✗ vllm-serve not found"
echo ""

echo "=== Verification Complete ==="
echo ""
echo "Next steps:"
echo "1. Logout and login again to apply group changes (docker group)"
echo "2. Authenticate with Hugging Face: huggingface-cli login"
echo "3. Download a model: download-model facebook/opt-125m"
echo "4. Test vLLM: vllm-serve facebook/opt-125m"
EOF

chmod +x /usr/local/bin/llm-system-check

log_success "Verification script created: llm-system-check"

################################################################################
# Step 14: Create Example systemd Service
################################################################################

log_info "========================================="
log_info "Step 14: Creating Example systemd Service"
log_info "========================================="

cat > /etc/systemd/system/vllm-example.service <<EOF
[Unit]
Description=vLLM OpenAI-Compatible Server (Example)
After=network.target

[Service]
Type=simple
User=$ACTUAL_USER
Group=$ACTUAL_USER
WorkingDirectory=$ACTUAL_HOME
Environment="PATH=$ACTUAL_HOME/.venv/vllm/bin:/usr/local/bin:/usr/bin"
Environment="CUDA_VISIBLE_DEVICES=0,1"
Environment="HF_HOME=$ACTUAL_HOME/.cache/huggingface"

# Example command - edit model name and parameters as needed
# ExecStart=$ACTUAL_HOME/.venv/vllm/bin/python -m vllm.entrypoints.openai.api_server \\
#     --model facebook/opt-125m \\
#     --tensor-parallel-size 1 \\
#     --gpu-memory-utilization 0.9 \\
#     --port 8000 \\
#     --host 0.0.0.0

Restart=on-failure
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload

log_success "Example systemd service created: /etc/systemd/system/vllm-example.service"
log_info "Edit the service file to configure your model, then enable with: systemctl enable vllm-example.service"

################################################################################
# Final Steps and Summary
################################################################################

log_info "========================================="
log_info "Installation Complete!"
log_info "========================================="

echo ""
log_success "All components have been installed successfully!"
echo ""

log_info "IMPORTANT: Please perform the following manual steps:"
echo ""
echo "1. Logout and login again (required for docker group to take effect)"
echo "   - Or run: newgrp docker"
echo ""
echo "2. Authenticate with Hugging Face (if using gated models):"
echo "   source $ACTUAL_HOME/.venv/vllm/bin/activate"
echo "   huggingface-cli login"
echo "   deactivate"
echo ""
echo "3. Run the verification script:"
echo "   llm-system-check"
echo ""
echo "4. Test vLLM with a small model:"
echo "   download-model facebook/opt-125m"
echo "   vllm-serve facebook/opt-125m"
echo ""

log_info "Installed Components:"
echo "  ✓ System utilities (wget, curl, vim, nano, htop, git)"
echo "  ✓ UV Python package manager"
echo "  ✓ Python 3.13"
echo "  ✓ Docker with NVIDIA GPU support"
echo "  ✓ NVIDIA Container Toolkit"
echo "  ✓ Monitoring tools (nvitop, btop, htop)"
echo "  ✓ vLLM inference engine"
echo "  ✓ Hugging Face CLI"
echo "  ✓ Helper scripts and aliases"
echo ""

log_info "Useful Commands:"
echo "  llm-system-check          - Verify installation"
echo "  vllm-serve <model>        - Start vLLM server"
echo "  download-model <model>    - Download HuggingFace model"
echo "  nvitop                    - GPU monitoring"
echo "  btop                      - System monitoring"
echo "  gpu                       - Watch nvidia-smi"
echo ""

log_info "Configuration Files:"
echo "  /etc/docker/daemon.json                  - Docker configuration"
echo "  /etc/systemd/system/vllm-example.service - Example vLLM service"
echo "  /etc/sysctl.d/99-llm-performance.conf    - Performance tuning"
echo "  $ACTUAL_HOME/.bashrc                     - User aliases and environment"
echo ""

log_success "Setup complete! Enjoy your LLM inference system! 🚀"

exit 0
