# System Bootstrap Scripts

This repository contains scripts that I use to set up new systems with the
tools and software I rely on daily. Primarily, this repository is used to host
scripts that I use to initialize Linux systems with my web services.

# Linux System Setup

The system setup script for Linux is contained in `linux-bootstrap.sh`, which
is a standard shell script (not Bash, so that it can be run in Busybox, if need
be). This script attempts to detect the distribution, but currently only the
following distributions are supported:

* Debian

This script performs the following actions (generally):

* Install required tools for web services (docker, Python 3, etc.)
* Pull the Docker services from Dockerhub
* Install system services to start up the Docker services upon system startup.
  Only systemd is supported, currently, but the script is written to support
  OpenRC (or any other init system) as necessary.
* Set up GPG keys for git
* Set up OpenSSH:
  - Download the package for a distribution
  - Execute Shell script to generate patch
  - Apply patch
  - Rebuild package

# How this Repository Should Work:

The repository should cover the greatest extent of configuration deviations
possible. This mostly includes programs installed in PATH or installed packages
that don't belong to the current configuration.

1. (docker,mini-dinstall,repo-add) Provide installation candidates for
   pre-configured software
2. (custom) Provide scripts to generate the pre-configured software packages
3. (custom? ansible?) Provide scripts to detect local modifications to
   configuration-controlled software.
3. (custom/ansible?) Provide scripts to detect programs in PATH not under
   configuration management.
4. (Ansible) Provide a script for machine configuration management and tracks
   versions of installed packages.
