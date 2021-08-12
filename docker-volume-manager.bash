#!/usr/local/bin/bash
###############################################################################
# NAME:             docker-volume-manager.bash
#
# AUTHOR:           Ethan D. Twardy <edtwardy@mtu.edu>
#
# DESCRIPTION:      Manages Docker volumes. This script expects the following
#                   interface:
#
#                     1. It is installed in an image with a bash interpreter at
#                        /usr/local/bin/bash
#                     2. The working directory is '/'
#                     3. Paths to search for volume images are in env VOLPATH
#                     4. All volumes which are to be controlled are mounted.
#                        Otherwise, their contents will only be controlled to a
#                        transient volume (not persisting beyond the container)
#                     5. /volumes.dvm.lock exists and contains only volumes
#                        installed to paths in VOLPATH
#                     6. The following programs to be installed in PATH:
#                           * sha256sum
#                           * cat
#                           * awk
#                           * tar
#                           * tr
#
# CREATED:          05/22/2021
#
# LAST EDITED:      08/12/2021
###

read -r -d '' USAGE<<EOF
Usage: $0 sync [--init-downstream <downstreamVolumes>]
          backup [--tag <tag>] [--location <location>] [volumes,to,backup]

Arguments:
  sync [--init-downstream <downstreamVolumes>]
     Optionally takes a comma (,) separated list of names corresponding to
     downstream volumes (specified in volumes.dvm.lock) to be initialized from
     their archive images in VOLPATH.
  backup [--tag <tag>] [--location <location>] [backup,these,volumes]
     Backs up the downstream data volumes specified in volumes.dvm.lock. Or, if
     specified, backs up the volumes in the supplied comma-separated list. If
     tag is specified (with the "tag:" prefix!), a tags file is created (or the
     existing tags file is modified) to specify the tag for the backup image.
     If location is specified, it is the directory that the volumes are backed
     up to. If specified, this directory must exist beforehand.
EOF

read -r -d '' ALL_VOLUMES_AWK_SCRIPT<<EOF
/^#/{next};
NF == 0 {next};
NF < 2 {exit 1};
NF == 2 {print \$LINE,""; next};
{print}
EOF

set -e

LOG_TAG='docker-volume-manager'
INIT_DOWNSTREAM=()
BACKUP_ALL=n
BACKUP_VOLUMES=()
BACKUP_TAG=""
BACKUP_LOCATION=""
lockFile=/volumes.dvm.lock
if [[ ! -f $lockFile ]]; then
    printf ${LOG_TAG}': %s\n' "$lockFile not found; exiting"
    exit 1
fi

# join: Join a bash array by a delimiter
join() {
    local d=${1-} f=${2-};
    if shift 2; then
        printf %s "$f" "${@/#/$d}"
    fi
}

syncUpstream() {
    local name=$1 && shift

    if [[ -z "$VOLUME_IMAGE" ]]; then
        >&2 printf ${LOG_TAG}': %s %s\n' "Error: no volume image found for" \
            "volume $name. Exiting."
        return 1
    fi

    # The first argument contains information about the hash
    local hash=$1
    if [[ "$hash" = "unlocked" ]]; then
        printf ${LOG_TAG}': %s\n' "Processing u/u voume: $name"
        tar xzvf $volumeImage >/dev/null
        return 0
    elif [[ -z $(printf '%s\n' "$hash" | grep 'sha256') ]]; then
        >&2 printf ${LOG_TAG}': %s\n' "Unknown hash type for volume $name."
        return 1
    fi

    # Check the hash of the file
    printf ${LOG_TAG}': %s\n' "Checking hash for u/h volume: $name"
    printf '%s\n' "$(awk -F: '{print $2}' <<<$hash)  $volumeImage" |
        sha256sum -c -
    if [[ $? != 0 ]]; then
        >&2 printf ${LOG_TAG}': %s\n' "Volume $name failed hash check."
        return 1
    fi

    # Finally, unzip it.
    printf ${LOG_TAG}': %s\n' "Unzipping u/h volume: $name"
    tar xzvf $volumeImage >/dev/null
}

