# System Bootstrap Scripts

This repository contains scripts that I use to set up new systems with the
tools and software I rely on daily. Primarily, this repository is used to host
scripts that I use to initialize Linux systems with my web services.

# Components

1. `systemd` service: `edtwardy-webservices.service` provides `systemd` the
   means to orchestrate the services
2. Distribution packaging scripts: the `Makefile`, as well as the files under
   the `debian` directory allow packaging for distributions that utilize
   `dpkg`
3. Build scripts: the `Makefile`, as well as a few Bash scripts cleanly build
   artifacts needed for the services
4. Docker image creation scripts and docker-compose configurations
5. Custom applications and website configuration files
6. Cron jobs

# How this Repository Should Work:

The repository should cover the greatest extent of configuration deviations
possible. This mostly includes programs installed in PATH or installed packages
that don't belong to the current configuration.

1. (docker,mini-dinstall) Provide installation candidates for
   pre-configured software NOT available in the distribution repositories
3. (Ansible) Provide scripts to detect local modifications to
   configuration-controlled software.
3. (custom/Ansible) Provide scripts to detect programs in PATH not under
   configuration management.
4. (Ansible) Provide a script for machine configuration management and tracks
   versions of installed packages.

# Security Architecture

Identity management is fulfilled by an OpenLDAP service (`slapd`). Applications
query against this database for authentication and authorization.

TLS certificates are maintained by `certbot`, which is packaged with Docker and
automated on the host via cron (this is, naturally, distribution-specific).

For more information, see [Security](SecurityArchitecture.md)

# Performance and Requirements:

* Currently, only systems utilizing `dpkg` are supported.
* Only `systemd` is supported.
* Docker is required, as well as `docker-compose`.
* Bash is required on the host, as well as `cron` and `grep`.

# Open Container Images Used in this Package

Containers utilizing custom images are listed below.

1. [edtwardy/volumemanager:latest](
   https://hub.docker.com/repository/docker/edtwardy/volumemanager)
   This container is built from a custom Docker image, built on the Bash base
   image and a custom Bash script.
2. [nginx](https://hub.docker.com/_/nginx)
3. [certbot/certbot](https://hub.docker.com/r/certbot/certbot)
4. [osixia/openldap:stable](https://hub.docker.com/r/osixia/openldap)
5. [linuxserver/ldap-auth](https://hub.docker.com/r/linuxserver/ldap-auth)
6. [edtwardy/apps:latest](
   https://hub.docker.com/repository/docker/edtwardy/apps) This container is
   built from a custom Docker image, built on the python base image. It runs a
   series of Django applications served by uWSGI.
