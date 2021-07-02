###############################################################################
# NAME:		    Makefile
#
# AUTHOR:	    Ethan D. Twardy <edtwardy@mtu.edu>
#
# DESCRIPTION:	    Makefile for the edtwardy-webservices package
#
# CREATED:	    04/26/2021
#
# LAST EDITED:	    06/28/2021
###

PACKAGE_NAME=edtwardy-webservices

configVolumes=siteconf
configVolumeImages=$(addsuffix -volume.tar.gz,$(configVolumes))
dataVolumes=

all: $(configVolumeImages) volumes.dvm.lock
containers: apps-build.lock volumemanager-build.lock

#: Generate a .tar.gz archive from a directory
siteconf-volume.tar.gz: $(shell find siteconf)
	tar czvf $@ $<

#: Generate volume images from the content in this repository
$(configVolumeImages): $(configVolumes)

updateTagsDir=ContainerVolumeManager/UpdateTags
volumemanager-deps = \
	$(shell find $(updateTagsDir)/src) \
	$(updateTagsDir)/Cargo.toml \
	docker-volume-manager.bash \

#: Generate the volumemanager docker image
volumemanager-build.lock: Containerfile.volumemanager $(volumemanager-deps)
	buildah bud --layers -f $< -t "volumemanager:latest"
	touch $@

apps-deps = \
	$(shell find apps/apps) \
	apps/setup.py \
	apps/entrypoint.sh \
	apps/uwsgi.ini \
	requirements.apps.txt

#: Generate apps docker image
apps-build.lock: Containerfile.apps $(apps-deps)
	buildah bud --layers -f $< -t "apps:latest"
	touch $@

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
