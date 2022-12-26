###############################################################################
# NAME:		    Makefile
#
# AUTHOR:	    Ethan D. Twardy <edtwardy@mtu.edu>
#
# DESCRIPTION:	    Supporting build script for fundamental webservices
#		    infrastructure
#
# CREATED:	    10/25/2021
#
# LAST EDITED:	    12/25/2022
###

PACKAGE_NAME=edtwardy-webservices

BUILD_TARGETS += $(B)/siteconf-volume.tar.gz

MAKEFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
S := $(PWD)/$(notdir $(patsubst %/,%,$(dir $(MAKEFILE_PATH))))

include ../declarations.mk

#: Generate a .tar.gz archive from a directory
$(B)/siteconf-volume.tar.gz: $(shell find siteconf)
	tar czvf $@ -C $< .

install: build
	: # Docker compose and volumes
	install -d $(DESTDIR)/usr/share/$(PACKAGE_NAME)
	install -m444 docker-compose.yml $(DESTDIR)/usr/share/$(PACKAGE_NAME)
	install -m444 $(B)/siteconf-volume.tar.gz \
		$(DESTDIR)/usr/share/$(PACKAGE_NAME)
	install -d $(DESTDIR)/etc/volumetric/volumes.d
	install -m444 edtwardy-webservices.yaml \
		$(DESTDIR)/etc/volumetric/volumes.d
	:
	: # systemd files
	install -d $(DESTDIR)/lib/systemd/system
	install -m644 $(PACKAGE_NAME).service $(DESTDIR)/lib/systemd/system
	install -m644 mnt-Serve-yocto-sstate\\x2dcache.mount \
		$(DESTDIR)/lib/systemd/system
	install -m644 mnt-Serve-yocto-deploy.mount \
		$(DESTDIR)/lib/systemd/system
	install -m644 jenkins-builder.service $(DESTDIR)/lib/systemd/system
	:
	: # CNI network configuration file for the webservices
	install -d $(DESTDIR)/etc/cni/net.d
	install -m644 edtwardy-webservices_front_net.conflist \
		$(DESTDIR)/etc/cni/net.d

###############################################################################
