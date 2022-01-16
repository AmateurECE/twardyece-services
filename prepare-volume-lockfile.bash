#!/bin/bash
###############################################################################
# NAME:             prepare-volume-lockfile.sh
#
# AUTHOR:           Ethan D. Twardy <edtwardy@mtu.edu>
#
# DESCRIPTION:      Prepare volumes.dvm.lock file used by docker-volume-manager
#
# CREATED:          05/29/2021
#
# LAST EDITED:      01/16/2022
###

read -r -d '' USAGE<<EOF
Usage: $0 <lock.in> <lockfile> <volume-dir>

Prepares <lockfile> using the file at the path <lock.in> and the volumes
in <volume-dir>
EOF

set -e

NO_VOLUME_IMAGE_FOR_UPSTREAM="\
Error: $name configured as upstream but no image found."

prepareUpstream() {
    local name=$1 && shift
    local hash=$1 && shift
    local build=$1 && shift

    local volume="$build/$name-volume.tar.gz"
    if [[ ! -f "$volume" && "$hash" = "<hash>" ]]; then
        >&2 printf '%s\n' "$NO_VOLUME_IMAGE_FOR_UPSTREAM"
        return 1
    elif [[ "$hash" = "<hash>" ]]; then
        hash="sha256:$(sha256sum "$volume" | awk '{print $1}')"
    fi

    firstColumn=30
    firstPad=$(($firstColumn - ${#name}))
    if [[ ${#name} -ge $firstColumn ]]; then
        firstPad=1
    fi
    printf '%s%*s%80s\n' "$name" $firstPad "upstream" "$hash"
}

prepareDownstream() {
    local name=$1 && shift

    firstColumn=30
    firstPad=$(($firstColumn - ${#name}))
    if [[ ${#name} -ge $firstColumn ]]; then
        firstPad=1
    fi

    if [[ -n "$1" ]]; then
        # This volume has options
        printf '%s%*s%80s\n' "$name" $firstPad "downstream" "$1"
    else
        printf '%s%*s\n' "$name" $firstPad "downstream"
    fi
}

########
# Main
#

if [[ -z $1 || -z $2 || -z $3 ]]; then
    >&2 printf '%s\n' "$USAGE"
    exit 1
fi

LOCK_FILE=$2
BUILD=$3

if [[ -f $LOCK_FILE ]]; then
    rm -f $LOCK_FILE
fi

awk -f <(cat - <<EOF
/^#/{next};
NF == 0 {next};
NF < 2 {exit 1};
NF == 2 {print \$LINE,""; next};
{print}
EOF
        ) $1 |
    while read name type arguments; do
        case $type in
            upstream)
                prepareUpstream "$name" "$arguments" "$BUILD" >> $LOCK_FILE
                ;;
            downstream)
                prepareDownstream "$name" "$arguments" >> $LOCK_FILE
                ;;
            *)
                >&2 printf '%s\n' "Error while parsing $1: Unknown type $type"
                ;;
        esac
    done

if [[ "$PIPESTATUS" -eq 1 ]]; then
    >&2 printf '%s\n' "Error while reading $1: Incorrect format"
fi

###############################################################################
