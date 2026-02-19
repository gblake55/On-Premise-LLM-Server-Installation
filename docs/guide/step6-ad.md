# Red Hat Enterprise Linux 10.1 Active Directory Integration Guide

## Server Information
- **Hostname:** bert
- **Operating System:** Red Hat Enterprise Linux 10.1
- **Target Domain:** mycompany.org (placeholder for your company)
- **Domain Account:** henryf
- **Domain Password:** password123 *(placeholder for documentation)*

## Network Configuration Change
- **Current IP:** 198.186.1.1
- **New IP:** 10.0.13.35
- **Gateway:** 10.0.13.1
- **Subnet Mask:** 255.255.255.0 *(assumed - adjust as needed)*

---

## Prerequisites

Before beginning, ensure you have:
- Root or sudo access to the server
- Network connectivity to the Active Directory domain controllers
- DNS servers that can resolve the mycompany.org domain
- Active Directory domain administrator credentials or delegated permissions

---

## Part 1: Network Configuration Change

### Step 1: Identify Current Network Interface

```bash
# List network interfaces
nmcli device status

# Or use ip command
ip addr show
```

Note the interface name (e.g., `ens160`, `eth0`, `enpXsY`).

### Step 2: Backup Current Network Configuration

```bash
# Create backup directory
sudo mkdir -p /root/network-backup

# Export current network configuration
sudo nmcli connection show > /root/network-backup/connections-backup.txt
sudo ip addr show > /root/network-backup/ip-config-backup.txt
sudo ip route show > /root/network-backup/routes-backup.txt
```

### Step 3: Configure New IP Address

Replace `<interface-name>` with your actual interface name (e.g., `ens160`).

```bash
# Identify the connection name
sudo nmcli connection show

# Modify the connection with new IP settings
sudo nmcli connection modify <interface-name> \
  ipv4.addresses 10.0.13.35/24 \
  ipv4.gateway 10.0.13.1 \
  ipv4.method manual

# Set DNS servers (use your Active Directory DNS servers)
# Replace with actual DNS server IPs
sudo nmcli connection modify <interface-name> \
  ipv4.dns "10.0.13.10 10.0.13.11"

# Set DNS search domain
sudo nmcli connection modify <interface-name> \
  ipv4.dns-search mycompany.org

# Bring down and up the connection to apply changes
sudo nmcli connection down <interface-name>
sudo nmcli connection up <interface-name>
```

### Step 4: Verify Network Configuration

```bash
# Check IP address
ip addr show

# Check routing table
ip route show

# Test gateway connectivity
ping -c 4 10.0.13.1

# Test DNS resolution
nslookup mycompany.org

# Test internet connectivity
ping -c 4 8.8.8.8
```

### Step 5: Verify DNS Resolution for Active Directory

```bash
# Check domain controller discovery
nslookup mycompany.org

# Check for SRV records (essential for AD integration)
nslookup -type=SRV _ldap._tcp.mycompany.org

# Check Kerberos SRV records
nslookup -type=SRV _kerberos._tcp.mycompany.org
```

**Important:** If DNS queries fail, verify your DNS server settings and ensure they point to Active Directory domain controllers.

---

## Part 2: Active Directory Integration

### Step 6: Install Required Packages

```bash
# Update system packages
sudo dnf update -y

# Install required packages for AD integration
sudo dnf install -y \
  realmd \
  sssd \
  sssd-tools \
  sssd-ad \
  adcli \
  samba-common-tools \
  oddjob \
  oddjob-mkhomedir \
  krb5-workstation
```

### Step 7: Discover the Active Directory Domain

```bash
# Discover the domain
sudo realm discover mycompany.org
```

**Expected Output:**
```
mycompany.org
  type: kerberos
  realm-name: MYCOMPANY.ORG
  domain-name: mycompany.org
  configured: no
  server-software: active-directory
  client-software: sssd
  required-package: sssd-tools
  required-package: sssd
  required-package: adcli
  required-package: samba-common-tools
```

If the discovery fails, verify:
- DNS configuration points to AD DNS servers
- Firewall allows necessary traffic
- Network connectivity to domain controllers

### Step 8: Configure Time Synchronization

Active Directory requires time synchronization (within 5 minutes tolerance).

```bash
# Install chrony if not already installed
sudo dnf install -y chrony

# Configure chrony to sync with domain controller or NTP server
sudo vi /etc/chrony.conf

# Add or modify to include your domain controller or time server
# Example:
# server 10.0.13.10 iburst

# Restart chronyd service
sudo systemctl restart chronyd

# Enable chronyd to start at boot
sudo systemctl enable chronyd

# Verify time synchronization
sudo chronyc sources -v
sudo timedatectl status
```

