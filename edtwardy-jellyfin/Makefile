###############################################################################
# NAME:		    Makefile
#
# AUTHOR:	    Ethan D. Twardy <edtwardy@mtu.edu>
#
# DESCRIPTION:	    Makefile for the edtwardy-jellyfin package
#
# CREATED:	    08/28/2021
#
# LAST EDITED:	    08/28/2021
###

PACKAGE_NAME=edtwardy-jellyfin

install: shareDir=$(DESTDIR)/usr/share/$(PACKAGE_NAME)
install: serviceDir=$(DESTDIR)/lib/systemd/system
install:
	install -d $(shareDir)
	install -m644 docker-compose.yml $(shareDir)
	install -d $(serviceDir)
	install -m644 $(PACKAGE_NAME).service $(serviceDir)

###############################################################################
