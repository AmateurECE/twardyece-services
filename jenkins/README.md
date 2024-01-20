# Jenkins Infrastructure

This directory contains a few artifacts--a debian package, that installs a
Jenkins controller and agent, and the Containerfiles to build both of those
applications.

To build the controller image:

```
podman build -t localhost/amateurece/jenkins:latest \
	-f Containerfile.controller .
```

To build the agent image:

```
podman build -t localhost/amateurece/jenkins-agent:latest \
	-f Containerfile.controller .
```
