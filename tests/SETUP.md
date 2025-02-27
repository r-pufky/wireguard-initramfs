# Base Testing Setup

`client/`, `server/` contain working wireguard configurations for testing.

`keys/` contain pre-generated public testing keys for both systems.
* DO NOT USE THESE KEYS - TESTING ONLY - CONSIDER COMPROMISED.
* no passwords are set.

## Base Configuration
Setup test environment and ensure both hosts can communicate. Use pre-generated
material.

### Server
Standard Debian Install with a static wireguard endpoint that the client will
connect to for testing. Used to validate two-way communication on the client
and test remote unlock via dropbear.

``` bash
apt update && apt dist-upgrade
apt install vim wireguard
# Use pre-generated material.
# wg genkey | tee /root/server.key | wg pubkey > /root/server.pub
cp dropbear.* /root/.ssh/
```

### Client
Machine that will be encrypted using wireguard-initramfs and dropbear. This is
where all of the testing will be done.

Encrypted Debian Install
* standard options until Partition disks
  * Guided - use entire disk and set up encrypted LVM
  * PW: wireguard-initramfs

Install Packages
``` bash
apt update && apt dist-upgrade
apt install vim git wireguard dropbear-initramfs make
git clone https://github.com/r-pufky/wireguard-initramfs /root/wireguard-initramfs
```

Generate Key Material (all weak / no password for testing)
``` bash
mkdir /root/.ssh && chmod 0700 /root/.ssh
# Use pre-generated material.
# wg genkey | tee /root/client.key | wg pubkey > /root/client.pub
# openssl rand -base64 32 > /root/preshare.key
# ssh-keygen -q -N "" -b 1024 -t rsa -f /root/.ssh/dropbear
cp dropbear.* /root/.ssh/
```

### Verify
* Client requires manual input (locally) to unlock root drive.
* Client can ping server via interface IP.
* Server can ping client via interface IP.

## Configure Dropbear
Ensure dropbear configuration works with interface IP before enabling
wireguard.

### Client
Generate default dropbear configuration and add to initramfs. Reboot - client
should halt until root disk is unlocked (locally or via dropbear).

``` bash
cat /root/.ssh/dropbear.pub > /etc/dropbear/initramfs/authorized_keys
update-initramfs -u -k all
reboot
```

### Server
Connect to client and unlock root drive.

``` bash
ssh -i /root/.ssh/dropbear.key root@{CLIENT INTERFACE IP}
cryptroot-unlock
```

### Verify
* Client requires manual to unlock root drive.
* Server can SSH to client with dropbear identity and unlock drive to boot.

## Configure Wireguard
Setup a known working wireguard configuration before testing
wireguard-initramfs.

### Client

/etc/wireguard/base.conf
``` ini
[Interface]
Address = 172.31.255.10/32
PrivateKey = iMgmYiJ5KykymUlWO/qtaC1azuFqH3zKSxs+dEgDRmI=

[Peer]
PublicKey = gyW39I9bAiOBXyhL8LWw9qwiTZgMmtAbsWtLUv8uKTc=
AllowedIPs = 172.31.255.254/32
PresharedKey = xZOa9wXPCL86UtIEMc4kKwj/wsCohs+S9NexPLDaFwU=
PersistentKeepalive = 25
Endpoint = {SERVER INTERFACE IP}:51820  # update endpoint IP.
```

Enable wireguard:
``` bash
wg-quick up base
```

### Server

/etc/wireguard/base.conf
``` ini
[Interface]
Address = 172.31.255.254/24
ListenPort = 51820
PrivateKey = 4LfbvXeEsQ9gPRq0scgTGTVkdFUAxasLb8of5Yl/1m4=

[Peer]
PublicKey = rdW/zMRxx61XPJoHqFEixd/xoC8jwBSUfwEeKl71RGk=
AllowedIPs = 172.31.255.0/24
PresharedKey = xZOa9wXPCL86UtIEMc4kKwj/wsCohs+S9NexPLDaFwU=
PersistentKeepalive = 25
```

Enable wireguard:
``` bash
wg-quick up base
```

### Verify
* client can ping server on wireguard `172.31.255.254`.
* server can ping client on wireguard `172.31.255.10`.
* Client requires manual to unlock root drive.
* Server can SSH to client interface IP with dropbear identity and unlock drive
  to boot.

[Run tests](TESTING.md)
