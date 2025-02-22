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

# shellcheck source="${CONFIG_PATH}/initramfs" - load variables.
WG_CONFIG="${CONFIG_PATH}/initramfs"
source "${WG_CONFIG}"

if [ ! -s "${ADAPTER}" ]; then
  echo "Wireguard adapter config not found. Missing: ${ADAPTER}"
  exit 1
fi
if [ -z "${DATETIME_URL}" ]; then
  echo "DATETIME_URL not set (may cause issues for Raspberry Pi devices)."
fi

# TODO: use adapter and basename ${ADAPTER} .conf to parse interface name.
if [ -z "${INTERFACE}" ]; then
  echo "INTERFACE_NAME must be set."
  exit 1
fi
if [ -z "${INTERFACE_ADDR_IPV4}" ] && [ -z "${INTERFACE_ADDR_IPV6}" ]; then
  echo "INTERFACE_ADDR_IPV4 and/or INTERFACE_ADDR_IPV6 must be set."
  exit 1
fi

if [ -z "${PEER_ALLOWED_IPS_IPV4}" ] && [ -z "${PEER_ALLOWED_IPS_IPV6}" ]; then
  echo "PEER_ALLOWED_IPS_IPV4 and/or PEER_ALLOWED_IPS_IPV6 must be set."
  exit 1
fi

cp "${WG_CONFIG}" "/etc/wireguard/initramfs"

exit 0
