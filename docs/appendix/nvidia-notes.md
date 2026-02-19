# NVIDIA Installation Notes

Quick reference commands for NVIDIA driver and CUDA installation on RHEL 10.

## Fix RHEL 10 GPG Key Issue

Reference: Red Hat Article "DNF transaction fails with error: package GPG keys are already installed but they are not correct for this package"

```bash
sudo dnf clean all
dnf updateinfo list RHBA-2025:21017
sudo dnf update --advisory=RHBA-2025:21017 --nogpgcheck
```

## Install Kernel Development Packages

```bash
dnf install kernel-devel-matched kernel-headers
```

## Enable Required Repositories

```bash
subscription-manager repos --enable=rhel-10-for-x86_64-appstream-rpms
subscription-manager repos --enable=rhel-10-for-x86_64-baseos-rpms
subscription-manager repos --enable=codeready-builder-for-rhel-10-x86_64-rpms
dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm
```

## Install NVIDIA Driver

```bash
wget https://developer.download.nvidia.com/compute/nvidia-driver/590.48.01/local_installers/nvidia-driver-local-repo-rhel10-590.48.01-1.0-1.x86_64.rpm
rpm -i nvidia-driver-local-repo-rhel10-590.48.01-1.0-1.x86_64.rpm
dnf clean all
dnf -y install nvidia-open-590
```

## Install CUDA Toolkit

```bash
wget https://developer.download.nvidia.com/compute/cuda/13.1.1/local_installers/cuda-repo-rhel10-13-1-local-13.1.1_590.48.01-1.x86_64.rpm
rpm -i cuda-repo-rhel10-13-1-local-13.1.1_590.48.01-1.x86_64.rpm
dnf clean all
dnf -y install cuda-toolkit-13-1
```

## Configure Dracut for NVIDIA Modules

```bash
sudo nano /usr/lib/dracut/dracut.conf.d/99-nvidia.conf
sudo dracut -fv --add-drivers "nvidia nvidia-drm nvidia-modeset nvidia-uvm"
```
