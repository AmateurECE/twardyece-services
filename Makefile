###############################################################################
# NAME:		    Makefile
#
# AUTHOR:	    Ethan D. Twardy <edtwardy@mtu.edu>
#
# DESCRIPTION:	    Makefile for the edtwardy-webservices package
#
# CREATED:	    04/26/2021
###

# Setup for build directory
BUILD_DIR = build
B := $(shell pwd)/$(BUILD_DIR)
$(shell mkdir -p $(B))

SUBDIRS += common
SUBDIRS += nginx
SUBDIRS += jellyfin
SUBDIRS += prowlarr
SUBDIRS += qbittorrent
SUBDIRS += tftp
SUBDIRS += yocto
SUBDIRS += vps
SUBDIRS += vpn
SUBDIRS += openldap
SUBDIRS += jenkins
SUBDIRS += redirect
SUBDIRS += blog

# Mask these packages for now. The applications don't work for one reason or
# another.
# SUBDIRS += postgres
# SUBDIRS += compilations
# SUBDIRS += dns
# SUBDIRS += budget-tool

all: build-subdirs

.PHONY: force
BUILD_TARGETS += force
include declarations.mk

install: install-subdirs

clean: clean-subdirs
	rm -rf $(B)
	rm -rf debian/.debhelper
	rm -f debian/debhelper-build-stamp
	rm -f debian/files
	rm -rf debian/tmp
	rm -f debian/*.substvars
	$(foreach subdir,$(SUBDIRS),rm -rf debian/twardyece-$(subdir))

#------------------------------------------------------------------------------
# Packaging
#------------------------------------------------------------------------------
package:
	dpkg-buildpackage --no-sign -A -d

reinstall:
	dpkg -i ../$(PACKAGE)*.deb
#------------------------------------------------------------------------------
