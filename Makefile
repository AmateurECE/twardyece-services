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
SUBDIRS += tftp
SUBDIRS += yocto
SUBDIRS += vps
SUBDIRS += openldap
SUBDIRS += jenkins

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
PACKAGES = \
	twardyece-compilations

package:
	dpkg-buildpackage --no-sign -A -d

ifdef PACKAGE
reinstall:
	dpkg --purge $(PACKAGE)
	dpkg -i ../$(PACKAGE)*.deb
else
reinstall:
	dpkg --purge $(PACKAGES)
	dpkg -i ../*.deb
endif
#------------------------------------------------------------------------------

###############################################################################
