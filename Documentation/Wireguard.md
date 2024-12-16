# Configuration Files

Configuration files are stored at `/etc/wireguard`. ProtonVPN allows me to
download Wireguard configuration files from their web application. However,
these need a small modification to work with my current network topology:

```
[Interface]
# ...
PreUp = ip route add 192.168.1.0/24 via 192.168.2.1 dev enp7s0
PostDown = ip route del 192.168.1.0/24 via 192.168.2.1 dev enp7s0
```

This routes traffic to/from the 192.168.1.x subnet outside of the wireguard
interface.

To install a configuration file received from a VPN provider to configuration
wg1:

```bash-session
install -m600 my-wireguard.conf /etc/wireguard/wg1.conf
```
