#!/usr/bin/env bash

if [ "$(id -u)" -ne 0 ]
  then echo "Please run as root"
  exit
fi

target_dir=${DESTDIR}/etc/wireguard-initramfs
docs_dir=${DESTDIR}/usr/local/share/docs/wireguard-initramfs

config_dir="../configs"

mkdir -p "${config_dir}"
cat "${target_dir}/private_key" > "${config_dir}/private_key"
cat "${target_dir}/pre_shared_key" > "${config_dir}/pre_shared_key"
source "${target_dir}/config"

tmp_INTERFACE_ADDR_IP=$(echo "${INTERFACE_ADDR}" | cut -d/ -f 1)
tmp_INTERFACE_ADDR_SUFFIX=$(echo "${INTERFACE_ADDR}" | cut -d/ -f 2)
tmo_PEER_URL=$(echo "${PEER_ENDPOINT}" | cut -d: -f 1)

cat >"${config_dir}/config" <<EOL
# Wireguard initramfs configuration.
#
# NOTE: As most systems do not encrypt /boot, private key material is exposed
#       and compromised/untrusted. Boot wireguard network should be
#       **different** & untrusted; versus the network used after booting.
#       Always restrict ports and access on the wireguard server.
#
# Be sure to test wireguard config with a running system before setting
# options. See: https://manpages.debian.org/unstable/wireguard-tools/wg.8.en.html
#
# Restricting dropbear connections to **only** wireguard:
# * Confirm wireguard/dropbear work without restriction first.
# * Set dropbear listen address to only wireguard client interface address.
#
#   /etc/dropbear-initramfs/config
#     DROPBEAR_OPTIONS='... -p 172.31.255.10:22 ...'
#

# Wireguard interface name.
INTERFACE=${INTERFACE}

# CIDR wireguard interface address.
INTERFACE_ADDR_IP=${tmp_INTERFACE_ADDR_IP}
INTERFACE_ADDR_SUFFIX=${tmp_INTERFACE_ADDR_SUFFIX}
INTERFACE_ADDR="\${INTERFACE_ADDR_IP}/\${INTERFACE_ADDR_SUFFIX}"

# Peer public key (server's public key).
PEER_PUBLIC_KEY=${PEER_PUBLIC_KEY}

# IP:PORT of the peer (server); any reachable IP/DNS.
PEER_PORT=${PEER_PORT}
PEER_URL=${tmo_PEER_URL}
PEER_ENDPOINT="\${PEER_URL}:\${PEER_PORT}"

# Persistent Keepalive. Required to ensure connection for non-exposed ports.
PERSISTENT_KEEPALIVES=25

# Allowed IP addresses (CIDR) on wireguard; for boot this should be the peer (server).
ALLOWED_IPS=172.31.255.254/32

# url to send a web request to set the local datetime
DATETIME_URL=google.com
EOL

rm "${docs_dir}/examples/config"
rm "${target_dir}/private_key"
rm "${target_dir}/pre_shared_key"
rm "${target_dir}/config"
