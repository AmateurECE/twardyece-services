#!/bin/bash
###############################################################################
# NAME:             edtwardy-vps.bash
#
# AUTHOR:           Ethan D. Twardy <edtwardy@mtu.edu>
#
# DESCRIPTION:      Script to invoke ansible to manage a node with the
#                   installed playbook.
#
# CREATED:          08/13/2021
#
# LAST EDITED:      08/26/2021
###

read -r -d '' USAGE<<EOF
$0 <command>

The following commands are supported:
  configure <wgN.conf> <publickey>
    Run the Ansible playbook on the configured managed node. Argument
    <wgN.conf> is the path to the wireguard conf file for the managed node.
    <publickey> is the path of the public key.

  genkeys <outputConfDir>
    Generate two sets of keys; one for the VPS node, another for us. Files are
    placed into <outputConfDir>, and files are suffixed with either -vps or
    -home based on where they should be installed.

  localinstall <wgN.conf> <publickey>
    Install <wgN.conf> and <publickey> to be available on the local machine.

  start
    Start the wireguard interface and firewall service on the VPS

  stop
    Bring down the wireguard interface and firewall service on the VPS
EOF

set -e

PACKAGE_NAME=edtwardy-vps
SHARE_DIR=/usr/share/$PACKAGE_NAME
VPS_KEYS=$SHARE_DIR/vps-keys.conf
source $VPS_KEYS

VPS_USER=root

configure() {
    local wgConf=$1 && shift
    local wgPublickey=$1 && shift
    local playbook=$SHARE_DIR/ansible-playbook.yml
    ansible-playbook \
        -e "wg_conf_vps=$(realpath $wgConf)" \
        -e "wg_publickey_vps=$(realpath $wgPublickey)" \
        $playbook
}

genkeys() {
    local outputConfDir=$1 && shift
    local ourConf=$outputConfDir/wg0-client.conf
    local vpsConf=$outputConfDir/wg0-server.conf
    local ourPublic=$outputConfDir/publickey-client
    local vpsPublic=$outputConfDir/publickey-server

    local clientTemplate=$SHARE_DIR/wireguard-client.conf
    local serverTemplate=$SHARE_DIR/wireguard-server.conf

    # Prepare our files
    (umask 077 && wg genkey |
             tee >(renderbars -c client_private_key="{{stdin}}" \
                              -c server_public_key="\{{server_public_key}}" \
                              $clientTemplate ${ourConf}.tmp) |
             wg pubkey | tee $ourPublic |
             renderbars -c client_public_key="{{stdin}}" \
                        -c server_private_key="\{{server_private_key}}" \
                        $serverTemplate ${vpsConf}.tmp)

    # Prepare vps files
    (umask 077 && wg genkey |
             tee >(renderbars -c server_private_key="{{stdin}}" \
                              ${vpsConf}.tmp $vpsConf) |
             wg pubkey | tee $vpsPublic |
             renderbars -c server_public_key="{{stdin}}" \
                        ${ourConf}.tmp ${ourConf})
    rm -f ${ourConf}.tmp
    rm -f ${vpsConf}.tmp
}

localinstall() {
    local wgConf=$1 && shift
    local wgPublic=$1 && shift
    install -m600 $wgConf /etc/wireguard/wg0.conf
    install $wgPublic /etc/wireguard/publickey
}

start() {
    local restartCommand="wg-quick up wg0 && service nftables restart"
    ssh $VPS_USER@$vps_address "$restartCommand"
}

stop() {
    local stopCommand="wg-quick down wg0 && service nftables stop"
    ssh $VPS_USER@$vps_address "$stopCommand"
}

case "$1" in
    configure)
        if [[ -z "$2" || -z "$3" ]]; then
            >&2 printf '%s\n' "$USAGE"
            exit 1
        fi
        configure "$2" "$3"
        ;;
    genkeys)
        if [[ -z "$2" ]]; then
            >&2 printf '%s\n' "$USAGE"
            exit 1
        fi
        printf ${PACKAGE_NAME}': %s\n' "Generating VPS and home wg conf files"
        genkeys "$2"
        printf ${PACKAGE_NAME}': %s\n' "Done"
        ;;
    localinstall)
        if [[ -z "$2" || -z "$3" ]]; then
            >&2 printf '%s\n' "$USAGE"
            exit 1
        fi
        localinstall "$2" "$3"
        ;;
    start)
        start
        ;;
    stop)
        stop
        ;;
    *)
        >&2 printf '%s\n' "$USAGE"
        exit 1
        ;;
esac

###############################################################################
