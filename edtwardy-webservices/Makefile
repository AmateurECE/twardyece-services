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
# LAST EDITED:	    02/26/2022
###

PACKAGE_NAME=edtwardy-webservices

BUILD_TARGETS += $(B)/siteconf-volume.tar.gz
BUILD_TARGETS += $(B)/Containerfile.jenkins-agent
BUILD_TARGETS += $(B)/jenkins-agent-cmd.sh

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
	: # Start/stop script
	install -d $(DESTDIR)/bin
	install -m744 edtwardy-webservices.bash \
		$(DESTDIR)/bin/edtwardy-webservices
	install -m755 webservices-certbot.sh $(DESTDIR)/bin/webservices-certbot
	:
	: # Certificate renewal cron
	install -d $(DESTDIR)/etc/cron.daily
	install -m544 renew-certificates.bash \
		$(DESTDIR)/etc/cron.daily/renewcertificates
	:
	: # systemd files
	install -d $(DESTDIR)/lib/systemd/system
	install -m644 $(PACKAGE_NAME).service $(DESTDIR)/lib/systemd/system
	install -m644 mnt-Serve-yocto-sstate\\x2dcache.mount \
		$(DESTDIR)/lib/systemd/system
	install -m644 mnt-Serve-yocto-esdk.mount $(DESTDIR)/lib/systemd/system
	install -m644 jenkins-builder.service $(DESTDIR)/lib/systemd/system

$(B)/jenkins-agent-cmd.sh: jenkins-agent-cmd.sh; cp $< $@
$(B)/Containerfile.jenkins-agent: Containerfile.jenkins-agent; cp $< $@

$(B)/jenkins-agent-build.lock: $(B)/Containerfile.jenkins-agent $(B)/build.lock
	$(call buildahBud,$<,jenkins-agent)
	touch $@

containers: $(B)/jenkins-agent-build.lock

###############################################################################
