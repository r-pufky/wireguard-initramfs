# wireguard-initramfs

Use dropbear over wireguard.

Enables wireguard networking during kernel boot, before encrypted partitions
are mounted. Combined with [dropbear](https://github.com/mkj/dropbear) this
can enable FULLY ENCRYPTED remote booting without storing key material or
exposing ports on the remote network. An Internet connection simply needs to
exist that can reach the wireguard server endpoint.

Normal dropbear connections and DNS resolution can be used to find wireguard
endpoints.
This essentially enables the creation of a fully encrypted remote-managed
node, with the ability to prevent all local access.

## Requirements

Working knowledge of Linux. Understanding of networking and Wireguard.

1. [Debian Bullseye/Bookworm](https://debian.org) (any version with wireguard
   support should work, but untested).
2. [Wireguard](https://www.wireguard.com/) installed, configured and in a
   "known working" state.

## Getting started

Installation is supported via make.
Download, extract and configure contents, and install on target machine.

### Download

Grab the latest release, untarball.

```bash
RELEASE=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/r-pufky/wireguard-initramfs/releases/latest | tr "/" "\n" | tail -n 1)
wget https://github.com/r-pufky/wireguard-initramfs/archive/refs/tags/"${RELEASE}".tar.gz
tar xvf "${RELEASE}".tar.gz
cd wireguard-initramfs-"${RELEASE}"
```

### Configure

`configs/initramfs` file contains variables based on your working wireguard
connection. Refer to
[wg set man page](https://man7.org/linux/man-pages/man8/wg.8.html) for
additional information.

### Installation

```bash
make install
```

:warning:

Most installs do not currently encrypt `/boot`; and therefore the client
private key should be considered **untrusted/compromised**. It is highly
recommended that a separate point-to-point wireguard network with proper
port blocking is used for remote unlocking.

Rebuild initramfs to use using any of these methods:

```bash
make build_initramfs  # Debian
make build_initramfs_rpi  # Raspberry Pi
update-initramfs -u -k all && update-grub  # Manual build
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

`/etc/dropbear/initramfs/config`

```bash
DROPBEAR_OPTIONS='... -p 172.31.255.10:22 ...'
```


## Clevis-TPM2

`wireguard-initramfs` can be combined with clevis-tpm2 to enable the protection
of the wireguard private key. This protection does only make sense, if the owner
is capable of using a TPM correctly.
This information needs to be undestood!
- https://uapi-group.org/specifications/specs/linux_tpm_pcr_registry/

You need to adapt for wg-quick usage:
`PostUp = wg set %i private-key <(sh -c "clevis decrypt tpm2 < /etc/wireguard/privatekey.jwe")`

The PreSharedKey is not secured in this way!
### Requirements

1. a working TPM2
2. [clevis-tpm2](https://github.com/latchset/clevis) installed and firm to use
2. [clevis-initramfs](https://github.com/latchset/clevis) installed and firm to use
3. a jwe encoded wireguard private key


## Legacy compatibility (Migration)

If you are a user using a previous release, such as the one dated
2023-10-21, you can update your current projects by running:

```bash
sudo bash scripts/migrate_project_structure.sh
make install
make build_initramfs
```

Adapter configuration is located in `/etc/wireguard/initramfs.conf` and
initramfs configuration is located in `/etc/wireguard/initramfs`.

This should keep your project structure and contents intact; however manual
**validation** is required as full wireguard adapter configs are now supported.

## Bug / Patches / Contributions?

All are welcome, please submit a pull request or open a bug!

Know debian packaging? Create a .deb package for this!
