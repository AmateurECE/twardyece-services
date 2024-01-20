#!/bin/sh

set -e

if [ -z "$CONTROLLER_HOSTNAME" ]; then
    >&2 printf '%s\n' "CONTROLLER_HOSTNAME must be set in the environment"
    exit 1
fi

JNLP_PATH=${JENKINS_PREFIX}computer/$AGENT_NAME/jenkins-agent.jnlp
exec /opt/java/openjdk/bin/java -jar /usr/share/jenkins/agent.jar \
     -jnlpUrl $CONTROLLER_HOSTNAME/$JNLP_PATH \
     -secret @/secrets/jnlp-secret \
     -workDir /home/jenkins/agent
