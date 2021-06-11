#!/bin/bash
###############################################################################
# NAME:             buildah-volumemanager.bash
#
# AUTHOR:           Ethan D. Twardy <edtwardy@mtu.edu>
#
# DESCRIPTION:      Generate the volumemanager OCI for Docker Hub.
#
# CREATED:          05/22/2021
#
# LAST EDITED:      06/07/2021
###

read -r -d '' USAGE<<EOF
Usage: $0 <command>

Commands:
  build             Build the image using buildah
EOF

set -e

containerId=volumemanager
namespace=edtwardy
outputFile=image-build.out.lock

build() {
    trap "set +e; buildah rm $containerId" EXIT

    local scriptFile=docker-volume-manager.bash
    buildah from --name=$containerId registry.hub.docker.com/library/bash
    buildah copy $containerId $scriptFile /bin/docker-volume-manager
    buildah run $containerId chmod 544 /bin/docker-volume-manager
    # Clear cmd first to prevent 'ignored cmd' warning
    buildah config --cmd '' $containerId
    buildah config --entrypoint '["/bin/docker-volume-manager"]' \
            --author "Ethan D. Twardy <ethan.twardy@gmail.com>" \
            --workingdir '/' \
            $containerId
    buildah commit $containerId $containerId

    # Push to the docker-daemon
    local objectId=$namespace/$containerId:latest
    buildah push localhost/$containerId docker-daemon:$objectId

    # Hash calculation
    # NOTE: The hash is somehow salted (or otherwise made non-deterministic).
    #   So, we cannot use the image hash as a means to check for updates.
    local imageHash=$(docker inspect $objectId --format='{{.RootFS.Layers}}' |
                          sed -E 's/[][]//g' | awk -F'[ :]' '{print $8}')
    printf '%s  %s\n' $imageHash $namespace/$containerId > $outputFile
    sha256sum $scriptFile >> $outputFile
}

case $1 in
    build)
        build
        ;;
    *)
        >&2 printf '%s\n' "$USAGE"
esac

###############################################################################

