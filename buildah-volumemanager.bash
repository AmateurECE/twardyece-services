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
# LAST EDITED:      05/30/2021
###

read -r -d '' USAGE<<EOF
Usage: $0 <build | push-daemon | push-dockerhub>

Commands:
  build             Build the image using buildah
  push-daemon       Push the image to the Docker Daemon
EOF

set -e

containerId=volumemanager
namespace=edtwardy

cleanup() {
    set +e
    buildah rm $containerId
}

build() {
    trap cleanup EXIT

    buildah from --name=$containerId registry.hub.docker.com/library/bash
    buildah copy $containerId docker-volume-manager.bash \
            /bin/docker-volume-manager
    buildah run $containerId chmod 544 /bin/docker-volume-manager
    buildah config \
            --entrypoint "/bin/docker-volume-manager" \
            --author "Ethan D. Twardy <ethan.twardy@gmail.com>" \
            --workingdir '/' \
            $containerId
    buildah commit $containerId $containerId
}

pushDaemon() {
    buildah push localhost/$containerId \
            docker-daemon:$namespace/$containerId:latest
}

case $1 in
    build)
        build
        ;;
    push-daemon)
        pushDaemon
        ;;
    *)
        >&2 printf '%s\n' "$USAGE"
esac

###############################################################################

