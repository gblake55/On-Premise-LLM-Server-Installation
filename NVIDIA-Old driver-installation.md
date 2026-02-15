# NVIDIA Driver Installation Guide for RHEL 10

Complete guide for installing NVIDIA drivers with DKMS support on Red Hat Enterprise Linux 10 for multi-GPU configurations (RTX 3090, RTX 5090, and other modern NVIDIA GPUs).

## Table of Contents

- [Prerequisites](#prerequisites)
- [Important Notes](#important-notes)
- [Installation Steps](#installation-steps)
  - [1. Disable Secure Boot](#1-disable-secure-boot)
  - [2. Download NVIDIA Driver](#2-download-nvidia-driver)
  - [3. Install Driver Repository](#3-install-driver-repository)
  - [4. Install DKMS](#4-install-dkms)
  - [5. Install Development Tools](#5-install-development-tools)
  - [6. Install CUDA Driver](#6-install-cuda-driver)
  - [7. Verify Installation](#7-verify-installation)
  - [8. Reboot System](#8-reboot-system)
  - [9. Post-Installation Verification](#9-post-installation-verification)
- [Troubleshooting](#troubleshooting)
- [Known Issues](#known-issues)
- [Additional Resources](#additional-resources)

---

## Prerequisites

- Fresh installation of Red Hat Enterprise Linux 10
- Active Red Hat subscription (for development tools and kernel headers)
- Root or sudo access
- Internet connectivity
- Multiple NVIDIA GPUs (e.g., RTX 3090, RTX 5090)

---

## Important Notes

⚠️ **Secure Boot Configuration**

This installation method uses DKMS (Dynamic Kernel Module Support) to compile the NVIDIA driver from source code. Since the compiled driver does not have a vendor signature, **Secure Boot must be disabled** in the BIOS.

If Secure Boot is enabled, the driver will fail to load with the error:
```
Required key not available
```

For systems requiring Secure Boot, please refer to the pre-compiled driver installation method instead.

---

## Installation Steps

### 1. Disable Secure Boot

**Verify Current Secure Boot Status:**

```bash
mokutil --sb-state
```

**Expected output when disabled:**
```
SecureBoot disabled
```

**To Disable Secure Boot:**

1. Reboot your system
2. Press **F2** (or your system's BIOS key) during POST
3. Navigate to the Security or Boot settings
4. Disable Secure Boot
5. Save changes and exit

### 2. Download NVIDIA Driver

Visit the [NVIDIA Driver Downloads](https://www.nvidia.com/Download/index.aspx) page:

1. **Select your operating system:**
   - Operating System: `Linux 64-bit`
   - Distribution: `Red Hat Enterprise Linux 10`

2. **Select CUDA Toolkit version:**
   - Choose the CUDA version you plan to use (e.g., CUDA 13.1 or later)
   - For RTX 3090/5090, ensure you select a driver version that supports these GPUs

3. **Download the RPM package:**
   - Example: `nvidia-driver-local-repo-rhel10-580.126.09.x86_64.rpm`

Transfer the downloaded RPM to your RHEL 10 system.

### 3. Install Driver Repository

```bash
# Navigate to download location
cd /path/to/downloads

# Install the local repository RPM
sudo yum localinstall ./nvidia-driver-local-repo-rhel10-580.126.09.x86_64.rpm
```

**Verify repository installation:**

```bash
sudo yum repolist
```

You should see the NVIDIA repository listed:
```
nvidia-driver-local-rhel10-580.126.09  nvidia-driver-local-rhel10-580.126.09
```

### 4. Install DKMS

DKMS is not included in RHEL by default. It is available through EPEL (Extra Packages for Enterprise Linux).

**Install EPEL repository:**

```bash
sudo yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm
```

**Install DKMS:**

```bash
sudo yum install dkms
```

**Optional - Disable/Remove EPEL after installation:**

To disable EPEL (keep installed but inactive):
```bash
sudo vi /etc/yum.repos.d/epel.repo
# Change "enabled=1" to "enabled=0"
```

To completely remove EPEL:
```bash
sudo yum remove epel-release
```

### 5. Install Development Tools

Ensure your Red Hat subscription is active and attached.

**Install Development Tools:**

```bash
sudo yum groupinstall "Development Tools"
```

**Install kernel headers and development packages:**

```bash
sudo yum install kernel-devel-$(uname -r)
```

### 6. Install CUDA Driver

```bash
sudo yum install cuda-driver
```

This will install the NVIDIA driver along with CUDA components compatible with your selected version.

### 7. Verify Installation

**Check DKMS status:**

```bash
sudo dkms status
```

**Expected output:**
```
nvidia/580.126.09, 4.18.0-425.3.1.el8.x86_64, x86_64: installed
```

**Troubleshooting DKMS status:**

If status shows `added` instead of `installed`:
```bash
sudo dkms build nvidia/580.126.09
```

If status shows `built` but not `installed`:
```bash
sudo dkms install nvidia/580.126.09
```

If build or installation fails, check logs:
```bash
sudo ls /var/lib/dkms/nvidia/580.126.09/$(uname -r)/x86_64/log/make.log
```

### 8. Reboot System

```bash
sudo systemctl reboot
```

### 9. Post-Installation Verification

After reboot, verify the driver is loaded and functioning correctly.

**Check loaded kernel modules:**

```bash
sudo lsmod | grep nvidia
```

**Expected output:**
```
nvidia_drm             73728  0
nvidia_modeset       1306624  1 nvidia_drm
nvidia_uvm           1523712  0
nvidia              56426496  2 nvidia_uvm,nvidia_modeset
drm_kms_helper        176128  4 qxl,nvidia_drm
drm                   565248  7 drm_kms_helper,qxl,nvidia,drm_ttm_helper,nvidia_drm,ttm
```

**Run nvidia-smi to check GPU status:**

```bash
sudo nvidia-smi
```

**Expected output (example with multiple GPUs):**
```
+---------------------------------------------------------------------------------------+
| NVIDIA-SMI 580.126.09     Driver Version: 580.126.09     CUDA Version: 13.1          |
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

**Verify driver module information:**

```bash
sudo modinfo nvidia
```

This displays detailed information about the NVIDIA kernel module, including version and supported firmware.

---

## Troubleshooting

### Black Screen After Reboot (Graphical Target)

If your system boots to a black screen when running `graphical.target`:

```bash
# Boot to recovery mode or multi-user target
# Then move the X11 configuration:
sudo mv /etc/X11/xorg.conf.d/10-nvidia.conf /root/10-nvidia.conf.backup
sudo systemctl reboot
```

### GPU Passthrough for KVM Virtual Machines

If using GPU passthrough with KVM, boot the hypervisor into `multi-user.target` instead of `graphical.target`:

```bash
sudo systemctl set-default multi-user.target
sudo systemctl reboot
```

The graphical target prevents the NVIDIA driver from unloading properly before VM passthrough.

### Driver Build Failures

Check DKMS logs for detailed error messages:

```bash
sudo cat /var/lib/dkms/nvidia/580.126.09/$(uname -r)/x86_64/log/make.log
```

Common issues:
- Missing kernel headers: `sudo yum install kernel-devel-$(uname -r)`
- Missing development tools: `sudo yum groupinstall "Development Tools"`
- Kernel version mismatch: Ensure running kernel matches installed headers

### Collecting Diagnostic Information

If you need to contact support, collect the following:

```bash
# Generate system report
sudo sosreport

# DKMS logs
sudo tar -czf dkms-logs.tar.gz /var/lib/dkms/nvidia/*/log/

# NVIDIA installer logs (if present)
sudo tar -czf nvidia-logs.tar.gz /var/log/nvidia-installer.log
```

---

## Known Issues

- **Multiple GPU Performance**: Ensure adequate power supply and PCIe bandwidth for multi-GPU configurations
- **Mixed GPU Models**: RTX 3090 and RTX 5090 can coexist but may require specific CUDA versions
- **Kernel Updates**: After kernel updates, DKMS will automatically rebuild the driver for the new kernel

---

## Additional Resources

- [NVIDIA Driver Documentation](https://docs.nvidia.com/cuda/cuda-installation-guide-linux/)
- [RHEL DKMS Information](https://access.redhat.com/solutions/1132653)
- [NVIDIA CUDA Toolkit Documentation](https://docs.nvidia.com/cuda/)
- [Detailed Installation Blog Post](https://chrispaquin.com/2025/03/25/step-by-step-nvidia-driver-cuda-toolkit-container-toolkit-install-for-rhel9/)

---

## License

This guide is provided as-is for educational and informational purposes.

## Contributing

Contributions, corrections, and improvements are welcome. Please submit a pull request or open an issue.

---

**Last Updated:** February 2026  
**RHEL Version:** 10  
**Tested GPUs:** RTX 3090, RTX 5090  
**Driver Version:** 580.126.09 (example)
