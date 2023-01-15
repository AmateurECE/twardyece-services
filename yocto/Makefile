###############################################################################
# NAME:		    Makefile
#
# AUTHOR:	    Ethan D. Twardy <edtwardy@mtu.edu>
#
# DESCRIPTION:	    Rules for the Yocto package
#
# CREATED:	    10/25/2021
#
# LAST EDITED:	    01/14/2023
###

SERVICE_NAME = yocto
include ../declarations.mk

install:
	install -d $(DESTDIR)$(SYSTEMD_SYSTEM_UNITDIR)
	install -m644 mnt-Serve-tftp.mount $(DESTDIR)$(SYSTEMD_SYSTEM_UNITDIR)
	install -m644 mnt-Serve-yocto-deploy.mount \
		$(DESTDIR)$(SYSTEMD_SYSTEM_UNITDIR)
	install -m644 mnt-Serve-yocto-sstate\\x2dcache.mount \
		$(DESTDIR)$(SYSTEMD_SYSTEM_UNITDIR)
	install -Dm644 nginx.yaml $(DESTDIR)$(NGINXDIR)/$(SERVICE_NAME).yaml

###############################################################################
