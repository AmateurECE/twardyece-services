###############################################################################
# NAME:		    Makefile
#
# AUTHOR:	    Ethan D. Twardy <edtwardy@mtu.edu>
#
# DESCRIPTION:	    Makefile for the edtwardy-webservices package
#
# CREATED:	    04/26/2021
#
# LAST EDITED:	    06/22/2021
###

PACKAGE_NAME=edtwardy-webservices

configVolumes=siteconf
configVolumeImages=$(addsuffix -volume.tar.gz,$(configVolumes))
dataVolumes=

buildahImages=volumemanager-build.lock apps-build.lock
dockerHub=docker.io
appsBaseImage=$(dockerHub)/library/python:3.8.10-alpine3.13
volumemanagerBaseImage=$(dockerHub)/library/bash:5.1.8

all: $(configVolumeImages) volumes.dvm.lock $(buildahImages)

#: Generate a .tar.gz archive from a directory
siteconf-volume.tar.gz: $(shell find siteconf)
	tar czvf $@ $<

#: Generate volume images from the content in this repository
$(configVolumeImages): $(configVolumes)

apps-env:
	docker run --rm -it -v "$(PWD)/apps:/apps" --name $@ $(appsBaseImage) \
		/bin/sh -c \
		"python3 -m pip install pip-tools && cd apps && pip-compile"

#: Generate the volumemanager docker image (a phony target)
volumemanager-build.lock: export BASE_IMAGE=$(volumemanagerBaseImage)
volumemanager-build.lock: docker-volume-manager.bash buildah-images.bash
	./buildah-images.bash volumemanager $@

apps-build.lock: export BASE_IMAGE = $(appsBaseImage)
apps-build.lock: buildah-images.bash $(shell find apps)
	./buildah-images.bash apps $@

#: Generate volumes.dvm.lock file
volumes.dvm.lock: volumes.dvm.lock.in $(configVolumeImages)
	./prepare-volume-lockfile.bash $<

#: Install package files
install: shareDirectory=$(DESTDIR)/usr/share/$(PACKAGE_NAME)
install: configVolDir=$(shareDirectory)/volumes
install: $(configVolumeImages) volumes.dvm.lock
	install -d $(shareDirectory)
	install -m444 docker-compose.yml $(shareDirectory)
	install -m444 volumes.dvm.lock $(shareDirectory)
	install -d $(configVolDir)
	$(foreach i,$(configVolumeImages),install -m444 $(i) $(configVolDir))
	install -d $(DESTDIR)/lib/systemd/system
	install -m644 $(PACKAGE_NAME).service $(DESTDIR)/lib/systemd/system
	install -d $(DESTDIR)/bin
	install -m744 edtwardy-webservices.bash \
		$(DESTDIR)/bin/edtwardy-webservices
	install -d $(DESTDIR)/etc/$(PACKAGE_NAME)
	install -m644 dvm.conf $(DESTDIR)/etc/$(PACKAGE_NAME)
	install -d $(DESTDIR)/etc/cron.daily
	install -m544 renew-certificates.bash \
		$(DESTDIR)/etc/cron.daily/renewcertificates

clean:
	-rm -f volumes.dvm.lock
	-buildah rmi volumemanager
	-buildah rmi apps
	-rm -f *-volume.tar.gz

#------------------------------------------------------------------------------
# These rules are related to packaging, and aren't used except for testing.
#------------------------------------------------------------------------------
VERSION=1.0
DEB_VERSION=1
zipArchive = ../$(PACKAGE_NAME)_$(DEB_VERSION).orig.tar.xz

.PHONY: fake

zip: $(zipArchive)

$(zipArchive): fake
	tar cJvf $(zipArchive) .

package: $(zipArchive)
	debuild -us -uc

reinstall:
	dpkg --purge $(PACKAGE_NAME)
	dpkg -i ../*.deb
	systemctl restart $(PACKAGE_NAME)
#------------------------------------------------------------------------------

###############################################################################