### Step 9: Join the Active Directory Domain

```bash
# Join the domain using the provided credentials
sudo realm join --user=henryf mycompany.org
```

When prompted, enter the password: `password123`

**Alternative method with explicit parameters:**

```bash
sudo realm join --user=henryf \
  --computer-ou="OU=Servers,DC=mycompany,DC=org" \
  --verbose \
  mycompany.org
```

**Note:** Replace the `--computer-ou` parameter with the appropriate Organizational Unit path if needed, or omit it to use the default Computers container.

### Step 10: Verify Domain Join

```bash
# Check realm status
sudo realm list

# Verify SSSD configuration
sudo cat /etc/sssd/sssd.conf

# Test domain connectivity
sudo sssctl domain-status mycompany.org

# Verify Kerberos ticket
sudo kinit henryf@MYCOMPANY.ORG
sudo klist
```

### Step 11: Configure SSSD (Optional Enhancements)

Edit the SSSD configuration for enhanced functionality:

```bash
sudo vi /etc/sssd/sssd.conf
```

Add or modify these settings:

```ini
[sssd]
domains = mycompany.org
config_file_version = 2
services = nss, pam

[domain/mycompany.org]
default_shell = /bin/bash
krb5_store_password_if_offline = True
cache_credentials = True
krb5_realm = mycompany.org
realmd_tags = manages-system joined-with-adcli
id_provider = ad
fallback_homedir = /home/%u@%d
ad_domain = mycompany.org
use_fully_qualified_names = False
ldap_id_mapping = True
access_provider = ad
```

**Key Configuration Options:**
- `use_fully_qualified_names = False` - Allows login with just username instead of username@domain
- `fallback_homedir = /home/%u@%d` - Sets home directory location
- `cache_credentials = True` - Allows offline authentication

After editing, restart SSSD:

```bash
sudo systemctl restart sssd
sudo systemctl enable sssd
```

### Step 12: Configure Automatic Home Directory Creation

```bash
# Enable and start oddjobd service
sudo systemctl enable oddjobd
sudo systemctl start oddjobd

# Verify PAM configuration includes mkhomedir
sudo authselect current

# If needed, enable with-mkhomedir
sudo authselect select sssd with-mkhomedir --force
```

### Step 13: Test Domain User Authentication

```bash
# Test user information retrieval
id henryf
getent passwd henryf

# Test domain group information
getent group "domain users"

# Test SSH or local login (if SSH is configured)
# From another terminal or system:
ssh henryf@10.0.13.35
```

### Step 14: Configure Sudo Access for Domain Users (Optional)

To grant sudo privileges to domain users or groups:

```bash
# Edit sudoers file
sudo visudo

# Add domain users or groups
# For individual user:
henryf ALL=(ALL) ALL

# For a domain group (use %):
%domain\ admins ALL=(ALL) ALL
```

**Or create a separate sudoers file:**

```bash
sudo vi /etc/sudoers.d/domain_admins

# Add content:
%domain\ admins ALL=(ALL) ALL

# Set proper permissions
sudo chmod 0440 /etc/sudoers.d/domain_admins
```

### Step 15: Configure Firewall (If Applicable)

Ensure the firewall allows necessary AD traffic:

```bash
# Check firewall status
sudo firewall-cmd --state

# Allow required services
sudo firewall-cmd --permanent --add-service=kerberos
sudo firewall-cmd --permanent --add-service=ldap
sudo firewall-cmd --permanent --add-service=ldaps
sudo firewall-cmd --permanent --add-service=dns

# Reload firewall
sudo firewall-cmd --reload

# Verify rules
sudo firewall-cmd --list-all
```

### Step 16: Verify Complete Integration

```bash
# Check system authentication
sudo systemctl status sssd

# Verify domain membership
sudo realm list

# Test user lookup
id henryf
getent passwd henryf

# Check Kerberos ticket
sudo kinit henryf@MYCOMPANY.ORG
sudo klist

# Test password authentication
su - henryf
```

---

## Part 3: Post-Configuration Tasks

### Step 17: Set Hostname Resolution

Ensure the server's hostname is properly configured:

```bash
# Set hostname
sudo hostnamectl set-hostname bert.mycompany.org

# Verify hostname
hostnamectl

# Update /etc/hosts
sudo vi /etc/hosts

# Add entry:
10.0.13.35    bert.mycompany.org    bert
```

