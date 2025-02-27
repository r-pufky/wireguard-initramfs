#!/usr/bin/env bash
#
# Shellcheck specified config for syntax errors and sanity check variables that
# they are set appropriately to prevent any easy to detect errors. Copy the
# verified initramfs config to /etc/wireguard/initramfs.

# Use make config path if set: make install CONFIG=/path/to/config_folder.
if [ -z "${CONFIG}" ]; then
  CONFIG_PATH="$(pwd)/configs"
else
  CONFIG_PATH="${CONFIG}"
fi

WG_INIT_CONFIG="${CONFIG_PATH}/initramfs"
. "${WG_INIT_CONFIG}"

if [ ! -s "${ADAPTER}" ]; then
  echo "Wireguard adapter config not found. Missing: ${ADAPTER}"
  exit 1
fi
if [ -z "${DATETIME_URL}" ]; then
  echo "DATETIME_URL not set (may cause issues for Raspberry Pi devices)."
fi

cp "${WG_INIT_CONFIG}" "/etc/wireguard/initramfs"

exit 0
