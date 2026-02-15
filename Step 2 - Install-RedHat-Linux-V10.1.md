# Red Hat Enterprise Linux 10.1 Installation Guide

Complete step-by-step guide for installing Red Hat Enterprise Linux 10.1 on your LLM inference workstation, including account creation, ISO preparation, installation with custom partitioning for Docker workloads, and Active Directory domain integration.

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Part 1: Red Hat Account and Subscription](#part-1-red-hat-account-and-subscription)
- [Part 2: Download RHEL 10.1 ISO](#part-2-download-rhel-101-iso)
- [Part 3: Create Bootable USB with Balena Etcher](#part-3-create-bootable-usb-with-balena-etcher)
- [Part 4: BIOS/UEFI Configuration](#part-4-biosuefi-configuration)
- [Part 5: RHEL 10.1 Installation](#part-5-rhel-101-installation)
- [Part 6: Post-Installation Configuration](#part-6-post-installation-configuration)
- [Part 7: Red Hat Subscription Attachment](#part-7-red-hat-subscription-attachment)
- [Part 8: Active Directory Integration](#part-8-active-directory-integration)
- [Part 9: Verification and Testing](#part-9-verification-and-testing)
- [Troubleshooting](#troubleshooting)
- [Additional Resources](#additional-resources)

---

## Overview

This guide covers the complete installation process for Red Hat Enterprise Linux 10.1 on a multi-GPU LLM inference workstation. The installation includes:

- **Developer Subscription**: Free for individual developers
- **Custom Partitioning**: Optimized for Docker and LLM workloads
- **4TB NVMe Storage**: Proper allocation for containers and models
- **Active Directory Integration**: Enterprise authentication with domain.org

**Target System:**
- 4TB NVMe drive
- Multi-GPU configuration (5 GPUs)
- 256GB RAM
- AMD EPYC 7443P processor

**Time Required:** 2-3 hours (including downloads)

---

## Prerequisites

### Hardware Requirements
- ✅ Computer assembled and hardware tested
- ✅ 4TB NVMe drive installed
- ✅ Working monitor, keyboard, and mouse
- ✅ Network connectivity (Ethernet recommended)
- ✅ USB drive (16GB minimum) for installation media

### Software Requirements
- ✅ Windows, macOS, or Linux computer for preparation
- ✅ Balena Etcher (for creating bootable USB)
- ✅ Stable internet connection (minimum 10 Mbps for ISO download)

### Information Needed
- ✅ Email address for Red Hat account
- ✅ Desired hostname for the system
- ✅ Network configuration (static IP or DHCP)
- ✅ Active Directory domain credentials (if integrating)
- ✅ Active Directory domain: domain.org

---

## Part 1: Red Hat Account and Subscription

### Step 1.1: Create Red Hat Account

Red Hat provides a **free Developer Subscription** that includes access to RHEL for individual use.

**Navigate to Red Hat Developer Portal:**

1. Open your web browser
2. Go to: `https://developers.redhat.com/register`

**Complete Registration Form:**

```
Required Information:
- Email address (will be your login)
- First name
- Last name
- Company (can use "Individual" or "Self")
- Country
- Password (must be strong: 8+ characters, uppercase, lowercase, numbers)

Optional:
- Job role
- Phone number
```

3. Click **"Create my account"**
4. Check your email for verification link
5. Click verification link to activate account

**Expected Time:** 5 minutes

---

### Step 1.2: Accept Terms and Conditions

After verifying your email:

1. Log in to `https://developers.redhat.com`
2. Navigate to **"Products"** → **"Red Hat Enterprise Linux"**
3. Accept the **Terms and Conditions** for Developer Subscription
4. Subscription is automatically attached to your account

**What You Get:**
- 16 system entitlements
- Access to all RHEL versions
- Developer support resources
- No cost for non-production use

---

### Step 1.3: Verify Subscription Status

1. Log in to: `https://access.redhat.com`
2. Click **"Subscriptions"** in top navigation
3. You should see: **"Red Hat Developer Subscription for Individuals"**
4. Status: **Active**

---

## Part 2: Download RHEL 10.1 ISO

### Step 2.1: Access Download Portal

1. Navigate to: `https://access.redhat.com/downloads`
2. Log in with your Red Hat account credentials
3. Click on **"Product Downloads"**

---

### Step 2.2: Select RHEL Version

1. In the Products list, click **"Red Hat Enterprise Linux"**
2. Click **"All Red Hat Enterprise Linux Downloads"** at bottom of page
3. Select **"Red Hat Enterprise Linux 10.1"**

**Available ISO Options:**

| ISO Type | Size | Description | Use Case |
|----------|------|-------------|----------|
| **DVD ISO** | ~9.5 GB | Full installation | **Recommended - Offline install** |
| Boot ISO | ~900 MB | Network install | Requires internet during install |
| KVM Guest Image | ~1 GB | Pre-configured VM | Not for bare metal |

---

### Step 2.3: Download DVD ISO

**Select the DVD ISO:**

1. Click on **"Red Hat Enterprise Linux 10.1 Binary DVD"**
2. Architecture: **x86_64**
3. Click **"Download Now"**

**Download Details:**
- File: `rhel-10.1-x86_64-dvd.iso`
- Size: Approximately 9.5 GB
- Checksum: Provided on download page (save for verification)

**Recommended Download Location:**
- Windows: `C:\Users\[Username]\Downloads`
- macOS: `~/Downloads`
- Linux: `~/Downloads`

**Download Time Estimates:**
- 100 Mbps: ~15 minutes
- 50 Mbps: ~30 minutes
- 25 Mbps: ~60 minutes

---

### Step 2.4: Verify ISO Integrity (Optional but Recommended)

**Download SHA256 Checksum:**

1. On download page, copy the SHA256 checksum value
2. Save to text file: `rhel-10.1-sha256.txt`

**Verify on Windows (PowerShell):**

```powershell
cd Downloads
CertUtil -hashfile rhel-10.1-x86_64-dvd.iso SHA256
```

**Verify on macOS/Linux:**

```bash
cd ~/Downloads
shasum -a 256 rhel-10.1-x86_64-dvd.iso
```

**Compare output with checksum from Red Hat website. They must match exactly.**

---

## Part 3: Create Bootable USB with Balena Etcher

### Step 3.1: Download Balena Etcher

**Navigate to Balena Etcher website:**

1. Go to: `https://etcher.balena.io`
2. Download version for your operating system:
   - Windows: `.exe` installer
   - macOS: `.dmg` file
   - Linux: `.AppImage` file

**Install Balena Etcher:**

- **Windows**: Run `.exe` and follow installer
- **macOS**: Open `.dmg` and drag to Applications
- **Linux**: Make AppImage executable:
  ```bash
  chmod +x balenaEtcher*.AppImage
  ```

---

### Step 3.2: Prepare USB Drive

**⚠️ WARNING: All data on USB drive will be erased!**

**Requirements:**
- USB drive: 16GB minimum (32GB recommended)
- USB 3.0 or higher (for faster installation)
- Empty or backed up (all data will be lost)

**Insert USB Drive:**

1. Insert USB drive into your computer
2. **Back up any important data** from USB drive
3. Note drive letter/device name:
   - Windows: Typically `D:`, `E:`, or `F:`
   - macOS: `/Volumes/[USB_NAME]`
   - Linux: `/dev/sdX` (use `lsblk` to identify)

---

### Step 3.3: Flash ISO to USB with Balena Etcher

**Launch Balena Etcher:**

1. Open Balena Etcher application

**Step 1: Select Image**

2. Click **"Flash from file"**
3. Navigate to downloads folder
4. Select: `rhel-10.1-x86_64-dvd.iso`
5. Click **"Open"**

**Step 2: Select Target**

6. Click **"Select target"**
7. Choose your USB drive from list
   - **Verify** you selected correct drive!
   - Wrong selection will erase wrong drive
8. Click **"Select (1)"** to confirm

**Step 3: Flash**

9. Click **"Flash!"**
10. Enter administrator password when prompted
11. Wait for flashing process (5-10 minutes)

**Progress Indicators:**
```
Flashing...    [██████░░░░░░░░] 45%
Validating...  [████████████░░] 85%
```

12. When complete, you'll see: **"Flash Complete!"**
13. Click **"OK"**
14. **Safely eject USB drive**

**Expected Time:** 10-15 minutes

---

## Part 4: BIOS/UEFI Configuration

### Step 4.1: Access BIOS/UEFI

1. **Insert bootable USB** into target computer
2. **Power on** the system
3. **Press BIOS key** during POST:
   - ASRock motherboards: **F2** or **DEL**
   - Common alternatives: F1, F10, F12, ESC

**If you miss the key press:**
- Restart and try again
- Look for "Press X to enter Setup" message

---

### Step 4.2: Configure Boot Order

**Navigate to Boot Menu:**

1. Use arrow keys to navigate BIOS
2. Find **"Boot"** tab or **"Boot Priority"** section

**Set Boot Order:**

3. Move **USB device** to **first position**
4. Typical order:
   ```
   1st Boot Device: USB Hard Disk (or UEFI: USB_DEVICE_NAME)
   2nd Boot Device: NVMe Drive
   3rd Boot Device: Network Boot
   ```

**Configure UEFI Settings (if applicable):**

5. **Secure Boot**: Disabled (recommended for RHEL 10.1 with custom drivers)
6. **Boot Mode**: UEFI (not Legacy/CSM)
7. **Fast Boot**: Disabled

---

### Step 4.3: Save and Reboot

1. Press **F10** (or navigate to "Save & Exit")
2. Select **"Save Changes and Reset"**
3. Press **Enter** to confirm

**System will reboot and boot from USB**

---

## Part 5: RHEL 10.1 Installation

### Step 5.1: Boot from Installation Media

**RHEL Boot Menu:**

After reboot, you'll see the Red Hat installer boot menu:

```
Install Red Hat Enterprise Linux 10.1
Test this media & install Red Hat Enterprise Linux 10.1
Troubleshooting -->
```

1. Select **"Install Red Hat Enterprise Linux 10.1"**
2. Press **Enter**

**Initial boot takes 30-60 seconds**

---

### Step 5.2: Language and Keyboard Selection

**Welcome Screen:**

1. Select **Language**: English (United States)
2. Click **"Continue"**

**Time Required:** 1 minute

---

### Step 5.3: Installation Summary Screen

You'll see the main installation dashboard with multiple configuration sections:

```
INSTALLATION SUMMARY

LOCALIZATION
  [!] Keyboard: English (US)
  [!] Language Support: English (United States)
  [!] Time & Date: America/New_York

SOFTWARE
  [!] Installation Source: Local media
  [!] Software Selection: Server with GUI

SYSTEM
  [!] Installation Destination: No disks selected
  [!] Network & Host Name: Not configured
  [!] Root Password: Not set
  [!] User Creation: No user created
```

**Items with [!] require configuration**

---

### Step 5.4: Time & Date Configuration

1. Click **"Time & Date"**
2. Select your region and city
   - Example: **America/New_York**
3. **Network Time**: Toggle **ON** (recommended)
   - Automatically syncs with NTP servers
4. Click **"Done"**

---

### Step 5.5: Software Selection

1. Click **"Software Selection"**
2. **Base Environment**: Select **"Server with GUI"**
   - Provides desktop environment for easier management
   - Essential for monitoring GPUs visually

**Add-Ons for Selected Environment** (select these):
- [x] Debugging Tools
- [x] Development Tools (already selected for NVIDIA drivers)
- [x] System Tools
- [x] Network Servers (optional)

3. Click **"Done"**

**Note:** Additional software will be installed post-installation.

---

### Step 5.6: Installation Destination (Critical - Custom Partitioning)

This section is **critical** for Docker and LLM workloads.

**⚠️ IMPORTANT: Custom partition sizing for Docker containers and large models**

1. Click **"Installation Destination"**
2. Select your **4TB NVMe drive** (should show as 3.7 TB)
3. **Storage Configuration**: Select **"Custom"**
4. Click **"Done"**

**Manual Partitioning Screen Opens**

---

### Step 5.7: Create Partition Scheme

**Select Partitioning Scheme:**

1. **New RHEL Installation**: Click dropdown
2. Select: **"Standard Partition"** or **"LVM"** (LVM recommended)
3. Click **"Click here to create them automatically"**

**Auto-created partitions appear - now we customize them**

---

### Step 5.8: Customize Partitions for LLM/Docker Workload

**Delete and recreate with proper sizes for 4TB drive:**

#### Partition 1: /boot (EFI System)

**Already created - leave as is:**
- **Mount Point**: `/boot/efi`
- **Size**: 600 MB
- **File System**: EFI System Partition

---

#### Partition 2: /boot

**Already created - leave as is:**
- **Mount Point**: `/boot`
- **Size**: 1 GB (1024 MB)
- **File System**: xfs

---

#### Partition 3: swap (Critical - Large for LLM workloads)

**Modify existing swap:**

1. Select `swap` partition
2. **Desired Capacity**: `256 GB` (256000 MB)
   - Large swap for memory-intensive LLM operations
   - Allows safe handling of out-of-memory scenarios
3. Click **"Update Settings"**

**Why 256GB swap:**
- System has 256GB RAM
- Swap = 1× RAM for heavy workloads
- Allows emergency memory overflow
- Supports hibernation (optional)

---

#### Partition 4: / (Root)

**Modify existing root:**

1. Select `/` partition
2. **Desired Capacity**: `2.5 TB` (2500 GB = 2,560,000 MB)
   - OS and applications
   - User home directories
   - System files
3. **File System**: `xfs` (recommended for RHEL)
4. Click **"Update Settings"**

---

#### Partition 5: /var (Critical - Docker and containers)

**Create new /var partition:**

1. Click **"+" button** to add new partition
2. **Mount Point**: `/var`
3. **Desired Capacity**: `500 GB` (512,000 MB)
   - Docker images: 100-200 GB
   - Container volumes: 100-200 GB
   - Logs and temporary files: 100 GB
4. **File System**: `xfs`
5. Click **"Add mount point"**

**Why separate /var with 500GB:**
- Docker stores images/containers in `/var/lib/docker`
- Container data can grow very large
- Prevents container storage from filling root partition
- Isolates logs and variable data
- Critical for production Docker workloads

---

#### Partition 6: /home (User data and models)

**Create new /home partition:**

1. Click **"+"** to add partition
2. **Mount Point**: `/home`
3. **Desired Capacity**: Fill remaining space (~650 GB)
   - User directories
   - Downloaded models
   - Development projects
   - Datasets
4. **File System**: `xfs`
5. Click **"Add mount point"**

---

### Step 5.9: Review Final Partition Layout

**Verify your partition scheme:**

```
Device                 Mount Point    Size        Type
/dev/nvme0n1p1        /boot/efi      600 MB      vfat
/dev/nvme0n1p2        /boot          1 GB        xfs
/dev/nvme0n1p3        swap           256 GB      swap
/dev/nvme0n1p4        /              2.5 TB      xfs
/dev/nvme0n1p5        /var           500 GB      xfs
/dev/nvme0n1p6        /home          ~650 GB     xfs
-----------------------------------------------------------
Total:                               ~3.9 TB     (4TB drive)
```

**Partition Summary:**
- **Total drive**: 4TB (3.7 TB usable)
- **OS and apps** (/): 2.5 TB
- **Docker and containers** (/var): 500 GB
- **Swap**: 256 GB
- **User data and models** (/home): ~650 GB
- **Boot partitions**: ~1.6 GB

---

### Step 5.10: Accept Changes

1. Click **"Done"** (top left)
2. **Summary of Changes** dialog appears
3. Review changes carefully
4. Click **"Accept Changes"**

**⚠️ WARNING: This will format the drive. All data will be lost.**

---

### Step 5.11: Network & Host Name

**Configure networking:**

1. Click **"Network & Host Name"**
2. **Host name**: Enter your desired hostname
   - Example: `llm-inference-01.domain.org`
   - Format: `hostname.domain.org`
3. Click **"Apply"**

**Configure Network Interface:**

4. In left panel, select **Ethernet connection**
5. Toggle switch to **ON** (should turn green)

**For Static IP (recommended for servers):**

6. Click **"Configure..."**
7. Go to **"IPv4 Settings"** tab
8. **Method**: Select **"Manual"**
9. Click **"Add"** and enter:
   - **Address**: `192.168.1.100` (example - use your network)
   - **Netmask**: `255.255.255.0`
   - **Gateway**: `192.168.1.1` (your router)
   - **DNS servers**: `192.168.1.10,192.168.1.11` (your AD DNS servers)
10. Click **"Save"**

**For DHCP (automatic):**

6. Leave as **DHCP** (default)
7. Still configure DNS to point to AD servers

11. Click **"Done"**

**Important for Active Directory:**
- DNS must point to Active Directory domain controllers
- Example: `192.168.1.10` and `192.168.1.11`
- Do NOT use public DNS (8.8.8.8) if joining AD

---

### Step 5.12: Root Password

**Set root password:**

1. Click **"Root Password"**
2. Enter a **strong password**:
   - Minimum 8 characters
   - Mix of uppercase, lowercase, numbers, symbols
   - Don't use dictionary words
3. **Confirm password** (re-enter)
4. If weak password: Click **"Done"** twice to override

**Password Requirements:**
```
Weak:     admin123
Moderate: Admin@2026
Strong:   xK9#mP2!vL5@wN8q
```

5. Click **"Done"**

**⚠️ IMPORTANT: Save this password securely!**

---

### Step 5.13: User Creation

**Create administrative user:**

1. Click **"User Creation"**
2. **Full name**: `Administrator` (or your name)
3. **User name**: `admin` (or your preference)
4. **Password**: Enter strong password
5. **Confirm password**: Re-enter
6. **Make this user administrator**: ✓ Check this box
   - Grants sudo access
7. **Require a password to use this account**: ✓ Keep checked

8. Click **"Done"**

---

### Step 5.14: Begin Installation

**Verify all items configured:**

```
✓ Keyboard: Configured
✓ Language Support: Configured
✓ Time & Date: Configured
✓ Installation Source: Configured
✓ Software Selection: Server with GUI
✓ Installation Destination: Custom partitions configured
✓ Network & Host Name: Configured
✓ Root Password: Set
✓ User Creation: User created
```

1. Click **"Begin Installation"** (blue button, bottom right)

**Installation Progress:**

```
Installing Red Hat Enterprise Linux 10.1

Installing software packages...
[████████████░░░░░░░░░░░░] 45%

Time remaining: 15 minutes (varies by hardware)
```

**Installation time:**
- Typical: 20-30 minutes
- NVMe SSD: 15-20 minutes
- SATA SSD: 30-45 minutes

**During installation:**
- Progress bar shows package installation
- You can't interact with installer
- Do not power off system

---

### Step 5.15: Installation Complete

**When finished, you'll see:**

```
Complete!
Red Hat Enterprise Linux is now successfully installed.

[ Reboot System ]
```

1. Remove USB installation drive
2. Click **"Reboot System"**

**System will reboot into installed RHEL 10.1**

---

## Part 6: Post-Installation Configuration

### Step 6.1: Initial Boot and License Agreement

**First boot after installation:**

1. System boots to RHEL
2. **Initial Setup** screen appears
3. **License Information**: Click to open
4. **Accept license agreement**: ✓ Check box
5. Click **"Done"**
6. Click **"Finish Configuration"**

---

### Step 6.2: First Login

**Login Screen:**

1. Click on your username
2. Enter password
3. Press **Enter**

**GNOME Desktop loads**

---

### Step 6.3: Initial GNOME Setup (Optional)

**Welcome to RHEL wizard:**

1. **Privacy**: Configure location services (optional)
2. **Online Accounts**: Skip (click **"Skip"**)
3. **Ready to Go**: Click **"Start Using Red Hat Enterprise Linux"**

**Desktop environment is now ready**

---

## Part 7: Red Hat Subscription Attachment

### Step 7.1: Register System with Red Hat

**Open Terminal:**

- Click **"Activities"** → Search for **"Terminal"**
- Or press **Ctrl+Alt+T**

**Register system:**

```bash
sudo subscription-manager register --username YOUR_REDHAT_EMAIL
```

**Enter:**
1. Your Red Hat account password when prompted
2. Your user password for `sudo`

**Expected output:**
```
The system has been registered with ID: xxxxxxxxxx
The registered system name is: llm-inference-01.domain.org
```

---

### Step 7.2: Attach Subscription

**Auto-attach subscription:**

```bash
sudo subscription-manager attach --auto
```

**Expected output:**
```
Installed Product Current Status:
Product Name: Red Hat Enterprise Linux for x86_64
Status:       Subscribed
```

---

### Step 7.3: Verify Subscription

**Check subscription status:**

```bash
sudo subscription-manager status
```

**Expected output:**
```
+-------------------------------------------+
   System Status Details
+-------------------------------------------+
Overall Status: Current

System Purpose Status: Matched
```

---

### Step 7.4: Enable Required Repositories

**Enable base repositories:**

```bash
# Enable BaseOS repository
sudo subscription-manager repos --enable=rhel-10-for-x86_64-baseos-rpms

# Enable AppStream repository
sudo subscription-manager repos --enable=rhel-10-for-x86_64-appstream-rpms

# Enable CodeReady Builder (for development)
sudo subscription-manager repos --enable=codeready-builder-for-rhel-10-x86_64-rpms
```

**Verify repositories:**

```bash
sudo dnf repolist
```

**Expected output:**
```
repo id                                     repo name
rhel-10-for-x86_64-baseos-rpms             Red Hat Enterprise Linux 10 for x86_64 - BaseOS
rhel-10-for-x86_64-appstream-rpms          Red Hat Enterprise Linux 10 for x86_64 - AppStream
codeready-builder-for-rhel-10-x86_64-rpms  CodeReady Linux Builder for RHEL 10
```

---

### Step 7.5: Update System

**Perform initial system update:**

```bash
# Update all packages
sudo dnf update -y
```

**This may take 10-20 minutes depending on connection speed**

**Reboot after update (recommended):**

```bash
sudo systemctl reboot
```

---

## Part 8: Active Directory Integration

### Step 8.1: Prerequisites for AD Integration

**Network Requirements:**

1. **DNS Configuration**: System must use AD DNS servers
2. **Network Connectivity**: Verify connection to domain controllers
3. **Time Synchronization**: System time must match AD

**Verify DNS points to AD:**

```bash
cat /etc/resolv.conf
```

**Should show:**
```
nameserver 192.168.1.10  # AD Domain Controller 1
nameserver 192.168.1.11  # AD Domain Controller 2
search domain.org
```

**If not correct, edit:**

```bash
sudo nmcli connection modify "System eth0" ipv4.dns "192.168.1.10 192.168.1.11"
sudo nmcli connection modify "System eth0" ipv4.dns-search "domain.org"
sudo nmcli connection up "System eth0"
```

---

### Step 8.2: Install Required Packages

**Install AD integration packages:**

```bash
sudo dnf install -y \
    realmd \
    sssd \
    oddjob \
    oddjob-mkhomedir \
    adcli \
    samba-common-tools \
    krb5-workstation \
    openldap-clients \
    policycoreutils-python-utils
```

**Package descriptions:**
- `realmd`: Domain discovery and join utility
- `sssd`: System Security Services Daemon
- `oddjob-mkhomedir`: Auto-create home directories
- `adcli`: Active Directory command-line tool
- `krb5-workstation`: Kerberos client tools
- `samba-common-tools`: Samba utilities
- `openldap-clients`: LDAP client utilities

---

### Step 8.3: Configure System Hostname

**Set fully qualified hostname:**

```bash
# Set hostname
sudo hostnamectl set-hostname llm-inference-01.domain.org

# Verify
hostnamectl
```

**Expected output:**
```
   Static hostname: llm-inference-01.domain.org
         Icon name: computer-desktop
           Chassis: desktop
  Operating System: Red Hat Enterprise Linux 10.1
```

**Update /etc/hosts:**

```bash
sudo nano /etc/hosts
```

**Add/modify:**
```
127.0.0.1   localhost localhost.localdomain
192.168.1.100   llm-inference-01.domain.org llm-inference-01

# Remove any 127.0.1.1 entries for hostname
```

Save: **Ctrl+O**, Enter, **Ctrl+X**

---

### Step 8.4: Verify Time Synchronization

**AD requires synchronized time (critical for Kerberos):**

```bash
# Check current time
timedatectl

# Enable NTP synchronization
sudo timedatectl set-ntp true

# Verify synchronization
sudo systemctl status chronyd
```

**Time difference must be less than 5 minutes from AD**

---

### Step 8.5: Test DNS Resolution to AD

**Verify DNS records:**

```bash
# Test domain
nslookup domain.org

# Test domain controllers
nslookup dc1.domain.org
nslookup dc2.domain.org

# Test SRV records (critical for AD)
dig -t SRV _ldap._tcp.domain.org
dig -t SRV _kerberos._tcp.domain.org
```

**SRV records should return domain controller addresses**

---

### Step 8.6: Discover Active Directory Domain

**Use realmd to discover domain:**

```bash
sudo realm discover domain.org
```

**Expected output:**
```
domain.org
  type: kerberos
  realm-name: DOMAIN.ORG
  domain-name: domain.org
  configured: no
  server-software: active-directory
  client-software: sssd
  required-package: oddjob
  required-package: oddjob-mkhomedir
  required-package: sssd
  required-package: adcli
  required-package: samba-common-tools
```

**If discovery fails:**
- Verify DNS configuration
- Check network connectivity to domain controllers
- Verify firewall rules (ports 88, 389, 636, 464, 3268)

---

### Step 8.7: Join System to Active Directory Domain

**Join the domain:**

```bash
sudo realm join -U administrator domain.org
```

**You'll be prompted:**
```
Password for administrator:
```

**Enter your AD administrator password**

**Successful join output:**
```
 * Resolving: _ldap._tcp.domain.org
 * Performing LDAP DSE lookup on: 192.168.1.10
 * Successfully enrolled machine in realm
```

**Alternative - join with specific OU:**

```bash
# Join to specific organizational unit
sudo realm join -U administrator \
    --computer-ou="OU=Linux Servers,OU=Servers,DC=domain,DC=org" \
    domain.org
```

---

### Step 8.8: Verify Domain Join

**Check realm status:**

```bash
sudo realm list
```

**Expected output:**
```
domain.org
  type: kerberos
  realm-name: DOMAIN.ORG
  domain-name: domain.org
  configured: kerberos-member
  server-software: active-directory
  client-software: sssd
  required-package: oddjob
  required-package: oddjob-mkhomedir
  required-package: sssd
  required-package: adcli
  required-package: samba-common-tools
  login-formats: %U@domain.org
  login-policy: allow-realm-logins
```

**Key indicator:** `configured: kerberos-member`

---

### Step 8.9: Configure SSSD for Optimal Performance

**Edit SSSD configuration:**

```bash
sudo nano /etc/sssd/sssd.conf
```

**Optimize configuration:**

```ini
[sssd]
domains = domain.org
config_file_version = 2
services = nss, pam, ssh

[domain/domain.org]
# Domain configuration
ad_domain = domain.org
krb5_realm = DOMAIN.ORG
realmd_tags = manages-system joined-with-adcli
cache_credentials = True
id_provider = ad
krb5_store_password_if_offline = True
default_shell = /bin/bash
ldap_id_mapping = True

# Allow simple usernames (no domain required)
use_fully_qualified_names = False

# Home directory configuration
fallback_homedir = /home/%u
override_homedir = /home/%u

# Performance tuning
ldap_referrals = false
ldap_id_mapping = True

# Enumerate users (useful for small domains)
enumerate = False

# Access control - limit to specific groups
# access_provider = simple
# simple_allow_groups = linux-admins, llm-users
```

**Save:** Ctrl+O, Enter, Ctrl+X

**Set proper permissions:**

```bash
sudo chmod 600 /etc/sssd/sssd.conf
sudo chown root:root /etc/sssd/sssd.conf
```

---

### Step 8.10: Configure PAM for Home Directory Creation

**Ensure home directories are auto-created:**

```bash
sudo authselect select sssd with-mkhomedir --force
```

**Or manually enable:**

```bash
sudo systemctl enable --now oddjobd
```

---

### Step 8.11: Restart SSSD Service

**Restart SSSD to apply changes:**

```bash
# Restart SSSD
sudo systemctl restart sssd

# Enable SSSD at boot
sudo systemctl enable sssd

# Check status
sudo systemctl status sssd
```

**Expected status:**
```
● sssd.service - System Security Services Daemon
   Loaded: loaded (/usr/lib/systemd/system/sssd.service; enabled)
   Active: active (running) since ...
```

---

### Step 8.12: Test AD User Authentication

**Verify AD user lookup:**

```bash
# Look up AD user (replace with actual AD username)
id username

# Look up AD user with domain
id username@domain.org

# Get user information
getent passwd username
```

**Expected output:**
```
uid=1234567890(username) gid=1234567890(domain users) groups=1234567890(domain users),1234567891(linux-admins)
```

**Test AD group lookup:**

```bash
getent group "domain users"
getent group "linux-admins"
```

---

### Step 8.13: Test SSH Login with AD Credentials

**From another machine, test SSH:**

```bash
ssh username@192.168.1.100
```

**Or test locally:**

```bash
su - username
```

**Enter AD password when prompted**

**Successful login creates home directory automatically:**
```
Creating home directory for username.
username@llm-inference-01:~$
```

---

### Step 8.14: Configure Sudo Access for AD Groups

**Grant sudo access to AD group:**

```bash
sudo visudo -f /etc/sudoers.d/ad-admins
```

**Add:**
```bash
# Allow AD linux-admins group full sudo access
%linux-admins ALL=(ALL) ALL

# Or without password (use with caution)
# %linux-admins ALL=(ALL) NOPASSWD: ALL
```

**Save:** Ctrl+X, Y, Enter

**Test sudo access:**

```bash
# As AD user
sudo whoami
```

Should output: `root`

---

## Part 9: Verification and Testing

### Step 9.1: System Verification

**Verify all core components:**

```bash
# Check RHEL version
cat /etc/redhat-release

# Check subscription
sudo subscription-manager status

# Check hostname
hostnamectl

# Check network
ip addr show
ping -c 4 google.com

# Check DNS
nslookup domain.org

# Check AD membership
sudo realm list
```

---

### Step 9.2: Partition Verification

**Verify partition layout:**

```bash
# Show disk usage
df -h

# Show partition table
sudo fdisk -l /dev/nvme0n1

# Verify swap
sudo swapon --show
free -h
```

**Expected output:**
```
Filesystem      Size  Used Avail Use% Mounted on
/dev/nvme0n1p4  2.5T  8.2G  2.5T   1% /
/dev/nvme0n1p5  500G  1.5G  499G   1% /var
/dev/nvme0n1p6  650G  2.1G  648G   1% /home
/dev/nvme0n1p2  1.0G  250M  750M  25% /boot
/dev/nvme0n1p1  600M  12M   588M   2% /boot/efi
```

**Verify swap:**
```
NAME           TYPE  SIZE USED PRIO
/dev/nvme0n1p3 partition 256G   0B   -2
```

---

### Step 9.3: AD Integration Verification

**Complete AD test:**

```bash
# Test Kerberos
kinit administrator@DOMAIN.ORG
klist

# Test LDAP search
ldapsearch -x -H ldap://dc1.domain.org -b "DC=domain,DC=org" "(sAMAccountName=username)"

# Test group membership
groups username

# Test SSH key from AD (if configured)
getent sshkey username
```

---

### Step 9.4: Security Verification

**Check firewall status:**

```bash
sudo firewall-cmd --state
sudo firewall-cmd --list-all
```

**Check SELinux:**

```bash
getenforce
# Should show: Enforcing
```

---

## Troubleshooting

### Issue: Cannot Join AD Domain

**Symptoms:**
- `realm join` fails with authentication error
- "Couldn't authenticate to active directory" message

**Solutions:**

**1. Verify DNS:**
```bash
# DNS must resolve AD domain
nslookup domain.org
dig -t SRV _ldap._tcp.domain.org
```

**2. Check time sync:**
```bash
# Time must be within 5 minutes of AD
timedatectl
sudo chronyd -q 'server dc1.domain.org iburst'
```

**3. Verify network connectivity:**
```bash
# Test LDAP port
telnet dc1.domain.org 389

# Test Kerberos port
telnet dc1.domain.org 88
```

**4. Check AD permissions:**
- Verify user has rights to join computers to domain
- Check computer account quota in AD

**5. Try manual Kerberos test:**
```bash
kinit administrator@DOMAIN.ORG
klist
```

---

### Issue: AD User Login Fails

**Symptoms:**
- Can't SSH or login with AD credentials
- "Authentication failure" message

**Solutions:**

**1. Verify user lookup:**
```bash
id username
getent passwd username
```

**2. Check SSSD status:**
```bash
sudo systemctl status sssd
sudo journalctl -u sssd -f
```

**3. Clear SSSD cache:**
```bash
sudo systemctl stop sssd
sudo rm -rf /var/lib/sss/db/*
sudo systemctl start sssd
```

**4. Verify PAM configuration:**
```bash
authselect current
sudo authselect select sssd with-mkhomedir --force
```

---

### Issue: Home Directory Not Created

**Symptoms:**
- AD user logs in but no home directory exists
- "Could not chdir to home directory" error

**Solutions:**

```bash
# Verify oddjobd is running
sudo systemctl status oddjobd
sudo systemctl enable --now oddjobd

# Manually create home directory
sudo mkhomedir_helper username

# Check PAM configuration
grep mkhomedir /etc/pam.d/system-auth
# Should contain: session optional pam_oddjob_mkhomedir.so
```

---

### Issue: Slow Login with AD

**Symptoms:**
- Login takes 30+ seconds
- Slow response for `id` command

**Solutions:**

**1. Disable enumeration:**
```bash
sudo nano /etc/sssd/sssd.conf
# Set: enumerate = False
sudo systemctl restart sssd
```

**2. Reduce DNS timeout:**
```bash
sudo nano /etc/sssd/sssd.conf
# Add under [domain/domain.org]:
dns_resolver_timeout = 5
ldap_network_timeout = 3
sudo systemctl restart sssd
```

**3. Configure SSSD caching:**
```bash
sudo nano /etc/sssd/sssd.conf
# Add:
entry_cache_timeout = 300
sudo systemctl restart sssd
```

---

### Issue: Partition Not Mounted

**Symptoms:**
- `/var` or `/home` shows wrong size
- "No space left on device" on root

**Solutions:**

```bash
# Check mounts
mount | grep nvme

# Check /etc/fstab
cat /etc/fstab

# Manually mount if missing
sudo mount -a

# Regenerate fstab if corrupted
sudo blkid
# Add missing entries to /etc/fstab
```

---

## Additional Resources

### Red Hat Documentation

- [RHEL 10.1 Installation Guide](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/10/html/performing_a_standard_rhel_installation/)
- [Integrating RHEL with Active Directory](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/10/html/integrating_rhel_systems_directly_with_windows_active_directory/)
- [Storage Administration Guide](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/10/html/managing_storage_devices/)
- [Security Hardening Guide](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/10/html/security_hardening/)

### Active Directory Integration

- [SSSD Configuration](https://sssd.io/docs/users/ad_provider.html)
- [Realmd Documentation](https://www.freedesktop.org/software/realmd/)
- [Kerberos Configuration](https://web.mit.edu/kerberos/krb5-latest/doc/)

### Community Resources

- [Red Hat Customer Portal](https://access.redhat.com)
- [Red Hat Developer Forums](https://developers.redhat.com/forums)
- [RHEL Subreddit](https://reddit.com/r/redhat)

---

## Quick Reference Commands

### Subscription Management
```bash
# Register system
sudo subscription-manager register --username EMAIL

# Attach subscription
sudo subscription-manager attach --auto

# Check status
sudo subscription-manager status

# List repositories
sudo dnf repolist

# Enable repository
sudo subscription-manager repos --enable=REPO_ID
```

### Active Directory
```bash
# Discover domain
sudo realm discover domain.org

# Join domain
sudo realm join -U administrator domain.org

# Leave domain
sudo realm leave domain.org

# List domains
sudo realm list

# Test user lookup
id username
getent passwd username

# Check SSSD status
sudo systemctl status sssd

# Clear SSSD cache
sudo sss_cache -E
```

### System Management
```bash
# Check partitions
df -h
sudo fdisk -l

# Check swap
free -h
sudo swapon --show

# Update system
sudo dnf update

# Check services
sudo systemctl status SERVICE_NAME

# View logs
sudo journalctl -u SERVICE_NAME -f
```

---

**Installation Complete!** 🎉

Your RHEL 10.1 system is now:
- ✅ Installed with optimized partitioning for Docker/LLM workloads
- ✅ Registered with Red Hat subscription
- ✅ Integrated with Active Directory domain (domain.org)
- ✅ Ready for NVIDIA driver installation
- ✅ Ready for Docker and vLLM deployment

**Next Steps:**
1. Install NVIDIA drivers (see: NVIDIA-driver-installation.md)
2. Run step2.sh script for LLM software stack
3. Deploy Docker containers with Open WebUI and vLLM

---

**Last Updated:** February 2026  
**RHEL Version:** 10.1  
**Domain:** domain.org  
**Storage:** 4TB NVMe with Docker-optimized partitioning