### Step 18: Configure SELinux (If Enabled)

```bash
# Check SELinux status
getenforce

# If SELinux is enforcing, ensure proper contexts
sudo setsebool -P allow_polyinstantiation on
sudo restorecon -Rv /home
```

### Step 19: Enable Services at Boot

```bash
# Ensure all required services start at boot
sudo systemctl enable sssd
sudo systemctl enable chronyd
sudo systemctl enable oddjobd
```

### Step 20: Document and Backup Configuration

```bash
# Create configuration backup
sudo mkdir -p /root/ad-integration-backup
sudo cp /etc/sssd/sssd.conf /root/ad-integration-backup/
sudo cp /etc/krb5.conf /root/ad-integration-backup/
sudo cp /etc/resolv.conf /root/ad-integration-backup/
sudo nmcli connection show > /root/ad-integration-backup/network-config.txt

# Create documentation of current state
sudo realm list > /root/ad-integration-backup/realm-status.txt
sudo systemctl list-unit-files | grep enabled > /root/ad-integration-backup/enabled-services.txt
```

---

## Troubleshooting

### Common Issues and Solutions

#### Issue: Domain Discovery Fails

**Solution:**
```bash
# Verify DNS servers
cat /etc/resolv.conf

# Test DNS resolution
nslookup mycompany.org
nslookup -type=SRV _ldap._tcp.mycompany.org

# Manually set DNS servers if needed
sudo nmcli connection modify <interface-name> ipv4.dns "AD_DNS_SERVER_IP"
sudo nmcli connection down <interface-name>
sudo nmcli connection up <interface-name>
```

#### Issue: Join Operation Fails

**Solution:**
```bash
# Check time synchronization
timedatectl status

# Verify connectivity to domain controller
ping <DC_IP>

# Check for existing computer account in AD and remove if necessary
# Attempt join with verbose output
sudo realm join --user=henryf --verbose mycompany.org
```

#### Issue: User Login Fails

**Solution:**
```bash
# Clear SSSD cache
sudo sss_cache -E

# Restart SSSD
sudo systemctl restart sssd

# Check SSSD logs
sudo tail -f /var/log/sssd/*.log

# Test user lookup
getent passwd henryf
id henryf
```

#### Issue: Home Directory Not Created

**Solution:**
```bash
# Verify oddjobd is running
sudo systemctl status oddjobd

# Check authselect configuration
sudo authselect current

# Re-enable mkhomedir
sudo authselect select sssd with-mkhomedir --force
sudo systemctl restart sssd
```

#### Issue: Permission Denied on Login

**Solution:**
```bash
# Check access_provider setting in sssd.conf
sudo grep access_provider /etc/sssd/sssd.conf

# Verify SELinux is not blocking
sudo ausearch -m avc -ts recent

# Check PAM configuration
sudo ls -la /etc/pam.d/
```

---

## Verification Checklist

- [ ] Network IP address changed to 10.0.13.35
- [ ] Gateway configured as 10.0.13.1
- [ ] DNS resolves mycompany.org domain
- [ ] Time synchronized with domain
- [ ] Server joined to mycompany.org domain
- [ ] `realm list` shows domain configuration
- [ ] Domain user `henryf` can be resolved with `id` command
- [ ] SSSD service is running and enabled
- [ ] Home directories are created automatically on first login
- [ ] Domain users can authenticate
- [ ] Firewall configured appropriately
- [ ] Configuration backed up

---

## Important Security Notes

1. **Change the default password** for the `henryf` account immediately after testing
2. **Use strong passwords** for all domain accounts
3. **Implement least privilege** - only grant necessary permissions
4. **Enable firewall** and restrict access to required ports only
5. **Keep system updated** with security patches:
   ```bash
   sudo dnf update -y
   ```
6. **Monitor logs** regularly for suspicious activity:
   ```bash
   sudo journalctl -u sssd -f
   ```
7. **Implement SSH key authentication** for remote access instead of password-only

---

## Additional Resources

- Red Hat Enterprise Linux Documentation: https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/10
- SSSD Documentation: https://sssd.io/
- Active Directory Integration Guide: https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/10/html/configuring_authentication_and_authorization_in_rhel/

---

## Support Contact Information

For issues or questions, contact:
- IT Support: [Your IT Support Contact]
- Domain Administrator: [Domain Admin Contact]
- Red Hat Support: https://access.redhat.com/support

---

**Document Version:** 1.0  
**Last Updated:** February 16, 2026  
**Author:** System Administrator  
**Server:** bert.mycompany.org
