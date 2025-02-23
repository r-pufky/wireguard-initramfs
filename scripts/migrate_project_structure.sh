#!/usr/bin/env bash
#
# Migrate 2023-10-21 installs to current format, creating
# /etc/wireguard/initramfs.conf adapter for the original config settings.

if [ "$(id -u)" -ne 0 ]
  then echo "Please run as root"
  exit
fi

target_dir=${DESTDIR}/etc/wireguard-initramfs
docs_dir=${DESTDIR}/usr/local/share/docs/wireguard-initramfs

config_dir="../configs"

mkdir -p "${config_dir}"
source "${target_dir}/config"

# Write new initramfs config.
cat >"${config_dir}/initramfs" <<EOL
# Wireguard initramfs configuration.
#
# NOTE: As most systems do not encrypt /boot, private key material is exposed
#       and compromised/untrusted. Boot wireguard network should be
#       **different** & untrusted; versus the network used after booting.
#       Always restrict ports and access on the wireguard server.
#
# Be sure to test wireguard config with a running system before setting
# options.
#
# Restricting dropbear connections to **only** wireguard:
# * Confirm wireguard/dropbear work without restriction first.
# * Set dropbear listen address to only wireguard interface (INTERFACE_ADDR_*)
#   address:
#
#   /etc/dropbear/initramfs/config
#     DROPBEAR_OPTIONS='... -p 172.31.255.10:22 ...'
#
# Reference:
# * https://manpages.debian.org/unstable/wireguard-tools/wg-quick.8.en.html

# Absolute path to working wireguard adapter config for initramfs. This is
# copied to initramfs and loaded after the hardware device is initialized to
# complete wireguard configuration.
ADAPTER=/etc/wireguard/initramfs.conf

# Enable wg-quick for adapter management?
#
# wg is used by default and requires no additional dependencies, at the cost of
# parsing the adapter configuration with a reduced set of options.
#
# Enabling will add wg-quick and bash to the initramfs package, enabling full
# adapter configuration support at the cost of an additional 1.4M of space.
#
# Highly recommend only enabling if basic wg configuration does not meet needs.
#
# Any value enables.
ENABLE_QUICK=

# URL to send a web request to set the local datetime.
#
# Raspberry Pi's should enable this feature for wireguard-initramfs to work.
#
# Skipped if blank.
DATETIME_URL=google.com

# Persist (do not down) interface after initramfs exits? Any value enables.
PERSISTENT=

# Enable debug logging (will expose key material)? Any value enables.
DEBUG=
EOL

# Migrate initramfs adapter configuration.
CONFIG_FILE="/etc/wireguard/initramfs.conf"
cat > "${CONFIG_FILE}" <<EOL
[Interface]
Address = ${INTERFACE_ADDR}
PrivateKey = $(cat "${target_dir}/private_key")
ListenPort = ${PEER_PORT}

[Peer]
PublicKey = $(cat "${target_dir}/pre_shared_key")
Endpoint = ${PEER_ENDPOINT}
AllowedIPs = ${ALLOWED_IPS}
PersistentKeepalive = ${PERSISTENT_KEEPALIVES}
EOL

PRE_SHARED_KEY="${CONFIG_PATH}/pre_shared_key"
if [ -s "${PRE_SHARED_KEY}" ]; then
  PRE_SHARED_KEY_CONTENT=$(cat "${PRE_SHARED_KEY}")
	echo "PresharedKey = ${PRE_SHARED_KEY_CONTENT}" >> "${CONFIG_FILE}"
fi

rm "${docs_dir}/examples/config"
rm "${target_dir}/private_key"
rm "${target_dir}/pre_shared_key"
rm "${target_dir}/config"
