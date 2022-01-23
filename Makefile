###############################################################################
# NAME:		    Makefile
#
# AUTHOR:	    Ethan D. Twardy <edtwardy@mtu.edu>
#
# DESCRIPTION:	    Makefile for the edtwardy-webservices package
#
# CREATED:	    04/26/2021
#
# LAST EDITED:	    01/23/2022
###

# Setup for build directory
BUILD_DIR = build
B := $(shell pwd)/$(BUILD_DIR)
$(shell mkdir -p $(B))

SUBDIRS += vps
SUBDIRS += tftp
SUBDIRS += webservices
SUBDIRS += apps
SUBDIRS += jellyfin
SUBDIRS += dns

all: build-subdirs

.PHONY: force
BUILD_TARGETS += force
include declarations.mk

install: install-subdirs
containers: containers-subdirs

#------------------------------------------------------------------------------
# These rules are related to packaging, and aren't used except for testing.
#------------------------------------------------------------------------------
PACKAGE_NAME=edtwardy-webservices
VERSION=1.0
DEB_VERSION=1
zipArchive = ../$(PACKAGE_NAME)_$(DEB_VERSION).orig.tar.xz

.PHONY: fake

zip: $(zipArchive)

$(zipArchive): fake
	tar cJvf $(zipArchive) `ls | grep -v '^\.git$$'`

package: $(zipArchive)
	debuild -us -uc

ifdef BINARY_PACKAGE
reinstall:
	dpkg --purge edtwardy-$(BINARY_PACKAGE)
	dpkg -i ../edtwardy-$(BINARY_PACKAGE)*.deb
else
reinstall:
	dpkg --purge edtwardy-plex edtwardy-webservices
	dpkg -i ../*.deb
endif
#------------------------------------------------------------------------------

###############################################################################
