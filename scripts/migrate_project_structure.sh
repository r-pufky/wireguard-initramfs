#!/usr/bin/env bash
#
# Migrate 2023-10-21 releases. Original config is adapter only and migrated to
# /etc/wireguard/initramfs.conf; which is the default adapter defined.
#
# This preps the filesystem for the current wireguard-initramfs implementation
# to 'make install && make build_initramfs'.

if [ "$(id -u)" -ne 0 ]
  then echo 'Please run as root'
  exit
fi

PACKAGE_DIR="$(dirname "${0}")/.."

TARGET_DIR='/etc/wireguard'
SOURCE_DIR="${DESTDIR}/etc/wireguard-initramfs"
DOCS_DIR="${DESTDIR}/usr/local/share/docs/wireguard-initramfs"
. "${SOURCE_DIR}/config"

ADAPTER="${TARGET_DIR}/initramfs.conf"
NEW_CONFIG="${PACKAGE_DIR}/configs/initramfs"

echo "Migrate new config: ${NEW_CONFIG}"
cp -av "${NEW_CONFIG}" "${TARGET_DIR}"

echo "Migrate initramfs adapter to: ${ADAPTER}"
cat > "${ADAPTER}" <<EOL
[Interface]
Address = ${INTERFACE_ADDR}
PrivateKey = $(cat "${SOURCE_DIR}/private_key")
ListenPort = 0
FwMark = 0

[Peer]
PublicKey = ${PEER_PUBLIC_KEY}
Endpoint = ${PEER_ENDPOINT}
AllowedIPs = ${ALLOWED_IPS}
PersistentKeepalive = ${PERSISTENT_KEEPALIVES:-25}
EOL

PRE_SHARED_KEY="${SOURCE_DIR}/pre_shared_key"
if [ -s "${PRE_SHARED_KEY}" ]; then
  PRE_SHARED_KEY_CONTENT=$(cat "${PRE_SHARED_KEY}")
	echo "PresharedKey = ${PRE_SHARED_KEY_CONTENT}" >> "${ADAPTER}"
fi

rm "${DOCS_DIR}/examples/config"
rm "${SOURCE_DIR}/private_key"
rm "${SOURCE_DIR}/pre_shared_key"
rm "${SOURCE_DIR}/config"
rmdir "${SOURCE_DIR}"
