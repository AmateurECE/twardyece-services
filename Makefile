###############################################################################
# NAME:		    Makefile
#
# AUTHOR:	    Ethan D. Twardy <edtwardy@mtu.edu>
#
# DESCRIPTION:	    Makefile for the edtwardy-webservices package
#
# CREATED:	    04/26/2021
#
# LAST EDITED:	    11/01/2022
###

# Setup for build directory
BUILD_DIR = build
B := $(shell pwd)/$(BUILD_DIR)
$(shell mkdir -p $(B))

SUBDIRS += vps
SUBDIRS += tftp
SUBDIRS += webservices
SUBDIRS += jellyfin
SUBDIRS += dns

all: build-subdirs

.PHONY: force
BUILD_TARGETS += force
include declarations.mk

install: install-subdirs
containers: containers-subdirs

clean: clean-subdirs
	rm -rf build
	rm -rf debian/.debhelper
	rm -rf debian/files
	rm -rf debian/tmp
	rm -f debian/debhelper-build-stamp
	:
	rm -f debian/edtwardy-dns.postrm.debhelper
	rm -f debian/edtwardy-dns.substvars
	rm -rf debian/edtwardy-dns
	:
	rm -f debian/edtwardy-tftp.postrm.debhelper
	rm -f debian/edtwardy-tftp.substvars
	rm -rf debian/edtwardy-tftp
	:
	rm -f debian/edtwardy-vps.postrm.debhelper
	rm -f debian/edtwardy-vps.substvars
	rm -rf debian/edtwardy-vps
	:
	rm -f debian/edtwardy-webservices.postrm.debhelper
	rm -f debian/edtwardy-webservices.substvars
	rm -rf debian/edtwardy-webservices

#------------------------------------------------------------------------------
# These rules are related to packaging, and aren't used except for testing.
#------------------------------------------------------------------------------
PACKAGE_NAME=edtwardy-webservices
VERSION=1.0
DEB_VERSION=1
zipArchive = ../$(PACKAGE_NAME)_$(DEB_VERSION).orig.tar.xz

PACKAGES = \
	edtwardy-webservices \
	edtwardy-dns \
	edtwardy-vps \
	edtwardy-tftp

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
	dpkg --purge $(PACKAGES)
	dpkg -i ../*.deb
endif
#------------------------------------------------------------------------------

###############################################################################
