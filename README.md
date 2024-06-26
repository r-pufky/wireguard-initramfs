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

To configure wireguard-initramfs, follow these steps:
1. **Locate the configuration files:** Open and modify the files in the 
   `configs` folder.
2. **Set the variables:** The `config` file contains variables based on your 
   working wireguard connection. 
3. **Set the private and preshared keys:** The separate files contain 
   options for setting the private and preshared keys.
   While it is necessary to set the private key, setting the preshared key 
   is optional.
4. Make sure to set these according to your network configuration.

Refer to [wg set man page](https://man7.org/linux/man-pages/man8/wg.8.html) for
additional information.

Based on these files from the `configs` folder the `make install` step builds  
a named configuration file into `/etc/wireguard`.
That will be used and copy into the initramfs.

### Installation

```bash
make install
```

:warning:

Most installs do not currently encrypt `/boot`; and therefore the client
private key should be considered **untrusted/compromised**. It is highly
recommended that a separate point-to-point wireguard network with proper
port blocking is used for remote unlocking.

Rebuild initramfs to use:

```bash
make build_initramfs
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

## Legacy compatibility

If you are a user using a previous release, such as the one dated 
2023-10-21, you can update your current projects by running

```bash
sudo bash scripts/migrate_project_structure.sh
```

This should keep your project structure and contents intact.

## Bug / Patches / Contributions?

All are welcome, please submit a pull request or open a bug!

Know debian packaging? Create a .deb package for this!
