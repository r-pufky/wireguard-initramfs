# Wireguard-initramfs Testing

[Setup environment first](SETUP.md)

## 1. Remote dropbear login over wireguard for boot unlock (wg).

### Success Criteria
* Server can SSH to client wireguard IP with dropbear identity and unlock drive
  to boot.

### Client

/root/wireguard-initramfs/configs/initramfs
``` ini
ADAPTER=/etc/wireguard/base.conf
ENABLE_QUICK=
DATETIME_URL=google.com
PERSISTENT=
DEBUG=y
```

Generate configuration and reboot:
``` bash
make install
make build_initramfs
reboot
```

## 2. Remote dropbear login over wireguard for boot unlock (wg-quick).

### Success Criteria
* Server can SSH to client wireguard IP with dropbear identity and unlock drive
  to boot using a full wg-quick configuration.

### Client

/root/wireguard-initramfs/configs/initramfs
``` ini
ADAPTER=/etc/wireguard/base.conf
ENABLE_QUICK=y
DATETIME_URL=google.com
PERSISTENT=
DEBUG=y
```

Generate configuration and reboot:
``` bash
make install
make build_initramfs
reboot
```

## 3. Multiple Interface address parsing (wg).

### Success Criteria
* Server can SSH to client wireguard IP with dropbear identity and unlock drive
  to boot.

### Client

/root/wireguard-initramfs/configs/initramfs
``` ini
ADAPTER=/etc/wireguard/multi_address.conf
ENABLE_QUICK=
DATETIME_URL=google.com
PERSISTENT=
DEBUG=y
```

Generate configuration and reboot:
``` bash
cp multi_address.conf /etc/wireguard/multi_address.conf  # update endpoint IP.
make install
make build_initramfs
reboot
```
## 4. Multiple AllowedIPs parsing (wg).

### Success Criteria
* Server can SSH to client wireguard IP with dropbear identity and unlock drive
  to boot.

### Client

/root/wireguard-initramfs/configs/initramfs
``` ini
ADAPTER=/etc/wireguard/multi_allowed.conf
ENABLE_QUICK=
DATETIME_URL=google.com
PERSISTENT=
DEBUG=y
```

Generate configuration and reboot:
``` bash
cp multi_allowed.conf /etc/wireguard/multi_allowed.conf  # update endpoint IP.
make install
make build_initramfs
reboot
```

## 5. 2023-10-21 Migration

### Success Criteria
* Verify a working 2023-10-21 upgrade to current config structure works without
  requiring manual reconfiguration.
* Test until 2023-10-21 no longer works on current OS releases.

### Client

Install 2023-10-21 and configure with existing wireguard network.
``` bash
wget --content-disposition https://github.com/r-pufky/wireguard-initramfs/archive/refs/tags/2023-10-21.tar.gz -P /tmp
mkdir /root/2023-10-21 && tar xvf /tmp/wireguard-initramfs-2023-10-21.tar.gz -C /root
cd /root/wireguard-initramfs-2023-10-21
make install
cat preshare.key > /etc/wireguard-initramfs/pre_shared_key
cat client.key > /etc/wireguard-initramfs/private_key
cat 2023-10-21.config > /etc/wireguard-initramfs/config  # update endpoint IP.
update-initramfs -u && update-grub
reboot
```
* Ensure endpoint is updated to server testing interface IP.
* Server can SSH to client wireguard IP with dropbear identity and unlock drive
  to boot.

Install release and run migrate_project_structure.sh:
``` bash
git clone https://github.com/r-pufky/wireguard-initramfs /root/wireguard-initramfs
cd /root/wireguard-initramfs
./scripts/migrate_project_structure.sh
make install
make build_initramfs
reboot
```
* System ready to test.

## 6. Rapsberry Pi

### Success Criteria
* All defined tests pass on Raspberry Pi platform.
