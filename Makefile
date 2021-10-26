###############################################################################
# NAME:		    Makefile
#
# AUTHOR:	    Ethan D. Twardy <edtwardy@mtu.edu>
#
# DESCRIPTION:	    Makefile for the edtwardy-webservices package
#
# CREATED:	    04/26/2021
#
# LAST EDITED:	    10/25/2021
###

PACKAGE_NAME=edtwardy-webservices

configVolumes=siteconf
configVolumeImages=$(addsuffix -volume.tar.gz,$(configVolumes))

all: $(configVolumeImages) volumes.dvm.lock
containers: apps-build.lock volumemanager-build.lock jenkins-agent-build.lock

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

ifdef SQUASH
squash=--squash
endif

define buildahBud
buildah bud --layers $(squash) -f $(1) -t "$(2):latest"
endef

#: Generate the volumemanager docker image
volumemanager-build.lock: Containerfile.volumemanager $(volumemanager-deps)
	$(call buildahBud,$<,volumemanager)
	touch $@

basicssoWheel = django-sandbox/dist/djangobasicsso-0.1.0-py3-none-any.whl

$(basicssoWheel): $(shell find django-sandbox/basicsso) django-sandbox/setup.py
	cd django-sandbox && python3 setup.py bdist_wheel

apps-deps = \
	$(shell find apps/apps) \
	apps/setup.py \
	apps/entrypoint.sh \
	apps/uwsgi.ini \
	apps/MANIFEST.in \
	requirements.apps.txt

#: Generate jenkins-agent image
jenkins-agent-build.lock: Containerfile.jenkins-agent
	$(call buildahBud,$<,jenkins-agent)
	touch $@

#: Generate apps docker image
apps-build.lock: Containerfile.apps $(apps-deps) $(basicssoWheel)
	$(call buildahBud,$<,apps)
	touch $@

#: Generate volumes.dvm.lock file
volumes.dvm.lock: volumes.dvm.lock.in $(configVolumeImages)
	./prepare-volume-lockfile.bash $<

#: Install package files
shareDirectory=$(DESTDIR)/usr/share/$(PACKAGE_NAME)
export shareDirectory
configVolDir=$(shareDirectory)/volumes
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
	:
	: # edtwardy-tftp
	:
	$(MAKE) -C edtwardy-tftp install
	:
	: # edtwardy-vps
	:
	$(MAKE) -C edtwardy-vps install
	:
	: # edtwardy-jellyfin
	:
	$(MAKE) -C edtwardy-jellyfin install

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
