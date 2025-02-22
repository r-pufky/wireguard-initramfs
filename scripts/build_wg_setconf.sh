#!/usr/bin/env bash

# use a different config via make arguments
# make install CONFIG=/path/to/config_folder
if [ -z "${CONFIG}" ]; then
  CONFIG_PATH="$(pwd)/configs"
else
  CONFIG_PATH="${CONFIG}"
fi

CONFIG_FILE="${CONFIG_PATH}/config"
# shellcheck source="${CONFIG_PATH}/config"
source "${CONFIG_FILE}"

# copy config file due to naming in the following steps
cp "${CONFIG_FILE}" "/etc/wireguard/config"

# check all required parameter
if [ -z "${INTERFACE}" ]; then
  echo "Please set the missing interface name"
  exit 1
fi

if [ -z "${INTERFACE_ADDR_IPV4}" ] && -z [ "${INTERFACE_ADDR_IPV6}" ]; then
  echo "Please set the missing interface ip address"
  exit 1
fi
if [ -z "${INTERFACE_ADDR_IPV4_SUFFIX}" ] && -z [ "${INTERFACE_ADDR_IPV6_SUFFIX}" ]; then
  echo "Please set the missing interface ip address suffix"
  exit 1
fi
if [ -z "${INTERFACE_PORT}" ]; then
  echo "Please set the missing interface port"
  exit 1
fi

if [ -z "${PEER_PUBLIC_KEY}" ]; then
  echo "Please set the missing server public key"
  exit 1
fi
if [ -z "${PEER_PORT}" ]; then
  echo "Please set the missing wireguard port"
  exit 1
fi
if [ -z "${PEER_URL}" ]; then
  echo "Please set the missing wireguard url"
  exit 1
fi

if [ -z "${PERSISTENT_KEEPALIVES}" ]; then
  echo "Please set the missing persistent keepalive"
  exit 1
fi

if [ -z "${ALLOWED_IPS_IPV4}" ] && -z [ "${ALLOWED_IPS_IPV6}" ]; then
  echo "Please set the missing allowed ip addresses"
  exit 1
fi

CLIENT_PRIVATE_KEYFILE="${CONFIG_PATH}/private_key"
if [ ! -s "${CLIENT_PRIVATE_KEYFILE}" ]; then
  echo "Wireguard client private key required. Missing: ${CLIENT_PRIVATE_KEYFILE}"
  exit 1
fi

# Set dual-stack interface addresses.
if [ -n "${INTERFACE_ADDR_IPV4}" ]; then
  WG_INTER_ADDRESS="Address = ${INTERFACE_ADDR_IPV4}"
fi

if [ -n "${INTERFACE_ADDR_IPV6}" ]; then
  # Enable newlines on here document processing.
  WG_INTER_ADDRESS=$(printf "${WG_INTER_ADDRESS}\nAddress = ${INTERFACE_ADDR_IPV6}")
fi

# Separate lists only needed for interface setup, converge.
if [ -n "${ALLOWED_IPS_IPV4}" ]; then
  PEER_ALLOWED_IPS="${ALLOWED_IPS_IPV4}"
fi

if [ -n "${ALLOWED_IPS_IPV6}" ]; then
  PEER_ALLOWED_IPS="${CLIENT_ALLOWED_IPS},${ALLOWED_IPS_IPV6}"
fi

# build wireguard config file
CLIENT_PRIVATE_KEYFILE_CONTENT=$(cat "${CLIENT_PRIVATE_KEYFILE}")

CONFIG_FILE="/etc/wireguard/${INTERFACE}.conf"
cat > "${CONFIG_FILE}" <<EOL
[Interface]
${WG_INTER_ADDRESS}
PrivateKey = ${CLIENT_PRIVATE_KEYFILE_CONTENT}
ListenPort = ${INTERFACE_PORT}

[Peer]
PublicKey = ${PEER_PUBLIC_KEY}
Endpoint = ${PEER_ENDPOINT}
AllowedIPs = ${PEER_ALLOWED_IPS}
PersistentKeepalive = ${PERSISTENT_KEEPALIVES}
EOL

# add optional parameter
PRE_SHARED_KEY="${CONFIG_PATH}/pre_shared_key"
if [ -s "${PRE_SHARED_KEY}" ]; then
  PRE_SHARED_KEY_CONTENT=$(cat "${PRE_SHARED_KEY}")
	echo "PresharedKey = ${PRE_SHARED_KEY_CONTENT}" >> "${CONFIG_FILE}"
fi

if [ -z "${DATETIME_URL}" ]; then
  echo "INFO: DATETIME_URL not set"
fi

exit 0
