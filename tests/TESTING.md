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

## 3. Rapsberry Pi

### Success Criteria
* All defined tests pass on Raspberry Pi platform.
