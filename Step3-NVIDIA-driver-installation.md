# NVIDIA Driver Installation Guide for RHEL 10

Complete guide for installing NVIDIA drivers and CUDA Toolkit on Red Hat Enterprise Linux 10 for multi-GPU configurations (RTX 3090, RTX 5090, and other modern NVIDIA GPUs).

## Table of Contents

- [Prerequisites](#prerequisites)
- [Important Notes](#important-notes)
- [Installation Steps](#installation-steps)
  - [1. Fix RHEL 10 GPG Key Issue](#1-fix-rhel-10-gpg-key-issue)
  - [2. Enable Required Repositories](#2-enable-required-repositories)
  - [3. Install Kernel Development Packages](#3-install-kernel-development-packages)
  - [4. Install EPEL Repository](#4-install-epel-repository)
  - [5. Download and Install NVIDIA Driver Repository](#5-download-and-install-nvidia-driver-repository)
  - [6. Install NVIDIA Open Kernel Driver](#6-install-nvidia-open-kernel-driver)
  - [7. Download and Install CUDA Toolkit](#7-download-and-install-cuda-toolkit)
  - [8. Configure Dracut for NVIDIA Modules](#8-configure-dracut-for-nvidia-modules)
  - [9. Reboot System](#9-reboot-system)
  - [10. Post-Installation Verification](#10-post-installation-verification)
- [Troubleshooting](#troubleshooting)
- [Known Issues](#known-issues)
- [Additional Resources](#additional-resources)

---

## Prerequisites

- Fresh installation of Red Hat Enterprise Linux 10
- Active Red Hat subscription (required)
- Root or sudo access
- Internet connectivity
- Multiple NVIDIA GPUs (e.g., RTX 3090, RTX 5090)
- Secure Boot disabled (recommended)

---

## Important Notes

⚠️ **RHEL 10.1+ Simplified Installation Available**

If you're running RHEL 10.1 or later, Red Hat now provides a simplified installation method using the `rhel-drivers` tool. This is the **recommended approach** as it:
- Uses drivers built and signed by Red Hat
- Works with Secure Boot enabled
- Automatically handles dependencies
- Provides a one-command installation

See the "Alternative: RHEL 10.1+ Simplified Method" section below for details.

⚠️ **RHEL 10.0 GPG Key Issue**

RHEL 10.0 has a known GPG key issue that must be resolved before proceeding with driver installation. This guide includes the fix as the first step.

⚠️ **Open vs Proprietary Driver**

This guide uses the **NVIDIA Open Kernel Driver** (`nvidia-open`), which is recommended for modern GPUs including RTX 3090 and RTX 5090. Note:
- Open drivers are supported on Turing architecture and newer (RTX 2000 series+)
- For older GPUs (Maxwell, Pascal, Volta), use proprietary drivers instead

⚠️ **Secure Boot Considerations**

The method in this guide uses locally downloaded drivers that are not Red Hat signed:
- **Secure Boot must be disabled** for this method
- For Secure Boot support, use the RHEL 10.1+ simplified method or precompiled signed drivers

---

## Installation Steps

### 1. Fix RHEL 10 GPG Key Issue

RHEL 10 has a known bug where DNF transactions fail with GPG key errors. This must be resolved first.

**Reference:** [Red Hat Article - DNF transaction fails with GPG key errors](https://access.redhat.com/solutions/7090648)

```bash
# Attempt initial upgrade (may fail with GPG errors)
sudo dnf upgrade

# Clean DNF cache
sudo dnf clean all

# Check for the specific advisory
sudo dnf updateinfo list RHBA-2025:21017

# Locate the redhat-release package
sudo dnf repoquery --location redhat-release

# Update with the advisory, bypassing GPG check
sudo sudo dnf update --advisory=RHBA-2025:21017 --nogpgcheck

# Run upgrade again to ensure system is up to date
sudo dnf upgrade
```

After this fix, DNF operations should work normally without GPG key errors.

### 2. Enable Required Repositories

Enable the necessary Red Hat repositories for kernel development and additional packages.

```bash
# Enable AppStream repository (will take a 5 minutes to respond)
sudo subscription-manager repos --enable=rhel-10-for-x86_64-appstream-rpms

# Enable BaseOS repository (will take a 5 minutes to respond)
sudo subscription-manager repos --enable=rhel-10-for-x86_64-baseos-rpms

# Enable CodeReady Builder repository (for development packages) (will take a 5 minutes to respond)
sudo subscription-manager repos --enable=codeready-builder-for-rhel-10-x86_64-rpms
```

**Verify repositories are enabled:**

```bash
dnf repolist
```

### 3. Install Kernel Development Packages

Install the kernel headers and development packages that match your running kernel.

```bash
sudo dnf install kernel-devel-matched kernel-headers
```

**Note:** The `kernel-devel-matched` package ensures compatibility with your current running kernel. If you encounter issues, you can install the specific version:

```bash
# Check your current kernel version
sudo uname -r

# Install specific kernel development packages
sudo dnf install kernel-devel-$(uname -r) kernel-headers-$(uname -r)
```

This ensures the kernel modules can be built properly for your current kernel version.

### 4. Install EPEL Repository

EPEL (Extra Packages for Enterprise Linux) provides additional packages not included in RHEL.

```bash
sudo dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm
```

### 5. Download and Install NVIDIA Driver Repository

Download the NVIDIA driver local repository RPM and install it.

**Download the driver repository:**

```bash
# Driver version 590.48.01 (adjust version as needed)
sudo wget https://developer.download.nvidia.com/compute/nvidia-driver/590.48.01/local_installers/nvidia-driver-local-repo-rhel10-590.48.01-1.0-1.x86_64.rpm
```

**Install the repository:**

```bash
sudo rpm -i nvidia-driver-local-repo-rhel10-590.48.01-1.0-1.x86_64.rpm
```

**Clean DNF cache:**

```bash
sudo dnf clean all
```

### 6. Install NVIDIA Open Kernel Driver

Install the NVIDIA open kernel driver, which provides better compatibility with modern RHEL systems.

```bash
dnf -y install nvidia-open-590
```

This will install:
- NVIDIA open kernel modules
- NVIDIA driver libraries
- Required dependencies

The installation may take several minutes to complete.

### 7. Download and Install CUDA Toolkit

Download and install the CUDA Toolkit (version 13.1.1 in this example).

**Download CUDA repository:**

```bash
sudo wget https://developer.download.nvidia.com/compute/cuda/13.1.1/local_installers/cuda-repo-rhel10-13-1-local-13.1.1_590.48.01-1.x86_64.rpm
```

**Install CUDA repository:**

```bash
sudo rpm -i cuda-repo-rhel10-13-1-local-13.1.1_590.48.01-1.x86_64.rpm
```

**Clean DNF cache:**

```bash
sudo dnf clean all
```

**Install CUDA Toolkit:**

```bash
sudo dnf -y install cuda-toolkit-13-1
```

This installs:
- CUDA compiler (nvcc)
- CUDA libraries
- CUDA samples and documentation
- Development tools

### 8. Configure Dracut for NVIDIA Modules

Configure dracut to include NVIDIA kernel modules in the initial RAM filesystem (initramfs). This ensures the drivers load early in the boot process.

**First, blacklist the Nouveau driver (conflicts with NVIDIA):**

```bash
sudo bash -c 'cat > /etc/modprobe.d/blacklist-nouveau.conf << EOF
blacklist nouveau
options nouveau modeset=0
EOF'
```

**Create dracut configuration file:**

```bash
sudo nano /usr/lib/dracut/dracut.conf.d/99-nvidia.conf
```

**Add the following content:**
** and - Remove the Omit_drivers+= line so just the add driver is .conf file.
```bash
add_drivers+=" nvidia nvidia-drm nvidia-modeset nvidia-uvm "
```

**Save and exit** (Ctrl+X, then Y, then Enter)

**Rebuild the initramfs:**

```bash
sudo dracut -fv --add-drivers "nvidia nvidia-drm nvidia-modeset nvidia-uvm"
```

This command:
- `-f` forces a rebuild
- `-v` provides verbose output
- `--add-drivers` explicitly includes the NVIDIA modules

### 9. Reboot System

```bash
sudo systemctl reboot
```

### 10. Post-Installation Verification

After reboot, verify the NVIDIA driver and CUDA Toolkit are properly installed and functional.

**Check loaded kernel modules:**

```bash
lsmod | grep nvidia
```

**Expected output:**
```
nvidia_uvm           1523712  0
nvidia_drm             73728  0
nvidia_modeset       1306624  1 nvidia_drm
nvidia              56426496  2 nvidia_uvm,nvidia_modeset
drm_kms_helper        176128  4 qxl,nvidia_drm
drm                   565248  7 drm_kms_helper,qxl,nvidia,drm_ttm_helper,nvidia_drm,ttm
```

**Verify NVIDIA driver with nvidia-smi:**

```bash
sudo nvidia-smi
```

**Expected output (example with multiple GPUs):**
```
+---------------------------------------------------------------------------------------+
| NVIDIA-SMI 590.48.01      Driver Version: 590.48.01      CUDA Version: 13.1          |
|-----------------------------------------+----------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |         Memory-Usage | GPU-Util  Compute M. |
|                                         |                      |               MIG M. |
|=========================================+======================+======================|
|   0  NVIDIA GeForce RTX 3090        Off | 00000000:01:00.0 Off |                  N/A |
| 30%   35C    P8              25W / 350W |      0MiB / 24576MiB |      0%      Default |
+-----------------------------------------+----------------------+----------------------+
|   1  NVIDIA GeForce RTX 5090        Off | 00000000:02:00.0 Off |                  N/A |
| 30%   33C    P8              28W / 450W |      0MiB / 32768MiB |      0%      Default |
+-----------------------------------------+----------------------+----------------------+
```

**Verify CUDA compiler installation:**

```bash
nvcc --version
```

**Expected output:**
```
nvcc: NVIDIA (R) Cuda compiler driver
Copyright (c) 2005-2024 NVIDIA Corporation
Built on Wed_Oct_30_01:18:48_PDT_2024
Cuda compilation tools, release 13.1, V13.1.1
Build cuda_13.1.r13.1/compiler.34431801_0
```

**Check driver module information:**

```bash
modinfo nvidia
```

**Test CUDA with a simple deviceQuery (if CUDA samples installed):**

```bash
cd /usr/local/cuda-13.1/extras/demo_suite
./deviceQuery
```

**Configure CUDA environment variables (important!):**

Add CUDA to your PATH and LD_LIBRARY_PATH:

```bash
echo 'export PATH=/usr/local/cuda-13.1/bin:$PATH' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=/usr/local/cuda-13.1/lib64:$LD_LIBRARY_PATH' >> ~/.bashrc
source ~/.bashrc
```

For system-wide configuration:

```bash
sudo bash -c 'cat > /etc/profile.d/cuda.sh << EOF
export PATH=/usr/local/cuda-13.1/bin:\$PATH
export LD_LIBRARY_PATH=/usr/local/cuda-13.1/lib64:\$LD_LIBRARY_PATH
EOF'
```

---

## Troubleshooting

### GPG Key Errors Persist

If you continue to see GPG key errors after following Step 1:

```bash
# Force clean all DNF metadata
sudo dnf clean all
sudo rm -rf /var/cache/dnf

# Try update again
sudo dnf update --nogpgcheck
```

### NVIDIA Driver Not Loading

**Check kernel messages:**

```bash
dmesg | grep -i nvidia
```

**Check systemd journal:**

```bash
journalctl -b | grep -i nvidia
```

**Verify dracut configuration was applied:**

```bash
lsinitrd | grep nvidia
```

You should see the NVIDIA modules listed in the initramfs.

### Multiple GPU Issues

**Verify all GPUs are detected:**

```bash
nvidia-smi -L
```

**Check PCIe bus configuration:**

```bash
lspci | grep -i nvidia
```

**Monitor GPU topology:**

```bash
nvidia-smi topo -m
```

### CUDA Toolkit Not Found

**Set CUDA environment variables:**

Add to `~/.bashrc`:

```bash
export PATH=/usr/local/cuda-13.1/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda-13.1/lib64:$LD_LIBRARY_PATH
```

Then reload:

```bash
source ~/.bashrc
```

### Nouveau Driver Conflicts

If the system still loads the Nouveau driver:

```bash
# Verify Nouveau is disabled
lsmod | grep nouveau

# If Nouveau is loaded, ensure blacklist is correct
cat /etc/modprobe.d/blacklist-nouveau.conf

# Rebuild initramfs again
sudo dracut -fv
sudo reboot
```

### SELinux Considerations

SELinux may interfere with NVIDIA driver loading. Check status:

```bash
getenforce
```

If experiencing issues, you can temporarily set to permissive mode for testing:

```bash
sudo setenforce 0
```

To make it permanent (not recommended for production):

```bash
sudo sed -i 's/SELINUX=enforcing/SELINUX=permissive/' /etc/selinux/config
```

**Note:** It's better to create proper SELinux policies than disable it entirely.

### Rebuild Initramfs

If drivers are not loading at boot:

```bash
# Rebuild initramfs for current kernel
sudo dracut -fv

# Or rebuild for specific kernel
sudo dracut -fv /boot/initramfs-$(uname -r).img $(uname -r)
```

### Driver Version Conflicts

If you need to switch driver versions:

```bash
# Remove current driver
dnf remove nvidia-open-*

# Clean cache
dnf clean all

# Install different version
dnf install nvidia-open-<version>
```

---

## Known Issues

### RHEL 10 Specific Issues

- **GPG Key Bug**: Fixed in RHBA-2025:21017 advisory (addressed in Step 1)
- **Kernel Updates**: After kernel updates, you may need to rebuild initramfs:
  ```bash
  sudo dracut -fv
  sudo systemctl reboot
  ```

### Multi-GPU Considerations

- **Power Requirements**: Ensure adequate PSU capacity
  - RTX 3090: ~350W per card
  - RTX 5090: ~450W per card
  - Recommended: 1200W+ PSU for dual GPU setup

- **PCIe Bandwidth**: Check motherboard specifications
  - Both GPUs should run at PCIe 4.0 x16 or x8 minimum
  - Some boards reduce lanes when multiple slots are populated

- **Cooling**: Multi-GPU configurations generate significant heat
  - Ensure proper case ventilation
  - Monitor temperatures with `nvidia-smi dmon`

### Driver Updates

When updating NVIDIA drivers:

```bash
# Update driver
dnf update nvidia-open-*

# Rebuild initramfs
sudo dracut -fv

# Reboot
sudo systemctl reboot
```

---

## Alternative: RHEL 10.1+ Simplified Installation Method

**For RHEL 10.1 and later, Red Hat provides a much simpler installation method using `rhel-drivers`.**

### Prerequisites

- RHEL 10.1 or later
- Active Red Hat subscription
- Compatible NVIDIA GPU (Turing architecture or newer for open drivers)

### Installation Steps

**1. Install the rhel-drivers package:**

```bash
sudo dnf install rhel-drivers
```

**2. Install NVIDIA drivers with one command:**

```bash
sudo rhel-drivers install nvidia
sudo reboot
```

**3. Verify installation:**

```bash
nvidia-smi
```

### Advantages of this Method

- ✅ Drivers are built and signed by Red Hat
- ✅ Works with Secure Boot enabled
- ✅ Automatic dependency handling
- ✅ No manual repository configuration needed
- ✅ No EPEL required
- ✅ Tested and validated driver/kernel combinations
- ✅ Prevents kernel updates that break the driver

### Installing Specific Driver Versions

If you need a specific driver version instead of the latest:

**Enable the supplementary repository:**

```bash
sudo subscription-manager repos --enable=rhel-10-for-x86_64-supplementary-rpms
sudo subscription-manager repos --enable=rhel-10-for-x86_64-extensions-rpms
```

**Install specific version:**

```bash
sudo dnf install kmod-nvidia-<version> nvidia-driver-<version>
sudo reboot
```

### CUDA Toolkit Installation (RHEL 10.1+)

After installing the driver with `rhel-drivers`, install CUDA Toolkit:

**Enable EPEL for dependencies:**

```bash
sudo dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm
```

**Download and install CUDA repository:**

```bash
wget https://developer.download.nvidia.com/compute/cuda/13.1.1/local_installers/cuda-repo-rhel10-13-1-local-13.1.1_590.48.01-1.x86_64.rpm
sudo rpm -i cuda-repo-rhel10-13-1-local-13.1.1_590.48.01-1.x86_64.rpm
sudo dnf clean all
sudo dnf install cuda-toolkit-13-1
```

**Set environment variables:**

```bash
echo 'export PATH=/usr/local/cuda-13.1/bin:$PATH' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=/usr/local/cuda-13.1/lib64:$LD_LIBRARY_PATH' >> ~/.bashrc
source ~/.bashrc
```

---

## Additional Resources

- [NVIDIA Driver Documentation](https://docs.nvidia.com/cuda/cuda-installation-guide-linux/)
- [NVIDIA Open GPU Kernel Modules](https://github.com/NVIDIA/open-gpu-kernel-modules)
- [Red Hat GPG Key Issue Solution](https://access.redhat.com/solutions/7090648)
- [Red Hat AI Accelerator Driver Guide](https://www.redhat.com/en/blog/introducing-new-and-simplified-ai-accelerator-driver-experience-rhel)
- [NVIDIA Open GPU Drivers Signed by Red Hat](https://developer.nvidia.com/blog/nvidia-open-gpu-datacenter-drivers-for-rhel9-signed-by-red-hat)
- [CUDA Toolkit Documentation](https://docs.nvidia.com/cuda/)
- [RHEL 10 Release Notes](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/10/)

### Version-Specific Downloads

- [NVIDIA Driver Downloads](https://www.nvidia.com/Download/index.aspx)
- [CUDA Toolkit Archive](https://developer.nvidia.com/cuda-toolkit-archive)

---

## Quick Reference Commands

```bash
# Check driver status
nvidia-smi

# Monitor GPU usage
watch -n 1 nvidia-smi

# Check loaded modules
lsmod | grep nvidia

# View GPU details
nvidia-smi -q

# Check CUDA version
nvcc --version

# Monitor temperatures and power
nvidia-smi dmon

# GPU topology (multi-GPU)
nvidia-smi topo -m
```

---

## License

This guide is provided as-is for educational and informational purposes.

## Contributing

Contributions, corrections, and improvements are welcome. Please submit a pull request or open an issue.

---

**Last Updated:** February 2026  
**RHEL Version:** 10  
**Driver Version:** 590.48.01  
**CUDA Version:** 13.1.1  
**Tested GPUs:** RTX 3090, RTX 5090  
**Installation Method:** NVIDIA Open Kernel Driver
