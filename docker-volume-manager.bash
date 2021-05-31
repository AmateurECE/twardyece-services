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
# LAST EDITED:      05/30/2021
###

set -e

LOG_TAG='docker-volume-manager'

processUpstream() {
    local name=$1 && shift
    local volumeImage=$1 && shift

    # The first argument contains information about the hash
    local hash=$1
    if [[ "$hash" = "unlocked" ]]; then
        printf ${LOG_TAG}': %s\n' "Processing u/u voume: $name"
        tar xzvf $volumeImage
        return 0
    elif [[ -z $(printf '%s\n' "$hash" | grep 'sha256') ]]; then
        >&2 printf ${LOG_TAG}': %s\n' "Unknown hash type for volume $name."
        return 1
    fi

    # Check the hash of the file
    printf ${LOG_TAG}': %s\n' "Checking hash for u/h volume: $name"
    printf '%s\n' "$(awk -F: '{print $2}' <<<$hash)  $volumeImage"
    printf '%s\n' "$(sha256sum $volumeImage)"
    printf '%s\n' "$(awk -F: '{print $2}' <<<$hash)  $volumeImage" |
        sha256sum -c -
    if [[ $? != 0 ]]; then
        >&2 printf ${LOG_TAG}': %s\n' "Volume $name failed hash check."
        return 1
    fi

    # Finally, unzip it.
    printf ${LOG_TAG}': %s\n' "Unzipping u/h volume: $name"
    tar xzvf $volumeImage
}

processDownstream() {
    local name=$1 && shift
    local volumeImage=$1 && shift

    if [[ -n $1 && $1 =~ "--init-downstream" && "$1 $2" =~ $name ]]; then
        # We've been instructed to initialize this downstream volume from an
        # upstream image
        printf ${LOG_TAG}': %s\n' "Initializing d volume: $name"
        tar xzvf $volumeImage
    else
        # The rest of the time, downstream repos are easy--just archive them.
        printf ${LOG_TAG}': %s\n' "Archiving d volume: $name"
        tar czvf $volumeImage /$name
    fi
}

processVolume() {
    local name=$1 && shift
    local type=$1 && shift
    local arguments=$1

    # Locate volume image file
    local volumeImage
    for location in $(printf '%s\n' "$VOLPATH" | tr ':' '\n'); do
        if [[ -f "$location/$name-volume.tar.gz" ]]; then
            volumeImage="$location/$name-volume.tar.gz"
            break
        fi
    done

    if [[ -z $volumeImage ]]; then
        >&2 printf '%s\n' "Error: Could not find image for volume $name"
        exit 1
    fi

    case $type in
        upstream)
            processUpstream $name $volumeImage $arguments
            ;;
        downstream)
            processDownstream $name $volumeImage $arguments
            ;;
        *)
            >&2 printf ${LOG_TAG}': %s\n' "Unknown type $volume. Exiting."
    esac
}

########
# Main
#

lockFile=/volumes.dvm.lock
if [[ ! -f $lockFile ]]; then
    printf ${LOG_TAG}': %s\n' "$lockFile not found; exiting"
    exit 1
fi

# Must handle four cases:
#  1. Upstream,versioned: check hash sum, run "Upstream,unversioned" routine
#  2. Upstream,unversioned: decompress volume image
#  3. Downstream: compress contents of directory into volume image
#  4. Downstream,--init-downstream: decompress volume image
printf ${LOG_TAG}': %s\n' "Parsing lock file"
awk -f <(cat - <<EOF
/^#/{next};
NF == 0 {next};
NF < 2 {exit 1};
NF == 2 {print \$LINE,""; next};
{print}
EOF
        ) $lockFile |
    while read name volumeType arguments; do
        processVolume $name $volumeType $arguments
    done

if [[ "${PIPESTATUS[0]}" -eq 1 ]]; then
    printf ${LOG_TAG}': %s\n' "error while parsing $lockFile"
    exit 1
fi

printf ${LOG_TAG}': %s\n' "Finished."

###############################################################################
