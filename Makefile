###############################################################################
# NAME:		    Makefile
#
# AUTHOR:	    Ethan D. Twardy <edtwardy@mtu.edu>
#
# DESCRIPTION:	    Makefile for the edtwardy-webservices package
#
# CREATED:	    04/26/2021
#
# LAST EDITED:	    05/02/2021
###

VERSION=1.0
DEB_VERSION=1
PACKAGE_NAME=edtwardy-webservices

zipArchive = ../$(PACKAGE_NAME)_$(DEB_VERSION).orig.tar.xz

configVolumes=siteconf
dataVolumes=

define getImageName
$(addsuffix -volume.tar.gz,$(1))
endef

# generate: Generate a .tar.gz archive from a directory
define generate
tar czvf $(call getImageName,$(1)) $(1)
endef

all: volumeImages start-webservices

#: Generate volume images from the content in this repository
.PHONY: fake
volumeImages: fake
	$(foreach i,$(configVolumes),$(call generate,$(i)))

start-webservices: start-webservices.in
	sed \
	-e "s/CONFIG_VOLUMES_DEF/CONFIG_VOLUMES=($(configVolumes))/" \
	-e "s/DATA_VOLUMES_DEF/DATA_VOLUMES=($(dataVolumes))/" \
	$< > $@

zip: $(zipArchive)

$(zipArchive): fake
	tar cJvf $(zipArchive) .

#: Install package files
install: installVolumes=$(foreach i,$(configVolumes),$(call getImageName,$(i)))
install: shareDirectory=$(DESTDIR)/usr/share/$(PACKAGE_NAME)
install:
	install -d $(shareDirectory)
	install docker-compose.yml -m 444 $(shareDirectory)
	$(foreach i,$(installVolumes),install -m 444 $(i) $(shareDirectory))
	install -d $(DESTDIR)/lib/systemd/system
	install -m 644 $(PACKAGE_NAME).service $(DESTDIR)/lib/systemd/system
	install -d $(DESTDIR)/bin
	install -m 744 start-webservices $(DESTDIR)/bin

package: $(zipArchive)
	debuild -us -uc

# TODO: Write a clean rule and erase override_dh_clean

###############################################################################
