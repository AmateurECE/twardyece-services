###############################################################################
# NAME:		    Makefile
#
# AUTHOR:	    Ethan D. Twardy <edtwardy@mtu.edu>
#
# DESCRIPTION:	    Rules for the Yocto package
#
# CREATED:	    10/25/2021
#
# LAST EDITED:	    12/25/2022
###

SERVICE_NAME = twardyece-yocto
include ../declarations.mk

SERVICEDIR=$(DATADIR)/$(SERVICE_NAME)

install:
	install -d $(DESTDIR)$(SYSTEMD_SYSTEM_UNITDIR)
	install -m644 mnt-Serve-tftp.mount $(DESTDIR)$(SYSTEMD_SYSTEM_UNITDIR)
	install -m644 mnt-Serve-yocto-deploy.mount \
		$(DESTDIR)$(SYSTEMD_SYSTEM_UNITDIR)
	install -m644 mnt-Serve-yocto-sstate\\x2dcache.mount \
		$(DESTDIR)$(SYSTEMD_SYSTEM_UNITDIR)
	install -Dm644 nginx.yaml $(DESTDIR)$(NGINXDIR)/$(SERVICE_NAME).yaml

###############################################################################
