#!/bin/sh

set -e

chown -R jenkins:jenkins $REPOSITORY_MOUNT

CONTROLLER_HOSTNAME=http://edtwardy-webservices_jenkins-controller_1:8080
JNLP_PATH=jenkins/computer/docker-agent/jenkins-agent.jnlp
exec su jenkins -c "java -jar /usr/share/jenkins/agent.jar \
     -jnlpUrl $CONTROLLER_HOSTNAME/$JNLP_PATH \
     -secret @/secrets/jnlp-secret \
     -workDir /home/jenkins/agent"
