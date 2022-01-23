#!/bin/bash
###############################################################################
# NAME:             edtwardy-webservices.bash
#
# AUTHOR:           Ethan D. Twardy <edtwardy@mtu.edu>
#
# DESCRIPTION:      Start the edtwardy-webservices docker services
#
# CREATED:          05/01/2021
#
# LAST EDITED:      07/02/2021
###

read -r -d '' USAGE <<EOF
$0 <command>

Start Docker Web Services

Commands:
  start     Start the webservices daemon (runs until interrupted)
  rm        Purge volumes and containers created by the daemon, leaving OCF
            images and volume images untouched.
  backup [--tag <tag>] [--location <location>] [volumes,to,backup]
            If <tag> is specified, the images are tagged with the specified
            tag, and a tags file is created, if one does not already exist. If
            location is specified, this is the location that the volumes are
            backed up to (but only if they don't already exist in VOLPATH). A
            comma-separated list of volumes to backup can be specified. If one
            is not given, all volumes are backed up.
EOF

shopt -s extglob
set -e

PACKAGE_NAME=edtwardy-webservices
DVM_LOCK=/usr/share/$PACKAGE_NAME/volumes.dvm.lock
VOLUME_NAMES=($(awk '/^#/{next};NF==0{next};{print $1}' $DVM_LOCK))
LOG_TAG='edtwardy-webservices'
COMPOSE_FILE=/usr/share/$PACKAGE_NAME/docker-compose.yml

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

runDockerVolumeManager() {
    # Spin up a docker container to synchronize all of the volumes
    containerName='edtwardy-webservices_volumemanager'
    imageName=edtwardy/volumemanager:latest

    volumeSpec=()
    for volume in "${VOLUME_NAMES[@]}"; do
        volumeSpec+=("-v" "${volume}:/${volume}")
    done

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
           $(join ' ' "${volumeSpec[@]}") \
           -e VOLPATH=$(join : "${dockerVolpath[@]}") \
           $imageName $(join ' ' "$@")
    trap - EXIT
}

syncVolumes() {
    # Create missing volumes, if any
    printf ${LOG_TAG}': %s\n' "Checking for missing volumes"
    newVolumes=($(getVolumesToCreate))
    for volume in "${newVolumes[@]}"; do
        printf ${LOG_TAG}': Creating volume %s\n' $volume
        docker volume create $volume
    done

    # Pass --init-downstream for newly created downstream volumes
    arguments=()
    if [[ -n "${newVolumes[@]}" ]]; then
        upstreams=($(awk '/^[^#].*upstream/{print $1}' $DVM_LOCK))
        newDownstream=${newVolumes[@]//*($(join '|' "${upstreams[@]}"))?( )}
        printf ${LOG_TAG}': %s\n' \
               "Found downstreams to init: $(join ' ' ${newVolumes[@]})"
        arguments+=("--init-downstream" "$(join , ${newDownstream[@]})")
    fi

    runDockerVolumeManager sync "${arguments[@]}"
}

BACKUP_VOLUMES=""
BACKUP_TAG=""
BACKUP_LOCATION=""
backupVolumes() {
    local args=()
    local volpathOverride="$VOLPATH"
    if [[ -n "$BACKUP_TAG" ]]; then
        args+=("--tag" "$BACKUP_TAG")
    fi
    if [[ -n "$BACKUP_LOCATION" ]]; then
        # TODO: This is bad; we know how runDockerVolumeManager constructs
        # VOLPATH for the container, and this is prone to breaking at next
        # refactor.
        args+=("--location" "/$(basename $BACKUP_LOCATION)-0")
        volpathOverride="$(realpath $BACKUP_LOCATION)"
    fi

    VOLPATH="$volpathOverride" runDockerVolumeManager backup \
           $(join ' ' "${args[@]}") "$BACKUP_VOLUMES"
}

RC=0
case $1 in
    start)
        syncVolumes
        printf ${LOG_TAG}': %s\n' "Starting docker services"
        docker-compose -f $COMPOSE_FILE up
        ;;
    rm)
        printf ${LOG_TAG}': %s\n' "Purging Docker containers and volumes"
        docker-compose -f $COMPOSE_FILE rm -fsv
        docker volume rm $(join ' ' "${VOLUME_NAMES[@]}")
        ;;
    backup)
        while [[ -n "$2" ]]; do
            case "$2" in
                --tag)
                    if [[ -n "$3" ]]; then BACKUP_TAG="$3" && shift
                    else >&2 printf ${LOG_TAG}': %s\n' "$USAGE" && return 1
                    fi ;;
                --location)
                    if [[ -n "$3" ]]; then BACKUP_LOCATION="$3" && shift
                    else >&2 printf ${LOG_TAG}': %s\n' "$USAGE" && return 1
                    fi ;;
                *)
                    BACKUP_VOLUMES="$2"
            esac
            shift
        done
        backupVolumes ;;
    *)
        >&2 printf '%s\n' "$USAGE"
        RC=1
        ;;
esac

###############################################################################