#!/bin/sh

set -e

if [ -z "$CONTROLLER_HOSTNAME" ]; then
    >&2 printf '%s\n' "CONTROLLER_HOSTNAME must be set in the environment"
    exit 1
fi

exec /opt/java/openjdk/bin/java -jar /usr/share/jenkins/agent.jar \
     -url $CONTROLLER_HOSTNAME \
     -secret @/secrets/jnlp-secret \
     -name docker-agent \
     -tunnel jenkins.lan:50000 \
     -workDir /home/jenkins/agent
