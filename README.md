# wireguard-initramfs
Use dropbear over wireguard.
Start wireguard network during kernel init; enabling dropbear use over wireguard!

Enables wireguard networking during kernel boot, before encrypted partitions
are mounted. Combined with [dropbear](https://github.com/mkj/dropbear) this
can enable FULLY ENCRYPTED remote booting without storing key material or
exposing ports on the remote network. An Internet connection simply needs to
exist that can reach the wireguard endpoint.

Normal dropbear connections can still be used, as well as DNS resolution to
find wireguard endpoints. This essentially enables the creation of a fully
encrypted remote managed node, with the ability to prevent all local access.

## Requirements
Working knowledge of Linux. Understanding of networking and how Dropbear,
Wireguard work.

1. [Debian Bullseye](debian.org) (any version with wireguard support should work, but untested).
1. [Dropbear](https://github.com/mkj/dropbear) installed, configured and in a "known working" state.
1. [Wireguard](https://www.wireguard.com/) installed, configured and in a "known working" state.

## Install
Installation is automated via make. Download, extract contents, and install on
target machine.

Grab the latest release, untarball, and install.
```bash
wget https://github.com/r-pufky/wireguard-initramfs/archive/refs/tags/2021-07-03.tar.gz
tar xvf 2021-07-03.tar.gz
cd wireguard-initramfs-2021-07-03; make install
```

## Configure
Configuration is explained within `/etc/wireguard-initramfs/config`. Be sure to
set the private key as well.

Restricting dropbear connections to **only** wireguard:
> Confirm wireguard/dropbear work without restriction first.
>
> Set dropbear listen address to only wireguard client interface address.
> Using example configuration:
>
> /etc/dropbear-initramfs/config
> ```bash
> DROPBEAR_OPTIONS='... -p 172.31.255.10:22 ...'
> ```

Refer to [wg set man page](https://man7.org/linux/man-pages/man8/wg.8.html) for
additional information.

:warning:
Most installs do not currently encrypt `/boot`; and therefore the client's
private key should be considered **untrusted/compromised**. It is highly
recommended that a separate wireguard network is used to for remote unlocking.

Rebuild initramfs to use:
```bash
update-initramfs -u
update-grub
reboot
```

Any static errors will abort the build. Mis-configurations will not be caught;
test this where you can easily get physical access to the machine if something
goes wrong.

## FAQ
Q: **I want to use this, but without dropbear**

> A: Supported; just remove the pre-requisite dependency for `init-bottom`:
>
> `/usr/share/initramfs-tools/init-bottom/wireguard`
> ```bash
> #PREREQ="dropbear" 
> PREREQ="" 
> ```
>
> and rebuild the initramfs image.

Q: **I want to restrict dropbear to only wireguard**

> A: Supported. Confirm wireguard works before restricting normal networks.
>
> Restricting dropbear connections to **only** wireguard:
>   Confirm wireguard/dropbear work without restriction first.
>
>   Set dropbear listen address to only wireguard client interface address.
>   Using example configuration:
>
>   /etc/dropbear-initramfs/config
>   ```bash
>   DROPBEAR_OPTIONS='... -p 172.31.255.10:22 ...'
>   ```

## Bug / Patches / Contributions?
All are welcome, please submit a pull request or open a bug!

Know debian packaging? Create a .deb package for this!
