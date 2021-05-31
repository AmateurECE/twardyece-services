###############################################################################
# NAME:		    Makefile
#
# AUTHOR:	    Ethan D. Twardy <edtwardy@mtu.edu>
#
# DESCRIPTION:	    Makefile for the edtwardy-webservices package
#
# CREATED:	    04/26/2021
#
# LAST EDITED:	    05/30/2021
###

PACKAGE_NAME=edtwardy-webservices

configVolumes=siteconf
configVolumeImages=$(addsuffix -volume.tar.gz,$(configVolumes))
dataVolumes=

all: $(configVolumeImages) volumes.dvm.lock

#: Generate a .tar.gz archive from a directory
siteconf-volume.tar.gz: $(shell find siteconf)
	tar czvf $@ $<

#: Generate volume images from the content in this repository
$(configVolumeImages): $(configVolumes)

#: Generate the volumemanager docker image (a phony target)
volumemanager:
	./buildah-volumemanager.bash

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
	install -m744 start-webservices.bash $(DESTDIR)/bin/start-webservices
	install -d $(DESTDIR)/etc/$(PACKAGE_NAME)
	install -m644 dvm.conf $(DESTDIR)/etc/$(PACKAGE_NAME)

clean:
	-rm -f volumes.dvm.lock
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
