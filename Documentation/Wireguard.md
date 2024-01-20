# Configuration Files

Configuration files are stored at `/etc/wireguard`. To install a configuration file
received from a VPN provider to configuration wg1:

```bash-session
install -m600 my-wireguard.conf /etc/wireguard/wg1.conf
```
