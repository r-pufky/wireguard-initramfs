# wireguard-initramfs
Use dropbear over wireguard.

Enables wireguard networking during kernel boot, before encrypted partitions
are mounted. Combined with [dropbear](https://github.com/mkj/dropbear) this
can enable FULLY ENCRYPTED remote booting without storing key material or
exposing ports on the remote network. An Internet connection simply needs to
exist that can reach the wireguard server endpoint.

Normal dropbear connections and DNS resolution can be used to find wireguard
endpoints. This essentially enables the creation of a fully encrypted remote
managed node, with the ability to prevent all local access.

## Requirements
Working knowledge of Linux. Understanding of networking and Wireguard.

1. [Debian Bullseye/Bookworm](https://debian.org) (any version with wireguard
   support should work, but untested).
1. [Wireguard](https://www.wireguard.com/) installed, configured and in a
   "known working" state.

## Install
Installation is automated via make. Download, extract contents, and install on
target machine.

Grab the latest release, untarball, and install.
```bash
wget https://github.com/r-pufky/wireguard-initramfs/archive/refs/tags/{RELEASE}.tar.gz
tar xvf {RELASE}.tar.gz
cd wireguard-initramfs-{RELEASE}; make install
```

### Configure
See comments in `/etc/wireguard-initramfs/config`. Be sure to set the private
and preshared keys (optional) as well.

Refer to [wg set man page](https://man7.org/linux/man-pages/man8/wg.8.html) for
additional information.

:warning:
Most installs do not currently encrypt `/boot`; and therefore the client
private key should be considered **untrusted/compromised**. It is highly
recommended that a separate point-to-point wireguard network with proper port
blocking is used for remote unlocking.

Rebuild initramfs to use:
```bash
update-initramfs -u
update-grub
reboot
```

Any static errors will abort the build. Mis-configurations will not be caught.
Be sure to test while you still have physical access to the machine.

## Dropbear
`wireguard-initramfs` can be combined with dropbear to enable remote system
unlocking without needing control over the remote network, or knowing what the
public IP of that system is. It also creates an encrypted no-trust tunnel
before SSH connections are attempted.

### Requirements

1. [Dropbear](https://github.com/mkj/dropbear) installed, configured and in a
   "known working" state.

### Configure
Set dropbear to use *all* network interfaces to ensure remote unlocks work over
wireguard first. Then restrict to the wireguard network once it is working:

`/etc/dropbear-initramfs/config`
```bash
DROPBEAR_OPTIONS='... -p 172.31.255.10:22 ...'
```

## Bug / Patches / Contributions?
All are welcome, please submit a pull request or open a bug!

Know debian packaging? Create a .deb package for this!
