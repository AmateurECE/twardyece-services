# Using the Debug Nameserver

The files `debug.docker-compose.yml` and the files in `dns/` provide
configuration for an authoritative DNS nameserver that will allow anyone on the
LAN to use the actual hostname (and thus TLS certificates, etc.) of the
production server, but the server's ports don't need to be open on the
WAN-facing firewall.

This configuration has not been verified, and should not be considered safe to
expose to the public internet (especially because it's authoritative over a
zone that already has an authoritative nameserver on the public internet).
