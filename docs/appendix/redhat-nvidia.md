# RHEL NVIDIA Driver Installation with DKMS

This guide covers compiling and installing an NVIDIA driver with DKMS in Red Hat Enterprise Linux with Secure Boot **disabled**.

!!! warning "Secure Boot"
    Ensure Secure Boot is disabled in BIOS before proceeding. DKMS compiles the driver from source without a vendor signature. If Secure Boot is enabled, the driver fails to load with "Required key not available".

    Verify status: `mokutil --sb-state`

!!! note "Alternative for Secure Boot"
    If Secure Boot is required, see Red Hat article: "How to Install NVIDIA Driver Online in Red Hat Enterprise Linux with Secure Boot Enabled"

## Step 1: Download Driver

1. Go to the NVIDIA website
2. Select Red Hat Enterprise Linux 10
3. Select CUDA version (e.g., 13.1)
4. Download the RPM (e.g., `nvidia-driver-local-repo-rhel10-580.126.09.x86_64.rpm`)

## Step 2: Install Local Repository

```bash
sudo yum localinstall ./nvidia-driver-local-repo-rhel10-580.126.09.x86_64.rpm
sudo yum repolist
```

## Step 3: Install DKMS

DKMS is available from EPEL (Extra Packages for Enterprise Linux):

```bash
sudo yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm
sudo yum install dkms
```

To disable EPEL after installation:

```bash
sudo vi /etc/yum.repos.d/epel.repo
# Change to: enabled=0
```

Or remove completely:

```bash
sudo yum remove epel-release
```

## Step 4: Install Build Tools and Kernel Headers

Ensure Red Hat subscription is attached:

```bash
sudo yum groupinstall "Development Tools"
sudo yum install kernel-devel-$(uname -r)
```

## Step 5: Install CUDA Driver

```bash
sudo yum install cuda-driver
```

## Step 6: Verify Installation

```bash
sudo dkms status
# Expected: nvidia/580.126.09, x86_64: installed
```

If status shows "Added" instead of "installed":

```bash
sudo dkms build nvidia/580.126.09
sudo dkms install nvidia/580.126.09
```

If build/install fails, check logs:

```bash
sudo cat /var/lib/dkms/nvidia/580.126.09/$(uname -r)/x86_64/log/make.log
```

## Step 7: Reboot

```bash
sudo systemctl reboot
```

## Step 8: Verify Driver

```bash
sudo lsmod | grep nvidia
sudo nvidia-smi
sudo modinfo nvidia
```

Expected output from `lsmod`:

```
nvidia_drm             73728  0
nvidia_modeset       1306624  1 nvidia_drm
nvidia_uvm           1523712  0
nvidia              56426496  2 nvidia_uvm,nvidia_modeset
```

## Troubleshooting

### Black Screen After Reboot (Graphical Target)

If RHEL boots to graphical.target and shows black screen:

```bash
sudo mv /etc/X11/xorg.conf.d/10-nvidia.conf /root/
sudo systemctl reboot
```

### GPU Passthrough to KVM VM

If passing GPU to VM with graphical.target enabled, it will fail. Boot hypervisor to multi-user.target:

```bash
sudo systemctl set-default multi-user.target
```

## Support

Collect these logs for Dell Support:

- `sosreport`
- Build/make log files
- `/var/log/nvidia-installer.log`

## References

- [Step-by-Step NVIDIA Driver CUDA Toolkit Install for RHEL9](https://chrispaquin.com/2025/03/25/step-by-step-nvidia-driver-cuda-toolkit-container-toolkit-install-for-rhel9/)
