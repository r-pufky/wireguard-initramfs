# Testing Plan
All tests must pass before a release can be cut. Pull requests must test
affected tests to ensure no breakage.

Any breakage should be explicitly mentioned as intentional in pull request.

## IPv4 Client/Server
Traditional 1:1 IPv4 client/server model.

`client` - machine with WG configured.
`server` - machine with wireguard-initramfs configured.

### Setup
* configure and apply wireguard-initramfs to server.

### Success Criteria
* client can send net traffic to server.
* server can send net traffic to client.

## IPv6 Client/Server.
Traditional 1:1 IPv6 client/server model.

`client` - machine with WG configured.
`server` - machine with wireguard-initramfs configured.

### Setup
* configure and apply wireguard-initramfs to server.

### Success Criteria
* client can send net traffic to server.
* server can send net traffic to client.

## IPv6 Client/Server Dualstack.
Traditional 1:1 client/server model; server has both IPv4 and IPv6 connections
enabled at the same time.

`client` - machine with WG configured.
`server` - machine with wireguard-initramfs configured.

### Setup
* configure and apply wireguard-initramfs to server.
* client configured for IPv4 wireguard, then reconfigured for IPv6 wireguard.

### Success Criteria
* No server reconfiguration.
* client configured to use IPv4.
* client can send IPv4 net traffic to server.
* server can send IPv4 net traffic to client.
* client configured to use IPv6.
* client can send IPv6 net traffic to server.
* server can send IPv6 net traffic to client.

## IPv6 Client/Server Preshared-Key.
Traditional 1:1 client/server model with preshared key.

`client` - machine with WG configured.
`server` - machine with wireguard-initramfs configured.

### Setup
* configure and apply wireguard-initramfs to server.

### Success Criteria
* client can send IPv4 net traffic to server.
* server can send IPv4 net traffic to client.

## IPv6 Client/Server CryptFS, Dropbear.
Traditional 1:1 client/server model; server using dropbear with full disk
encryption requiring manual key input to unlock.

`client` - machine with WG configured.
`server` - machine with wireguard-initramfs configured, dropbear configured,
           full disk encryption enabled with manual key input.

### Setup
* configure and apply wireguard-initramfs to server.

### Success Criteria
* client connects to server.
* client inputs key to unlock FDE on server to allowed continued boot.
* server completes encrypted boot.
