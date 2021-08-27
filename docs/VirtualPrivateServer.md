# Virtual Private Server Management

The `edtwardy-vps` package provides infrastructure to configure the machine on
which it is installed as the controller node in an Ansible workflow, managing
a virtual private server (currently provided by Linode).

See the output of `edtwardy-vps -h` for more information, but the installed
files allow the user to generate wireguard keys, configure the VPS using
Ansible, stop and restart the services, etc.

NOTE: When running under Alpine, it's not required to do any manual setup of
the node, except what's required via the Linode portal.

The `systemd` target `edtwardy-vps.target` is provided to enable the wireguard
interface.
