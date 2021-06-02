#!/bin/bash
###############################################################################
# NAME:             start-webservices.bash
#
# AUTHOR:           Ethan D. Twardy <edtwardy@mtu.edu>
#
# DESCRIPTION:      Start the edtwardy-webservices docker services
#
# CREATED:          05/01/2021
#
# LAST EDITED:      05/31/2021
###

# TODO: Cron/certbot to renew certificate
# TODO: postrm script
#   This package should remove docker images and volumes when uninstalled.
# TODO: Device a way to enable/disable whole locations/services at runtime?
# TODO: Re-map user id of files within containers
#   https://docs.docker.com/engine/security/userns-remap/
# TODO: Set up non-root user with systemd.

read -r -d '' USAGE <<EOF
$(basename $0): Start Docker Web Services
EOF

shopt -s extglob
set -e

PACKAGE_NAME=edtwardy-webservices
DVM_LOCK=/usr/share/$PACKAGE_NAME/volumes.dvm.lock
VOLUME_NAMES=($(awk '/^#/{next};NF==0{next};{print $1}' $DVM_LOCK))
LOG_TAG='start-webservices'

# Read the configuration file (with defaults set)
VOLPATH=/var/data/$PACKAGE_NAME
. /etc/$PACKAGE_NAME/dvm.conf

# join: Join a bash array by a delimiter
join() {
    local d=${1-} f=${2-};
    if shift 2; then
        printf %s "$f" "${@/#/$d}"
    fi
}

# getConfigVolumesToCreate: Get subset of config volumes we need to create
getVolumesToCreate() {
    existingVolumes=($(docker volume ls | tail -n+2 | awk '{print $2}'))
    pattern=$(join '|' "${existingVolumes[@]}")
    neededVolumes=${VOLUME_NAMES[@]//*($pattern)?( )}
    printf '%s\n' "${neededVolumes[@]}"
}

syncVolumes() {
    # Create missing volumes, if any
    printf ${LOG_TAG}': %s\n' "Checking for missing volumes"
    newVolumes=($(getVolumesToCreate))
    for volume in "${newVolumes[@]}"; do
        printf ${LOG_TAG}': Creating volume %s\n' $volume
        docker volume create $volume
    done

    # Spin up a docker container to synchronize all of the volumes
    containerName='edtwardy-webservices_volumemanager'
    command=edtwardy/volumemanager:latest

    volumeSpec=()
    for volume in "${VOLUME_NAMES[@]}"; do
        volumeSpec+=("-v" "${volume}:/${volume}")
    done

    # Pass --init-downstream for newly created downstream volumes
    if [[ -n "${newVolumes[@]}" ]]; then
        upstreams=($(awk '/^[^#].*upstream/{print $1}' $DVM_LOCK))
        newDownstream=${newVolumes[@]//*($(join '|' "${upstreams[@]}"))?( )}
        printf ${LOG_TAG}': %s\n' "Found downstreams to init: ${newVolumes[@]}"
        command="${command} --init-downstream $(join , ${newDownstream[@]})"
    fi

    # Pass volumes to search for images as env var
    IFS=: read -ra volpathComponents <<<"$VOLPATH"
    dockerVolpath=()
    printf ${LOG_TAG}': %s\n' "Host VOLPATH: $VOLPATH"
    for i in $(seq 0 $(("${#volpathComponents[@]}" - 1))); do
        volume="${volpathComponents[i]}"
        volumeSpec+=("-v" "$volume:/$(basename $volume)-$i")
        dockerVolpath+=("/$(basename $volume)-$i")
    done

    # Finally--must mount volumes.dvm.lock at /
    volumeSpec+=("-v" "$DVM_LOCK:/$(basename $DVM_LOCK):ro")

    printf ${LOG_TAG}': %s\n' "Volumes: $(join ' ' ${volumeSpec[@]})"
    printf ${LOG_TAG}': %s\n' "Docker VOLPATH: $(join : ${dockerVolpath[@]})"
    printf ${LOG_TAG}': %s\n' "Starting docker-volume-manager"
    trap "docker stop $containerName" EXIT
    docker run -t --rm --name $containerName \
           "${volumeSpec[@]}" \
           -e VOLPATH=$(join : "${dockerVolpath[@]}") \
           $command
    trap - EXIT
}

RC=0
case $1 in
    start)
        syncVolumes
        printf ${LOG_TAG}': %s\n' "Starting docker services"
        docker-compose up
        ;;
    *)
        >&2 printf '%s\n' "$USAGE"
        RC=1
        ;;
esac

###############################################################################
