#!/bin/bash
###############################################################################
# NAME:             edtwardy-plex.bash
#
# AUTHOR:           Ethan D. Twardy <edtwardy@mtu.edu>
#
# DESCRIPTION:      Wrapper script to start/stop Plex (in the container)
#
# CREATED:          08/02/2021
#
# LAST EDITED:      08/05/2021
###

read -r -d '' USAGE <<EOF
Usage: $0 <command>

Commands:
  start     Start Plex in the container
EOF

set -e

LOG_TAG=edtwardy-plex
COMPOSE_FILE=/usr/share/$LOG_TAG/docker-compose.yml

if [[ -z $1 ]]; then
    >&2 printf '%s\n' "$USAGE"
    exit 1
fi

case "$1" in
    start)
        printf ${LOG_TAG}': %s\n' "Starting Plex in a container"
        docker-compose -f $COMPOSE_FILE up
        ;;
    *)
        >&2 printf '%s\n' "$USAGE"
        exit 1
        ;;
esac

###############################################################################
