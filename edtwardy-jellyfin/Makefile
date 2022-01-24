###############################################################################
# NAME:		    Makefile
#
# AUTHOR:	    Ethan D. Twardy <edtwardy@mtu.edu>
#
# DESCRIPTION:	    Makefile for the edtwardy-jellyfin package
#
# CREATED:	    08/28/2021
#
# LAST EDITED:	    01/23/2022
###

include ../declarations.mk

PACKAGE_NAME=edtwardy-jellyfin

install: build
	install -d $(DESTDIR)/usr/share/$(PACKAGE_NAME)
	install -m644 docker-compose.yml $(DESTDIR)/usr/share/$(PACKAGE_NAME)
	install -d $(DESTDIR)/lib/systemd/system
	install -m644 $(PACKAGE_NAME).service $(DESTDIR)/lib/systemd/system
	install -d $(DESTDIR)/etc/volumetric/volumes.d
	install -m444 edtwardy-jellyfin.yaml \
		$(DESTDIR)/etc/volumetric/volumes.d

###############################################################################
