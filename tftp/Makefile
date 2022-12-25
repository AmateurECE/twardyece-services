###############################################################################
# NAME:		    Makefile
#
# AUTHOR:	    Ethan D. Twardy <edtwardy@mtu.edu>
#
# DESCRIPTION:	    Rules for the edtwardy-tftp service.
#
# CREATED:	    10/25/2021
#
# LAST EDITED:	    12/25/2022
###

SERVICE_NAME = twardyece-tftp
include ../declarations.mk

SERVICEDIR=$(DATADIR)/$(SERVICE_NAME)

install:
	install -Dm644 $(SERVICE_NAME).service \
		$(DESTDIR)$(SYSTEMD_SYSTEM_UNITDIR)/$(SERVICE_NAME).service
	install -Dm644 docker-compose.yaml \
		$(DESTDIR)$(SERVICEDIR)/docker-compose.yaml
	install -Dm644 mnt-Serve-tftp.mount $(DESTDIR)$(SYSTEMD_SYSTEM_UNITDIR)

###############################################################################