syncDownstream() {
    local name=$1 && shift

    local tag="$1"
    if [[ -n "$tag" ]]; then
        if [[ -z "$VOLUME_IMAGE" ]]; then
            >&2 printf ${LOG_TAG}': %s %s\n' "Error: tag specified for" \
                "volume $name, but no volume image found."
            return 1
        fi

        local tagsFile="$(dirname $VOLUME_IMAGE)/tags"
        if [[ ! -f "$tagsFile" ]]; then
            >&2 printf ${LOG_TAG}': %s %s\n' "Error: tag specified for" \
                "volume $name, but tags file does not exist."
            return 2
        fi

        local thisTag=$(awk "/^$name/"'{print $2}' "$tagsFile")
        if [[ "$thisTag" != "${tag/#tag:}" ]]; then
            >&2 printf ${LOG_TAG}': %s %s %s\n' "Error. Tag specified for" \
                "$name does not match the tag in the tags file." \
                "tags: $thisTag; lock: ${tag/#tag:}"
            return 1
        fi
    elif [[ -z "$tag" && -z "$VOLUME_IMAGE" ]]; then
        # Warn if there's no volume image
        printf ${LOG_TAG}': %s %s\n' "Warning: No volume image found for" \
               "volume $name"
        return 0
    fi

    if [[ "${INIT_DOWNSTREAM[@]}" =~ $name ]]; then
        # We've been instructed to initialize this downstream volume from an
        # upstream image
        printf ${LOG_TAG}': %s %s\n' "Initializing downstream volume $name" \
               "from $volumeImage"
        tar xzvf $volumeImage >/dev/null
    fi
}

sync() {
    printf ${LOG_TAG}': %s\n' "Parsing lock file"
    awk -f <(echo "$ALL_VOLUMES_AWK_SCRIPT") $lockFile |
        while read name volumeType arguments; do
            # Locate volume image file
            local volumeImage=""
            for location in $(printf '%s\n' "$VOLPATH" | tr ':' '\n'); do
                if [[ -f "$location/$name-volume.tar.gz" ]]; then
                    volumeImage="$location/$name-volume.tar.gz"
                    break
                fi
            done

            if [[ -z $volumeImage && "$volumeType" = "downstream" ]]; then
                >&2 printf '%s %s\n' \
                    "Warning: Couldn't find image for downstream" \
                    "volume $name"
                continue
            elif [[ -z $volumeImage ]]; then
                >&2 printf '%s\n' \
                    "Error: Could not find image for volume $name"
                continue
            fi

            case $volumeType in
                upstream)
                    VOLUME_IMAGE="$volumeImage" syncUpstream $name $arguments
                    ;;
                downstream)
                    VOLUME_IMAGE="$volumeImage" syncDownstream $name $arguments
                    ;;
                *)
                    >&2 printf ${LOG_TAG}': %s\n' \
                        "Ignoring unknown type $volumeType for $name."
            esac
        done

    if [[ "${PIPESTATUS[0]}" -eq 1 ]]; then
        printf ${LOG_TAG}': %s\n' "error while parsing $lockFile"
        exit 1
    fi
}

backup() {
    if [[ BACKUP_ALL = "y" ]]; then
        BACKUP_VOLUMES=($(awk '/^[^#].*downstream/{print $1}' $lockFile))
    fi

    printf ${LOG_TAG}': %s\n' "BACKUP_VOLUMES=${BACKUP_VOLUMES[@]}"
    for downstream in "${BACKUP_VOLUMES[@]}"; do
        # We've been instructed to backup the volume to a tar archive.
        local volumeImage="$BACKUP_LOCATION/$downstream-volume.tar.gz"
        printf ${LOG_TAG}': %s %s\n' "Archiving volume $downstream to" \
               "$volumeImage"
        tar czvf $volumeImage /$downstream >/dev/null
        update_tags $BACKUP_TAG $volumeImage
    done
}

########
# Main
#

printf ${LOG_TAG}': Arguments: %s\n' "$(join ' ' $@)"

case "$1" in
    sync)
        if [[ -n "$2" && -n "$3" ]]; then
            # 1. Either the next argument is the volume list
            IFS=, read -ra INIT_DOWNSTREAM<<<"$3" && shift && shift
            printf ${LOG_TAG}': %s\n' \
                   "INIT_DOWNSTREAM=$(join , ${INIT_DOWNSTREAM[@]})"
        elif [[ -n "$2" ]]; then
            >&2 printf ${LOG_TAG}': %s\n' \
                "Malformed --init-downstream directive."
            exit 1
        fi
        sync ;;

    backup)
        BACKUP_ALL=y
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
                    BACKUP_ALL=n
                    IFS=, read -ra BACKUP_VOLUMES<<<"$2" ;;
            esac
            shift
        done
        backup ;;

    *)
        >&2 printf ${LOG_TAG}': %s\n' "Unknown argument: $1" ;;
esac

printf ${LOG_TAG}': %s\n' "Finished."

###############################################################################
