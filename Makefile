###############################################################################
# NAME:		    Makefile
#
# AUTHOR:	    Ethan D. Twardy <edtwardy@mtu.edu>
#
# DESCRIPTION:	    Makefile for the edtwardy-webservices package
#
# CREATED:	    04/26/2021
#
# LAST EDITED:	    05/26/2021
###

PACKAGE_NAME=edtwardy-webservices

configVolumes=siteconf
configVolumeImages=$(addsuffix -volume.tar.gz,$(configVolumes))
dataVolumes=

all: $(configVolumeImages) start-webservices

#: Generate a .tar.gz archive from a directory
siteconf-volume.tar.gz: $(shell find siteconf)
	tar czvf $@ $<

#: Generate volume images from the content in this repository
$(configVolumeImages): $(configVolumes)

volumemanager: buildah-volumemanager.sh
	./buildah-volumemanager.sh

start-webservices: start-webservices.in
	sed \
	-e "s/CONFIG_VOLUMES_DEF/CONFIG_VOLUMES=($(configVolumes))/" \
	-e "s/DATA_VOLUMES_DEF/DATA_VOLUMES=($(dataVolumes))/" \
	$< > $@

#: Install package files
install: shareDirectory=$(DESTDIR)/usr/share/$(PACKAGE_NAME)
install: configVolDir=$(shareDirectory)/config-volumes
install: start-webservices $(configVolumeImages)
	install -d $(shareDirectory)
	install docker-compose.yml -m 444 $(shareDirectory)
	install -d $(configVolDir)
	$(foreach i,$(configVolumeImages),install -m444 $(i) $(configVolDir))
	install -d $(DESTDIR)/lib/systemd/system
	install -m644 $(PACKAGE_NAME).service $(DESTDIR)/lib/systemd/system
	install -d $(DESTDIR)/bin
	install -m744 start-webservices $(DESTDIR)/bin
	install -d $(DESTDIR)/etc/$(PACKAGE_NAME)
	install -m644 docker-volume-manager.conf $(DESTDIR)/etc/$(PACKAGE_NAME)

clean:
	-rm -f start-webservices
	-rm -f volumemanager-digest
	-buildah rmi volumemanager
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
#------------------------------------------------------------------------------

###############################################################################
