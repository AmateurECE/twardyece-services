###############################################################################
# NAME:		    Makefile
#
# AUTHOR:	    Ethan D. Twardy <edtwardy@mtu.edu>
#
# DESCRIPTION:	    Makefile for the edtwardy-webservices package
#
# CREATED:	    04/26/2021
#
# LAST EDITED:	    01/16/2022
###

PACKAGE_NAME=edtwardy-webservices
BUILD_DIR = build
B := $(shell pwd)/$(BUILD_DIR)

$(shell mkdir -p build)

all: $(B)/siteconf-volume.tar.gz $(B)/volumes.dvm.lock
containers: $(B)/apps-build.lock $(B)/volumemanager-build.lock \
	$(B)/jenkins-agent-build.lock

#: Generate a .tar.gz archive from a directory
$(B)/siteconf-volume.tar.gz: $(shell find siteconf)
	tar czvf $@ $<

updateTagsDir=ContainerVolumeManager/UpdateTags
volumemanager-deps = \
	$(shell find $(updateTagsDir)/src) \
	$(updateTagsDir)/Cargo.toml \
	docker-volume-manager.bash \

ifdef SQUASH
squash=--squash
endif

define buildahBud
buildah bud --build-arg buildDir=$(BUILD_DIR) --layers $(squash) -f $(1) \
    -t "$(2):latest"
endef

#: Generate the volumemanager docker image
$(B)/volumemanager-build.lock: Containerfile.volumemanager $(volumemanager-deps)
	$(call buildahBud,$<,volumemanager)
	touch $@

basicssoWheel = $(B)/dist/djangobasicsso-0.1.0-py3-none-any.whl

$(basicssoWheel): $(shell find django-sandbox/basicsso) django-sandbox/setup.py
	cd $(B) && SOURCE_DIR=$(PWD)/django-sandbox python3 $(PWD)/django-sandbox/setup.py bdist_wheel

apps-deps = \
	$(shell find apps/apps) \
	apps/setup.py \
	apps/entrypoint.sh \
	apps/uwsgi.ini \
	apps/MANIFEST.in \
	requirements.apps.txt

#: Generate jenkins-agent image
$(B)/jenkins-agent-build.lock: Containerfile.jenkins-agent
	$(call buildahBud,$<,jenkins-agent)
	touch $@

#: Generate apps docker image
$(B)/apps-build.lock: Containerfile.apps $(apps-deps) $(basicssoWheel)
	$(call buildahBud,$<,apps)
	touch $@

#: Generate volumes.dvm.lock file
$(B)/volumes.dvm.lock: volumes.dvm.lock.in $(B)/siteconf-volume.tar.gz
	./prepare-volume-lockfile.bash $< $@ $(B)

subdirs = \
	webservices \
	tftp \
	vps \
	jellyfin \
	dns

define subdirInvoke
$(MAKE) -C edtwardy-$(1) $(2);
endef

#: Install package files
shareDirectory=$(DESTDIR)/usr/share/$(PACKAGE_NAME)
export shareDirectory
export B
configVolDir=$(shareDirectory)/volumes
install: $(configVolumeImages) $(B)/volumes.dvm.lock
	install -d $(shareDirectory)
	install -m444 docker-compose.yml $(shareDirectory)
	install -m444 $(B)/volumes.dvm.lock $(shareDirectory)
	install -d $(configVolDir)
	install -m444 $(B)/siteconf-volume.tar.gz $(configVolDir)
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
	$(foreach subdir,$(subdirs),$(call subdirInvoke,$(subdir),install))

clean:
	-rm -f volumes.dvm.lock
	-buildah rmi volumemanager
	-buildah rmi apps
	-rm -f *-volume.tar.gz
	$(foreach subdir,$(subdirs),$(call subdirInvoke,$(subdir),clean))

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
