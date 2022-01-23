###############################################################################
# NAME:		    Makefile
#
# AUTHOR:	    Ethan D. Twardy <edtwardy@mtu.edu>
#
# DESCRIPTION:	    Rules for the edtwardy-tftp service.
#
# CREATED:	    10/25/2021
#
# LAST EDITED:	    01/23/2022
###

include ../declarations.mk

install: build
	install -d $(DESTDIR)/usr/share/edtwardy-tftp
	install -m444 docker-compose.yml $(DESTDIR)/usr/share/edtwardy-tftp
	install -d $(DESTDIR)/lib/systemd/system
	install -m644 edtwardy-tftp.service $(DESTDIR)/lib/systemd/system
	install -m444 mnt-Serve-tftp.mount $(DESTDIR)/lib/systemd/system

###############################################################################
