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

# Performance and Requirements:

* Currently, only systems utilizing `dpkg` are supported.
* Only `systemd` is supported.
* Docker is required.

<!-- TODO: Grab the size on disk (according to dpkg and Docker) -->
<!-- TODO: Grab memory requirements from systemd -->

# TODO: Private data archive
This package requires private data. It's not clear how it should be installed
(probably not as a dpkg dependency, though).

# TODO: Cron job to renew certificate

# TODO: Even some of the data volumes should be version controlled
Using the lock file

# TODO: Add ${QUIET} cmd to shell scripts (docker-volume-manager)
This is for the tar command.

# TODO: postrm script
This package should remove docker images and volumes when uninstalled.

# TODO: docker-volume-manager --init-data <,volumes>
The docker-volume-manager script should take an --init-data argument that
accepts a comma-separated list of data volumes to initialize from images. This
is to bootstrap data volumes upon first install.

# TODO: Django project as packaged pip application
