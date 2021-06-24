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
# LAST EDITED:      06/24/2021
###

read -r -d '' USAGE<<EOF
Usage: $0 <command> [args]
          [--backup [volumes,to,backup]]

Arguments:
  sync [--init-downstream <downstreamVolumes>]
     Optionally takes a comma (,) separated list of names corresponding to
     downstream volumes (specified in volumes.dvm.lock) to be initialized from
     their archive images in VOLPATH.
  backup [backup,these,volumes]
     Backs up the downstream data volumes specified in volumes.dvm.lock. Or, if
     specified, backs up the volumes in the supplied comma-separated list.
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

processUpstream() {
    local name=$1 && shift
    local volumeImage=$1 && shift

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

processDownstream() {
    local name=$1 && shift
    local volumeImage=$1 && shift

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
                    processUpstream $name $volumeImage $arguments
                    ;;
                downstream)
                    processDownstream $name $volumeImage $arguments
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
    for downstream in "${BACKUP_VOLUMES[@]}"; do
        # We've been instructed to backup the volume to a tar archive.
        printf ${LOG_TAG}': %s\n' "Archiving d volume: $name"
        tar czvf $volumeImage /$name >/dev/null
    done
}

########
# Main
#

# TODO: This is being printed on multiple lines
printf ${LOG_TAG}': Arguments: %s\n' "$(join ' ' $@)"

while [[ -n "$1" ]]; do
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
            sync
            ;;
        backup)
            if [[ -z "$2" ]]; then
                # 1. Backup all
                BACKUP_ALL=y
            else
                IFS=, read -ra BACKUP_VOLUMES<<<"$2" && shift
            fi
            printf ${LOG_TAG}': %s\n' "BACKUP_VOLUMES=${BACKUP_VOLUMES[@]}"
            backup
            ;;
        *)
            >&2 printf ${LOG_TAG}': %s\n' "Unknown argument: $1"
    esac
    shift
done

printf ${LOG_TAG}': %s\n' "Finished."

###############################################################################
