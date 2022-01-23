#!/bin/sh

set -e

CONTROLLER_HOSTNAME=http://edtwardy-webservices_jenkins-controller_1:8080
JNLP_PATH=jenkins/computer/docker-agent/jenkins-agent.jnlp
exec /opt/java/openjdk/bin/java -jar /usr/share/jenkins/agent.jar \
     -jnlpUrl $CONTROLLER_HOSTNAME/$JNLP_PATH \
     -secret @/secrets/jnlp-secret \
     -workDir /home/jenkins/agent
