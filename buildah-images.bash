#!/bin/bash
###############################################################################
# NAME:             buildah-images.bash
#
# AUTHOR:           Ethan D. Twardy <edtwardy@mtu.edu>
#
# DESCRIPTION:      Generate OCI images for Docker Hub.
#
# CREATED:          05/22/2021
#
# LAST EDITED:      06/21/2021
###

read -r -d '' USAGE<<EOF
Usage: $0 <imageName> <outputFile>

Arguments:
  <imageName>       Build the recipe <imageName> using buildah. The base image
                    used by the recipe must be pulled from BASE_IMAGE env var.
  <outputFile>      Place image digests in <outputFile>
EOF

set -e
set -x

namespace=edtwardy

tagAndPush() {
    local containerId=$1 && shift
    local outputFile=$1 && shift
    local otherArgs=("$@")
    local cmd="${otherArgs[0]}"
    local miscConfig=("${otherArgs[@]:1}")

    # If cmd is empty, doing this first prevents a warning.
    buildah config --cmd "$cmd" $containerId
    buildah config \
            --author "Ethan D. Twardy <ethan.twardy@gmail.com>" \
            --workingdir '/' \
            "${miscConfig[@]}" \
            $containerId
    buildah commit $containerId $containerId

    # Push to the docker-daemon
    local objectId=$namespace/$containerId:latest
    buildah push localhost/$containerId docker-daemon:$objectId

    # Hash calculation
    # NOTE: The hash is somehow salted (or otherwise made non-deterministic).
    #   So, we cannot use the image hash as a means to check for updates.
    local imageHash=$(docker inspect $objectId --format='{{.RootFS.Layers}}' |
                          sed -E 's/[][]//g' | awk -F'[ :]' '{print $NF}')
    printf '%s  %s\n' $imageHash $namespace/$containerId > $outputFile
}

volumemanager() {
    local outputFile=$1 && shift
    local containerId=volumemanager
    local scriptFile=docker-volume-manager.bash

    buildah from --name=$containerId "$BASE_IMAGE"
    trap "set +e; buildah rm $containerId" EXIT

    buildah copy $containerId $scriptFile /bin/docker-volume-manager
    buildah run $containerId chmod 544 /bin/docker-volume-manager
    tagAndPush $containerId $outputFile '' \
               --entrypoint '["/bin/docker-volume-manager"]'
    sha256sum $scriptFile >> $outputFile
}

apps() {
    local outputFile=$1 && shift
    local containerId=apps

    # Create container
    buildah from --name=$containerId $BASE_IMAGE
    trap "set +e; buildah rm $containerId" EXIT

    # Copy directory into container
    (cd apps && python3 setup.py bdist_wheel)
    shopt -s nullglob
    local wheels=(apps/dist/*.whl)
    if [[ ${#wheels[@]} -eq 0 ]]; then
        >&2 printf '%s\n' "Something went wrong while building wheels for apps"
        exit 1
    fi

    printf '%s\n' "Installing ${wheels[0]} to container..."
    local wheelsFile=$(basename ${wheels[0]})
    buildah copy $containerId ${wheels[0]} /root/$wheelsFile
    local uwsgiBuildDeps="build-base linux-headers"
    local uwsgiVersion="2.0.19.1"
    buildah run $containerId apk add --no-cache $uwsgiBuildDeps
    buildah run $containerId python3 -m pip install --no-cache-dir \
            /root/$wheelsFile \
            uwsgi==$uwsgiVersion
    buildah run $containerId rm -f /root/$wheelsFile
    buildah run $containerId apk del $uwsgiBuildDeps
    buildah copy $containerId apps/entrypoint.sh /bin/entrypoint
    buildah copy $containerId apps/uwsgi.ini /etc/uwsgi.ini
    tagAndPush $containerId $outputFile '' \
               --entrypoint '["/bin/entrypoint"]' \
               --port 8000
    sha256sum ${wheels[0]} >> $outputFile
}

if [[ -z $2 || -z $BASE_IMAGE ]]; then
    >&2 printf '%s\n' "$USAGE"
fi

case $1 in
    volumemanager) volumemanager $2;;
    apps) apps $2;;
    *)
        >&2 printf '%s\n' "$USAGE"
esac

###############################################################################
